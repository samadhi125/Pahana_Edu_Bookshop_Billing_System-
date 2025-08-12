/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import models.Item;
import utils.DBConnection;
import java.sql.*;
import java.util.*;

public class ItemDAO {
    
    public boolean insertItem(Item c) throws SQLException {
        
        String sql = "INSERT INTO items (name, description, price, stock_quantity) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, c.getItemName());
            stmt.setString(2, c.getDescription());
            stmt.setBigDecimal(3, new java.math.BigDecimal(c.getPrice())); // numeric bind
            stmt.setInt(4, Integer.parseInt(c.getStockQuantity())); 
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean updateItem(Item c) throws SQLException {
        String sql = "UPDATE items SET name=?, description=?, price=?, stock_quantity=? WHERE item_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, c.getItemName());
            stmt.setString(2, c.getDescription());
            stmt.setBigDecimal(3, new java.math.BigDecimal(c.getPrice()));
            stmt.setInt(4, Integer.parseInt(c.getStockQuantity()));
            stmt.setInt(5, c.getItemId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public Item getItemById(String ItemId) throws SQLException {
    String sql = "SELECT * FROM items WHERE item_id = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, ItemId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            Item c = new Item();
            c.setItemId(rs.getInt("item_id"));
            c.setItemName(rs.getString("name"));
            c.setDescription(rs.getString("description"));
            c.setPrice(rs.getString("price"));
            c.setStockQuantity(rs.getString("stock_quantity"));
            return c;
        }
    }
    return null;
}

    
    public boolean deleteItem(String  itemId) throws SQLException {
        String sql = "DELETE FROM items WHERE item_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, itemId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public List<Item> getAllItems() throws SQLException {
        List<Item> list = new ArrayList<>();
        String sql = "SELECT * FROM items";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Item c = new Item();
                c.setItemId(rs.getInt("item_id"));
                c.setItemName(rs.getString("name"));
                c.setDescription(rs.getString("description"));
                c.setPrice(rs.getString("price"));
                c.setStockQuantity(rs.getString("stock_quantity"));
                list.add(c);
            }
        }
        return list;
    }
}