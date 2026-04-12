-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: pos_saas
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `pos_saas`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pos_saas` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `pos_saas`;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-admin@example.com|127.0.0.1','i:1;',1775832054),('laravel-cache-admin@example.com|127.0.0.1:timer','i:1775832054;',1775832054),('laravel-cache-admin@exemple.com|127.0.0.1','i:1;',1775832063),('laravel-cache-admin@exemple.com|127.0.0.1:timer','i:1775832063;',1775832063),('laravel-cache-translations.en.saas','a:150:{s:5:\"Email\";s:5:\"Email\";s:7:\"false])\";s:7:\"false])\";s:8:\"Password\";s:8:\"Password\";s:11:\"Remember me\";s:11:\"Remember me\";s:21:\"Forgot your password?\";s:21:\"Forgot your password?\";s:6:\"Log in\";s:6:\"Log in\";s:8:\"Username\";s:8:\"Username\";s:9:\"Dashboard\";s:9:\"Dashboard\";s:28:\"Quick overview of your SaaS.\";s:28:\"Quick overview of your SaaS.\";s:8:\"Managers\";s:8:\"Managers\";s:5:\"Plans\";s:5:\"Plans\";s:13:\"Subscriptions\";s:13:\"Subscriptions\";s:6:\"Stores\";s:6:\"Stores\";s:7:\"Devices\";s:7:\"Devices\";s:15:\"Payment Methods\";s:15:\"Payment Methods\";s:10:\"Currencies\";s:10:\"Currencies\";s:10:\"Categories\";s:10:\"Categories\";s:25:\"Product Option Categories\";s:25:\"Product Option Categories\";s:15:\"Product Options\";s:15:\"Product Options\";s:8:\"Products\";s:8:\"Products\";s:9:\"Customers\";s:9:\"Customers\";s:5:\"Taxes\";s:5:\"Taxes\";s:9:\"Discounts\";s:9:\"Discounts\";s:5:\"Roles\";s:5:\"Roles\";s:11:\"Permissions\";s:11:\"Permissions\";s:8:\"Printing\";s:8:\"Printing\";s:4:\"Open\";s:4:\"Open\";s:7:\"Reports\";s:7:\"Reports\";s:9:\"Languages\";s:9:\"Languages\";s:12:\"Translations\";s:12:\"Translations\";s:8:\"Shipping\";s:8:\"Shipping\";s:14:\"POS SaaS Admin\";s:14:\"POS SaaS Admin\";s:9:\"SaaS Menu\";s:9:\"SaaS Menu\";s:12:\"Manager Menu\";s:12:\"Manager Menu\";s:4:\"Dark\";s:4:\"Dark\";s:6:\"Logout\";s:6:\"Logout\";s:28:\"Manage companies and limits.\";s:28:\"Manage companies and limits.\";s:11:\"New Manager\";s:11:\"New Manager\";s:7:\"Profile\";s:7:\"Profile\";s:4:\"Name\";s:4:\"Name\";s:4:\"Plan\";s:4:\"Plan\";s:10:\"Expires In\";s:10:\"Expires In\";s:6:\"Active\";s:6:\"Active\";s:10:\"Max Stores\";s:10:\"Max Stores\";s:11:\"Max Devices\";s:11:\"Max Devices\";s:7:\"Actions\";s:7:\"Actions\";s:3:\"Yes\";s:3:\"Yes\";s:2:\"No\";s:2:\"No\";s:8:\"Currency\";s:8:\"Currency\";s:8:\"Timezone\";s:8:\"Timezone\";s:11:\"Select Plan\";s:11:\"Select Plan\";s:29:\"Manager Admin User (Optional)\";s:29:\"Manager Admin User (Optional)\";s:10:\"Admin Name\";s:10:\"Admin Name\";s:14:\"Admin Username\";s:14:\"Admin Username\";s:11:\"Admin Email\";s:11:\"Admin Email\";s:14:\"Admin Password\";s:14:\"Admin Password\";s:14:\"Create Manager\";s:14:\"Create Manager\";s:6:\"Cancel\";s:6:\"Cancel\";s:26:\"Manage subscription plans.\";s:26:\"Manage subscription plans.\";s:8:\"New Plan\";s:8:\"New Plan\";s:15:\"Duration (days)\";s:15:\"Duration (days)\";s:30:\"Max Stores (empty = unlimited)\";s:30:\"Max Stores (empty = unlimited)\";s:31:\"Max Devices (empty = unlimited)\";s:31:\"Max Devices (empty = unlimited)\";s:11:\"Create Plan\";s:11:\"Create Plan\";s:4:\"Edit\";s:4:\"Edit\";s:6:\"Delete\";s:6:\"Delete\";s:28:\"Manage available currencies.\";s:28:\"Manage available currencies.\";s:12:\"New Currency\";s:12:\"New Currency\";s:4:\"Code\";s:4:\"Code\";s:6:\"Symbol\";s:6:\"Symbol\";s:16:\"Code (3 letters)\";s:16:\"Code (3 letters)\";s:15:\"Create Currency\";s:15:\"Create Currency\";s:21:\"Delete this currency?\";s:21:\"Delete this currency?\";s:4:\"days\";s:4:\"days\";s:20:\"Delete this manager?\";s:20:\"Delete this manager?\";s:22:\"Manage manager stores.\";s:22:\"Manage manager stores.\";s:9:\"New Store\";s:9:\"New Store\";s:17:\"Filter by Manager\";s:17:\"Filter by Manager\";s:12:\"All Managers\";s:12:\"All Managers\";s:6:\"Filter\";s:6:\"Filter\";s:7:\"Manager\";s:7:\"Manager\";s:5:\"Stock\";s:5:\"Stock\";s:18:\"Delete this store?\";s:18:\"Delete this store?\";s:26:\"Manage product categories.\";s:26:\"Manage product categories.\";s:12:\"New Category\";s:12:\"New Category\";s:5:\"Scope\";s:5:\"Scope\";s:7:\"Picture\";s:7:\"Picture\";s:6:\"Parent\";s:6:\"Parent\";s:15:\"Parent Category\";s:15:\"Parent Category\";s:9:\"No Parent\";s:9:\"No Parent\";s:15:\"Create Category\";s:15:\"Create Category\";s:33:\"Manage product option categories.\";s:33:\"Manage product option categories.\";s:27:\"New Product Option Category\";s:27:\"New Product Option Category\";s:27:\"Manage products and prices.\";s:27:\"Manage products and prices.\";s:15:\"Import Products\";s:15:\"Import Products\";s:11:\"New Product\";s:11:\"New Product\";s:3:\"SKU\";s:3:\"SKU\";s:5:\"Price\";s:5:\"Price\";s:14:\"Select Manager\";s:14:\"Select Manager\";s:8:\"Category\";s:8:\"Category\";s:11:\"No Category\";s:11:\"No Category\";s:3:\"Tax\";s:3:\"Tax\";s:6:\"No Tax\";s:6:\"No Tax\";s:7:\"Barcode\";s:7:\"Barcode\";s:4:\"Cost\";s:4:\"Cost\";s:11:\"Description\";s:11:\"Description\";s:26:\"Product Options (quantity)\";s:26:\"Product Options (quantity)\";s:48:\"No product options available. Add options first.\";s:48:\"No product options available. Add options first.\";s:11:\"Track Stock\";s:11:\"Track Stock\";s:14:\"Create Product\";s:14:\"Create Product\";s:26:\"Overview for your manager.\";s:26:\"Overview for your manager.\";s:5:\"Sales\";s:5:\"Sales\";s:14:\"Manager Portal\";s:14:\"Manager Portal\";s:19:\"Manage your stores.\";s:19:\"Manage your stores.\";s:31:\"Manage your product categories.\";s:31:\"Manage your product categories.\";s:8:\"(Global)\";s:8:\"(Global)\";s:9:\"Duplicate\";s:9:\"Duplicate\";s:23:\"Manage product options.\";s:23:\"Manage product options.\";s:10:\"New Option\";s:10:\"New Option\";s:21:\"Manage your products.\";s:21:\"Manage your products.\";s:12:\"Edit Product\";s:12:\"Edit Product\";s:4:\"Save\";s:4:\"Save\";s:8:\"Variants\";s:8:\"Variants\";s:11:\"Add Variant\";s:11:\"Add Variant\";s:16:\"No variants yet.\";s:16:\"No variants yet.\";s:17:\"Printing services\";s:17:\"Printing services\";s:45:\"Configure the printers used by your services.\";s:45:\"Configure the printers used by your services.\";s:5:\"Store\";s:5:\"Store\";s:11:\"New Service\";s:11:\"New Service\";s:4:\"Type\";s:4:\"Type\";s:8:\"Template\";s:8:\"Template\";s:5:\"Order\";s:5:\"Order\";s:25:\"No printing services yet.\";s:25:\"No printing services yet.\";s:15:\"Loyalty Program\";s:15:\"Loyalty Program\";s:52:\"Configure how customers earn and use loyalty points.\";s:52:\"Configure how customers earn and use loyalty points.\";s:14:\"Enable Loyalty\";s:14:\"Enable Loyalty\";s:16:\"Points per order\";s:16:\"Points per order\";s:20:\"Added once per sale.\";s:20:\"Added once per sale.\";s:15:\"Points per item\";s:15:\"Points per item\";s:30:\"Applied to each item quantity.\";s:30:\"Applied to each item quantity.\";s:16:\"Amount per point\";s:16:\"Amount per point\";s:34:\"Spend this amount to earn 1 point.\";s:34:\"Spend this amount to earn 1 point.\";s:11:\"Point value\";s:11:\"Point value\";s:39:\"1 point equals this amount at checkout.\";s:39:\"1 point equals this amount at checkout.\";s:4:\"Back\";s:4:\"Back\";s:13:\"Recent sales.\";s:13:\"Recent sales.\";s:6:\"Status\";s:6:\"Status\";s:8:\"Subtotal\";s:8:\"Subtotal\";s:5:\"Total\";s:5:\"Total\";s:10:\"Ordered At\";s:10:\"Ordered At\";}',1775835381),('laravel-cache-translations.fr.flutter','a:0:{}',1775835721);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned DEFAULT NULL,
  `parent_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_manager_id_name_unique` (`manager_id`,`name`),
  KEY `categories_parent_id_foreign` (`parent_id`),
  CONSTRAINT `categories_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `categories_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,NULL,NULL,'cafe',NULL,1,'2026-04-10 13:57:13','2026-04-10 13:57:13',NULL);
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `currencies_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
INSERT INTO `currencies` VALUES (1,'usd','USD','usd',1,'2026-04-10 13:51:23','2026-04-10 13:51:23');
/*!40000 ALTER TABLE `currencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `loyalty_points_balance` int unsigned NOT NULL DEFAULT '0',
  `loyalty_points_earned_total` int unsigned NOT NULL DEFAULT '0',
  `loyalty_points_redeemed_total` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customers_manager_id_is_active_index` (`manager_id`,`is_active`),
  CONSTRAINT `customers_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,1,'manager - CLIENT',NULL,NULL,NULL,NULL,0,0,0,1,'2026-04-10 13:52:12','2026-04-10 13:52:12',NULL);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_sync_logs`
--

DROP TABLE IF EXISTS `device_sync_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_sync_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `device_id` bigint unsigned NOT NULL,
  `direction` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ok',
  `payload_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `synced_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `device_sync_logs_device_id_direction_status_index` (`device_id`,`direction`,`status`),
  CONSTRAINT `device_sync_logs_device_id_foreign` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_sync_logs`
--

LOCK TABLES `device_sync_logs` WRITE;
/*!40000 ALTER TABLE `device_sync_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `device_sync_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `devices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `store_id` bigint unsigned NOT NULL,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pos',
  `platform` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'android',
  `secret` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `last_sync_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `devices_uuid_unique` (`uuid`),
  KEY `devices_store_id_foreign` (`store_id`),
  KEY `devices_manager_id_store_id_is_active_index` (`manager_id`,`store_id`,`is_active`),
  CONSTRAINT `devices_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `devices_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devices`
--

LOCK TABLES `devices` WRITE;
/*!40000 ALTER TABLE `devices` DISABLE KEYS */;
/*!40000 ALTER TABLE `devices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `discounts`
--

DROP TABLE IF EXISTS `discounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discounts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'percent',
  `value` decimal(12,2) NOT NULL DEFAULT '0.00',
  `scope` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'order',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `discounts_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `discounts_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discounts`
--

LOCK TABLES `discounts` WRITE;
/*!40000 ALTER TABLE `discounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `discounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_reserved_at_available_at_index` (`queue`,`reserved_at`,`available_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `native_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direction` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ltr',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `languages_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES (1,'en','EN','EN','ltr',1,1,'2026-03-31 02:55:48','2026-03-31 02:55:48');
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `managers`
--

DROP TABLE IF EXISTS `managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `managers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `max_stores` int unsigned DEFAULT NULL,
  `max_devices` int unsigned DEFAULT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `timezone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `plan_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plan_id` bigint unsigned DEFAULT NULL,
  `loyalty_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `loyalty_points_per_order` int unsigned NOT NULL DEFAULT '0',
  `loyalty_points_per_item` int unsigned NOT NULL DEFAULT '0',
  `loyalty_amount_per_point` decimal(12,2) NOT NULL DEFAULT '0.00',
  `loyalty_point_value` decimal(12,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `managers_slug_unique` (`slug`),
  UNIQUE KEY `managers_username_unique` (`username`),
  KEY `managers_plan_id_index` (`plan_id`),
  CONSTRAINT `managers_plan_id_foreign` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `managers`
--

LOCK TABLES `managers` WRITE;
/*!40000 ALTER TABLE `managers` DISABLE KEYS */;
INSERT INTO `managers` VALUES (1,'manager','manager','manager',1,NULL,NULL,'USD','UTC','PRO',1,0,0,0,0.00,0.00,'2026-04-10 13:52:12','2026-04-10 13:52:12',NULL);
/*!40000 ALTER TABLE `managers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_03_14_015940_create_managers_table',1),(5,'2026_03_14_015941_create_roles_table',1),(6,'2026_03_14_015941_create_stores_table',1),(7,'2026_03_14_015942_create_categories_table',1),(8,'2026_03_14_015942_create_customers_table',1),(9,'2026_03_14_015942_create_devices_table',1),(10,'2026_03_14_015942_create_permissions_table',1),(11,'2026_03_14_015942_create_products_table',1),(12,'2026_03_14_015943_create_payment_methods_table',1),(13,'2026_03_14_015943_create_product_variants_table',1),(14,'2026_03_14_015943_create_sales_table',1),(15,'2026_03_14_015944_create_device_sync_logs_table',1),(16,'2026_03_14_015944_create_discounts_table',1),(17,'2026_03_14_015944_create_payments_table',1),(18,'2026_03_14_015944_create_sale_items_table',1),(19,'2026_03_14_015944_create_stock_movements_table',1),(20,'2026_03_14_015944_create_taxes_table',1),(21,'2026_03_14_015945_create_permission_role_table',1),(22,'2026_03_14_015945_create_role_user_table',1),(23,'2026_03_14_020207_add_manager_fields_to_users_table',1),(24,'2026_03_14_020434_add_tax_fk_to_products_table',1),(25,'2026_03_14_030510_create_personal_access_tokens_table',1),(26,'2026_03_16_000001_add_ingredients_and_image_to_products_table',1),(27,'2026_03_17_000001_create_currencies_table',1),(28,'2026_03_17_000002_add_currency_to_stores_table',1),(29,'2026_03_18_000001_create_ingredients_table',1),(30,'2026_03_18_000002_create_ingredient_product_table',1),(31,'2026_03_18_000003_add_ingredients_to_sale_items_table',1),(32,'2026_03_20_000001_create_plans_table',1),(33,'2026_03_20_000002_create_ingredient_categories_table',1),(34,'2026_03_20_000003_add_plan_id_to_managers_table',1),(35,'2026_03_20_000004_add_image_path_to_categories_table',1),(36,'2026_03_20_000005_add_category_and_image_to_ingredients_table',1),(37,'2026_03_20_000006_add_logo_to_stores_table',1),(38,'2026_03_20_000007_add_image_url_to_products_table',1),(39,'2026_03_24_000001_add_manager_id_to_payment_methods_table',1),(40,'2026_03_24_000002_migrate_tenants_to_managers',1),(41,'2026_03_24_000010_create_languages_table',1),(42,'2026_03_24_000011_create_translations_table',1),(43,'2026_03_24_000020_create_user_audits_table',1),(44,'2026_03_25_000003_drop_tenant_id_from_legacy_tables',1),(45,'2026_03_25_000005_fix_legacy_unique_indexes',1),(46,'2026_03_25_000006_rename_ingredients_to_product_options',1),(47,'2026_03_26_000001_add_username_to_managers_table',1),(48,'2026_03_26_000002_add_option_type_to_product_options_table',1),(49,'2026_03_26_000003_create_subscriptions_table',1),(50,'2026_03_30_000001_add_loyalty_fields_to_managers_table',1),(51,'2026_03_30_000002_add_loyalty_fields_to_customers_table',1),(52,'2026_03_30_000003_add_loyalty_fields_to_sales_table',1),(53,'2026_03_30_000004_add_allow_loyalty_redeem_to_stores_table',1),(54,'2026_03_30_000005_add_allow_loyalty_redeem_to_users_table',1),(55,'2026_03_30_000006_create_shipping_methods_table',1),(56,'2026_03_31_000001_create_printing_services_table',1),(57,'2026_04_10_150000_add_username_to_users_table',2);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_methods_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `payment_methods_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sale_id` bigint unsigned NOT NULL,
  `payment_method_id` bigint unsigned NOT NULL,
  `amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payments_payment_method_id_foreign` (`payment_method_id`),
  KEY `payments_sale_id_index` (`sale_id`),
  CONSTRAINT `payments_payment_method_id_foreign` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_sale_id_foreign` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission_role`
--

DROP TABLE IF EXISTS `permission_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_role` (
  `permission_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`role_id`),
  KEY `permission_role_role_id_foreign` (`role_id`),
  CONSTRAINT `permission_role_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `permission_role_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission_role`
--

LOCK TABLES `permission_role` WRITE;
/*!40000 ALTER TABLE `permission_role` DISABLE KEYS */;
/*!40000 ALTER TABLE `permission_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',3,'flutter','ded0a29e29f12b4c5e86260f738586a7a42c0db4f81cf1746d04ec301ec108e0','[\"*\"]','2026-04-10 13:58:36',NULL,'2026-04-10 13:55:24','2026-04-10 13:58:36'),(2,'App\\Models\\User',3,'flutter','b77f9069616d89d201d21ba1f820ce9b0bb6108c23f849a3f7030411d9f0879d','[\"*\"]','2026-04-10 13:59:35',NULL,'2026-04-10 13:59:33','2026-04-10 13:59:35'),(3,'App\\Models\\User',3,'flutter','24b9fd82f3226de59687775d88e0d2d45221052b41fa5133cb72ba10a6fed9f2','[\"*\"]','2026-04-10 14:36:28',NULL,'2026-04-10 14:32:27','2026-04-10 14:36:28'),(4,'App\\Models\\User',3,'flutter','63db2b9a5a2c4b5234ec69078123b1ecdfac9bd00b3cb991a523221fdd1573b6','[\"*\"]','2026-04-10 14:39:09',NULL,'2026-04-10 14:38:34','2026-04-10 14:39:09'),(5,'App\\Models\\User',3,'flutter','f8ac06a8d91a57e74d3dc604cdf2d88b760e9c44b55acee605f5c5d3c74b9169','[\"*\"]','2026-04-10 14:59:09',NULL,'2026-04-10 14:41:08','2026-04-10 14:59:09');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plans`
--

DROP TABLE IF EXISTS `plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_days` int unsigned DEFAULT NULL,
  `max_stores` int unsigned DEFAULT NULL,
  `max_devices` int unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `plans_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plans`
--

LOCK TABLES `plans` WRITE;
/*!40000 ALTER TABLE `plans` DISABLE KEYS */;
INSERT INTO `plans` VALUES (1,'PRO',90,NULL,NULL,1,'2026-04-10 13:48:25','2026-04-10 13:48:25',NULL);
/*!40000 ALTER TABLE `plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `printing_services`
--

DROP TABLE IF EXISTS `printing_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `printing_services` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `store_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `template` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'receipt',
  `settings` json DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `printing_services_manager_id_foreign` (`manager_id`),
  KEY `printing_services_store_id_foreign` (`store_id`),
  CONSTRAINT `printing_services_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `printing_services_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `printing_services`
--

LOCK TABLES `printing_services` WRITE;
/*!40000 ALTER TABLE `printing_services` DISABLE KEYS */;
/*!40000 ALTER TABLE `printing_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_option_categories`
--

DROP TABLE IF EXISTS `product_option_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_option_categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ingredient_categories_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `ingredient_categories_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_option_categories`
--

LOCK TABLES `product_option_categories` WRITE;
/*!40000 ALTER TABLE `product_option_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_option_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_option_product`
--

DROP TABLE IF EXISTS `product_option_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_option_product` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_option_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT '1.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_option_product_product_option_id_product_id_unique` (`product_option_id`,`product_id`),
  KEY `product_option_product_product_id_foreign` (`product_id`),
  CONSTRAINT `product_option_product_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `product_option_product_product_option_id_foreign` FOREIGN KEY (`product_option_id`) REFERENCES `product_options` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_option_product`
--

LOCK TABLES `product_option_product` WRITE;
/*!40000 ALTER TABLE `product_option_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_option_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_options`
--

DROP TABLE IF EXISTS `product_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_options` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned DEFAULT NULL,
  `product_option_category_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `option_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'boolean',
  `step_action` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step_value` int unsigned DEFAULT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ingredients_manager_id_name_unique` (`manager_id`,`name`),
  KEY `ingredients_manager_id_ingredient_category_id_index` (`manager_id`,`product_option_category_id`),
  KEY `product_options_product_option_category_id_foreign` (`product_option_category_id`),
  CONSTRAINT `ingredients_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `product_options_product_option_category_id_foreign` FOREIGN KEY (`product_option_category_id`) REFERENCES `product_option_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_options`
--

LOCK TABLES `product_options` WRITE;
/*!40000 ALTER TABLE `product_options` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sku` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `barcode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(12,2) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_variants_uuid_unique` (`uuid`),
  UNIQUE KEY `product_variants_manager_id_sku_unique` (`manager_id`,`sku`),
  UNIQUE KEY `product_variants_manager_id_barcode_unique` (`manager_id`,`barcode`),
  KEY `product_variants_product_id_foreign` (`product_id`),
  KEY `product_variants_manager_id_product_id_is_active_index` (`manager_id`,`product_id`,`is_active`),
  CONSTRAINT `product_variants_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `product_variants_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `category_id` bigint unsigned DEFAULT NULL,
  `tax_id` bigint unsigned DEFAULT NULL,
  `uuid` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sku` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `barcode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `options` text COLLATE utf8mb4_unicode_ci,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `cost` decimal(12,2) NOT NULL DEFAULT '0.00',
  `track_stock` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_uuid_unique` (`uuid`),
  UNIQUE KEY `products_manager_id_sku_unique` (`manager_id`,`sku`),
  UNIQUE KEY `products_manager_id_barcode_unique` (`manager_id`,`barcode`),
  KEY `products_category_id_foreign` (`category_id`),
  KEY `products_manager_id_is_active_index` (`manager_id`,`is_active`),
  KEY `products_tax_id_index` (`tax_id`),
  CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `products_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `products_tax_id_foreign` FOREIGN KEY (`tax_id`) REFERENCES `taxes` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,1,1,NULL,'1a68ff82-aefd-4558-8f6d-80714df55529','cafe','cafe','cafee',NULL,NULL,NULL,NULL,12.00,8.00,0,1,'2026-04-10 13:58:30','2026-04-10 13:59:11',NULL);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_user`
--

DROP TABLE IF EXISTS `role_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_user` (
  `role_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`user_id`),
  KEY `role_user_user_id_foreign` (`user_id`),
  CONSTRAINT `role_user_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_user_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_user`
--

LOCK TABLES `role_user` WRITE;
/*!40000 ALTER TABLE `role_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `roles_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sale_items`
--

DROP TABLE IF EXISTS `sale_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sale_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sale_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned DEFAULT NULL,
  `product_variant_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sku` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` decimal(12,3) NOT NULL DEFAULT '1.000',
  `unit_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `options` json DEFAULT NULL,
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sale_items_product_id_foreign` (`product_id`),
  KEY `sale_items_product_variant_id_foreign` (`product_variant_id`),
  KEY `sale_items_sale_id_index` (`sale_id`),
  CONSTRAINT `sale_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sale_items_product_variant_id_foreign` FOREIGN KEY (`product_variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sale_items_sale_id_foreign` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_items`
--

LOCK TABLES `sale_items` WRITE;
/*!40000 ALTER TABLE `sale_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `sale_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS `sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `store_id` bigint unsigned NOT NULL,
  `device_id` bigint unsigned DEFAULT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned DEFAULT NULL,
  `number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'paid',
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tax_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `grand_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `note` text COLLATE utf8mb4_unicode_ci,
  `loyalty_points_earned` int unsigned NOT NULL DEFAULT '0',
  `loyalty_points_redeemed` int unsigned NOT NULL DEFAULT '0',
  `loyalty_amount_redeemed` decimal(12,2) NOT NULL DEFAULT '0.00',
  `ordered_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sales_store_id_foreign` (`store_id`),
  KEY `sales_device_id_foreign` (`device_id`),
  KEY `sales_user_id_foreign` (`user_id`),
  KEY `sales_customer_id_foreign` (`customer_id`),
  KEY `sales_manager_id_store_id_status_index` (`manager_id`,`store_id`,`status`),
  KEY `sales_manager_id_ordered_at_index` (`manager_id`,`ordered_at`),
  CONSTRAINT `sales_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sales_device_id_foreign` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sales_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sales_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sales_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
/*!40000 ALTER TABLE `sales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('ZjoeqhqIACalCOmv0r8i6mXS6xYtiLunN9WQjWU3',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:149.0) Gecko/20100101 Firefox/149.0','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiWFBRMlJWUjRrZTdXakxOa05zYXdvZTdDV2NxNWM0dVRPOWw5bEpOcSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo0OiJsYW5nIjtzOjI6ImVuIjtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czozNToiaHR0cDovLzEyNy4wLjAuMTo4MDAwL21hbmFnZXIvc2FsZXMiO3M6NToicm91dGUiO3M6MTk6Im1hbmFnZXIuc2FsZXMuaW5kZXgiO31zOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aTozO30=',1775835337);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_methods`
--

DROP TABLE IF EXISTS `shipping_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_methods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` decimal(12,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shipping_methods_manager_id_is_active_index` (`manager_id`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_methods`
--

LOCK TABLES `shipping_methods` WRITE;
/*!40000 ALTER TABLE `shipping_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipping_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_movements`
--

DROP TABLE IF EXISTS `stock_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_movements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `store_id` bigint unsigned DEFAULT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `quantity` decimal(12,3) NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'adjust',
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ref_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ref_id` bigint unsigned DEFAULT NULL,
  `occurred_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stock_movements_product_id_foreign` (`product_id`),
  KEY `stock_movements_store_id_foreign` (`store_id`),
  KEY `stock_movements_user_id_foreign` (`user_id`),
  KEY `stock_movements_manager_id_product_id_type_index` (`manager_id`,`product_id`,`type`),
  CONSTRAINT `stock_movements_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stock_movements_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stock_movements_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL,
  CONSTRAINT `stock_movements_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stores` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stock_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `currency_id` bigint unsigned DEFAULT NULL,
  `is_currency_right` tinyint(1) NOT NULL DEFAULT '1',
  `allow_loyalty_redeem` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `stores_manager_id_code_unique` (`manager_id`,`code`),
  KEY `stores_manager_id_is_active_index` (`manager_id`,`is_active`),
  KEY `stores_currency_id_foreign` (`currency_id`),
  KEY `stores_manager_id_currency_id_index` (`manager_id`,`currency_id`),
  CONSTRAINT `stores_currency_id_foreign` FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`) ON DELETE SET NULL,
  CONSTRAINT `stores_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stores`
--

LOCK TABLES `stores` WRITE;
/*!40000 ALTER TABLE `stores` DISABLE KEYS */;
INSERT INTO `stores` VALUES (1,1,'manager',NULL,NULL,NULL,NULL,NULL,1,1,'2026-04-10 13:52:12','2026-04-10 13:52:12',NULL,1,1,1);
/*!40000 ALTER TABLE `stores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned NOT NULL,
  `plan_id` bigint unsigned DEFAULT NULL,
  `starts_at` timestamp NULL DEFAULT NULL,
  `ends_at` timestamp NULL DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `device_limit` int unsigned DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscriptions_plan_id_foreign` (`plan_id`),
  KEY `subscriptions_manager_id_status_index` (`manager_id`,`status`),
  KEY `subscriptions_ends_at_index` (`ends_at`),
  CONSTRAINT `subscriptions_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `subscriptions_plan_id_foreign` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxes`
--

DROP TABLE IF EXISTS `taxes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taxes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rate` decimal(7,4) NOT NULL DEFAULT '0.0000',
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'percent',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taxes_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `taxes_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxes`
--

LOCK TABLES `taxes` WRITE;
/*!40000 ALTER TABLE `taxes` DISABLE KEYS */;
/*!40000 ALTER TABLE `taxes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `translations`
--

DROP TABLE IF EXISTS `translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `translations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint unsigned NOT NULL,
  `scope` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'saas',
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `translations_language_id_scope_key_unique` (`language_id`,`scope`,`key`),
  KEY `translations_scope_key_index` (`scope`,`key`),
  CONSTRAINT `translations_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translations`
--

LOCK TABLES `translations` WRITE;
/*!40000 ALTER TABLE `translations` DISABLE KEYS */;
INSERT INTO `translations` VALUES (1,1,'saas','Email','Email','2026-03-31 02:59:46','2026-03-31 02:59:46'),(2,1,'saas','false])','false])','2026-03-31 02:59:46','2026-03-31 02:59:46'),(3,1,'saas','Password','Password','2026-03-31 02:59:46','2026-03-31 02:59:46'),(4,1,'saas','Remember me','Remember me','2026-03-31 02:59:46','2026-03-31 02:59:46'),(5,1,'saas','Forgot your password?','Forgot your password?','2026-03-31 02:59:46','2026-03-31 02:59:46'),(6,1,'saas','Log in','Log in','2026-03-31 02:59:46','2026-03-31 02:59:46'),(7,1,'saas','Username','Username','2026-04-10 13:43:16','2026-04-10 13:43:16'),(8,1,'saas','Dashboard','Dashboard','2026-04-10 13:43:27','2026-04-10 13:43:27'),(9,1,'saas','Quick overview of your SaaS.','Quick overview of your SaaS.','2026-04-10 13:43:28','2026-04-10 13:43:28'),(10,1,'saas','Managers','Managers','2026-04-10 13:43:28','2026-04-10 13:43:28'),(11,1,'saas','Plans','Plans','2026-04-10 13:43:28','2026-04-10 13:43:28'),(12,1,'saas','Subscriptions','Subscriptions','2026-04-10 13:43:28','2026-04-10 13:43:28'),(13,1,'saas','Stores','Stores','2026-04-10 13:43:28','2026-04-10 13:43:28'),(14,1,'saas','Devices','Devices','2026-04-10 13:43:28','2026-04-10 13:43:28'),(15,1,'saas','Payment Methods','Payment Methods','2026-04-10 13:43:28','2026-04-10 13:43:28'),(16,1,'saas','Currencies','Currencies','2026-04-10 13:43:28','2026-04-10 13:43:28'),(17,1,'saas','Categories','Categories','2026-04-10 13:43:28','2026-04-10 13:43:28'),(18,1,'saas','Product Option Categories','Product Option Categories','2026-04-10 13:43:28','2026-04-10 13:43:28'),(19,1,'saas','Product Options','Product Options','2026-04-10 13:43:28','2026-04-10 13:43:28'),(20,1,'saas','Products','Products','2026-04-10 13:43:28','2026-04-10 13:43:28'),(21,1,'saas','Customers','Customers','2026-04-10 13:43:28','2026-04-10 13:43:28'),(22,1,'saas','Taxes','Taxes','2026-04-10 13:43:28','2026-04-10 13:43:28'),(23,1,'saas','Discounts','Discounts','2026-04-10 13:43:28','2026-04-10 13:43:28'),(24,1,'saas','Roles','Roles','2026-04-10 13:43:28','2026-04-10 13:43:28'),(25,1,'saas','Permissions','Permissions','2026-04-10 13:43:28','2026-04-10 13:43:28'),(26,1,'saas','Printing','Printing','2026-04-10 13:43:28','2026-04-10 13:43:28'),(27,1,'saas','Open','Open','2026-04-10 13:43:28','2026-04-10 13:43:28'),(28,1,'saas','Reports','Reports','2026-04-10 13:43:28','2026-04-10 13:43:28'),(29,1,'saas','Languages','Languages','2026-04-10 13:43:28','2026-04-10 13:43:28'),(30,1,'saas','Translations','Translations','2026-04-10 13:43:28','2026-04-10 13:43:28'),(31,1,'saas','Shipping','Shipping','2026-04-10 13:43:28','2026-04-10 13:43:28'),(32,1,'saas','POS SaaS Admin','POS SaaS Admin','2026-04-10 13:43:28','2026-04-10 13:43:28'),(33,1,'saas','SaaS Menu','SaaS Menu','2026-04-10 13:43:28','2026-04-10 13:43:28'),(34,1,'saas','Manager Menu','Manager Menu','2026-04-10 13:43:28','2026-04-10 13:43:28'),(35,1,'saas','Dark','Dark','2026-04-10 13:43:28','2026-04-10 13:43:28'),(36,1,'saas','Logout','Logout','2026-04-10 13:43:28','2026-04-10 13:43:28'),(37,1,'saas','Manage companies and limits.','Manage companies and limits.','2026-04-10 13:43:35','2026-04-10 13:43:35'),(38,1,'saas','New Manager','New Manager','2026-04-10 13:43:35','2026-04-10 13:43:35'),(39,1,'saas','Profile','Profile','2026-04-10 13:43:35','2026-04-10 13:43:35'),(40,1,'saas','Name','Name','2026-04-10 13:43:35','2026-04-10 13:43:35'),(41,1,'saas','Plan','Plan','2026-04-10 13:43:35','2026-04-10 13:43:35'),(42,1,'saas','Expires In','Expires In','2026-04-10 13:43:35','2026-04-10 13:43:35'),(43,1,'saas','Active','Active','2026-04-10 13:43:35','2026-04-10 13:43:35'),(44,1,'saas','Max Stores','Max Stores','2026-04-10 13:43:35','2026-04-10 13:43:35'),(45,1,'saas','Max Devices','Max Devices','2026-04-10 13:43:35','2026-04-10 13:43:35'),(46,1,'saas','Actions','Actions','2026-04-10 13:43:35','2026-04-10 13:43:35'),(47,1,'saas','Yes','Yes','2026-04-10 13:43:38','2026-04-10 13:43:38'),(48,1,'saas','No','No','2026-04-10 13:43:38','2026-04-10 13:43:38'),(49,1,'saas','Currency','Currency','2026-04-10 13:43:38','2026-04-10 13:43:38'),(50,1,'saas','Timezone','Timezone','2026-04-10 13:43:38','2026-04-10 13:43:38'),(51,1,'saas','Select Plan','Select Plan','2026-04-10 13:43:38','2026-04-10 13:43:38'),(52,1,'saas','Manager Admin User (Optional)','Manager Admin User (Optional)','2026-04-10 13:43:38','2026-04-10 13:43:38'),(53,1,'saas','Admin Name','Admin Name','2026-04-10 13:43:38','2026-04-10 13:43:38'),(54,1,'saas','Admin Username','Admin Username','2026-04-10 13:43:38','2026-04-10 13:43:38'),(55,1,'saas','Admin Email','Admin Email','2026-04-10 13:43:38','2026-04-10 13:43:38'),(56,1,'saas','Admin Password','Admin Password','2026-04-10 13:43:38','2026-04-10 13:43:38'),(57,1,'saas','Create Manager','Create Manager','2026-04-10 13:43:38','2026-04-10 13:43:38'),(58,1,'saas','Cancel','Cancel','2026-04-10 13:43:38','2026-04-10 13:43:38'),(59,1,'saas','Manage subscription plans.','Manage subscription plans.','2026-04-10 13:48:07','2026-04-10 13:48:07'),(60,1,'saas','New Plan','New Plan','2026-04-10 13:48:08','2026-04-10 13:48:08'),(61,1,'saas','Duration (days)','Duration (days)','2026-04-10 13:48:08','2026-04-10 13:48:08'),(62,1,'saas','Max Stores (empty = unlimited)','Max Stores (empty = unlimited)','2026-04-10 13:48:12','2026-04-10 13:48:12'),(63,1,'saas','Max Devices (empty = unlimited)','Max Devices (empty = unlimited)','2026-04-10 13:48:12','2026-04-10 13:48:12'),(64,1,'saas','Create Plan','Create Plan','2026-04-10 13:48:12','2026-04-10 13:48:12'),(65,1,'saas','Edit','Edit','2026-04-10 13:48:26','2026-04-10 13:48:26'),(66,1,'saas','Delete','Delete','2026-04-10 13:48:26','2026-04-10 13:48:26'),(67,1,'saas','Manage available currencies.','Manage available currencies.','2026-04-10 13:51:14','2026-04-10 13:51:14'),(68,1,'saas','New Currency','New Currency','2026-04-10 13:51:14','2026-04-10 13:51:14'),(69,1,'saas','Code','Code','2026-04-10 13:51:14','2026-04-10 13:51:14'),(70,1,'saas','Symbol','Symbol','2026-04-10 13:51:14','2026-04-10 13:51:14'),(71,1,'saas','Code (3 letters)','Code (3 letters)','2026-04-10 13:51:16','2026-04-10 13:51:16'),(72,1,'saas','Create Currency','Create Currency','2026-04-10 13:51:16','2026-04-10 13:51:16'),(73,1,'saas','Delete this currency?','Delete this currency?','2026-04-10 13:51:24','2026-04-10 13:51:24'),(74,1,'saas','days','days','2026-04-10 13:52:13','2026-04-10 13:52:13'),(75,1,'saas','Delete this manager?','Delete this manager?','2026-04-10 13:52:13','2026-04-10 13:52:13'),(76,1,'saas','Manage manager stores.','Manage manager stores.','2026-04-10 13:56:42','2026-04-10 13:56:42'),(77,1,'saas','New Store','New Store','2026-04-10 13:56:42','2026-04-10 13:56:42'),(78,1,'saas','Filter by Manager','Filter by Manager','2026-04-10 13:56:42','2026-04-10 13:56:42'),(79,1,'saas','All Managers','All Managers','2026-04-10 13:56:42','2026-04-10 13:56:42'),(80,1,'saas','Filter','Filter','2026-04-10 13:56:42','2026-04-10 13:56:42'),(81,1,'saas','Manager','Manager','2026-04-10 13:56:42','2026-04-10 13:56:42'),(82,1,'saas','Stock','Stock','2026-04-10 13:56:42','2026-04-10 13:56:42'),(83,1,'saas','Delete this store?','Delete this store?','2026-04-10 13:56:42','2026-04-10 13:56:42'),(84,1,'saas','Manage product categories.','Manage product categories.','2026-04-10 13:57:01','2026-04-10 13:57:01'),(85,1,'saas','New Category','New Category','2026-04-10 13:57:01','2026-04-10 13:57:01'),(86,1,'saas','Scope','Scope','2026-04-10 13:57:01','2026-04-10 13:57:01'),(87,1,'saas','Picture','Picture','2026-04-10 13:57:01','2026-04-10 13:57:01'),(88,1,'saas','Parent','Parent','2026-04-10 13:57:01','2026-04-10 13:57:01'),(89,1,'saas','Parent Category','Parent Category','2026-04-10 13:57:03','2026-04-10 13:57:03'),(90,1,'saas','No Parent','No Parent','2026-04-10 13:57:03','2026-04-10 13:57:03'),(91,1,'saas','Create Category','Create Category','2026-04-10 13:57:03','2026-04-10 13:57:03'),(92,1,'saas','Manage product option categories.','Manage product option categories.','2026-04-10 13:57:17','2026-04-10 13:57:17'),(93,1,'saas','New Product Option Category','New Product Option Category','2026-04-10 13:57:17','2026-04-10 13:57:17'),(94,1,'saas','Manage products and prices.','Manage products and prices.','2026-04-10 13:57:22','2026-04-10 13:57:22'),(95,1,'saas','Import Products','Import Products','2026-04-10 13:57:23','2026-04-10 13:57:23'),(96,1,'saas','New Product','New Product','2026-04-10 13:57:23','2026-04-10 13:57:23'),(97,1,'saas','SKU','SKU','2026-04-10 13:57:23','2026-04-10 13:57:23'),(98,1,'saas','Price','Price','2026-04-10 13:57:23','2026-04-10 13:57:23'),(99,1,'saas','Select Manager','Select Manager','2026-04-10 13:57:25','2026-04-10 13:57:25'),(100,1,'saas','Category','Category','2026-04-10 13:57:25','2026-04-10 13:57:25'),(101,1,'saas','No Category','No Category','2026-04-10 13:57:25','2026-04-10 13:57:25'),(102,1,'saas','Tax','Tax','2026-04-10 13:57:25','2026-04-10 13:57:25'),(103,1,'saas','No Tax','No Tax','2026-04-10 13:57:25','2026-04-10 13:57:25'),(104,1,'saas','Barcode','Barcode','2026-04-10 13:57:25','2026-04-10 13:57:25'),(105,1,'saas','Cost','Cost','2026-04-10 13:57:25','2026-04-10 13:57:25'),(106,1,'saas','Description','Description','2026-04-10 13:57:25','2026-04-10 13:57:25'),(107,1,'saas','Product Options (quantity)','Product Options (quantity)','2026-04-10 13:57:25','2026-04-10 13:57:25'),(108,1,'saas','No product options available. Add options first.','No product options available. Add options first.','2026-04-10 13:57:25','2026-04-10 13:57:25'),(109,1,'saas','Track Stock','Track Stock','2026-04-10 13:57:25','2026-04-10 13:57:25'),(110,1,'saas','Create Product','Create Product','2026-04-10 13:57:25','2026-04-10 13:57:25'),(111,1,'saas','Overview for your manager.','Overview for your manager.','2026-04-10 13:57:42','2026-04-10 13:57:42'),(112,1,'saas','Sales','Sales','2026-04-10 13:57:42','2026-04-10 13:57:42'),(113,1,'saas','Manager Portal','Manager Portal','2026-04-10 13:57:42','2026-04-10 13:57:42'),(114,1,'saas','Manage your stores.','Manage your stores.','2026-04-10 13:57:44','2026-04-10 13:57:44'),(115,1,'saas','Manage your product categories.','Manage your product categories.','2026-04-10 13:57:48','2026-04-10 13:57:48'),(116,1,'saas','(Global)','(Global)','2026-04-10 13:57:48','2026-04-10 13:57:48'),(117,1,'saas','Duplicate','Duplicate','2026-04-10 13:57:48','2026-04-10 13:57:48'),(118,1,'saas','Manage product options.','Manage product options.','2026-04-10 13:57:51','2026-04-10 13:57:51'),(119,1,'saas','New Option','New Option','2026-04-10 13:57:51','2026-04-10 13:57:51'),(120,1,'saas','Manage your products.','Manage your products.','2026-04-10 13:57:53','2026-04-10 13:57:53'),(121,1,'saas','Edit Product','Edit Product','2026-04-10 13:59:04','2026-04-10 13:59:04'),(122,1,'saas','Save','Save','2026-04-10 13:59:04','2026-04-10 13:59:04'),(123,1,'saas','Variants','Variants','2026-04-10 13:59:04','2026-04-10 13:59:04'),(124,1,'saas','Add Variant','Add Variant','2026-04-10 13:59:04','2026-04-10 13:59:04'),(125,1,'saas','No variants yet.','No variants yet.','2026-04-10 13:59:04','2026-04-10 13:59:04'),(126,1,'saas','Printing services','Printing services','2026-04-10 14:03:19','2026-04-10 14:03:19'),(127,1,'saas','Configure the printers used by your services.','Configure the printers used by your services.','2026-04-10 14:03:19','2026-04-10 14:03:19'),(128,1,'saas','Store','Store','2026-04-10 14:03:19','2026-04-10 14:03:19'),(129,1,'saas','New Service','New Service','2026-04-10 14:03:19','2026-04-10 14:03:19'),(130,1,'saas','Type','Type','2026-04-10 14:03:19','2026-04-10 14:03:19'),(131,1,'saas','Template','Template','2026-04-10 14:03:19','2026-04-10 14:03:19'),(132,1,'saas','Order','Order','2026-04-10 14:03:19','2026-04-10 14:03:19'),(133,1,'saas','No printing services yet.','No printing services yet.','2026-04-10 14:03:19','2026-04-10 14:03:19'),(134,1,'saas','Loyalty Program','Loyalty Program','2026-04-10 14:26:18','2026-04-10 14:26:18'),(135,1,'saas','Configure how customers earn and use loyalty points.','Configure how customers earn and use loyalty points.','2026-04-10 14:26:18','2026-04-10 14:26:18'),(136,1,'saas','Enable Loyalty','Enable Loyalty','2026-04-10 14:26:18','2026-04-10 14:26:18'),(137,1,'saas','Points per order','Points per order','2026-04-10 14:26:18','2026-04-10 14:26:18'),(138,1,'saas','Added once per sale.','Added once per sale.','2026-04-10 14:26:18','2026-04-10 14:26:18'),(139,1,'saas','Points per item','Points per item','2026-04-10 14:26:18','2026-04-10 14:26:18'),(140,1,'saas','Applied to each item quantity.','Applied to each item quantity.','2026-04-10 14:26:18','2026-04-10 14:26:18'),(141,1,'saas','Amount per point','Amount per point','2026-04-10 14:26:18','2026-04-10 14:26:18'),(142,1,'saas','Spend this amount to earn 1 point.','Spend this amount to earn 1 point.','2026-04-10 14:26:18','2026-04-10 14:26:18'),(143,1,'saas','Point value','Point value','2026-04-10 14:26:18','2026-04-10 14:26:18'),(144,1,'saas','1 point equals this amount at checkout.','1 point equals this amount at checkout.','2026-04-10 14:26:18','2026-04-10 14:26:18'),(145,1,'saas','Back','Back','2026-04-10 14:26:18','2026-04-10 14:26:18'),(146,1,'saas','Recent sales.','Recent sales.','2026-04-10 14:26:21','2026-04-10 14:26:21'),(147,1,'saas','Status','Status','2026-04-10 14:26:21','2026-04-10 14:26:21'),(148,1,'saas','Subtotal','Subtotal','2026-04-10 14:26:21','2026-04-10 14:26:21'),(149,1,'saas','Total','Total','2026-04-10 14:26:21','2026-04-10 14:26:21'),(150,1,'saas','Ordered At','Ordered At','2026-04-10 14:26:21','2026-04-10 14:26:21');
/*!40000 ALTER TABLE `translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_audits`
--

DROP TABLE IF EXISTS `user_audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_audits` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `actor_user_id` bigint unsigned DEFAULT NULL,
  `target_user_id` bigint unsigned DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  `store_id` bigint unsigned DEFAULT NULL,
  `action` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `changes` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_audits_actor_user_id_foreign` (`actor_user_id`),
  KEY `user_audits_target_user_id_foreign` (`target_user_id`),
  KEY `user_audits_manager_id_foreign` (`manager_id`),
  KEY `user_audits_store_id_foreign` (`store_id`),
  CONSTRAINT `user_audits_actor_user_id_foreign` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `user_audits_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `user_audits_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL,
  CONSTRAINT `user_audits_target_user_id_foreign` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_audits`
--

LOCK TABLES `user_audits` WRITE;
/*!40000 ALTER TABLE `user_audits` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_audits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  `store_id` bigint unsigned DEFAULT NULL,
  `is_super_admin` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `allow_loyalty_redeem` tinyint(1) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`),
  KEY `users_store_id_foreign` (`store_id`),
  KEY `users_manager_id_is_active_index` (`manager_id`,`is_active`),
  CONSTRAINT `users_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Test User','test','test@example.com','2026-03-31 02:55:51','$2y$12$zsYbuLRV0H9yFkcH5FZDTe7Ewle2TBg738Iub7JL/CK8u7YcuXz32','HnC4YcOIYb','2026-03-31 02:55:51','2026-03-31 02:55:51',NULL,NULL,0,1,NULL,NULL),(2,'Admin','admin','admin@kinpos.com',NULL,'$2y$12$7K1J.btbuJsHDSYtdrJGrO3UJhPEPoNRpSqRg4EKp6HiZqbJSxK7S',NULL,'2026-03-31 03:16:25','2026-04-10 13:42:25',NULL,NULL,1,1,NULL,NULL),(3,'manager','manager','manager@kinpos.com',NULL,'$2y$12$9pO2oKnx7Zb72NxHLbUEA.IRk5niXU/V2tU02bRfS0sxSlQeabFpC',NULL,'2026-04-10 13:52:12','2026-04-10 13:52:12',1,1,0,1,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'pos_saas'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-10 17:00:26
