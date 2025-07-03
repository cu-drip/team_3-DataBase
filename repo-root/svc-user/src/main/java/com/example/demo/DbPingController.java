package com.example.demo;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;
import java.util.Map;

@RestController
public class DbPingController {

    private final DbPingRepository repo;

    public DbPingController(DbPingRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/api/db-check")
    public ResponseEntity<Map<String, Object>> dbCheck() {
        OffsetDateTime ts = repo.fetchDbTime();
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "dbTime", ts
        ));
    }
}
