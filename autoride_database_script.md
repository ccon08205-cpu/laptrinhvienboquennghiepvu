-- =============================================================================
-- DỰ ÁN: AUTORIDE - TỐI ƯU HÓA CƠ SỞ DỮ LIỆU THUÊ XE TỰ LÁI
-- Script bao gồm: DDL (Sửa đổi & Tạo bảng) và DML (Mô phỏng kịch bản thực tế)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. KHỞI TẠO CƠ SỞ DỮ LIỆU
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS autoride_db;
USE autoride_db;

-- Dọn dẹp bảng cũ nếu cần chạy lại script (theo thứ tự khóa ngoại)
DROP TABLE IF EXISTS Inspections;
DROP TABLE IF EXISTS Rentals;
DROP TABLE IF EXISTS Cars;

-- -----------------------------------------------------------------------------
-- 2. XÂY DỰNG CẤU TRÚC BẢNG BAN ĐẦU (LEGACY SYSTEM BASELINE)
-- -----------------------------------------------------------------------------
CREATE TABLE Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME,
    status VARCHAR(50) DEFAULT 'BOOKED',
    FOREIGN KEY (car_id) REFERENCES Cars(car_id)
);

-- -----------------------------------------------------------------------------
-- 3. BƯỚC 3 (DDL): CẢI TIẾN CẤU TRÚC BẢNG THEO THIẾT KẾ MỚI (OPTIMIZATION)
-- -----------------------------------------------------------------------------

-- 3.1 Khóa chặt trạng thái bằng ENUM và thêm các cột tài chính (DECIMAL) vào bảng Rentals
ALTER TABLE Rentals
    MODIFY COLUMN status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'BOOKED',
    ADD COLUMN security_deposit DECIMAL(12, 2) NOT NULL DEFAULT 0.00 AFTER return_date,
    ADD COLUMN late_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00 AFTER security_deposit,
    ADD COLUMN damage_fee DECIMAL(12, 2) NOT NULL DEFAULT 0.00 AFTER late_fee;

-- 3.2 Tạo bảng Inspections lưu trữ Biên bản kiểm tra tình trạng xe
CREATE TABLE Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT,
    inspector_name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_inspections_rentals 
        FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

-- 3.3 (Nâng cao) Trigger ngăn chặn tạo biên bản kiểm tra khi hợp đồng ở trạng thái BOOKED
DELIMITER //
CREATE TRIGGER trg_prevent_inspection_on_booked
BEFORE INSERT ON Inspections
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(50);
    SELECT status INTO v_status FROM Rentals WHERE rental_id = NEW.rental_id;
    IF v_status = 'BOOKED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Không thể tạo biên bản kiểm tra xe khi hợp đồng đang ở trạng thái BOOKED!';
    END IF;
END;
//
DELIMITER ;

-- -----------------------------------------------------------------------------
-- 4. BƯỚC 4 (DML): MÔ PHỎNG KỊCH BẢN NGHIỆP VỤ THỰC TẾ
-- -----------------------------------------------------------------------------

-- 4.1 Thêm thông tin xe mẫu
INSERT INTO Cars (model_name, license_plate) 
VALUES ('Toyota Camry 2023', '30H-888.88');

-- 4.2 Kịch bản Phase 1: Khách "Nguyen Van A" đặt và nhận xe, đặt cọc 10.000.000 VNĐ (Trạng thái: ACTIVE)
INSERT INTO Rentals (car_id, customer_name, rent_date, return_date, status, security_deposit)
VALUES (1, 'Nguyen Van A', '2026-03-20 08:00:00', '2026-03-22 18:00:00', 'ACTIVE', 10000000.00);

-- 4.3 Kịch bản Phase 2: Khách trả xe. Nhân viên kiểm tra phát hiện vỡ đèn pha trái và lập biên bản
INSERT INTO Inspections (rental_id, inspection_date, damage_description, inspector_name)
VALUES (1, '2026-03-22 18:30:00', 'Vỡ đèn pha phía trước bên trái do va chạm nhẹ', 'Tran Van B');

-- 4.4 Kịch bản Phase 3: Cập nhật hợp đồng thuê - Trạng thái COMPLETED, ghi nhận late_fee = 0, damage_fee = 2.000.000 VNĐ
UPDATE Rentals
SET status = 'COMPLETED',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = 1;

-- 4.5 Truy vấn tính toán chính xác số tiền thực tế cần hoàn trả lại cho khách hàng
SELECT 
    r.rental_id AS 'Mã Hợp Đồng',
    r.customer_name AS 'Tên Khách Hàng',
    c.model_name AS 'Tên Xe',
    c.license_plate AS 'Biển Số',
    r.status AS 'Trạng Thái',
    FORMAT(r.security_deposit, 0) AS 'Tiền Cọc (VNĐ)',
    FORMAT(r.late_fee, 0) AS 'Phí Phạt Trễ (VNĐ)',
    FORMAT(r.damage_fee, 0) AS 'Phí Sửa Chữa (VNĐ)',
    FORMAT((r.security_deposit - COALESCE(r.late_fee, 0) - COALESCE(r.damage_fee, 0)), 0) AS 'Tiền Hoàn Trả Khách (VNĐ)',
    i.damage_description AS 'Ghi Chú Hư Hỏng',
    i.inspector_name AS 'Nhân Viên Kiểm Tra'
FROM Rentals r
JOIN Cars c ON r.car_id = c.car_id
LEFT JOIN Inspections i ON r.rental_id = i.rental_id
WHERE r.rental_id = 1;