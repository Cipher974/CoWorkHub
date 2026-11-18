package com.project.coworkhub.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;

import com.project.coworkhub.models.Booking;
import com.project.coworkhub.models.BookingStatus;


public interface BookingRepository extends JpaRepository<Booking, Long>{
    List<Booking> findByMemberId(Long memberId);
    List<Booking> findByResourceId(Long resourceId);
    List<Booking> findByStatus(BookingStatus status);

    // Find the IDs of resources already booked during the requested interval.
    @Query("select distinct b.resource.id from Booking b where b.status = :status " +
           "and b.startDateTime < :endDateTime and b.endDateTime > :startDateTime")
    List<Long> findConflictingResourceIds(@Param("status") BookingStatus status,
                                          @Param("endDateTime") LocalDateTime endDateTime,
                                          @Param("startDateTime") LocalDateTime startDateTime);
}
