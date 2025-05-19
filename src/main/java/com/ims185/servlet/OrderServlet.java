package com.ims185.servlet;

import com.ims185.model.Order;
import com.ims185.model.Item;
import com.ims185.config.FilePaths;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/order") 
public class OrderServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(OrderServlet.class.getName());

    private List<Order> loadOrders() {
        List<Order> orders = new ArrayList<>();
        Path ordersPath = Paths.get(FilePaths.getDataDirectory(), "orders.txt");
        File file = ordersPath.toFile();
        
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                LOGGER.severe("Failed to create orders.txt: " + e.getMessage());
            }
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length == 6) {
                    Order order = new Order();
                    order.setId(parts[0]);
                    order.setCustomerName(parts[1]);
                    order.setItemName(parts[2]);
                    order.setQuantity(Integer.parseInt(parts[3]));
                    order.setTotalPrice(Double.parseDouble(parts[4]));
                    order.setOrderDate(LocalDateTime.parse(parts[5]));
                    orders.add(order);
                }
            }
        } catch (IOException e) {
            LOGGER.severe("Error reading orders: " + e.getMessage());
        }
        return orders;
    }

    private void saveOrders(List<Order> orders) {
        Path ordersPath = Paths.get(FilePaths.getDataDirectory(), "orders.txt");
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(ordersPath.toFile()))) {
            for (Order order : orders) {
                writer.write(String.format("%s,%s,%s,%d,%.2f,%s\n",
                    order.getId(),
                    order.getCustomerName(),
                    order.getItemName(),
                    order.getQuantity(),
                    order.getTotalPrice(),
                    order.getOrderDate()
                ));
            }
            LOGGER.info("Saved " + orders.size() + " orders successfully");
        } catch (IOException e) {
            LOGGER.severe("Error saving orders: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Order> orders = loadOrders();
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }

    private boolean updateInventoryStock(String itemName, int quantity) throws IOException {
        Path inventoryFile = Paths.get(FilePaths.getDataDirectory(), "inventory.txt");
        if (!inventoryFile.toFile().exists()) {
            throw new IOException("Inventory file not found");
        }

        List<Item> items = new ArrayList<>();
        boolean stockUpdated = false;

        try (BufferedReader reader = new BufferedReader(new FileReader(inventoryFile.toFile()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length >= 10) {
                    if (parts[1].trim().equals(itemName)) {
                        int currentStock = Integer.parseInt(parts[3].trim());
                        if (currentStock < quantity) {
                            LOGGER.warning("Insufficient stock for item: " + itemName + ". Available: " + currentStock + ", Requested: " + quantity);
                            return false;
                        }
                    }
                }
            }
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(inventoryFile.toFile()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.trim().isEmpty()) continue;
                
                String[] parts = line.split(",");
                if (parts.length >= 10) {
                    Item item = new Item();
                    item.setId(Integer.parseInt(parts[0].trim()));
                    item.setName(parts[1].trim());
                    item.setCategory(parts[2].trim());
                    item.setStock(Integer.parseInt(parts[3].trim()));
                    item.setPrice(Double.parseDouble(parts[4].trim()));
                    item.setItemId(parts[5].trim());
                    item.setImagePath(parts[6].trim());
                    item.setExpiryDate(parts[7].trim());
                    item.setAddedDate(parts[8].trim());
                    item.setLastUpdatedDate(parts[9].trim());

                    if (item.getName().equals(itemName)) {
                        item.setStock(item.getStock() - quantity);
                        stockUpdated = true;
                    }
                    items.add(item);
                }
            }
        }

        if (!stockUpdated) {
            throw new IOException("Item not found in inventory: " + itemName);
        }

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
            LOGGER.info("Successfully updated inventory stock for item: " + itemName);
        }
        return true;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        List<Order> orders = loadOrders();

        try {
            if ("create".equals(action)) {
                String customerName = request.getParameter("customerName");
                String itemName = request.getParameter("itemName");
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                double totalPrice = Double.parseDouble(request.getParameter("totalPrice"));
                
                boolean stockUpdated = updateInventoryStock(itemName, quantity);
                
                if (!stockUpdated) {
                    request.setAttribute("error", "Cannot create order: Insufficient stock for item " + itemName);
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/orders.jsp").forward(request, response);
                    return;
                }

                Order order = new Order(customerName, itemName, quantity, totalPrice);
                orders.add(order);
                LOGGER.info("Created new order for customer: " + customerName);

            } else if ("update".equals(action)) {
                String id = request.getParameter("id");
                Order order = orders.stream().filter(o -> o.getId().equals(id)).findFirst().orElse(null);
                if (order != null) {
                    order.setCustomerName(request.getParameter("customerName"));
                    order.setItemName(request.getParameter("itemName"));
                    order.setQuantity(Integer.parseInt(request.getParameter("quantity")));
                    order.setTotalPrice(Double.parseDouble(request.getParameter("totalPrice")));
                }
            } else if ("delete".equals(action)) {
                String id = request.getParameter("id");
                orders.removeIf(o -> o.getId().equals(id));
            }

            saveOrders(orders);
            response.sendRedirect(request.getContextPath() + "/orders");
            
        } catch (IOException e) {
            LOGGER.severe("Error processing order: " + e.getMessage());
            request.setAttribute("error", "Error processing order: " + e.getMessage());
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/orders.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            LOGGER.severe("Invalid number format in order: " + e.getMessage());
            request.setAttribute("error", "Please enter valid numbers for quantity and price");
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/orders.jsp").forward(request, response);
        }
    }
}
