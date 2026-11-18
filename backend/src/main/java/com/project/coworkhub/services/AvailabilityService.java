package com.project.coworkhub.services;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.project.coworkhub.models.BookableResource;
import com.project.coworkhub.models.BookingStatus;
import com.project.coworkhub.models.ResourceStatus;
import com.project.coworkhub.repository.BookingRepository;
import com.project.coworkhub.repository.ResourceRepository;

@Service
public class AvailabilityService {
    private final ResourceRepository resourceRepository;
    private final BookingRepository bookingRepository;

    public AvailabilityService(ResourceRepository resourceRepository,
                               BookingRepository bookingRepository) {
        this.resourceRepository = resourceRepository;
        this.bookingRepository = bookingRepository;
    }

    public List<BookableResource> findAvailable(LocalDateTime startDateTime,
                                               LocalDateTime endDateTime,
                                               Integer attendees, String type) {
        if (startDateTime == null || endDateTime == null ||
                !startDateTime.isBefore(endDateTime)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Start date/time must be before end date/time.");
        }
        if (attendees != null && attendees < 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Attendees must be at least 1.");
        }
        if (type != null && !type.isBlank() &&
                !type.equalsIgnoreCase("ROOM") && !type.equalsIgnoreCase("DESK")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Type must be ROOM or DESK.");
        }

        // Only confirmed bookings block the requested time interval.
        // existingStart < newEnd AND existingEnd > newStart
        Set<Long> unavailableIds = bookingRepository
                .findConflictingResourceIds(BookingStatus.CONFIRMED, endDateTime, startDateTime)
                .stream().collect(Collectors.toSet());

        return resourceRepository.findAll().stream()
                .filter(resource -> resource.getStatus() == ResourceStatus.ACTIVE)
                .filter(resource -> !unavailableIds.contains(resource.getId()))
                .filter(resource -> attendees == null || resource.getCapacity() >= attendees)
                .filter(resource -> type == null || type.isBlank() ||
                        resource.getType().equalsIgnoreCase(type))
                .collect(Collectors.toList());
    }
}
