package com.acme.domain;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "customers")
public class Customer {
  @Id
  private Long id;

  @Column(name = "email")
  private String email;

  @Column(name = "name")
  private String name;
}
