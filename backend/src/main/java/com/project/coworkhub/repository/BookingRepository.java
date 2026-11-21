package com.project.coworkhub.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.project.coworkhub.models.Booking;
import com.project.coworkhub.models.BookingStatus;

public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByMemberId(Long memberId);

    List<Booking> findByResourceId(Long resourceId);

    List<Booking> findByStatus(BookingStatus status);

    @Query("""
        SELECT DISTINCT b.resource.id
        FROM Booking b
        WHERE b.status = :status
        AND b.startDateTime < :endDateTime
        AND b.endDateTime > :startDateTime
    """)
    List<Long> findConflictingResourceIds(
            @Param("status") BookingStatus status,
            @Param("endDateTime") LocalDateTime endDateTime,
            @Param("startDateTime") LocalDateTime startDateTime
    );

    @Query("""
        SELECT b
        FROM Booking b
        WHERE b.resource.id = :resourceId
        AND b.status = :status
        AND b.startDateTime < :endDateTime
        AND b.endDateTime > :startDateTime
        AND (:excludeBookingId IS NULL OR b.id <> :excludeBookingId)
    """)
    List<Booking> findConflictingBookings(
            @Param("resourceId") Long resourceId,
            @Param("status") BookingStatus status,
            @Param("endDateTime") LocalDateTime endDateTime,
            @Param("startDateTime") LocalDateTime startDateTime,
            @Param("excludeBookingId") Long excludeBookingId
    );
}
