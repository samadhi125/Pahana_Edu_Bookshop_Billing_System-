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
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }

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
