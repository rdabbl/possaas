-- MySQL dump 10.13  Distrib 9.0.1, for macos14.7 (arm64)
--
-- Host: 127.0.0.1    Database: pos_saas
-- ------------------------------------------------------
-- Server version	9.0.1

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
INSERT INTO `cache` VALUES ('laravel-cache-lookwino@gmail.com|127.0.0.1','i:1;',1775161420),('laravel-cache-lookwino@gmail.com|127.0.0.1:timer','i:1775161420;',1775161420),('laravel-cache-translations.en.saas','a:240:{s:1:\"+\";s:1:\"+\";s:39:\"1 point equals this amount at checkout.\";s:39:\"1 point equals this amount at checkout.\";s:7:\"Actions\";s:7:\"Actions\";s:6:\"Active\";s:6:\"Active\";s:84:\"Add printer profiles, templates, and routing rules for receipts and kitchen tickets.\";s:84:\"Add printer profiles, templates, and routing rules for receipts and kitchen tickets.\";s:11:\"Add Variant\";s:11:\"Add Variant\";s:20:\"Added once per sale.\";s:20:\"Added once per sale.\";s:7:\"Address\";s:7:\"Address\";s:11:\"Admin Email\";s:11:\"Admin Email\";s:10:\"Admin Name\";s:10:\"Admin Name\";s:14:\"Admin Password\";s:14:\"Admin Password\";s:3:\"All\";s:3:\"All\";s:13:\"All Languages\";s:13:\"All Languages\";s:12:\"All Managers\";s:12:\"All Managers\";s:24:\"Allow Loyalty Redemption\";s:24:\"Allow Loyalty Redemption\";s:6:\"Amount\";s:6:\"Amount\";s:16:\"Amount per point\";s:16:\"Amount per point\";s:30:\"Applied to each item quantity.\";s:30:\"Applied to each item quantity.\";s:4:\"Back\";s:4:\"Back\";s:7:\"Barcode\";s:7:\"Barcode\";s:6:\"Cancel\";s:6:\"Cancel\";s:8:\"Canceled\";s:8:\"Canceled\";s:10:\"Categories\";s:10:\"Categories\";s:8:\"Category\";s:8:\"Category\";s:4:\"Code\";s:4:\"Code\";s:11:\"Coming Soon\";s:11:\"Coming Soon\";s:52:\"Configure how customers earn and use loyalty points.\";s:52:\"Configure how customers earn and use loyalty points.\";s:45:\"Configure the printers used by your services.\";s:45:\"Configure the printers used by your services.\";s:4:\"Cost\";s:4:\"Cost\";s:6:\"Create\";s:6:\"Create\";s:15:\"Create Category\";s:15:\"Create Category\";s:15:\"Create Language\";s:15:\"Create Language\";s:14:\"Create Manager\";s:14:\"Create Manager\";s:14:\"Create Product\";s:14:\"Create Product\";s:11:\"Create User\";s:11:\"Create User\";s:10:\"Currencies\";s:10:\"Currencies\";s:8:\"Currency\";s:8:\"Currency\";s:9:\"Customers\";s:9:\"Customers\";s:4:\"Dark\";s:4:\"Dark\";s:9:\"Dashboard\";s:9:\"Dashboard\";s:4:\"days\";s:4:\"days\";s:9:\"Days Left\";s:9:\"Days Left\";s:7:\"Default\";s:7:\"Default\";s:41:\"Define a service and its ticket template.\";s:41:\"Define a service and its ticket template.\";s:6:\"Delete\";s:6:\"Delete\";s:21:\"Delete this currency?\";s:21:\"Delete this currency?\";s:20:\"Delete this manager?\";s:20:\"Delete this manager?\";s:27:\"Delete this payment method?\";s:27:\"Delete this payment method?\";s:18:\"Delete this store?\";s:18:\"Delete this store?\";s:17:\"Delete this user?\";s:17:\"Delete this user?\";s:11:\"Description\";s:11:\"Description\";s:7:\"Devices\";s:7:\"Devices\";s:9:\"Direction\";s:9:\"Direction\";s:9:\"Discounts\";s:9:\"Discounts\";s:9:\"Duplicate\";s:9:\"Duplicate\";s:15:\"Duration (days)\";s:15:\"Duration (days)\";s:4:\"Edit\";s:4:\"Edit\";s:13:\"Edit Category\";s:13:\"Edit Category\";s:13:\"Edit Customer\";s:13:\"Edit Customer\";s:13:\"Edit Language\";s:13:\"Edit Language\";s:12:\"Edit Manager\";s:12:\"Edit Manager\";s:12:\"Edit Product\";s:12:\"Edit Product\";s:10:\"Edit Store\";s:10:\"Edit Store\";s:8:\"Edit Tax\";s:8:\"Edit Tax\";s:5:\"Email\";s:5:\"Email\";s:2:\"en\";s:2:\"en\";s:14:\"Enable Loyalty\";s:14:\"Enable Loyalty\";s:7:\"English\";s:7:\"English\";s:7:\"Expired\";s:7:\"Expired\";s:10:\"Expires In\";s:10:\"Expires In\";s:7:\"false])\";s:7:\"false])\";s:6:\"Filter\";s:6:\"Filter\";s:17:\"Filter by Manager\";s:17:\"Filter by Manager\";s:7:\"Flutter\";s:7:\"Flutter\";s:21:\"Forgot your password?\";s:21:\"Forgot your password?\";s:37:\"free, order_percent, per_item, manual\";s:37:\"free, order_percent, per_item, manual\";s:15:\"Import Products\";s:15:\"Import Products\";s:5:\"Items\";s:5:\"Items\";s:3:\"Key\";s:3:\"Key\";s:12:\"Key or value\";s:12:\"Key or value\";s:8:\"Language\";s:8:\"Language\";s:9:\"Languages\";s:9:\"Languages\";s:6:\"Log in\";s:6:\"Log in\";s:4:\"Logo\";s:4:\"Logo\";s:6:\"Logout\";s:6:\"Logout\";s:14:\"Loyalty Points\";s:14:\"Loyalty Points\";s:15:\"Loyalty Program\";s:15:\"Loyalty Program\";s:3:\"LTR\";s:3:\"LTR\";s:28:\"Manage available currencies.\";s:28:\"Manage available currencies.\";s:27:\"Manage available languages.\";s:27:\"Manage available languages.\";s:36:\"Manage cash and other payment types.\";s:36:\"Manage cash and other payment types.\";s:28:\"Manage companies and limits.\";s:28:\"Manage companies and limits.\";s:17:\"Manage discounts.\";s:17:\"Manage discounts.\";s:22:\"Manage manager stores.\";s:22:\"Manage manager stores.\";s:47:\"Manage manager subscriptions and device limits.\";s:47:\"Manage manager subscriptions and device limits.\";s:31:\"Manage manager users and roles.\";s:31:\"Manage manager users and roles.\";s:29:\"Manage POS and kiosk devices.\";s:29:\"Manage POS and kiosk devices.\";s:26:\"Manage product categories.\";s:26:\"Manage product categories.\";s:33:\"Manage product option categories.\";s:33:\"Manage product option categories.\";s:23:\"Manage product options.\";s:23:\"Manage product options.\";s:27:\"Manage products and prices.\";s:27:\"Manage products and prices.\";s:24:\"Manage shipping methods.\";s:24:\"Manage shipping methods.\";s:26:\"Manage subscription plans.\";s:26:\"Manage subscription plans.\";s:36:\"Manage UI text for SaaS and Flutter.\";s:36:\"Manage UI text for SaaS and Flutter.\";s:22:\"Manage your customers.\";s:22:\"Manage your customers.\";s:22:\"Manage your discounts.\";s:22:\"Manage your discounts.\";s:31:\"Manage your product categories.\";s:31:\"Manage your product categories.\";s:38:\"Manage your product option categories.\";s:38:\"Manage your product option categories.\";s:21:\"Manage your products.\";s:21:\"Manage your products.\";s:29:\"Manage your shipping methods.\";s:29:\"Manage your shipping methods.\";s:19:\"Manage your stores.\";s:19:\"Manage your stores.\";s:18:\"Manage your taxes.\";s:18:\"Manage your taxes.\";s:7:\"Manager\";s:7:\"Manager\";s:29:\"Manager Admin User (Optional)\";s:29:\"Manager Admin User (Optional)\";s:12:\"Manager Menu\";s:12:\"Manager Menu\";s:14:\"Manager Portal\";s:14:\"Manager Portal\";s:8:\"Managers\";s:8:\"Managers\";s:11:\"Max Devices\";s:11:\"Max Devices\";s:10:\"Max Stores\";s:10:\"Max Stores\";s:6:\"Method\";s:6:\"Method\";s:4:\"Name\";s:4:\"Name\";s:6:\"Native\";s:6:\"Native\";s:11:\"Native Name\";s:11:\"Native Name\";s:12:\"New Category\";s:12:\"New Category\";s:12:\"New Currency\";s:12:\"New Currency\";s:12:\"New Customer\";s:12:\"New Customer\";s:10:\"New Device\";s:10:\"New Device\";s:12:\"New Discount\";s:12:\"New Discount\";s:12:\"New Language\";s:12:\"New Language\";s:11:\"New Manager\";s:11:\"New Manager\";s:10:\"New Method\";s:10:\"New Method\";s:10:\"New Option\";s:10:\"New Option\";s:19:\"New Option Category\";s:19:\"New Option Category\";s:8:\"New Plan\";s:8:\"New Plan\";s:20:\"New printing service\";s:20:\"New printing service\";s:11:\"New Product\";s:11:\"New Product\";s:27:\"New Product Option Category\";s:27:\"New Product Option Category\";s:11:\"New Service\";s:11:\"New Service\";s:19:\"New Shipping Method\";s:19:\"New Shipping Method\";s:9:\"New Store\";s:9:\"New Store\";s:16:\"New Subscription\";s:16:\"New Subscription\";s:7:\"New Tax\";s:7:\"New Tax\";s:15:\"New Translation\";s:15:\"New Translation\";s:8:\"New User\";s:8:\"New User\";s:2:\"No\";s:2:\"No\";s:11:\"No Category\";s:11:\"No Category\";s:9:\"No Parent\";s:9:\"No Parent\";s:25:\"No printing services yet.\";s:25:\"No printing services yet.\";s:13:\"No roles yet.\";s:13:\"No roles yet.\";s:6:\"No Tax\";s:6:\"No Tax\";s:16:\"No variants yet.\";s:16:\"No variants yet.\";s:4:\"Note\";s:4:\"Note\";s:4:\"Open\";s:4:\"Open\";s:6:\"Option\";s:6:\"Option\";s:17:\"Option Categories\";s:17:\"Option Categories\";s:5:\"Order\";s:5:\"Order\";s:10:\"Ordered At\";s:10:\"Ordered At\";s:26:\"Overview for your manager.\";s:26:\"Overview for your manager.\";s:7:\"Paid At\";s:7:\"Paid At\";s:6:\"Parent\";s:6:\"Parent\";s:15:\"Parent Category\";s:15:\"Parent Category\";s:8:\"Password\";s:8:\"Password\";s:6:\"Paused\";s:6:\"Paused\";s:15:\"Payment Methods\";s:15:\"Payment Methods\";s:8:\"Payments\";s:8:\"Payments\";s:6:\"Period\";s:6:\"Period\";s:11:\"Permissions\";s:11:\"Permissions\";s:5:\"Phone\";s:5:\"Phone\";s:7:\"Picture\";s:7:\"Picture\";s:4:\"Plan\";s:4:\"Plan\";s:5:\"Plans\";s:5:\"Plans\";s:8:\"Platform\";s:8:\"Platform\";s:11:\"Point value\";s:11:\"Point value\";s:6:\"Points\";s:6:\"Points\";s:15:\"Points per item\";s:15:\"Points per item\";s:16:\"Points per order\";s:16:\"Points per order\";s:14:\"POS SaaS Admin\";s:14:\"POS SaaS Admin\";s:49:\"Prepare shipping settings for the POS mobile app.\";s:49:\"Prepare shipping settings for the POS mobile app.\";s:5:\"Price\";s:5:\"Price\";s:14:\"Print template\";s:14:\"Print template\";s:8:\"Printing\";s:8:\"Printing\";s:81:\"Printing module placeholder. We will define the workflow and settings here later.\";s:81:\"Printing module placeholder. We will define the workflow and settings here later.\";s:17:\"Printing services\";s:17:\"Printing services\";s:7:\"Product\";s:7:\"Product\";s:25:\"Product Option Categories\";s:25:\"Product Option Categories\";s:15:\"Product Options\";s:15:\"Product Options\";s:26:\"Product Options (quantity)\";s:26:\"Product Options (quantity)\";s:13:\"Product Stock\";s:13:\"Product Stock\";s:8:\"Products\";s:8:\"Products\";s:7:\"Profile\";s:7:\"Profile\";s:3:\"Qty\";s:3:\"Qty\";s:8:\"Quantity\";s:8:\"Quantity\";s:28:\"Quick overview of your SaaS.\";s:28:\"Quick overview of your SaaS.\";s:4:\"Rate\";s:4:\"Rate\";s:13:\"Recent sales.\";s:13:\"Recent sales.\";s:11:\"Remember me\";s:11:\"Remember me\";s:7:\"Reports\";s:7:\"Reports\";s:5:\"Roles\";s:5:\"Roles\";s:3:\"RTL\";s:3:\"RTL\";s:4:\"SaaS\";s:4:\"SaaS\";s:9:\"SaaS Menu\";s:9:\"SaaS Menu\";s:5:\"Sales\";s:5:\"Sales\";s:4:\"Save\";s:4:\"Save\";s:5:\"Scope\";s:5:\"Scope\";s:6:\"Search\";s:6:\"Search\";s:15:\"Select Currency\";s:15:\"Select Currency\";s:11:\"Select Plan\";s:11:\"Select Plan\";s:12:\"Service name\";s:12:\"Service name\";s:12:\"Service type\";s:12:\"Service type\";s:8:\"Shipping\";s:8:\"Shipping\";s:3:\"SKU\";s:3:\"SKU\";s:34:\"Spend this amount to earn 1 point.\";s:34:\"Spend this amount to earn 1 point.\";s:6:\"Status\";s:6:\"Status\";s:5:\"Stock\";s:5:\"Stock\";s:13:\"Stock Enabled\";s:13:\"Stock Enabled\";s:16:\"Stock Management\";s:16:\"Stock Management\";s:5:\"Store\";s:5:\"Store\";s:11:\"Store Stock\";s:11:\"Store Stock\";s:6:\"Stores\";s:6:\"Stores\";s:13:\"Subscriptions\";s:13:\"Subscriptions\";s:8:\"Subtotal\";s:8:\"Subtotal\";s:7:\"Summary\";s:7:\"Summary\";s:6:\"Symbol\";s:6:\"Symbol\";s:3:\"Tax\";s:3:\"Tax\";s:5:\"Taxes\";s:5:\"Taxes\";s:8:\"Template\";s:8:\"Template\";s:87:\"This module will manage shipping methods, rates, and zones used by the Flutter POS app.\";s:87:\"This module will manage shipping methods, rates, and zones used by the Flutter POS app.\";s:8:\"Timezone\";s:8:\"Timezone\";s:5:\"Total\";s:5:\"Total\";s:11:\"Track Stock\";s:11:\"Track Stock\";s:12:\"Translations\";s:12:\"Translations\";s:4:\"Type\";s:4:\"Type\";s:10:\"Unit Price\";s:10:\"Unit Price\";s:54:\"Used for percent or per item. Leave 0 for free/manual.\";s:54:\"Used for percent or per item. Leave 0 for free/manual.\";s:8:\"Username\";s:8:\"Username\";s:5:\"Users\";s:5:\"Users\";s:5:\"Value\";s:5:\"Value\";s:8:\"Variants\";s:8:\"Variants\";s:4:\"View\";s:4:\"View\";s:3:\"Yes\";s:3:\"Yes\";}',1777335548),('laravel-cache-translations.fr.flutter','a:0:{}',1777552656);
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
  `parent_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_manager_id_name_unique` (`manager_id`,`name`),
  KEY `categories_parent_id_foreign` (`parent_id`),
  CONSTRAINT `categories_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `categories_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,NULL,'CAFE',NULL,1,'2026-03-16 22:28:52','2026-03-25 23:12:26','2026-03-25 23:12:26',5),(2,NULL,'LIMONADE',NULL,1,'2026-03-16 22:28:59','2026-03-25 23:12:24','2026-03-25 23:12:24',5),(4,NULL,'CAFE','categories/2WTw31ySQUiJNmjIJqzZQZnup0f34MGFJkOdgIQo.png',1,'2026-03-25 01:21:30','2026-03-27 15:32:49',NULL,6),(5,NULL,'TACOS','categories/pLS2WuBbvq1YMaXm1jIMsotvsnZyBKYj5EDhaSpD.png',1,'2026-03-25 01:24:28','2026-03-27 15:32:41',NULL,6),(6,NULL,'SALADES','categories/ObGwnJJihVnE1HZ79zMTsqsdhHxAr5d4sUFLo9ax.png',1,'2026-03-27 15:26:03','2026-03-27 15:32:08',NULL,6),(7,NULL,'JUS','categories/h8dcSAdnmsXlhLjJLxafPt5OhE0OUYQCYFCpS5nz.png',1,'2026-03-27 15:26:27','2026-03-27 15:31:57',NULL,6),(8,NULL,'PIZZA','categories/EEThFRDLuuukpGegcdrRI5zSYaMWwnFea7ncuII8.png',1,'2026-03-27 15:26:41','2026-03-27 15:31:42',NULL,6);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
INSERT INTO `currencies` VALUES (1,'USD','USD','usd',1,'2026-03-17 03:11:46','2026-03-17 03:11:46'),(2,'EURO','EUR','euro',1,'2026-03-17 03:12:10','2026-03-17 03:12:10');
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `customers_tenant_id_is_active_index` (`is_active`),
  KEY `customers_manager_id_foreign` (`manager_id`),
  CONSTRAINT `customers_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'TACOS LYON POS',NULL,NULL,NULL,NULL,277,286,9,1,'2026-03-25 01:13:44','2026-03-30 21:38:47',NULL,6),(2,'lookwino - CLIENT',NULL,NULL,NULL,NULL,0,0,0,1,'2026-04-02 19:22:08','2026-04-02 19:22:08',NULL,7);
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `devices_uuid_unique` (`uuid`),
  KEY `devices_tenant_id_store_id_is_active_index` (`store_id`,`is_active`),
  KEY `devices_manager_id_foreign` (`manager_id`),
  CONSTRAINT `devices_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
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
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'percent',
  `value` decimal(12,2) NOT NULL DEFAULT '0.00',
  `scope` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'order',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `discounts_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `discounts_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discounts`
--

LOCK TABLES `discounts` WRITE;
/*!40000 ALTER TABLE `discounts` DISABLE KEYS */;
INSERT INTO `discounts` VALUES (1,'offer','percent',10.00,'order',1,'2026-03-19 23:27:54','2026-03-25 23:12:55','2026-03-25 23:12:55',5),(2,'FANS','percent',10.00,'order',1,'2026-03-25 01:22:38','2026-03-25 01:22:38',NULL,6);
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES (1,'en','EN','EN','ltr',1,1,'2026-03-24 02:34:07','2026-03-24 02:34:07'),(2,'fr','FR','FR','ltr',1,0,'2026-03-26 00:14:22','2026-03-26 00:14:34');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `managers`
--

LOCK TABLES `managers` WRITE;
/*!40000 ALTER TABLE `managers` DISABLE KEYS */;
INSERT INTO `managers` VALUES (1,'rdabb',NULL,'bl',1,1,1,'USD','UTC','ELITE',1,0,0,0,0.00,0.00,'2026-03-24 01:29:47','2026-03-25 01:10:40','2026-03-25 01:10:40'),(2,'Tenant 1',NULL,'tenant-1',1,5,10,'USD','UTC',NULL,NULL,0,0,0,0.00,0.00,'2026-03-14 03:15:34','2026-03-25 01:10:38','2026-03-25 01:10:38'),(3,'tacos',NULL,'tacos',1,1,1,'USD','UTC','plan A',NULL,0,0,0,0.00,0.00,'2026-03-14 03:26:26','2026-03-25 01:10:35','2026-03-25 01:10:35'),(4,'pizzeria',NULL,'pizzeria',1,1,1,'USD','UTC','plan a',NULL,0,0,0,0.00,0.00,'2026-03-16 21:27:14','2026-03-25 01:10:33','2026-03-25 01:10:33'),(5,'RESTAURANT',NULL,'RESTAURANT',1,1,1,'USD','UTC','plan a',NULL,0,0,0,0.00,0.00,'2026-03-16 22:23:30','2026-03-25 01:10:30','2026-03-25 01:10:30'),(6,'badr bl','rdabbl','badr-bl',1,1,1,'USD','UTC','ELITE',1,1,10,3,100.00,1.00,'2026-03-25 01:13:44','2026-03-30 15:35:08',NULL),(7,'lookwino','lookwino','lookwino',1,1,1,'USD','UTC','ELITE',1,0,0,0,0.00,0.00,'2026-04-02 19:22:08','2026-04-02 19:22:08',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_03_14_015940_create_tenants_table',2),(5,'2026_03_14_015941_create_roles_table',2),(6,'2026_03_14_015941_create_stores_table',2),(7,'2026_03_14_015942_create_categories_table',2),(8,'2026_03_14_015942_create_customers_table',2),(9,'2026_03_14_015942_create_devices_table',3),(10,'2026_03_14_015942_create_permissions_table',3),(11,'2026_03_14_015942_create_products_table',4),(12,'2026_03_14_015943_create_payment_methods_table',4),(13,'2026_03_14_015943_create_product_variants_table',4),(14,'2026_03_14_015943_create_sales_table',4),(15,'2026_03_14_015944_create_device_sync_logs_table',4),(16,'2026_03_14_015944_create_discounts_table',4),(17,'2026_03_14_015944_create_payments_table',4),(18,'2026_03_14_015944_create_sale_items_table',4),(19,'2026_03_14_015944_create_stock_movements_table',4),(20,'2026_03_14_015944_create_taxes_table',4),(21,'2026_03_14_015945_create_permission_role_table',4),(22,'2026_03_14_015945_create_role_user_table',4),(23,'2026_03_14_020207_add_tenant_fields_to_users_table',4),(24,'2026_03_14_020434_add_tax_fk_to_products_table',4),(25,'2026_03_14_030510_create_personal_access_tokens_table',5),(26,'2026_03_16_000001_add_ingredients_and_image_to_products_table',6),(27,'2026_03_17_000001_create_currencies_table',7),(28,'2026_03_17_000002_add_currency_to_stores_table',7),(29,'2026_03_18_000001_create_ingredients_table',8),(30,'2026_03_18_000002_create_ingredient_product_table',8),(31,'2026_03_18_000003_add_ingredients_to_sale_items_table',9),(32,'2026_03_20_000001_create_plans_table',9),(33,'2026_03_20_000002_create_ingredient_categories_table',9),(34,'2026_03_20_000003_add_plan_id_to_tenants_table',9),(35,'2026_03_20_000004_add_image_path_to_categories_table',9),(36,'2026_03_20_000005_add_category_and_image_to_ingredients_table',9),(37,'2026_03_20_000006_add_logo_to_stores_table',9),(38,'2026_03_20_000007_add_image_url_to_products_table',9),(39,'2026_03_14_015940_create_managers_table',10),(40,'2026_03_14_020207_add_manager_fields_to_users_table',10),(41,'2026_03_20_000003_add_plan_id_to_managers_table',10),(42,'2026_03_24_000001_add_manager_id_to_payment_methods_table',10),(43,'2026_03_24_000002_migrate_tenants_to_managers',11),(44,'2026_03_24_000010_create_languages_table',12),(45,'2026_03_24_000011_create_translations_table',12),(46,'2026_03_24_000020_create_user_audits_table',12),(47,'2026_03_25_000001_drop_tenant_id_from_stores_table',13),(48,'2026_03_25_000003_drop_tenant_id_from_legacy_tables',14),(49,'2026_03_25_000005_fix_legacy_unique_indexes',15),(50,'2026_03_25_000006_rename_ingredients_to_product_options',16),(51,'2026_03_26_000001_add_username_to_managers_table',17),(52,'2026_03_26_000002_add_option_type_to_product_options_table',17),(53,'2026_03_26_000003_create_subscriptions_table',17),(54,'2026_03_30_000001_add_loyalty_fields_to_managers_table',18),(55,'2026_03_30_000002_add_loyalty_fields_to_customers_table',18),(56,'2026_03_30_000003_add_loyalty_fields_to_sales_table',18),(57,'2026_03_30_000004_add_allow_loyalty_redeem_to_stores_table',19),(58,'2026_03_30_000005_add_allow_loyalty_redeem_to_users_table',19),(59,'2026_03_30_000006_create_shipping_methods_table',20),(60,'2026_03_31_000001_create_printing_services_table',21),(61,'2026_04_10_150000_add_username_to_users_table',22),(62,'2026_04_30_120000_add_pin_to_users_table',22);
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
  `tenant_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_methods_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `payment_methods_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
INSERT INTO `payment_methods` VALUES (1,5,'cash','cash',1,1,'2026-03-17 02:45:38','2026-03-17 02:45:38',NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,1,10.00,NULL,'2026-03-25 01:48:49','2026-03-25 01:48:49','2026-03-25 01:48:49',NULL),(2,2,1,20.00,NULL,'2026-03-25 01:52:11','2026-03-25 01:52:11','2026-03-25 01:52:11',NULL),(3,3,1,10.00,NULL,'2026-03-25 02:31:47','2026-03-25 02:31:47','2026-03-25 02:31:47',NULL),(4,4,1,30.00,NULL,'2026-03-25 02:50:08','2026-03-25 02:50:08','2026-03-25 02:50:08',NULL),(5,6,1,10.00,NULL,'2026-03-25 02:55:43','2026-03-25 02:55:43','2026-03-25 02:55:43',NULL),(6,7,1,20.00,NULL,'2026-03-25 03:05:22','2026-03-25 03:05:22','2026-03-25 03:05:22',NULL),(7,8,1,30.00,NULL,'2026-03-25 03:16:17','2026-03-25 03:16:17','2026-03-25 03:16:17',NULL),(8,9,1,20.00,NULL,'2026-03-25 03:20:53','2026-03-25 03:20:53','2026-03-25 03:20:53',NULL),(9,10,1,90.20,NULL,'2026-03-25 03:29:37','2026-03-25 03:29:37','2026-03-25 03:29:37',NULL),(10,11,1,72.00,NULL,'2026-03-27 15:45:40','2026-03-27 15:45:40','2026-03-27 15:45:40',NULL),(11,12,1,9.00,NULL,'2026-03-27 21:56:08','2026-03-27 21:56:08','2026-03-27 21:56:08',NULL),(12,13,1,79.00,NULL,'2026-03-30 15:36:39','2026-03-30 15:36:39','2026-03-30 15:36:39',NULL),(13,14,1,90.00,NULL,'2026-03-30 15:37:32','2026-03-30 15:37:32','2026-03-30 15:37:32',NULL),(14,15,1,179.30,NULL,'2026-03-30 20:16:57','2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(15,16,1,100.00,NULL,'2026-03-30 20:17:29','2026-03-30 20:17:29','2026-03-30 20:17:29',NULL),(16,18,1,14.00,NULL,'2026-03-30 20:22:48','2026-03-30 20:22:48','2026-03-30 20:22:48',NULL),(17,23,1,245.00,NULL,'2026-03-30 21:34:39','2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(18,24,1,40.00,NULL,'2026-03-30 21:38:47','2026-03-30 21:38:47','2026-03-30 21:38:47',NULL);
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
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',6,'flutter','b3015a780f873860ea43dc84f64277fb6342c14f3e05bf7bf9d71475dcbd7fd0','[\"*\"]','2026-03-20 19:42:04',NULL,'2026-03-17 02:37:43','2026-03-20 19:42:04'),(2,'App\\Models\\User',7,'flutter','f63d81782c3ab19c0e9f8a8e9495d87dc03afafdbfee271214d92fa3c9d68769','[\"*\"]','2026-03-25 00:43:43',NULL,'2026-03-25 00:25:42','2026-03-25 00:43:43'),(3,'App\\Models\\User',7,'flutter','c4f67dbf9a67842fc9f4434fe03b67e925fbb31712b0f96f551d64a0f7f7c43c','[\"*\"]','2026-03-25 01:43:56',NULL,'2026-03-25 00:43:56','2026-03-25 01:43:56'),(4,'App\\Models\\User',8,'flutter','1d6e9316d6ef6bc15877d3a23e9232f542846baf923a78f4e9f368cc71391baa','[\"*\"]','2026-03-25 02:23:51',NULL,'2026-03-25 01:45:51','2026-03-25 02:23:51'),(5,'App\\Models\\User',8,'flutter','4dcc7542b33383dc377ba1e8798bceb384923b01ffed2b775411742164230015','[\"*\"]','2026-03-31 01:22:13',NULL,'2026-03-25 02:26:42','2026-03-31 01:22:13');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plans`
--

LOCK TABLES `plans` WRITE;
/*!40000 ALTER TABLE `plans` DISABLE KEYS */;
INSERT INTO `plans` VALUES (1,'ELITE',90,1,1,1,'2026-03-20 02:29:16','2026-03-20 02:29:16',NULL),(2,'STARTER',30,1,1,1,'2026-03-20 02:29:30','2026-03-20 02:29:30',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `printing_services`
--

LOCK TABLES `printing_services` WRITE;
/*!40000 ALTER TABLE `printing_services` DISABLE KEYS */;
INSERT INTO `printing_services` VALUES (1,6,3,'BORNE PRINCIPALE','borne','kiosk',NULL,0,1,'2026-03-31 01:11:25','2026-03-31 01:11:25',NULL),(2,6,3,'POS','pos','receipt',NULL,0,1,'2026-03-31 01:11:39','2026-03-31 01:11:39',NULL),(3,6,3,'CUISINE','cuisine','kitchen',NULL,0,1,'2026-03-31 01:11:52','2026-03-31 01:11:52',NULL);
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
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ingredient_categories_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `ingredient_categories_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_option_categories`
--

LOCK TABLES `product_option_categories` WRITE;
/*!40000 ALTER TABLE `product_option_categories` DISABLE KEYS */;
INSERT INTO `product_option_categories` VALUES (1,'INGREDIENTS TACOS',1,'2026-03-25 01:21:38','2026-03-25 01:22:03',NULL,6);
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_option_product`
--

LOCK TABLES `product_option_product` WRITE;
/*!40000 ALTER TABLE `product_option_product` DISABLE KEYS */;
INSERT INTO `product_option_product` VALUES (1,2,1,1.00,'2026-03-18 01:10:16','2026-03-18 01:10:16'),(2,1,1,1.00,'2026-03-18 01:10:16','2026-03-18 01:10:16'),(3,6,2,1.00,'2026-03-25 01:26:35','2026-03-27 15:48:07'),(4,5,2,1.00,'2026-03-25 01:26:35','2026-03-27 15:48:07'),(5,3,2,1.00,'2026-03-25 01:26:35','2026-03-27 15:48:07');
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ingredients_manager_id_name_unique` (`manager_id`,`name`),
  KEY `ingredients_tenant_id_ingredient_category_id_index` (`product_option_category_id`),
  CONSTRAINT `ingredients_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `product_options_product_option_category_id_foreign` FOREIGN KEY (`product_option_category_id`) REFERENCES `product_option_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_options`
--

LOCK TABLES `product_options` WRITE;
/*!40000 ALTER TABLE `product_options` DISABLE KEYS */;
INSERT INTO `product_options` VALUES (1,NULL,'sucre','boolean',NULL,NULL,NULL,1,'2026-03-18 01:03:06','2026-03-25 23:12:37','2026-03-25 23:12:37',5),(2,NULL,'sel','boolean',NULL,NULL,NULL,1,'2026-03-18 01:03:25','2026-03-25 23:12:35','2026-03-25 23:12:35',5),(3,1,'SEL','boolean',NULL,NULL,'ingredients/sDeOLsAnrx9UZ0TH504bwJVK8GE1wqVgferfzZNO.png',1,'2026-03-25 01:24:45','2026-03-25 01:24:45',NULL,6),(4,NULL,'TOMATE','boolean',NULL,NULL,NULL,1,'2026-03-25 01:24:55','2026-03-25 01:25:15','2026-03-25 01:25:15',6),(5,1,'KETCH UP','boolean',NULL,NULL,'ingredients/LnS6zvOoIpFhgjnGHSewTJLe3KevwriiOVWBWGIo.png',1,'2026-03-25 01:25:12','2026-03-25 01:25:12',NULL,6),(6,1,'HOT','boolean',NULL,NULL,'ingredients/gx0aNBa37B42FPbd0QeVhVMiJ6klfbBHAArz9Nql.png',1,'2026-03-25 01:25:29','2026-03-25 01:25:29',NULL,6);
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_variants_uuid_unique` (`uuid`),
  UNIQUE KEY `product_variants_manager_id_sku_unique` (`manager_id`,`sku`),
  UNIQUE KEY `product_variants_manager_id_barcode_unique` (`manager_id`,`barcode`),
  KEY `product_variants_tenant_id_product_id_is_active_index` (`product_id`,`is_active`),
  CONSTRAINT `product_variants_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `product_variants_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
INSERT INTO `product_variants` VALUES (1,2,'80d7f5fb-4bb2-4cb5-bb24-d8abcf0acaa3','AVEC SAUCE',NULL,NULL,14.00,1,'2026-03-25 02:47:07','2026-03-25 02:47:07',NULL,6),(2,2,'7167805a-88c9-4259-88f2-5be58e0fe95c','AVEC FRITE',NULL,NULL,15.00,1,'2026-03-25 02:47:34','2026-03-25 02:47:34',NULL,6),(3,3,'31defd2c-17a8-412b-992f-6eb391457148','AVEC SAUCE',NULL,NULL,14.00,1,'2026-03-27 15:42:42','2026-03-27 15:42:42',NULL,6),(4,3,'371bf1f9-e084-4741-b81b-5e428f32e1f8','AVEC FRITE',NULL,NULL,15.00,1,'2026-03-27 15:42:42','2026-03-27 15:42:42',NULL,6),(5,4,'48c26497-5dbc-4521-80cc-f74c6f275f79','AVEC SAUCE',NULL,NULL,14.00,1,'2026-03-27 15:48:20','2026-03-27 15:49:13','2026-03-27 15:49:13',6),(6,4,'445dd0e1-35ea-4570-a7be-106a87439b74','AVEC FRITE',NULL,NULL,15.00,1,'2026-03-27 15:48:20','2026-03-27 15:49:16','2026-03-27 15:49:16',6);
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_uuid_unique` (`uuid`),
  UNIQUE KEY `products_manager_id_sku_unique` (`manager_id`,`sku`),
  UNIQUE KEY `products_manager_id_barcode_unique` (`manager_id`,`barcode`),
  KEY `products_category_id_foreign` (`category_id`),
  KEY `products_tenant_id_is_active_index` (`is_active`),
  KEY `products_tax_id_index` (`tax_id`),
  CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `products_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `products_tax_id_foreign` FOREIGN KEY (`tax_id`) REFERENCES `taxes` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,2,NULL,'a3dc6c62-91e2-42c5-893d-f91c8a96f3f9','THE','SKUUU','BARCOD','DESCRIPTION',NULL,'products/M8Ukh14oEn7GpXXkh7I2G1IOG5JOcz9xxK5M1HES.jpg',NULL,12.00,10.00,0,1,'2026-03-16 22:30:45','2026-03-24 01:27:48','2026-03-24 01:27:48',5),(2,5,2,'6b77c2f3-a3ea-4b6e-9b7a-3e9d8f0eab50','TACOS MIXTE','TACOS','TACOS',NULL,NULL,'products/G4TMgdgNJZQo0VaGR5OkIZ9bnpSvk5qBOCRxvoTS.png',NULL,10.00,7.00,0,1,'2026-03-25 01:26:35','2026-03-27 15:48:07',NULL,6),(3,5,2,'10cada76-a170-46fe-9636-db02c9c7ce6f','TACOS NORMAL',NULL,NULL,NULL,NULL,'products/g2baw3eplb8uk29u7WbCiMmXcyTkQQzAcnD8a26y.png',NULL,12.00,9.00,0,1,'2026-03-27 15:42:42','2026-03-27 15:49:50',NULL,6),(4,7,2,'a2b08aa6-45e5-4464-a6d5-e5e5db73f87f','JUS ORANGE',NULL,NULL,NULL,NULL,'products/91YZuzzbRUepDdywoAsqirj5OuSgOOoeb7oEMmIQ.jpg',NULL,12.00,9.00,0,1,'2026-03-27 15:48:20','2026-03-27 15:49:35',NULL,6),(5,7,NULL,'c4e1b053-9d56-4e31-b29c-3e43af4c09e8','JUS CITRON',NULL,NULL,NULL,NULL,'products/mjjEVfkSEuar4k5hyLiYRwlXEKqxun3sruuSwRVi.jpg',NULL,11.00,13.00,0,1,'2026-03-27 15:50:40','2026-03-27 15:52:11',NULL,6),(6,7,NULL,'98ce3f21-829a-4c2d-8960-77cb8d766d75','JUS FRAISE',NULL,NULL,NULL,NULL,'products/TVYEBOqiH7dFRI8DW15pfr2pH6rETrq5fmJ4KSWD.jpg',NULL,15.00,21.00,0,1,'2026-03-27 15:51:16','2026-03-27 16:00:16',NULL,6),(7,6,NULL,'bf3b85e7-cdf2-4cba-8ddb-60a1e762cc21','MAROCAINE',NULL,NULL,NULL,NULL,'products/UAQt6TwLd4sgoxYYyDF1tsz6k9Q8ZSx3Ss22zkAy.jpg',NULL,15.00,21.00,0,1,'2026-03-27 15:58:39','2026-03-27 16:00:03',NULL,6),(8,6,NULL,'77eb0a32-44a0-41f0-b5c0-a4dc48113a3c','NISOISE',NULL,NULL,NULL,NULL,'products/GoHwcawK2p5IsukD3ZH14esmapM5Op62WXuiFL5L.jpg',NULL,15.00,21.00,0,1,'2026-03-27 15:59:25','2026-03-27 15:59:44',NULL,6),(9,8,NULL,'102ae7a6-0e2e-4352-97ea-353c28ba86ca','MARGARITA',NULL,NULL,NULL,NULL,'products/hxg6S1OMfhQtnluFX2cg84ZJbeFpO28ebjlE8Lyk.jpg',NULL,14.00,22.00,0,1,'2026-03-27 16:01:09','2026-03-27 16:01:56',NULL,6),(10,8,NULL,'8c309ccf-97ff-425a-adc1-212264ae6621','CHESS',NULL,NULL,NULL,NULL,'products/JbVZUPP2RmpQWzj2m9onF4oQoj53xewmTEiugMAd.jpg',NULL,14.00,22.00,0,1,'2026-03-27 16:01:22','2026-03-27 16:01:44',NULL,6),(11,4,NULL,'8e2f8ca1-a665-4799-9acd-494dd3a48c22','NORMAL',NULL,NULL,NULL,NULL,'products/7nWpj8Tz5Rx4Uk5tGinR5XNRYX3Vw7MdVUiA9nJT.jpg',NULL,7.00,14.00,0,1,'2026-03-27 16:02:38','2026-03-27 16:02:38',NULL,6),(12,4,NULL,'51852f33-3430-4880-af7b-29481f634d61','CRÉME',NULL,NULL,NULL,NULL,'products/gGs2CvmjNcOFopn6DFJCVaJ0RPwA9seWY3j4MPgp.webp',NULL,9.00,11.00,0,1,'2026-03-27 16:03:05','2026-03-27 16:03:26',NULL,6);
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
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sale_items`
--

LOCK TABLES `sale_items` WRITE;
/*!40000 ALTER TABLE `sale_items` DISABLE KEYS */;
INSERT INTO `sale_items` VALUES (1,1,2,NULL,'TACOS MIXTE','TACOS',1.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',10.00,'2026-03-25 01:48:49','2026-03-25 01:48:49',NULL),(2,2,2,NULL,'TACOS MIXTE','TACOS',2.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',20.00,'2026-03-25 01:52:11','2026-03-25 01:52:11',NULL),(3,3,2,NULL,'TACOS MIXTE','TACOS',1.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',10.00,'2026-03-25 02:31:47','2026-03-25 02:31:47',NULL),(4,4,2,NULL,'TACOS MIXTE','TACOS',3.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',30.00,'2026-03-25 02:50:08','2026-03-25 02:50:08',NULL),(5,5,2,NULL,'TACOS MIXTE','TACOS',5.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',50.00,'2026-03-25 02:55:34','2026-03-25 02:55:34',NULL),(6,6,2,NULL,'TACOS MIXTE','TACOS',1.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',10.00,'2026-03-25 02:55:43','2026-03-25 02:55:43',NULL),(7,7,2,NULL,'TACOS MIXTE','TACOS',1.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',10.00,'2026-03-25 03:05:22','2026-03-25 03:05:22',NULL),(8,7,2,NULL,'TACOS MIXTE','TACOS',1.000,10.00,0.00,0.00,'[{\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',10.00,'2026-03-25 03:05:22','2026-03-25 03:05:22',NULL),(9,8,2,NULL,'TACOS MIXTE','TACOS',3.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',30.00,'2026-03-25 03:16:17','2026-03-25 03:16:17',NULL),(10,9,2,NULL,'TACOS MIXTE','TACOS',2.000,10.00,0.00,0.00,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',20.00,'2026-03-25 03:20:53','2026-03-25 03:20:53',NULL),(11,10,2,NULL,'TACOS MIXTE','TACOS',7.000,10.00,7.00,6.30,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 1}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 1}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 1}]',69.30,'2026-03-25 03:29:37','2026-03-25 03:29:37',NULL),(12,10,2,NULL,'TACOS MIXTE','TACOS',1.000,10.00,1.00,0.90,'[{\"id\": 3, \"name\": \"SEL\", \"quantity\": 0.5}, {\"id\": 5, \"name\": \"KETCH UP\", \"quantity\": 0.5}, {\"id\": 6, \"name\": \"HOT\", \"quantity\": 0.5}]',9.90,'2026-03-25 03:29:37','2026-03-25 03:29:37',NULL),(13,11,3,NULL,'TACOS NORMAL',NULL,6.000,12.00,0.00,0.00,NULL,72.00,'2026-03-27 15:45:40','2026-03-27 15:45:40',NULL),(14,12,12,NULL,'CRÉME',NULL,1.000,9.00,0.00,0.00,NULL,9.00,'2026-03-27 21:56:08','2026-03-27 21:56:08',NULL),(15,13,12,NULL,'CRÉME',NULL,1.000,9.00,0.00,0.00,NULL,9.00,'2026-03-30 15:36:39','2026-03-30 15:36:39',NULL),(16,13,11,NULL,'NORMAL',NULL,10.000,7.00,0.00,0.00,NULL,70.00,'2026-03-30 15:36:39','2026-03-30 15:36:39',NULL),(17,14,12,NULL,'CRÉME',NULL,10.000,9.00,0.00,0.00,NULL,90.00,'2026-03-30 15:37:32','2026-03-30 15:37:32',NULL),(18,15,12,NULL,'CRÉME',NULL,3.000,9.00,1.41,2.56,NULL,28.15,'2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(19,15,11,NULL,'NORMAL',NULL,3.000,7.00,1.10,1.99,NULL,21.89,'2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(20,15,10,NULL,'CHESS',NULL,3.000,14.00,2.20,3.98,NULL,43.78,'2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(21,15,9,NULL,'MARGARITA',NULL,2.000,14.00,1.47,2.65,NULL,29.19,'2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(22,15,8,NULL,'NISOISE',NULL,2.000,15.00,1.57,2.84,NULL,31.27,'2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(23,15,3,NULL,'TACOS NORMAL',NULL,1.000,12.00,0.63,1.14,NULL,12.51,'2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(24,15,4,NULL,'JUS ORANGE',NULL,1.000,12.00,0.63,1.14,NULL,12.51,'2026-03-30 20:16:57','2026-03-30 20:16:57',NULL),(25,16,11,NULL,'NORMAL',NULL,1.000,7.00,0.00,0.00,NULL,7.00,'2026-03-30 20:17:29','2026-03-30 20:17:29',NULL),(26,16,12,NULL,'CRÉME',NULL,1.000,9.00,0.00,0.00,NULL,9.00,'2026-03-30 20:17:29','2026-03-30 20:17:29',NULL),(27,16,10,NULL,'CHESS',NULL,2.000,14.00,0.00,0.00,NULL,28.00,'2026-03-30 20:17:29','2026-03-30 20:17:29',NULL),(28,16,9,NULL,'MARGARITA',NULL,4.000,14.00,0.00,0.00,NULL,56.00,'2026-03-30 20:17:29','2026-03-30 20:17:29',NULL),(29,17,8,NULL,'NISOISE',NULL,1.000,15.00,0.00,0.00,NULL,15.00,'2026-03-30 20:22:39','2026-03-30 20:22:39',NULL),(30,17,10,NULL,'CHESS',NULL,1.000,14.00,0.00,0.00,NULL,14.00,'2026-03-30 20:22:39','2026-03-30 20:22:39',NULL),(31,18,10,NULL,'CHESS',NULL,1.000,14.00,0.00,0.00,NULL,14.00,'2026-03-30 20:22:48','2026-03-30 20:22:48',NULL),(32,19,10,NULL,'CHESS',NULL,1.000,14.00,0.00,0.00,NULL,14.00,'2026-03-30 20:29:01','2026-03-30 20:29:01',NULL),(33,20,10,NULL,'CHESS',NULL,2.000,14.00,0.00,0.00,NULL,28.00,'2026-03-30 20:33:37','2026-03-30 20:33:37',NULL),(34,21,5,NULL,'JUS CITRON',NULL,1.000,11.00,0.00,0.00,NULL,11.00,'2026-03-30 20:34:27','2026-03-30 20:34:27',NULL),(35,22,7,NULL,'MAROCAINE',NULL,1.000,15.00,0.00,0.00,NULL,15.00,'2026-03-30 20:55:37','2026-03-30 20:55:37',NULL),(36,23,8,NULL,'NISOISE',NULL,3.000,15.00,0.00,0.00,NULL,45.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(37,23,9,NULL,'MARGARITA',NULL,2.000,14.00,0.00,0.00,NULL,28.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(38,23,10,NULL,'CHESS',NULL,6.000,14.00,0.00,0.00,NULL,84.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(39,23,11,NULL,'NORMAL',NULL,2.000,7.00,0.00,0.00,NULL,14.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(40,23,3,NULL,'TACOS NORMAL',NULL,1.000,12.00,0.00,0.00,NULL,12.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(41,23,4,NULL,'JUS ORANGE',NULL,1.000,12.00,0.00,0.00,NULL,12.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(42,23,5,NULL,'JUS CITRON',NULL,1.000,11.00,0.00,0.00,NULL,11.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(43,23,6,NULL,'JUS FRAISE',NULL,1.000,15.00,0.00,0.00,NULL,15.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(44,23,7,NULL,'MAROCAINE',NULL,1.000,15.00,0.00,0.00,NULL,15.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(45,23,12,NULL,'CRÉME',NULL,1.000,9.00,0.00,0.00,NULL,9.00,'2026-03-30 21:34:39','2026-03-30 21:34:39',NULL),(46,24,10,NULL,'CHESS',NULL,2.000,14.00,20.00,0.00,NULL,8.00,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(47,24,7,NULL,'MAROCAINE',NULL,1.000,15.00,10.71,0.00,NULL,4.29,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(48,24,8,NULL,'NISOISE',NULL,2.000,15.00,21.43,0.00,NULL,8.57,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(49,24,4,NULL,'JUS ORANGE',NULL,1.000,12.00,8.57,0.00,NULL,3.43,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(50,24,11,NULL,'NORMAL',NULL,1.000,7.00,5.00,0.00,NULL,2.00,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(51,24,12,NULL,'CRÉME',NULL,1.000,9.00,6.43,0.00,NULL,2.57,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(52,24,9,NULL,'MARGARITA',NULL,2.000,14.00,20.00,0.00,NULL,8.00,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(53,24,5,NULL,'JUS CITRON',NULL,1.000,11.00,7.86,0.00,NULL,3.14,'2026-03-30 21:38:47','2026-03-30 21:38:47',NULL),(54,25,2,NULL,'TACOS MIXTE','TACOS',20.000,10.00,0.00,0.00,NULL,200.00,'2026-03-30 21:44:21','2026-03-30 21:44:21',NULL),(55,25,4,NULL,'JUS ORANGE',NULL,1.000,12.00,0.00,0.00,NULL,12.00,'2026-03-30 21:44:21','2026-03-30 21:44:21',NULL),(56,26,12,NULL,'CRÉME',NULL,1.000,9.00,0.00,0.00,NULL,9.00,'2026-03-30 22:03:17','2026-03-30 22:03:17',NULL),(57,26,2,NULL,'TACOS MIXTE','TACOS',1.000,10.00,0.00,0.00,NULL,10.00,'2026-03-30 22:03:17','2026-03-30 22:03:17',NULL),(58,26,4,NULL,'JUS ORANGE',NULL,1.000,12.00,0.00,0.00,NULL,12.00,'2026-03-30 22:03:17','2026-03-30 22:03:17',NULL),(59,26,7,NULL,'MAROCAINE',NULL,2.000,15.00,0.00,0.00,NULL,30.00,'2026-03-30 22:03:17','2026-03-30 22:03:17',NULL),(60,26,6,NULL,'JUS FRAISE',NULL,1.000,15.00,0.00,0.00,NULL,15.00,'2026-03-30 22:03:17','2026-03-30 22:03:17',NULL),(61,26,3,NULL,'TACOS NORMAL',NULL,1.000,12.00,0.00,0.00,NULL,12.00,'2026-03-30 22:03:17','2026-03-30 22:03:17',NULL);
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sales_device_id_foreign` (`device_id`),
  KEY `sales_user_id_foreign` (`user_id`),
  KEY `sales_customer_id_foreign` (`customer_id`),
  KEY `sales_tenant_id_store_id_status_index` (`store_id`,`status`),
  KEY `sales_tenant_id_ordered_at_index` (`ordered_at`),
  KEY `sales_manager_id_foreign` (`manager_id`),
  CONSTRAINT `sales_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sales_device_id_foreign` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sales_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sales_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sales_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales`
--

LOCK TABLES `sales` WRITE;
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` VALUES (1,3,NULL,NULL,1,'S20260325024849NKCS','paid',10.00,0.00,0.00,10.00,'USD',NULL,0,0,0.00,'2026-03-25 01:48:49','2026-03-25 01:48:49','2026-03-25 01:48:49',NULL,6),(2,3,NULL,NULL,1,'S20260325025211JPL8','paid',20.00,0.00,0.00,20.00,'USD',NULL,0,0,0.00,'2026-03-25 01:52:11','2026-03-25 01:52:11','2026-03-25 01:52:11',NULL,6),(3,3,NULL,NULL,NULL,'S20260325033147FPQP','paid',10.00,0.00,0.00,10.00,'USD',NULL,0,0,0.00,'2026-03-25 02:31:47','2026-03-25 02:31:47','2026-03-25 02:31:47',NULL,6),(4,3,NULL,NULL,1,'S20260325035008CDHG','paid',30.00,0.00,0.00,30.00,'USD',NULL,0,0,0.00,'2026-03-25 02:50:08','2026-03-25 02:50:08','2026-03-25 02:50:08',NULL,6),(5,3,NULL,NULL,NULL,'S202603250355344JT7','unpaid',50.00,0.00,0.00,50.00,'USD',NULL,0,0,0.00,'2026-03-25 02:55:34','2026-03-25 02:55:34','2026-03-25 02:55:34',NULL,6),(6,3,NULL,NULL,NULL,'S20260325035543VBDD','paid',10.00,0.00,0.00,10.00,'USD',NULL,0,0,0.00,'2026-03-25 02:55:43','2026-03-25 02:55:43','2026-03-25 02:55:43',NULL,6),(7,3,NULL,NULL,NULL,'S20260325040522UNQA','paid',20.00,0.00,0.00,20.00,'USD',NULL,0,0,0.00,'2026-03-25 03:05:22','2026-03-25 03:05:22','2026-03-25 03:05:22',NULL,6),(8,3,NULL,NULL,NULL,'S20260325041617BXJC','paid',30.00,0.00,0.00,30.00,'USD',NULL,0,0,0.00,'2026-03-25 03:16:17','2026-03-25 03:16:17','2026-03-25 03:16:17',NULL,6),(9,3,NULL,NULL,NULL,'S20260325042053ZKPT','paid',20.00,0.00,0.00,20.00,'USD',NULL,0,0,0.00,'2026-03-25 03:20:53','2026-03-25 03:20:53','2026-03-25 03:20:53',NULL,6),(10,3,NULL,NULL,NULL,'S20260325042937S9FG','paid',80.00,8.00,7.20,79.20,'USD',NULL,0,0,0.00,'2026-03-25 03:29:37','2026-03-25 03:29:37','2026-03-25 03:29:37',NULL,6),(11,3,NULL,NULL,NULL,'S20260327164540CGHU','paid',72.00,0.00,0.00,72.00,'USD',NULL,0,0,0.00,'2026-03-27 15:45:40','2026-03-27 15:45:40','2026-03-27 15:45:40',NULL,6),(12,3,NULL,NULL,NULL,'S20260327225608DUII','paid',9.00,0.00,0.00,9.00,'USD',NULL,0,0,0.00,'2026-03-27 21:56:08','2026-03-27 21:56:08','2026-03-27 21:56:08',NULL,6),(13,3,NULL,NULL,1,'S20260330163639HMBP','paid',79.00,0.00,0.00,79.00,'USD',NULL,43,0,0.00,'2026-03-30 15:36:39','2026-03-30 15:36:39','2026-03-30 15:36:39',NULL,6),(14,3,NULL,NULL,1,'S20260330163732V3L0','paid',90.00,0.00,0.00,90.00,'USD',NULL,40,0,0.00,'2026-03-30 15:37:32','2026-03-30 15:37:32','2026-03-30 15:37:32',NULL,6),(15,3,NULL,NULL,1,'S20260330211657A3ZQ','paid',172.00,9.00,16.30,179.30,'USD',NULL,56,9,9.00,'2026-03-30 20:16:57','2026-03-30 20:16:57','2026-03-30 20:16:57',NULL,6),(16,3,NULL,NULL,1,'S20260330211729S6QX','paid',100.00,0.00,0.00,100.00,'USD',NULL,35,0,0.00,'2026-03-30 20:17:29','2026-03-30 20:17:29','2026-03-30 20:17:29',NULL,6),(17,3,NULL,NULL,NULL,'S20260330212239GPO6','unpaid',29.00,0.00,0.00,29.00,'USD','BORNE #1',0,0,0.00,'2026-03-30 20:22:39','2026-03-30 20:22:39','2026-03-30 20:22:39',NULL,6),(18,3,NULL,NULL,NULL,'S20260330212248BE50','paid',14.00,0.00,0.00,14.00,'USD','BORNE #2',0,0,0.00,'2026-03-30 20:22:48','2026-03-30 20:22:48','2026-03-30 20:22:48',NULL,6),(19,3,NULL,NULL,NULL,'S202603302129019M5C','unpaid',14.00,0.00,0.00,14.00,'USD','BORNE #3',0,0,0.00,'2026-03-30 20:29:01','2026-03-30 20:29:01','2026-03-30 20:29:01',NULL,6),(20,3,NULL,NULL,NULL,'S20260330213337BZ6H','unpaid',28.00,0.00,0.00,28.00,'USD','BORNE #4',0,0,0.00,'2026-03-30 20:33:37','2026-03-30 20:33:37','2026-03-30 20:33:37',NULL,6),(21,3,NULL,NULL,NULL,'S20260330213427AO1L','unpaid',11.00,0.00,0.00,11.00,'USD','BORNE #5',0,0,0.00,'2026-03-30 20:34:27','2026-03-30 20:34:27','2026-03-30 20:34:27',NULL,6),(22,3,NULL,NULL,NULL,'S20260330215537TES7','unpaid',15.00,0.00,0.00,15.00,'USD','BORNE #6 - CAISSE',0,0,0.00,'2026-03-30 20:55:37','2026-03-30 20:55:37','2026-03-30 20:55:37',NULL,6),(23,3,NULL,NULL,1,'S20260330223439IHCW','paid',245.00,0.00,0.00,245.00,'USD',NULL,69,0,0.00,'2026-03-30 21:34:39','2026-03-30 21:34:39','2026-03-30 21:34:39',NULL,6),(24,3,NULL,NULL,1,'S20260330223847ZEVZ','paid',140.00,100.00,0.00,40.00,'USD',NULL,43,0,0.00,'2026-03-30 21:38:47','2026-03-30 21:38:47','2026-03-30 21:38:47',NULL,6),(25,3,NULL,NULL,NULL,'S20260330224421CQSE','unpaid',212.00,0.00,0.00,212.00,'USD','BORNE #7 - CAISSE',0,0,0.00,'2026-03-30 21:44:21','2026-03-30 21:44:21','2026-03-30 21:44:21',NULL,6),(26,3,NULL,NULL,NULL,'S20260330230317SCUA','unpaid',88.00,0.00,0.00,88.00,'USD','BORNE #8 - CAISSE',0,0,0.00,'2026-03-30 22:03:17','2026-03-30 22:03:17','2026-03-30 22:03:17',NULL,6);
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
INSERT INTO `sessions` VALUES ('asI5Gxo21yhSNizl3muI55UYVW8sWucWFYlVNhWq',8,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:149.0) Gecko/20100101 Firefox/149.0','YTo2OntzOjY6Il90b2tlbiI7czo0MDoiNU1IVTBDSm1NOTVscXV1YUw1SjZYZWZiQXVkSURNWkdvR2xuM2x1dSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo0OiJsYW5nIjtzOjI6ImVuIjtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czo0NzoiaHR0cDovLzEyNy4wLjAuMTo4MDAwL21hbmFnZXIvcHJpbnRpbmctc2VydmljZXMiO3M6NToicm91dGUiO3M6MzE6Im1hbmFnZXIucHJpbnRpbmdfc2VydmljZXMuaW5kZXgiO31zOjM6InVybCI7YTowOnt9czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6ODt9',1775161959),('GcdSdBVisU3a0po2DDisz0ctNjnnVhWA6TGkIgLZ',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:150.0) Gecko/20100101 Firefox/150.0','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiZDI3N2l3RHF5Nm9TVEtYUTRsQnhmajhyWXZ6Q3BxS09xSlFMcllHbyI7czo0OiJsYW5nIjtzOjI6ImVuIjtzOjk6Il9wcmV2aW91cyI7YToyOntzOjM6InVybCI7czoyNzoiaHR0cDovLzEyNy4wLjAuMTo4MDAwL2xvZ2luIjtzOjU6InJvdXRlIjtzOjU6ImxvZ2luIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czozOiJ1cmwiO2E6MTp7czo4OiJpbnRlbmRlZCI7czoyNzoiaHR0cDovLzEyNy4wLjAuMTo4MDAwL2FkbWluIjt9fQ==',1777334954);
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_methods`
--

LOCK TABLES `shipping_methods` WRITE;
/*!40000 ALTER TABLE `shipping_methods` DISABLE KEYS */;
INSERT INTO `shipping_methods` VALUES (1,6,'GRATUIT','free',0.00,1,'2026-03-30 21:36:37','2026-03-30 21:36:37'),(2,6,'LIVREUR','order_percent',3.00,1,'2026-03-30 21:37:11','2026-03-30 21:37:11'),(3,6,'PAR ARTICLE','per_item',2.00,1,'2026-03-30 21:37:37','2026-03-30 21:37:37'),(4,6,'MANUEL','manual',0.00,1,'2026-03-30 21:37:51','2026-03-30 21:37:51');
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `stock_movements_store_id_foreign` (`store_id`),
  KEY `stock_movements_user_id_foreign` (`user_id`),
  KEY `stock_movements_tenant_id_product_id_type_index` (`product_id`,`type`),
  KEY `stock_movements_manager_id_foreign` (`manager_id`),
  CONSTRAINT `stock_movements_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
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
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stores_manager_id_code_unique` (`manager_id`,`code`),
  KEY `stores_tenant_id_is_active_index` (`is_active`),
  KEY `stores_tenant_id_currency_id_index` (`currency_id`),
  CONSTRAINT `stores_currency_id_foreign` FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`) ON DELETE SET NULL,
  CONSTRAINT `stores_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stores`
--

LOCK TABLES `stores` WRITE;
/*!40000 ALTER TABLE `stores` DISABLE KEYS */;
INSERT INTO `stores` VALUES (1,'restaurant 1','restaurant 1','0633337723','resto1@pos.com','adresse',NULL,1,1,'2026-03-16 22:27:25','2026-03-25 01:10:48','2026-03-25 01:10:48',1,1,1,5),(2,'TACOS LYON','TACOSLYON','0600000000','tacos@kinpos.com','adresse','stores/0tCXEQAJIhnTV9ioxynS1EXLXZpv0bmeQ7sftJaV.png',1,1,'2026-03-25 00:40:39','2026-03-25 01:10:46','2026-03-25 01:10:46',2,1,1,1),(3,'TACOS LYON',NULL,NULL,NULL,NULL,'stores/WUF4B4lD58ru7gLpfmjc1u9jhwsHqslnAxc9s4hZ.png',1,1,'2026-03-25 01:13:44','2026-03-25 01:27:35',NULL,1,1,1,6),(4,'lookwino',NULL,NULL,NULL,NULL,NULL,1,1,'2026-04-02 19:22:08','2026-04-02 19:22:08',NULL,1,1,1,7);
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
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rate` decimal(7,4) NOT NULL DEFAULT '0.0000',
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'percent',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taxes_manager_id_name_unique` (`manager_id`,`name`),
  CONSTRAINT `taxes_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxes`
--

LOCK TABLES `taxes` WRITE;
/*!40000 ALTER TABLE `taxes` DISABLE KEYS */;
INSERT INTO `taxes` VALUES (1,'normal',20.0000,'percent',1,'2026-03-19 23:27:36','2026-03-25 23:12:49','2026-03-25 23:12:49',2),(2,'normal',20.0000,'percent',1,'2026-03-25 01:22:25','2026-03-25 01:22:25',NULL,6);
/*!40000 ALTER TABLE `taxes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenants`
--

DROP TABLE IF EXISTS `tenants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenants` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `max_stores` int unsigned DEFAULT NULL,
  `max_devices` int unsigned DEFAULT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `timezone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `plan_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plan_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tenants_slug_unique` (`slug`),
  KEY `tenants_plan_id_index` (`plan_id`),
  CONSTRAINT `tenants_plan_id_foreign` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenants`
--

LOCK TABLES `tenants` WRITE;
/*!40000 ALTER TABLE `tenants` DISABLE KEYS */;
INSERT INTO `tenants` VALUES (1,'macdo','macdo',1,3,3,'USD','UTC','plan a',NULL,'2026-03-14 03:01:56','2026-03-14 03:01:56',NULL),(2,'Tenant 1','tenant-1',1,5,10,'USD','UTC',NULL,NULL,'2026-03-14 03:15:34','2026-03-14 03:15:34',NULL),(3,'tacos','tacos',1,1,1,'USD','UTC','plan A',NULL,'2026-03-14 03:26:26','2026-03-16 21:23:26',NULL),(4,'pizzeria','pizzeria',1,1,1,'USD','UTC','plan a',NULL,'2026-03-16 21:27:14','2026-03-16 21:27:14',NULL),(5,'RESTAURANT','RESTAURANT',1,1,1,'USD','UTC','plan a',NULL,'2026-03-16 22:23:30','2026-03-16 22:23:30',NULL);
/*!40000 ALTER TABLE `tenants` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=379 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `translations`
--

LOCK TABLES `translations` WRITE;
/*!40000 ALTER TABLE `translations` DISABLE KEYS */;
INSERT INTO `translations` VALUES (1,1,'saas','Dashboard','Dashboard','2026-03-26 00:12:33','2026-03-26 00:12:33'),(2,1,'saas','Quick overview of your SaaS.','Quick overview of your SaaS.','2026-03-26 00:12:33','2026-03-26 00:12:33'),(3,1,'saas','Managers','Managers','2026-03-26 00:12:33','2026-03-26 00:12:33'),(4,1,'saas','Plans','Plans','2026-03-26 00:12:33','2026-03-26 00:12:33'),(5,1,'saas','Subscriptions','Subscriptions','2026-03-26 00:12:33','2026-03-26 00:12:33'),(6,1,'saas','Stores','Stores','2026-03-26 00:12:33','2026-03-26 00:12:33'),(7,1,'saas','Devices','Devices','2026-03-26 00:12:33','2026-03-26 00:12:33'),(8,1,'saas','Payment Methods','Payment Methods','2026-03-26 00:12:33','2026-03-26 00:12:33'),(9,1,'saas','Currencies','Currencies','2026-03-26 00:12:33','2026-03-26 00:12:33'),(10,1,'saas','Categories','Categories','2026-03-26 00:12:33','2026-03-26 00:12:33'),(11,1,'saas','Product Option Categories','Product Option Categories','2026-03-26 00:12:33','2026-03-26 00:12:33'),(12,1,'saas','Product Options','Product Options','2026-03-26 00:12:33','2026-03-26 00:12:33'),(13,1,'saas','Products','Products','2026-03-26 00:12:33','2026-03-26 00:12:33'),(14,1,'saas','Customers','Customers','2026-03-26 00:12:33','2026-03-26 00:12:33'),(15,1,'saas','Taxes','Taxes','2026-03-26 00:12:33','2026-03-26 00:12:33'),(16,1,'saas','Discounts','Discounts','2026-03-26 00:12:33','2026-03-26 00:12:33'),(17,1,'saas','Roles','Roles','2026-03-26 00:12:33','2026-03-26 00:12:33'),(18,1,'saas','Permissions','Permissions','2026-03-26 00:12:33','2026-03-26 00:12:33'),(19,1,'saas','Printing','Printing','2026-03-26 00:12:33','2026-03-26 00:12:33'),(20,1,'saas','Open','Open','2026-03-26 00:12:33','2026-03-26 00:12:33'),(21,1,'saas','Reports','Reports','2026-03-26 00:12:33','2026-03-26 00:12:33'),(22,1,'saas','Languages','Languages','2026-03-26 00:12:33','2026-03-26 00:12:33'),(23,1,'saas','Translations','Translations','2026-03-26 00:12:33','2026-03-26 00:12:33'),(24,1,'saas','Shipping','Shipping','2026-03-26 00:12:33','2026-03-26 00:12:33'),(25,1,'saas','POS SaaS Admin','POS SaaS Admin','2026-03-26 00:12:33','2026-03-26 00:12:33'),(26,1,'saas','SaaS Menu','SaaS Menu','2026-03-26 00:12:33','2026-03-26 00:12:33'),(27,1,'saas','Manager Menu','Manager Menu','2026-03-26 00:12:33','2026-03-26 00:12:33'),(28,1,'saas','Dark','Dark','2026-03-26 00:12:33','2026-03-26 00:12:33'),(29,1,'saas','Logout','Logout','2026-03-26 00:12:33','2026-03-26 00:12:33'),(30,1,'saas','Manage manager subscriptions and device limits.','Manage manager subscriptions and device limits.','2026-03-26 00:12:57','2026-03-26 00:12:57'),(31,1,'saas','New Subscription','New Subscription','2026-03-26 00:12:57','2026-03-26 00:12:57'),(32,1,'saas','Filter by Manager','Filter by Manager','2026-03-26 00:12:57','2026-03-26 00:12:57'),(33,1,'saas','All Managers','All Managers','2026-03-26 00:12:57','2026-03-26 00:12:57'),(34,1,'saas','Status','Status','2026-03-26 00:12:57','2026-03-26 00:12:57'),(35,1,'saas','All','All','2026-03-26 00:12:57','2026-03-26 00:12:57'),(36,1,'saas','Active','Active','2026-03-26 00:12:57','2026-03-26 00:12:57'),(37,1,'saas','Paused','Paused','2026-03-26 00:12:57','2026-03-26 00:12:57'),(38,1,'saas','Canceled','Canceled','2026-03-26 00:12:57','2026-03-26 00:12:57'),(39,1,'saas','Expired','Expired','2026-03-26 00:12:57','2026-03-26 00:12:57'),(40,1,'saas','Filter','Filter','2026-03-26 00:12:57','2026-03-26 00:12:57'),(41,1,'saas','Manager','Manager','2026-03-26 00:12:57','2026-03-26 00:12:57'),(42,1,'saas','Plan','Plan','2026-03-26 00:12:57','2026-03-26 00:12:57'),(43,1,'saas','Period','Period','2026-03-26 00:12:57','2026-03-26 00:12:57'),(44,1,'saas','Days Left','Days Left','2026-03-26 00:12:57','2026-03-26 00:12:57'),(45,1,'saas','Actions','Actions','2026-03-26 00:12:57','2026-03-26 00:12:57'),(46,1,'saas','Manage subscription plans.','Manage subscription plans.','2026-03-26 00:12:58','2026-03-26 00:12:58'),(47,1,'saas','New Plan','New Plan','2026-03-26 00:12:58','2026-03-26 00:12:58'),(48,1,'saas','Name','Name','2026-03-26 00:12:58','2026-03-26 00:12:58'),(49,1,'saas','Duration (days)','Duration (days)','2026-03-26 00:12:58','2026-03-26 00:12:58'),(50,1,'saas','Max Stores','Max Stores','2026-03-26 00:12:59','2026-03-26 00:12:59'),(51,1,'saas','Max Devices','Max Devices','2026-03-26 00:12:59','2026-03-26 00:12:59'),(52,1,'saas','Edit','Edit','2026-03-26 00:12:59','2026-03-26 00:12:59'),(53,1,'saas','Delete','Delete','2026-03-26 00:12:59','2026-03-26 00:12:59'),(54,1,'saas','Manage companies and limits.','Manage companies and limits.','2026-03-26 00:13:00','2026-03-26 00:13:00'),(55,1,'saas','New Manager','New Manager','2026-03-26 00:13:00','2026-03-26 00:13:00'),(56,1,'saas','Profile','Profile','2026-03-26 00:13:00','2026-03-26 00:13:00'),(57,1,'saas','Username','Username','2026-03-26 00:13:00','2026-03-26 00:13:00'),(58,1,'saas','Expires In','Expires In','2026-03-26 00:13:00','2026-03-26 00:13:00'),(59,1,'saas','days','days','2026-03-26 00:13:00','2026-03-26 00:13:00'),(60,1,'saas','Delete this manager?','Delete this manager?','2026-03-26 00:13:00','2026-03-26 00:13:00'),(61,1,'saas','Manage manager stores.','Manage manager stores.','2026-03-26 00:13:13','2026-03-26 00:13:13'),(62,1,'saas','New Store','New Store','2026-03-26 00:13:13','2026-03-26 00:13:13'),(63,1,'saas','Code','Code','2026-03-26 00:13:13','2026-03-26 00:13:13'),(64,1,'saas','Stock','Stock','2026-03-26 00:13:13','2026-03-26 00:13:13'),(65,1,'saas','Delete this store?','Delete this store?','2026-03-26 00:13:13','2026-03-26 00:13:13'),(66,1,'saas','Manage POS and kiosk devices.','Manage POS and kiosk devices.','2026-03-26 00:13:16','2026-03-26 00:13:16'),(67,1,'saas','New Device','New Device','2026-03-26 00:13:16','2026-03-26 00:13:16'),(68,1,'saas','Store','Store','2026-03-26 00:13:16','2026-03-26 00:13:16'),(69,1,'saas','Type','Type','2026-03-26 00:13:16','2026-03-26 00:13:16'),(70,1,'saas','Platform','Platform','2026-03-26 00:13:16','2026-03-26 00:13:16'),(71,1,'saas','Manage cash and other payment types.','Manage cash and other payment types.','2026-03-26 00:13:17','2026-03-26 00:13:17'),(72,1,'saas','New Method','New Method','2026-03-26 00:13:17','2026-03-26 00:13:17'),(73,1,'saas','Scope','Scope','2026-03-26 00:13:17','2026-03-26 00:13:17'),(74,1,'saas','Default','Default','2026-03-26 00:13:17','2026-03-26 00:13:17'),(75,1,'saas','Delete this payment method?','Delete this payment method?','2026-03-26 00:13:17','2026-03-26 00:13:17'),(76,1,'saas','Manage available currencies.','Manage available currencies.','2026-03-26 00:13:18','2026-03-26 00:13:18'),(77,1,'saas','New Currency','New Currency','2026-03-26 00:13:18','2026-03-26 00:13:18'),(78,1,'saas','Symbol','Symbol','2026-03-26 00:13:18','2026-03-26 00:13:18'),(79,1,'saas','Delete this currency?','Delete this currency?','2026-03-26 00:13:18','2026-03-26 00:13:18'),(80,1,'saas','Manage available languages.','Manage available languages.','2026-03-26 00:13:19','2026-03-26 00:13:19'),(81,1,'saas','New Language','New Language','2026-03-26 00:13:19','2026-03-26 00:13:19'),(82,1,'saas','Native','Native','2026-03-26 00:13:19','2026-03-26 00:13:19'),(83,1,'saas','Direction','Direction','2026-03-26 00:13:20','2026-03-26 00:13:20'),(84,1,'saas','Manage UI text for SaaS and Flutter.','Manage UI text for SaaS and Flutter.','2026-03-26 00:13:21','2026-03-26 00:13:21'),(85,1,'saas','New Translation','New Translation','2026-03-26 00:13:21','2026-03-26 00:13:21'),(86,1,'saas','Language','Language','2026-03-26 00:13:21','2026-03-26 00:13:21'),(87,1,'saas','All Languages','All Languages','2026-03-26 00:13:21','2026-03-26 00:13:21'),(88,1,'saas','SaaS','SaaS','2026-03-26 00:13:21','2026-03-26 00:13:21'),(89,1,'saas','Flutter','Flutter','2026-03-26 00:13:21','2026-03-26 00:13:21'),(90,1,'saas','Search','Search','2026-03-26 00:13:21','2026-03-26 00:13:21'),(91,1,'saas','Key or value','Key or value','2026-03-26 00:13:21','2026-03-26 00:13:21'),(92,1,'saas','Key','Key','2026-03-26 00:13:21','2026-03-26 00:13:21'),(93,1,'saas','Value','Value','2026-03-26 00:13:21','2026-03-26 00:13:21'),(94,1,'saas','en','en','2026-03-26 00:14:00','2026-03-26 00:14:00'),(95,1,'saas','English','English','2026-03-26 00:14:00','2026-03-26 00:14:00'),(96,1,'saas','Native Name','Native Name','2026-03-26 00:14:00','2026-03-26 00:14:00'),(97,1,'saas','LTR','LTR','2026-03-26 00:14:00','2026-03-26 00:14:00'),(98,1,'saas','RTL','RTL','2026-03-26 00:14:00','2026-03-26 00:14:00'),(99,1,'saas','Yes','Yes','2026-03-26 00:14:00','2026-03-26 00:14:00'),(100,1,'saas','No','No','2026-03-26 00:14:00','2026-03-26 00:14:00'),(101,1,'saas','Create Language','Create Language','2026-03-26 00:14:00','2026-03-26 00:14:00'),(102,1,'saas','Cancel','Cancel','2026-03-26 00:14:00','2026-03-26 00:14:00'),(103,1,'saas','Edit Language','Edit Language','2026-03-26 00:14:27','2026-03-26 00:14:27'),(104,2,'saas','Edit Language','Edit Language','2026-03-26 00:14:27','2026-03-26 00:14:27'),(105,1,'saas','Save','Save','2026-03-26 00:14:27','2026-03-26 00:14:27'),(106,2,'saas','Save','Save','2026-03-26 00:14:27','2026-03-26 00:14:27'),(107,1,'saas','Email','Email','2026-03-26 00:19:57','2026-03-26 00:19:57'),(108,2,'saas','Email','Email','2026-03-26 00:19:57','2026-03-26 00:19:57'),(109,1,'saas','false])','false])','2026-03-26 00:19:57','2026-03-26 00:19:57'),(110,2,'saas','false])','false])','2026-03-26 00:19:57','2026-03-26 00:19:57'),(111,1,'saas','Password','Password','2026-03-26 00:19:57','2026-03-26 00:19:57'),(112,2,'saas','Password','Password','2026-03-26 00:19:57','2026-03-26 00:19:57'),(113,1,'saas','Remember me','Remember me','2026-03-26 00:19:57','2026-03-26 00:19:57'),(114,2,'saas','Remember me','Remember me','2026-03-26 00:19:57','2026-03-26 00:19:57'),(115,1,'saas','Forgot your password?','Forgot your password?','2026-03-26 00:19:57','2026-03-26 00:19:57'),(116,2,'saas','Forgot your password?','Forgot your password?','2026-03-26 00:19:57','2026-03-26 00:19:57'),(117,1,'saas','Log in','Log in','2026-03-26 00:19:57','2026-03-26 00:19:57'),(118,2,'saas','Log in','Log in','2026-03-26 00:19:57','2026-03-26 00:19:57'),(119,1,'saas','Overview for your manager.','Overview for your manager.','2026-03-26 00:20:04','2026-03-26 00:20:04'),(120,2,'saas','Overview for your manager.','Overview for your manager.','2026-03-26 00:20:04','2026-03-26 00:20:04'),(121,1,'saas','Sales','Sales','2026-03-26 00:20:04','2026-03-26 00:20:04'),(122,2,'saas','Sales','Sales','2026-03-26 00:20:04','2026-03-26 00:20:04'),(123,1,'saas','Manager Portal','Manager Portal','2026-03-26 00:20:04','2026-03-26 00:20:04'),(124,2,'saas','Manager Portal','Manager Portal','2026-03-26 00:20:04','2026-03-26 00:20:04'),(125,1,'saas','Manage your product categories.','Manage your product categories.','2026-03-26 00:20:09','2026-03-26 00:20:09'),(126,2,'saas','Manage your product categories.','Manage your product categories.','2026-03-26 00:20:09','2026-03-26 00:20:09'),(127,1,'saas','New Category','New Category','2026-03-26 00:20:09','2026-03-26 00:20:09'),(128,2,'saas','New Category','New Category','2026-03-26 00:20:09','2026-03-26 00:20:09'),(129,1,'saas','Parent','Parent','2026-03-26 00:20:09','2026-03-26 00:20:09'),(130,2,'saas','Parent','Parent','2026-03-26 00:20:09','2026-03-26 00:20:09'),(131,1,'saas','Duplicate','Duplicate','2026-03-26 00:20:09','2026-03-26 00:20:09'),(132,2,'saas','Duplicate','Duplicate','2026-03-26 00:20:09','2026-03-26 00:20:09'),(133,1,'saas','Option Categories','Option Categories','2026-03-26 00:20:11','2026-03-26 00:20:11'),(134,2,'saas','Option Categories','Option Categories','2026-03-26 00:20:11','2026-03-26 00:20:11'),(135,1,'saas','Manage your product option categories.','Manage your product option categories.','2026-03-26 00:20:11','2026-03-26 00:20:11'),(136,2,'saas','Manage your product option categories.','Manage your product option categories.','2026-03-26 00:20:11','2026-03-26 00:20:11'),(137,1,'saas','New Option Category','New Option Category','2026-03-26 00:20:11','2026-03-26 00:20:11'),(138,2,'saas','New Option Category','New Option Category','2026-03-26 00:20:11','2026-03-26 00:20:11'),(139,1,'saas','Manage product options.','Manage product options.','2026-03-26 00:20:12','2026-03-26 00:20:12'),(140,2,'saas','Manage product options.','Manage product options.','2026-03-26 00:20:12','2026-03-26 00:20:12'),(141,1,'saas','New Option','New Option','2026-03-26 00:20:12','2026-03-26 00:20:12'),(142,2,'saas','New Option','New Option','2026-03-26 00:20:12','2026-03-26 00:20:12'),(143,1,'saas','Manage your products.','Manage your products.','2026-03-26 00:20:14','2026-03-26 00:20:14'),(144,2,'saas','Manage your products.','Manage your products.','2026-03-26 00:20:14','2026-03-26 00:20:14'),(145,1,'saas','Import Products','Import Products','2026-03-26 00:20:14','2026-03-26 00:20:14'),(146,2,'saas','Import Products','Import Products','2026-03-26 00:20:14','2026-03-26 00:20:14'),(147,1,'saas','New Product','New Product','2026-03-26 00:20:14','2026-03-26 00:20:14'),(148,2,'saas','New Product','New Product','2026-03-26 00:20:14','2026-03-26 00:20:14'),(149,1,'saas','Picture','Picture','2026-03-26 00:20:14','2026-03-26 00:20:14'),(150,2,'saas','Picture','Picture','2026-03-26 00:20:14','2026-03-26 00:20:14'),(151,1,'saas','SKU','SKU','2026-03-26 00:20:14','2026-03-26 00:20:14'),(152,2,'saas','SKU','SKU','2026-03-26 00:20:14','2026-03-26 00:20:14'),(153,1,'saas','Price','Price','2026-03-26 00:20:14','2026-03-26 00:20:14'),(154,2,'saas','Price','Price','2026-03-26 00:20:14','2026-03-26 00:20:14'),(155,1,'saas','Stock Management','Stock Management','2026-03-26 00:20:16','2026-03-26 00:20:16'),(156,2,'saas','Stock Management','Stock Management','2026-03-26 00:20:16','2026-03-26 00:20:16'),(157,1,'saas','Store Stock','Store Stock','2026-03-26 00:20:16','2026-03-26 00:20:16'),(158,2,'saas','Store Stock','Store Stock','2026-03-26 00:20:16','2026-03-26 00:20:16'),(159,1,'saas','Stock Enabled','Stock Enabled','2026-03-26 00:20:16','2026-03-26 00:20:16'),(160,2,'saas','Stock Enabled','Stock Enabled','2026-03-26 00:20:16','2026-03-26 00:20:16'),(161,1,'saas','Product Stock','Product Stock','2026-03-26 00:20:16','2026-03-26 00:20:16'),(162,2,'saas','Product Stock','Product Stock','2026-03-26 00:20:16','2026-03-26 00:20:16'),(163,1,'saas','Product','Product','2026-03-26 00:20:16','2026-03-26 00:20:16'),(164,2,'saas','Product','Product','2026-03-26 00:20:16','2026-03-26 00:20:16'),(165,1,'saas','Track Stock','Track Stock','2026-03-26 00:20:16','2026-03-26 00:20:16'),(166,2,'saas','Track Stock','Track Stock','2026-03-26 00:20:16','2026-03-26 00:20:16'),(167,1,'saas','Manage your customers.','Manage your customers.','2026-03-26 00:20:18','2026-03-26 00:20:18'),(168,2,'saas','Manage your customers.','Manage your customers.','2026-03-26 00:20:18','2026-03-26 00:20:18'),(169,1,'saas','New Customer','New Customer','2026-03-26 00:20:18','2026-03-26 00:20:18'),(170,2,'saas','New Customer','New Customer','2026-03-26 00:20:18','2026-03-26 00:20:18'),(171,1,'saas','Phone','Phone','2026-03-26 00:20:18','2026-03-26 00:20:18'),(172,2,'saas','Phone','Phone','2026-03-26 00:20:18','2026-03-26 00:20:18'),(173,1,'saas','Manage your taxes.','Manage your taxes.','2026-03-26 00:20:19','2026-03-26 00:20:19'),(174,2,'saas','Manage your taxes.','Manage your taxes.','2026-03-26 00:20:19','2026-03-26 00:20:19'),(175,1,'saas','New Tax','New Tax','2026-03-26 00:20:19','2026-03-26 00:20:19'),(176,2,'saas','New Tax','New Tax','2026-03-26 00:20:19','2026-03-26 00:20:19'),(177,1,'saas','Rate','Rate','2026-03-26 00:20:19','2026-03-26 00:20:19'),(178,2,'saas','Rate','Rate','2026-03-26 00:20:19','2026-03-26 00:20:19'),(179,1,'saas','Manage your discounts.','Manage your discounts.','2026-03-26 00:20:20','2026-03-26 00:20:20'),(180,2,'saas','Manage your discounts.','Manage your discounts.','2026-03-26 00:20:20','2026-03-26 00:20:20'),(181,1,'saas','New Discount','New Discount','2026-03-26 00:20:20','2026-03-26 00:20:20'),(182,2,'saas','New Discount','New Discount','2026-03-26 00:20:20','2026-03-26 00:20:20'),(183,1,'saas','Recent sales.','Recent sales.','2026-03-26 00:20:21','2026-03-26 00:20:21'),(184,2,'saas','Recent sales.','Recent sales.','2026-03-26 00:20:21','2026-03-26 00:20:21'),(185,1,'saas','Subtotal','Subtotal','2026-03-26 00:20:21','2026-03-26 00:20:21'),(186,2,'saas','Subtotal','Subtotal','2026-03-26 00:20:21','2026-03-26 00:20:21'),(187,1,'saas','Tax','Tax','2026-03-26 00:20:21','2026-03-26 00:20:21'),(188,2,'saas','Tax','Tax','2026-03-26 00:20:21','2026-03-26 00:20:21'),(189,1,'saas','Total','Total','2026-03-26 00:20:21','2026-03-26 00:20:21'),(190,2,'saas','Total','Total','2026-03-26 00:20:21','2026-03-26 00:20:21'),(191,1,'saas','Ordered At','Ordered At','2026-03-26 00:20:21','2026-03-26 00:20:21'),(192,2,'saas','Ordered At','Ordered At','2026-03-26 00:20:21','2026-03-26 00:20:21'),(193,1,'saas','View','View','2026-03-26 00:20:21','2026-03-26 00:20:21'),(194,2,'saas','View','View','2026-03-26 00:20:21','2026-03-26 00:20:21'),(195,1,'saas','Summary','Summary','2026-03-26 00:20:27','2026-03-26 00:20:27'),(196,2,'saas','Summary','Summary','2026-03-26 00:20:27','2026-03-26 00:20:27'),(197,1,'saas','Payments','Payments','2026-03-26 00:20:27','2026-03-26 00:20:27'),(198,2,'saas','Payments','Payments','2026-03-26 00:20:27','2026-03-26 00:20:27'),(199,1,'saas','Method','Method','2026-03-26 00:20:27','2026-03-26 00:20:27'),(200,2,'saas','Method','Method','2026-03-26 00:20:27','2026-03-26 00:20:27'),(201,1,'saas','Amount','Amount','2026-03-26 00:20:27','2026-03-26 00:20:27'),(202,2,'saas','Amount','Amount','2026-03-26 00:20:27','2026-03-26 00:20:27'),(203,1,'saas','Paid At','Paid At','2026-03-26 00:20:27','2026-03-26 00:20:27'),(204,2,'saas','Paid At','Paid At','2026-03-26 00:20:27','2026-03-26 00:20:27'),(205,1,'saas','Items','Items','2026-03-26 00:20:27','2026-03-26 00:20:27'),(206,2,'saas','Items','Items','2026-03-26 00:20:27','2026-03-26 00:20:27'),(207,1,'saas','Qty','Qty','2026-03-26 00:20:27','2026-03-26 00:20:27'),(208,2,'saas','Qty','Qty','2026-03-26 00:20:27','2026-03-26 00:20:27'),(209,1,'saas','Unit Price','Unit Price','2026-03-26 00:20:27','2026-03-26 00:20:27'),(210,2,'saas','Unit Price','Unit Price','2026-03-26 00:20:27','2026-03-26 00:20:27'),(211,1,'saas','Manage your stores.','Manage your stores.','2026-03-26 00:20:34','2026-03-26 00:20:34'),(212,2,'saas','Manage your stores.','Manage your stores.','2026-03-26 00:20:34','2026-03-26 00:20:34'),(213,1,'saas','Edit Tax','Edit Tax','2026-03-26 00:20:59','2026-03-26 00:20:59'),(214,2,'saas','Edit Tax','Edit Tax','2026-03-26 00:20:59','2026-03-26 00:20:59'),(215,1,'saas','Users','Users','2026-03-26 00:21:11','2026-03-26 00:21:11'),(216,2,'saas','Users','Users','2026-03-26 00:21:11','2026-03-26 00:21:11'),(217,1,'saas','Manage manager users and roles.','Manage manager users and roles.','2026-03-26 00:21:11','2026-03-26 00:21:11'),(218,2,'saas','Manage manager users and roles.','Manage manager users and roles.','2026-03-26 00:21:11','2026-03-26 00:21:11'),(219,1,'saas','New User','New User','2026-03-26 00:21:11','2026-03-26 00:21:11'),(220,2,'saas','New User','New User','2026-03-26 00:21:11','2026-03-26 00:21:11'),(221,1,'saas','Delete this user?','Delete this user?','2026-03-26 00:21:11','2026-03-26 00:21:11'),(222,2,'saas','Delete this user?','Delete this user?','2026-03-26 00:21:11','2026-03-26 00:21:11'),(223,1,'saas','Prepare shipping settings for the POS mobile app.','Prepare shipping settings for the POS mobile app.','2026-03-27 15:04:29','2026-03-27 15:04:29'),(224,2,'saas','Prepare shipping settings for the POS mobile app.','Prepare shipping settings for the POS mobile app.','2026-03-27 15:04:29','2026-03-27 15:04:29'),(225,1,'saas','Coming Soon','Coming Soon','2026-03-27 15:04:29','2026-03-27 15:04:29'),(226,2,'saas','Coming Soon','Coming Soon','2026-03-27 15:04:29','2026-03-27 15:04:29'),(227,1,'saas','This module will manage shipping methods, rates, and zones used by the Flutter POS app.','This module will manage shipping methods, rates, and zones used by the Flutter POS app.','2026-03-27 15:04:29','2026-03-27 15:04:29'),(228,2,'saas','This module will manage shipping methods, rates, and zones used by the Flutter POS app.','This module will manage shipping methods, rates, and zones used by the Flutter POS app.','2026-03-27 15:04:29','2026-03-27 15:04:29'),(229,1,'saas','Printing module placeholder. We will define the workflow and settings here later.','Printing module placeholder. We will define the workflow and settings here later.','2026-03-27 15:04:34','2026-03-27 15:04:34'),(230,2,'saas','Printing module placeholder. We will define the workflow and settings here later.','Printing module placeholder. We will define the workflow and settings here later.','2026-03-27 15:04:34','2026-03-27 15:04:34'),(231,1,'saas','Add printer profiles, templates, and routing rules for receipts and kitchen tickets.','Add printer profiles, templates, and routing rules for receipts and kitchen tickets.','2026-03-27 15:04:34','2026-03-27 15:04:34'),(232,2,'saas','Add printer profiles, templates, and routing rules for receipts and kitchen tickets.','Add printer profiles, templates, and routing rules for receipts and kitchen tickets.','2026-03-27 15:04:34','2026-03-27 15:04:34'),(233,1,'saas','Manage product option categories.','Manage product option categories.','2026-03-27 15:04:41','2026-03-27 15:04:41'),(234,2,'saas','Manage product option categories.','Manage product option categories.','2026-03-27 15:04:41','2026-03-27 15:04:41'),(235,1,'saas','New Product Option Category','New Product Option Category','2026-03-27 15:04:41','2026-03-27 15:04:41'),(236,2,'saas','New Product Option Category','New Product Option Category','2026-03-27 15:04:41','2026-03-27 15:04:41'),(237,1,'saas','Manage products and prices.','Manage products and prices.','2026-03-27 15:10:52','2026-03-27 15:10:52'),(238,2,'saas','Manage products and prices.','Manage products and prices.','2026-03-27 15:10:52','2026-03-27 15:10:52'),(239,1,'saas','Edit Manager','Edit Manager','2026-03-27 15:11:24','2026-03-27 15:11:24'),(240,2,'saas','Edit Manager','Edit Manager','2026-03-27 15:11:25','2026-03-27 15:11:25'),(241,1,'saas','Currency','Currency','2026-03-27 15:11:25','2026-03-27 15:11:25'),(242,2,'saas','Currency','Currency','2026-03-27 15:11:25','2026-03-27 15:11:25'),(243,1,'saas','Timezone','Timezone','2026-03-27 15:11:25','2026-03-27 15:11:25'),(244,2,'saas','Timezone','Timezone','2026-03-27 15:11:25','2026-03-27 15:11:25'),(245,1,'saas','Select Plan','Select Plan','2026-03-27 15:11:25','2026-03-27 15:11:25'),(246,2,'saas','Select Plan','Select Plan','2026-03-27 15:11:25','2026-03-27 15:11:25'),(247,1,'saas','No roles yet.','No roles yet.','2026-03-27 15:12:54','2026-03-27 15:12:54'),(248,2,'saas','No roles yet.','No roles yet.','2026-03-27 15:12:54','2026-03-27 15:12:54'),(249,1,'saas','Create User','Create User','2026-03-27 15:12:54','2026-03-27 15:12:54'),(250,2,'saas','Create User','Create User','2026-03-27 15:12:54','2026-03-27 15:12:54'),(251,1,'saas','Parent Category','Parent Category','2026-03-27 15:25:55','2026-03-27 15:25:55'),(252,2,'saas','Parent Category','Parent Category','2026-03-27 15:25:55','2026-03-27 15:25:55'),(253,1,'saas','No Parent','No Parent','2026-03-27 15:25:55','2026-03-27 15:25:55'),(254,2,'saas','No Parent','No Parent','2026-03-27 15:25:55','2026-03-27 15:25:55'),(255,1,'saas','Create Category','Create Category','2026-03-27 15:25:55','2026-03-27 15:25:55'),(256,2,'saas','Create Category','Create Category','2026-03-27 15:25:55','2026-03-27 15:25:55'),(257,1,'saas','Edit Category','Edit Category','2026-03-27 15:26:09','2026-03-27 15:26:09'),(258,2,'saas','Edit Category','Edit Category','2026-03-27 15:26:09','2026-03-27 15:26:09'),(259,1,'saas','Edit Product','Edit Product','2026-03-27 15:36:27','2026-03-27 15:36:27'),(260,2,'saas','Edit Product','Edit Product','2026-03-27 15:36:27','2026-03-27 15:36:27'),(261,1,'saas','Category','Category','2026-03-27 15:36:27','2026-03-27 15:36:27'),(262,2,'saas','Category','Category','2026-03-27 15:36:27','2026-03-27 15:36:27'),(263,1,'saas','No Category','No Category','2026-03-27 15:36:27','2026-03-27 15:36:27'),(264,2,'saas','No Category','No Category','2026-03-27 15:36:27','2026-03-27 15:36:27'),(265,1,'saas','No Tax','No Tax','2026-03-27 15:36:27','2026-03-27 15:36:27'),(266,2,'saas','No Tax','No Tax','2026-03-27 15:36:27','2026-03-27 15:36:27'),(267,1,'saas','Barcode','Barcode','2026-03-27 15:36:27','2026-03-27 15:36:27'),(268,2,'saas','Barcode','Barcode','2026-03-27 15:36:27','2026-03-27 15:36:27'),(269,1,'saas','Cost','Cost','2026-03-27 15:36:27','2026-03-27 15:36:27'),(270,2,'saas','Cost','Cost','2026-03-27 15:36:27','2026-03-27 15:36:27'),(271,1,'saas','Description','Description','2026-03-27 15:36:27','2026-03-27 15:36:27'),(272,2,'saas','Description','Description','2026-03-27 15:36:27','2026-03-27 15:36:27'),(273,1,'saas','Product Options (quantity)','Product Options (quantity)','2026-03-27 15:36:27','2026-03-27 15:36:27'),(274,2,'saas','Product Options (quantity)','Product Options (quantity)','2026-03-27 15:36:27','2026-03-27 15:36:27'),(275,1,'saas','Option','Option','2026-03-27 15:36:27','2026-03-27 15:36:27'),(276,2,'saas','Option','Option','2026-03-27 15:36:27','2026-03-27 15:36:27'),(277,1,'saas','Quantity','Quantity','2026-03-27 15:36:27','2026-03-27 15:36:27'),(278,2,'saas','Quantity','Quantity','2026-03-27 15:36:27','2026-03-27 15:36:27'),(279,1,'saas','+','+','2026-03-27 15:36:27','2026-03-27 15:36:27'),(280,2,'saas','+','+','2026-03-27 15:36:27','2026-03-27 15:36:27'),(281,1,'saas','Variants','Variants','2026-03-27 15:36:27','2026-03-27 15:36:27'),(282,2,'saas','Variants','Variants','2026-03-27 15:36:27','2026-03-27 15:36:27'),(283,1,'saas','Add Variant','Add Variant','2026-03-27 15:36:27','2026-03-27 15:36:27'),(284,2,'saas','Add Variant','Add Variant','2026-03-27 15:36:27','2026-03-27 15:36:27'),(285,1,'saas','No variants yet.','No variants yet.','2026-03-27 15:49:16','2026-03-27 15:49:16'),(286,2,'saas','No variants yet.','No variants yet.','2026-03-27 15:49:16','2026-03-27 15:49:16'),(287,1,'saas','Create Product','Create Product','2026-03-27 15:50:17','2026-03-27 15:50:17'),(288,2,'saas','Create Product','Create Product','2026-03-27 15:50:17','2026-03-27 15:50:17'),(289,1,'saas','Manage product categories.','Manage product categories.','2026-03-27 21:44:19','2026-03-27 21:44:19'),(290,2,'saas','Manage product categories.','Manage product categories.','2026-03-27 21:44:19','2026-03-27 21:44:19'),(291,1,'saas','Manage discounts.','Manage discounts.','2026-03-30 15:32:40','2026-03-30 15:32:40'),(292,2,'saas','Manage discounts.','Manage discounts.','2026-03-30 15:32:40','2026-03-30 15:32:40'),(293,1,'saas','Loyalty Program','Loyalty Program','2026-03-30 15:34:11','2026-03-30 15:34:11'),(294,2,'saas','Loyalty Program','Loyalty Program','2026-03-30 15:34:11','2026-03-30 15:34:11'),(295,1,'saas','Configure how customers earn and use loyalty points.','Configure how customers earn and use loyalty points.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(296,2,'saas','Configure how customers earn and use loyalty points.','Configure how customers earn and use loyalty points.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(297,1,'saas','Enable Loyalty','Enable Loyalty','2026-03-30 15:34:11','2026-03-30 15:34:11'),(298,2,'saas','Enable Loyalty','Enable Loyalty','2026-03-30 15:34:11','2026-03-30 15:34:11'),(299,1,'saas','Points per order','Points per order','2026-03-30 15:34:11','2026-03-30 15:34:11'),(300,2,'saas','Points per order','Points per order','2026-03-30 15:34:11','2026-03-30 15:34:11'),(301,1,'saas','Added once per sale.','Added once per sale.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(302,2,'saas','Added once per sale.','Added once per sale.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(303,1,'saas','Points per item','Points per item','2026-03-30 15:34:11','2026-03-30 15:34:11'),(304,2,'saas','Points per item','Points per item','2026-03-30 15:34:11','2026-03-30 15:34:11'),(305,1,'saas','Applied to each item quantity.','Applied to each item quantity.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(306,2,'saas','Applied to each item quantity.','Applied to each item quantity.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(307,1,'saas','Amount per point','Amount per point','2026-03-30 15:34:11','2026-03-30 15:34:11'),(308,2,'saas','Amount per point','Amount per point','2026-03-30 15:34:11','2026-03-30 15:34:11'),(309,1,'saas','Spend this amount to earn 1 point.','Spend this amount to earn 1 point.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(310,2,'saas','Spend this amount to earn 1 point.','Spend this amount to earn 1 point.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(311,1,'saas','Point value','Point value','2026-03-30 15:34:11','2026-03-30 15:34:11'),(312,2,'saas','Point value','Point value','2026-03-30 15:34:11','2026-03-30 15:34:11'),(313,1,'saas','1 point equals this amount at checkout.','1 point equals this amount at checkout.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(314,2,'saas','1 point equals this amount at checkout.','1 point equals this amount at checkout.','2026-03-30 15:34:11','2026-03-30 15:34:11'),(315,1,'saas','Back','Back','2026-03-30 15:34:11','2026-03-30 15:34:11'),(316,2,'saas','Back','Back','2026-03-30 15:34:11','2026-03-30 15:34:11'),(317,1,'saas','Manage shipping methods.','Manage shipping methods.','2026-03-30 19:36:53','2026-03-30 19:36:53'),(318,2,'saas','Manage shipping methods.','Manage shipping methods.','2026-03-30 19:36:53','2026-03-30 19:36:53'),(319,1,'saas','New Shipping Method','New Shipping Method','2026-03-30 19:36:53','2026-03-30 19:36:53'),(320,2,'saas','New Shipping Method','New Shipping Method','2026-03-30 19:36:53','2026-03-30 19:36:53'),(321,1,'saas','Manage your shipping methods.','Manage your shipping methods.','2026-03-30 21:36:24','2026-03-30 21:36:24'),(322,2,'saas','Manage your shipping methods.','Manage your shipping methods.','2026-03-30 21:36:24','2026-03-30 21:36:24'),(323,1,'saas','free, order_percent, per_item, manual','free, order_percent, per_item, manual','2026-03-30 21:36:25','2026-03-30 21:36:25'),(324,2,'saas','free, order_percent, per_item, manual','free, order_percent, per_item, manual','2026-03-30 21:36:25','2026-03-30 21:36:25'),(325,1,'saas','Used for percent or per item. Leave 0 for free/manual.','Used for percent or per item. Leave 0 for free/manual.','2026-03-30 21:36:25','2026-03-30 21:36:25'),(326,2,'saas','Used for percent or per item. Leave 0 for free/manual.','Used for percent or per item. Leave 0 for free/manual.','2026-03-30 21:36:25','2026-03-30 21:36:25'),(327,1,'saas','Create','Create','2026-03-30 21:36:25','2026-03-30 21:36:25'),(328,2,'saas','Create','Create','2026-03-30 21:36:25','2026-03-30 21:36:25'),(329,1,'saas','Points','Points','2026-03-30 23:46:37','2026-03-30 23:46:37'),(330,2,'saas','Points','Points','2026-03-30 23:46:37','2026-03-30 23:46:37'),(331,1,'saas','Edit Customer','Edit Customer','2026-03-30 23:46:48','2026-03-30 23:46:48'),(332,2,'saas','Edit Customer','Edit Customer','2026-03-30 23:46:48','2026-03-30 23:46:48'),(333,1,'saas','Address','Address','2026-03-30 23:46:48','2026-03-30 23:46:48'),(334,2,'saas','Address','Address','2026-03-30 23:46:48','2026-03-30 23:46:48'),(335,1,'saas','Note','Note','2026-03-30 23:46:48','2026-03-30 23:46:48'),(336,2,'saas','Note','Note','2026-03-30 23:46:48','2026-03-30 23:46:48'),(337,1,'saas','Loyalty Points','Loyalty Points','2026-03-30 23:46:48','2026-03-30 23:46:48'),(338,2,'saas','Loyalty Points','Loyalty Points','2026-03-30 23:46:48','2026-03-30 23:46:48'),(339,1,'saas','Printing services','Printing services','2026-03-31 01:10:01','2026-03-31 01:10:01'),(340,2,'saas','Printing services','Printing services','2026-03-31 01:10:01','2026-03-31 01:10:01'),(341,1,'saas','Configure the printers used by your services.','Configure the printers used by your services.','2026-03-31 01:10:01','2026-03-31 01:10:01'),(342,2,'saas','Configure the printers used by your services.','Configure the printers used by your services.','2026-03-31 01:10:01','2026-03-31 01:10:01'),(343,1,'saas','New Service','New Service','2026-03-31 01:10:01','2026-03-31 01:10:01'),(344,2,'saas','New Service','New Service','2026-03-31 01:10:01','2026-03-31 01:10:01'),(345,1,'saas','Template','Template','2026-03-31 01:10:01','2026-03-31 01:10:01'),(346,2,'saas','Template','Template','2026-03-31 01:10:01','2026-03-31 01:10:01'),(347,1,'saas','Order','Order','2026-03-31 01:10:01','2026-03-31 01:10:01'),(348,2,'saas','Order','Order','2026-03-31 01:10:01','2026-03-31 01:10:01'),(349,1,'saas','No printing services yet.','No printing services yet.','2026-03-31 01:10:01','2026-03-31 01:10:01'),(350,2,'saas','No printing services yet.','No printing services yet.','2026-03-31 01:10:01','2026-03-31 01:10:01'),(351,1,'saas','New printing service','New printing service','2026-03-31 01:10:07','2026-03-31 01:10:07'),(352,2,'saas','New printing service','New printing service','2026-03-31 01:10:07','2026-03-31 01:10:07'),(353,1,'saas','Define a service and its ticket template.','Define a service and its ticket template.','2026-03-31 01:10:07','2026-03-31 01:10:07'),(354,2,'saas','Define a service and its ticket template.','Define a service and its ticket template.','2026-03-31 01:10:07','2026-03-31 01:10:07'),(355,1,'saas','Service name','Service name','2026-03-31 01:10:07','2026-03-31 01:10:07'),(356,2,'saas','Service name','Service name','2026-03-31 01:10:07','2026-03-31 01:10:07'),(357,1,'saas','Service type','Service type','2026-03-31 01:10:07','2026-03-31 01:10:07'),(358,2,'saas','Service type','Service type','2026-03-31 01:10:07','2026-03-31 01:10:07'),(359,1,'saas','Print template','Print template','2026-03-31 01:10:07','2026-03-31 01:10:07'),(360,2,'saas','Print template','Print template','2026-03-31 01:10:07','2026-03-31 01:10:07'),(361,1,'saas','Manager Admin User (Optional)','Manager Admin User (Optional)','2026-04-02 19:20:13','2026-04-02 19:20:13'),(362,2,'saas','Manager Admin User (Optional)','Manager Admin User (Optional)','2026-04-02 19:20:13','2026-04-02 19:20:13'),(363,1,'saas','Admin Name','Admin Name','2026-04-02 19:20:13','2026-04-02 19:20:13'),(364,2,'saas','Admin Name','Admin Name','2026-04-02 19:20:13','2026-04-02 19:20:13'),(365,1,'saas','Admin Email','Admin Email','2026-04-02 19:20:13','2026-04-02 19:20:13'),(366,2,'saas','Admin Email','Admin Email','2026-04-02 19:20:13','2026-04-02 19:20:13'),(367,1,'saas','Admin Password','Admin Password','2026-04-02 19:20:13','2026-04-02 19:20:13'),(368,2,'saas','Admin Password','Admin Password','2026-04-02 19:20:13','2026-04-02 19:20:13'),(369,1,'saas','Create Manager','Create Manager','2026-04-02 19:20:13','2026-04-02 19:20:13'),(370,2,'saas','Create Manager','Create Manager','2026-04-02 19:20:13','2026-04-02 19:20:13'),(371,1,'saas','Edit Store','Edit Store','2026-04-02 19:32:32','2026-04-02 19:32:32'),(372,2,'saas','Edit Store','Edit Store','2026-04-02 19:32:32','2026-04-02 19:32:32'),(373,1,'saas','Select Currency','Select Currency','2026-04-02 19:32:32','2026-04-02 19:32:32'),(374,2,'saas','Select Currency','Select Currency','2026-04-02 19:32:32','2026-04-02 19:32:32'),(375,1,'saas','Logo','Logo','2026-04-02 19:32:32','2026-04-02 19:32:32'),(376,2,'saas','Logo','Logo','2026-04-02 19:32:32','2026-04-02 19:32:32'),(377,1,'saas','Allow Loyalty Redemption','Allow Loyalty Redemption','2026-04-02 19:32:32','2026-04-02 19:32:32'),(378,2,'saas','Allow Loyalty Redemption','Allow Loyalty Redemption','2026-04-02 19:32:32','2026-04-02 19:32:32');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_audits`
--

LOCK TABLES `user_audits` WRITE;
/*!40000 ALTER TABLE `user_audits` DISABLE KEYS */;
INSERT INTO `user_audits` VALUES (1,8,9,6,3,'create','{\"diff\": {\"name\": {\"to\": \"serveur\", \"from\": null}, \"email\": {\"to\": \"serveur@kinpos.com\", \"from\": null}, \"roles\": {\"to\": [], \"from\": null}, \"store_id\": {\"to\": \"3\", \"from\": null}, \"is_active\": {\"to\": true, \"from\": null}}, \"after\": {\"name\": \"serveur\", \"email\": \"serveur@kinpos.com\", \"roles\": [], \"store_id\": \"3\", \"is_active\": true}, \"before\": null}','127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:148.0) Gecko/20100101 Firefox/148.0','2026-03-27 15:13:17','2026-03-27 15:13:17');
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
  `pin` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `store_id` bigint unsigned DEFAULT NULL,
  `is_super_admin` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `allow_loyalty_redeem` tinyint(1) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `manager_id` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`),
  KEY `users_store_id_foreign` (`store_id`),
  KEY `users_tenant_id_is_active_index` (`is_active`),
  KEY `users_manager_id_is_active_index` (`manager_id`,`is_active`),
  CONSTRAINT `users_manager_id_foreign` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin','admin','admin@example.com',NULL,'$2y$12$7i.ZNZ8B7pTlXck7Bf922unPUcZj8FFk2HawWeh1bmTtE6sJgWc/S',NULL,'6rV9VUg0JVD4t9wfhWVgLdDh6zy2LaHY3JWsTNZeYas6vYZ8hQvAJruVNZWD','2026-03-14 02:59:48','2026-03-14 02:59:48',NULL,1,1,NULL,NULL,NULL),(2,'Tenant Admin','tenant1','tenant1@example.com',NULL,'$2y$12$Q9wvodLBV7LkCRWUipyxeOrLmPxXx0C330jvf8Cp1DkzNv3eoYqv.',NULL,NULL,'2026-03-14 03:19:46','2026-03-14 03:19:46',NULL,0,1,NULL,NULL,1),(3,'tacos','tacos','tacos@pos.com',NULL,'$2y$12$spZK06Uv3aQmISjDjjkWvu9RfKDnkHntV32.TFENGm748ItJSCz52',NULL,NULL,'2026-03-14 03:26:26','2026-03-14 03:26:26',NULL,0,1,NULL,NULL,3),(4,'','admin_ravtq9','admin@badr.com',NULL,'$2y$10$ZA0FtZON2YRC9lgnHjajk.XHIn4vP5X50uAVslrMUSpUGMThW/.ZC',NULL,NULL,'2026-03-16 00:22:48','2026-03-16 00:22:48',NULL,0,1,NULL,NULL,NULL),(5,'pizeria','pizeria','pizeria@pos.com',NULL,'$2y$12$hFw1F6ZOm.EPDHKyrvLfJ.tNgE0P/zXHhAu79zfSKKFFL8bMR1TfW',NULL,NULL,'2026-03-16 21:27:14','2026-03-16 21:27:14',NULL,0,1,NULL,NULL,4),(6,'resto','resto','resto@pos.com',NULL,'$2y$12$J8nnyzhJhIhAzzuV8IXKjONtblHcSQupZF4AMQoiAREHRQz1JSNmO',NULL,NULL,'2026-03-16 22:23:30','2026-03-16 22:23:30',NULL,0,1,NULL,NULL,5),(7,'manager','manager','manager@kinpos.com',NULL,'$2y$12$BFmCKt7DqIEqgMXZ6KsBce/l8MyNd8JhErhw0JaIOLdb2bPVGOxEW',NULL,'wbHlOcB61ra3l1rj3ggd39jEg9r2SiHeTISYSOviIJgkEL3OmsaIZswYdH9L','2026-03-24 01:29:48','2026-03-24 01:29:48',NULL,0,1,NULL,NULL,1),(8,'manager','rdabbl','rdabbl@kinpos.com',NULL,'$2y$12$9RPBcPTJZsvpbxbFwGR/N.2zeVg88FnEe9.bwpVeLgLhPyKLyiVee',NULL,NULL,'2026-03-25 01:13:45','2026-03-25 01:13:45',3,0,1,NULL,NULL,6),(9,'serveur','serveur','serveur@kinpos.com',NULL,'$2y$12$UiuJlOQCV50q6Eet.HeG1eR8jx5Vanw1LkOf2/Y/wad/Qwi.gKIlG',NULL,NULL,'2026-03-27 15:13:17','2026-03-27 15:13:17',3,0,1,NULL,NULL,6),(10,'lookwino','lookwino','lookwino@gmail.com',NULL,'$2y$12$ZUQvIhz8/dQOr10IPMaYHuhD7Qer6El6Q7KfEQxP0rPkRuUsjsr0S',NULL,NULL,'2026-04-02 19:22:09','2026-04-02 19:22:09',4,0,1,NULL,NULL,7);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-30 13:44:54
