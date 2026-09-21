# BÀI TẬP: XÂY DỰNG CƠ SỞ DỮ LIỆU QUẢN LÝ BÁN HÀNG (`QuanLyBanHang`)

---

## I. MÔ TẢ VÀ PHÂN TÍCH HỆ THỐNG

Cơ sở dữ liệu **`QuanLyBanHang`** được thiết kế nhằm quản lý thông tin khách hàng, hóa đơn, sản phẩm và chi tiết mua hàng trong siêu thị với 4 bảng dữ liệu chuẩn:

1. **`Customer` (Khách hàng)**: Lưu thông tin tất cả khách hàng đến cửa hàng.
   - `cID`: Mã khách hàng (Khóa chính - Primary Key, Tự động tăng - Auto Increment).
   - `cName`: Tên khách hàng (Không được để trống - Not Null).
   - `cAge`: Tuổi của khách hàng (Có kiểm tra ràng buộc `cAge > 0`).

2. **`Order` (Hóa đơn)**: Lưu thông tin hóa đơn khi mua hàng.
   - `oID`: Mã hóa đơn (Khóa chính - Primary Key, Tự động tăng).
   - `cID`: Mã khách hàng mua hàng (Khóa ngoại - Foreign Key tham chiếu `Customer(cID)`).
   - `oDate`: Ngày lập hóa đơn (Kiểu ngày giờ DATETIME).
   - `oTotalPrice`: Tổng tiền hóa đơn (Giá trị mặc định hoặc tính toán).

3. **`Product` (Sản phẩm)**: Lưu thông tin sản phẩm bán tại siêu thị.
   - `pID`: Mã sản phẩm (Khóa chính - Primary Key, Tự động tăng).
   - `pName`: Tên sản phẩm (Không được để trống).
   - `pPrice`: Giá bán sản phẩm (Giá trị kiểm tra `pPrice >= 0`).

4. **`OrderDetail` (Chi tiết hóa đơn)**: Bảng trung gian giải quyết mối quan hệ Nhiều - Nhiều ($N - N$) giữa `Order` và `Product`.
   - `oID`: Khóa ngoại tham chiếu `Order(oID)`.
   - `pID`: Khóa ngoại tham chiếu `Product(pID)`.
   - `odQTY`: Số lượng mua của sản phẩm trong hóa đơn (Kiểm tra `odQTY > 0`).
   - Khóa chính: Tổ hợp (`oID`, `pID`).

---

## II. BẢNG MÔ TẢ CÁC RÀNG BUỘC K khóa VÀ LIÊN KẾT (FOREIGN KEY)

| Tên Bảng | Cột (Field) | Kiểu dữ liệu | Ràng buộc (Constraints) | Diễn giải |
| :--- | :--- | :--- | :--- | :--- |
| **Customer** | `cID` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Khóa chính khách hàng |
| | `cName` | `VARCHAR(50)` | `NOT NULL` | Tên khách hàng |
| | `cAge` | `TINYINT` | `CHECK (cAge > 0)` | Tuổi khách hàng |
| **Order** | `oID` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Khóa chính hóa đơn |
| | `cID` | `INT` | `FOREIGN KEY` $\rightarrow$ `Customer(cID)` | Mã khách hàng (Khóa ngoại) |
| | `oDate` | `DATETIME` | `NOT NULL` | Ngày tạo hóa đơn |
| | `oTotalPrice` | `INT` | `DEFAULT NULL` | Tổng tiền hóa đơn |
| **Product** | `pID` | `INT` | `PRIMARY KEY`, `AUTO_INCREMENT` | Khóa chính sản phẩm |
| | `pName` | `VARCHAR(100)`| `NOT NULL` | Tên sản phẩm |
| | `pPrice` | `INT` | `CHECK (pPrice >= 0)` | Giá bán sản phẩm |
| **OrderDetail**| `oID` | `INT` | `FOREIGN KEY` $\rightarrow$ `Order(oID)` | Mã hóa đơn |
| | `pID` | `INT` | `FOREIGN KEY` $\rightarrow$ `Product(pID)` | Mã sản phẩm |
| | `odQTY` | `INT` | `CHECK (odQTY > 0)` | Số lượng sản phẩm mua |
| | *(oID, pID)* | | `PRIMARY KEY (oID, pID)` | Khóa chính phức hợp |

---

## III. MÃ SQL ĐẦY ĐỦ TẠO CƠ SỞ DỮ LIỆU VÀ CÁC BẢNG (DDL SCRIPT)

```sql
-- 1. Tạo Cơ sở dữ liệu QuanLyBanHang nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS QuanLyBanHang;
USE QuanLyBanHang;

-- 2. Tạo bảng Customer (Khách hàng)
CREATE TABLE Customer (
    cID INT AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(50) NOT NULL,
    cAge TINYINT CHECK (cAge > 0)
);

-- 3. Tạo bảng Order (Hóa đơn)
-- Lưu ý: Từ khóa 'Order' trùng với từ khóa dự phòng của SQL nên dùng cặp dấu trích dẫn ngược `Order`
CREATE TABLE `Order` (
    oID INT AUTO_INCREMENT PRIMARY KEY,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice INT DEFAULT NULL,
    FOREIGN KEY (cID) REFERENCES Customer(cID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. Tạo bảng Product (Sản phẩm)
CREATE TABLE Product (
    pID INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(100) NOT NULL,
    pPrice INT CHECK (pPrice >= 0)
);

-- 5. Tạo bảng OrderDetail (Chi tiết hóa đơn - Bảng trung gian N-N)
CREATE TABLE OrderDetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL CHECK (odQTY > 0),
    PRIMARY KEY (oID, pID),
    FOREIGN KEY (oID) REFERENCES `Order`(oID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (pID) REFERENCES Product(pID) ON DELETE CASCADE ON UPDATE CASCADE
);
```

---

## IV. MÃ SQL CHÈN DỮ LIỆU MẪU KIỂM TRA (DML SCRIPT)

```sql
-- Chèn dữ liệu mẫu vào bảng Customer
INSERT INTO Customer (cName, cAge) VALUES
('Minh Quan', 10),
('Ngoc Oanh', 20),
('Hong Ha', 50);

-- Chèn dữ liệu mẫu vào bảng Product
INSERT INTO Product (pName, pPrice) VALUES
('May Giat', 3),
('Tu Lanh', 5),
('Dieu Hoa', 7),
('Quat', 1),
('Bep Dien', 2);

-- Chèn dữ liệu mẫu vào bảng Order
INSERT INTO `Order` (cID, oDate, oTotalPrice) VALUES
(1, '2006-03-21', NULL),
(2, '2006-03-23', NULL),
(1, '2006-03-16', NULL);

-- Chèn dữ liệu mẫu vào bảng OrderDetail
INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3);
```