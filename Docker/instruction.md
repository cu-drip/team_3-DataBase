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

`.env.example` содержит:

```dotenv
POSTGRES_USER=app_user
POSTGRES_PASSWORD=strong_password
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

## 5. Init-скрипты (опционально)

Складывайте `.sql` или `.sh` файлы в папку `initdb/`.\
Они выполняются **один раз** при первом создании кластера.

## 6. Удаление данных

```bash
docker compose down -v
```

Флаг `-v` удаляет том `pgdata`.

## Лицензия

MIT.

