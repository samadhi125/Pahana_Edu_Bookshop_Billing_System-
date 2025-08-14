<%-- 
    Document   : billing
    Created on : Aug 11, 2025, 4:19:26 PM
    Author     : ugdin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ page import="models.User,dao.CustomerDAO,dao.ItemDAO,models.Customer,models.Item,java.util.List" %>
<%
  User u = (User) session.getAttribute("user");
  if (u == null || (!"CASHIER".equals(u.getRole()) && !"ADMIN".equals(u.getRole()))) { response.sendRedirect("../login.jsp"); return; }

  CustomerDAO cdao = new CustomerDAO();
  ItemDAO idao = new ItemDAO();
  java.util.List<Customer> customers = cdao.getAllCustomers();
  java.util.List<Item> items = idao.getAllItems();

  String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Billing (Cashier)</title>
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
        color: #333;
    }

    h2 {
        color: #333;
        font-size: 32px;
        font-weight: 700;
        margin-bottom: 2rem;
        background: linear-gradient(135deg, #667eea, #764ba2);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        display: flex;
        align-items: center;
        gap: 12px;
        text-align: center;
        justify-content: center;
    }

    h2::before {
        content: "🧾";
        font-size: 28px;
    }

    h3 {
        color: #333;
        font-size: 22px;
        font-weight: 600;
        margin: 2rem 0 1rem 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    h3::before {
        content: "📦";
        font-size: 18px;
    }

    /* Form Container */
    form {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 20px;
        padding: 2.5rem;
        box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        max-width: 1200px;
        margin: 0 auto;
    }

    /* Form Fields */
    div {
        margin-bottom: 1.5rem;
    }

    label {
        display: block;
        margin-bottom: 8px;
        font-weight: 600;
        color: #555;
        font-size: 16px;
    }

    select, 
    input[type="number"] {
        width: 100%;
        max-width: 400px;
        padding: 12px 16px;
        border: 2px solid ;
        border-radius: 10px;
        font-size: 16px;
        transition: all 0.3s ease;
        background-color: #f8f9fa;
    }

    select:focus, 
    input[type="number"]:focus {
        outline: none;
        border-color: #667eea;
        background-color: #fff;
        box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    /* Buttons */
    button {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 10px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        margin: 8px 8px 8px 0;
        display: inline-flex;
        align-items: center;
        gap: 8px;
    }

    button:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
    }

    button[onclick*="addLine"]::before {
        content: "➕";
        font-size: 14px;
    }

    button[onclick*="submitBill"] {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        font-size: 18px;
        padding: 16px 32px;
        margin-top: 1.5rem;
    }

    button[onclick*="submitBill"]:hover {
        box-shadow: 0 8px 20px rgba(40, 167, 69, 0.3);
    }

    button[onclick*="submitBill"]::before {
        content: "💾";
        font-size: 16px;
    }

    button[type="button"]:not([onclick*="addLine"]):not([onclick*="submitBill"]) {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 6px 12px;
        font-size: 14px;
    }

    button[type="button"]:not([onclick*="addLine"]):not([onclick*="submitBill"]):hover {
        box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
    }

    button[type="button"]:not([onclick*="addLine"]):not([onclick*="submitBill"])::before {
        content: "🗑️";
        font-size: 12px;
    }

    /* Table Styling */
    table {
        width: 100%;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border-radius: 15px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-collapse: separate;
        border-spacing: 0;
        overflow: hidden;
        margin: 1.5rem 0;
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

    tbody tr {
        transition: all 0.2s ease;
        border-bottom: 1px solid rgba(0, 0, 0, 0.05);
    }

    tbody tr:hover {
        background: rgba(102, 126, 234, 0.05);
    }

    tbody tr:last-child {
        border-bottom: none;
    }

    tbody tr:last-child td:first-child {
        border-bottom-left-radius: 15px;
    }

    tbody tr:last-child td:last-child {
        border-bottom-right-radius: 15px;
    }

    td {
        padding: 12px;
        vertical-align: middle;
        font-size: 14px;
    }

    /* Table form elements */
    tbody select {
        width: 100%;
        max-width: none;
        margin: 0;
        font-size: 14px;
        padding: 8px 12px;
    }

    tbody input[type="number"] {
        width: 80px;
        max-width: none;
        margin: 0;
        font-size: 14px;
        padding: 8px 12px;
        text-align: center;
    }

    tbody button {
        margin: 0;
        padding: 6px 12px;
        font-size: 12px;
    }

    /* Price display columns */
    .unit, .lineTotal {
        font-weight: 600;
        color: #28a745;
        text-align: right;
        font-family: 'Courier New', monospace;
    }

    /* Totals Section */
    div:last-of-type:not(:has(button)) {
        background: rgba(102, 126, 234, 0.1);
        border: 2px solid rgba(102, 126, 234, 0.2);
        border-radius: 15px;
        padding: 1.5rem;
        margin-top: 2rem;
        text-align: center;
        font-size: 18px;
        font-weight: 600;
    }

    #subtotal, #tax_amt, #grand_total {
        color: #28a745;
        font-weight: 700;
        font-family: 'Courier New', monospace;
        font-size: 20px;
    }

    #grand_total {
        color: #667eea;
        font-size: 24px;
    }

    /* Customer and Tax Rate Section */
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 2rem;
        align-items: end;
    }

    form > div:first-of-type,
    form > div:nth-of-type(2) {
        margin-bottom: 1rem;
    }

    /* Add Item Button Styling */
    button[onclick*="addLine"] {
        margin-bottom: 1rem;
        background: linear-gradient(135deg, #17a2b8 0%, #20c997 100%);
    }

    button[onclick*="addLine"]:hover {
        box-shadow: 0 8px 20px rgba(23, 162, 184, 0.3);
    }

    /* Empty table state */
    tbody:empty::after {
        content: "No items added yet. Click 'Add Item' to get started.";
        display: block;
        text-align: center;
        padding: 2rem;
        color: #6c757d;
        font-style: italic;
    }

    /* Responsive Design */
    @media (max-width: 768px) {
        body {
            padding: 10px;
        }

        form {
            padding: 1.5rem;
        }

        h2 {
            font-size: 28px;
        }

        .form-row {
            grid-template-columns: 1fr;
            gap: 1rem;
        }

        select, 
        input[type="number"] {
            max-width: 100%;
        }

        table {
            font-size: 12px;
        }

        th, td {
            padding: 8px 6px;
        }

        tbody input[type="number"] {
            width: 60px;
        }

        button[onclick*="submitBill"] {
            font-size: 16px;
            padding: 14px 24px;
        }

        div:last-of-type:not(:has(button)) {
            font-size: 16px;
        }

        #subtotal, #tax_amt, #grand_total {
            font-size: 18px;
        }

        #grand_total {
            font-size: 20px;
        }
    }

    @media (max-width: 600px) {
        /* Stack table columns on very small screens */
        table, thead, tbody, th, td, tr {
            display: block;
        }

        thead tr {
            position: absolute;
            top: -9999px;
            left: -9999px;
        }

        tbody tr {
            border: 1px solid #ddd;
            margin-bottom: 15px;
            padding: 15px;
            border-radius: 10px;
            background: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        td {
            border: none;
            position: relative;
            padding: 10px 10px 10px 35%;
        }

        td:before {
            content: attr(data-label);
            position: absolute;
            left: 10px;
            width: 30%;
            padding-right: 10px;
            white-space: nowrap;
            font-weight: bold;
            color: #333;
        }

        /* Add data labels for mobile */
        tbody tr td:nth-child(1):before { content: "Item:"; }
        tbody tr td:nth-child(2):before { content: "Qty:"; }
        tbody tr td:nth-child(3):before { content: "Unit:"; }
        tbody tr td:nth-child(4):before { content: "Total:"; }
        tbody tr td:nth-child(5):before { content: "Action:"; }

        tbody select,
        tbody input[type="number"] {
            width: 100%;
        }
    }

    /* Loading states */
    .loading {
        opacity: 0.6;
        pointer-events: none;
    }

    .loading button::after {
        content: " 🔄";
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }

    /* Validation states */
    select:invalid,
    input:invalid {
        border-color: #dc3545;
        box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1);
    }

    select:valid,
    input:valid {
        border-color: #28a745;
    }
</style>

<script>
  // --- utils ---
  function currency(n) {
    const x = Number.parseFloat(n || 0);
    return Number.isFinite(x) ? x.toFixed(2) : "0.00";
  }
  function getUnitPrice(selectEl) {
    const opt = selectEl?.options?.[selectEl.selectedIndex] || null;
    const raw = opt?.getAttribute?.('data-price') ?? opt?.dataset?.price ?? "0";
    const num = parseFloat(raw);
    return Number.isFinite(num) ? num : 0;
  }
  function getStock(selectEl) {
    const opt = selectEl?.options?.[selectEl.selectedIndex] || null;
    const raw = opt?.getAttribute?.('data-stock') ?? opt?.dataset?.stock ?? "0";
    const num = parseInt(raw, 10);
    return Number.isFinite(num) ? num : 0;
  }

  // --- totals + stock highlighting ---
  function recalc() {
    let subtotal = 0;
    document.querySelectorAll('#lines tr').forEach(tr => {
      const sel = tr.querySelector('select[name="item_id"]');
      const qtyEl = tr.querySelector('input[name="quantity"]');
      if (!sel || !qtyEl) return;

      const unit  = getUnitPrice(sel);
      const qty   = parseInt(qtyEl.value || "0", 10) || 0;
      const stock = getStock(sel);
      const line  = unit * qty;

      tr.querySelector('.unit').textContent      = currency(unit);
      tr.querySelector('.lineTotal').textContent = currency(line);
      subtotal += line;

      // highlight shortage
      if (qty > stock) {
        tr.style.background = 'rgba(220,53,69,0.08)'; // light red
        qtyEl.title = `Only ${stock} in stock`;
      } else {
        tr.style.background = '';
        qtyEl.title = '';
      }
    });

    const taxRate = parseFloat(document.getElementById('tax_rate')?.value || "0") || 0;
    const taxAmt  = subtotal * (taxRate / 100);
    const total   = subtotal + taxAmt;

    document.getElementById('subtotal').textContent     = currency(subtotal);
    document.getElementById('tax_amt').textContent      = currency(taxAmt);
    document.getElementById('grand_total').textContent  = currency(total);
  }

  // --- add a row ---
  function addLine() {
    const itemsEl = document.getElementById('itemsJson');
    if (!itemsEl) { alert('Item list not found'); return; }

    let items = [];
    try { items = JSON.parse(itemsEl.value) || []; } catch { items = []; }

    const tbody = document.getElementById('lines');
    const tr = document.createElement('tr');

    // Item select
    const tdItem = document.createElement('td');
    const sel = document.createElement('select');
    sel.name = 'item_id';
    sel.required = true;

    const ph = document.createElement('option');
    ph.value = ''; ph.text = '-- choose --'; ph.disabled = true; ph.selected = true;
    ph.setAttribute('data-price','0'); ph.setAttribute('data-stock','0');
    sel.appendChild(ph);

//    items.forEach(it => {
//      const o = document.createElement('option');
//      o.value = it.itemId;
//      o.text  = `${it.itemName} (Rs ${it.price}, stock ${it.stock})`;
//      o.setAttribute('data-price', it.price);
//      o.setAttribute('data-stock', it.stock);
//      sel.appendChild(o);
//    });
//    sel.addEventListener('change', recalc);
//    tdItem.appendChild(sel);
    items.forEach(it => {
        const o = document.createElement('option');
        o.value = it.itemId;
        o.text = it.itemName + ' (Rs ' + it.price + ') ${it.stock}';
        o.setAttribute('data-price', it.price);
        o.setAttribute('data-stock', it.stock);
        sel.appendChild(o);
      });
      sel.onchange = recalc;
      tdItem.appendChild(sel);

    // Qty
    const tdQty = document.createElement('td');
    const qty = document.createElement('input');
    qty.type = 'number'; qty.name = 'quantity'; qty.min = '1'; qty.value = '1';
    qty.addEventListener('input', recalc);
    tdQty.appendChild(qty);

    // Unit + Line
    const tdUnit = document.createElement('td'); tdUnit.className = 'unit';      tdUnit.textContent = '0.00';
    const tdLine = document.createElement('td'); tdLine.className = 'lineTotal'; tdLine.textContent = '0.00';

    // Remove
    const tdAct = document.createElement('td');
    const rm = document.createElement('button'); rm.type='button'; rm.textContent='Remove';
    rm.addEventListener('click', () => { tr.remove(); recalc(); });
    tdAct.appendChild(rm);

    tr.appendChild(tdItem);
    tr.appendChild(tdQty);
    tr.appendChild(tdUnit);
    tr.appendChild(tdLine);
    tr.appendChild(tdAct);

    tbody.appendChild(tr);
    recalc();
  }

  // --- validate + submit ---
  function submitBill() {
    const form  = document.getElementById('billForm');
    const tbody = document.getElementById('lines');

    if (!tbody || tbody.children.length === 0) {
      alert('Please add at least one item');
      return;
    }

    let validCount = 0;
    const shortages = [];
    [...tbody.children].forEach(tr => {
      const sel   = tr.querySelector('select[name="item_id"]');
      const qtyEl = tr.querySelector('input[name="quantity"]');

      const itemTxt = sel?.options?.[sel.selectedIndex]?.text || 'Unknown';
      const qty     = parseInt(qtyEl?.value || "0", 10);
      const stock   = getStock(sel);

      if (sel?.value && qty > 0) {
        validCount++;
        if (qty > stock) shortages.push(`${itemTxt}: need ${qty}, in stock ${stock}`);
      }
    });

    if (validCount === 0) {
      alert('Please select items and set valid quantities');
      return;
    }
    if (shortages.length) {
      alert("Insufficient stock:\n\n" + shortages.join("\n"));
      return;
    }

    form.submit(); // server will also re-check & deduct stock in a transaction
  }
</script>

</head>
<body>

<h2>Invoice</h2>
<% if ("success".equals(msg)) { %><script>alert("✔ Bill saved!");</script><% } %>

<form id="billForm" action="<%=request.getContextPath()%>/billing" method="post" target="_blank">
  <div>
    <label>Customer</label>
    <select name="customer_id" required>
      <option value="">-- choose --</option>
      <% for (Customer c : customers) { %>
        <option value="<%= c.getCustomerId() %>"><%= c.getAccountNumber() %> - <%= c.getFirstName()+" "+c.getLastName() %></option>
      <% } %>
    </select>
  </div>

  <div>
    <label>Tax Rate (%)</label>
    <input id="tax_rate" name="tax_rate" type="number" min="0" step="0.01" value="0" oninput="recalc()" />
  </div>

<input type="hidden" id="itemsJson" value='[
<% for (int i=0;i<items.size();i++){ 
     Item it = items.get(i); 
     String safeName = it.getItemName() == null ? "" : it.getItemName().replace("\"","\\\"");
     String price = it.getPrice() == null ? "0" : it.getPrice();
     String stock = it.getStockQuantity() == null ? "0" : it.getStockQuantity();
%>
  {"itemId": <%=it.getItemId()%>, "itemName": "<%=safeName%>", "price": "<%=price%>", "stock": "<%=stock%>"}<%= (i<items.size()-1) ? "," : "" %>
<% } %>
]' />

  <h3>Items</h3>
  <button type="button" onclick="addLine()">+ Add Item</button>

  <table border="1" cellpadding="5" cellspacing="0">
    <thead>
      <tr>
        <th>Item</th>
        <th>Qty</th>
        <th>Unit</th>
        <th>Line Total</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody id="lines"></tbody>
  </table>

  <div>
    Subtotal: Rs <span id="subtotal">0.00</span> |
    Tax: Rs <span id="tax_amt">0.00</span> |
    Grand Total: Rs <span id="grand_total">0.00</span>
  </div>

  <div>
    <button type="button" onclick="submitBill()">Save & Print</button>
  </div>
</form>

</body>
</html>
   