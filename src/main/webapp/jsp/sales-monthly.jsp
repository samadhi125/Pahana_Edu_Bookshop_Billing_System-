<%-- 
    Document   : sales-monthly
    Created on : Aug 14, 2025, 7:35:20 AM
    Author     : ugdin
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User,dao.ReportDAO,java.util.*,java.math.BigDecimal" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }

  String base = request.getContextPath();
  String yearStr = request.getParameter("year");
  String monthStr = request.getParameter("month");

  List<Map<String,Object>> rows = Collections.emptyList();
  if (yearStr != null && monthStr != null && !yearStr.isBlank() && !monthStr.isBlank()) {
    try {
      int y = Integer.parseInt(yearStr);
      int m = Integer.parseInt(monthStr);
      ReportDAO rdao = new ReportDAO();
      rows = rdao.salesMonthly(y, m);
    } catch (Exception ex) { ex.printStackTrace(); }
  }
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Monthly Sales Report</title></head>
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
    content: "📅";
    font-size: 2rem;
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
    display: flex;
    align-items: center;
    gap: 2rem;
    flex-wrap: wrap;
    justify-content: center;
}

label {
    font-weight: 600;
    color: #555;
    font-size: 1rem;
    display: flex;
    align-items: center;
    gap: 10px;
    flex-direction: column;
    text-align: center;
}

input[type="number"] {
    padding: 12px 16px;
    border: 2px solid #e1e5e9;
    border-radius: 10px;
    font-size: 16px;
    transition: all 0.3s ease;
    background-color: #f8f9fa;
    width: 120px;
    text-align: center;
    font-weight: 600;
}

input[type="number"]:focus {
    outline: none;
    border-color: #667eea;
    background-color: #fff;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
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
    margin-top: 1.5rem;
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
}

th:last-child {
    border-top-right-radius: 15px;
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

/* Date column styling */
td:first-child {
    font-weight: 600;
    color: #667eea;
    font-size: 15px;
}

/* Bills count column */
td:nth-child(2) {
    text-align: center;
    font-weight: 600;
    color: #764ba2;
}

/* Total amount column */
td:nth-child(3) {
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    text-align: right;
    font-weight: 600;
    font-size: 15px;
    color: #28a745;
}

/* Actions column */
td:nth-child(4) {
    text-align: center;
}

/* View bills link styling */
td a {
    color: #667eea;
    text-decoration: none;
    font-weight: 600;
    padding: 8px 16px;
    background: rgba(102, 126, 234, 0.1);
    border-radius: 8px;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}

td a::after {
    content: "🔗";
    font-size: 12px;
}

td a:hover {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* Monthly total row styling */
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
    content: "📄";
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

/* Empty state message */
p:not(:last-child):not([a]) {
    color: #6c757d;
    font-style: italic;
    background: rgba(255, 193, 7, 0.1);
    border: 1px solid rgba(255, 193, 7, 0.3);
    border-left: 4px solid #ffc107;
    text-align: center;
}

/* Month/Year display enhancement */
.period-display {
    text-align: center;
    margin: 1rem 0 2rem 0;
    padding: 1rem;
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
    border-radius: 12px;
    border: 2px solid rgba(102, 126, 234, 0.2);
}

.period-display h2 {
    color: #667eea;
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0;
}

/* Responsive Design */
@media (max-width: 992px) {
    .container {
        padding: 1.5rem;
    }
    
    table {
        font-size: 13px;
    }
    
    th, td {
        padding: 14px 12px;
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
    
    form {
        flex-direction: column;
        align-items: center;
        gap: 1.5rem;
        padding: 1.5rem;
    }
    
    label {
        flex-direction: row;
        justify-content: space-between;
        width: 200px;
    }
    
    input[type="number"] {
        width: 100px;
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
    
    form {
        padding: 1rem;
        gap: 1rem;
    }
    
    label {
        width: 100%;
        justify-content: space-between;
    }
    
    input[type="number"] {
        width: 80px;
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
    
    h1 {
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
</style>
<body>
  <h1>Monthly Sales Report</h1>

  <form method="get" action="">
    <label>Year:
      <input type="number" name="year" min="2000" max="2100" value="<%= (yearStr==null?"":yearStr) %>" required>
    </label>
    <label>Month:
      <input type="number" name="month" min="1" max="12" value="<%= (monthStr==null?"":monthStr) %>" required>
    </label>
    <button type="submit">Load</button>
  </form>

  <%
    if (!rows.isEmpty()) {
      BigDecimal totalAll = BigDecimal.ZERO;
  %>
  <table border="1" cellpadding="4">
    <tr><th>Date</th><th># Bills</th><th>Total</th><th>Actions</th></tr>
    <%
      for (Map<String,Object> r : rows) {
        BigDecimal t = (BigDecimal) r.get("total");
        totalAll = totalAll.add(t==null?BigDecimal.ZERO:t);
    %>
      <tr>
        <td><%=r.get("date")%></td>
        <td><%=r.get("bills")%></td>
        <td><%=r.get("total")%></td>
        <td>
          <a href="<%=base%>/jsp/sales-daily.jsp?date=<%=r.get("date")%>" target="_blank">View bills</a>
        </td>
      </tr>
    <%
      }
    %>
    <tr>
      <td colspan="2" style="text-align:right;"><strong>Monthly Total:</strong></td>
      <td colspan="2"><strong><%=totalAll%></strong></td>
    </tr>
  </table>

  <p>
    Export:
    <a href="<%=base%>/api/reports/sales/monthly?year=<%=yearStr%>&month=<%=monthStr%>&format=csv" target="_blank">CSV</a> |
<!--    <a href="<%=base%>/api/reports/sales/monthly?year=<%=yearStr%>&month=<%=monthStr%>&format=pdf" target="_blank">PDF</a>-->
  </p>
  <%
    } else if (yearStr != null && monthStr != null) {
  %>
    <p>No data for the selected month.</p>
  <%
    }
  %>

  <p><a href="<%=base%>/jsp/reportMenu.jsp">Back</a></p>
</body>
</html>

