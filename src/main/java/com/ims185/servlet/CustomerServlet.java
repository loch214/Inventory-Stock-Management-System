package com.ims185.servlet;

import com.ims185.model.Customer;
import com.ims185.util.ActivityLogger;
import com.ims185.util.FileStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.logging.FileHandler;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

@WebServlet("/customer_management")
public class CustomerServlet extends HttpServlet {
    private static final String DATA_DIR = "C:/IMS-185-Data";
    private static final Logger LOGGER = Logger.getLogger(CustomerServlet.class.getName());

    static {
        try {
            File logDir = new File(DATA_DIR);
            if (!logDir.exists()) {
                logDir.mkdirs();
            }
            FileHandler fileHandler = new FileHandler(DATA_DIR + "/customer_errors.log", true);
            fileHandler.setFormatter(new SimpleFormatter());
            LOGGER.addHandler(fileHandler);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("loggedInUser") == null) {
                LOGGER.info("No logged-in user found, redirecting to login.");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            List<Customer> customers = FileStorage.loadCustomers();
            request.setAttribute("customers", customers);
            request.getRequestDispatcher("/customer_management.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error in doGet: " + e.getMessage());
            throw new ServletException("Failed to load customers", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("loggedInUser") == null) {
                LOGGER.info("No logged-in user found, redirecting to login.");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String action = request.getParameter("action");
            if ("add".equals(action)) {
                // Validate parameters
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String balanceStr = request.getParameter("balance");
                String orderCountStr = request.getParameter("orderCount");
                String address = request.getParameter("address");
                String notes = request.getParameter("notes");

                if (name == null || name.trim().isEmpty() ||
                        email == null || email.trim().isEmpty() ||
                        phone == null || phone.trim().isEmpty()) {
                    LOGGER.warning("Missing required fields: name=" + name + ", email=" + email + ", phone=" + phone);
                    response.sendRedirect(request.getContextPath() + "/customer_management?error=All required fields must be filled");
                    return;
                }

                double balance;
                int orderCount;
                try {
                    balance = balanceStr != null && !balanceStr.trim().isEmpty() ? Double.parseDouble(balanceStr) : 0.0;
                    orderCount = orderCountStr != null && !orderCountStr.trim().isEmpty() ? Integer.parseInt(orderCountStr) : 0;
                } catch (NumberFormatException e) {
                    LOGGER.warning("Invalid number format: balance=" + balanceStr + ", orderCount=" + orderCountStr);
                    response.sendRedirect(request.getContextPath() + "/customer_management?error=Invalid number format");
                    return;
                }

                // Create customer
                Customer customer;
                try {
                    customer = new Customer(
                            UUID.randomUUID().toString(),
                            name,
                            email,
                            phone,
                            balance,
                            orderCount,
                            LocalDateTime.now(),
                            address != null ? address : "",
                            LocalDateTime.now(),
                            notes != null ? notes : ""
                    );
                } catch (Exception e) {
                    LOGGER.severe("Customer creation failed: " + e.getMessage());
                    throw new ServletException("Failed to create customer", e);
                }

                // Save customer
                try {
                    FileStorage.addCustomer(customer);
                    LOGGER.info("Customer saved: " + name);
                    ActivityLogger.logUserActivity(request, "created", "customer " + name + " with ID " + customer.getId());
                } catch (Exception e) {
                    LOGGER.severe("Customer save failed: " + name + ", error: " + e.getMessage());
                    throw new ServletException("Failed to save customer", e);
                }

                response.sendRedirect(request.getContextPath() + "/customer_management");
            } else if ("update".equals(action)) {
                String id = request.getParameter("id");
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");
                String balanceStr = request.getParameter("balance");
                String orderCountStr = request.getParameter("orderCount");
                String address = request.getParameter("address");
                String notes = request.getParameter("notes");

                if (id == null || name == null || name.trim().isEmpty() ||
                        email == null || email.trim().isEmpty() ||
                        phone == null || phone.trim().isEmpty()) {
                    LOGGER.warning("Missing required fields for update: id=" + id + ", name=" + name + ", email=" + email + ", phone=" + phone);
                    response.sendRedirect(request.getContextPath() + "/customer_management?error=All required fields must be filled");
                    return;
                }

                double balance;
                int orderCount;
                try {
                    balance = balanceStr != null && !balanceStr.trim().isEmpty() ? Double.parseDouble(balanceStr) : 0.0;
                    orderCount = orderCountStr != null && !orderCountStr.trim().isEmpty() ? Integer.parseInt(orderCountStr) : 0;
                } catch (NumberFormatException e) {
                    LOGGER.warning("Invalid number format for update: balance=" + balanceStr + ", orderCount=" + orderCountStr);
                    response.sendRedirect(request.getContextPath() + "/customer_management?error=Invalid number format");
                    return;
                }

                Customer customer;
                try {
                    customer = new Customer(
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
                } catch (Exception e) {
                    LOGGER.severe("Customer update creation failed: " + e.getMessage());
                    throw new ServletException("Failed to create customer for update", e);
                }

                try {
                    FileStorage.updateCustomer(customer);
                    LOGGER.info("Customer updated: " + name);
                    ActivityLogger.logUserActivity(request, "updated", "customer " + name + " with ID " + customer.getId());
                } catch (Exception e) {
                    LOGGER.severe("Customer update failed: " + name + ", error: " + e.getMessage());
                    throw new ServletException("Failed to update customer", e);
                }

                response.sendRedirect(request.getContextPath() + "/customer_management");
            } else if ("delete".equals(action)) {
                String id = request.getParameter("itemId");
                if (id == null || id.trim().isEmpty()) {
                    LOGGER.warning("Missing itemId for delete");
                    response.sendRedirect(request.getContextPath() + "/customer_management?error=Missing customer ID");
                    return;
                }

                try {
                    FileStorage.deleteCustomer(id);
                    LOGGER.info("Customer deleted: ID=" + id);
                    ActivityLogger.logUserActivity(request, "deleted", "customer with ID " + id);
                } catch (Exception e) {
                    LOGGER.severe("Customer delete failed: ID=" + id + ", error: " + e.getMessage());
                    throw new ServletException("Failed to delete customer", e);
                }

                response.sendRedirect(request.getContextPath() + "/customer_management");
            } else {
                LOGGER.warning("Invalid action: " + action);
                response.sendRedirect(request.getContextPath() + "/customer_management?error=Invalid action");
            }
        } catch (Exception e) {
            LOGGER.severe("Error in doPost: " + e.getMessage());
            throw new ServletException("Customer operation failed", e);
        }
    }
}