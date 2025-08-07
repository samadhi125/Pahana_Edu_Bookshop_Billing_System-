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
    <form method="post" action="/PahanaEduBookShop/customer">
        <input type="hidden" name="action" value="add" />
        First Name: <input type="text" name="first_name" required><br>
        Last Name: <input type="text" name="last_name" required><br>
        Phone: <input type="text" name="phone"><br>
        Address: <input type="text" name="address"><br>
        Email: <input type="email" name="email"><br>
        <button type="submit">Submit</button>
    </form>
</body>
</html>

