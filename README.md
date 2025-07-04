# Схема базы данных 

---

### User
```text
id: UUID
name: string
surname: string
patronymic: string                     -- опционально
phone_number: string
email: string                          -- опционально
hashed_password: string
is_admin: boolean
date_of_birth: date                    -- опционально
age: int                               -- опционально
sex: enum('male', 'female', 'other')   -- опционально
weight: float                          -- опционально
height: float                          -- опционально
created_at: timestamp
bio: string?                           -- краткое описание игрока
avatar_url: string?                    -- опциональный аватар
```

---

### User_sport_mmr_relation
```text
user_id: UUID                           
sport: enum('football', 'boxing', 'basketball', 'chess', 'tennis', 'jiu jitsu')
mmr: double
PRIMARY KEY(user_id, sport)
(FK → User.id)
```


---


### Team
```text
id: UUID
name: string
created_at: timestamp
avatar: string
```


---


### Team_player_relation
```text
team_id: UUID
user_id: UUID
foreign key(UUID, UUID)
```


---
### Team_mmr_relation
```text
team_id: UUID
mmr: double
foreign key(UUID)
```


---

### Tournament
```text
id: UUID
title: string
description: string
sport: enum('football', 'boxing', 'basketball', 'chess', 'tennis', 'jiu jitsu')
type_tournament: enum('solo', 'team')
type_group: enum('olympic', 'swiss', 'round_robin')
matches_number: int
start_time: timestamp
created_at: timestamp
entry_cost: decimal
max_participants: int
registration_deadline: timestamp        -- по умолчанию start_time - 24hours
place: string
organizer_id: UUID    
(FK → User.id)
```

---

### TournamentRegistration
```text
tournament_id: UUID                     
sport: enum('football', 'boxing', 'basketball', 'chess', 'tennis', 'jiu jitsu')
participant_id: UUID                    -- может быть user_id или team_id
participant_type: enum('solo', 'team')
registered_at: timestamp
status: enum('pending', 'accepted', 'rejected')
PRIMARY KEY(tournament_id, participant_id)
(FK → Tournament.id)
```

---

### Matches
```text
match_id: UUID PRIMARY KEY
tournament_id:: UUID
match_id: UUID
started_at: timestamp
created_at: timestamp
position: int
partition1_id: UUID
partition2_id: UUID
partition1_points: int
partition2_points: int
winner_id: UUID
(FK → Tournament.id)
```

