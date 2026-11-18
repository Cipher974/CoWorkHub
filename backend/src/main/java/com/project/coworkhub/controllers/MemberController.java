package com.project.coworkhub.controllers;

import com.project.coworkhub.models.Booking;
import com.project.coworkhub.models.Member;
import com.project.coworkhub.repository.BookingRepository;
import com.project.coworkhub.services.MemberService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/members")
public class MemberController {

    private final MemberService service;
    private final BookingRepository bookingRepository;

    public MemberController(MemberService service, BookingRepository bookingRepository) {
        this.service = service;
        this.bookingRepository = bookingRepository;
    }

    @GetMapping
    public List<Member> all() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public Member one(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Member create(@Valid @RequestBody Member member) {
        return service.create(member);
    }

    // Bookings of one member (includes CANCELLED ones = history)
    @GetMapping("/{id}/bookings")
    public List<Booking> bookings(@PathVariable Long id) {
        service.findById(id); // 404 if the member does not exist
        return bookingRepository.findByMemberId(id);
    }
}