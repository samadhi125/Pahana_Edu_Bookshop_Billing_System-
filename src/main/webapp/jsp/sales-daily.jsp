<%-- 
    Document   : sales-daily
    Created on : Aug 14, 2025, 7:34:41 AM
    Author     : ugdin
--%>

<%-- admin/reports/sales-daily.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%@ page import="models.User,java.sql.*,java.math.BigDecimal,utils.DBConnection,dao.ReportDAO,java.util.*" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || !"ADMIN".equals(u.getRole())) { response.sendRedirect("../login.jsp"); return; }

  String base = request.getContextPath();
  String dateStr = request.getParameter("date"); // YYYY-MM-DD

  Map<String,Object> dailySummary = Collections.emptyMap();
  List<Map<String,Object>> bills = new ArrayList<>();

  if (dateStr != null && !dateStr.isBlank()) {
    try {
      java.sql.Date d = java.sql.Date.valueOf(dateStr);

      // 1) Summary via ReportDAO
      ReportDAO rdao = new ReportDAO();
      dailySummary = rdao.salesDaily(d);

      // 2) Bills list for the day
      String qb = "SELECT bill_id, customer_id, subtotal, tax_rate, tax_amount, total, created_at " +
                  "FROM Bills WHERE DATE(created_at)=? ORDER BY created_at";
      try (Connection c = DBConnection.getConnection();
           PreparedStatement ps = c.prepareStatement(qb)) {
        ps.setDate(1, d);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            Map<String,Object> m = new HashMap<>();
            m.put("bill_id", rs.getInt("bill_id"));
            m.put("customer_id", rs.getInt("customer_id"));
            m.put("subtotal", rs.getBigDecimal("subtotal"));
            m.put("tax_rate", rs.getBigDecimal("tax_rate"));
            m.put("tax_amount", rs.getBigDecimal("tax_amount"));
            m.put("total", rs.getBigDecimal("total"));
            m.put("created_at", rs.getTimestamp("created_at"));
            bills.add(m);
          }
        }
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Daily Sales Report</title></head>
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
    max-width: 1400px;
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
    content: "📊";
    font-size: 2rem;
}

h3 {
    color: #333;
    font-size: 1.5rem;
    font-weight: 600;
    margin: 2rem 0 1rem 0;
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 1rem 0;
    border-bottom: 2px solid rgba(102, 126, 234, 0.2);
}

h3::before {
    content: "📈";
    font-size: 1.2rem;
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
    gap: 1rem;
    flex-wrap: wrap;
}

label {
    font-weight: 600;
    color: #555;
    font-size: 1rem;
    display: flex;
    align-items: center;
    gap: 10px;
}

input[type="date"] {
    padding: 12px 16px;
    border: 2px solid #e1e5e9;
    border-radius: 10px;
    font-size: 16px;
    transition: all 0.3s ease;
    background-color: #f8f9fa;
    min-width: 180px;
}

input[type="date"]:focus {
    outline: none;
    border-color: #667eea;
    background-color: #fff;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

button[type="submit"] {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
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

/* Summary table specific styling */
table:first-of-type {
    max-width: 800px;
}

thead, 
tr:first-child {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

th {
    padding: 16px 12px;
    font-weight: 600;
    text-align: left;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

td {
    padding: 14px 12px;
    border-bottom: 1px solid rgba(0, 0, 0, 0.05);
    font-size: 14px;
    color: #555;
    vertical-align: top;
}

/* Alternating row colors */
tbody tr:nth-child(even) {
    background: rgba(102, 126, 234, 0.03);
}

tbody tr:hover {
    background: rgba(102, 126, 234, 0.08);
    transition: background-color 0.3s ease;
}

/* Money columns formatting */
td:nth-child(5), /* Subtotal */
td:nth-child(7), /* Tax Amount */
td:nth-child(8) { /* Total */
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    text-align: right;
    font-weight: 600;
}

/* Total row styling */
tr:last-child {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
    font-weight: 700;
}

tr:last-child td {
    border-top: 2px solid #667eea;
    font-size: 15px;
}

/* Nested items table */
table table {
    margin: 10px 0;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
    border-radius: 10px;
    font-size: 13px;
}

table table th {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.8), rgba(118, 75, 162, 0.8));
    padding: 10px 8px;
    font-size: 12px;
}

table table td {
    padding: 8px;
    font-size: 13px;
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
}

p a {
    color: #667eea;
    text-decoration: none;
    font-weight: 600;
    padding: 8px 16px;
    background: rgba(102, 126, 234, 0.1);
    border-radius: 8px;
    transition: all 0.3s ease;
    margin: 0 5px;
}

p a:hover {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* Back link styling */
p:last-child {
    text-align: center;
    margin-top: 3rem;
}

p:last-child a {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
    border: 2px solid rgba(102, 126, 234, 0.2);
    padding: 12px 24px;
    font-size: 16px;
}

/* Empty state message */
p:not(:last-child):not([a]) {
    text-align: center;
    color: #6c757d;
    font-style: italic;
    background: rgba(255, 193, 7, 0.1);
    border: 1px solid rgba(255, 193, 7, 0.3);
    border-left: 4px solid #ffc107;
}

/* Index number column */
td:first-child {
    font-weight: 600;
    color: #667eea;
    text-align: center;
    width: 50px;
}

/* Responsive Design */
@media (max-width: 1200px) {
    .container {
        padding: 1.5rem;
    }
    
    table {
        font-size: 13px;
    }
    
    th, td {
        padding: 12px 10px;
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
        font-size: 1.25rem;
    }
    
    form {
        flex-direction: column;
        align-items: stretch;
        gap: 15px;
        padding: 1.5rem;
    }
    
    input[type="date"] {
        min-width: auto;
        width: 100%;
    }
    
    /* Make tables horizontally scrollable */
    .table-container {
        overflow-x: auto;
        margin: 1rem 0;
    }
    
    table {
        min-width: 600px;
        font-size: 12px;
    }
    
    th, td {
        padding: 8px 6px;
        white-space: nowrap;
    }
    
    /* Nested table adjustments */
    table table {
        min-width: 400px;
        font-size: 11px;
    }
}

@media (max-width: 480px) {
    h1 {
        font-size: 1.75rem;
    }
    
    h3 {
        font-size: 1.1rem;
        flex-direction: column;
        text-align: center;
        gap: 5px;
    }
    
    form {
        padding: 1rem;
    }
    
    table {
        min-width: 500px;
        font-size: 11px;
    }
    
    th, td {
        padding: 6px 4px;
    }
    
    p {
        padding: 0.75rem;
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
    
    p a {
        display: none;
    }
}
</style>
<body>
  <h1>Daily Sales Report</h1>

  <form method="get" action="">
    <label>Date:
      <input type="date" name="date" value="<%= (dateStr==null?"":dateStr) %>" required>
    </label>
    <button type="submit">Load</button>
  </form>

  <%
    if (dateStr != null && !dateStr.isBlank()) {
  %>
  <h3>Summary (<%=dateStr%>)</h3>
  <table border="1" cellpadding="4">
    <tr><th>Date</th><th>Bills</th><th>Subtotal</th><th>Tax</th><th>Total</th></tr>
    <tr>
      <td><%= String.valueOf(dailySummary.getOrDefault("date","-")) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("bills",0)) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("subtotal",0)) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("tax",0)) %></td>
      <td><%= String.valueOf(dailySummary.getOrDefault("total",0)) %></td>
    </tr>
  </table>

  <p>
    Export:
    <a href="<%=base%>/api/reports/sales/daily?date=<%=dateStr%>&format=csv" target="_blank">CSV</a> |
<!--    <a href="<%=base%>/api/reports/sales/daily?date=<%=dateStr%>&format=pdf" target="_blank">PDF</a>-->
  </p>

  <h3>Bills for <%=dateStr%></h3>
  <%
    if (bills.isEmpty()) {
  %>
    <p>No bills found for this date.</p>
  <%
    } else {
      BigDecimal grandSubtotal = BigDecimal.ZERO;
      BigDecimal grandTax = BigDecimal.ZERO;
      BigDecimal grandTotal = BigDecimal.ZERO;
  %>
  <table border="1" cellpadding="4">
    <tr>
      <th>#</th><th>Bill ID</th><th>Customer ID</th><th>Created At</th>
      <th>Subtotal</th><th>Tax %</th><th>Tax Amount</th><th>Total</th>
    </tr>
    <%
      int idx = 0;
      for (Map<String,Object> b : bills) {
        idx++;
        BigDecimal sub = (BigDecimal)b.get("subtotal");
        BigDecimal taxAmt = (BigDecimal)b.get("tax_amount");
        BigDecimal tot = (BigDecimal)b.get("total");
        BigDecimal taxRate = (BigDecimal)b.get("tax_rate");
        grandSubtotal = grandSubtotal.add(sub==null?BigDecimal.ZERO:sub);
        grandTax = grandTax.add(taxAmt==null?BigDecimal.ZERO:taxAmt);
        grandTotal = grandTotal.add(tot==null?BigDecimal.ZERO:tot);
    %>
      <tr>
        <td><%=idx%></td>
        <td><%=b.get("bill_id")%></td>
        <td><%=b.get("customer_id")%></td>
        <td><%=b.get("created_at")%></td>
        <td><%=sub%></td>
        <td><%=taxRate%></td>
        <td><%=taxAmt%></td>
        <td><%=tot%></td>
      </tr>
      <tr>
        <td></td>
        <td colspan="7">
          <strong>Items</strong>
          <table border="1" cellpadding="2" width="100%">
            <tr>
              <th>Item ID</th><th>Item Name</th><th>Unit Price</th><th>Qty</th><th>Line Total</th>
            </tr>
            <%
              // fetch items for this bill
              try (Connection c = DBConnection.getConnection();
                   PreparedStatement ps = c.prepareStatement(
                     "SELECT item_id,item_name,unit_price,quantity,line_total FROM BillItems WHERE bill_id=?"
                   )) {
                ps.setInt(1, (Integer)b.get("bill_id"));
                try (ResultSet rs = ps.executeQuery()) {
                  while (rs.next()) {
            %>
              <tr>
                <td><%=rs.getInt("item_id")%></td>
                <td><%=rs.getString("item_name")%></td>
                <td><%=rs.getBigDecimal("unit_price")%></td>
                <td><%=rs.getInt("quantity")%></td>
                <td><%=rs.getBigDecimal("line_total")%></td>
              </tr>
            <%
                  }
                }
              } catch (Exception iex) { iex.printStackTrace(); }
            %>
          </table>
        </td>
      </tr>
    <%
      } // end for bills
    %>
    <tr>
      <td colspan="4" style="text-align:right;"><strong>Totals:</strong></td>
      <td><strong><%=grandSubtotal%></strong></td>
      <td></td>
      <td><strong><%=grandTax%></strong></td>
      <td><strong><%=grandTotal%></strong></td>
    </tr>
  </table>
  <%
    } // end else bills not empty
  } // end if date provided
  %>
  <p><a href="<%=base%>/jsp/reportMenu.jsp">Back</a></p>
</body>
</html>
