package com.acme.service;

import com.acme.repo.OrderRepository;
import org.springframework.stereotype.Service;

@Service
public class OrderService {
  private final OrderRepository orderRepository;

  public OrderService(OrderRepository orderRepository) {
    this.orderRepository = orderRepository;
  }

  public String findAll() {
    return orderRepository.findAll().toString();
  }

  public String create() {
    return "created";
  }
}
