package com.project.coworkhub.models;

import jakarta.persistence.Entity;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class MeetingRoom extends BookableResource {
    private boolean hasProjector;
    private boolean hasVideoConference;

    @Override
    public String getType() { return "ROOM"; }
}