package com.project.coworkhub.controllers;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.project.coworkhub.models.BookableResource;
import com.project.coworkhub.services.AvailabilityService;

@RestController
@RequestMapping("/api/resources")
public class AvailabilityController {
    private final AvailabilityService availabilityService;

    public AvailabilityController(AvailabilityService availabilityService) {
        this.availabilityService = availabilityService;
    }

    // Example: /api/resources/available?startDateTime=2026-11-20T10:00:00&endDateTime=2026-11-20T11:00:00
    @GetMapping("/available")
    public List<BookableResource> available(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDateTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDateTime,
            @RequestParam(required = false) Integer attendees,
            @RequestParam(required = false) String type) {
        return availabilityService.findAvailable(startDateTime, endDateTime, attendees, type);
    }
}
