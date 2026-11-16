package com.project.coworkhub.models;

import jakarta.persistence.Entity;

@Entity
public class MeetingRoom extends BookableResource {

    private boolean hasProjector;
    private boolean hasVideoConference;

    public MeetingRoom() {
    }

    public MeetingRoom(String name, String location, int capacity, double hourlyRate,
                       ResourceStatus status, boolean hasProjector, boolean hasVideoConference) {
        super(name, location, capacity, hourlyRate, status);
        this.hasProjector = hasProjector;
        this.hasVideoConference = hasVideoConference;
    }

    @Override
    public String getType() { return "ROOM"; }

    public boolean isHasProjector() { return hasProjector; }
    public void setHasProjector(boolean hasProjector) { this.hasProjector = hasProjector; }
    public boolean isHasVideoConference() { return hasVideoConference; }
    public void setHasVideoConference(boolean v) { this.hasVideoConference = v; }
}