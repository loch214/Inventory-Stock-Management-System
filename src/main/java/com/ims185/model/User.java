package com.ims185.model;

import java.time.LocalDateTime;
import java.util.UUID;

public class User {
    private String id;
    private String username;
    private String password;
    private String image;
    private boolean active;
    private LocalDateTime timestamp;
    private String email;
    private String phone;
    private String role;

    public User() {
        this.id = UUID.randomUUID().toString();
        this.active = true;
        this.timestamp = LocalDateTime.now();
        this.role = "user";
    }

    public User(String id, String username, String password, String image, boolean active,
                LocalDateTime timestamp, String email, String phone) {
        this.id = id != null ? id : UUID.randomUUID().toString();
        this.username = username;
        this.password = password;
        this.image = image != null ? image : "default.jpg";
        this.active = active;
        this.timestamp = timestamp != null ? timestamp : LocalDateTime.now();
        this.email = email;
        this.phone = phone;
        this.role = "user";
    }

    public User(String id, String username, String password, String image, boolean active,
                LocalDateTime timestamp, String email, String phone, String role) {
        this.id = id != null ? id : UUID.randomUUID().toString();
        this.username = username;
        this.password = password;
        this.image = image != null ? image : "default.jpg";
        this.active = active;
        this.timestamp = timestamp != null ? timestamp : LocalDateTime.now();
        this.email = email;
        this.phone = phone;
        this.role = role != null ? role : "user";
    }

    // Getters
    public String getId() {
        return id;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getImage() {
        return image;
    }

    public boolean isActive() {
        return active;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getRole() {
        return role;
    }

    // Compatibility methods
    public String getProfilePicPath() {
        return image;
    }

    public boolean getIsAdmin() {
        return "admin".equalsIgnoreCase(role);
    }

    public LocalDateTime getCreatedAt() {
        return timestamp;
    }

    // Setters
    public void setId(String id) {
        this.id = id;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setRole(String role) {
        this.role = role;
    }

    @Override
    public String toString() {
        return String.format("%s,%s,%s,%s,%b,%s,%s,%s,%s",
                id, username, password, image, active, timestamp, email, phone, role != null ? role : "user");
    }
}
