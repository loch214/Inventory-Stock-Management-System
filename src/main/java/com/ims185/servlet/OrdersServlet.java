package com.ims185.servlet;

import com.ims185.model.Order;
import com.ims185.model.Item;
import com.ims185.model.User;
import com.ims185.util.ActivityLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/orders")
public class OrdersServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(OrdersServlet.class.getName());
    private static final String ORDERS_FILE_PATH = "WEB-INF/data/orders.txt";
    private static final String INVENTORY_FILE_PATH = "WEB-INF/data/inventory.txt";
    private static final String CUSTOMERS_FILE_PATH = "WEB-INF/data/customers.txt";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Load existing orders
        List<Order> orders = loadOrders();
        request.setAttribute("orders", orders);
        
        // Load customers and items for dropdowns
        request.setAttribute("customers", loadCustomers());
        request.setAttribute("items", loadItems());
        
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loggedInUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String customerName = request.getParameter("customerName");
        String itemName = request.getParameter("itemName");
        
        try {            if ("create".equals(action)) {
                // Create a new order
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                double totalPrice = Double.parseDouble(request.getParameter("totalPrice"));
                
                // Check if there's enough stock available
                int availableStock = getAvailableStock(itemName);
                if (quantity > availableStock) {
                    // Not enough stock available
                    request.setAttribute("error", "Cannot create order: Requested quantity (" + quantity + 
                        ") exceeds available stock (" + availableStock + ") for item " + itemName);
                    LOGGER.warning("Order creation failed: Insufficient stock for " + itemName + 
                        ". Requested: " + quantity + ", Available: " + availableStock);
                } else {
                    Order order = new Order(customerName, itemName, quantity, totalPrice);
                    
                    // Generate formatted order ID (e.g., 2025001)
                    int numericId = generateId();
                    // Format: YYYY + 3-digit sequence
                    String formattedId = String.format("%d%03d", LocalDateTime.now().getYear(), numericId);
                    order.setId(formattedId);
                    
                    // Update inventory stock
                    updateInventoryStock(itemName, quantity);
                    // Save the order
                    saveOrder(order);
                    
                    // Log the order creation
                    ActivityLogger.logOrderAction(request, "created", order.getId(), Double.valueOf(totalPrice));
                    
                    request.setAttribute("success", "Order created successfully.");
                }} else if ("update".equals(action)) {
                // Update an existing order
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                double totalPrice = Double.parseDouble(request.getParameter("totalPrice"));
                String id = request.getParameter("id");
                
                // Get the old order details to adjust inventory correctly
                Order oldOrder = findOrderById(id);
                if (oldOrder != null) {
                    boolean hasEnoughStock = true;
                    
                    // If quantity or item changed, check inventory stock
                    if (!oldOrder.getItemName().equals(itemName) || oldOrder.getQuantity() != quantity) {
                        // For a different item, check the new item's stock
                        if (!oldOrder.getItemName().equals(itemName)) {
                            int availableStock = getAvailableStock(itemName);
                            if (quantity > availableStock) {
                                hasEnoughStock = false;
                                request.setAttribute("error", "Cannot update order: Requested quantity (" + quantity + 
                                    ") exceeds available stock (" + availableStock + ") for item " + itemName);
                                LOGGER.warning("Order update failed: Insufficient stock for " + itemName + 
                                    ". Requested: " + quantity + ", Available: " + availableStock);
                            }
                        } 
                        // For the same item but increased quantity
                        else if (quantity > oldOrder.getQuantity()) {
                            int availableStock = getAvailableStock(itemName);
                            // We need to check if the additional quantity is available
                            int additionalQuantity = quantity - oldOrder.getQuantity();
                            if (additionalQuantity > availableStock) {
                                hasEnoughStock = false;
                                request.setAttribute("error", "Cannot update order: The additional quantity (" + additionalQuantity + 
                                    ") exceeds available stock (" + availableStock + ") for item " + itemName);
                                LOGGER.warning("Order update failed: Insufficient stock for additional quantity of " + itemName + 
                                    ". Requested additional: " + additionalQuantity + ", Available: " + availableStock);
                            }
                        }
                    }
                    
                    if (hasEnoughStock) {
                        // If quantity or item changed, update inventory
                        if (!oldOrder.getItemName().equals(itemName) || oldOrder.getQuantity() != quantity) {
                            // Restore stock for the old item/quantity
                            restoreInventoryStock(oldOrder.getItemName(), oldOrder.getQuantity());
                            
                            // Update stock for the new item/quantity
                            updateInventoryStock(itemName, quantity);
                        }
                        
                        updateOrder(id, customerName, itemName, quantity, totalPrice);
                        
                        // Log the order update
                        ActivityLogger.logOrderAction(request, "updated", id, Double.valueOf(totalPrice));
                        
                        request.setAttribute("success", "Order updated successfully.");
                    }
                } else {
                    request.setAttribute("error", "Cannot update order: Order not found with ID " + id);
                }
                  } else if ("delete".equals(action)) {
                // Delete an order
                String id = request.getParameter("id");
                
                // Get the order details to restore inventory
                Order orderToDelete = findOrderById(id);
                if (orderToDelete != null) {
                    // Restore stock when deleting an order
                    restoreInventoryStock(orderToDelete.getItemName(), orderToDelete.getQuantity());
                }
                  deleteOrder(id);
                
                // Log the order deletion
                if (orderToDelete != null) {
                    ActivityLogger.logOrderAction(request, "deleted", id, orderToDelete.getTotalPrice());
                } else {
                    ActivityLogger.logOrderAction(request, "deleted", id, null);
                }
                
                request.setAttribute("success", "Order deleted successfully.");
            }
        } catch (Exception e) {
            LOGGER.warning("Error processing order: " + e.getMessage());
            request.setAttribute("error", "Error processing order: " + e.getMessage());
        }
        
        // Reload orders
        List<Order> orders = loadOrders();
        request.setAttribute("orders", orders);
        
        // Load customers and items for dropdowns
        request.setAttribute("customers", loadCustomers());
        request.setAttribute("items", loadItems());
        
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }    private List<Order> loadOrders() {
        List<Order> orders = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + ORDERS_FILE_PATH;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) continue; // Skip comments and empty lines
                
                String[] parts = line.split(",");
                if (parts.length >= 5) {
                    try {
                        Order order = new Order();
                        order.setId(parts[0]);
                        order.setCustomerName(parts[1]);
                        order.setItemName(parts[2]);
                        order.setQuantity(Integer.parseInt(parts[3]));
                        order.setTotalPrice(Double.parseDouble(parts[4]));
                        order.setOrderDate(LocalDateTime.parse(parts[5]));
                        orders.add(order);
                    } catch (Exception e) {
                        LOGGER.warning("Invalid order data: " + line + " - " + e.getMessage());
                    }
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error reading orders file: " + e.getMessage());
            // Use sample data if file not found or error reading
            orders.add(new Order("John Doe", "Laptop", 1, 999.99));
            orders.add(new Order("Jane Smith", "Monitor", 2, 499.98));
        }
        
        return orders;
    }
    
    private List<String> loadCustomers() {
        List<String> customers = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + CUSTOMERS_FILE_PATH;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) continue; // Skip comments and empty lines
                
                String[] parts = line.split(",");
                if (parts.length >= 2) {
                    customers.add(parts[1]); // Name is at index 1
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error reading customers file: " + e.getMessage());
        }
        
        return customers;
    }
    
    private List<Item> loadItems() {
        List<Item> items = new ArrayList<>();
        String filePath = getServletContext().getRealPath("/") + INVENTORY_FILE_PATH;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) continue; // Skip comments and empty lines
                
                String[] parts = line.split(",");
                if (parts.length >= 5) {
                    try {
                        Item item = new Item();
                        item.setId(Integer.parseInt(parts[0]));
                        item.setName(parts[1]);
                        item.setCategory(parts[2]);
                        item.setStock(Integer.parseInt(parts[3]));
                        item.setPrice(Double.parseDouble(parts[4]));
                        items.add(item);
                    } catch (Exception e) {
                        LOGGER.warning("Invalid item data: " + line);
                    }
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error reading items file: " + e.getMessage());
        }
        
        return items;
    }
    
    private void saveOrder(Order order) {
        String filePath = getServletContext().getRealPath("/") + ORDERS_FILE_PATH;
        try (FileWriter writer = new FileWriter(filePath, true)) {
            writer.write(order.getId() + "," + 
                         order.getCustomerName() + "," + 
                         order.getItemName() + "," + 
                         order.getQuantity() + "," + 
                         order.getTotalPrice() + "," + 
                         order.getOrderDate() + "\n");
        } catch (IOException e) {
            LOGGER.warning("Error writing to orders file: " + e.getMessage());
        }
    }
      private void updateOrder(String id, String customerName, String itemName, int quantity, double totalPrice) {
        List<Order> orders = loadOrders();
        String filePath = getServletContext().getRealPath("/") + ORDERS_FILE_PATH;
        
        try (FileWriter writer = new FileWriter(filePath)) {
            // Write header
            writer.write("// Orders data file\n");
            
            // Update the matching order and write all back
            for (Order order : orders) {
                if (order.getId().equals(id)) {
                    order.setCustomerName(customerName);
                    order.setItemName(itemName);
                    order.setQuantity(quantity);
                    order.setTotalPrice(totalPrice);
                }
                
                writer.write(order.getId() + "," + 
                             order.getCustomerName() + "," + 
                             order.getItemName() + "," + 
                             order.getQuantity() + "," + 
                             order.getTotalPrice() + "," + 
                             order.getOrderDate() + "\n");
            }
        } catch (IOException e) {
            LOGGER.warning("Error updating order: " + e.getMessage());
        }
    }    
    private void deleteOrder(String id) {
        List<Order> orders = loadOrders();
        String filePath = getServletContext().getRealPath("/") + ORDERS_FILE_PATH;
        
        try (FileWriter writer = new FileWriter(filePath)) {
            // Write header
            writer.write("// Orders data file\n");
            
            // Write all orders except the one to be deleted
            for (Order order : orders) {
                if (!order.getId().equals(id)) {
                    writer.write(order.getId() + "," + 
                                 order.getCustomerName() + "," + 
                                 order.getItemName() + "," + 
                                 order.getQuantity() + "," + 
                                 order.getTotalPrice() + "," + 
                                 order.getOrderDate() + "\n");
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error deleting order: " + e.getMessage());
        }
    }
      private int generateId() {
        List<Order> orders = loadOrders();
        int maxId = 0;
        for (Order order : orders) {
            try {
                int orderId = Integer.parseInt(order.getId());
                if (orderId > maxId) {
                    maxId = orderId;
                }
            } catch (NumberFormatException e) {
                // Skip non-numeric IDs
            }
        }
        return maxId + 1;
    }
    
    // Method to update inventory stock when an order is placed
    private void updateInventoryStock(String itemName, int quantity) {
        String filePath = getServletContext().getRealPath("/") + INVENTORY_FILE_PATH;
        List<Item> items = new ArrayList<>();
        boolean itemFound = false;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) {
                    // Keep comments and empty lines
                    items.add(null); // Use null as a marker for non-item lines
                    continue;
                }
                
                String[] parts = line.split(",");
                if (parts.length >= 5) {
                    try {
                        Item item = new Item();
                        item.setId(Integer.parseInt(parts[0]));
                        item.setName(parts[1]);
                        item.setCategory(parts[2]);
                        item.setStock(Integer.parseInt(parts[3]));
                        item.setPrice(Double.parseDouble(parts[4]));
                        
                        if (parts.length > 5) item.setItemId(parts[5]);
                        if (parts.length > 6) item.setImagePath(parts[6]);
                        if (parts.length > 7) item.setExpiryDate(parts[7]);
                        if (parts.length > 8) item.setAddedDate(parts[8]);
                        if (parts.length > 9) item.setLastUpdatedDate(parts[9]);
                        
                        // If this is the item being ordered, reduce stock
                        if (item.getName().equals(itemName)) {
                            int newStock = item.getStock() - quantity;
                            if (newStock < 0) {
                                LOGGER.warning("Insufficient stock for " + itemName + ". Available: " + item.getStock() + ", Requested: " + quantity);
                                newStock = 0; // Prevent negative stock
                            }
                            item.setStock(newStock);
                            itemFound = true;
                        }
                        items.add(item);
                    } catch (Exception e) {
                        LOGGER.warning("Invalid item data: " + line);
                        items.add(null); // Mark invalid lines
                    }
                } else {
                    items.add(null); // Mark invalid lines
                }
            }
            
            // If the item wasn't found, log a warning
            if (!itemFound) {
                LOGGER.warning("Item not found in inventory: " + itemName);
                return;
            }
            
            // Write back the updated inventory
            try (FileWriter writer = new FileWriter(filePath)) {
                for (Item item : items) {
                    if (item == null) {
                        // Write back comment or empty line
                        writer.write("\n");
                    } else {
                        StringBuilder sb = new StringBuilder();
                        sb.append(item.getId()).append(",")
                          .append(item.getName()).append(",")
                          .append(item.getCategory()).append(",")
                          .append(item.getStock()).append(",")
                          .append(item.getPrice());
                        
                        if (item.getItemId() != null) sb.append(",").append(item.getItemId());
                        if (item.getImagePath() != null) sb.append(",").append(item.getImagePath());
                        if (item.getExpiryDate() != null) sb.append(",").append(item.getExpiryDate());
                        if (item.getAddedDate() != null) sb.append(",").append(item.getAddedDate());
                        if (item.getLastUpdatedDate() != null) sb.append(",").append(item.getLastUpdatedDate());
                        
                        sb.append("\n");
                        writer.write(sb.toString());
                    }
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error updating inventory stock: " + e.getMessage());
        }
    }
    
    // Method to restore inventory when an order is deleted
    private void restoreInventoryStock(String itemName, int quantity) {
        String filePath = getServletContext().getRealPath("/") + INVENTORY_FILE_PATH;
        List<Item> items = new ArrayList<>();
        boolean itemFound = false;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("//") || line.trim().isEmpty()) {
                    // Keep comments and empty lines
                    items.add(null); // Use null as a marker for non-item lines
                    continue;
                }
                
                String[] parts = line.split(",");
                if (parts.length >= 5) {
                    try {
                        Item item = new Item();
                        item.setId(Integer.parseInt(parts[0]));
                        item.setName(parts[1]);
                        item.setCategory(parts[2]);
                        item.setStock(Integer.parseInt(parts[3]));
                        item.setPrice(Double.parseDouble(parts[4]));
                        
                        if (parts.length > 5) item.setItemId(parts[5]);
                        if (parts.length > 6) item.setImagePath(parts[6]);
                        if (parts.length > 7) item.setExpiryDate(parts[7]);
                        if (parts.length > 8) item.setAddedDate(parts[8]);
                        if (parts.length > 9) item.setLastUpdatedDate(parts[9]);
                        
                        // If this is the item being ordered, increase stock
                        if (item.getName().equals(itemName)) {
                            item.setStock(item.getStock() + quantity);
                            itemFound = true;
                        }
                        items.add(item);
                    } catch (Exception e) {
                        LOGGER.warning("Invalid item data: " + line);
                        items.add(null); // Mark invalid lines
                    }
                } else {
                    items.add(null); // Mark invalid lines
                }
            }
            
            // If the item wasn't found, log a warning
            if (!itemFound) {
                LOGGER.warning("Item not found in inventory: " + itemName);
                return;
            }
            
            // Write back the updated inventory
            try (FileWriter writer = new FileWriter(filePath)) {
                for (Item item : items) {
                    if (item == null) {
                        // Write back comment or empty line
                        writer.write("\n");
                    } else {
                        StringBuilder sb = new StringBuilder();
                        sb.append(item.getId()).append(",")
                          .append(item.getName()).append(",")
                          .append(item.getCategory()).append(",")
                          .append(item.getStock()).append(",")
                          .append(item.getPrice());
                        
                        if (item.getItemId() != null) sb.append(",").append(item.getItemId());
                        if (item.getImagePath() != null) sb.append(",").append(item.getImagePath());
                        if (item.getExpiryDate() != null) sb.append(",").append(item.getExpiryDate());
                        if (item.getAddedDate() != null) sb.append(",").append(item.getAddedDate());
                        if (item.getLastUpdatedDate() != null) sb.append(",").append(item.getLastUpdatedDate());
                        
                        sb.append("\n");
                        writer.write(sb.toString());
                    }
                }
            }
        } catch (IOException e) {
            LOGGER.warning("Error restoring inventory stock: " + e.getMessage());
        }
    }
      // Method to find an order by ID
    private Order findOrderById(String id) {
        List<Order> orders = loadOrders();
        for (Order order : orders) {
            if (order.getId().equals(id)) {
                return order;
            }
        }
        return null;
    }
    
    // Method to check available stock for an item
    private int getAvailableStock(String itemName) {
        List<Item> items = loadItems();
        for (Item item : items) {
            if (item.getName().equals(itemName)) {
                return item.getStock();
            }
        }
        LOGGER.warning("Item not found in inventory: " + itemName);
        return 0; // Return 0 if item not found
    }
}
