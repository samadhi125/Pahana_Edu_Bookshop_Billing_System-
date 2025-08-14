<%-- 
    Document   : customer-consumption
    Created on : Aug 12, 2025, 7:21:09 AM
    Author     : ugdin
--%>

 
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User,dao.ReportDAO,java.util.*,java.math.BigDecimal" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }

  String base   = request.getContextPath();
  String acct   = request.getParameter("account"); // account number (string)
  String fromStr= request.getParameter("from");
  String toStr  = request.getParameter("to");

  List<Map<String,Object>> rows = Collections.emptyList();
  if (acct != null && !acct.isBlank() &&
      fromStr != null && !fromStr.isBlank() &&
      toStr   != null && !toStr.isBlank()) {
    try {
      java.sql.Date from = java.sql.Date.valueOf(fromStr);
      java.sql.Date to   = java.sql.Date.valueOf(toStr);
      ReportDAO rdao = new ReportDAO();
      rows = rdao.customerConsumptionByAccount(acct.trim(), from, to);
    } catch (Exception ex) { ex.printStackTrace(); }
  }
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Customer Consumption Reports</title></head>
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
    color: #333;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
    padding: 2rem;
    border: 1px solid rgba(255, 255, 255, 0.2);
}

/* Header styles */
h1 {
    color: #333;
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 2rem;
    text-align: center;
    background: linear-gradient(135deg, #667eea, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 15px;
}

h1::before {
    content: "🔋";
    font-size: 2rem;
}

h3 {
    color: #333;
    font-size: 1.4rem;
    font-weight: 600;
    margin: 2rem 0 1.5rem 0;
    padding: 1.5rem;
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
    border-radius: 12px;
    border-left: 4px solid #667eea;
    backdrop-filter: blur(5px);
    text-align: center;
    border: 1px solid rgba(102, 126, 234, 0.2);
}

/* Form styling */
form {
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    padding: 2rem;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    margin-bottom: 2rem;
    display: grid;
    grid-template-columns: 1fr 1fr 1fr auto;
    gap: 1.5rem;
    align-items: end;
}

label {
    font-weight: 600;
    color: #555;
    font-size: 1rem;
    display: flex;
    flex-direction: column;
    gap: 8px;
}

input[type="text"],
input[type="date"] {
    padding: 12px 16px;
    border: 2px solid #e1e5e9;
    border-radius: 10px;
    font-size: 16px;
    transition: all 0.3s ease;
    background-color: #f8f9fa;
    font-weight: 500;
}

input[type="text"]:focus,
input[type="date"]:focus {
    outline: none;
    border-color: #667eea;
    background-color: #fff;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

input[type="text"] {
    text-align: center;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1px;
}

button[type="submit"] {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    padding: 12px 30px;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    height: fit-content;
}

button[type="submit"]:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
}

/* Table styling */
table {
    width: 100%;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    border-radius: 15px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-collapse: separate;
    border-spacing: 0;
    overflow: hidden;
    margin-bottom: 2rem;
}

thead,
tr:first-child {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

th {
    padding: 18px 16px;
    font-weight: 600;
    text-align: left;
    font-size: 15px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

th:first-child {
    border-top-left-radius: 15px;
    text-align: center;
}

th:last-child {
    border-top-right-radius: 15px;
    text-align: right;
}

td {
    padding: 16px;
    border-bottom: 1px solid rgba(0, 0, 0, 0.05);
    font-size: 14px;
    color: #555;
    vertical-align: middle;
}

/* Alternating row colors */
tbody tr:nth-child(even) {
    background: rgba(102, 126, 234, 0.03);
}

tbody tr:hover {
    background: rgba(102, 126, 234, 0.08);
    transition: background-color 0.3s ease;
}

tbody tr:last-child {
    border-bottom-left-radius: 15px;
    border-bottom-right-radius: 15px;
}

tbody tr:last-child td:first-child {
    border-bottom-left-radius: 15px;
}

tbody tr:last-child td:last-child {
    border-bottom-right-radius: 15px;
}

/* Column-specific styling */
/* Item ID column */
td:first-child {
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    font-weight: 600;
    color: #667eea;
    text-align: center;
    font-size: 13px;
}

/* Item Name column */
td:nth-child(2) {
    font-weight: 600;
    color: #333;
    max-width: 200px;
}

/* Quantity column */
td:nth-child(3) {
    text-align: center;
    font-weight: 600;
    color: #764ba2;
    font-size: 15px;
}

/* Amount column */
td:nth-child(4) {
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    text-align: right;
    font-weight: 600;
    font-size: 15px;
    color: #28a745;
}

/* Total row styling */
tr:last-child {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.15), rgba(118, 75, 162, 0.15));
    font-weight: 700;
}

tr:last-child td {
    border-top: 3px solid #667eea;
    font-size: 16px;
    padding: 20px 16px;
}

tr:last-child td:nth-child(2) {
    text-align: right;
    color: #333;
}

tr:last-child td:nth-child(3) {
    color: #764ba2;
    font-size: 18px;
}

tr:last-child td:nth-child(4) {
    color: #28a745;
    font-size: 18px;
}

/* Export links styling */
p {
    margin: 1.5rem 0;
    padding: 1rem 1.5rem;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    border: 1px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
    text-align: center;
}

p a {
    color: #667eea;
    text-decoration: none;
    font-weight: 600;
    padding: 10px 20px;
    background: rgba(102, 126, 234, 0.1);
    border-radius: 8px;
    transition: all 0.3s ease;
    margin: 0 8px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

p a::before {
    content: "📊";
    font-size: 14px;
}

p a:hover {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 6px 15px rgba(102, 126, 234, 0.3);
}

/* Back link styling */
p:last-child {
    text-align: center;
    margin-top: 3rem;
}

p:last-child a {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
    border: 2px solid rgba(102, 126, 234, 0.2);
    padding: 15px 30px;
    font-size: 16px;
}

p:last-child a::before {
    content: "⬅️";
}

/* No data message styling */
p:not(:last-child):not(:first-of-type) {
    color: #6c757d;
    font-style: italic;
    background: rgba(255, 193, 7, 0.1);
    border: 1px solid rgba(255, 193, 7, 0.3);
    border-left: 4px solid #ffc107;
    text-align: center;
}

/* Summary card styling */
.summary-card {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin: 2rem 0;
}

.summary-item {
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    padding: 1.5rem;
    text-align: center;
    border: 1px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
}

.summary-item h4 {
    color: #667eea;
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 0.5rem;
}

.summary-item .value {
    color: #333;
    font-size: 1.8rem;
    font-weight: 700;
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
}

/* Responsive Design */
@media (max-width: 1024px) {
    .container {
        padding: 1.5rem;
    }
    
    form {
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
    }
    
    button[type="submit"] {
        grid-column: span 2;
        justify-self: center;
        width: 200px;
    }
}

@media (max-width: 768px) {
    body {
        padding: 10px;
    }
    
    .container {
        padding: 1rem;
        border-radius: 15px;
    }
    
    h1 {
        font-size: 2rem;
        flex-direction: column;
        gap: 10px;
    }
    
    h3 {
        font-size: 1.2rem;
        padding: 1rem;
    }
    
    form {
        grid-template-columns: 1fr;
        gap: 1.5rem;
        padding: 1.5rem;
    }
    
    button[type="submit"] {
        grid-column: span 1;
        width: 100%;
    }
    
    /* Make table horizontally scrollable */
    .table-container {
        overflow-x: auto;
        margin: 1rem 0;
    }
    
    table {
        min-width: 600px;
        font-size: 12px;
    }
    
    th, td {
        padding: 12px 10px;
        white-space: nowrap;
    }
}

@media (max-width: 480px) {
    h1 {
        font-size: 1.75rem;
    }
    
    h3 {
        font-size: 1.1rem;
        padding: 0.75rem;
        text-align: left;
    }
    
    form {
        padding: 1rem;
        gap: 1rem;
    }
    
    input[type="text"],
    input[type="date"] {
        font-size: 14px;
        padding: 10px 12px;
    }
    
    table {
        min-width: 500px;
        font-size: 11px;
    }
    
    th, td {
        padding: 10px 8px;
    }
    
    p {
        padding: 0.75rem;
        font-size: 14px;
    }
    
    p a {
        padding: 8px 12px;
        margin: 0 4px;
        font-size: 14px;
    }
}

/* Print styles */
@media print {
    body {
        background: white;
        padding: 0;
    }
    
    .container {
        background: white;
        box-shadow: none;
        border: none;
        backdrop-filter: none;
    }
    
    h1, h3 {
        color: #333 !important;
        background: none !important;
        -webkit-text-fill-color: #333 !important;
    }
    
    table {
        background: white;
        box-shadow: none;
        border: 1px solid #333;
    }
    
    th {
        background: #f0f0f0 !important;
        color: #333 !important;
    }
    
    p:not(:last-child) a {
        display: none;
    }
}

/* Loading animation for enhanced UX */
@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

table {
    animation: fadeInUp 0.6s ease-out;
}

h3 {
    animation: fadeInUp 0.4s ease-out;
}
</style>
<body>
  <h1>Customer Consumption Reports</h1>

  <form method="get" action="">
    <label>Account No:
      <input type="text" name="account" value="<%= (acct==null?"":acct) %>" required>
    </label>
    <label>From:
      <input type="date" name="from" value="<%= (fromStr==null?"":fromStr) %>" required>
    </label>
    <label>To:
      <input type="date" name="to" value="<%= (toStr==null?"":toStr) %>" required>
    </label>
    <button type="submit">Load</button>
  </form>

  <%
    if (acct != null && fromStr != null && toStr != null) {
      if (!rows.isEmpty()) {
        BigDecimal totalAmt = BigDecimal.ZERO;
        int totalQty = 0;
  %>
  <h3>Account: <%=acct%> | Period: <%=fromStr%> to <%=toStr%></h3>
  <table border="1" cellpadding="4">
    <tr><th>Item ID</th><th>Item Name</th><th>Quantity</th><th>Amount</th></tr>
    <%
      for (Map<String,Object> r : rows) {
        BigDecimal amt = (BigDecimal) r.get("amount");
        Integer qty    = (Integer) r.get("quantity");
        totalAmt = totalAmt.add(amt==null?BigDecimal.ZERO:amt);
        totalQty += (qty==null?0:qty);
    %>
      <tr>
        <td><%=r.get("itemId")%></td>
        <td><%=r.get("itemName")%></td>
        <td><%=r.get("quantity")%></td>
        <td><%=r.get("amount")%></td>
      </tr>
    <%
      } // for
    %>
    <tr>
      <td colspan="2" style="text-align:right;"><strong>Totals:</strong></td>
      <td><strong><%=totalQty%></strong></td>
      <td><strong><%=totalAmt%></strong></td>
    </tr>
  </table>

  <p>
    Export:
    <a href="<%=base%>/api/reports/customer/consumption?account=<%=acct%>&from=<%=fromStr%>&to=<%=toStr%>&format=csv" target="_blank">CSV</a> |
<!--    <a href="<%=base%>/api/reports/customer/consumption?account=<%=acct%>&from=<%=fromStr%>&to=<%=toStr%>&format=pdf" target="_blank">PDF</a>-->
  </p>
  <%
      } else {
  %>
    <p>No data for Account <strong><%=acct%></strong> in the selected period.</p>
  <%
      }
    }
  %>

  <p><a href="<%=base%>/jsp/reportMenu.jsp">Back</a></p>
</body>
</html>



