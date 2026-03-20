-- MySQL export generated from SQLite on 2026-03-20
SET NAMES utf8mb4;
SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `migrations` (`id` integer primary key AUTO_INCREMENT not null, `migration` varchar(255) not null, `batch` integer not null);
INSERT INTO migrations VALUES(1,'0001_01_01_000000_create_users_table',1);
INSERT INTO migrations VALUES(2,'0001_01_01_000001_create_cache_table',1);
INSERT INTO migrations VALUES(3,'0001_01_01_000002_create_jobs_table',1);
CREATE TABLE IF NOT EXISTS `users` (`id` integer primary key AUTO_INCREMENT not null, `name` varchar(255) not null, `email` varchar(255) not null, `email_verified_at` datetime, `password` varchar(255) not null, `remember_token` varchar(255), `created_at` datetime, `updated_at` datetime);
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (`email` varchar(255) not null, `token` varchar(255) not null, `created_at` datetime, primary key (`email`));
CREATE TABLE IF NOT EXISTS `sessions` (`id` varchar(255) not null, `user_id` integer, `ip_address` varchar(255), `user_agent` text, `payload` text not null, `last_activity` integer not null, primary key (`id`));
CREATE TABLE IF NOT EXISTS `cache` (`key` varchar(255) not null, `value` text not null, `expiration` integer not null, primary key (`key`));
CREATE TABLE IF NOT EXISTS `cache_locks` (`key` varchar(255) not null, `owner` varchar(255) not null, `expiration` integer not null, primary key (`key`));
CREATE TABLE IF NOT EXISTS `jobs` (`id` integer primary key AUTO_INCREMENT not null, `queue` varchar(255) not null, `payload` text not null, `attempts` integer not null, `reserved_at` integer, `available_at` integer not null, `created_at` integer not null);
CREATE TABLE IF NOT EXISTS `job_batches` (`id` varchar(255) not null, `name` varchar(255) not null, `total_jobs` integer not null, `pending_jobs` integer not null, `failed_jobs` integer not null, `failed_job_ids` text not null, `options` text, `cancelled_at` integer, `created_at` integer not null, `finished_at` integer, primary key (`id`));
CREATE TABLE IF NOT EXISTS `failed_jobs` (`id` integer primary key AUTO_INCREMENT not null, `uuid` varchar(255) not null, `connection` text not null, `queue` text not null, `payload` text not null, `exception` text not null, `failed_at` datetime not null default CURRENT_TIMESTAMP);
CREATE UNIQUE INDEX `users_email_unique` on `users` (`email`);
CREATE INDEX `sessions_user_id_index` on `sessions` (`user_id`);
CREATE INDEX `sessions_last_activity_index` on `sessions` (`last_activity`);
CREATE INDEX `cache_expiration_index` on `cache` (`expiration`);
CREATE INDEX `cache_locks_expiration_index` on `cache_locks` (`expiration`);
CREATE INDEX `jobs_queue_reserved_at_available_at_index` on `jobs` (`queue`, `reserved_at`, `available_at`);
CREATE UNIQUE INDEX `failed_jobs_uuid_unique` on `failed_jobs` (`uuid`);

SET foreign_key_checks = 1;
