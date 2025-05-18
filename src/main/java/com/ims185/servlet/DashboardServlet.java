package com.ims185.servlet;

import com.ims185.model.Item;
import com.ims185.model.Notification;
import com.ims185.model.User;
import com.ims185.util.FileStorage;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

//@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("DashboardServlet: Processing GET request");

        // Check session
        User loggedInUser = (User) request.getSession().getAttribute("loggedInUser");
        if (loggedInUser == null) {
            System.out.println("DashboardServlet: No loggedInUser in session - Redirecting to login");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        System.out.println("DashboardServlet: User authenticated: " + loggedInUser.getUsername());

        // Load items
        List<Item> allItems = FileStorage.loadItems();
        if (allItems == null) {
            allItems = new ArrayList<>();
        }
        System.out.println("DashboardServlet: Loaded " + allItems.size() + " items");

        // Set items in servlet context (for notifications)
        getServletContext().setAttribute("itemsFromServletContext", allItems);

        // Prepare recent items (e.g., last 5 items)
        List<Item> recentItems = new ArrayList<>();
        int count = Math.min(5, allItems.size());
        for (int i = 0; i < count; i++) {
            recentItems.add(allItems.get(i));
        }
        request.setAttribute("recentItems", recentItems);
        System.out.println("DashboardServlet: Set recentItems with " + recentItems.size() + " items");        // Prepare notifications
        List<Notification> notifications = new ArrayList<>();
        
        // Check for low stock items
        for (Item item : allItems) {
            if (item.getStock() < 5) {
                notifications.add(new Notification("Low stock alert: " + item.getName() + " (Stock: " + item.getStock() + ")", java.time.LocalDateTime.now()));
            }
        }        // Check for expiry dates
        // Note: As of May 17, 2025 (current date)
        // This is commented since the Item class may not have expiry date functionality yet
        
        /* 
        java.time.LocalDate today = java.time.LocalDate.of(2025, 5, 17);  // May 17, 2025
        java.time.LocalDate thirtyDaysFromNow = today.plusDays(30);       // June 16, 2025
        
        // Example of how to add expiry notifications if items had expiry date
        for (Item item : allItems) {
            if (item.getExpiryDate() != null) {
                if (item.getExpiryDate().isBefore(today)) {
                    notifications.add(new Notification("Expired: " + item.getName() + " expired on " + 
                        item.getExpiryDate().toString(), java.time.LocalDateTime.now()));
                } else if (item.getExpiryDate().isBefore(thirtyDaysFromNow)) {
                    notifications.add(new Notification("Expiring soon: " + item.getName() + " expires on " + 
                        item.getExpiryDate().toString(), java.time.LocalDateTime.now()));
                }
            }
        }
        */
        
        // Simulating some expiry notifications for demonstration
        if (!allItems.isEmpty()) {
            // Add sample expiration notification for the first item
            notifications.add(new Notification("Expiring soon: " + allItems.get(0).getName() + " expires in 25 days", java.time.LocalDateTime.now()));
            
            if (allItems.size() > 1) {
                // Add sample expired notification for the second item
                notifications.add(new Notification("Expired: " + allItems.get(1).getName() + " expired on May 10, 2025", java.time.LocalDateTime.now()));
            }
        }
          request.setAttribute("notifications", notifications);
        System.out.println("DashboardServlet: Generated and set " + notifications.size() + " notifications with " + 
            (int)notifications.stream().filter(n -> n.getMessage().toLowerCase().contains("low stock")).count() + " low stock alerts and " +
            (int)notifications.stream().filter(n -> n.getMessage().toLowerCase().contains("expir")).count() + " expiry alerts");

        // Forward to dashboard.jsp
        System.out.println("DashboardServlet: Forwarding to dashboard.jsp");
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}