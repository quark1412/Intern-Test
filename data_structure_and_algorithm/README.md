# Task 4: Data Structure & Algorithm

## Cấu trúc Dự án

```
data_structure_and_algorithm/
├── script.js           # File chương trình
├── package.json        # Node.js dependencies và configs
├── package-lock.json
└── README.md          # Tài liệu
```

## Thuật toán

### Phương pháp: Sử dụng Prefix Sum Array

Sử dụng **Prefix Sum** để xử lý dữ liệu, sau đó tính toán mỗi truy vấn.

#### 1. Loại 1 (Tổng khoảng)

```javascript
// Tiền xử lý: O(n)
prefixSum[i] = tổng các phần tử từ chỉ số 0 đến i-1

// Xử lý truy vấn: O(1)
sum[l, r] = prefixSum[r + 1] - prefixSum[l]
```

#### 2. Loại 2 (Tổng/hiệu Xen kẽ)

```javascript
// Tiền xử lý: O(n) - Xây dựng prefix sum array riêng cho chỉ số chẵn/lẻ
prefixEven[i] = tổng các phần tử tại chỉ số chẵn từ 0 đến i-1
prefixOdd[i] = tổng các phần tử tại chỉ số lẻ từ 0 đến i-1

// Xử lý truy vấn: O(1)
nếu (l là chẵn):
    kết quả = (tổng chẵn trong khoảng) - (tổng lẻ trong khoảng)
ngược lại:
    kết quả = (tổng lẻ trong khoảng) - (tổng chẵn trong khoảng)
```

### Triển khai

**Dữ liệu:**

- `prefixSum[]`: Mảng tổng tiền tố cho truy vấn Loại 1
- `prefixEven[]`: Tổng tiền tố các phần tử tại chỉ số chẵn
- `prefixOdd[]`: Tổng tiền tố các phần tử tại chỉ số lẻ

**Hàm Chính:**

- `preCompute()`: Xử lý mảng đầu vào (O(n))
- `calculate()`: Xử lý từng truy vấn (O(1))
- `solve()`: Điều phối quá trình giải quyết

## Cách Chạy

### Cài đặt & Thực thi

1. **Di chuyển đến thư mục dự án:**

   ```bash
   cd data_structure_and_algorithm
   ```

2. **Cài đặt deps:**

   ```bash
   npm install
   ```

3. **Chạy chương trình:**
   ```bash
   node script.js
   ```
