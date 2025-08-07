<%-- 
    Document   : login
    Created on : Aug 6, 2025, 11:11:55 PM
    Author     : ugdin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
    <form method="post" action="${pageContext.request.contextPath}/login">
        <label>Username:</label>
        <input type="text" name="username" required /><br/>
        <label>Password:</label>
        <input type="password" name="password" required /><br/>
        <button type="submit">Login</button>
    </form>

    <p style="color:red;">
        ${requestScope.error}
    </p>
</body>
</html>
