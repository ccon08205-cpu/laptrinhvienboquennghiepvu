# Báo Cáo Phân Tích Sự Bất Nhất (Gap Analysis Report)
**Dự án:** Hệ thống Quản lý Phòng khám HealthSync
**Người thực hiện:** System Analyst & DBA

## 1. Tổng quan
Đối chiếu giữa **UML Activity Diagram** do BA thiết kế và **Legacy SQL Script** ban đầu, chúng tôi phát hiện 3 điểm bất nhất nghiêm trọng khiến hệ thống liên tục phát sinh lỗi nghiệp vụ khi vận hành.

## 2. 3 Điểm vênh nghiêm trọng nhất
1. **Sai lệch kiểu dữ liệu quản lý vòng đời lịch hẹn (Status Tracking):**
   * *Nghiệp vụ:* Lịch hẹn trải qua 5 trạng thái: `PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` / `CANCELLED`.
   * *Legacy SQL:* Dùng `is_active BOOLEAN` (chỉ có 2 giá trị True/False). Thiết kế này hoàn toàn vô hiệu hóa khả năng theo dõi tiến trình khám bệnh.
2. **Thiếu hụt trường dữ liệu tài chính và xử lý vi phạm hợp đồng:**
   * *Nghiệp vụ:* Bệnh nhân đóng tiền cọc (`Deposit`), khi hủy lịch sau khi xác nhận phải chịu phí phạt (`Penalty Fee`) trừ vào cọc và lưu lý do hủy.
   * *Legacy SQL:* Thiếu hoàn toàn các cột `deposit_amount`, `penalty_fee`, và `cancel_reason`. Kế toán không thể đối soát dòng tiền cọc/phạt, gây thất thoát doanh thu.
3. **Thiếu hụt thực thể Đơn thuốc (Prescription Entity):**
   * *Nghiệp vụ:* Khi lịch hẹn chuyển sang `COMPLETED`, bác sĩ kê đơn thuốc đi kèm lịch hẹn.
   * *Legacy SQL:* Bỏ quên hoàn toàn bảng `Prescriptions` và quan hệ khóa ngoại kết nối với `Appointments`, làm đứt gãy luồng nghiệp vụ khám chữa bệnh chính.

## 3. Giải pháp
Tái cấu trúc bảng `Appointments` bằng kiểu `ENUM` cho trạng thái, `DECIMAL(10,2)` cho tiền cọc/phạt, đồng thời tạo mới bảng `Prescriptions` với ràng buộc `FOREIGN KEY` duy nhất (1-1) trỏ về `Appointments`.
