# CoWorkHub
Project for INFS4102. CoWorkHub is a desktop application for managing a coworking space.

## Dependencies
* Java 25
* Spring Boot Tools 2.4.1
* Maven 3.10.0

### Spring boot dependencies (for pom.xml)
> [!NOTE]
> There is no need to install anything in this section, it's for documenting the dependencies in maven.
1. Lombok
2. Spring Boot DevTools
3. Spring Data JPA
4. Spring Boot Starter Web
5. H2 Database

## Building
1. `git clone https://github.com/Cipher974/CoWorkHub.git`
2. `cd backend/`
3. `mvn clean package`

## Running
### Visual Studio Code
Using VSCode or VSCodium, the extensions in [dependencies](#dependencies), run the CoworkhubApplication.java in backend/src/main/ using spring-boot.

### Manual
1. `cd backend/`
2. `mvn spring-boot:run`
