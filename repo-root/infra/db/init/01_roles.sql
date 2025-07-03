-- Контейнер уже создаёт супер-роль `user` (env POSTGRES_USER).
-- Просто назначим ей все привилегии на схему, чтобы Flyway и Spring жили спокойно.

GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO "user";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "user";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
      GRANT ALL PRIVILEGES ON TABLES TO "user";
