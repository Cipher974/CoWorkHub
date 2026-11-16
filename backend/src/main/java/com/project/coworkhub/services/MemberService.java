package com.project.coworkhub.services;

import com.project.coworkhub.exceptions.ConflictException;
import com.project.coworkhub.exceptions.NotFoundException;
import com.project.coworkhub.models.Member;
import com.project.coworkhub.repository.MemberRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class MemberService {

    private final MemberRepository repo;

    public MemberService(MemberRepository repo) {
        this.repo = repo;
    }

    public List<Member> findAll() {
        return repo.findAll();
    }

    public Member findById(Long id) {
        return repo.findById(id)
                .orElseThrow(() -> new NotFoundException("Member " + id + " not found"));
    }

    @Transactional
    public Member create(Member member) {
        // Normalise so "A@x.com" and "a@x.com" are the same email
        member.setId(null);
        member.setFullName(member.getFullName().trim());
        member.setEmail(member.getEmail().trim().toLowerCase());

        if (repo.existsByEmailIgnoreCase(member.getEmail())) {
            throw new ConflictException("A member with email " + member.getEmail() + " already exists");
        }
        return repo.save(member);
    }
}