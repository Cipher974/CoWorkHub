package com.project.coworkhub.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.project.coworkhub.exceptions.NotFoundException;
import com.project.coworkhub.models.BookableResource;
import com.project.coworkhub.models.Booking;
import com.project.coworkhub.models.Member;
import com.project.coworkhub.repository.BookingRepository;
import com.project.coworkhub.repository.MemberRepository;
import com.project.coworkhub.repository.ResourceRepository;

import jakarta.transaction.Transactional;

@Service
public class BookingService {
    private final BookingRepository bookingRepository;
    private final MemberRepository memberRepository;
    private final ResourceRepository resourceRepository;

    public BookingService(BookingRepository bookingRepository,
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
                .orElseThrow(() -> new NotFoundException("Booking " + id + " not found"));
    }

    public List<Booking> findByMemberId(Long memberId) {
        return bookingRepository.findByMemberId(memberId);
    }

    @Transactional
    public Booking add(Long memberId, Long resourceId, Booking booking) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new NotFoundException("Member " + memberId + " not found"));
        BookableResource resource = resourceRepository.findById(resourceId)
                .orElseThrow(() -> new NotFoundException("Resource " + resourceId + " not found"));

        booking.setId(null);
        booking.setMember(member);
        booking.setResource(resource);
        
        return bookingRepository.save(booking);
    }

    @Transactional
    public Booking update(Long id, Booking updatedBooking) {
        Booking existing = findById(id);

        existing.setStartDateTime(updatedBooking.getStartDateTime());
        existing.setEndDateTime(updatedBooking.getEndDateTime());
        existing.setAttendees(updatedBooking.getAttendees());
        existing.setTotalCost(updatedBooking.getTotalCost());
        existing.setStatus(updatedBooking.getStatus());
        
        return bookingRepository.save(existing);
    }

    @Transactional
    public void delete(Long id) {
        findById(id);
        bookingRepository.deleteById(id);
    }
}