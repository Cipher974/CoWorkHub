package com.project.coworkhub.models;

import jakarta.persistence.Entity;

@Entity
public class Desk extends BookableResource {

    private String deskType;

    public Desk() {
    }

    public Desk(String name, String location, double hourlyRate,
                ResourceStatus status, String deskType) {
        super(name, location, 1, hourlyRate, status);   // a desk holds 1 person
        this.deskType = deskType;
    }

    @Override
    public String getType() { return "DESK"; }

    public String getDeskType() { return deskType; }
    public void setDeskType(String deskType) { this.deskType = deskType; }
}