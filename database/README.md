# Task 3: Database

## Cấu trúc Dự án

```
database/
├── station_management.sql    # Script tạo database và insert data
├── STATION_MANAGEMENT_ERD.png # Sơ đồ ERD của database
└── README.md                # Tài liệu
```

## Mô tả

Database MySQL cho hệ thống quản lý trạm xăng với đầy đủ cấu trúc bảng và dữ liệu mẫu.

### Các bảng chính:

- **STATION** - Thông tin trạm xăng
- **PRODUCT** - Sản phẩm xăng dầu
- **EMPLOYEE** - Nhân viên
- **CUSTOMER** - Khách hàng
- **PUMP** - Trụ bơm xăng
- **TRANSACTION** - Giao dịch bán hàng
- **TRANSACTION_DETAIL** - Chi tiết giao dịch
- **PAYMENT** - Thanh toán

### Tính năng:

- Cấu trúc database đầy đủ với ràng buộc
- Dữ liệu mẫu cho test
- Foreign key relationships
- Constraints và validations
- Indexes cho performance

## Cách Thực thi

### Cài đặt Database:

1. **Mở online compiler MySQL:**

   Truy cập đường link: https://onecompiler.com/mysql

2. **Chạy script:**

   - Copy script từ file `station_management.sql` và paste vào
   - Nhấn `RUN` để xem kết quả

### Xem ERD:

Mở file `STATION_MANAGEMENT_ERD.png` để xem sơ đồ quan hệ các bảng.
