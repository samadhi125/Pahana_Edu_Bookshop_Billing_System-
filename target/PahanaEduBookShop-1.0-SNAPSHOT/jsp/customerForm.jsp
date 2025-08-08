<%-- 
    Document   : customerForm
    Created on : Aug 7, 2025, 1:36:44 PM
    Author     : ugdin
--%>
<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || (!"ADMIN".equals(loggedUser.getRole()) && !"CASHIER".equals(loggedUser.getRole()))) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Form</title>
    <script>
        window.onload = function () {
            const params = new URLSearchParams(window.location.search);
            if (params.get("msg") === "success") alert("✔ Operation successful!");
            if (params.get("msg") === "error") alert("❌ Operation failed!");
        }
    </script>
</head>
<body>
    <h2>Customer Registration</h2>
    <form action="../customer" method="post">
    <input type="hidden" name="action" value="${param.action != null ? param.action : 'add'}" />
    <input type="hidden" name="account_number" value="${param.account_number}" />

    First Name: <input type="text" name="first_name" value="${param.first_name}" required><br>
    Last Name: <input type="text" name="last_name" value="${param.last_name}" required><br>
    Phone: <input type="text" name="phone" value="${param.phone}" required><br>
    Address: <input type="text" name="address" value="${param.address}" required><br>
    Email: <input type="email" name="email" value="${param.email}" required><br>

    <input type="submit" value="${param.action == 'edit' ? 'Update' : 'Register'} Customer">
</form>
<%
    dao.CustomerDAO dao = new dao.CustomerDAO();
    java.util.List<models.Customer> customers = dao.getAllCustomers();
%>

<h3>Customer List</h3>
<table border="1">
    <tr>
        <th>Account No</th>
        <th>Name</th>
        <th>Phone</th>
        <th>Actions</th>
    </tr>
    <%
        for (models.Customer c : customers) {
    %>
    <tr>
        <td><%= c.getAccountNumber() %></td>
        <td><%= c.getFirstName() + " " + c.getLastName() %></td>
        <td><%= c.getPhone() %></td>
        <td>
            <form action="customerForm.jsp" method="get" style="display:inline;">
                <input type="hidden" name="action" value="edit"/>
                <input type="hidden" name="account_number" value="<%= c.getAccountNumber() %>"/>
                <input type="hidden" name="first_name" value="<%= c.getFirstName() %>"/>
                <input type="hidden" name="last_name" value="<%= c.getLastName() %>"/>
                <input type="hidden" name="phone" value="<%= c.getPhone() %>"/>
                <input type="hidden" name="address" value="<%= c.getAddress() %>"/>
                <input type="hidden" name="email" value="<%= c.getEmail() %>"/>
                <input type="submit" value="Edit"/>
            </form>

            <form action="../customer" method="post" style="display:inline;" onsubmit="return confirm('Are you sure to delete?');">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="account_number" value="<%= c.getAccountNumber() %>"/>
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

