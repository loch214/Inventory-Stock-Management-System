package com.ims185.servlet;

import com.ims185.model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@WebServlet("/returns")
public class ReturnsServlet extends HttpServlet {
    private List<String[]> loadReturnsFromFile() {
        List<String[]> returns = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + "returns.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length >= 5) returns.add(parts);
            }
        } catch (IOException e) {
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
                writer.write(""); // Create empty file
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        return returns;
    }

    private void saveReturnsToFile(List<String[]> returns) {
        String filePath = getServletContext().getRealPath("/") + "returns.txt";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String[] ret : returns) {
                writer.write(String.join(",", ret) + "\n");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        // Handle AJAX request to get order details
        if ("getOrderDetails".equals(action)) {
            String orderId = request.getParameter("orderId");
            if (orderId != null) {
                // Return order details as JSON
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                // Look up order in database
                Order order = findOrderById(orderId);
                
                if (order != null) {
                    // JSON response format
                    String json = "{" +
                        "\"found\": true," +
                        "\"id\": \"" + order.getId() + "\"," +
                        "\"customerName\": \"" + order.getCustomerName() + "\"," +
                        "\"itemName\": \"" + order.getItemName() + "\"," +
                        "\"quantity\": " + order.getQuantity() + "," +
                        "\"totalPrice\": " + order.getTotalPrice() +
                    "}";
                    response.getWriter().write(json);
                } else {
                    // Order not found
                    response.getWriter().write("{\"found\": false}");
                }
                return;
            }
        }
        // Handle AJAX request to get all valid order IDs
        else if ("getValidOrderIds".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            List<String> validOrderIds = getValidOrderIds();
            StringBuilder jsonBuilder = new StringBuilder("{\"orderIds\":[");
            
            for (int i = 0; i < validOrderIds.size(); i++) {
                if (i > 0) jsonBuilder.append(",");
                jsonBuilder.append("\"").append(validOrderIds.get(i)).append("\"");
            }
            
            jsonBuilder.append("]}");
            response.getWriter().write(jsonBuilder.toString());
            return;
        }
        
        // Regular page load
        // Check for any error or success messages passed as parameters
        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("error", error);
        }
        
        request.getRequestDispatcher("/returns.jsp").forward(request, response);
    }
    
    // Method to find an order by ID
    private Order findOrderById(String id) {
        String filePath = getServletContext().getRealPath("/WEB-INF/data/orders.txt");
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) continue;
                
                String[] parts = line.split(",");
                if (parts.length >= 5 && parts[0].equals(id)) {
                    Order order = new Order();
                    order.setId(parts[0]);
                    order.setCustomerName(parts[1]);
                    order.setItemName(parts[2]);
                    order.setQuantity(Integer.parseInt(parts[3]));
                    order.setTotalPrice(Double.parseDouble(parts[4]));
                    if (parts.length > 5) {
                        try {
                            order.setOrderDate(LocalDateTime.parse(parts[5]));
                        } catch (Exception e) {
                            // Invalid date, ignore
                        }
                    }
                    return order;
                }
            }
        } catch (IOException e) {
            // File not found or other IO error
        } catch (Exception e) {
            // Other errors (parsing, etc.)
        }
        
        return null;
    }

    // Method to get all valid order IDs from the orders.txt file
    private List<String> getValidOrderIds() {
        List<String> orderIds = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/WEB-INF/data/orders.txt");
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) continue;
                
                String[] parts = line.split(",");
                if (parts.length >= 5) {
                    orderIds.add(parts[0]);
                }
            }
        } catch (IOException e) {
            // File not found or other IO error
        }
        
        return orderIds;
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Load existing returns
        List<String[]> returns = loadReturnsFromFile();
        
        // Check if this is a return status update
        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            String returnId = request.getParameter("returnId");
            String status = request.getParameter("status");
            
            if (returnId != null && status != null) {
                boolean updated = false;
                
                // Find the return with matching ID and update its status
                for (String[] ret : returns) {
                    if (ret.length > 0 && ret[0].equals(returnId)) {
                        if (ret.length > 6) {
                            ret[6] = status; // Update existing status
                        } else {
                            // Add status field if it doesn't exist
                            String[] newRet = new String[7];
                            System.arraycopy(ret, 0, newRet, 0, ret.length);
                            newRet[6] = status;
                            
                            // Replace the old return record with the new one
                            returns.set(returns.indexOf(ret), newRet);
                        }
                        updated = true;
                        break;
                    }
                }
                
                if (updated) {
                    saveReturnsToFile(returns);
                    response.sendRedirect(request.getContextPath() + "/returns?success=true");
                    return;
                }
            }
        }
        
        // Get parameters from the form
        String returnReason = request.getParameter("returnId");
        String orderId = request.getParameter("orderId");
        String itemName = request.getParameter("itemId");
        String quantityStr = request.getParameter("quantity");
        
        if (returnReason == null || orderId == null || itemName == null || quantityStr == null) {
            request.setAttribute("error", "All fields are required");
            request.getRequestDispatcher("/returns.jsp").forward(request, response);
            return;
        }
        
        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
            if (quantity <= 0) {
                request.setAttribute("error", "Quantity must be greater than 0");
                request.getRequestDispatcher("/returns.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid quantity");
            request.getRequestDispatcher("/returns.jsp").forward(request, response);
            return;
        }
        
        // Remove "ORD-" prefix if present in the order ID
        if (orderId.startsWith("ORD-")) {
            orderId = orderId.substring(4);
        }
        
        // Validate Order ID format
        if (!orderId.matches("\\d+")) {
            request.setAttribute("error", "Invalid Order ID format. Must be numeric.");
            request.getRequestDispatcher("/returns.jsp").forward(request, response);
            return;
        }
        
        // Validate Order ID exists in the system
        List<String> validOrderIds = getValidOrderIds();
        if (!validOrderIds.contains(orderId)) {
            request.setAttribute("error", "Order ID not found in the system. Please enter a valid Order ID.");
            request.getRequestDispatcher("/returns.jsp").forward(request, response);
            return;
        }
        
        // Validate order quantity
        Order orderDetails = findOrderById(orderId);
        if (orderDetails != null && quantity > orderDetails.getQuantity()) {
            request.setAttribute("error", "Return quantity cannot exceed original order quantity of " + orderDetails.getQuantity());
            request.getRequestDispatcher("/returns.jsp").forward(request, response);
            return;
        }
        
        // Format the current date
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String date = sdf.format(new Date());
        
        // Generate a return ID (RET-YYYYMMDD-XXX where XXX is the count of returns for the day + 1)
        String returnIdPrefix = "RET-" + date.replace("-", "");
        int returnCount = 1;
        
        for (String[] ret : returns) {
            if (ret.length > 0 && ret[0].startsWith(returnIdPrefix)) {
                returnCount++;
            }
        }
        
        String returnId = returnIdPrefix + "-" + String.format("%03d", returnCount);
        
        // Create and save the new return record with a "pending" status
        String[] newReturn = {returnId, orderId, itemName, String.valueOf(quantity), date, returnReason, "pending"};
        returns.add(newReturn);
        saveReturnsToFile(returns);
        
        // Update inventory (increase stock for the returned item)
        updateInventoryStock(itemName, quantity);
        
        // Log the activity
        logReturnActivity(request, returnId, orderId, itemName, quantity);
        
        // Redirect with success message
        response.sendRedirect(request.getContextPath() + "/returns?success=true");
    }
    
    private void updateInventoryStock(String itemName, int quantity) {
        String filePath = getServletContext().getRealPath("/WEB-INF/data/inventory.txt");
        List<String> inventoryLines = new ArrayList<>();
        boolean itemFound = false;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) {
                    inventoryLines.add(line);
                    continue;
                }
                
                String[] parts = line.split(",");
                if (parts.length >= 5 && parts[1].equals(itemName)) {
                    // Found the item, update stock
                    try {
                        int currentStock = Integer.parseInt(parts[3]);
                        int newStock = currentStock + quantity;
                        parts[3] = String.valueOf(newStock);
                        itemFound = true;
                    } catch (NumberFormatException e) {
                        // If stock is not a number, keep original line
                        inventoryLines.add(line);
                        continue;
                    }
                    line = String.join(",", parts);
                }
                inventoryLines.add(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }
        
        if (!itemFound) {
            return; // Item not found in inventory
        }
        
        // Write updated inventory back to file
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            for (String line : inventoryLines) {
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private void logReturnActivity(HttpServletRequest request, String returnId, String orderId, String itemName, int quantity) {
        // This method would log the return activity to your activity log system
        // For now, we'll leave it as a stub that could be implemented later
        // You can integrate with ActivityLogger if it exists in your application
        try {
            Class<?> loggerClass = Class.forName("com.ims185.util.ActivityLogger");
            java.lang.reflect.Method logMethod = loggerClass.getMethod("logReturnAction", 
                HttpServletRequest.class, String.class, String.class, String.class, Integer.class);
            logMethod.invoke(null, request, returnId, orderId, itemName, quantity);
        } catch (Exception e) {
            // Logger not available or method doesn't exist, silently continue
        }
    }
}