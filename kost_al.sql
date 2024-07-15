-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 14, 2024 at 09:07 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kost_al`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddPenyewaan` (`id_pengguna` INT, `id_kamar` INT)   BEGIN
    DECLARE kamar_status VARCHAR(20);
    
    -- Ensure the query returns only one row
    SELECT status INTO kamar_status 
    FROM Kamar 
    WHERE id_kamar = id_kamar 
    LIMIT 1;
    
    IF kamar_status = 'tersedia' THEN
        INSERT INTO Penyewaan (tanggal_mulai, id_pengguna, id_kamar) 
        VALUES (CURDATE(), id_pengguna, id_kamar);
        
        UPDATE Kamar 
        SET status = 'tidak tersedia' 
        WHERE id_kamar = id_kamar;
    ELSE
        SELECT 'Kamar tidak tersedia' AS pesan;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPengguna` ()   BEGIN
    SELECT * FROM Pengguna;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `TotalPengguna` () RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM Pengguna;
    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `TotalPenyewaanPengguna` (`id` INT, `tahun` INT) RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total 
    FROM Penyewaan 
    WHERE id_pengguna = id AND YEAR(tanggal_mulai) = tahun;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detail_pengguna`
--

CREATE TABLE `detail_pengguna` (
  `id_detail` int(11) NOT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL,
  `id_pengguna` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_pengguna`
--

INSERT INTO `detail_pengguna` (`id_detail`, `alamat`, `tanggal_lahir`, `jenis_kelamin`, `id_pengguna`) VALUES
(1, 'Jl. Merdeka No. 1', '1990-01-01', 'L', 1),
(2, 'Jl. Kebon Jeruk No. 2', '1992-02-02', 'L', 2),
(3, 'Jl. Sudirman No. 3', '1994-03-03', 'L', 3);

-- --------------------------------------------------------

--
-- Table structure for table `fasilitas`
--

CREATE TABLE `fasilitas` (
  `id_fasilitas` int(11) NOT NULL,
  `nama_fasilitas` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fasilitas`
--

INSERT INTO `fasilitas` (`id_fasilitas`, `nama_fasilitas`) VALUES
(1, 'WiFi'),
(2, 'AC'),
(3, 'Kamar Mandi Dalam');

-- --------------------------------------------------------

--
-- Table structure for table `kamar`
--

CREATE TABLE `kamar` (
  `id_kamar` int(11) NOT NULL,
  `nomor_kamar` varchar(10) NOT NULL,
  `ukuran` varchar(50) DEFAULT NULL,
  `harga` decimal(10,2) NOT NULL,
  `status` enum('tersedia','tidak tersedia') NOT NULL,
  `id_kost` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kamar`
--

INSERT INTO `kamar` (`id_kamar`, `nomor_kamar`, `ukuran`, `harga`, `status`, `id_kost`) VALUES
(1, '101', '3x4', 1500000.00, 'tidak tersedia', 1),
(2, '102', '3x4', 1500000.00, 'tidak tersedia', 1),
(3, '201', '3x4', 2000000.00, 'tidak tersedia', 2),
(4, '202', '3x4', 2000000.00, 'tidak tersedia', 2);

--
-- Triggers `kamar`
--
DELIMITER $$
CREATE TRIGGER `AfterDeleteKamar` AFTER DELETE ON `kamar` FOR EACH ROW BEGIN
    -- Insert data into LogKamar
    INSERT INTO LogKamar (id_kamar, action_type, old_status) 
    VALUES (OLD.id_kamar, 'DELETE', OLD.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `AfterInsertKamar` AFTER INSERT ON `kamar` FOR EACH ROW BEGIN
    INSERT INTO LogKamar (id_kamar, action_type, new_status) 
    VALUES (NEW.id_kamar, 'INSERT', NEW.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `AfterUpdateKamar` AFTER UPDATE ON `kamar` FOR EACH ROW BEGIN
    -- Insert data into LogKamar
    INSERT INTO LogKamar (id_kamar, action_type, old_status, new_status) 
    VALUES (OLD.id_kamar, 'UPDATE', OLD.status, NEW.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `BeforeDeleteKamar` BEFORE DELETE ON `kamar` FOR EACH ROW BEGIN
    INSERT INTO LogKamar (id_kamar, action_type, old_status) 
    VALUES (OLD.id_kamar, 'DELETE', OLD.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `BeforeInsertKamar` BEFORE INSERT ON `kamar` FOR EACH ROW BEGIN
    INSERT INTO LogKamar (id_kamar, action_type, new_status) 
    VALUES (NEW.id_kamar, 'INSERT', NEW.status);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `BeforeUpdateKamar` BEFORE UPDATE ON `kamar` FOR EACH ROW BEGIN
    INSERT INTO LogKamar (id_kamar, action_type, old_status, new_status) 
    VALUES (OLD.id_kamar, 'UPDATE', OLD.status, NEW.status);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kamar_fasilitas`
--

CREATE TABLE `kamar_fasilitas` (
  `id_kamar` int(11) NOT NULL,
  `id_fasilitas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kamar_fasilitas`
--

INSERT INTO `kamar_fasilitas` (`id_kamar`, `id_fasilitas`) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 1),
(3, 3);

-- --------------------------------------------------------

--
-- Table structure for table `kost`
--

CREATE TABLE `kost` (
  `id_kost` int(11) NOT NULL,
  `nama_kost` varchar(100) NOT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `pemilik_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kost`
--

INSERT INTO `kost` (`id_kost`, `nama_kost`, `alamat`, `pemilik_id`) VALUES
(1, 'Kost Indah', 'Jl. Mawar No. 10', 1),
(2, 'Kost Mewah', 'Jl. Melati No. 20', 2);

-- --------------------------------------------------------

--
-- Table structure for table `logkamar`
--

CREATE TABLE `logkamar` (
  `id_log` int(11) NOT NULL,
  `id_kamar` int(11) DEFAULT NULL,
  `action_type` varchar(50) DEFAULT NULL,
  `old_status` varchar(20) DEFAULT NULL,
  `new_status` varchar(20) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `logpenyewaan`
--

CREATE TABLE `logpenyewaan` (
  `id_log` int(11) NOT NULL,
  `id_penyewaan` int(11) DEFAULT NULL,
  `id_pengguna` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengguna`
--

CREATE TABLE `pengguna` (
  `id_pengguna` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `no_telepon` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengguna`
--

INSERT INTO `pengguna` (`id_pengguna`, `nama`, `email`, `password`, `no_telepon`) VALUES
(1, 'Muhammad Ali', 'muhammadali@gmail.com', 'password123', '081234567890'),
(2, 'Naufal Haidar', 'naufal@gmail.com', 'password123', '082345678901'),
(3, 'Bayu Setya Adjie', 'bayu@gmail.com', 'password123', '083456789012');

-- --------------------------------------------------------

--
-- Table structure for table `penyewaan`
--

CREATE TABLE `penyewaan` (
  `id_penyewaan` int(11) NOT NULL,
  `tanggal_mulai` date NOT NULL,
  `tanggal_berakhir` date DEFAULT NULL,
  `id_pengguna` int(11) DEFAULT NULL,
  `id_kamar` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `penyewaan`
--

INSERT INTO `penyewaan` (`id_penyewaan`, `tanggal_mulai`, `tanggal_berakhir`, `id_pengguna`, `id_kamar`) VALUES
(1, '2023-01-01', '2023-06-30', 1, 1),
(2, '2023-02-01', '2023-07-31', 2, 3),
(3, '2024-07-14', NULL, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `id_transaksi` int(11) NOT NULL,
  `tanggal_transaksi` date NOT NULL,
  `jumlah` decimal(10,2) NOT NULL,
  `metode_pembayaran` varchar(50) DEFAULT NULL,
  `id_penyewaan` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`id_transaksi`, `tanggal_transaksi`, `jumlah`, `metode_pembayaran`, `id_penyewaan`) VALUES
(1, '2023-01-01', 1500000.00, 'Transfer', 1),
(2, '2023-02-01', 2000000.00, 'Cash', 2);

-- --------------------------------------------------------

--
-- Stand-in structure for view `viewkamardetail`
-- (See below for the actual view)
--
CREATE TABLE `viewkamardetail` (
`id_kamar` int(11)
,`nomor_kamar` varchar(10)
,`harga` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `viewpengguna`
-- (See below for the actual view)
--
CREATE TABLE `viewpengguna` (
`id_pengguna` int(11)
,`nama` varchar(100)
,`email` varchar(100)
,`no_telepon` varchar(15)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `viewpenyewaan`
-- (See below for the actual view)
--
CREATE TABLE `viewpenyewaan` (
`id_penyewaan` int(11)
,`tanggal_mulai` date
,`tanggal_berakhir` date
,`pengguna_nama` varchar(100)
,`nomor_kamar` varchar(10)
);

-- --------------------------------------------------------

--
-- Structure for view `viewkamardetail`
--
DROP TABLE IF EXISTS `viewkamardetail`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `viewkamardetail`  AS SELECT `kamar`.`id_kamar` AS `id_kamar`, `kamar`.`nomor_kamar` AS `nomor_kamar`, `kamar`.`harga` AS `harga` FROM `kamar` ;

-- --------------------------------------------------------

--
-- Structure for view `viewpengguna`
--
DROP TABLE IF EXISTS `viewpengguna`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `viewpengguna`  AS SELECT `pengguna`.`id_pengguna` AS `id_pengguna`, `pengguna`.`nama` AS `nama`, `pengguna`.`email` AS `email`, `pengguna`.`no_telepon` AS `no_telepon` FROM `pengguna` ;

-- --------------------------------------------------------

--
-- Structure for view `viewpenyewaan`
--
DROP TABLE IF EXISTS `viewpenyewaan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `viewpenyewaan`  AS SELECT `p`.`id_penyewaan` AS `id_penyewaan`, `p`.`tanggal_mulai` AS `tanggal_mulai`, `p`.`tanggal_berakhir` AS `tanggal_berakhir`, `pe`.`nama` AS `pengguna_nama`, `k`.`nomor_kamar` AS `nomor_kamar` FROM ((`penyewaan` `p` join `pengguna` `pe` on(`p`.`id_pengguna` = `pe`.`id_pengguna`)) join `kamar` `k` on(`p`.`id_kamar` = `k`.`id_kamar`))WITH CASCADED CHECK OPTION  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detail_pengguna`
--
ALTER TABLE `detail_pengguna`
  ADD PRIMARY KEY (`id_detail`),
  ADD UNIQUE KEY `id_pengguna` (`id_pengguna`);

--
-- Indexes for table `fasilitas`
--
ALTER TABLE `fasilitas`
  ADD PRIMARY KEY (`id_fasilitas`);

--
-- Indexes for table `kamar`
--
ALTER TABLE `kamar`
  ADD PRIMARY KEY (`id_kamar`),
  ADD KEY `idx_kamar_status` (`id_kost`,`status`);

--
-- Indexes for table `kamar_fasilitas`
--
ALTER TABLE `kamar_fasilitas`
  ADD PRIMARY KEY (`id_kamar`,`id_fasilitas`),
  ADD KEY `id_fasilitas` (`id_fasilitas`);

--
-- Indexes for table `kost`
--
ALTER TABLE `kost`
  ADD PRIMARY KEY (`id_kost`),
  ADD KEY `pemilik_id` (`pemilik_id`);

--
-- Indexes for table `logkamar`
--
ALTER TABLE `logkamar`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `logpenyewaan`
--
ALTER TABLE `logpenyewaan`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `idx_penyewaan_pengguna` (`id_penyewaan`,`id_pengguna`);

--
-- Indexes for table `pengguna`
--
ALTER TABLE `pengguna`
  ADD PRIMARY KEY (`id_pengguna`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `penyewaan`
--
ALTER TABLE `penyewaan`
  ADD PRIMARY KEY (`id_penyewaan`),
  ADD KEY `id_kamar` (`id_kamar`),
  ADD KEY `idx_penyewaan_pengguna_kamar` (`id_pengguna`,`id_kamar`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `id_penyewaan` (`id_penyewaan`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `detail_pengguna`
--
ALTER TABLE `detail_pengguna`
  MODIFY `id_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `fasilitas`
--
ALTER TABLE `fasilitas`
  MODIFY `id_fasilitas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `kamar`
--
ALTER TABLE `kamar`
  MODIFY `id_kamar` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `kost`
--
ALTER TABLE `kost`
  MODIFY `id_kost` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `logkamar`
--
ALTER TABLE `logkamar`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logpenyewaan`
--
ALTER TABLE `logpenyewaan`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pengguna`
--
ALTER TABLE `pengguna`
  MODIFY `id_pengguna` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `penyewaan`
--
ALTER TABLE `penyewaan`
  MODIFY `id_penyewaan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `id_transaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_pengguna`
--
ALTER TABLE `detail_pengguna`
  ADD CONSTRAINT `detail_pengguna_ibfk_1` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`);

--
-- Constraints for table `kamar`
--
ALTER TABLE `kamar`
  ADD CONSTRAINT `kamar_ibfk_1` FOREIGN KEY (`id_kost`) REFERENCES `kost` (`id_kost`);

--
-- Constraints for table `kamar_fasilitas`
--
ALTER TABLE `kamar_fasilitas`
  ADD CONSTRAINT `kamar_fasilitas_ibfk_1` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`),
  ADD CONSTRAINT `kamar_fasilitas_ibfk_2` FOREIGN KEY (`id_fasilitas`) REFERENCES `fasilitas` (`id_fasilitas`);

--
-- Constraints for table `kost`
--
ALTER TABLE `kost`
  ADD CONSTRAINT `kost_ibfk_1` FOREIGN KEY (`pemilik_id`) REFERENCES `pengguna` (`id_pengguna`);

--
-- Constraints for table `penyewaan`
--
ALTER TABLE `penyewaan`
  ADD CONSTRAINT `penyewaan_ibfk_1` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`),
  ADD CONSTRAINT `penyewaan_ibfk_2` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`);

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_penyewaan`) REFERENCES `penyewaan` (`id_penyewaan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
