package com.ims185.model;

public class Item {
    private int id;
    private String name;
    private String category;
    private int stock;
    private double price;
    private String itemId;
    private String imagePath;
    private String expiryDate;    
    private String addedDate;    
    private String lastUpdatedDate; 

    public Item() {
    }
    public Item(int id, String name, String category, int stock, double price, String itemId, String imagePath, String expiryDate, String addedDate, String lastUpdatedDate) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.stock = stock;
        this.price = price;
        this.itemId = itemId;
        this.imagePath = imagePath;
        this.expiryDate = expiryDate;
        this.addedDate = addedDate;
        this.lastUpdatedDate = lastUpdatedDate;
    }

    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(String expiryDate) {
        this.expiryDate = expiryDate;
    }

    public String getAddedDate() {
        return addedDate;
    }

    public void setAddedDate(String addedDate) {
        this.addedDate = addedDate;
    }

    public String getLastUpdatedDate() {
        return lastUpdatedDate;
    }

    public void setLastUpdatedDate(String lastUpdatedDate) {
        this.lastUpdatedDate = lastUpdatedDate;
    }

    
    @Override
    public String toString() {
        return "Item{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", stock=" + stock +
                ", price=" + price +
                ", itemId='" + itemId + '\'' +
                ", imagePath='" + imagePath + '\'' +
                ", expiryDate='" + expiryDate + '\'' +
                ", addedDate='" + addedDate + '\'' +
                ", lastUpdatedDate='" + lastUpdatedDate + '\'' +
                '}';
    }
}
