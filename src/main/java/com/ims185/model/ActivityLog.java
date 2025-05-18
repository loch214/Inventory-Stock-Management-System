package com.ims185.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ActivityLog {
    private String id;
    private String username;
    private String action;
    private String details;
    private LocalDateTime timestamp;
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public ActivityLog() {
        this.id = java.util.UUID.randomUUID().toString();
        this.timestamp = LocalDateTime.now();
    }

    public ActivityLog(String username, String action, String details) {
        this();
        this.username = username;
        this.action = action;
        this.details = details;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
    
    public String getFormattedTimestamp() {
        return timestamp != null ? timestamp.format(DATE_FORMATTER) : "";
    }
    
    @Override
    public String toString() {
        return getFormattedTimestamp() + ": User " + username + " " + action + " - " + details;
    }
}
