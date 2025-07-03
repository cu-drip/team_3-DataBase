package com.example.demo;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class PingController {
    private final RestTemplate rt;
    public PingController(RestTemplate rt) { this.rt = rt; }

    @GetMapping("/ping")
    public String ping() {
        return "pong-from-A";
    }

    @GetMapping("/call-b")
    public String callB() {
        return "A→" + rt.getForObject("http://service-b:8080/ping", String.class);
    }
}