<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"CASHIER".equals(loggedUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Cashier Dashboard</title>
</head>
<body>
    <h1>Welcome Cashier: <%= loggedUser.getUsername() %></h1>
    <p>This is the cashier dashboard.</p>

    <form action="<%=request.getContextPath()%>/logout" method="post">
        <button type="submit">Logout</button>
    </form>
</body>
</html>
