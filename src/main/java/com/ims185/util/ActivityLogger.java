package com.ims185.util;

import com.ims185.model.ActivityLog;
import com.ims185.model.User;
import com.ims185.servlet.ActivityLogServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * Utility class for logging user activities and system events across the application.
 */
public class ActivityLogger {
    
    /**
     * Log a user activity
     * 
     * @param request The HttpServletRequest
     * @param action  The action performed (e.g., "added", "deleted", "updated")
     * @param details Details about the action (e.g., "Item Laptop XPS 15")
     */
    public static void logUserActivity(HttpServletRequest request, String action, String details) {
        ActivityLogServlet.logActivity(request, action, details);
    }
    
    /**
     * Log a system event
     * 
     * @param request The HttpServletRequest
     * @param action  The action performed (e.g., "backup", "maintenance", "error")
     * @param details Details about the action
     */
    public static void logSystemEvent(HttpServletRequest request, String action, String details) {
        ActivityLogServlet.logSystemActivity(request, action, details);
    }
    
    /**
     * Log an inventory action
     * 
     * @param request The HttpServletRequest
     * @param action  The specific inventory action (e.g., "added", "updated", "deleted")
     * @param itemName The name of the item
     * @param quantity The quantity involved (optional, can be null)
     */
    public static void logInventoryAction(HttpServletRequest request, String action, String itemName, Integer quantity) {
        String details = "item " + itemName;
        if (quantity != null) {
            details += " (quantity: " + quantity + ")";
        }
        logUserActivity(request, action, details);
    }
    
    /**
     * Log an order action
     * 
     * @param request The HttpServletRequest
     * @param action  The specific order action (e.g., "placed", "canceled", "fulfilled")
     * @param orderId The order ID
     * @param amount  The order amount (optional, can be null)
     */
    public static void logOrderAction(HttpServletRequest request, String action, String orderId, Double amount) {
        String details = "order " + orderId;
        if (amount != null) {
            details += " ($" + String.format("%.2f", amount) + ")";
        }
        logUserActivity(request, action, details);
    }
    
    /**
     * Log a login event
     * 
     * @param request The HttpServletRequest
     * @param success Whether the login was successful
     * @param username The username that attempted to log in
     */
    public static void logLogin(HttpServletRequest request, boolean success, String username) {
        String action = success ? "logged in" : "failed login attempt";
        String details = success ? "successfully" : "incorrect credentials";
        
        if (success) {
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("loggedInUser");
            ActivityLogServlet.logActivity(request, action, details);
        } else {
            // For failed logins, we need to create a special system log since there's no logged-in user
            ActivityLog log = new ActivityLog(username, action, details);
            ActivityLogServlet.logSystemActivity(request, "login failed", "User: " + username);
        }
    }
    
    /**
     * Log a user logout event
     * 
     * @param request The HttpServletRequest
     */
    public static void logLogout(HttpServletRequest request) {
        logUserActivity(request, "logged out", "session terminated");
    }
}
