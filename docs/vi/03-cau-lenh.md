# 03 - Câu lệnh

## Tổng quan các lệnh

| Lệnh | Mô tả |
|------|------|
| `init` | Tạo dự án luận văn mới |
| `build` | Biên dịch luận văn ra PDF |
| `validate` | Kiểm tra tuân thủ quy định CTU |
| `doctor` | Chẩn đoán môi trường |
| `clean` | Xóa file tạm, file build |
| `config` | Quản lý cấu hình người dùng và dự án |
| `chapter` | Thêm, xóa, liệt kê, sắp xếp chương |
| `update` | Cập nhật CLI và/hoặc bộ mẫu |
| `help` | Hiển thị trợ giúp |

---

## `ctu-thesis init`

Tạo một dự án luận văn hoàn chỉnh từ bộ mẫu.

```bash
ctu-thesis init <đường-dẫn-dự-án> [tùy chọn]
```

### Tùy chọn

| Cờ | Mô tả | Mặc định |
|-----|------|----------|
| `--lang=en` | Ngôn ngữ chính | `en` |
| `--lang=vi` | Chế độ tiếng Việt | — |
| `--title="..."` | Tên đề tài | `Your Thesis Title` |
| `--name="..."` | Họ tên sinh viên | `{{STUDENT_NAME}}` (giữ chỗ) |
| `--id="..."` | MSSV | `{{STUDENT_ID}}` (giữ chỗ) |
| `--class="..."` | Lớp | `{{STUDENT_CLASS}}` (giữ chỗ) |
| `--advisor="..."` | GVHD | `{{ADVISOR_NAME}}` (giữ chỗ) |
| `--force` | Ghi đè thư mục đã tồn tại | tắt |

### Ví dụ

```bash
# Luận văn tiếng Việt
ctu-thesis init luan-van --lang=vi --title="Hệ thống gợi ý thương mại điện tử"

# Luận văn tiếng Anh
ctu-thesis init my-thesis --lang=en --title="E-commerce Recommendation System"

# Với đầy đủ thông tin
ctu-thesis init luan-van \
  --lang=vi \
  --title="Học máy trong Y tế" \
  --name="Nguyễn Văn A" \
  --id="B2000001" \
  --class="DI20V8A1" \
  --advisor="TS. Trần Văn B"

# Ghi đè thư mục
ctu-thesis init luan-van --force
```

---

## `ctu-thesis build`

Biên dịch dự án Typst ra PDF.

```bash
ctu-thesis build [tùy chọn]
```

Phải chạy từ bên trong thư mục dự án.

### Tùy chọn

| Cờ | Mô tả |
|-----|------|
| `--watch` | Theo dõi thay đổi và tự động biên dịch lại |
| `--draft` | Biên dịch nhanh (bỏ qua một số định dạng để tăng tốc) |
| `--output=<đường-dẫn>` | Đường dẫn PDF đầu ra (mặc định: `<thư-mục-dự-án>.pdf`) |

### Ví dụ

```bash
# Biên dịch một lần
ctu-thesis build

# Chế độ theo dõi
ctu-thesis build --watch

# Chế độ nháp (nhanh hơn)
ctu-thesis build --draft

# Đường dẫn đầu ra tùy chỉnh
ctu-thesis build --output=build/luan-van-v2.pdf
```

---

## `ctu-thesis validate`

Kiểm tra dự án tuân thủ quy định định dạng CTU.

```bash
ctu-thesis validate [tùy chọn]
```

### Các kiểm tra thực hiện

- Các file và thư mục bắt buộc tồn tại
- Số từ tóm tắt (200–350)
- Số lượng từ khóa (3–5)
- Số tài liệu tham khảo (tối thiểu 15)
- `compliance.json` khớp với `info.typ`
- Chương thiếu hoặc không hợp lệ
- Tham chiếu hình ảnh

### Tùy chọn

| Cờ | Mô tả |
|-----|------|
| `--strict` | Tất cả cảnh báo thành lỗi |
| `--fix` | Tự động sửa các lỗi nhỏ khi có thể |

### Ví dụ

```bash
# Kiểm tra cơ bản
ctu-thesis validate

# Chế độ nghiêm ngặt cho CI/CD
ctu-thesis validate --strict

# Tự động sửa lỗi
ctu-thesis validate --fix
```

### Mã thoát

| Mã | Ý nghĩa |
|----|---------|
| 0 | Tất cả kiểm tra đạt |
| 4 | Xác thực thất bại (cảnh báo hoặc lỗi) |

---

## `ctu-thesis doctor`

Chẩn đoán môi trường của bạn.

```bash
ctu-thesis doctor
```

### Các kiểm tra thực hiện

- Bash phiên bản >= 4.2
- Typst CLI đã cài và phiên bản
- curl khả dụng
- Times New Roman đã cài
- Kết nối Internet
- Bộ mẫu tồn tại và hợp lệ
- `~/.ctu-thesis/config` đọc được

### Ví dụ đầu ra

```
✓ bash 5.2.15 (>= 4.2)
✓ typst 0.12.0 (>= 0.12.0)
✓ curl 8.5.0
✓ Times New Roman đã cài
✓ Internet: đã kết nối
✓ Bộ mẫu: hợp lệ
✓ Config: /home/user/.ctu-thesis/config

Tất cả kiểm tra đạt.
```

---

## `ctu-thesis clean`

Xóa các file tạm và file build khỏi thư mục dự án.

```bash
ctu-thesis clean [tùy chọn]
```

### Xóa bỏ

- `*.pdf` (file luận văn đã biên dịch)
- `*.tmp` (file tạm)
- `*.bak` (file sao lưu)

### Tùy chọn

| Cờ | Mô tả |
|-----|------|
| `--all` | Xóa cả thư mục cache Typst |
| `--dry-run` | Hiển thị những gì sẽ bị xóa mà không xóa thực tế |

### Ví dụ

```bash
# Dọn dẹp cơ bản
ctu-thesis clean

# Dọn dẹp sâu
ctu-thesis clean --all

# Xem trước
ctu-thesis clean --dry-run
```

---

## `ctu-thesis config`

Quản lý cấu hình người dùng và dự án.

```bash
ctu-thesis config [lệnh-con] [tùy chọn]
```

### Lệnh con

| Lệnh con | Mô tả |
|----------|------|
| `set <khóa> <giá-trị>` | Đặt giá trị cấu hình |
| `get <khóa>` | Lấy giá trị cấu hình |
| `list` | Hiển thị tất cả giá trị |
| `unset <khóa>` | Xóa giá trị cấu hình |
| `init` | Tạo `.ctu-thesisrc` từ cấu hình toàn cục |

### Khóa cấu hình

| Khóa | Mô tả | Ví dụ |
|------|-------|-------|
| `student.name` | Họ tên | `Nguyễn Văn A` |
| `student.id` | MSSV | `B2000001` |
| `student.class` | Lớp | `DI20V8A1` |
| `student.major` | Ngành | `Kỹ thuật Phần mềm` |
| `student.program` | Chương trình | `Chương trình Chất lượng cao` |
| `advisor.name` | GVHD | `TS. Trần Văn B` |
| `advisor.title` | Học hàm | `TS.` |
| `defaults.lang` | Ngôn ngữ mặc định | `en` hoặc `vi` |

### Ví dụ

```bash
# Đặt cấu hình toàn cục (dùng bởi `init` khi không có cờ)
ctu-thesis config set student.name "Nguyễn Văn A"
ctu-thesis config set student.id "B2000001"
ctu-thesis config set defaults.lang "vi"

# Xem tất cả cấu hình
ctu-thesis config list

# Khởi tạo cấu hình dự án từ cấu hình toàn cục
cd luan-van
ctu-thesis config init

# Lấy giá trị cụ thể
ctu-thesis config get student.name
```

### Vị trí file cấu hình

| File | Phạm vi |
|------|---------|
| `~/.ctu-thesis/config` | Toàn cục (định dạng ini) |
| `<dự-án>/.ctu-thesisrc` | Theo dự án (ghi đè toàn cục) |

---

## `ctu-thesis chapter`

Quản lý chương trong vùng đánh dấu của `main.typ`.

```bash
ctu-thesis chapter <lệnh-con> [tham-số]
```

### Lệnh con

| Lệnh con | Mô tả |
|----------|------|
| `list` | Liệt kê tất cả chương theo thứ tự |
| `add <tên>` | Thêm chương mới vào cuối danh sách |
| `remove <tên>` | Xóa chương |
| `reorder` | Sắp xếp lại chương tương tác |

### Cách hoạt động

`main.typ` chứa các vùng đánh dấu:

```typst
// -- CTU-THESIS-CHAPTERS-START --
#include "chapters/part1-introduction.typ"
#include "chapters/part2-content.typ"
#include "chapters/part3-conclusion.typ"
// -- CTU-THESIS-CHAPTERS-END --
```

CLI chỉ đọc/ghi giữa các vùng đánh dấu này.

### Ví dụ

```bash
# Liệt kê chương
ctu-thesis chapter list

# Thêm chương mới
ctu-thesis chapter add "chuong4-ket-qua.typ"

# Xóa chương
ctu-thesis chapter remove "phu-luc-cu.typ"

# Sắp xếp lại (giao diện tương tác)
ctu-thesis chapter reorder
```

---

## `ctu-thesis update`

Cập nhật CLI và/hoặc bộ mẫu.

```bash
ctu-thesis update [tùy chọn]
```

### Tùy chọn

| Cờ | Mô tả |
|-----|------|
| `--cli` | Chỉ cập nhật CLI |
| `--templates` | Chỉ cập nhật bộ mẫu |
| `--check` | Kiểm tra cập nhật mà không cài |

### Ví dụ

```bash
# Cập nhật tất cả
ctu-thesis update

# Chỉ cập nhật CLI
ctu-thesis update --cli

# Chỉ cập nhật bộ mẫu
ctu-thesis update --templates

# Kiểm tra cập nhật
ctu-thesis update --check
```

---

## `ctu-thesis help`

Hiển thị trợ giúp cho bất kỳ lệnh nào.

```bash
ctu-thesis help [lệnh]
```

### Ví dụ

```bash
# Trợ giúp chung
ctu-thesis help

# Trợ giúp cho lệnh cụ thể
ctu-thesis help build
ctu-thesis help config
```
