package com.acme.domain;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "orders")
public class Order {
  @Id
  private Long id;

  @Column(name = "status")
  private String status;

  @Column(name = "total_amount")
  private Long totalAmount;

  @ManyToOne
  @JoinColumn(name = "customer_id")
  private Customer customer;
}
