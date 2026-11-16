package com.project.coworkhub.repository;

import com.project.coworkhub.models.Member;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemberRepository extends JpaRepository<Member, Long> {

    // Derived query used by the unique-email rule
    boolean existsByEmailIgnoreCase(String email);
}