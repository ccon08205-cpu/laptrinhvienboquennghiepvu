# AI Prompt Log - Nhật Ký Tương Tác AI
**Dự án:** Cấu trúc lại CSDL HealthSync

---

### Prompt 1: Tìm hiểu Anti-pattern trong theo dõi trạng thái
* **User Prompt:** "Trong thiết kế cơ sở dữ liệu quan hệ, tại sao việc dùng một cột is_active (kiểu TINYINT/BOOLEAN) để theo dõi vòng đời của một Đơn hàng/Lịch hẹn lại là một thiết kế tồi (Anti-pattern)? Tôi nên thay thế bằng cấu trúc nào trong MySQL?"
* **AI Application:** AI phân tích rằng BOOLEAN không thể biểu diễn Finite State Machine (FSM) gồm 5 trạng thái của quy trình. Khuyên dùng `ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED')`. Tôi đã áp dụng cấu trúc này vào bảng `Appointments`.

---

### Prompt 2: Lựa chọn kiểu dữ liệu tài chính
* **User Prompt:** "Khi thiết kế cột deposit_amount và penalty_fee trong MySQL phục vụ tính toán tài chính, tôi nên dùng kiểu dữ liệu FLOAT, DOUBLE hay DECIMAL? Tại sao?"
* **AI Application:** AI giải thích lỗi làm tròn số thực của `FLOAT`/`DOUBLE` trong tính toán tiền tệ và khuyên dùng `DECIMAL(10,2)` để đảm bảo độ chính xác tuyệt đối. Tôi đã áp dụng kiểu `DECIMAL` cho 2 trường tiền cọc và phí phạt.

---

### Prompt 3: Ràng buộc toàn vẹn dữ liệu
* **User Prompt:** "Hãy cho tôi xem cú pháp TRIGGER trong MySQL để ngăn chặn việc chèn đơn thuốc (Prescriptions) nếu trạng thái lịch hẹn chưa phải là COMPLETED?"
* **AI Application:** AI hướng dẫn cú pháp `BEFORE INSERT ON Prescriptions` sử dụng `SIGNAL SQLSTATE '45000'`. Tôi dùng kiến thức này để chuẩn bị cho phần vấn đáp bảo vệ thiết kế với Giảng viên.
