# PostgreSQL in Docker – Quick Start

## Пререквизиты

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose v2](https://docs.docker.com/compose/)

---

## 1. Клонируем репозиторий

```bash
git clone https://github.com/<your‑org>/<repo>.git
cd <repo>
```

---

## 2. Настраиваем переменные окружения

```bash
cp .env.example .env           # создаём локальную копию
# откройте .env и задайте свои значения
```

`.env` **минимально** содержит:

```dotenv
POSTGRES_USER=user          # админ Postgres (используется только init‑скриптами)
POSTGRES_PASSWORD=password
POSTGRES_DB=app_db

ENGINE_DB_USER=engine_rw    # сервис Engine → RW + DDL
ENGINE_DB_PASS=secret

READER_DB_USER=teams_ro     # UI / Swift / др. читатели → только SELECT
READER_DB_PASS=readpwd

DB_HOST=teams-db            # имя контейнера внутри сети docker-compose
DB_PORT=5432
```

> ⚠️  **Не выкладывайте .env в публичный Git!**

---

## 3. Запускаем стек

```bash
# первый запуск / пересборка
docker compose up -d --build
```

- **teams-db** поднимает PostgreSQL и выполняет все `db/init/*.sql` *один раз*.
- **db-migrator** (Flyway CLI) применяет миграции из `db/migration/` и завершается.
- Сервисы (`engine`, `ui-service`, …) стартуют после БД.

После старта база слушает `localhost:5432` (если не меняли порт).

---

## 4. Полезные команды

| Задача                 | Команда                                                                                 |
| ---------------------- | --------------------------------------------------------------------------------------- |
| Логи Postgres          | `docker compose logs -f teams-db`                                                       |
| Логи Flyway            | `docker compose logs db-migrator`                                                       |
| Остановить сервисы     | `docker compose down`                                                                   |
| Бэкап всей БД          | `docker compose exec teams-db pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql`      |
| Восстановить бэкап     | `cat backup.sql \| docker compose exec -T teams-db psql -U $POSTGRES_USER $POSTGRES_DB` |
| Полное удаление данных | `docker compose down -v`                                                                |

---

## 5. Init‑скрипты

Каталог `` выполняется при ПЕРВОМ создании тома `pgdata`.

```
db/init/
├── 00_schema.sql   # исходная структура (таблицы, перечисления)
└── 01_roles.sql    # роли engine_rw / teams_ro и права
```

Если нужно доработать исходную схему до первого запуска — меняйте `00_schema.sql`.

---

## 6. Flyway‑миграции (эволюция схемы)

1. Создайте файл в `db/migration/` по шаблону `V<N>__description.sql`, где `N` — следующая версия.
2. Пишите обычный DDL‑SQL (`ALTER TABLE …` / `CREATE INDEX …`).
3. Закоммитьте и задеплойте: `docker compose up -d --build`.
4. Контейнер **db-migrator** возьмёт advisory‑lock в БД, применит все новые V‑файлы и запишет их в `flyway_schema_history`.

> Пример:
>
> ```sql
> -- db/migration/V2__add_founded_year_to_team.sql
> ALTER TABLE Team ADD COLUMN founded_year INT;
> ```

### Ручной запуск Flyway (опционально)

```bash
# «сухой» прогон (покажет, что будет выполнено)
docker compose run --rm db-migrator info

# принудительно применить всё новое
docker compose run --rm db-migrator migrate
```

---

## 7. Подключение сервисов

### 7.1 Java / Spring Boot (Engine)

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${POSTGRES_DB}
    username: ${ENGINE_DB_USER}
    password: ${ENGINE_DB_PASS}
  jpa:
    hibernate:
      ddl-auto: validate    # проверяем схему, но не меняем её
spring.flyway.enabled: false # мигрирует db-migrator, а не сам сервис
```

### 7.2 Swift / Vapor (UI‑reader)

```swift
let db = PostgresConfiguration(
  hostname: Environment.get("DB_HOST") ?? "teams-db",
  port: Int(Environment.get("DB_PORT") ?? "5432")!,
  username: Environment.get("READER_DB_USER") ?? "teams_ro",
  password: Environment.get("READER_DB_PASS") ?? "readpwd",
  database: Environment.get("POSTGRES_DB") ?? "teams"
)
```

### 7.3 Любой другой язык

```
postgres://${USER}:${PASSWORD}@${DB_HOST}:${DB_PORT}/${POSTGRES_DB}
```

Используйте `ENGINE_DB_*` для сервисов, которые записывают и мигрируют, либо `READER_DB_*` – только для чтения.

---

## 8. FAQ

| Вопрос                                                | Ответ                                                                                               |
| ----------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Что будет, если два релиза одновременно?              | Flyway использует advisory‑lock, миграции выполнятся ровно один раз, остальные контейнеры дождутся. |
| Можно ли добавить третьего пользователя с правами RW? | Да: добавьте команду `CREATE ROLE …` в отдельный миграционный скрипт либо вручную на проде.         |
| Как проверить, какие миграции применены?              | `docker compose run --rm db-migrator info` покажет полную таблицу версий.                           |

---

## 9. Удаление данных

```bash
docker compose down -v  # удалит том pgdata и ВСЕ данные
```

---

Happy coding! 🎉

