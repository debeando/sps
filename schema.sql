CREATE DATABASE IF NOT EXISTS trash;
CREATE DATABASE IF NOT EXISTS dba;

USE dba;

CREATE TABLE `audits` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `action` enum('I','U','D') NOT NULL,
  `database_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `column_name` varchar(64) NOT NULL,
  `primary_key` int(10) unsigned DEFAULT NULL,
  `old_value` text,
  `new_value` text,
  `user_name` varchar(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `audits_database_name` (`database_name`),
  KEY `audits_table_name` (`table_name`),
  KEY `audits_column_name` (`column_name`),
  KEY `audits_primary_key` (`primary_key`),
  KEY `audits_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `trash` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `database_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `user_name` varchar(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
