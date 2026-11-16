package com.project.coworkhub.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import java.util.ArrayList;
import java.util.List;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public abstract class BookableResource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Location is required")
    private String location;

    @Min(value = 1, message = "Capacity must be at least 1")
    private int capacity;

    @PositiveOrZero(message = "Hourly rate cannot be negative")
    private double hourlyRate;

    @Enumerated(EnumType.STRING)
    private ResourceStatus status = ResourceStatus.ACTIVE;

    @OneToMany(mappedBy = "resource")
    @JsonIgnore
    private List<Booking> bookings = new ArrayList<>();

    public BookableResource() {
    }

    public BookableResource(String name, String location, int capacity,
                            double hourlyRate, ResourceStatus status) {
        this.name = name;
        this.location = location;
        this.capacity = capacity;
        this.hourlyRate = hourlyRate;
        this.status = status;
    }

    // "ROOM" or "DESK" - sent to the client in the JSON as "type"
    public abstract String getType();

    public Long getId() { return id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }
    public double getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(double hourlyRate) { this.hourlyRate = hourlyRate; }
    public ResourceStatus getStatus() { return status; }
    public void setStatus(ResourceStatus status) { this.status = status; }
    public List<Booking> getBookings() { return bookings; }
}