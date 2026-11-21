# CoWorkHub – Coworking Space & Meeting Room Booking

INFS4102 Course Project – Fall 2026

**Team:** Mufeeda, Eva, Abdulrahman Al-Mutawah, Karem Ftayyeh

Stack: Flutter Desktop · Spring Boot · Spring Data JPA · PostgreSQL · REST/JSON · Docker Compose

## Project structure
```
CoWorkHub/
  backend/              Spring Boot project (pom.xml, src/, Dockerfile)
  frontend/             Flutter desktop project (pubspec.yaml, lib/)
  docker-compose.yml    backend + PostgreSQL
  .env.example          example environment variables
  coworkhub.http        REST Client test requests (VS Code)
  README.md
```

## Prerequisites
- Docker Desktop (Compose v2)
- Flutter SDK with desktop support enabled (`flutter doctor`)

## 1. Start the backend and database
```bash
cp .env.example .env          # Windows (cmd): copy .env.example .env
# edit .env and set POSTGRES_PASSWORD
docker compose up --build
```
- API: http://localhost:8080
- Quick check: http://localhost:8080/api/members (returns `[]` on first run)
- Database data is stored in the Docker volume `pgdata`, so it survives restarts.

## 2. Run the Flutter desktop client
```bash
cd frontend
flutter pub get
flutter run -d windows        # or: -d macos / -d linux
```
The client connects to `http://localhost:8080`.

## Stop / reset
| Goal | Command |
|------|---------|
| Stop, keep data | `docker compose down` |
| Start again | `docker compose up` |
| Stop and DELETE all data | `docker compose down -v` |

## Environment variables
| Variable | Used by | Meaning |
|----------|---------|---------|
| POSTGRES_DB | db, backend | database name |
| POSTGRES_USER | db, backend | database user |
| POSTGRES_PASSWORD | db, backend | database password (placeholder in .env.example) |
| SPRING_DATASOURCE_URL | backend | JDBC URL (host is the service name `db`) |
| SPRING_JPA_HIBERNATE_DDL_AUTO | backend | `update` – non-destructive schema strategy |
`SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME` and `SPRING_DATASOURCE_PASSWORD` are set in `docker-compose.yml` from the `.env` values. Outside Docker, the backend falls back to the defaults in `application.properties` (in-memory H2), so data is not kept between runs.

## REST API summary
| Method | Endpoint | Purpose | Status codes |
|--------|----------|---------|--------------|
| GET | /api/resources | List/filter resources (type, minCapacity, location, maxPrice) | 200 |
| GET | /api/resources/{id} | Get a resource | 200, 404 |
| POST | /api/resources/rooms | Create meeting room | 201, 400 |
| POST | /api/resources/desks | Create desk | 201, 400 |
| PUT | /api/resources/{id} | Update resource or its status | 200, 400, 404 |
| DELETE | /api/resources/{id} | Delete (only if no bookings) | 204, 404, 409 |
| GET | /api/resources/available?... | Availability search | 200, 400 |
| GET | /api/members | List members | 200 |
| GET | /api/members/{id} | Get a member | 200, 404 |
| POST | /api/members | Create member (unique email) | 201, 400, 409 |
| GET | /api/members/{id}/bookings | Bookings of a member | 200, 404 |
| GET | /api/bookings | List bookings | 200 |
| GET | /api/bookings/{id} | Get a booking | 200, 404 |
| POST | /api/bookings?memberId=&resourceId= | Create booking | 201, 400, 404, 409 |
| PUT | /api/bookings/{id} | Update / cancel booking | 200, 400, 404, 409 |

## Design notes
- JPA inheritance strategy: JOINED. `BookableResource` (abstract) holds the common columns; `MeetingRoom` and `Desk` have their own tables for room-specific and desk-specific fields. This avoids repeated columns and many null columns.
- Resources are created through separate endpoints for rooms and desks.
- Booking total = hourlyRate × duration in hours, calculated by the backend.
- Cancelled bookings are kept (status CANCELLED) and do not block the time slot.
- A resource with any bookings cannot be deleted (409). Set it to OUT_OF_SERVICE instead to keep its history.
- `POST /api/bookings` takes `memberId` and `resourceId` as query parameters; the JSON body contains `startDateTime`, `endDateTime` and `attendees`.
- Errors are returned as JSON: `{"message": "..."}`.

## Team members and contributions
| Member | Contribution |
|--------|--------------|
| Mufeeda | Resource entities and JPA inheritance; resource repository, service and controller; filtering and CRUD; Resources screen |
| Eva | Member management (backend and Members screen); Dashboard and navigation; Dockerfile and Docker Compose; README |
| Abdulrahman | Booking entity, repository, service and controller; booking rules (overlap, capacity, resource status); cost calculation, cancellation and exception handling |
| Karem | Availability search and API service; frontend-backend integration; New Booking and Bookings screens; form validation, loading states and error handling |