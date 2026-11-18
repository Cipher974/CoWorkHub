package com.project.coworkhub.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.project.coworkhub.exceptions.NotFoundException;
import com.project.coworkhub.models.Booking;
import com.project.coworkhub.repository.BookingRepository;

import jakarta.transaction.Transactional;

@Service
public class BookingService {
    private final BookingRepository bookingRepository;
    
    public BookingService(BookingRepository bookingRepository) {
        this.bookingRepository = bookingRepository;
    }

    public List<Booking> findAll() {
        return bookingRepository.findAll();
    }

    public Booking findById(Long id) {
        if (!bookingRepository.existsById(id)) {
            throw new NotFoundException("ID not found.");
        }

        return bookingRepository.findById(id).orElseThrow();
    }

    public List<Booking> findByMemberId(Long memberId) {
        if (memberId > 0 && memberId != null) {
            return bookingRepository.findByMemberId(memberId);
        } else {
            throw new NotFoundException("ID Not found, please check or try again.");
        }
    }

    @Transactional
    public Booking add(Booking booking) {
        if (booking != null) {
            return bookingRepository.save(booking);
        } else {
            throw new NotFoundException("Booking cannot be empty, or data is invalid.");
        }
    }

    @Transactional
    public Booking update(Long id, Booking updatedBooking) {
        if (id > 0 && id != null && updatedBooking != null) {
            updatedBooking.setId(id);
            return bookingRepository.save(updatedBooking);
        } else {
            throw new NotFoundException("ID or Booking data invalid, or ID not found.");
        }
    }

    @Transactional
    public void delete(Long id) {
        if (!bookingRepository.existsById(id)) {
            throw new NotFoundException("ID not found.");
        }
        
        bookingRepository.deleteById(id);
    }
}
