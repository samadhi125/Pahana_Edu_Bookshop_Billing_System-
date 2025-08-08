<%-- 
    Document   : itemForm
    Created on : Aug 8, 2025, 6:33:51 PM
    Author     : ugdin
--%>

<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Item Form</title>
    <script>
        window.onload = function () {
            const params = new URLSearchParams(window.location.search);
            if (params.get("msg") === "success") alert("✔ Operation successful!");
            if (params.get("msg") === "error") alert("❌ Operation failed!");
        }
    </script>
</head>
<body>
    <h2>Add Item</h2>
    <form action="../items" method="post">
    <input type="hidden" name="action" value="${param.action != null ? param.action : 'add'}" />
    <input type="hidden" name="item_id" value="${param.item_id}" />

    Item Name: <input type="text" name="name" value="${param.name}" required><br>
    Description: <input type="text" name="description" value="${param.description}" required><br>
    Price: <input type="number" name="price" value="${param.price}" required><br>
    Stock Quantity: <input type="number" name="stock_quantity" value="${param.stock_quantity}" required><br>

    <input type="submit" value="${param.action == 'edit' ? 'Update' : 'Enter'} Item">
</form>
<%
    dao.ItemDAO dao = new dao.ItemDAO();
    java.util.List<models.Item> items = dao.getAllItems();
%>

<h3>Customer List</h3>
<table border="1">
    <tr>
        <th>Item Name</th>
        <th>Description</th>
        <th>Price</th>
        <th>Stock Quantity</th>
        <th>Actions</th>
    </tr>
    <%
        for (models.Item c : items) {
    %>
    <tr>
        <td><%= c.getItemName() %></td>
        <td><%= c.getDescription() + " " + c.getDescription() %></td>
        <td><%= c.getPrice() %></td>
        <td><%= c.getStockQuantity() %></td>
        <td>
            <form action="itemForm.jsp" method="get" style="display:inline;">
                <input type="hidden" name="action" value="edit"/>
                <input type="hidden" name="item_id" value="<%= c.getItemId() %>"/>
                <input type="hidden" name="name" value="<%= c.getItemName() %>"/>
                <input type="hidden" name="description" value="<%= c.getDescription() %>"/>
                <input type="hidden" name="price" value="<%= c.getPrice() %>"/>
                <input type="hidden" name="stock_quantity" value="<%= c.getStockQuantity() %>"/>
                <input type="submit" value="Edit"/>
            </form>

            <form action="../items" method="post" style="display:inline;" onsubmit="return confirm('Are you sure to delete?');">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="item_id" value="<%= c.getItemId() %>"/>
                <input type="submit" value="Delete"/>
            </form>
        </td>
    </tr>
    <%
        }
    %>
</table>
  
</body>
</html>
