-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: 192.168.200.13    Database: 1135_inventory_system
-- ------------------------------------------------------
-- Server version	5.5.5-10.3.39-MariaDB-0ubuntu0.20.04.2

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
-- Table structure for table `AssignmentHistory`
--

DROP TABLE IF EXISTS `AssignmentHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `AssignmentHistory` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `EquipmentId` int(11) NOT NULL,
  `PreviousUserId` int(11) DEFAULT NULL,
  `NewUserId` int(11) NOT NULL,
  `AssignedByAccountantId` int(11) NOT NULL,
  `AssignmentDate` datetime DEFAULT current_timestamp(),
  `Action` enum('Assign','Return','Reassign') NOT NULL,
  `Reason` text DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `EquipmentId` (`EquipmentId`),
  KEY `PreviousUserId` (`PreviousUserId`),
  KEY `NewUserId` (`NewUserId`),
  KEY `AssignedByAccountantId` (`AssignedByAccountantId`),
  CONSTRAINT `AssignmentHistory_ibfk_1` FOREIGN KEY (`EquipmentId`) REFERENCES `Equipment` (`Id`),
  CONSTRAINT `AssignmentHistory_ibfk_2` FOREIGN KEY (`PreviousUserId`) REFERENCES `Users` (`Id`),
  CONSTRAINT `AssignmentHistory_ibfk_3` FOREIGN KEY (`NewUserId`) REFERENCES `Users` (`Id`),
  CONSTRAINT `AssignmentHistory_ibfk_4` FOREIGN KEY (`AssignedByAccountantId`) REFERENCES `Users` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AssignmentHistory`
--

LOCK TABLES `AssignmentHistory` WRITE;
/*!40000 ALTER TABLE `AssignmentHistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `AssignmentHistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Equipment`
--

DROP TABLE IF EXISTS `Equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Equipment` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `InventoryNumber` varchar(50) NOT NULL,
  `Name` varchar(150) NOT NULL,
  `Description` text DEFAULT NULL,
  `Category` varchar(50) NOT NULL,
  `Status` enum('Available','Assigned','UnderRepair','Missing','Decommissioned') DEFAULT 'Available',
  `AssignedToUserId` int(11) DEFAULT NULL,
  `DateAssigned` datetime DEFAULT NULL,
  `LastInventoryDate` datetime DEFAULT NULL,
  `PurchaseDate` date DEFAULT NULL,
  `Cost` decimal(10,2) DEFAULT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp(),
  `IsActive` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `InventoryNumber` (`InventoryNumber`),
  KEY `AssignedToUserId` (`AssignedToUserId`),
  CONSTRAINT `Equipment_ibfk_1` FOREIGN KEY (`AssignedToUserId`) REFERENCES `Users` (`Id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Equipment`
--

LOCK TABLES `Equipment` WRITE;
/*!40000 ALTER TABLE `Equipment` DISABLE KEYS */;
/*!40000 ALTER TABLE `Equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `InventoryRecords`
--

DROP TABLE IF EXISTS `InventoryRecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `InventoryRecords` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `EquipmentId` int(11) NOT NULL,
  `EmployeeId` int(11) NOT NULL,
  `InventoryDate` datetime NOT NULL DEFAULT current_timestamp(),
  `EquipmentCondition` enum('New','Good','RequiresRepair','Unusable') NOT NULL,
  `IsPresent` tinyint(1) NOT NULL,
  `Location` varchar(100) DEFAULT NULL,
  `Comments` text DEFAULT NULL,
  `PhotoPath` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `EquipmentId` (`EquipmentId`),
  KEY `EmployeeId` (`EmployeeId`),
  CONSTRAINT `InventoryRecords_ibfk_1` FOREIGN KEY (`EquipmentId`) REFERENCES `Equipment` (`Id`) ON DELETE CASCADE,
  CONSTRAINT `InventoryRecords_ibfk_2` FOREIGN KEY (`EmployeeId`) REFERENCES `Users` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `InventoryRecords`
--

LOCK TABLES `InventoryRecords` WRITE;
/*!40000 ALTER TABLE `InventoryRecords` DISABLE KEYS */;
/*!40000 ALTER TABLE `InventoryRecords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SystemSettings`
--

DROP TABLE IF EXISTS `SystemSettings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SystemSettings` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `SettingKey` varchar(50) NOT NULL,
  `SettingValue` varchar(255) NOT NULL,
  `Description` text DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `SettingKey` (`SettingKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SystemSettings`
--

LOCK TABLES `SystemSettings` WRITE;
/*!40000 ALTER TABLE `SystemSettings` DISABLE KEYS */;
/*!40000 ALTER TABLE `SystemSettings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `Role` enum('Accountant','Employee') NOT NULL,
  `FullName` varchar(100) NOT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `IsActive` tinyint(1) DEFAULT 1,
  `CreatedAt` datetime DEFAULT current_timestamp(),
  `LastLogin` datetime DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Username` (`Username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database '1135_inventory_system'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-10 15:34:18
