package com.ims185.servlet;

import com.ims185.config.FilePaths;
import com.ims185.model.Item;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.stream.Collectors;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/* @WebServlet annotation removed - using web.xml configuration instead */
public class ItemsServlet extends HttpServlet {    
    // Method to load threshold value from settings file
    private int loadThresholdFromSettings() {
        int defaultThreshold = 10;
        Path[] possiblePaths = new Path[] {
            // Primary path from FilePaths config
            Paths.get(FilePaths.getDataDirectory(), "settings.txt"),
            // Alt path - WEB-INF/data
            Paths.get(getServletContext().getRealPath("/WEB-INF/data"), "settings.txt"),
            // Target directory path
            Paths.get(getServletContext().getRealPath("/"), "WEB-INF", "data", "settings.txt")
        };
        
        for (Path settingsPath : possiblePaths) {
            File settingsFile = settingsPath.toFile();
            if (settingsFile.exists()) {
                try (BufferedReader reader = new BufferedReader(new FileReader(settingsPath.toString()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        String[] parts = line.split("=", 2);
                        if (parts.length == 2 && "threshold".equals(parts[0])) {
                            try {
                                int threshold = Integer.parseInt(parts[1].trim());
                                return threshold;
                            } catch (NumberFormatException e) {
                                System.out.println("Invalid threshold value: " + parts[1]);
                            }
                        }
                    }
                } catch (IOException e) {
                    System.err.println("Error reading settings from " + settingsPath + ": " + e.getMessage());
                }
            }
        }
        return defaultThreshold;
    }
    
    private List<Item> loadItemsFromFile() {
        List<Item> items = new ArrayList<>();
        Path inventoryFile = Paths.get(FilePaths.getDataDirectory(), "inventory.txt");
        File file = inventoryFile.toFile();

        if (!file.exists()) {
            System.out.println("Inventory file not found at: " + file.getAbsolutePath());
            return items;
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
                        System.out.println("Skipping line due to parsing error: " + line);
                    }
                }
            }
        } catch (IOException e) {
            System.out.println("Error reading inventory: " + e.getMessage());
        }
        return items;
    }    
      @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        List<Item> items = loadItemsFromFile();
        
        // Handle search functionality
        String searchQuery = request.getParameter("search");
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            String query = searchQuery.toLowerCase();
            items = items.stream()
                .filter(item -> 
                    (item.getName() != null && item.getName().toLowerCase().contains(query)) ||
                    (item.getItemId() != null && item.getItemId().toLowerCase().contains(query)) ||
                    (item.getCategory() != null && item.getCategory().toLowerCase().contains(query)))
                .collect(Collectors.toList());
        }

        // Load the threshold value from settings
        int threshold = loadThresholdFromSettings();
        
        request.setAttribute("items", items);
        request.setAttribute("lowStockThreshold", threshold);
        request.getRequestDispatcher("/items.jsp").forward(request, response);
    }
}