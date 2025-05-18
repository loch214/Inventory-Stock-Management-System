package com.ims185.model;

public class Supplier extends Entity {
    private String name;
    private String contactPerson;
    private String email;
    private String phone;
    private String address;

    public Supplier() {
    }

    public Supplier(String name, String contactPerson, String email, String phone, String address) {
        this.name = name;
        this.contactPerson = contactPerson;
        this.email = email;
        this.phone = phone;
        this.address = address;
    }


}