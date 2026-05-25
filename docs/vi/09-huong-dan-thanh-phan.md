# 09 - Hướng dẫn: Hình ảnh, Bảng biểu, Công thức, Mã nguồn

> # ⚠️  TUYÊN BỐ MIỄN TRỪ TRÁCH NHIỆM — VUI LÒNG ĐỌC
>
> **Đây KHÔNG phải là tài liệu chính thức của ĐHCT.** Đây là diễn giải của cộng đồng dựa trên **Quyết định 4125/QĐ-ĐHCT** (06/08/2024).
>
> - Quy định định dạng **có thể khác nhau tùy bộ môn** và **thay đổi không báo trước**.
> - **Luôn xác nhận** với giảng viên hướng dẫn và văn phòng khoa trước khi nộp bài chính thức.
> - Phát hiện lỗi? [**Báo lỗi tại đây.**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)

## Hình ảnh

### Đánh số

Tuần tự trong mỗi chương: Hình 1.1, 1.2, 2.1, 2.2, v.v.

### Định dạng chú thích

```
Hình 1.1. Sơ đồ Kiến trúc Hệ thống
```

Chú thích nằm **dưới** hình.

### Vị trí

| Thuộc tính | Giá trị |
|-----------|---------|
| Canh lề | Canh giữa trang |
| Vị trí chú thích | Dưới hình (cách 0.3cm) |
| Khoảng cách khối | 0.6cm trước và sau |

### Yêu cầu chất lượng

| Thuộc tính | Giá trị |
|-----------|---------|
| Độ phân giải tối thiểu | 300 DPI |
| Định dạng ưu tiên | Đồ họa vector (SVG, PDF) |
| Văn bản trong sơ đồ | Rõ ràng, dễ đọc |
| Trình bày | Chuyên nghiệp |

### Tham chiếu trong văn bản

```
Như được thể hiện trong Hình 1.1, hệ thống...
```

### Cách dùng trong Typst

```typst
#figure(
  image("../images/chapter1/kien-truc.png", width: 80%),
  caption: [Sơ đồ Kiến trúc Hệ thống],
) <hinh-kien-truc>

Tham chiếu bằng @hinh-kien-truc.
```

---

## Bảng biểu

### Đánh số

Tuần tự trong mỗi chương: Bảng 1.1, 1.2, 2.1, 2.2, v.v.

### Định dạng chú thích

```
Bảng 2.1. Kết quả So sánh Hiệu năng
```

Chú thích nằm **trên** bảng.

### Vị trí

| Thuộc tính | Giá trị |
|-----------|---------|
| Canh lề | Canh giữa trang |
| Vị trí chú thích | Trên bảng (cách 0.3cm) |
| Khoảng cách khối | 0.6cm trước và sau |

### Quy tắc định dạng

| Quy tắc | Mô tả |
|---------|-------|
| Đường viền | Đơn giản, không dùng nét đậm |
| Hàng tiêu đề | In đậm |
| Canh văn bản | Văn bản canh trái, số liệu canh phải |
| Độ rộng cột | Nhất quán |

### Tham chiếu trong văn bản

```
Bảng 2.1 cho thấy các chỉ số hiệu năng...
```

### Cách dùng trong Typst

```typst
#figure(
  table(
    columns: 3,
    [Phương pháp], [Độ chính xác], [Độ bao phủ],
    [SVM], [0.92], [0.88],
    [CNN], [0.95], [0.91],
  ),
  caption: [So sánh Hiệu năng Mô hình],
) <bang-hieu-nang>
```

---

## Công thức toán học

### Đánh số

Tuần tự trong mỗi chương: (1.1), (1.2), (2.1), v.v.

### Định dạng

```
    E = mc²                                    (1.1)
```

- Thân công thức canh giữa
- Số thứ tự canh phải trong ngoặc đơn
- Khoảng cách 0.3cm trên và dưới

### Tham chiếu trong văn bản

```
Công thức (1.1) mô tả...
```

### Cách dùng trong Typst

```typst
$ E = m c^2 $ <cthuc-einstein>

Tham chiếu bằng @cthuc-einstein.
```

---

## Đoạn mã

### Định dạng

| Thuộc tính | Giá trị |
|-----------|---------|
| Phông chữ | Courier New hoặc Consolas, 10pt |
| Nền | Xám nhạt (#F5F5F5) |
| Viền | Xám 0.5pt |
| Đệm | 0.3cm các cạnh |
| Giãn dòng | Đơn (1.0) |

### Tô màu cú pháp

Khuyến khích nhưng không bắt buộc.

### Chú thích (tùy chọn)

```
Đoạn mã 2.1. Hàm tính tổng giá tiền
```

### Cách dùng trong Typst

```typst
```python
def calculate_total(items):
    """Tính tổng giá tiền."""
    return sum(item.price for item in items)
```
```

---

## Giải thuật

### Định dạng

Mã giả (Pseudocode) hoặc văn bản có cấu trúc.

### Ví dụ

```
Algorithm 1: Binary Search
Input: Sorted array A, target value x
Output: Index of x in A, or -1 if not found

1: left ← 0
2: right ← length(A) - 1
3: while left ≤ right do
4:     mid ← ⌊(left + right) / 2⌋
5:     if A[mid] = x then
6:         return mid
7:     else if A[mid] < x then
8:         left ← mid + 1
9:     else
10:        right ← mid - 1
11: end while
12: return -1
```

---

## Sơ đồ kỹ thuật

### Loại sơ đồ chấp nhận

- Sơ đồ kiến trúc hệ thống
- Sơ đồ UML (class, sequence, use case)
- Sơ đồ thực thể liên kết (ERD)
- Lưu đồ (Flowcharts)
- Sơ đồ mạng

### Công cụ khuyên dùng

- Draw.io (miễn phí, trực tuyến)
- Lucidchart (có gói miễn phí)
- PlantUML (miễn phí, dựa trên văn bản)
- Microsoft Visio

### Yêu cầu

- Nhãn rõ ràng
- Ký hiệu nhất quán
- Trình bày chuyên nghiệp
- Độ phân giải cao (300+ DPI cho raster, ưu tiên vector)

---

## Nguồn Tham Khảo Chính Thức

- **Quyết định 4125/QĐ-ĐHCT** (06/08/2024) — Quy định hình thức trình bày luận văn toàn trường (liên hệ văn phòng khoa)
- **Trường CNTT&TT** — [cict.ctu.edu.vn](https://cict.ctu.edu.vn/)
- **Trung tâm Học liệu ĐHCT** — [lrc.ctu.edu.vn](https://lrc.ctu.edu.vn/)

> Luôn đối chiếu với văn phòng khoa để có yêu cầu mới nhất.
