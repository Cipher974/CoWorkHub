package com.project.coworkhub.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.project.coworkhub.models.Booking;
import com.project.coworkhub.models.BookingStatus;


public interface BookingRepository extends JpaRepository<Booking, Long>{
    List<Booking> findByMemberId(Long memberId);
    List<Booking> findByResourceId(Long resourceId);
    List<Booking> findByStatus(BookingStatus status);
}
