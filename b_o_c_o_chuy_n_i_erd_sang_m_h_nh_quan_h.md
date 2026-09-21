# BÀI LÀM: CHUYỂN ĐỔI SƠ ĐỒ ERD SANG MÔ HÌNH QUAN HỆ

---

## BƯỚC 1: XÁC ĐỊNH CÁC THỰC THỂ CÓ TRONG MÔ HÌNH ERD

Dựa vào sơ đồ ERD quản lý vật tư, hệ thống gồm **5 thực thể chính** (ký hiệu bằng hình chữ nhật) cùng các thuộc tính (hình elip):

1. **PHIEUXUAT**: Quản lý các phiếu xuất kho.
   - Thuộc tính: `SoPX` (Khóa chính - gạch chân), `NgayXuat`.
2. **VATTU**: Quản lý danh mục vật tư.
   - Thuộc tính: `MaVTU` (Khóa chính - gạch chân), `TenVTU`.
3. **PHIEUNHAP**: Quản lý các phiếu nhập kho.
   - Thuộc tính: `SoPN` (Khóa chính - gạch chân), `NgayNhap`.
4. **DONDH**: Quản lý các đơn đặt hàng gửi cho nhà cung cấp.
   - Thuộc tính: `SoDH` (Khóa chính - gạch chân), `NgayDH`.
5. **NHACC**: Quản lý thông tin nhà cung cấp.
   - Thuộc tính: `MaNCC` (Khóa chính - gạch chân), `TenNCC`, `DiaChi`, `SĐT` (Thuộc tính đa trị - elip viền đôi).

---

## BƯỚC 2: XÁC ĐỊNH VÀ CHUYỂN ĐỔI CÁC MỐI QUAN HỆ (Khóa ngoại & Bảng trung gian)

### 1. Quan hệ giữa PHIEUXUAT và VATTU (Chi tiết xuất)
- **Loại quan hệ**: Nhiều - Nhiều ($N - N$). Một phiếu xuất có nhiều vật tư, một vật tư xuất ở nhiều phiếu.
- **Xử lý**: Tạo bảng trung gian `ChiTietPhieuXuat`.
- **Thành phần**:
  - `SoPX`: Khóa ngoại tham chiếu `PHIEUXUAT(SoPX)`.
  - `MaVTU`: Khóa ngoại tham chiếu `VATTU(MaVTU)`.
  - Thuộc tính riêng: `DGXuat` (Đơn giá xuất), `SLXuat` (Số lượng xuất).
  - Khóa chính: Tổ hợp (`SoPX`, `MaVTU`).

### 2. Quan hệ giữa PHIEUNHAP và VATTU (Chi tiết nhập)
- **Loại quan hệ**: Nhiều - Nhiều ($N - N$).
- **Xử lý**: Tạo bảng trung gian `ChiTietPhieuNhap`.
- **Thành phần**:
  - `SoPN`: Khóa ngoại tham chiếu `PHIEUNHAP(SoPN)`.
  - `MaVTU`: Khóa ngoại tham chiếu `VATTU(MaVTU)`.
  - Thuộc tính riêng: `DGNhap` (Đơn giá nhập), `SLNhap` (Số lượng nhập).
  - Khóa chính: Tổ hợp (`SoPN`, `MaVTU`).

### 3. Quan hệ giữa DONDH và VATTU (Chi tiết đơn hàng)
- **Loại quan hệ**: Nhiều - Nhiều ($N - N$).
- **Xử lý**: Tạo bảng trung gian `ChiTietDonDatHang`.
- **Thành phần**:
  - `SoDH`: Khóa ngoại tham chiếu `DONDH(SoDH)`.
  - `MaVTU`: Khóa ngoại tham chiếu `VATTU(MaVTU)`.
  - Khóa chính: Tổ hợp (`SoDH`, `MaVTU`).

### 4. Quan hệ giữa NHACC và DONDH (Cung cấp)
- **Loại quan hệ**: Một - Nhiều ($1 - N$). Một nhà cung cấp có thể nhận nhiều đơn đặt hàng.
- **Xử lý**: Đưa Khóa chính của bên (1) là `NHACC(MaNCC)` làm **Khóa ngoại** sang bảng bên (N) là `DONDH`.
- **Thành phần**: Bổ sung cột `MaNCC` (Khóa ngoại) vào bảng `DONDH`.

---

## BƯỚC 3: XỬ LÝ THUỘC TÍNH ĐA TRỊ

- Trong thực thể `NHACC`, thuộc tính `SĐT` là **thuộc tính đa trị** (ký hiệu bằng nét đôi).
- **Quy tắc chuyển đổi**: Tách thuộc tính đa trị thành một bảng độc lập tên là `NhaCungCap_SDT`.
- **Thành phần**:
  - `MaNCC`: Khóa ngoại tham chiếu tới `NHACC(MaNCC)`.
  - `SDT`: Số điện thoại liên hệ.
  - Khóa chính: Tổ hợp (`MaNCC`, `SDT`).

---

## BƯỚC 4: DANH SÁCH BẢNG MÔ HÌNH QUAN HỆ HOÀN CHỈNH

*(Quy ước: **In đậm gạch chân** = Khóa chính, *In nghiêng* = Khóa ngoại)*

1. **PHIEUXUAT** (**<u>SoPX</u>**, NgayXuat)
2. **VATTU** (**<u>MaVTU</u>**, TenVTU)
3. **PHIEUNHAP** (**<u>SoPN</u>**, NgayNhap)
4. **NHACC** (**<u>MaNCC</u>**, TenNCC, DiaChi)
5. **NhaCungCap_SDT** (**<u>MaNCC</u>**, **<u>SDT</u>**)
   - *MaNCC* (FK) $\rightarrow$ `NHACC(MaNCC)`
6. **DONDH** (**<u>SoDH</u>**, NgayDH, *MaNCC*)
   - *MaNCC* (FK) $\rightarrow$ `NHACC(MaNCC)`
7. **ChiTietPhieuXuat** (**<u>SoPX</u>**, **<u>MaVTU</u>**, DGXuat, SLXuat)
   - *SoPX* (FK) $\rightarrow$ `PHIEUXUAT(SoPX)`
   - *MaVTU* (FK) $\rightarrow$ `VATTU(MaVTU)`
8. **ChiTietPhieuNhap** (**<u>SoPN</u>**, **<u>MaVTU</u>**, DGNhap, SLNhap)
   - *SoPN* (FK) $\rightarrow$ `PHIEUNHAP(SoPN)`
   - *MaVTU* (FK) $\rightarrow$ `VATTU(MaVTU)`
9. **ChiTietDonDatHang** (**<u>SoDH</u>**, **<u>MaVTU</u>**)
   - *SoDH* (FK) $\rightarrow$ `DONDH(SoDH)`
   - *MaVTU* (FK) $\rightarrow$ `VATTU(MaVTU)`

---

## MÃ SQL TẠO BẢNG CÓ ĐẦY ĐỦ RÀNG BUỘC KHOÁ NGOẠI (DDL)

```sql
-- Tạo cơ sở dữ liệu
CREATE DATABASE IF NOT EXISTS QuanLyVatTu;
USE QuanLyVatTu;

-- 1. Bảng PHIEUXUAT
CREATE TABLE PHIEUXUAT (
    SoPX VARCHAR(20) PRIMARY KEY,
    NgayXuat DATETIME NOT NULL
);

-- 2. Bảng VATTU
CREATE TABLE VATTU (
    MaVTU VARCHAR(20) PRIMARY KEY,
    TenVTU VARCHAR(100) NOT NULL
);

-- 3. Bảng PHIEUNHAP
CREATE TABLE PHIEUNHAP (
    SoPN VARCHAR(20) PRIMARY KEY,
    NgayNhap DATETIME NOT NULL
);

-- 4. Bảng NHACC
CREATE TABLE NHACC (
    MaNCC VARCHAR(20) PRIMARY KEY,
    TenNCC VARCHAR(100) NOT NULL,
    DiaChi VARCHAR(200)
);

-- 5. Bảng thuộc tính đa trị SĐT Nhà cung cấp
CREATE TABLE NhaCungCap_SDT (
    MaNCC VARCHAR(20),
    SDT VARCHAR(15),
    PRIMARY KEY (MaNCC, SDT),
    FOREIGN KEY (MaNCC) REFERENCES NHACC(MaNCC) ON DELETE CASCADE
);

-- 6. Bảng DONDH (Chứa khóa ngoại MaNCC)
CREATE TABLE DONDH (
    SoDH VARCHAR(20) PRIMARY KEY,
    NgayDH DATETIME NOT NULL,
    MaNCC VARCHAR(20) NOT NULL,
    FOREIGN KEY (MaNCC) REFERENCES NHACC(MaNCC)
);

-- 7. Bảng ChiTietPhieuXuat (Bảng trung gian N-N)
CREATE TABLE ChiTietPhieuXuat (
    SoPX VARCHAR(20),
    MaVTU VARCHAR(20),
    DGXuat DECIMAL(18, 2) NOT NULL CHECK (DGXuat >= 0),
    SLXuat INT NOT NULL CHECK (SLXuat > 0),
    PRIMARY KEY (SoPX, MaVTU),
    FOREIGN KEY (SoPX) REFERENCES PHIEUXUAT(SoPX),
    FOREIGN KEY (MaVTU) REFERENCES VATTU(MaVTU)
);

-- 8. Bảng ChiTietPhieuNhap (Bảng trung gian N-N)
CREATE TABLE ChiTietPhieuNhap (
    SoPN VARCHAR(20),
    MaVTU VARCHAR(20),
    DGNhap DECIMAL(18, 2) NOT NULL CHECK (DGNhap >= 0),
    SLNhap INT NOT NULL CHECK (SLNhap > 0),
    PRIMARY KEY (SoPN, MaVTU),
    FOREIGN KEY (SoPN) REFERENCES PHIEUNHAP(SoPN),
    FOREIGN KEY (MaVTU) REFERENCES VATTU(MaVTU)
);

-- 9. Bảng ChiTietDonDatHang (Bảng trung gian N-N)
CREATE TABLE ChiTietDonDatHang (
    SoDH VARCHAR(20),
    MaVTU VARCHAR(20),
    PRIMARY KEY (SoDH, MaVTU),
    FOREIGN KEY (SoDH) REFERENCES DONDH(SoDH),
    FOREIGN KEY (MaVTU) REFERENCES VATTU(MaVTU)
);
```