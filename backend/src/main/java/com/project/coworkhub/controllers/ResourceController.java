package com.project.coworkhub.controllers;

import com.project.coworkhub.models.*;
import com.project.coworkhub.services.ResourceService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/resources")
@CrossOrigin
public class ResourceController {

    private final ResourceService service;

    public ResourceController(ResourceService service) {
        this.service = service;
    }

    @GetMapping
    public List<BookableResource> getAll(@RequestParam(required = false) String type,
                                         @RequestParam(required = false) Integer minCapacity,
                                         @RequestParam(required = false) String location,
                                         @RequestParam(required = false) Double maxPrice) {
        return service.findAll(type, minCapacity, location, maxPrice);
    }

    @GetMapping("/{id}")
    public BookableResource getOne(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping("/rooms")
    public ResponseEntity<MeetingRoom> createRoom(@Valid @RequestBody MeetingRoom room) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createRoom(room));
    }

    @PostMapping("/desks")
    public ResponseEntity<Desk> createDesk(@Valid @RequestBody Desk desk) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createDesk(desk));
    }

    @PutMapping("/{id}")
    public BookableResource update(@PathVariable Long id, @RequestBody ResourceUpdateRequest req) {
        return service.update(id, req);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}