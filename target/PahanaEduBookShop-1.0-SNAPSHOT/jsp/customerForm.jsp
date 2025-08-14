<%-- 
    Document   : customerForm
    Created on : Aug 7, 2025, 1:36:44 PM
    Author     : ugdin
--%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="models.User" %>
<%@ page import="dao.CustomerDAO" %>
<%@ page import="models.Customer" %>
<%@ page import="java.util.*" %>

<%
    // --- Auth guard (ADMIN or CASHIER only) ---
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null || (!"ADMIN".equals(loggedUser.getRole()) && !"CASHIER".equals(loggedUser.getRole()))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // --- Load data (server-side search) ---
    String q = request.getParameter("q");
    CustomerDAO dao = new CustomerDAO();
    List<Customer> customers = (q != null && !q.trim().isEmpty())
            ? dao.searchCustomers(q.trim())
            : dao.getAllCustomers();
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Form</title>
    <meta charset="UTF-8" />
   <style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        min-height: 100vh;
        padding: 20px;
    }

    h2 {
        color: #333;
        font-size: 28px;
        font-weight: 700;
        margin-bottom: 1.5rem;
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    h2::before {
        content: "👥";
        font-size: 24px;
    }

    h3 {
        color: #333;
        font-size: 22px;
        font-weight: 600;
        margin: 2rem 0 1rem 0;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    h3::before {
        content: "📋";
        font-size: 18px;
    }

    /* Form Styling */
    form {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 15px;
        padding: 2rem;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        margin-bottom: 2rem;
        max-width: 600px;
    }

    .toolbar form {
        background: none;
        box-shadow: none;
        border: none;
        padding: 0;
        margin: 0;
    }

    .row-actions form {
        background: none;
        box-shadow: none;
        border: none;
        padding: 0;
        margin: 0 4px;
        display: inline;
    }
        /* Custom Alert Styling */
 /* Alerts */
.alert{
  position:fixed; top:20px; right:20px;
  padding:14px 20px; border-radius:10px;
  font-size:15px; font-weight:500;
  min-width:280px; max-width:360px;
  background:#fff; box-shadow:0 6px 20px rgba(0,0,0,.15);
  border:2px solid transparent; border-left-width:5px;
  display:flex; align-items:center; gap:10px;
  transform:translateX(400px); opacity:0; transition:all .4s;
  z-index:1000;
}
.alert.show{ transform:translateX(0); opacity:1; }
.alert.success{ color:#155724; border-color:#28a745; }
.alert.error{ color:#dc3545; border-color:#dc3545; }
.alert .close-btn{
  margin-left:auto; background:none; border:0;
  font-size:18px; font-weight:700; color:inherit; cursor:pointer; opacity:.6;
}
.alert .close-btn:hover{ opacity:1; }

    input[type="text"], 
    input[type="email"] {
        width: 100%;
        max-width: 320px;
        padding: 12px 16px;
        border: 2px solid #e1e5e9;
        border-radius: 10px;
        font-size: 16px;
        transition: all 0.3s ease;
        background-color: #f8f9fa;
        margin: 8px 0 16px 0;
    }

    input[type="text"]:focus,
    input[type="email"]:focus {
        outline: none;
        border-color: #667eea;
        background-color: #fff;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    label {
        display: inline-block;
        min-width: 100px;
        font-weight: 600;
        color: #555;
        font-size: 14px;
    }

    button, 
    input[type="submit"] {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 12px 20px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        margin: 4px;
    }

    button:hover, 
    input[type="submit"]:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
    }

    input[type="submit"][value="Delete"] {
        background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
    }

    input[type="submit"][value="Delete"]:hover {
        box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
    }

    input[type="submit"][value="Edit"] {
        background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    }

    input[type="submit"][value="Edit"]:hover {
        box-shadow: 0 5px 15px rgba(40, 167, 69, 0.3);
    }

    /* Toolbar Styling */
    .toolbar {
        display: flex;
        gap: 15px;
        align-items: center;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 15px;
        padding: 1.5rem;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        margin-bottom: 1.5rem;
        flex-wrap: wrap;
    }

    .toolbar input[type="text"] {
        width: 350px;
        margin: 0;
    }

    .toolbar button {
        margin: 0;
    }

    .muted {
        color: #6c757d;
        font-size: 13px;
        font-style: italic;
        opacity: 0.8;
    }

    /* Table Styling */
    table {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-collapse: separate;
        border-spacing: 0;
        width: 100%;
        max-width: 1200px;
        overflow: hidden;
    }

    thead {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }

    th {
        padding: 16px 12px;
        font-weight: 600;
        text-align: left;
        font-size: 14px;
        border: none;
    }

    th:first-child {
        border-top-left-radius: 15px;
    }

    th:last-child {
        border-top-right-radius: 15px;
    }

    td {
        padding: 14px 12px;
        border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        font-size: 14px;
        color: #555;
    }

    tbody tr {
        transition: all 0.2s ease;
    }

    tbody tr:hover {
        background: rgba(102, 126, 234, 0.05);
    }

    tbody tr:last-child td:first-child {
        border-bottom-left-radius: 15px;
    }

    tbody tr:last-child td:last-child {
        border-bottom-right-radius: 15px;
    }

    .row-actions {
        display: flex;
        gap: 4px;
        justify-content: center;
        flex-wrap: wrap;
    }

    .row-actions form {
        margin: 0;
    }

    .row-actions input[type="submit"] {
        padding: 6px 12px;
        font-size: 12px;
        margin: 2px;
    }

    /* Empty State */
    td[colspan] {
        text-align: center;
        color: #6c757d;
        font-style: italic;
        padding: 2rem;
    }

    /* Responsive Design */
    @media (max-width: 768px) {
        body {
            padding: 10px;
        }

        form {
            padding: 1.5rem;
        }

        input[type="text"], 
        input[type="email"] {
            max-width: 100%;
        }

        .toolbar {
            flex-direction: column;
            align-items: stretch;
            gap: 10px;
        }

        .toolbar input[type="text"] {
            width: 100%;
        }

        table {
            font-size: 12px;
        }

        th, td {
            padding: 10px 8px;
        }

        .row-actions {
            flex-direction: column;
        }

        .row-actions input[type="submit"] {
            width: 100%;
            margin: 1px;
        }
    }

    @media (max-width: 600px) {
        h2 {
            font-size: 24px;
        }

        h3 {
            font-size: 18px;
        }

        /* Stack table on mobile */
        table, thead, tbody, th, td, tr {
            display: block;
        }

        thead tr {
            position: absolute;
            top: -9999px;
            left: -9999px;
        }

        tr {
            border: 1px solid #ccc;
            margin-bottom: 10px;
            padding: 10px;
            border-radius: 10px;
            background: white;
        }

        td {
            border: none;
            position: relative;
            padding-left: 35%;
            padding-top: 8px;
            padding-bottom: 8px;
        }

        td:before {
            content: attr(data-label);
            position: absolute;
            left: 6px;
            width: 30%;
            font-weight: bold;
            color: #333;
        }
    }

    /* Form field styling improvements */
    .form-group {
        margin-bottom: 1rem;
        display: flex;
        flex-direction: column;
    }

    .form-group label {
        margin-bottom: 5px;
        min-width: auto;
    }

    /* Search highlight animation */
    @keyframes highlight {
        0% { background-color: rgba(255, 255, 0, 0.3); }
        100% { background-color: transparent; }
    }

    tbody tr.highlight {
        animation: highlight 1s ease-out;
    }
</style>

    
</head>
<body>
    <h2>Customer Registration</h2>

    <!-- Registration / Edit form -->
    <form action="../customer" method="post">
        <input type="hidden" name="action" value="<%= (request.getParameter("action") != null ? request.getParameter("action") : "add") %>" />
        <input type="hidden" name="account_number" value="<%= (request.getParameter("account_number") != null ? request.getParameter("account_number") : "") %>" />

        First Name: <input type="text" name="first_name" value="<%= (request.getParameter("first_name") != null ? request.getParameter("first_name") : "") %>" required><br>
        Last Name:  <input type="text" name="last_name"  value="<%= (request.getParameter("last_name")  != null ? request.getParameter("last_name")  : "") %>" required><br>
        Phone:      <input type="text" name="phone"      value="<%= (request.getParameter("phone")      != null ? request.getParameter("phone")      : "") %>" required><br>
        Address:    <input type="text" name="address"    value="<%= (request.getParameter("address")    != null ? request.getParameter("address")    : "") %>" required><br>
        Email:      <input type="email" name="email"     value="<%= (request.getParameter("email")     != null ? request.getParameter("email")     : "") %>" required><br>

        <input type="submit" value="<%= "edit".equals(request.getParameter("action")) ? "Update" : "Register" %> Customer">
    </form>

    <!-- Search toolbar: server-side + client-side -->
    <div class="toolbar">
        <form method="get" action="customerForm.jsp">
            <input
                type="text"
                id="custSearch"
                name="q"
                value="<%= (q != null ? q : "") %>"
                placeholder="Search customers… (name, phone, account, email)"
            >
            <button type="submit">Search</button>
        </form>
        <span class="muted">
            Tip: typing here filters instantly; submitting reloads from server.
        </span>
    </div>

    <!-- Customer list -->
    <h3>Customer List <%= (q != null && !q.trim().isEmpty()) ? "(filtered)" : "" %></h3>
    <table>
        <thead>
            <tr>
                <th>Account No</th>
                <th>Name</th>
                <th>Phone</th>
                <th>Email</th>
                <th>Address</th>
                <th style="width:220px;">Actions</th>
            </tr>
        </thead>
        <tbody id="customerRows">
            <%
                for (Customer c : customers) {
            %>
            <tr>
                <td><%= c.getAccountNumber() %></td>
                <td><%= c.getFirstName() + " " + c.getLastName() %></td>
                <td><%= c.getPhone() %></td>
                <td><%= c.getEmail() %></td>
                <td><%= c.getAddress() %></td>
                <td class="row-actions">
                    <!-- Edit: prefill via query params -->
                    <form action="customerForm.jsp" method="get">
                        <input type="hidden" name="action" value="edit"/>
                        <input type="hidden" name="account_number" value="<%= c.getAccountNumber() %>"/>
                        <input type="hidden" name="first_name"     value="<%= c.getFirstName() %>"/>
                        <input type="hidden" name="last_name"      value="<%= c.getLastName() %>"/>
                        <input type="hidden" name="phone"          value="<%= c.getPhone() %>"/>
                        <input type="hidden" name="address"        value="<%= c.getAddress() %>"/>
                        <input type="hidden" name="email"          value="<%= c.getEmail() %>"/>
                        <input type="submit" value="Edit"/>
                    </form>

                    <!-- Delete -->
                    <form action="../customer" method="post" onsubmit="return confirm('Are you sure to delete?');">
                        <input type="hidden" name="action" value="delete"/>
                        <input type="hidden" name="account_number" value="<%= c.getAccountNumber() %>"/>
                        <input type="submit" value="Delete"/>
                    </form>
                </td>
            </tr>
            <%
                } // end for
            %>
            <% if (customers == null || customers.isEmpty()) { %>
            <tr>
                <td colspan="6" style="text-align:center; color:#777;">No customers found.</td>
            </tr>
            <% } %>
        </tbody>
    </table>
        <script>
  function showAlert(message, type) {
    if (!message) return;

    const el = document.createElement('div');
    el.className = 'alert ' + (type === 'error' ? 'error' : 'success');
    el.innerHTML =
      '<span>' + String(message).replace(/</g, '&lt;') + '</span>' +
      '<button class="close-btn" type="button" aria-label="Close">&times;</button>';

    document.body.appendChild(el);

    // animate in
    requestAnimationFrame(() => el.classList.add('show'));

    // auto-close after 4s
    const hide = () => {
      el.classList.remove('show');
      setTimeout(() => el.remove(), 400);
    };
    el.querySelector('.close-btn').addEventListener('click', hide);
    setTimeout(hide, 4000);
  }
</script>


<c:if test="${not empty sessionScope.flashSuccess}">
  <script>
    window.addEventListener('DOMContentLoaded', function () {
      showAlert('<c:out value="${sessionScope.flashSuccess}"/>', 'success');
    });
  </script>
  <c:remove var="flashSuccess" scope="session"/>
</c:if>

<c:if test="${not empty sessionScope.flashError}">
  <script>
    window.addEventListener('DOMContentLoaded', function () {
      showAlert('<c:out value="${sessionScope.flashError}"/>', 'error');
    });
  </script>
  <c:remove var="flashError" scope="session"/>
</c:if>
</body>

</html>
