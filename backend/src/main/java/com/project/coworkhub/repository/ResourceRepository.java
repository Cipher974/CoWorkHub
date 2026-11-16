package com.project.coworkhub.repository;

import com.project.coworkhub.models.BookableResource;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ResourceRepository extends JpaRepository<BookableResource, Long> {
}