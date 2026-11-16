package com.project.coworkhub.services;

import com.project.coworkhub.models.*;
import com.project.coworkhub.repository.ResourceRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class ResourceService {

    private final ResourceRepository repository;

    public ResourceService(ResourceRepository repository) {
        this.repository = repository;
    }

    // All filters are optional (null = ignore that filter)
    public List<BookableResource> findAll(String type, Integer minCapacity,
                                          String location, Double maxPrice) {
        return repository.findAll().stream()
                .filter(r -> type == null || type.isBlank() || r.getType().equalsIgnoreCase(type))
                .filter(r -> minCapacity == null || r.getCapacity() >= minCapacity)
                .filter(r -> location == null || location.isBlank()
                        || r.getLocation().toLowerCase().contains(location.toLowerCase()))
                .filter(r -> maxPrice == null || r.getHourlyRate() <= maxPrice)
                .toList();
    }

    public BookableResource findById(Long id) {
        return repository.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Resource with id " + id + " was not found"));
    }

    public MeetingRoom createRoom(MeetingRoom room) {
        if (room.getStatus() == null) room.setStatus(ResourceStatus.ACTIVE);
        return repository.save(room);
    }

    public Desk createDesk(Desk desk) {
        desk.setCapacity(1);                       // a desk holds only one person
        if (desk.getStatus() == null) desk.setStatus(ResourceStatus.ACTIVE);
        return repository.save(desk);
    }

    public BookableResource update(Long id, ResourceUpdateRequest req) {
        BookableResource resource = findById(id);

        if (req.getName() != null) {
            if (req.getName().isBlank())
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Name cannot be empty");
            resource.setName(req.getName());
        }
        if (req.getLocation() != null) {
            if (req.getLocation().isBlank())
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Location cannot be empty");
            resource.setLocation(req.getLocation());
        }
        if (req.getHourlyRate() != null) {
            if (req.getHourlyRate() < 0)
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Hourly rate cannot be negative");
            resource.setHourlyRate(req.getHourlyRate());
        }
        if (req.getStatus() != null) resource.setStatus(req.getStatus());

        if (resource instanceof MeetingRoom room) {
            if (req.getCapacity() != null) {
                if (req.getCapacity() < 1)
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Capacity must be at least 1");
                room.setCapacity(req.getCapacity());
            }
            if (req.getHasProjector() != null) room.setHasProjector(req.getHasProjector());
            if (req.getHasVideoConference() != null) room.setHasVideoConference(req.getHasVideoConference());
        } else if (resource instanceof Desk desk) {
            if (req.getDeskType() != null) desk.setDeskType(req.getDeskType());
        }
        return repository.save(resource);
    }

    public void delete(Long id) {
        BookableResource resource = findById(id);
        if (!resource.getBookings().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Cannot delete a resource that has bookings. Set it to OUT_OF_SERVICE instead.");
        }
        repository.delete(resource);
    }
}