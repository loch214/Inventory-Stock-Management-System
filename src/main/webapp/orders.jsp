<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ims185.model.Order" %>
<%@ page import="com.ims185.model.Item" %>
<%@ page import="java.util.List" %>
<%@ page import="com.ims185.model.User" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Order Management - IMS-185</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Roboto', sans-serif; background-color: #f0f0f0; color: #333; line-height: 1.6; }
    .container { display: flex; min-height: 100vh; }
    .sidebar { width: 250px; background-color: #222; color: #fff; padding: 20px; }
    .main-content { flex: 1; padding: 20px; }
    .header { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; margin-bottom: 20px; }
    .header-left { font-size: 1.5em; font-weight: bold; color: #e50914; }
    .header-right { text-align: right; color: #333; }
    .sidebar h1 { font-size: 1.5em; margin-bottom: 20px; color: #e50914; }
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
    form { max-width: 400px; margin-bottom: 20px; }
    label { display: block; margin-bottom: 5px; font-weight: bold; }
    input, select { width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 4px; }
    button { background-color: #e50914; color: #fff; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; margin-right: 5px; }
    button:hover { background-color: #c40810; }
    .no-orders { color: #555; font-style: italic; }
    .error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 10px; margin-bottom: 15px; border-radius: 4px; }
    .success { background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 10px; margin-bottom: 15px; border-radius: 4px; }
    @media (max-width: 768px) { .container { flex-direction: column; } .sidebar { width: 100%; } }
  </style>
</head>
<body>
<%  User loggedInUser = (User) session.getAttribute("loggedInUser");
  if (loggedInUser == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
  }
  List<Order> orders = (List<Order>) request.getAttribute("orders");
  List<String> customers = (List<String>) request.getAttribute("customers");
  List<Item> items = (List<Item>) request.getAttribute("items");
  String error = (String) request.getAttribute("error");
  String success = (String) request.getAttribute("success");
%>
<div class="container">
  <div class="sidebar">
    <h1>Navigation</h1>
    <ul>
      <li><a href="<%= request.getContextPath() %>/dashboard" <%= request.getRequestURI().contains("dashboard") ? "class=\"active\"" : "" %>>Dashboard</a></li>
      <% if (loggedInUser.getIsAdmin()) { %>
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
      <div class="header-right">User: <%= loggedInUser.getUsername() %> (Role: <%= loggedInUser.getIsAdmin() ? "Admin" : "User" %>)</div>
    </div>

    <div class="section">
      <h2>Order Management</h2>
      
      <% if (error != null) { %>
        <div class="error"><%= error %></div>
      <% } %>
      <% if (success != null) { %>
        <div class="success"><%= success %></div>
      <% } %>      <h3>Create New Order</h3>
      <form action="<%= request.getContextPath() %>/orders" method="post" class="order-form">
        <input type="hidden" name="action" value="create">
        <div class="form-group">
          <label for="customerName">Customer Name:</label>
          <select id="customerName" name="customerName" required>
            <option value="">Select a customer</option>
            <% 
              if (customers != null && !customers.isEmpty()) {
                for (String customer : customers) {
                  %>
                  <option value="<%= customer %>"><%= customer %></option>
                  <%
                }
              } else {
                // Read customers from file as fallback
                try {
                  String customerFilePath = application.getRealPath("/WEB-INF/data/customers.txt");
                  java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.FileReader(customerFilePath));
                  String line;
                  while ((line = reader.readLine()) != null) {
                    if (!line.startsWith("//") && !line.trim().isEmpty()) {
                      String[] parts = line.split(",");
                      if (parts.length >= 2) {
                        String customerName = parts[1]; // Name is at index 1
                        %>
                        <option value="<%= customerName %>"><%= customerName %></option>
                        <%
                      }
                    }
                  }
                  reader.close();
                } catch (Exception e) {
                  // If error, provide some default data
                  %>
                  <option value="John Doe">John Doe</option>
                  <option value="Jane Smith">Jane Smith</option>
                  <option value="Robert Johnson">Robert Johnson</option>
                  <option value="Lisa Brown">Lisa Brown</option>
                  <option value="Michael Wilson">Michael Wilson</option>
                  <%
                }
              }
            %>
          </select>
        </div>
        <div class="form-group">
          <label for="itemName">Item Name:</label>
          <select id="itemName" name="itemName" required>
            <option value="">Select an item</option>
            <% 
              if (items != null && !items.isEmpty()) {
                for (Item item : items) {
                  %>
                  <option value="<%= item.getName() %>" data-price="<%= item.getPrice() %>"><%= item.getName() %> - $<%= String.format("%.2f", item.getPrice()) %></option>
                  <%
                }
              } else {
                // Read items from file as fallback
                try {
                  String inventoryFilePath = application.getRealPath("/WEB-INF/data/inventory.txt");
                  java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.FileReader(inventoryFilePath));
                  String line;
                  while ((line = reader.readLine()) != null) {
                    if (!line.startsWith("//") && !line.trim().isEmpty()) {
                      String[] parts = line.split(",");
                      if (parts.length >= 5) {
                        String itemName = parts[1]; // Name is at index 1
                        String price = parts[4];    // Price is at index 4
                        %>
                        <option value="<%= itemName %>" data-price="<%= price %>"><%= itemName %> - $<%= price %></option>
                        <%
                      }
                    }
                  }
                  reader.close();
                } catch (Exception e) {
                  // If error, provide some default data
                  %>
                  <option value="Laptop" data-price="999.99">Laptop - $999.99</option>
                  <option value="Desk Chair" data-price="149.99">Desk Chair - $149.99</option>
                  <option value="Printer" data-price="299.99">Printer - $299.99</option>
                  <option value="Monitor" data-price="249.99">Monitor - $249.99</option>
                  <option value="Keyboard" data-price="79.99">Keyboard - $79.99</option>
                  <%
                }
              }
            %>
          </select>
        </div>
        <div class="form-group">
          <label for="quantity">Quantity:</label>
          <input type="number" id="quantity" name="quantity" required min="1">
        </div>        <div class="form-group">
          <label for="totalPrice">Total Price:</label>
          <input type="number" id="totalPrice" name="totalPrice" step="0.01" required readonly>
        </div>
        <button type="submit">Create Order</button>
      </form>      <h3>Current Orders</h3>
      <% if (orders != null && !orders.isEmpty()) { %>
        <table>
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer Name</th>
              <th>Item Name</th>
              <th>Quantity</th>
              <th>Total Price</th>
              <th>Order Date</th>
              <th>Actions</th>
            </tr>
          </thead>          <tbody>
          <% for (Order order : orders) { %>
            <tr>
              <td>ORD-<%= order.getId() %></td>
              <td><%= order.getCustomerName() %></td>
              <td><%= order.getItemName() %></td>
              <td><%= order.getQuantity() %></td>
              <td>$<%= String.format("%.2f", order.getTotalPrice()) %></td>
              <td><%= order.getOrderDate() %></td>
              <td>
                <form action="<%= request.getContextPath() %>/orders" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="update">
                  <input type="hidden" name="id" value="<%= order.getId() %>">
                  <button type="button" onclick="editOrder(this.form)" style="background-color: #28a745;">Edit</button>
                </form>
                <form action="<%= request.getContextPath() %>/orders" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="id" value="<%= order.getId() %>">
                  <button type="submit" style="background-color: #dc3545;">Delete</button>
                </form>
              </td>
            </tr>
          <% } %>
          </tbody>
        </table>
      <% } else { %>
        <p class="no-orders">No orders found.</p>
      <% } %>
    </div>
    
    <!-- Pending Returns Section -->
    <div class="section">
      <h2>Pending Returns</h2>
      <% 
        // Load returns from file
        List<String[]> pendingReturns = new ArrayList<>();
        String returnsFilePath = application.getRealPath("/") + "returns.txt";
        try (BufferedReader reader = new BufferedReader(new FileReader(returnsFilePath))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    String[] parts = line.split(",");
                    if (parts.length >= 5) {
                        pendingReturns.add(parts);
                    }
                }
            }
        } catch (IOException e) {
            // File might not exist yet
        }
        
        if (!pendingReturns.isEmpty()) {
      %>
      <div style="overflow-x: auto;">
        <table>          <thead>
            <tr>
              <th>Return ID</th>
              <th>Order ID</th>
              <th>Item</th>
              <th>Quantity</th>
              <th>Return Date</th>
              <th>Reason</th>
            </tr>
          </thead>
          <tbody>
          <% 
            // Display most recent returns first (up to 10)
            int count = 0;
            for (int i = pendingReturns.size() - 1; i >= 0 && count < 10; i--, count++) {
              String[] ret = pendingReturns.get(i);
              String reason = ret.length > 5 ? ret[5] : "N/A";
              // Format the reason for display
              switch(reason) {
                case "damaged": reason = "Damaged Product"; break;
                case "wrong_item": reason = "Wrong Item"; break;
                case "defective": reason = "Defective"; break;
                case "changed_mind": reason = "Customer Changed Mind"; break;
              }
          %>
            <tr>
              <td><%= ret[0] %></td>
              <td>ORD-<%= ret[1] %></td>
              <td><%= ret[2] %></td>
              <td><%= ret[3] %></td>              <td><%= ret[4] %></td>
              <td><%= reason %></td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>
      <% } else { %>
        <p>No pending returns at this time.</p>
      <% } %>
    </div>
  </div>
</div>

<script>  // Function to calculate total price based on quantity and unit price
  document.addEventListener('DOMContentLoaded', function() {
    const quantityInput = document.getElementById('quantity');
    const itemSelect = document.getElementById('itemName');
    const totalPriceInput = document.getElementById('totalPrice');
    
    // Update total price when either quantity or item selection changes
    function updateTotalPrice() {
      const quantity = parseInt(quantityInput.value) || 0;
      const selectedOption = itemSelect.options[itemSelect.selectedIndex];
      
      if (quantity > 0 && selectedOption && selectedOption.value) {
        const price = parseFloat(selectedOption.getAttribute('data-price')) || 0;
        if (price > 0) {
          totalPriceInput.value = (price * quantity).toFixed(2);
        }
      }
    }
    
    // Also update when input values are directly changed
    quantityInput.addEventListener('input', updateTotalPrice);
    quantityInput.addEventListener('change', updateTotalPrice);
    itemSelect.addEventListener('change', updateTotalPrice);
    
    // Initial calculation when the page loads
    setTimeout(updateTotalPrice, 500);
  });
  function editOrder(form) {
    const row = form.closest('tr');
    const cells = row.cells;
    
    const customerName = cells[0].textContent;
    const itemName = cells[1].textContent;
    const quantity = cells[2].textContent;
    const totalPrice = cells[3].textContent.replace('$', '');
      // Create modal dialog for editing instead of prompts
    const modalHTML = 
      '<div id="editModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); z-index: 1000; display: flex; align-items: center; justify-content: center;">' +      '<div style="background: white; padding: 20px; border-radius: 5px; width: 400px; max-width: 90%;">' +
          '<h3 style="margin-bottom: 15px;">Edit Order <span style="color: #e50914; font-weight: bold;">ORD-' + form.elements["id"].value + '</span></h3>' +
          '<div style="margin-bottom: 10px;">' +
            '<label for="editCustomerName" style="display: block; margin-bottom: 5px;">Customer Name:</label>' +
            '<select id="editCustomerName" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">' +
            '</select>' +
          '</div>' +
          '<div style="margin-bottom: 10px;">' +
            '<label for="editItemName" style="display: block; margin-bottom: 5px;">Item Name:</label>' +
            '<select id="editItemName" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">' +
            '</select>' +
          '</div>' +
          '<div style="margin-bottom: 10px;">' +
            '<label for="editQuantity" style="display: block; margin-bottom: 5px;">Quantity:</label>' +
            '<input type="number" id="editQuantity" value="' + quantity + '" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">' +
          '</div>' +
          '<div style="margin-bottom: 10px;">' +
            '<label for="editTotalPrice" style="display: block; margin-bottom: 5px;">Total Price:</label>' +
            '<input type="number" id="editTotalPrice" value="' + totalPrice + '" step="0.01" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;" readonly>' +
          '</div>' +
          '<div style="text-align: right;">' +
            '<button id="cancelEdit" style="background-color: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 4px; margin-right: 5px;">Cancel</button>' +
            '<button id="saveEdit" style="background-color: #e50914; color: white; border: none; padding: 8px 16px; border-radius: 4px;">Save</button>' +
          '</div>' +
        '</div>' +
      '</div>';
      // Add modal to body
    const modalContainer = document.createElement('div');
    modalContainer.innerHTML = modalHTML;
    document.body.appendChild(modalContainer);
    
    // Populate customer dropdown in edit modal
    const editCustomerNameSelect = document.getElementById('editCustomerName');
    const customerNameSelect = document.getElementById('customerName');
    // Clone options from the create form dropdown
    Array.from(customerNameSelect.options).forEach(option => {
      const newOption = document.createElement('option');
      newOption.value = option.value;
      newOption.text = option.text;
      editCustomerNameSelect.appendChild(newOption);
    });
    // Select the current customer
    for(let i = 0; i < editCustomerNameSelect.options.length; i++) {
      if(editCustomerNameSelect.options[i].value === customerName) {
        editCustomerNameSelect.selectedIndex = i;
        break;
      }
    }
    
    // Populate item dropdown in edit modal
    const editItemNameSelect = document.getElementById('editItemName');
    const itemNameSelect = document.getElementById('itemName');
    // Clone options from the create form dropdown
    Array.from(itemNameSelect.options).forEach(option => {
      const newOption = document.createElement('option');
      newOption.value = option.value;
      newOption.text = option.text;
      newOption.setAttribute('data-price', option.getAttribute('data-price'));
      editItemNameSelect.appendChild(newOption);
    });
    // Select the current item
    for(let i = 0; i < editItemNameSelect.options.length; i++) {
      if(editItemNameSelect.options[i].value === itemName) {
        editItemNameSelect.selectedIndex = i;
        break;
      }
    }
    
    // Add event listeners for the modal buttons
    document.getElementById('cancelEdit').addEventListener('click', function() {
      document.body.removeChild(modalContainer);
    });
    
    // Function to update total price in edit modal
    function updateEditTotalPrice() {
      const editItemSelect = document.getElementById('editItemName');
      const selectedOption = editItemSelect.options[editItemSelect.selectedIndex];
      const editQuantityInput = document.getElementById('editQuantity');
      const editTotalPriceInput = document.getElementById('editTotalPrice');
      
      if (editQuantityInput.value && selectedOption && selectedOption.value) {
        const price = selectedOption.getAttribute('data-price');
        if (price) {
          editTotalPriceInput.value = (price * editQuantityInput.value).toFixed(2);
        }
      }
    }
    
    // Add event listeners for auto-calculating total price
    document.getElementById('editItemName').addEventListener('change', updateEditTotalPrice);
    document.getElementById('editQuantity').addEventListener('change', updateEditTotalPrice);
    
    document.getElementById('saveEdit').addEventListener('click', function() {
      const newCustomerName = document.getElementById('editCustomerName').value;
      const newItemName = document.getElementById('editItemName').value;
      const newQuantity = document.getElementById('editQuantity').value;
      const newTotalPrice = document.getElementById('editTotalPrice').value;
      
      if (newCustomerName && newItemName && newQuantity && newTotalPrice) {
        const customerNameInput = document.createElement('input');
        customerNameInput.type = 'hidden';
        customerNameInput.name = 'customerName';
        customerNameInput.value = newCustomerName;
        
        const itemNameInput = document.createElement('input');
        itemNameInput.type = 'hidden';
        itemNameInput.name = 'itemName';
        itemNameInput.value = newItemName;
        
        const quantityInput = document.createElement('input');
        quantityInput.type = 'hidden';
        quantityInput.name = 'quantity';
        quantityInput.value = newQuantity;
        
        const totalPriceInput = document.createElement('input');
        totalPriceInput.type = 'hidden';
        totalPriceInput.name = 'totalPrice';
        totalPriceInput.value = newTotalPrice;
        
        form.appendChild(customerNameInput);
        form.appendChild(itemNameInput);
        form.appendChild(quantityInput);
        form.appendChild(totalPriceInput);
        
        document.body.removeChild(modalContainer);
        form.submit();
      }
    });
  }
</script>
</body>
</html>
