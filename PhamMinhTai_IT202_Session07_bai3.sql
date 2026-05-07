-- =========================================
-- CHIẾN DỊCH "ĐÁNH THỨC HỌC VIÊN NGỦ ĐÔNG"
-- =========================================

/*
YÊU CẦU:
Tìm Email của các học viên:
- Có tài khoản trong bảng Students
- Nhưng CHƯA TỪNG mua khóa học nào trong năm 2024
*/


-- =========================================
-- PHÂN TÍCH PERFORMANCE
-- =========================================

/*
1. VÌ SAO NOT EXISTS THẮNG NOT IN?
------------------------------------------------

Bạn A:

WHERE id NOT IN (...)

Bạn B:

WHERE NOT EXISTS (...)

Trong hệ thống lớn (5 triệu users),
NOT EXISTS thường tối ưu hơn.

------------------------------------------------
CƠ CHẾ SHORT-CIRCUIT (DỪNG SỚM)
------------------------------------------------

EXISTS hoạt động kiểu:

"Chỉ cần tìm thấy 1 dòng phù hợp là DỪNG NGAY"

Ví dụ:
- Student id = 100
- Payments có 5000 giao dịch của user này

EXISTS:
- Chỉ cần thấy giao dịch đầu tiên
=> Dừng scan ngay
=> Tiết kiệm CPU + I/O

------------------------------------------------
NOT IN KÉM HƠN Ở ĐIỂM NÀO?
------------------------------------------------

NOT IN thường:
- Phải build toàn bộ tập dữ liệu con
- So sánh toàn bộ danh sách
- Tốn memory hơn

Ngoài ra:
- NOT IN còn cực kỳ nguy hiểm nếu subquery chứa NULL
=> Có thể làm kết quả sai toàn bộ.

------------------------------------------------
NOT EXISTS PHÙ HỢP CHO:
------------------------------------------------

- Anti Join
- Kiểm tra tồn tại
- Dữ liệu lớn
- Correlated Subquery
- Hệ thống production nhiều triệu record
*/


-- =========================================
-- SQL CHUẨN PERFORMANCE
-- =========================================

SELECT s.email
FROM Students s
WHERE NOT EXISTS (
    SELECT 1
    FROM Payments p
    WHERE p.student_id = s.student_id
      AND YEAR(p.payment_date) = 2024
);


-- =========================================
-- GIẢI THÍCH CORRELATED SUBQUERY
-- =========================================

/*
Subquery này là Correlated Subquery vì:

p.student_id = s.student_id

Subquery phụ thuộc trực tiếp
vào từng dòng của query ngoài.

------------------------------------------------
LUỒNG HOẠT ĐỘNG
------------------------------------------------

Với mỗi học viên trong Students:

1. MySQL kiểm tra:
   Có payment nào trong năm 2024 không?

2. Nếu tìm thấy:
   EXISTS = TRUE
   => NOT EXISTS = FALSE
   => Loại user

3. Nếu không tìm thấy:
   EXISTS = FALSE
   => NOT EXISTS = TRUE
   => Giữ lại user

------------------------------------------------
KẾT QUẢ:
------------------------------------------------

Danh sách email của:
- Người có tài khoản
- Nhưng chưa mua gì trong năm 2024
*/