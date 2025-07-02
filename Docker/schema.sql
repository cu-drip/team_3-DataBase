-- schema.sql 


-- Общие перечисления
CREATE TYPE sex_enum AS ENUM ('male', 'female', 'other');
CREATE TYPE sport_enum AS ENUM (
  'football', 'boxing', 'basketball', 'chess', 'tennis', 'jiu jitsu'
);
CREATE TYPE participant_type_enum AS ENUM ('solo', 'team');
CREATE TYPE status_enum AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE type_tournament_enum AS ENUM ('solo', 'team');
CREATE TYPE type_group_enum AS ENUM ('olympic', 'swiss', 'round_robin');


-- Таблица пользователей
CREATE TABLE "User" (
  id              UUID PRIMARY KEY,
  name            VARCHAR NOT NULL,
  surname         VARCHAR NOT NULL,
  patronymic      VARCHAR,
  phone_number    VARCHAR NOT NULL UNIQUE,
  email           VARCHAR UNIQUE,
  hashed_password VARCHAR NOT NULL,
  is_admin        BOOLEAN DEFAULT FALSE,
  date_of_birth   DATE,
  age             INTEGER,
  sex             sex_enum,
  weight          REAL,
  height          REAL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  bio             TEXT,
  avatar_url      TEXT
);

-- Рейтинг пользователя по видам спорта
CREATE TABLE User_sport_mmr_relation (
  user_id UUID      REFERENCES "User"(id) ON DELETE CASCADE,
  sport   sport_enum NOT NULL,
  mmr     DOUBLE PRECISION NOT NULL,
  PRIMARY KEY (user_id, sport)
);

-- Команды
CREATE TABLE Team (
  id         UUID PRIMARY KEY,
  name       VARCHAR NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  avatar     TEXT
);

-- Игроки в команде
CREATE TABLE Team_player_relation (
  team_id UUID REFERENCES Team(id) ON DELETE CASCADE,
  user_id UUID REFERENCES \"User\"(id) ON DELETE CASCADE,
  PRIMARY KEY (team_id, user_id)
);

-- MMR команды
CREATE TABLE Team_mmr_relation (
  team_id UUID PRIMARY KEY REFERENCES Team(id) ON DELETE CASCADE,
  mmr     DOUBLE PRECISION NOT NULL
);

-- Турниры
CREATE TABLE Tournament (
  id                  UUID PRIMARY KEY,
  title               VARCHAR NOT NULL,
  description         TEXT,
  sport               sport_enum NOT NULL,
  type_tournament     type_tournament_enum NOT NULL,
  type_group          type_group_enum NOT NULL,
  matches_number      INTEGER NOT NULL,
  start_time          TIMESTAMP NOT NULL,
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  entry_cost          DECIMAL(10,2) DEFAULT 0,
  max_participants    INTEGER,
  registration_deadline TIMESTAMP DEFAULT (start_time - INTERVAL '24 hours'),
  place               VARCHAR,
  organizer_id        UUID REFERENCES \"User\"(id) ON DELETE SET NULL
);

-- Регистрация на турнир
CREATE TABLE TournamentRegistration (
  tournament_id   UUID REFERENCES Tournament(id) ON DELETE CASCADE,
  sport           sport_enum NOT NULL,
  participant_id  UUID NOT NULL,
  participant_type participant_type_enum NOT NULL,
  registered_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status          status_enum DEFAULT 'pending',
  PRIMARY KEY (tournament_id, participant_id)
);

-- Матчи
CREATE TABLE Matches (
  match_id           UUID PRIMARY KEY,
  started_at         TIMESTAMP,
  created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  position           INTEGER,
  partition1_id      UUID NOT NULL,
  partition2_id      UUID NOT NULL,
  partition1_points  INTEGER,
  partition2_points  INTEGER,
  winner_id          UUID
);
