<%@ page import="models.User" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || !"ADMIN".equals(loggedUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
</head>
<body>
    <h1>Welcome Admin: <%= loggedUser.getUsername() %></h1>
    <p>This is the admin dashboard.</p>

    <form action="<%=request.getContextPath()%>/logout" method="post">
        <button type="submit">Logout</button>
    </form>
</body>
</html>
