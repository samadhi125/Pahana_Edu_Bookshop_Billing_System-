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

  <script>
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
    function recalc() {
      let subtotal = 0;
      document.querySelectorAll('#lines tr').forEach(tr => {
        const sel = tr.querySelector('select[name="item_id"]');
        const qtyEl = tr.querySelector('input[name="quantity"]');
        if (!sel || !qtyEl) return;
        const unit = getUnitPrice(sel);
        const qty  = parseInt(qtyEl.value || "0", 10) || 0;
        const line = unit * qty;
        tr.querySelector('.unit').textContent = currency(unit);
        tr.querySelector('.lineTotal').textContent = currency(line);
        subtotal += line;
      });
      const taxRate = parseFloat(document.getElementById('tax_rate')?.value || "0") || 0;
      const taxAmt  = subtotal * (taxRate / 100);
      const total   = subtotal + taxAmt;
      document.getElementById('subtotal').textContent = currency(subtotal);
      document.getElementById('tax_amt').textContent  = currency(taxAmt);
      document.getElementById('grand_total').textContent = currency(total);
    }
    function addLine() {
      const itemsEl = document.getElementById('itemsJson');
      if (!itemsEl) { alert('Item list not found'); return; }
      let items = [];
      try { items = JSON.parse(itemsEl.value) || []; } catch (e) { items = []; }
      const tbody = document.getElementById('lines');
      const tr = document.createElement('tr');
      const tdItem = document.createElement('td');
      const sel = document.createElement('select');
      sel.name = 'item_id';
      sel.required = true;
      const ph = document.createElement('option');
      ph.value = ''; ph.text = '-- choose --'; ph.disabled = true; ph.selected = true;
      ph.setAttribute('data-price', '0');
      sel.appendChild(ph);
      items.forEach(it => {
        const o = document.createElement('option');
        o.value = it.itemId;
        o.text = it.itemName + ' (Rs ' + it.price + ')';
        o.setAttribute('data-price', it.price);
        sel.appendChild(o);
      });
      sel.onchange = recalc;
      tdItem.appendChild(sel);
      const tdQty = document.createElement('td');
      const qty = document.createElement('input');
      qty.type = 'number'; qty.name = 'quantity'; qty.min = '1'; qty.value = '1';
      qty.oninput = recalc;
      tdQty.appendChild(qty);
      const tdUnit = document.createElement('td'); tdUnit.className = 'unit'; tdUnit.textContent = '0.00';
      const tdLine = document.createElement('td'); tdLine.className = 'lineTotal'; tdLine.textContent = '0.00';
      const tdAct = document.createElement('td');
      const rm = document.createElement('button'); rm.type='button'; rm.textContent='Remove';
      rm.onclick = () => { tr.remove(); recalc(); };
      tdAct.appendChild(rm);
      tr.appendChild(tdItem);
      tr.appendChild(tdQty);
      tr.appendChild(tdUnit);
      tr.appendChild(tdLine);
      tr.appendChild(tdAct);
      tbody.appendChild(tr);
      recalc();
    }
    function submitBill() {
  const form  = document.getElementById('billForm');
  const tbody = document.getElementById('lines');

  if (!tbody || tbody.children.length === 0) {
    alert('Please add at least one item'); 
    return;
  }

  // Remove any old hidden fields from previous submissions (safety)
  form.querySelectorAll('input[type="hidden"][name="item_id"], input[type="hidden"][name="quantity"]').forEach(n => n.remove());

  // Validate each visible row
  let validCount = 0;
  for (let i = 0; i < tbody.children.length; i++) {
    const tr = tbody.children[i];
    const sel = tr.querySelector('select[name="item_id"]');
    const qty = tr.querySelector('input[name="quantity"]');
    const valQty = parseInt(qty?.value || "0", 10);

    if (sel && sel.value && valQty > 0) {
      validCount++;
    }
  }

  if (validCount === 0) {
    alert('Please select items and set valid quantities');
    return;
  }

  // Submit only the visible named fields (no hidden duplicates)
  form.submit();
}
  </script>
</head>
<body>

<h2>Billing (Cashier)</h2>
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
<% for (int i=0;i<items.size();i++){ Item it = items.get(i); 
   String safeName = it.getItemName() == null ? "" : it.getItemName().replace("\"","\\\"");
   String price = it.getPrice() == null ? "0" : it.getPrice(); %>
  {"itemId": <%=it.getItemId()%>, "itemName": "<%=safeName%>", "price": "<%=price%>"}<%= (i<items.size()-1) ? "," : "" %>
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
   