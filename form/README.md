# Task 2: Form

## Cấu trúc Dự án

```
form/
├── src/
│   ├── App.tsx         # Component form chính
│   ├── main.tsx        # Entry point
│   └── App.css         # Styles
├── package.json        # React + Vite dependencies và configs
├── package-lock.json
└── README.md          # Tài liệu
```

## Mô tả

Ứng dụng React form với validation để nhập liệu dữ liệu trạm xăng.

### Tính năng:

- Form nhập liệu với validation
- Date picker cho chọn thời gian
- Tính toán tự động doanh thu
- Toast notifications
- Interface responsive với Tailwind CSS

### Công nghệ:

- **React 19** - UI framework
- **TypeScript** - Type safety
- **React Hook Form** - Form management
- **Yup** - Schema validation
- **React DatePicker** - Date selection
- **React Hot Toast** - Notifications
- **Tailwind CSS** - Styling

## Cách Chạy

### Cài đặt & Thực thi

1. **Di chuyển đến thư mục dự án:**

   ```bash
   cd form
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
