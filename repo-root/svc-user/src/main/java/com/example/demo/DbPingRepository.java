package com.example.demo;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;

@Repository
public class DbPingRepository {

    private final JdbcTemplate jdbc;

    public DbPingRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public OffsetDateTime fetchDbTime() {
        return jdbc.queryForObject("SELECT now()", OffsetDateTime.class);
    }
}
