# 02 - Bắt đầu Nhanh

## Trong 5 phút

### Bước 1: Tạo dự án luận văn mới

```bash
ctu-thesis init luan-van --lang=vi --title="Tên Đề Tài của Bạn"
```

Lệnh này tạo một dự án luận văn hoàn chỉnh, có thể biên dịch ngay trong thư mục `luan-van/`.

### Bước 2: Vào thư mục dự án

```bash
cd luan-van
```

### Bước 3: Sửa thông tin cá nhân

Mở file `info.typ` và thay thế các giá trị mẫu bằng thông tin thực tế của bạn:

```typst
// info.typ — sửa file này đầu tiên
vi: (
  student: (
    name: "Nguyễn Văn A",        // Họ và tên
    id: "B2000001",               // Mã số sinh viên
    class: "DI20V8A1",            // Lớp
    major: "Kỹ thuật Phần mềm",
    program: "Chương trình Chất lượng cao",
  ),
  advisor: (
    name: "TS. Trần Văn B",       // Giảng viên hướng dẫn
    title: "TS.",
  ),
  thesis: (
    title: "Tên Đề Tài của Bạn",
    short_title: "Tên Rút Gọn",
    date: "Tháng 5, 2026",
    location: "Cần Thơ",
    degree: "KỸ SƯ CÔNG NGHỆ THÔNG TIN",
  ),
  keywords: (
    "từ khóa 1", "từ khóa 2", "từ khóa 3",
    "từ khóa 4", "từ khóa 5"
  ),
  // ...
)
```

### Bước 4: Biên dịch luận văn

```bash
# Biên dịch một lần
ctu-thesis build

# Chế độ theo dõi (tự động biên dịch khi lưu file)
ctu-thesis build --watch
```

File PDF được tạo tại thư mục gốc của dự án (mặc định: `luan-van.pdf`).

### Bước 5: Bắt đầu viết

Vào thư mục `chapters/part1/01-context.typ` và bắt đầu viết phần giới thiệu.

```bash
# Xem danh sách chương
ctu-thesis chapter list

# Thêm chương mới
ctu-thesis chapter add "04-thuc-nghiem.typ"
```

### Các bước tiếp theo

- [Cấu hình](04-cau-hinh.md) — chi tiết về `info.typ` và `.ctu-thesisrc`
- [Câu lệnh](03-cau-lenh.md) — tất cả các lệnh CLI
- [Hướng dẫn: Tổng quan](06-huong-dan-tong-quan.md) — quy định định dạng CTU
- [Khắc phục lỗi](12-khac-phuc-loi.md) — các vấn đề phổ biến và cách sửa
