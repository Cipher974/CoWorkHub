package com.project.coworkhub.models;

public class ResourceUpdateRequest {

    private String name;
    private String location;
    private Integer capacity;
    private Double hourlyRate;
    private ResourceStatus status;
    private Boolean hasProjector;
    private Boolean hasVideoConference;
    private String deskType;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }
    public Double getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(Double hourlyRate) { this.hourlyRate = hourlyRate; }
    public ResourceStatus getStatus() { return status; }
    public void setStatus(ResourceStatus status) { this.status = status; }
    public Boolean getHasProjector() { return hasProjector; }
    public void setHasProjector(Boolean hasProjector) { this.hasProjector = hasProjector; }
    public Boolean getHasVideoConference() { return hasVideoConference; }
    public void setHasVideoConference(Boolean v) { this.hasVideoConference = v; }
    public String getDeskType() { return deskType; }
    public void setDeskType(String deskType) { this.deskType = deskType; }
}