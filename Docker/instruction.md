# PostgreSQL in Docker – Quick Start

## Пререквизиты

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose v2](https://docs.docker.com/compose/)

## 1. Клонируем репозиторий

```bash
git clone https://github.com/<your-org>/<repo>.git
cd <repo>
```

## 2. Настраиваем переменные окружения

```bash
cp .env.example .env
# отредактируйте .env под себя
```

`.env` содержит:

```dotenv
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=app_db
```

## 3. Запускаем базу

```bash
docker compose up -d
```

После запуска PostgreSQL слушает `localhost:5432`.

## 4. Полезные команды

| Задача             | Команда                                                                           |
| ------------------ | --------------------------------------------------------------------------------- |
| Логи Postgres      | `docker compose logs -f db`                                                       |
| Остановить сервисы | `docker compose down`                                                             |
| Бэкап базы         | `docker compose exec db pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql`      |
| Восстановить бэкап | `cat backup.sql \| docker compose exec -T db psql -U $POSTGRES_USER $POSTGRES_DB` |

## 5. Init‑скрипты и схема БД

Все SQL‑скрипты, которые лежат в каталоге `initdb/`, выполняются **один раз** при первом создании кластера.

В репозитории уже есть файл `initdb/01_schema.sql` c полной схемой (таблицы, перечисления и связи), поэтому после первого запуска база поднимается сразу с готовой структурой.

```text
initdb/
└── 01_schema.sql   # ← здесь описана структура User, Team, Tournament и др.
```

Если вы добавите новые таблицы или типы, просто создайте next‑script `02_<название>.sql` — порядок задаётся префиксом номера.

## 6. Удаление данных

```bash
docker compose down -v
```

Флаг `-v` удаляет том `pgdata`. Удаление данных

```bash
docker compose down -v
```

Флаг `-v` удаляет том `pgdata`.



