package com.ims185.servlet;

import com.ims185.model.Item;
import com.ims185.config.FilePaths;
import com.ims185.util.ActivityLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Logger;
import java.util.stream.Collectors;



@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,  // 1 MB
        maxFileSize = 1024 * 1024 * 10,   // 10 MB
        maxRequestSize = 1024 * 1024 * 50, // 50 MB
        location = "C:/IMS-185-Data/Uploads"
)
public class InventoryServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(InventoryServlet.class.getName());

    private List<Item> loadItemsFromFile() {
        List<Item> items = new ArrayList<>();
        Path inventoryFile = Paths.get(FilePaths.getDataDirectory(), "inventory.txt");
        File file = inventoryFile.toFile();

        // Ensure directory exists
        if (!file.getParentFile().exists()) {
            boolean created = file.getParentFile().mkdirs();
            LOGGER.info("Created directory " + file.getParentFile().getPath() + ": " + created);
        }

        // Create file if it doesn't exist
        if (!file.exists()) {
            try {
                if (file.createNewFile()) {
                    LOGGER.info("Created inventory.txt");
                }
            } catch (IOException e) {
                LOGGER.severe("Failed to create inventory.txt: " + e.getMessage());
                return items;
            }
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 10) {
                    try {
                        Item item = new Item();
                        item.setId(Integer.parseInt(parts[0]));
                        item.setName(parts[1]);
                        item.setCategory(parts[2]);
                        item.setStock(Integer.parseInt(parts[3]));
                        item.setPrice(Double.parseDouble(parts[4]));
                        item.setItemId(parts[5]);
                        item.setImagePath(parts[6]);
                        item.setExpiryDate(parts[7]);
                        item.setAddedDate(parts[8]);
                        item.setLastUpdatedDate(parts[9]);
                        items.add(item);
                    } catch (NumberFormatException e) {
                        LOGGER.warning("Skipping line due to parsing error: " + line);
                    }
                }
            }
        } catch (IOException e) {
            LOGGER.severe("Error reading inventory.txt: " + e.getMessage());
        }
        return items;
    }

    private void saveItemsToFile(List<Item> items) {
        Path inventoryFile = Paths.get(FilePaths.getDataDirectory(), "inventory.txt");
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(inventoryFile.toFile()))) {
            for (Item item : items) {
                writer.write(String.format("%d,%s,%s,%d,%.2f,%s,%s,%s,%s,%s%n",
                        item.getId(),
                        item.getName(),
                        item.getCategory() != null ? item.getCategory() : "",
                        item.getStock(),
                        item.getPrice(),
                        item.getItemId(),
                        item.getImagePath() != null ? item.getImagePath() : "",
                        item.getExpiryDate() != null ? item.getExpiryDate() : "",
                        item.getAddedDate() != null ? item.getAddedDate() : "",
                        item.getLastUpdatedDate() != null ? item.getLastUpdatedDate() : ""));
            }
            LOGGER.info("Saved " + items.size() + " items to inventory.");
        } catch (IOException e) {
            LOGGER.severe("Error saving inventory: " + e.getMessage());
        }
    }    private String saveImage(Part filePart, String itemId) {
        if (filePart != null && filePart.getSize() > 0) {
            try {
                String fileName = itemId + "_" + UUID.randomUUID().toString() + ".jpg";
                // Create images directory within upload directory
                Path imagesPath = Paths.get(FilePaths.getUploadDirectory(), "images");
                if (!imagesPath.toFile().exists()) {
                    imagesPath.toFile().mkdirs();
                }
                String contentType = filePart.getContentType();
                String extension = contentType != null && contentType.contains("/")
                        ? contentType.split("/")[1]
                        : "jpg";
                fileName = fileName.replace(".jpg", "." + extension);
                Path filePath = imagesPath.resolve(fileName);
                filePart.write(filePath.toString());
                // Return path relative to upload directory
                return "images/" + fileName;
            } catch (IOException e) {
                LOGGER.severe("Error saving image: " + e.getMessage());
            }
        }
        return "";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Item> items = loadItemsFromFile();

        // Sort items if requested
        String sortBy = request.getParameter("sort");
        if ("expiry".equals(sortBy)) {
            items = sortItemsByExpiryDate(items);
        }

        // Filter items if search query exists
        final String searchQuery = request.getParameter("search");
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            final String query = searchQuery.toLowerCase();
            items = items.stream()
                    .filter(item ->
                            (item.getName() != null && item.getName().toLowerCase().contains(query)) ||
                                    (item.getItemId() != null && item.getItemId().toLowerCase().contains(query)))
                    .collect(Collectors.toList());
        }

        request.setAttribute("items", items);
        request.getRequestDispatcher("/inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        List<Item> items = loadItemsFromFile();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

        try {
            if ("Add".equals(action)) {
                // Create new item
                Item item = new Item();
                item.setId(items.isEmpty() ? 1 : items.stream().mapToInt(Item::getId).max().getAsInt() + 1);
                item.setName(request.getParameter("name"));
                item.setCategory(request.getParameter("category"));
                item.setStock(Integer.parseInt(request.getParameter("stock")));
                item.setPrice(Double.parseDouble(request.getParameter("price")));
                item.setItemId(request.getParameter("itemId"));
                item.setExpiryDate(request.getParameter("expiryDate"));
                item.setAddedDate(dateFormat.format(new Date()));
                item.setLastUpdatedDate(dateFormat.format(new Date()));

                // Handle image upload
                Part filePart = request.getPart("image");
                String imagePath = saveImage(filePart, item.getItemId());
                item.setImagePath(imagePath);                items.add(item);
                LOGGER.info("Added new item: " + item.getName());

                // Log the inventory addition activity
                ActivityLogger.logInventoryAction(request, "added", item.getName(), item.getStock());} else if ("Update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Item item = items.stream()
                        .filter(i -> i.getId() == id)
                        .findFirst()
                        .orElse(null);

                if (item != null) {
                    item.setName(request.getParameter("name"));
                    item.setCategory(request.getParameter("category"));
                    item.setStock(Integer.parseInt(request.getParameter("stock")));
                    item.setPrice(Double.parseDouble(request.getParameter("price")));
                    item.setItemId(request.getParameter("itemId"));
                    item.setExpiryDate(request.getParameter("expiryDate"));
                    item.setLastUpdatedDate(dateFormat.format(new Date()));

                    Part filePart = request.getPart("image");
                    if (filePart != null && filePart.getSize() > 0) {
                        String imagePath = saveImage(filePart, item.getItemId());
                        item.setImagePath(imagePath);
                    }                    LOGGER.info("Updated item: " + item.getName());

                    // Log the inventory update activity
                    ActivityLogger.logInventoryAction(request, "updated", item.getName(), item.getStock());
                }} else if ("Delete".equals(action)) {                int id = Integer.parseInt(request.getParameter("id"));

                // Get item name before deletion for logging
                Item itemToDelete = items.stream()
                        .filter(i -> i.getId() == id)
                        .findFirst()
                        .orElse(null);

                if (itemToDelete != null) {
                    String itemName = itemToDelete.getName();
                    items.removeIf(item -> item.getId() == id);
                    LOGGER.info("Deleted item with ID: " + id);

                    // Log the inventory deletion activity
                    ActivityLogger.logInventoryAction(request, "deleted", itemName, null);
                } else {
                    items.removeIf(item -> item.getId() == id);
                    LOGGER.info("Deleted item with ID: " + id);
                }
            }

            saveItemsToFile(items);

        } catch (NumberFormatException e) {
            LOGGER.warning("Invalid number format: " + e.getMessage());
            request.setAttribute("error", "Invalid number format in the form. Please check your input.");
            request.setAttribute("items", items);
            request.getRequestDispatcher("/inventory.jsp").forward(request, response);
            return;
        } catch (Exception e) {
            LOGGER.severe("Error processing inventory action: " + e.getMessage());
            request.setAttribute("error", "An error occurred while processing your request.");
            request.setAttribute("items", items);
            request.getRequestDispatcher("/inventory.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/inventory");
    }

    private List<Item> sortItemsByExpiryDate(List<Item> items) {
        return items.stream()
                .sorted((a, b) -> {
                    String dateA = a.getExpiryDate() != null ? a.getExpiryDate() : "9999-12-31";
                    String dateB = b.getExpiryDate() != null ? b.getExpiryDate() : "9999-12-31";
                    return dateA.compareTo(dateB);
                })
                .collect(Collectors.toList());
    }
}


