FROM flyway/flyway:10-alpine

# миграции лежат в infra/db/migration ─ относительный к контексту .
COPY db/migration /flyway/sql

ENTRYPOINT ["flyway","migrate"]
