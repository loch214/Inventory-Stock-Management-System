<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="com.ims185.model.Item" %>
<%@ page import="com.ims185.model.Notification" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports Dashboard - IMS-185</title>
    <style>
        /* Base styles */
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Roboto', sans-serif; background-color: #f0f0f0; color: #333; line-height: 1.6; }
        .container { display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background-color: #222; color: #fff; padding: 20px; }
        .main-content { flex: 1; padding: 20px; }
        
        /* Header styles */
        .header { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; margin-bottom: 20px; }
        .header-left { font-size: 1.5em; font-weight: bold; color: #e50914; }
        .header-right { text-align: right; color: #333; }
        
        /* Navigation styles */
        .sidebar h1 { font-size: 1.5em; margin-bottom: 20px; color: #e50914; }
        .sidebar ul { list-style: none; padding: 0; }
        .sidebar li { margin-bottom: 10px; }
        .sidebar a { color: #fff; text-decoration: none; display: block; padding: 10px; border-radius: 5px; transition: background-color 0.3s ease; }
        .sidebar a:hover { background-color: #444; }
        .sidebar a.active { background-color: #e50914; font-weight: bold; }
        
        /* Report styles */
        .section { background-color: #fff; padding: 20px; margin-bottom: 20px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .section h2 { margin-bottom: 15px; color: #555; border-bottom: 1px solid #eee; padding-bottom: 5px; }
        .report-header { margin-bottom: 25px; }
        .report-description { color: #666; margin: 10px 0 20px; }
        .report-summary { 
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 25px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
        }
        .summary-card {
            padding: 15px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .summary-card h4 { margin-bottom: 10px; color: #444; }
        .summary-card .count { font-size: 1.5em; font-weight: bold; color: #e50914; }
        
        /* Table styles */
        .report-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .report-table th, .report-table td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        .report-table th { background-color: #f8f9fa; font-weight: bold; }
        .report-table tr:hover { background-color: #f5f5f5; }
        
        /* Status styles */
        .stock-low { color: #dc3545; font-weight: bold; }
        .stock-normal { color: #28a745; }
        .stock-high { color: #17a2b8; }
        .expired { color: #dc3545; font-weight: bold; }
        .near-expiry { color: #ffc107; font-weight: bold; }
        
        /* Form styles */
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; }
        .form-group select { 
            width: 200px; 
            padding: 8px; 
            border-radius: 4px; 
            border: 1px solid #ddd;
            background-color: #fff;
        }
        .submit-button {
            background-color: #e50914;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .submit-button:hover { background-color: #cc0812; }
        
        /* Responsive design */
        @media (max-width: 768px) {
            .container { flex-direction: column; }
            .sidebar { width: 100%; }
            .report-table { display: block; overflow-x: auto; }
        }
    </style>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const navLinks = document.querySelectorAll(".sidebar a");
            const currentPath = window.location.pathname.split("/").pop();
            navLinks.forEach(link => {
                const linkPath = link.getAttribute("href");
                if (linkPath === currentPath) link.classList.add("active");
            });
        });
    </script>
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String reportType = (String) request.getAttribute("reportType");
%>
<div class="container">
    <div class="sidebar">
        <h1>Navigation</h1>
        <ul>
            <li><a href="<%= request.getContextPath() %>/dashboard" <%= request.getRequestURI().contains("dashboard") ? "class=\"active\"" : "" %>>Dashboard</a></li>
            <% if (user.getRole().equals("admin")) { %>
            <li><a href="<%= request.getContextPath() %>/user_management" <%= request.getRequestURI().contains("user_management") ? "class=\"active\"" : "" %>>Manage Users</a></li>
            <% } %>
            <li><a href="<%= request.getContextPath() %>/inventory" <%= request.getRequestURI().contains("inventory") ? "class=\"active\"" : "" %>>Manage Inventory</a></li>
            <li><a href="<%= request.getContextPath() %>/customer_management" <%= request.getRequestURI().contains("customer_management") ? "class=\"active\"" : "" %>>Manage Customers</a></li>
            <li><a href="<%= request.getContextPath() %>/update_profile" <%= request.getRequestURI().contains("update_profile") ? "class=\"active\"" : "" %>>Update Profile</a></li>
            <li><a href="<%= request.getContextPath() %>/items" <%= request.getRequestURI().contains("items") ? "class=\"active\"" : "" %>>View Items</a></li>
            <li><a href="<%= request.getContextPath() %>/reports" <%= request.getRequestURI().contains("reports") ? "class=\"active\"" : "" %>>Reports Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/analytics" <%= request.getRequestURI().contains("analytics") ? "class=\"active\"" : "" %>>Analytics Overview</a></li>
            <li><a href="<%= request.getContextPath() %>/suppliers" <%= request.getRequestURI().contains("suppliers") ? "class=\"active\"" : "" %>>Supplier Management</a></li>
            <li><a href="<%= request.getContextPath() %>/orders" <%= request.getRequestURI().contains("orders") ? "class=\"active\"" : "" %>>Order Processing</a></li>
            <li><a href="<%= request.getContextPath() %>/returns" <%= request.getRequestURI().contains("returns") ? "class=\"active\"" : "" %>>Returns Management</a></li>
            <li><a href="<%= request.getContextPath() %>/stockalerts" <%= request.getRequestURI().contains("stockalerts") ? "class=\"active\"" : "" %>>Stock Alerts</a></li>
            <li><a href="<%= request.getContextPath() %>/activitylog" <%= request.getRequestURI().contains("activitylog") ? "class=\"active\"" : "" %>>User Activity Log</a></li>
            <li><a href="<%= request.getContextPath() %>/settings" <%= request.getRequestURI().contains("settings") ? "class=\"active\"" : "" %>>Settings Configuration</a></li>
            <li><a href="<%= request.getContextPath() %>/audittrail" <%= request.getRequestURI().contains("audittrail") ? "class=\"active\"" : "" %>>Audit Trail</a></li>
            <li><a href="<%= request.getContextPath() %>/notice_board" <%= request.getRequestURI().contains("notice_board") ? "class=\"active\"" : "" %>>Notice Board</a></li>
            <li><a href="<%= request.getContextPath() %>/logout">Logout</a></li>
        </ul>
    </div>
    <div class="main-content">
        <div class="header">
            <div class="header-left">IMS-185</div>
            <div class="header-right">User: <%= user.getUsername() %> (Role: <%= user.getRole() %>)</div>
        </div>
        <div class="section">
            <div class="report-header">
                <h2>Reports Dashboard</h2>
                <p class="report-description">View detailed reports on inventory status, expired items, and stock levels.</p>
                <form action="<%= request.getContextPath() %>/reports" method="get">
                    <div class="form-group">
                        <label for="reportType">Select Report:</label>                        <select id="reportType" name="reportType">
                            <option value="stock" <%= "stock".equals(reportType) ? "selected" : "" %>>Stock Levels</option>
                            <option value="expired" <%= "expired".equals(reportType) ? "selected" : "" %>>Expired Items</option>
                            <option value="notifications" <%= "notifications".equals(reportType) ? "selected" : "" %>>System Notifications</option>
                        </select>
                    </div>
                    <button type="submit" class="submit-button">Generate Report</button>
                </form>
            </div>

            <% if (reportType != null) { %>
                <div class="report-content">
                    <h3><%= request.getAttribute("reportTitle") %></h3>
                    <p class="report-description"><%= request.getAttribute("reportDescription") %></p>
                    
                    <% if ("stock".equals(reportType)) { %>
                        <div class="report-summary">
                            <div class="summary-card">
                                <h4>Total Items</h4>
                                <div class="count"><%= request.getAttribute("totalItems") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Low Stock</h4>
                                <div class="count stock-low"><%= request.getAttribute("lowStockCount") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Normal Stock</h4>
                                <div class="count stock-normal"><%= request.getAttribute("normalStockCount") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>High Stock</h4>
                                <div class="count stock-high"><%= request.getAttribute("highStockCount") %></div>
                            </div>
                        </div>

                        <% List<Item> lowStockItems = (List<Item>) request.getAttribute("lowStockItems"); %>
                        <% if (lowStockItems != null && !lowStockItems.isEmpty()) { %>
                            <h4>Low Stock Items (Less than 10 units)</h4>
                            <table class="report-table">
                                <tr>
                                    <th>Item Name</th>
                                    <th>Category</th>
                                    <th>Stock</th>
                                    <th>Price</th>
                                    <th>Last Updated</th>
                                </tr>
                                <% for (Item item : lowStockItems) { %>
                                    <tr>
                                        <td><%= item.getName() %></td>
                                        <td><%= item.getCategory() %></td>
                                        <td class="stock-low"><%= item.getStock() %></td>
                                        <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                                        <td><%= item.getLastUpdatedDate() %></td>
                                    </tr>
                                <% } %>
                            </table>
                        <% } %>

                        <% List<Item> normalStockItems = (List<Item>) request.getAttribute("normalStockItems"); %>
                        <% if (normalStockItems != null && !normalStockItems.isEmpty()) { %>
                            <h4>Normal Stock Items (10-50 units)</h4>
                            <table class="report-table">
                                <tr>
                                    <th>Item Name</th>
                                    <th>Category</th>
                                    <th>Stock</th>
                                    <th>Price</th>
                                    <th>Last Updated</th>
                                </tr>
                                <% for (Item item : normalStockItems) { %>
                                    <tr>
                                        <td><%= item.getName() %></td>
                                        <td><%= item.getCategory() %></td>
                                        <td class="stock-normal"><%= item.getStock() %></td>
                                        <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                                        <td><%= item.getLastUpdatedDate() %></td>
                                    </tr>
                                <% } %>
                            </table>
                        <% } %>
                    <% } else if ("expired".equals(reportType)) { %>
                        <div class="report-summary">
                            <div class="summary-card">
                                <h4>Total Items</h4>
                                <div class="count"><%= request.getAttribute("totalItems") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Expired</h4>
                                <div class="count expired"><%= request.getAttribute("expiredCount") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Expiring Soon</h4>
                                <div class="count near-expiry"><%= request.getAttribute("nearExpiryCount") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Valid Items</h4>
                                <div class="count stock-normal"><%= request.getAttribute("validCount") %></div>
                            </div>
                        </div>

                        <p class="report-description">
                            Current Date: <%= request.getAttribute("currentDate") %><br>
                            Warning Period: Items expiring before <%= request.getAttribute("warningDate") %>
                        </p>

                        <% List<Item> expiredItems = (List<Item>) request.getAttribute("expiredItems"); %>
                        <% if (expiredItems != null && !expiredItems.isEmpty()) { %>
                            <h4>Expired Items</h4>
                            <table class="report-table">
                                <tr>
                                    <th>Item Name</th>
                                    <th>Category</th>
                                    <th>Stock</th>
                                    <th>Expiry Date</th>
                                    <th>Price</th>
                                </tr>
                                <% for (Item item : expiredItems) { %>
                                    <tr>
                                        <td><%= item.getName() %></td>
                                        <td><%= item.getCategory() %></td>
                                        <td><%= item.getStock() %></td>
                                        <td class="expired"><%= item.getExpiryDate() %></td>
                                        <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                                    </tr>
                                <% } %>
                            </table>
                        <% } %>

                        <% List<Item> nearExpiryItems = (List<Item>) request.getAttribute("nearExpiryItems"); %>
                        <% if (nearExpiryItems != null && !nearExpiryItems.isEmpty()) { %>
                            <h4>Items Expiring Soon (Within 30 days)</h4>
                            <table class="report-table">
                                <tr>
                                    <th>Item Name</th>
                                    <th>Category</th>
                                    <th>Stock</th>
                                    <th>Expiry Date</th>
                                    <th>Price</th>
                                </tr>
                                <% for (Item item : nearExpiryItems) { %>
                                    <tr>
                                        <td><%= item.getName() %></td>
                                        <td><%= item.getCategory() %></td>
                                        <td><%= item.getStock() %></td>
                                        <td class="near-expiry"><%= item.getExpiryDate() %></td>
                                        <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                                    </tr>                        <% } %>
                            </table>
                        <% } %>                    <% } else if ("notifications".equals(reportType)) { %>
                        <div class="report-summary">
                            <div class="summary-card">
                                <h4>Total Notifications</h4>
                                <div class="count"><%= request.getAttribute("totalNotifications") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Low Stock Alerts</h4>
                                <div class="count stock-low"><%= request.getAttribute("lowStockCount") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Expired Items</h4>
                                <div class="count expired"><%= request.getAttribute("expiredCount") %></div>
                            </div>
                            <div class="summary-card">
                                <h4>Expiring Soon</h4>
                                <div class="count near-expiry"><%= request.getAttribute("expiringCount") %></div>
                            </div>
                        </div>

                        <% List<Notification> notifications = (List<Notification>) request.getAttribute("notifications"); %>
                        <% if (notifications != null && !notifications.isEmpty()) { %>
                            <h4>System Notifications</h4>
                            <table class="report-table">
                                <tr>
                                    <th>Message</th>
                                    <th>Timestamp</th>
                                </tr>
                                <% for (Notification notification : notifications) { %>
                                    <tr class="<%= notification.getMessage().toLowerCase().contains("low stock") ? "stock-low" : 
                                        (notification.getMessage().toLowerCase().contains("expir") ? 
                                            (notification.getMessage().toLowerCase().contains("expired") ? "expired" : "near-expiry") : "") %>">
                                        <td><%= notification.getMessage() %></td>
                                        <td><%= notification.getTimestamp() %></td>
                                    </tr>
                                <% } %>
                            </table>
                        <% } else { %>
                            <p>No notifications are currently in the system.</p>
                        <% } %>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>