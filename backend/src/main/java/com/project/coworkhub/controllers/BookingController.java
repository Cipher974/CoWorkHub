package com.project.coworkhub.controllers;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.project.coworkhub.models.Booking;
import com.project.coworkhub.services.BookingService;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.web.bind.annotation.RequestBody;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@Tag(name = "Bookings", description = "Booking management API")
@RestController
@RequestMapping("/api/bookings")
public class BookingController {
    private final BookingService bookingService;
    
    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @Operation(summary = "Get all Bookings", description = "Returns all Booking data")
    @GetMapping
    public List<Booking> getAll() {
        return bookingService.findAll();
    }

    @Operation(summary = "Get Booking by id")
    @GetMapping
    public Booking getById(@PathVariable Long id) {
        return bookingService.findById(id);
    }
    
    @Operation(summary = "Create a Booking")
    @PostMapping
    public ResponseEntity<Booking> createBooking(@Valid @RequestBody Booking booking) {
        Booking response = bookingService.add(booking);

        return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(response);
    }

    @Operation(summary = "Update a Booking")
    @PutMapping("/{id}")
    public Booking updateBooking(@PathVariable Long id, @Valid @RequestBody Booking booking) {
        Booking response = bookingService.update(id, booking);

        return response;
    }

    @Operation(summary = "Delete a Booking")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        bookingService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
