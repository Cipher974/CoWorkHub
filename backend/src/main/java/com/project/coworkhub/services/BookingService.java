package com.project.coworkhub.services;

import java.time.Duration;
import java.util.List;

import org.springframework.stereotype.Service;

import com.project.coworkhub.exceptions.ConflictException;
import com.project.coworkhub.exceptions.NotFoundException;
import com.project.coworkhub.models.BookableResource;
import com.project.coworkhub.models.Booking;
import com.project.coworkhub.models.BookingStatus;
import com.project.coworkhub.models.Desk;
import com.project.coworkhub.models.Member;
import com.project.coworkhub.models.ResourceStatus;
import com.project.coworkhub.repository.BookingRepository;
import com.project.coworkhub.repository.MemberRepository;
import com.project.coworkhub.repository.ResourceRepository;

import jakarta.transaction.Transactional;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;
    private final MemberRepository memberRepository;
    private final ResourceRepository resourceRepository;

    public BookingService(
            BookingRepository bookingRepository,
            MemberRepository memberRepository,
            ResourceRepository resourceRepository) {

        this.bookingRepository = bookingRepository;
        this.memberRepository = memberRepository;
        this.resourceRepository = resourceRepository;
    }

    public List<Booking> findAll() {
        return bookingRepository.findAll();
    }

    public Booking findById(Long id) {
        return bookingRepository.findById(id)
                .orElseThrow(() ->
                        new NotFoundException("Booking " + id + " not found"));
    }

    public List<Booking> findByMemberId(Long memberId) {
        return bookingRepository.findByMemberId(memberId);
    }

    @Transactional
    public Booking add(Long memberId, Long resourceId, Booking booking) {

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() ->
                        new NotFoundException("Member " + memberId + " not found"));

        BookableResource resource = resourceRepository.findById(resourceId)
                .orElseThrow(() ->
                        new NotFoundException("Resource " + resourceId + " not found"));

        validateBooking(booking, resource, null);

        booking.setId(null);
        booking.setMember(member);
        booking.setResource(resource);
        booking.setStatus(BookingStatus.CONFIRMED);

        booking.setTotalCost(calculateCost(booking, resource));

        return bookingRepository.save(booking);
    }

    @Transactional
    public Booking update(Long id, Booking updatedBooking) {

        Booking existing = findById(id);

        if (updatedBooking.getStartDateTime() != null) {
            existing.setStartDateTime(updatedBooking.getStartDateTime());
        }

        if (updatedBooking.getEndDateTime() != null) {
            existing.setEndDateTime(updatedBooking.getEndDateTime());
        }

        if (updatedBooking.getAttendees() > 0) {
            existing.setAttendees(updatedBooking.getAttendees());
        }

        if (updatedBooking.getStatus() != null) {
            existing.setStatus(updatedBooking.getStatus());
        }

        if (existing.getStatus() == BookingStatus.CONFIRMED) {
            validateBooking(
                    existing,
                    existing.getResource(),
                    existing.getId()
            );

            existing.setTotalCost(
                    calculateCost(existing, existing.getResource())
            );
        }

        return bookingRepository.save(existing);
    }

    @Transactional
    public void delete(Long id) {
        findById(id);
        bookingRepository.deleteById(id);
    }

    private void validateBooking(
            Booking booking,
            BookableResource resource,
            Long excludeBookingId) {

        if (booking.getStartDateTime() == null ||
                booking.getEndDateTime() == null) {
            throw new ConflictException(
                    "Booking start and end times are required");
        }

        if (!booking.getEndDateTime().isAfter(booking.getStartDateTime())) {
            throw new ConflictException(
                    "End time must be after start time");
        }

        if (booking.getAttendees() < 1) {
            throw new ConflictException(
                    "At least one attendee is required");
        }

        if (resource.getStatus() != ResourceStatus.ACTIVE) {
            throw new ConflictException(
                    "This resource is not currently available");
        }

        if (booking.getAttendees() > resource.getCapacity()) {
            throw new ConflictException(
                    "Number of attendees exceeds resource capacity");
        }

        if (resource instanceof Desk && booking.getAttendees() > 1) {
            throw new ConflictException(
                    "A desk can only be booked for one attendee");
        }

        List<Booking> conflicts =
                bookingRepository.findConflictingBookings(
                        resource.getId(),
                        BookingStatus.CONFIRMED,
                        booking.getEndDateTime(),
                        booking.getStartDateTime(),
                        excludeBookingId
                );

        if (!conflicts.isEmpty()) {
            throw new ConflictException(
                    "This resource is already booked during the selected time");
        }
    }

    private double calculateCost(
            Booking booking,
            BookableResource resource) {

        long minutes = Duration.between(
                booking.getStartDateTime(),
                booking.getEndDateTime()
        ).toMinutes();

        double cost = resource.getHourlyRate() * minutes / 60.0;

        return Math.round(cost * 100.0) / 100.0;
    }
}
