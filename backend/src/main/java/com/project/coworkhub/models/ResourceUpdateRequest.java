package com.project.coworkhub.models;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ResourceUpdateRequest {
    private String name;
    private String location;
    private Integer capacity;
    private Double hourlyRate;
    private ResourceStatus status;
    private Boolean hasProjector;
    private Boolean hasVideoConference;
    private String deskType;
}