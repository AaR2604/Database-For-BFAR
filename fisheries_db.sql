-- =====================================================
-- Fisheries Management System - MySQL Schema
-- Generated from ERD
-- =====================================================

CREATE DATABASE IF NOT EXISTS fisheries_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE fisheries_db;

-- -----------------------------------------------------
-- roles
-- -----------------------------------------------------
CREATE TABLE roles (
  role_id      INT AUTO_INCREMENT PRIMARY KEY,
  role_name    VARCHAR(30)  NOT NULL,
  description  VARCHAR(100)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- users
-- -----------------------------------------------------
CREATE TABLE users (
  user_id        INT AUTO_INCREMENT PRIMARY KEY,
  role_id        INT          NOT NULL,
  full_name      VARCHAR(100) NOT NULL,
  username       VARCHAR(50)  NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  email          VARCHAR(100),
  status         VARCHAR(20)  NOT NULL DEFAULT 'active',
  last_login     DATETIME,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_users_username UNIQUE (username),
  CONSTRAINT fk_users_role FOREIGN KEY (role_id)
    REFERENCES roles (role_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- fisherfolk
-- -----------------------------------------------------
CREATE TABLE fisherfolk (
  fisherfolk_id    INT AUTO_INCREMENT PRIMARY KEY,
  created_by       INT          NOT NULL,
  registration_no  VARCHAR(30)  NOT NULL,
  last_name        VARCHAR(50)  NOT NULL,
  first_name       VARCHAR(50)  NOT NULL,
  middle_name      VARCHAR(50),
  sex              VARCHAR(10),
  birth_date       DATE,
  contact_no       VARCHAR(20),
  address_barangay VARCHAR(150),
  livelihood_type  VARCHAR(50),
  association      VARCHAR(100),
  status           VARCHAR(20)  NOT NULL DEFAULT 'active',
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_fisherfolk_regno UNIQUE (registration_no),
  CONSTRAINT fk_fisherfolk_created_by FOREIGN KEY (created_by)
    REFERENCES users (user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- fisheries_resources
-- -----------------------------------------------------
CREATE TABLE fisheries_resources (
  resource_id    INT AUTO_INCREMENT PRIMARY KEY,
  fisherfolk_id  INT NULL,
  created_by     INT          NOT NULL,
  resource_code  VARCHAR(30)  NOT NULL,
  resource_type  VARCHAR(50)  NOT NULL,
  resource_name  VARCHAR(100) NOT NULL,
  description    TEXT,
  quantity       INT          NOT NULL DEFAULT 0,
  status         VARCHAR(20)  NOT NULL DEFAULT 'active',
  date_recorded  DATE,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_resources_code UNIQUE (resource_code),
  CONSTRAINT fk_resources_fisherfolk FOREIGN KEY (fisherfolk_id)
    REFERENCES fisherfolk (fisherfolk_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_resources_created_by FOREIGN KEY (created_by)
    REFERENCES users (user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- documents
-- -----------------------------------------------------
CREATE TABLE documents (
  document_id    INT AUTO_INCREMENT PRIMARY KEY,
  uploaded_by    INT          NOT NULL,
  resource_id    INT NULL,
  fisherfolk_id  INT NULL,
  title          VARCHAR(150) NOT NULL,
  doc_type       VARCHAR(50),
  keywords       VARCHAR(255),
  file_name      VARCHAR(255) NOT NULL,
  file_path      VARCHAR(255) NOT NULL,
  uploaded_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_documents_uploaded_by FOREIGN KEY (uploaded_by)
    REFERENCES users (user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_documents_resource FOREIGN KEY (resource_id)
    REFERENCES fisheries_resources (resource_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_documents_fisherfolk FOREIGN KEY (fisherfolk_id)
    REFERENCES fisherfolk (fisherfolk_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- activity_logs
-- -----------------------------------------------------
CREATE TABLE activity_logs (
  log_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT         NOT NULL,
  action       VARCHAR(30) NOT NULL,
  module       VARCHAR(50),
  record_id    INT,
  description  TEXT,
  ip_address   VARCHAR(45),
  created_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_activity_user FOREIGN KEY (user_id)
    REFERENCES users (user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- audit_logs
-- -----------------------------------------------------
CREATE TABLE audit_logs (
  audit_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT         NOT NULL,
  table_name  VARCHAR(50) NOT NULL,
  record_id   INT         NOT NULL,
  action      ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  old_values  JSON,
  new_values  JSON,
  ip_address  VARCHAR(45),
  user_agent  VARCHAR(255),
  created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id)
    REFERENCES users (user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Helpful indexes
-- -----------------------------------------------------
CREATE INDEX idx_fisherfolk_name      ON fisherfolk (last_name, first_name);
CREATE INDEX idx_resources_type       ON fisheries_resources (resource_type);
CREATE INDEX idx_documents_type       ON documents (doc_type);
CREATE INDEX idx_activity_user_date   ON activity_logs (user_id, created_at);
CREATE INDEX idx_audit_table_record   ON audit_logs (table_name, record_id);

-- -----------------------------------------------------
-- Seed data (optional)
-- -----------------------------------------------------
INSERT INTO roles (role_name, description) VALUES
  ('Admin', 'Full system access'),
  ('Staff', 'Encode and manage records'),
  ('Viewer', 'Read-only access');
