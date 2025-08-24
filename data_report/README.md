# Task 1: Data Report

## Cấu trúc Dự án

```
data_report/
├── src/
│   ├── App.tsx         # Component chính
│   ├── main.tsx        # Entry point
│   └── assets/
│       └── report.xlsx # File dữ liệu Excel
├── package.json        # React + Vite dependencies và configs
├── package-lock.json
└── README.md          # Tài liệu
```

## Mô tả

Ứng dụng React để đọc, tính toán và hiển thị báo cáo dữ liệu từ file Excel.

### Tính năng:

- Đọc file Excel (.xlsx)
- Hiển thị dữ liệu dưới dạng bảng
- Interface responsive với Tailwind CSS
- Xử lý dữ liệu giao dịch trạm xăng

### Công nghệ:

- **React 19** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **XLSX** - Xử lý file Excel

## Cách Chạy

### Cài đặt & Thực thi

1. **Di chuyển đến thư mục dự án:**

   ```bash
   cd data_report
   ```

2. **Cài đặt deps:**

   ```bash
   npm install
   ```

3. **Chạy chương trình:**

   ```bash
   npm run dev
   ```

4. **Mở trình duyệt:** `http://localhost:5173`
