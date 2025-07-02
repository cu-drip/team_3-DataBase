# 1) Берём малый и актуальный образ
FROM postgres:15-alpine

# 2) Копируем init-скрипты (если у вас есть .sql/.sh). Они выполнятся при первом старте инициализированной БД
COPY ./initdb/ /docker-entrypoint-initdb.d/

# 3) Устанавливаем дефолтные переменные, которые при необходимости переопределяются из внешнего .env
ENV POSTGRES_USER=app_user \
    POSTGRES_PASSWORD=strong_password \
    POSTGRES_DB=app_db

# 4) Открываем порт  
EXPOSE 5432

# ENTRYPOINT/CMD уже заданы в базовом образе