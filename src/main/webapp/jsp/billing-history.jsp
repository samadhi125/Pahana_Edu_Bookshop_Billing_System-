<%-- 
    Document   : billing-history
    Created on : Aug 11, 2025, 4:27:06 PM
    Author     : ugdin
--%>

<%@page import="models.Bills"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="models.User,dao.BillingDAO,dao.CustomerDAO,models.Bills,models.Customer,java.util.*" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || (!"CASHIER".equals(u.getRole()) && !"ADMIN".equals(u.getRole()))) { response.sendRedirect("../login.jsp"); return; }

  String account = request.getParameter("account");
  List<Bills> bills = java.util.Collections.emptyList();
  Customer customer = null;
  if (account != null && !account.isBlank()) {
      try {
          CustomerDAO cdao = new CustomerDAO();
          customer = cdao.getCustomerByAccount(account);
          if (customer != null) {
              BillingDAO bdao = new BillingDAO();
              bills = bdao.getBillsByCustomer(customer.getCustomerId());
          }
      } catch (Exception e) {
          e.printStackTrace(); // or log it; optionally show a friendly message
      }
  }
%>
<!DOCTYPE html>
<html>
<head><title>Billing History (Admin)</title></head>
<style>
 /* Reset and base styles */
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

/* Header styles */
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
    content: "💰";
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
    content: "👤";
    font-size: 18px;
}

/* Form styling */
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

form[action*="invoice"] {
    background: none;
    box-shadow: none;
    border: none;
    padding: 0;
    margin: 0 4px;
    display: inline;
}

input[name="account"] {
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

input[name="account"]:focus {
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

button[type="submit"] {
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

button[type="submit"]:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

/* Table styling */
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
    margin-top: 1rem;
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

/* Amount formatting */
td:nth-child(3), /* Subtotal */
td:nth-child(4), /* Tax */
td:nth-child(5) { /* Total */
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    text-align: right;
}

td:nth-child(5) { /* Total column - bold */
    font-weight: 700;
    font-size: 15px;
}

/* Invoice button styling */
form[action*="invoice"] button {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    margin: 2px;
}

form[action*="invoice"] button:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

/* Message styles */
p {
    text-align: center;
    color: #6c757d;
    font-style: italic;
    padding: 2rem;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    margin-top: 1rem;
}

/* Alert styles */
.alert {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 14px 20px;
    border-radius: 10px;
    font-size: 15px;
    font-weight: 500;
    min-width: 280px;
    max-width: 360px;
    background: #fff;
    box-shadow: 0 6px 20px rgba(0, 0, 0, .15);
    border: 2px solid transparent;
    border-left-width: 5px;
    display: flex;
    align-items: center;
    gap: 10px;
    transform: translateX(400px);
    opacity: 0;
    transition: all .4s;
    z-index: 1000;
}

.alert.show {
    transform: translateX(0);
    opacity: 1;
}

.alert.success {
    color: #155724;
    border-color: #28a745;
}

.alert.error {
    color: #dc3545;
    border-color: #dc3545;
}

.alert .close-btn {
    margin-left: auto;
    background: none;
    border: 0;
    font-size: 18px;
    font-weight: 700;
    color: inherit;
    cursor: pointer;
    opacity: .6;
}

.alert .close-btn:hover {
    opacity: 1;
}

/* Responsive Design */
@media (max-width: 768px) {
    body {
        padding: 10px;
    }

    form {
        padding: 1.5rem;
    }

    input[name="account"] {
        max-width: 100%;
    }

    table {
        font-size: 12px;
    }

    th, td {
        padding: 10px 8px;
    }

    h2 {
        font-size: 24px;
    }

    h3 {
        font-size: 18px;
    }
}

@media (max-width: 600px) {
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
</style>
<body>
<h2>Billing History</h2>

<form method="get">
  Account No: <input name="account" value="<%= account==null? "": account %>"/>
  <button type="submit">Search</button>
</form>

<% if (customer != null) { %>
  <h3>Customer: <%= customer.getAccountNumber() %> — <%= customer.getFirstName()+" "+customer.getLastName() %></h3>
  <table border="1" cellpadding="6">
    <tr><th>Bill #</th><th>Date</th><th>Subtotal</th><th>Tax</th><th>Total</th><th>Invoice</th></tr>
    <% for (Bills b : bills) { %>
      <tr>
        <td><%= b.getBillId() %></td>
        <td><%= b.getCreatedAt() %></td>
        <td>Rs <%= String.format("%.2f", b.getSubtotal()) %></td>
        <td><%= b.getTaxRate() %>% (Rs <%= String.format("%.2f", b.getTaxAmount()) %>)</td>
        <td><b>Rs <%= String.format("%.2f", b.getTotal()) %></b></td>
        <td>
          <!-- Re-generate PDF by calling a small invoice servlet if you want; or store PDFs server-side. -->
          <form action="<%=request.getContextPath()%>/invoice" method="get" target="_blank" style="display:inline;">
            <input type="hidden" name="bill_id" value="<%= b.getBillId() %>"/>
            <button type="submit">Open</button>
          </form>
        </td>
      </tr>
    <% } %>
  </table>
<% } else if (account != null) { %>
  <p>No customer found for account.</p>
<% } %>

</body>
</html>
