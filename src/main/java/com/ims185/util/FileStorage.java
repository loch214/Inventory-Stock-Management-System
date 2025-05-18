package com.ims185.util;

import com.ims185.model.Item;
import com.ims185.model.User;
import com.ims185.model.Customer;
import com.ims185.model.Notification;
import com.ims185.config.FilePaths;
import jakarta.servlet.http.Part;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.*;

public class FileStorage {
    // Load users from file
    public static List<User> loadUsers() {
        List<User> users = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(FilePaths.getUsersFile()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 8) {
                    User user = new User(
                            parts[0],
                            parts[1],
                            parts[2],
                            parts[3],
                            Boolean.parseBoolean(parts[4]),
                            LocalDateTime.parse(parts[5]),
                            parts[6],
                            parts[7],
                            parts.length > 8 ? parts[8] : "user"
                    );
                    users.add(user);
                }
            }
        } catch (IOException e) {
            logError("Error reading users: " + e.getMessage());
        }
        return users;
    }

    // Write users to file
    public static void writeUsers(List<User> users) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FilePaths.getUsersFile()))) {
            for (User user : users) {
                writer.write(user.toString());
                writer.newLine();
            }
        } catch (IOException e) {
            logError("Error writing users: " + e.getMessage());
        }
    }

    // Check if user exists
    public static boolean userExists(String username) {
        List<User> users = loadUsers();
        return users.stream().anyMatch(user -> user.getUsername().equals(username));
    }

    // Get all users
    public static List<User> getAllUsers() {
        return loadUsers();
    }

    // Save a single user
    public static void saveUser(User user) {
        List<User> users = loadUsers();
        users.add(user);
        writeUsers(users);
    }

    // Add a user
    public static void addUser(User user) {
        saveUser(user);
    }

    // Update a user
    public static void updateUser(User updatedUser) {
        List<User> users = loadUsers();
        users.replaceAll(user -> user.getId().equals(updatedUser.getId()) ? updatedUser : user);
        writeUsers(users);
    }

    // Delete a user
    public static void deleteUser(String userId) {
        List<User> users = loadUsers();
        users.removeIf(user -> user.getId().equals(userId));
        writeUsers(users);
    }    // Load items from file
    public static List<Item> loadItems() {
        List<Item> items = new ArrayList<>();
        
        // Try reading from items.txt first
        String itemsPath = FilePaths.getItemsFile();
        File itemsFile = new File(itemsPath);
        
        if (!itemsFile.exists() || itemsFile.length() == 0) {
            // Try reading from inventory.txt as a fallback
            String inventoryPath = FilePaths.getDataDirectory() + File.separator + "inventory.txt";
            itemsFile = new File(inventoryPath);
            
            if (!itemsFile.exists()) {
                logError("Neither items.txt nor inventory.txt exists. Creating empty list.");
                return items;
            }
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(itemsFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 9) {
                    Item item = new Item(
                            Integer.parseInt(parts[0]),
                            parts[1],
                            parts[2].isEmpty() ? null : parts[2],
                            Integer.parseInt(parts[3]),
                            Double.parseDouble(parts[4]),
                            parts[5],
                            parts[6].isEmpty() ? null : parts[6],
                            parts[7],
                            parts[8],
                            LocalDateTime.now().toString()
                    );
                    items.add(item);
                }
            }
        } catch (IOException | NumberFormatException e) {
            logError("Error reading items: " + e.getMessage());
        }
        return items;
    }

    // Write items to file
    public static void writeItems(List<Item> items) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FilePaths.getItemsFile()))) {
            for (Item item : items) {
                writer.write(item.toString());
                writer.newLine();
            }
        } catch (IOException e) {
            logError("Error writing items: " + e.getMessage());
        }
    }    // Load customers from file
    public static List<Customer> loadCustomers() {
        List<Customer> customers = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(FilePaths.getCustomersFile()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 7) { // Only need 7 fields for a valid customer
                    try {
                        String id = parts[0];
                        String name = parts[1];
                        String email = parts[2];
                        String phone = parts[3];
                        double balance = Double.parseDouble(parts[4]);
                        int orderCount = Integer.parseInt(parts[5]);
                        String address = parts.length > 6 ? parts[6] : "";
                        String notes = parts.length > 7 ? parts[7] : "";
                        
                        Customer customer = new Customer(
                            id,
                            name,
                            email,
                            phone,
                            balance,
                            orderCount,
                            LocalDateTime.now(),
                            address,
                            LocalDateTime.now(),
                            notes
                        );
                        customers.add(customer);
                    } catch (NumberFormatException e) {
                        logError("Error parsing customer data: " + line + " - " + e.getMessage());
                        continue; // Skip this customer but continue processing others
                    }
                }
            }
        } catch (IOException e) {
            logError("Error reading customers file: " + e.getMessage());
        }
        return customers;
    }    // Write customers to file
    public static void writeCustomers(List<Customer> customers) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(FilePaths.getCustomersFile()))) {
            for (Customer customer : customers) {
                String line = String.format("%s,%s,%s,%s,%.2f,%d,%s,%s,%s",
                    customer.getId(),
                    customer.getName(),
                    customer.getEmail(),
                    customer.getPhone(),
                    customer.getBalance(),
                    customer.getOrderCount(),
                    customer.getLastUpdated().toString(),
                    customer.getAddress() != null ? customer.getAddress() : "",
                    customer.getNotes() != null ? customer.getNotes() : ""
                );
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            logError("Error writing customers: " + e.getMessage());
        }
    }

    // Add a customer
    public static void addCustomer(Customer customer) {
        List<Customer> customers = loadCustomers();
        customers.add(customer);
        writeCustomers(customers);
    }

    // Update a customer
    public static void updateCustomer(Customer updatedCustomer) {
        List<Customer> customers = loadCustomers();
        customers.replaceAll(customer -> customer.getId().equals(updatedCustomer.getId()) ? updatedCustomer : customer);
        writeCustomers(customers);
    }

    // Delete a customer
    public static void deleteCustomer(String customerId) {
        List<Customer> customers = loadCustomers();
        customers.removeIf(customer -> customer.getId().equals(customerId));
        writeCustomers(customers);
    }

    // Load notifications from file
    public static List<Notification> loadNotifications() {
        List<Notification> notifications = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(FilePaths.getNotificationsFile()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty() || line.startsWith("type")) continue;
                String[] parts = line.split(",");
                if (parts.length >= 2) {
                    try {
                        LocalDateTime timestamp = LocalDateTime.parse(parts[1]);
                        Notification notification = new Notification(parts[0], timestamp);
                        notifications.add(notification);
                    } catch (DateTimeParseException e) {
                        logError("Invalid timestamp in notifications.txt: " + parts[1]);
                    }
                }
            }
        } catch (IOException e) {
            logError("Error reading notifications: " + e.getMessage());
        }
        return notifications;
    }

    // Save uploaded image
    public static String saveImage(Part part, String fileName) {
        String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
        Path filePath = Paths.get(FilePaths.getUploadDirectory(), uniqueFileName);
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, filePath);
            return uniqueFileName;
        } catch (IOException e) {
            logError("Error saving image: " + e.getMessage());
            return null;
        }
    }

    // Log errors to file
    private static void logError(String message) {
        Path logFile = Paths.get(FilePaths.getDataDirectory(), "storage_errors.log");
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(logFile.toString(), true))) {
            writer.write(LocalDateTime.now() + " - " + message);
            writer.newLine();
        } catch (IOException e) {
            System.err.println("Failed to log error: " + e.getMessage());
        }
    }
}
