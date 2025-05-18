package com.ims185.config;

import jakarta.servlet.ServletContext;
import java.nio.file.Path;
import java.nio.file.Paths;

public class FilePaths {
    private static String dataDirectory;
    private static String uploadDirectory;

    public static void initialize(ServletContext context) {
        // Get the application's real path
        String appPath = context.getRealPath("/");
        System.out.println("FilePaths.initialize - App Path: " + appPath);

        // Set up data directory in WEB-INF for security
        dataDirectory = Paths.get(appPath, "WEB-INF", "data").toString();
        uploadDirectory = Paths.get(dataDirectory, "uploads").toString();

        // Create directories if they don't exist
        createDirectories();

        System.out.println("Initialized FilePaths: dataDirectory = " + dataDirectory);
    }

    public static String getDataDirectory() {
        // If dataDirectory hasn't been initialized yet, provide a fallback location
        if (dataDirectory == null) {
            System.out.println("WARNING: FilePaths.dataDirectory was null when getDataDirectory was called!");
            // Default to target directory
            return Paths.get(System.getProperty("user.dir"), "target", "IMS-185", "WEB-INF", "data").toString();
        }
        return dataDirectory;
    }

    public static String getUploadDirectory() {
        return uploadDirectory;
    }

    public static String getUsersFile() {
        return Paths.get(dataDirectory, "users.txt").toString();
    }

    public static String getItemsFile() {
        return Paths.get(dataDirectory, "items.txt").toString();
    }

    public static String getCustomersFile() {
        return Paths.get(dataDirectory, "customers.txt").toString();
    }

    public static String getNotificationsFile() {
        return Paths.get(dataDirectory, "notifications.txt").toString();
    }

    public static String getAuditTrailFile() {
        return Paths.get(dataDirectory, "audittrail.txt").toString();
    }
    private static void createDirectories() {
        try {
            // Create data directory
            Path dataPath = Paths.get(dataDirectory);
            if (!dataPath.toFile().exists()) {
                dataPath.toFile().mkdirs();
            }

            // Create upload directory
            Path uploadPath = Paths.get(uploadDirectory);
            if (!uploadPath.toFile().exists()) {
                uploadPath.toFile().mkdirs();
            }

            // Create images directory within upload directory
            Path imagesPath = Paths.get(uploadDirectory, "images");
            if (!imagesPath.toFile().exists()) {
                imagesPath.toFile().mkdirs();
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to create required directories: " + e.getMessage());
        }
    }
}
