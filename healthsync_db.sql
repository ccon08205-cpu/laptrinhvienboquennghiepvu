-- ==========================================================
-- HỆ THỐNG HEALTHSYNC - DATABASE SCHEMA & DML OPTIMIZED
-- ==========================================================

CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- 1. BẢNG PATIENTS
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- 2. BẢNG DOCTORS
CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- 3. BẢNG APPOINTMENTS (Đã tái cấu trúc chuẩn hóa)
CREATE TABLE IF NOT EXISTS Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    deposit_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    penalty_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    cancel_reason VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- 4. BẢNG PRESCRIPTIONS (Tạo mới)
CREATE TABLE IF NOT EXISTS Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT UNIQUE NOT NULL,
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
);

-- ==========================================================
-- MÔ PHỎNG KỊCH BẢN NGHIỆP VỤ (DML)
-- ==========================================================

-- Chèn dữ liệu mẫu ban đầu
INSERT INTO Patients (full_name, phone) VALUES 
('Nguyễn Văn A', '0901234567'),
('Trần Thị B', '0987654321');

INSERT INTO Doctors (full_name, specialty) VALUES 
('Bác sĩ Lê Văn C', 'Nội khoa'),
('Bác sĩ Phạm Thị D', 'Nhi khoa');

-- KỊCH BẢN 1: Luồng khám bệnh thành công trọn vẹn
-- Step 1.1: Bệnh nhân Nguyễn Văn A đặt lịch (PENDING, cọc 500.000đ)
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-09-22 09:00:00', 'PENDING', 500000.00);

-- Step 1.2: Bệnh nhân check-in tại phòng khám
UPDATE Appointments 
SET status = 'CHECKED_IN' 
WHERE appointment_id = 1;

-- Step 1.3: Bác sĩ khám xong (COMPLETED)
UPDATE Appointments 
SET status = 'COMPLETED' 
WHERE appointment_id = 1;

-- Step 1.4: Bác sĩ kê đơn thuốc cho lịch hẹn 1
INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (1, 'Paracetamol 500mg (20 viên, uống 2 lần/ngày), Amoxicillin 500mg (14 viên)');

-- KỊCH BẢN 2: Luồng hủy lịch và phạt tiền cọc
-- Step 2.1: Bệnh nhân Trần Thị B đặt lịch & xác nhận cọc (CONFIRMED, cọc 300.000đ)
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 2, '2026-09-23 14:00:00', 'CONFIRMED', 300000.00);

-- Step 2.2: Bệnh nhân hủy lịch -> Cập nhật CANCELLED, lý do hủy & phạt 150.000đ
UPDATE Appointments 
SET status = 'CANCELLED',
    cancel_reason = 'Bận việc đột xuất',
    penalty_fee = 150000.00
WHERE appointment_id = 2;

-- ==========================================================
-- TRUY VẤN KIỂM TRA DỮ LIỆU
-- ==========================================================
-- 1. Danh sách bệnh nhân đã hoàn tất khám kèm đơn thuốc
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.appointment_date,
    a.deposit_amount,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';

-- 2. Báo cáo lịch hẹn bị hủy và phí phạt
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    a.deposit_amount,
    a.penalty_fee,
    a.cancel_reason,
    a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
WHERE a.status = 'CANCELLED';
