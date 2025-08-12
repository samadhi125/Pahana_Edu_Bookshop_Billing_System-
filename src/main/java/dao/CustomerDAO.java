/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import models.Customer;
import utils.DBConnection;
import java.sql.*;
import java.util.*;

public class CustomerDAO {
    
    public boolean insertCustomer(Customer c) throws SQLException {
        String newAccountNumber = generateNextAccountNumber();
        c.setAccountNumber(newAccountNumber); // Set the generated account number to the customer object
        
        String sql = "INSERT INTO Customers (account_number, first_name, last_name, phone, address, email) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, newAccountNumber);
            stmt.setString(2, c.getFirstName());
            stmt.setString(3, c.getLastName());
            stmt.setString(4, c.getPhone());
            stmt.setString(5, c.getAddress());
            stmt.setString(6, c.getEmail());
            
            int result = stmt.executeUpdate();
            System.out.println("Database insert result: " + result);
            return result > 0;
        }
    }
    
    private String generateNextAccountNumber() throws SQLException {
        String sql = "SELECT account_number FROM Customers ORDER BY customer_id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                String lastAcc = rs.getString("account_number").replace("ACC", "");
                int nextNum = Integer.parseInt(lastAcc) + 1;
                return String.format("ACC%04d", nextNum);
            } else {
                return "ACC0001";
            }
        }
    }
    
    public boolean updateCustomer(Customer c) throws SQLException {
        String sql = "UPDATE Customers SET first_name=?, last_name=?, phone=?, address=?, email=? WHERE account_number=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, c.getFirstName());
            stmt.setString(2, c.getLastName());
            stmt.setString(3, c.getPhone());
            stmt.setString(4, c.getAddress());
            stmt.setString(5, c.getEmail());
            stmt.setString(6, c.getAccountNumber());
            
            return stmt.executeUpdate() > 0;
        }
    }
    public Customer getCustomerByAccount(String accountNumber) throws SQLException {
    String sql = "SELECT * FROM Customers WHERE account_number = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setString(1, accountNumber);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            Customer c = new Customer();
            c.setCustomerId(rs.getInt("customer_id"));
            c.setAccountNumber(rs.getString("account_number"));
            c.setFirstName(rs.getString("first_name"));
            c.setLastName(rs.getString("last_name"));
            c.setPhone(rs.getString("phone"));
            c.setAddress(rs.getString("address"));
            c.setEmail(rs.getString("email"));
            return c;
        }
    }
    return null;
}
    public Customer getCustomerById(int id) throws SQLException {
    String sql = "SELECT * FROM Customers WHERE customer_id=?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, id);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("customer_id"));
                c.setAccountNumber(rs.getString("account_number"));
                c.setFirstName(rs.getString("first_name"));
                c.setLastName(rs.getString("last_name"));
                return c;
            }
        }
    }
    return null;
}


    
    public boolean deleteCustomer(String accountNumber) throws SQLException {
        String sql = "DELETE FROM Customers WHERE account_number=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, accountNumber);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public List<Customer> getAllCustomers() throws SQLException {
        List<Customer> list = new ArrayList<>();
        String sql = "SELECT * FROM Customers";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getInt("customer_id"));
                c.setAccountNumber(rs.getString("account_number"));
                c.setFirstName(rs.getString("first_name"));
                c.setLastName(rs.getString("last_name"));
                c.setPhone(rs.getString("phone"));
                c.setAddress(rs.getString("address"));
                c.setEmail(rs.getString("email"));
                list.add(c);
            }
        }
        return list;
    }
}
