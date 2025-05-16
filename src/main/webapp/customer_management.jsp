
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>IMS-185 Customer Management</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="${pageContext.request.contextPath}/animations.js"></script>
</head>
<body class="windows-11-theme">
<div class="customer-management-container">
    <aside class="sidebar blurred-panel">
        <nav>
            <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <a href="${pageContext.request.contextPath}/inventory">Inventory</a>
            <a href="${pageContext.request.contextPath}/items">Items</a>
            <a href="${pageContext.request.contextPath}/customer_management">Customer Management</a>
            <c:if test="${user.isAdmin}">
                <a href="${pageContext.request.contextPath}/user_management">User Management</a>
            </c:if>
        </nav>
        <div class="theme-toggle">
            <button onclick="toggleTheme()">Toggle Theme</button>
        </div>
    </aside>
    <main>
        <h1>Customer Management</h1>
        <div class="search-box blurred-panel">
            <form action="${pageContext.request.contextPath}/customer_management" method="get">
                <input type="hidden" name="action" value="search">
                <input type="text" name="searchQuery" placeholder="Search by Name or ID">
                <button type="submit" class="btn">Search</button>
            </form>
        </div>
        <h2>Add Customer</h2>
        <form action="${pageContext.request.contextPath}/customer_management" method="post" class="blurred-panel">
            <input type="hidden" name="action" value="add">
            <label for="name">Name:</label>
            <input type="text" id="name" name="name" required><br>
            <label for="itemId">Item:</label>
            <select id="itemId" name="itemId" required>
                <c:forEach var="item" items="${items}">
                    <option value="${item.id}"><c:out value="${item.name}"/> (${item.id})</option>
                </c:forEach>
            </select><br>
            <label for="quantity">Quantity:</label>
            <input type="number" id="quantity" name="quantity" min="1" required><br>
            <label for="contactNo">Contact No:</label>
            <input type="text" id="contactNo" name="contactNo" required><br>
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required><br>
            <button type="submit" class="btn">Add Customer</button>
        </form>
        <h2>Customers</h2>
        <table class="blurred-panel">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Item ID</th>
                <th>Item Name</th>
                <th>Price</th>
                <th>Quantity</th>
                <th>Bought DateTime</th>
                <th>Contact No</th>
                <th>Email</th>
                <th>Actions</th>
            </tr>
            <c:forEach var="customer" items="${customers}">
                <tr>
                    <td><c:out value="${customer.id}"/></td>
                    <td><c:out value="${customer.name}"/></td>
                    <td><c:out value="${customer.itemId}"/></td>
                    <td><c:out value="${customer.itemName}"/></td>
                    <td><c:out value="${customer.price}"/></td>
                    <td><c:out value="${customer.quantity}"/></td>
                    <td><c:out value="${customer.boughtDateTime}"/></td>
                    <td><c:out value="${customer.contactNo}"/></td>
                    <td><c:out value="${customer.email}"/></td>
                    <td>
                        <button onclick="showUpdateForm('${customer.id}', '${customer.name}', '${customer.itemId}', ${customer.quantity}, '${customer.contactNo}', '${customer.email}')">Update</button>
                        <form action="${pageContext.request.contextPath}/customer_management" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="customerId" value="${customer.id}">
                            <button type="submit" class="btn">Delete</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </table>
        <div id="updateForm" class="modal blurred-panel">
            <form action="${pageContext.request.contextPath}/customer_management" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="customerId" id="updateCustomerId">
                <label for="updateName">Name:</label>
                <input type="text" id="updateName" name="name" required><br>
                <label for="updateItemId">Item:</label>
                <select id="updateItemId" name="itemId" required>
                    <c:forEach var="item" items="${items}">
                        <option value="${item.id}"><c:out value="${item.name}"/> (${item.id})</option>
                    </c:forEach>
                </select><br>
                <label for="updateQuantity">Quantity:</label>
                <input type="number" id="updateQuantity" name="quantity" min="1" required><br>
                <label for="updateContactNo">Contact No:</label>
                <input type="text" id="updateContactNo" name="contactNo" required><br>
                <label for="updateEmail">Email:</label>
                <input type="email" id="updateEmail" name="email" required><br>
                <button type="submit" class="btn">Update Customer</button>
                <button type="button" onclick="closeUpdateForm()">Cancel</button>
            </form>
        </div>
        <c:if test="${not empty param.error}">
            <p class="error"><c:out value="${param.error}"/></p>
        </c:if>
    </main>
</div>
<script>
    function showUpdateForm(id, name, itemId, quantity, contactNo, email) {
        document.getElementById('updateCustomerId').value = id;
        document.getElementById('updateName').value = name;
        document.getElementById('updateItemId').value = itemId;
        document.getElementById('updateQuantity').value = quantity;
        document.getElementById('updateContactNo').value = contactNo;
        document.getElementById('updateEmail').value = email;
        document.getElementById('updateForm').style.display = 'block';
    }
    function closeUpdateForm() {
        document.getElementById('updateForm').style.display = 'none';
    }
</script>
</body>
</html>
