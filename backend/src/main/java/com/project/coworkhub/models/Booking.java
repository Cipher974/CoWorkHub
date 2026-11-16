package com.project.coworkhub.models;

import jakarta.persistence.*;

@Entity
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "resource_id")
    private BookableResource resource;

    public Long getId() { return id; }
    public BookableResource getResource() { return resource; }
    public void setResource(BookableResource resource) { this.resource = resource; }
}