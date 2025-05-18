package com.ims185.model;

import java.time.LocalDateTime;

public class Customer {
    private String id;
    private String name;
    private String email;
    private String phone;
    private double balance;
    private int orderCount;
    private LocalDateTime lastUpdated;
    private String address;
    private String notes;

    public Customer() {
        this.id = java.util.UUID.randomUUID().toString();
        this.lastUpdated = LocalDateTime.now();
    }

    public Customer(String id, String name, String email, String phone, double balance, int orderCount, LocalDateTime lastUpdated, String address, LocalDateTime now, String notes) {
        this.id = id != null ? id : java.util.UUID.randomUUID().toString();
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.balance = balance;
        this.orderCount = orderCount;
        this.lastUpdated = lastUpdated != null ? lastUpdated : LocalDateTime.now();
        this.address = address != null ? address : "";
        this.notes = notes != null ? notes : "";
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public double getBalance() { return balance; }
    public void setBalance(double balance) { this.balance = balance; }
    public int getOrderCount() { return orderCount; }
    public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    @Override
    public String toString() {
        return String.format("%s,%s,%s,%s,%.2f,%d,%s,%s,%s",
                id, name, email, phone, balance, orderCount, lastUpdated,
                address != null ? address : "",
                notes != null ? notes : "");
    }
}