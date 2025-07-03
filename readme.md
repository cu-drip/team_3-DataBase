# 🏋️‍♀️ Sport Platform — Mono‑Repo

Единый репозиторий со всеми микросервисами проекта: база данных, миграции, сервисы на Java, Swift и др. Всё собирается и запускается одной командой `docker compose` — никакие локальные SDK устанавливать не нужно.

---

## Содержание

1. [Структура каталога](#структура-каталога)
2. [Предварительные требования](#предварительные-требования)
3. [Первый запуск (TL;DR)](#первый-запуск-tldr)
4. [Ежедневный workflow](#ежедневный-workflow)
5. [База данных и миграции](#база-данных-и-миграции)
6. [Как добавить свой микросервис](#как-добавить-свой-микросервис)
7. [Запуск только нужных сервисов](#запуск-только-нужных-сервисов)
8. [Сброс / полная очистка](#сброс--полная-очистка)
9. [Типовые ошибки](#типовые-ошибки)
10. [FAQ](#faq)

---

## Структура каталога

```
repo-root/
├─ infra/                     # инфраструктура и CI
│  ├─ docker-compose.yml      # общий стек
│  └─ db/
│     ├─ init/01_roles.sql    # роли + привилегии (user/password)
│     └─ migration/           # V1__, V2__, … (Flyway)
│
├─ svc-user/   #!!!ПРИМЕР Замените на свой - микросервис на Java / Spring Boot
│  ├─ Dockerfile
│  ├─ pom.xml
│  └─ src/…
│
├─ svc-notify/                # микросервис на Swift (пример)
│  ├─ Dockerfile
│  └─ Sources/…
└─ …                          # добавляйте свои сервисы в корень
```

### Конвенции

- **Порт внутри контейнера:** `8080`\
  На хост маппим свободный (`8081`, `8082` …) через `ports: "HOST:8080"`.
- **Creds БД по умолчанию:** `user / password` — см. скрипт `01_roles.sql`.
- **JAR‑файл Java‑сервисов:** всегда `target/app.jar` (решается `<finalName>app</finalName>` + goal `repackage`).

---

## Предварительные требования

| Что                        | Версия     | Комментарий                       |
| -------------------------- | ---------- | --------------------------------- |
| **Docker Desktop**         | ≥ 4.25     | содержит `docker compose`         |
| **Git**                    | любая      |                                   |
| **JDK / Swift / Node / …** | *не нужны* | всё собирается внутри контейнеров |

---

## Первый запуск (TL;DR)

```bash
# клонируем репо
$ git clone <repo-url> && cd repo-root

# 1 — база данных + миграции
$ docker compose -f infra/docker-compose.yml up -d postgres flyway

# 2 — нужный сервис (пример: Java‑svc)
$ docker compose -f infra/docker-compose.yml up -d svc-user

# 3 — проверяем
$ curl http://localhost:8081/api/db-check
# {"status":"UP", …}
```

> **Важно:** если меняете SQL‑миграции или роли, удаляйте том `pgdata`:\
> `docker compose -f infra/docker-compose.yml down -v`

---

## Ежедневный workflow

| Задача                        | Команда                                                                                                                |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Собрать образ своего сервиса  | `docker compose -f infra/docker-compose.yml build svc-user`                                                            |
| Пересоздать БД (чистая схема) | `docker compose -f infra/docker-compose.yml down -v``docker compose -f infra/docker-compose.yml up -d postgres flyway` |
| Запустить весь стек           | `docker compose -f infra/docker-compose.yml up -d`                                                                     |
| Логи сервиса                  | `docker compose -f infra/docker-compose.yml logs -f svc-user`                                                          |
| Стоп всего                    | `docker compose -f infra/docker-compose.yml down`                                                                      |

---

## База данных и миграции

- Контейнер: ``
- Роль/пароль создаются при первом старте скриптом `init/01_roles.sql`.
- Миграции лежат в `infra/db/migration/` и именуются:
  ```
  V1__init_schema.sql
  V2__add_payments_table.sql
  ```
- Применяет их job‑контейнер Flyway:
  ```yaml
  flyway:
    image: flyway/flyway:10-alpine
    volumes: [ "./db/migration:/flyway/sql:ro" ]
    environment:
      FLYWAY_URL:  jdbc:postgresql://postgres:5432/sport
      FLYWAY_USER: user
      FLYWAY_PASSWORD: password
    command: migrate
  ```

---

## Как добавить свой микросервис

1. **Создать каталог** в корне, например `svc-payments/`.
2. **Dockerfile**: собирает конечный артефакт (jar, бинарь) *внутри* контейнера.
3. **Слушать порт **`` (иначе придётся менять healthcheck).
4. **Добавить секцию** в `infra/docker-compose.yml`:
   ```yaml
   payments:
     build: ../svc-payments         # путь от infra/
     depends_on:
       flyway:
         condition: service_completed_successfully
     environment:
       DB_URL:  jdbc:postgresql://postgres:5432/sport
       DB_USER: user
       DB_PASS: password
     ports: [ "8083:8080" ]
   ```
5. **При необходимости — миграции:** добавьте `V__*.sql` в `infra/db/migration/`.
6. `docker compose -f infra/docker-compose.yml build payments && \ docker compose -f infra/docker-compose.yml up -d payments`

---

## Запуск только нужных сервисов

```bash
# БД + миграции + два конкретных сервиса
$ docker compose -f infra/docker-compose.yml up -d postgres flyway svc-user svc-notify
```

Если нужно постоянно гонять один и тот же набор — создайте `docker-compose.override.yml` или используйте профили.

---

## Сброс / полная очистка

```bash
# останавливаем и удаляем ВСЁ (+ volume с данными БД)
$ docker compose -f infra/docker-compose.yml down -v

# поднимаем с чистого листа
$ docker compose -f infra/docker-compose.yml up -d postgres flyway svc-user
```

---

## Типовые ошибки

| Симптом                                          | Причина                         | Решение                                                                                                                      |
| ------------------------------------------------ | ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `no main manifest attribute`                     | JAR собран без goal `repackage` | Убедитесь, что в `pom.xml` у плагина Spring Boot прописан `<mainClass>` и goal `repackage`; пересоберите образ `--no-cache`. |
| `password authentication failed for user "user"` | Неверный пароль                 | Проверьте `DB_USER/PASS` в compose и скрипте `01_roles.sql`; затем `down -v`.                                                |
| `relation "table" does not exist`                | сервис стартует раньше миграций | В секции сервиса → `depends_on: flyway: condition: service_completed_successfully`.                                          |
| Порт занят                                       | На хосте тот же порт            | Поменяйте левую часть в `"8085:8080"`.                                                                                       |

---

## FAQ

**Q:** *Нужно ли ставить JDK, Swift, Node…?*\
**A:** Нет. Всё компилируется внутри контейнеров.

**Q:** *Можно ли использовать разные креды вместо user/password?*\
**A:** Да. Измените скрипт `01_roles.sql` и переменные окружения, затем `down -v`.

**Q:** *Как сделать автоматический hot‑reload?*\
**A:** Используйте делегированные тома (Docker Desktop → Settings → Resources → File Sharing) и spring‑dev‑tools / nodemon внутри Dockerfile.

---

