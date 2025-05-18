<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="com.ims185.model.Item" %>
<%@ page import="com.ims185.model.Order" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Overview - IMS-185</title>
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Roboto', sans-serif; background-color: #f0f0f0; color: #333; line-height: 1.6; }
        .container { display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background-color: #222; color: #fff; padding: 20px; }
        .main-content { flex: 1; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; margin-bottom: 20px; }
        .header-left { font-size: 1.5em; font-weight: bold; color: #e50914; }
        .header-right { text-align: right; color: #000000; }
        .sidebar h1 { font-size: 1.5em; margin-bottom: 20px; color: #e50914; }
        .sidebar ul { list-style: none; padding: 0; }
        .sidebar li { margin-bottom: 10px; }
        .sidebar a { color: #fff; text-decoration: none; display: block; padding: 10px; border-radius: 5px; transition: background-color 0.3s ease; }
        .sidebar a:hover { background-color: #444; }
        .sidebar a.active { background-color: #e50914; font-weight: bold; }
        .section { background-color: #fff; padding: 20px; margin-bottom: 20px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .section h2 { margin-bottom: 15px; color: #555; border-bottom: 1px solid #eee; padding-bottom: 5px; }
        .chart-container { width: 100%; height: 400px; margin-bottom: 30px; }
        .chart-row { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 20px; }
        .chart-col { flex: 1; min-width: 300px; margin-bottom: 20px; }
        .metric-boxes { display: flex; flex-wrap: wrap; gap: 15px; margin-bottom: 20px; }
        .metric-box { flex: 1; min-width: 150px; background: #f9f9f9; padding: 15px; border-radius: 5px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .metric-box h3 { color: #777; margin-bottom: 5px; font-size: 1em; }
        .metric-box .value { font-size: 1.8em; color: #222; font-weight: bold; }
        .metric-box .value.good { color: #28a745; }
        .metric-box .value.warning { color: #ffc107; }
        .metric-box .value.danger { color: #dc3545; }
        .filters { margin-bottom: 20px; display: flex; gap: 15px; }
        .filters select { padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } .chart-row { flex-direction: column; } }
    </style>
</head>
<body>
<%
    User user = (User) session.getAttribute("loggedInUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
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
        </div>        <%
            // Load order data
            List<Order> orders = new ArrayList<>();
            String ordersFilePath = application.getRealPath("/WEB-INF/data/orders.txt");
            try (BufferedReader reader = new BufferedReader(new FileReader(ordersFilePath))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.startsWith("//") || line.trim().isEmpty()) continue;
                    
                    String[] parts = line.split(",");
                    if (parts.length >= 5) {
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
                                // Skip orders with invalid dates
                                continue;
                            }
                        }
                        orders.add(order);
                    }
                }
            } catch (Exception e) {
                // Handle exception or load sample data
                e.printStackTrace();
            }
            
            // Load inventory data
            List<Item> items = new ArrayList<>();
            String inventoryFilePath = application.getRealPath("/WEB-INF/data/inventory.txt");
            try (BufferedReader reader = new BufferedReader(new FileReader(inventoryFilePath))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.startsWith("//") || line.trim().isEmpty()) continue;
                    
                    String[] parts = line.split(",");
                    if (parts.length >= 5) {
                        Item item = new Item();
                        item.setId(Integer.parseInt(parts[0]));
                        item.setName(parts[1]);
                        item.setCategory(parts[2]);
                        item.setStock(Integer.parseInt(parts[3]));
                        item.setPrice(Double.parseDouble(parts[4]));
                        items.add(item);
                    }
                }
            } catch (Exception e) {
                // Handle exception or load sample data
                e.printStackTrace();
            }
            
            // Calculate metrics
            int totalInventoryCount = 0;
            double totalInventoryValue = 0;
            int lowStockItemCount = 0;
            int outOfStockItemCount = 0;
            
            for (Item item : items) {
                totalInventoryCount += item.getStock();
                totalInventoryValue += item.getStock() * item.getPrice();
                if (item.getStock() == 0) {
                    outOfStockItemCount++;
                } else if (item.getStock() < 10) {
                    lowStockItemCount++;
                }
            }
            
            // Calculate sales data by month
            Map<String, Double> monthlySales = new HashMap<>();
            Map<String, Integer> monthlyItemsSold = new HashMap<>();
            
            for (Order order : orders) {
                if (order.getOrderDate() != null) {
                    String monthYear = order.getOrderDate().getMonth() + " " + order.getOrderDate().getYear();
                    monthlySales.put(monthYear, monthlySales.getOrDefault(monthYear, 0.0) + order.getTotalPrice());
                    monthlyItemsSold.put(monthYear, monthlyItemsSold.getOrDefault(monthYear, 0) + order.getQuantity());
                }
            }
            
            // Sort items by sales quantity
            Map<String, Integer> itemSalesQuantity = new HashMap<>();
            for (Order order : orders) {
                itemSalesQuantity.put(order.getItemName(), 
                    itemSalesQuantity.getOrDefault(order.getItemName(), 0) + order.getQuantity());
            }
            
            // Sort items by sales value
            Map<String, Double> itemSalesValue = new HashMap<>();
            for (Order order : orders) {
                itemSalesValue.put(order.getItemName(), 
                    itemSalesValue.getOrDefault(order.getItemName(), 0.0) + order.getTotalPrice());
            }
            
            // Get top 5 items by sales quantity
            List<Map.Entry<String, Integer>> sortedItemsByQuantity = 
                new ArrayList<>(itemSalesQuantity.entrySet());
            sortedItemsByQuantity.sort(Map.Entry.<String, Integer>comparingByValue().reversed());
            
            // Get top 5 items by sales value
            List<Map.Entry<String, Double>> sortedItemsByValue = 
                new ArrayList<>(itemSalesValue.entrySet());
            sortedItemsByValue.sort(Map.Entry.<String, Double>comparingByValue().reversed());
            
            // Prepare data for charts
            StringBuilder monthLabels = new StringBuilder("[");
            StringBuilder salesData = new StringBuilder("[");
            StringBuilder itemsSoldData = new StringBuilder("[");
            
            // Sort monthly data by date
            List<String> months = new ArrayList<>(monthlySales.keySet());
            Collections.sort(months);
            
            for (String month : months) {
                monthLabels.append("'").append(month).append("',");
                salesData.append(monthlySales.get(month)).append(",");
                itemsSoldData.append(monthlyItemsSold.get(month)).append(",");
            }
            
            // Remove last comma
            if (monthLabels.length() > 1) monthLabels.setLength(monthLabels.length() - 1);
            if (salesData.length() > 1) salesData.setLength(salesData.length() - 1);
            if (itemsSoldData.length() > 1) itemsSoldData.setLength(itemsSoldData.length() - 1);
            
            monthLabels.append("]");
            salesData.append("]");
            itemsSoldData.append("]");
            
            // Prepare top items data
            StringBuilder topItemsLabels = new StringBuilder("[");
            StringBuilder topItemsData = new StringBuilder("[");
            StringBuilder topItemsValueLabels = new StringBuilder("[");
            StringBuilder topItemsValueData = new StringBuilder("[");
            
            int count = 0;
            for (Map.Entry<String, Integer> entry : sortedItemsByQuantity) {
                if (count >= 5) break;
                topItemsLabels.append("'").append(entry.getKey()).append("',");
                topItemsData.append(entry.getValue()).append(",");
                count++;
            }
            
            count = 0;
            for (Map.Entry<String, Double> entry : sortedItemsByValue) {
                if (count >= 5) break;
                topItemsValueLabels.append("'").append(entry.getKey()).append("',");
                topItemsValueData.append(entry.getValue()).append(",");
                count++;
            }
            
            // Remove last comma
            if (topItemsLabels.length() > 1) topItemsLabels.setLength(topItemsLabels.length() - 1);
            if (topItemsData.length() > 1) topItemsData.setLength(topItemsData.length() - 1);
            if (topItemsValueLabels.length() > 1) topItemsValueLabels.setLength(topItemsValueLabels.length() - 1);
            if (topItemsValueData.length() > 1) topItemsValueData.setLength(topItemsValueData.length() - 1);
            
            topItemsLabels.append("]");
            topItemsData.append("]");
            topItemsValueLabels.append("]");
            topItemsValueData.append("]");
            
            // Prepare inventory stock data
            StringBuilder itemNamesForStock = new StringBuilder("[");
            StringBuilder stockLevels = new StringBuilder("[");
            
            for (Item item : items) {
                if (item.getStock() < 20) {  // Show only low and critical stock items
                    itemNamesForStock.append("'").append(item.getName()).append("',");
                    stockLevels.append(item.getStock()).append(",");
                }
            }
            
            // Remove last comma
            if (itemNamesForStock.length() > 1) itemNamesForStock.setLength(itemNamesForStock.length() - 1);
            if (stockLevels.length() > 1) stockLevels.setLength(stockLevels.length() - 1);
            
            itemNamesForStock.append("]");
            stockLevels.append("]");
            
            // Get current date
            String currentDate = LocalDate.now().format(DateTimeFormatter.ofPattern("MMMM dd, yyyy"));
        %>
        
        <div class="section">
            <h2>Analytics Overview</h2>
            <p>View graphical insights on sales, stock turnover, and inventory trends as of <%= currentDate %>.</p>
            
            <!-- Key metrics boxes -->
            <div class="metric-boxes">
                <div class="metric-box">
                    <h3>Total Inventory Items</h3>
                    <div class="value"><%= totalInventoryCount %></div>
                </div>
                <div class="metric-box">
                    <h3>Inventory Value</h3>
                    <div class="value">$<%= String.format("%.2f", totalInventoryValue) %></div>
                </div>
                <div class="metric-box">
                    <h3>Low Stock Items</h3>
                    <div class="value <%= lowStockItemCount > 5 ? "warning" : "good" %>"><%= lowStockItemCount %></div>
                </div>
                <div class="metric-box">
                    <h3>Out of Stock</h3>
                    <div class="value <%= outOfStockItemCount > 0 ? "danger" : "good" %>"><%= outOfStockItemCount %></div>
                </div>
            </div>
            
            <!-- Sales Trends Chart -->
            <div class="chart-row">
                <div class="chart-col">
                    <h3>Monthly Sales Trends</h3>
                    <div class="chart-container">
                        <canvas id="salesChart"></canvas>
                    </div>
                </div>
                <div class="chart-col">
                    <h3>Items Sold per Month</h3>
                    <div class="chart-container">
                        <canvas id="itemsSoldChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Top Products Charts -->
            <div class="chart-row">
                <div class="chart-col">
                    <h3>Top 5 Products by Quantity Sold</h3>
                    <div class="chart-container">
                        <canvas id="topItemsChart"></canvas>
                    </div>
                </div>
                <div class="chart-col">
                    <h3>Top 5 Products by Revenue</h3>
                    <div class="chart-container">
                        <canvas id="topRevenueChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Stock Levels Chart -->
            <div class="chart-row">
                <div class="chart-col">
                    <h3>Current Stock Levels (Items with Stock < 20)</h3>
                    <div class="chart-container">
                        <canvas id="stockLevelsChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    // Monthly Sales Chart
    new Chart(document.getElementById('salesChart').getContext('2d'), {
        type: 'line',
        data: {
            labels: <%= monthLabels.toString() %>,
            datasets: [{
                label: 'Monthly Sales ($)',
                data: <%= salesData.toString() %>,
                backgroundColor: 'rgba(229, 9, 20, 0.2)',
                borderColor: '#e50914',
                tension: 0.3,
                fill: true
            }]
        },
        options: { 
            responsive: true,
            maintainAspectRatio: false,
            scales: { y: { beginAtZero: true } }
        }
    });
    
    // Items Sold Chart
    new Chart(document.getElementById('itemsSoldChart').getContext('2d'), {
        type: 'bar',
        data: {
            labels: <%= monthLabels.toString() %>,
            datasets: [{
                label: 'Items Sold',
                data: <%= itemsSoldData.toString() %>,
                backgroundColor: '#3e95cd',
                borderColor: '#3e95cd',
            }]
        },
        options: { 
            responsive: true,
            maintainAspectRatio: false,
            scales: { y: { beginAtZero: true } }
        }
    });
    
    // Top Items Chart
    new Chart(document.getElementById('topItemsChart').getContext('2d'), {
        type: 'bar',
        data: {
            labels: <%= topItemsLabels.toString() %>,
            datasets: [{
                label: 'Quantity Sold',
                data: <%= topItemsData.toString() %>,
                backgroundColor: '#8e5ea2',
                borderColor: '#8e5ea2',
            }]
        },
        options: { 
            responsive: true,
            maintainAspectRatio: false,
            indexAxis: 'y',  // Horizontal bar chart
            scales: { x: { beginAtZero: true } }
        }
    });
    
    // Top Revenue Chart
    new Chart(document.getElementById('topRevenueChart').getContext('2d'), {
        type: 'bar',
        data: {
            labels: <%= topItemsValueLabels.toString() %>,
            datasets: [{
                label: 'Revenue ($)',
                data: <%= topItemsValueData.toString() %>,
                backgroundColor: '#3cba9f',
                borderColor: '#3cba9f',
            }]
        },
        options: { 
            responsive: true,
            maintainAspectRatio: false,
            indexAxis: 'y',  // Horizontal bar chart
            scales: { x: { beginAtZero: true } }
        }
    });
    
    // Stock Levels Chart
    new Chart(document.getElementById('stockLevelsChart').getContext('2d'), {
        type: 'bar',
        data: {
            labels: <%= itemNamesForStock.toString() %>,
            datasets: [{
                label: 'Current Stock',
                data: <%= stockLevels.toString() %>,
                backgroundColor: function(context) {
                    const value = context.dataset.data[context.dataIndex];
                    return value <= 0 ? '#dc3545' : value < 10 ? '#ffc107' : '#28a745';
                }
            }]
        },
        options: { 
            responsive: true,
            maintainAspectRatio: false,
            scales: { 
                y: { 
                    beginAtZero: true,
                    grid: { display: false }
                },
                x: {
                    grid: { display: false },
                    ticks: { autoSkip: false, maxRotation: 90, minRotation: 45 }
                }
            }
        }
    });
</script>
</body>
</html>