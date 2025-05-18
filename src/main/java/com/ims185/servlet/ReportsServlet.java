package com.ims185.servlet;

import com.ims185.model.Item;
import com.ims185.model.Notification;
import com.ims185.util.ActivityLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet("/reports")
public class ReportsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ReportsServlet.class.getName());
    private static final int LOW_STOCK_THRESHOLD = 10;
    private static final int NORMAL_STOCK_THRESHOLD = 50;
    private static final int EXPIRY_WARNING_DAYS = 30;
    
    private List<Item> loadItemsFromFile() {
        List<Item> items = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "inventory.txt";
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
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
                        LOGGER.warning("Invalid number format in line: " + line);
                    }
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error reading inventory file at " + filePath + ": " + e.getMessage());
            // Try alternative locations for the inventory file
            try {
                // First check in WEB-INF directory
                filePath = getServletContext().getRealPath("/WEB-INF/") + "inventory.txt";
                try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
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
                            } catch (NumberFormatException nfe) {
                                LOGGER.warning("Invalid number format in line: " + line);
                            }
                        }
                    }
                }
            } catch (IOException e2) {
                // Next, try in WEB-INF/data directory
                LOGGER.info("Trying to read inventory file from WEB-INF/data directory");
                try {
                    filePath = getServletContext().getRealPath("/WEB-INF/data/") + "inventory.txt";
                    try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
                        String line;
                        while ((line = reader.readLine()) != null) {
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
                                } catch (NumberFormatException nfe) {
                                    LOGGER.warning("Invalid number format in line: " + line);
                                }
                            }
                        }
                    }
                } catch (IOException e3) {
                    LOGGER.severe("Error reading inventory file from WEB-INF/data directory: " + e3.getMessage());
                }
                
                // Add some sample data if no file was found
                if (items.isEmpty()) {
                    LOGGER.info("Loading sample inventory data since no file was found");
                    items.add(new Item(1, "Laptop", "Electronics", 15, 999.99, "EL-001", "images/laptop.jpg", "2026-12-31", "2023-01-15", "2023-05-20"));
                    items.add(new Item(2, "Desk Chair", "Furniture", 8, 149.99, "FN-001", "images/desk_chair.jpg", "2030-01-01", "2023-02-10", "2023-05-15"));
                    items.add(new Item(3, "Printer", "Electronics", 12, 299.99, "EL-002", "images/printer.jpg", "2027-06-30", "2023-01-20", "2023-04-25"));
                    items.add(new Item(4, "Desk Lamp", "Furniture", 5, 39.99, "FN-002", "images/desk_lamp.jpg", "2029-12-31", "2023-03-05", "2023-05-10"));
                    items.add(new Item(5, "Monitor", "Electronics", 60, 249.99, "EL-003", "images/monitor.jpg", "2028-10-15", "2023-01-25", "2023-05-18"));
                }
            }
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

        String reportType = request.getParameter("reportType");
        List<Item> items = loadItemsFromFile();
        
        if ("stock".equals(reportType)) {
            generateStockReport(request, items);
            ActivityLogger.logUserActivity(request, "generated", "stock levels report");
        } else if ("expired".equals(reportType)) {
            generateExpiryReport(request, items);
            ActivityLogger.logUserActivity(request, "generated", "expiry status report");
        } else if ("notifications".equals(reportType)) {
            generateNotifications(request, items);
            ActivityLogger.logUserActivity(request, "generated", "notifications report");
        }
        
        request.setAttribute("reportType", reportType);
        request.getRequestDispatcher("/reports.jsp").forward(request, response);
    }
    
    private void generateStockReport(HttpServletRequest request, List<Item> items) {
        List<Item> lowStockItems = items.stream()
            .filter(item -> item.getStock() < LOW_STOCK_THRESHOLD)
            .collect(Collectors.toList());
            
        List<Item> normalStockItems = items.stream()
            .filter(item -> item.getStock() >= LOW_STOCK_THRESHOLD && item.getStock() < NORMAL_STOCK_THRESHOLD)
            .collect(Collectors.toList());
            
        List<Item> highStockItems = items.stream()
            .filter(item -> item.getStock() >= NORMAL_STOCK_THRESHOLD)
            .collect(Collectors.toList());
        
        request.setAttribute("reportTitle", "Stock Levels Report");
        request.setAttribute("reportDescription", "Overview of inventory stock levels");
        request.setAttribute("lowStockItems", lowStockItems);
        request.setAttribute("normalStockItems", normalStockItems);
        request.setAttribute("highStockItems", highStockItems);
        request.setAttribute("totalItems", items.size());
        request.setAttribute("lowStockCount", lowStockItems.size());
        request.setAttribute("normalStockCount", normalStockItems.size());
        request.setAttribute("highStockCount", highStockItems.size());
    }
    
    private void generateExpiryReport(HttpServletRequest request, List<Item> items) {
        LocalDate today = LocalDate.now();
        LocalDate thirtyDaysFromNow = today.plusDays(EXPIRY_WARNING_DAYS);
        DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE;
        
        List<Item> expiredItems = new ArrayList<>();
        List<Item> nearExpiryItems = new ArrayList<>();
        List<Item> validItems = new ArrayList<>();
        
        for (Item item : items) {
            if (item.getExpiryDate() != null && !item.getExpiryDate().trim().isEmpty()) {
                try {
                    LocalDate expiryDate = LocalDate.parse(item.getExpiryDate(), formatter);
                    if (expiryDate.isBefore(today)) {
                        expiredItems.add(item);
                    } else if (expiryDate.isBefore(thirtyDaysFromNow)) {
                        nearExpiryItems.add(item);
                    } else {
                        validItems.add(item);
                    }
                } catch (DateTimeParseException e) {
                    LOGGER.warning("Invalid date format for item: " + item.getName() + ", date: " + item.getExpiryDate());
                }
            }
        }
        
        request.setAttribute("reportTitle", "Expiry Status Report");
        request.setAttribute("reportDescription", "Items that have expired or will expire soon");
        request.setAttribute("expiredItems", expiredItems);
        request.setAttribute("nearExpiryItems", nearExpiryItems);
        request.setAttribute("validItems", validItems);
        request.setAttribute("totalItems", items.size());
        request.setAttribute("expiredCount", expiredItems.size());
        request.setAttribute("nearExpiryCount", nearExpiryItems.size());
        request.setAttribute("validCount", validItems.size());
        request.setAttribute("currentDate", today.format(formatter));
        request.setAttribute("warningDate", thirtyDaysFromNow.format(formatter));
    }
    
    /**
     * Generates notifications for low stock and expiry status
     * @param request The HTTP request
     * @param items The list of items to analyze
     */
    private void generateNotifications(HttpServletRequest request, List<Item> items) {
        List<Notification> notifications = new ArrayList<>();
        LocalDate today = LocalDate.now();
        LocalDate thirtyDaysFromNow = today.plusDays(EXPIRY_WARNING_DAYS);
        DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE;
        
        // Check for low stock items
        for (Item item : items) {
            if (item.getStock() < LOW_STOCK_THRESHOLD) {
                notifications.add(new Notification("Low stock alert: " + item.getName() + 
                    " (Stock: " + item.getStock() + " - below threshold of " + LOW_STOCK_THRESHOLD + ")", 
                    LocalDateTime.now()));
            }
        }
        
        // Check for expiry dates
        for (Item item : items) {
            if (item.getExpiryDate() != null && !item.getExpiryDate().trim().isEmpty()) {
                try {
                    LocalDate expiryDate = LocalDate.parse(item.getExpiryDate(), formatter);
                    if (expiryDate.isBefore(today)) {
                        notifications.add(new Notification("Expired: " + item.getName() + 
                            " expired on " + item.getExpiryDate(), LocalDateTime.now()));
                    } else if (expiryDate.isBefore(thirtyDaysFromNow)) {
                        long daysUntilExpiry = java.time.temporal.ChronoUnit.DAYS.between(today, expiryDate);
                        notifications.add(new Notification("Expiring soon: " + item.getName() + 
                            " expires in " + daysUntilExpiry + " days", LocalDateTime.now()));
                    }
                } catch (DateTimeParseException e) {
                    LOGGER.warning("Invalid date format for item: " + item.getName() + 
                        ", date: " + item.getExpiryDate());
                }
            }
        }
        
        request.setAttribute("notifications", notifications);
        request.setAttribute("reportTitle", "System Notifications");
        request.setAttribute("reportDescription", "Alerts for inventory requiring attention");
        request.setAttribute("lowStockCount", 
            notifications.stream().filter(n -> n.getMessage().toLowerCase().contains("low stock")).count());
        request.setAttribute("expiredCount", 
            notifications.stream().filter(n -> n.getMessage().toLowerCase().contains("expired")).count());
        request.setAttribute("expiringCount", 
            notifications.stream().filter(n -> n.getMessage().toLowerCase().contains("expiring")).count());
        request.setAttribute("totalNotifications", notifications.size());
    }
}