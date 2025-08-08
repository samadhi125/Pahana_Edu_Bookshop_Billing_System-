/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controllers;

/**
 *
 * @author ugdin
 */
import dao.ItemDAO;
import models.Item;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/items")
public class itemsController extends HttpServlet {
    private ItemDAO dao = new ItemDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stock_quantity");

        boolean success = false;
        
       
        try {
            // Basic validation for numeric fields
            if (priceStr == null || stockStr == null) throw new IllegalArgumentException("Price/Stock missing");
            // Parse to match DB numeric types
            java.math.BigDecimal price = new java.math.BigDecimal(priceStr);
            int stock = Integer.parseInt(stockStr);

            Item c = new Item();
            c.setItemName(name);
            c.setDescription(description);
            c.setPrice(priceStr);           // keep your model as String if you want
            c.setStockQuantity(stockStr);

            if ("add".equalsIgnoreCase(action)) {
                success = dao.insertItem(c); // will use price/stock as strings but bound properly
            } else if ("edit".equalsIgnoreCase(action)) {
                int itemId = Integer.parseInt(request.getParameter("item_id"));
                c.setItemId(itemId);
                success = dao.updateItem(c);
            } else if ("delete".equalsIgnoreCase(action)) {
                int itemId = Integer.parseInt(request.getParameter("item_id"));
                success = dao.deleteItem(String.valueOf(itemId));
            }
        } catch (Exception e) {
            e.printStackTrace(); // make sure you check server.log
            request.getSession().setAttribute("lastError", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/jsp/itemForm.jsp?msg=" + (success ? "success" : "error"));
    }
}
