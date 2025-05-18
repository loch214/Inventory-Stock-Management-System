<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="com.ims185.model.Item" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stock Alerts - IMS-185</title>
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Roboto', sans-serif; background-color: #f0f0f0; color: #333; line-height: 1.6; }
        .container { display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background-color: #222; color: #fff; padding: 20px; }
        .main-content { flex: 1; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; margin-bottom: 20px; }
        .header-left { font-size: 1.5em; font-weight: bold; color: #e50914; }
        .header-right { text-align: right; color: #333; }
        .sidebar h1 { font-size: 1.5em; margin-bottom: 20px; color: #e50914; }}
        .sidebar ul { list-style: none; padding: 0; }
        .sidebar li { margin-bottom: 10px; }
        .sidebar a { color: #fff; text-decoration: none; display: block; padding: 10px; border-radius: 5px; transition: background-color 0.3s ease; }
        .sidebar a:hover { background-color: #444; }
        .sidebar a.active { background-color: #e50914; font-weight: bold; }
        .section { background-color: #fff; padding: 20px; margin-bottom: 20px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .section h2 { margin-bottom: 15px; color: #555; border-bottom: 1px solid #eee; padding-bottom: 5px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f5f5f5; font-weight: bold; }
        tr:hover { background-color: #f9f9f9; }
        .no-alerts { color: #555; font-style: italic; }
        @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } }
        .alert-box {
            padding: 15px;
            margin-bottom: 15px;
            border-radius: 5px;
            background-color: #fff3cd;
            border: 1px solid #ffeeba;
            color: #856404;
        }
        .low-stock-alert {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            font-weight: bold;
        }
        .expiry-alert {
            background-color: #fff3cd;
            border: 1px solid #ffeeba;
            color: #856404;
        }
        .alert-count {
            background-color: #dc3545;
            color: white;
            padding: 2px 8px;
            border-radius: 10px;
            margin-left: 10px;
            font-size: 0.9em;
        }
        .stock-level-critical {
            color: #dc3545;
            font-weight: bold;
        }
        .stock-level-warning {
            color: #ffc107;
            font-weight: bold;
        }    </style>
</head>
<body>
<%
    // Check authentication
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
      // Get attributes
    List<Item> lowStockItems = (List<Item>) request.getAttribute("lowStockItems");
    Integer threshold = (Integer) request.getAttribute("threshold");
    Integer criticalThreshold = (Integer) request.getAttribute("criticalThreshold");
    String error = (String) request.getAttribute("error");
    Integer totalAlerts = (Integer) request.getAttribute("totalAlerts");
    
    if (threshold == null) threshold = 10;
    if (criticalThreshold == null) criticalThreshold = 5;
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
    </div>    <div class="main-content">
        <div class="section">
            <h2>Stock Alerts</h2>
            <% if (error != null) { %>
                <div class="alert-box" style="background-color: #f8d7da; border-color: #f5c6cb; color: #721c24;">
                    <%= error %>
                </div>
            <% } else { %>
                <div class="alert-summary" style="margin-bottom: 20px;">
                    <% if (totalAlerts != null && totalAlerts > 0) { %>
                        <div style="font-size: 1.2em; margin-bottom: 10px;">
                            <strong>Total Stock Alerts: </strong>
                            <span class="alert-count"><%= totalAlerts %></span>
                        </div>
                        
                        <div class="alerts-section">                    <% for (Item item : lowStockItems) { 
                        boolean isCritical = item.getStock() <= criticalThreshold;
                    %>
                        <div class="alert-box <%= isCritical ? "low-stock-alert" : "expiry-alert" %>">
                            <strong><%= item.getName() %></strong> - 
                            <%= isCritical ? "CRITICAL" : "LOW" %> Stock Alert! 
                            Only <strong><%= item.getStock() %></strong> units remaining
                        </div>
                    <% } %>
                        </div>
                    <% } else { %>
                        <div style="color: #155724; background-color: #d4edda; border-color: #c3e6cb; padding: 10px; border-radius: 4px;">
                            All items are well stocked.
                        </div>
                    <% } %>
                </div>            <% if (lowStockItems != null && !lowStockItems.isEmpty()) { %>
                    <h3>Low Stock Items Details (Stock ≤ <%= threshold %> units)</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Current Stock</th>
                                <th>Status</th>
                                <th>Price</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Item item : lowStockItems) {
                                int stock = item.getStock();
                                boolean isCritical = stock <= criticalThreshold;
                            %>
                                <tr>
                                    <td><%= item.getId() %></td>
                                    <td><%= item.getName() %></td>
                                    <td><%= item.getCategory() %></td>
                                    <td class="<%= isCritical ? "stock-level-critical" : "stock-level-warning" %>">
                                        <%= stock %>
                                    </td>
                                    <td>
                                        <%= isCritical ? "CRITICAL" : "WARNING" %>
                                    </td>
                                    <td>$<%= String.format("%.2f", item.getPrice()) %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>