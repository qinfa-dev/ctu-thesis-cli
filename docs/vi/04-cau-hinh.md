# 04 - Cấu hình

## Các lớp cấu hình

CTU Thesis CLI sử dụng hai lớp cấu hình:

| Lớp | File | Phạm vi | Ghi đè |
|------|------|---------|--------|
| **Toàn cục** | `~/.ctu-thesis/config` | Tất cả dự án trên máy này | — |
| **Dự án** | `<dự-án>/.ctu-thesisrc` | Chỉ dự án này | Toàn cục |

---

## Cấu hình toàn cục (`~/.ctu-thesis/config`)

File định dạng ini (khóa=giá trị). Được tạo tự động khi chạy `ctu-thesis config set` lần đầu.

```ini
# Cấu hình toàn cục CTU Thesis CLI
student.name=Nguyễn Văn A
student.id=B2000001
student.class=DI20V8A1
student.major=Kỹ thuật Phần mềm
student.program=Chương trình Chất lượng cao
advisor.name=TS. Trần Văn B
advisor.title=TS.
defaults.lang=vi
```

### Đặt giá trị

```bash
ctu-thesis config set student.name "Nguyễn Văn A"
ctu-thesis config set student.id "B2000001"
ctu-thesis config set defaults.lang "vi"
```

### Đọc giá trị

```bash
ctu-thesis config get student.name
# Nguyễn Văn A
```

### Liệt kê tất cả

```bash
ctu-thesis config list
```

### Xóa giá trị

```bash
ctu-thesis config unset student.class
```

---

## Cấu hình dự án (`.ctu-thesisrc`)

Được tạo trong thư mục gốc dự án. Dùng để lưu các ghi đè cụ thể theo dự án.

```bash
cd luan-van
ctu-thesis config init
```

Lệnh này sao chép cấu hình toàn cục vào `<dự-án>/.ctu-thesisrc`. Sau đó bạn có thể sửa file trực tiếp để tùy chỉnh theo dự án.

```ini
# Cấu hình dự án CTU Thesis CLI
student.name=Nguyễn Văn A
student.id=B2000001
```

---

## `info.typ` — Thông tin luận văn

File `info.typ` trong dự án chứa tất cả thông tin luận văn. Đây là **nguồn thông tin duy nhất** cho việc biên dịch.

### Cấu trúc

```typst
#let info = (
  en: (                          // Thông tin tiếng Anh
    student: (
      name: "Họ và Tên",
      id: "B2000001",
      class: "DI20V8A1",
      major: "Software Engineering",
      program: "High-Quality Program",
    ),
    advisor: (
      name: "TS. Tên GVHD",
      title: "Dr.",
    ),
    thesis: (
      title: "Tên Đề Tài",
      short_title: "Tên Rút Gọn",
      date: "May 2026",
      location: "Can Tho",
      degree: "BACHELOR OF ENGINEERING IN INFORMATION TECHNOLOGY",
    ),
    keywords: ("kw1", "kw2", "kw3", "kw4", "kw5"),
    committee: (
      chairman: "Dr. Tên Chủ Tịch",
      reviewer: "Dr. Tên Phản Biện",
      advisor: "Dr. Tên GVHD",
    ),
    abbreviations: (
      ("API", "Application Programming Interface"),
      ("CTU", "Can Tho University"),
    ),
  ),
  vi: (                          // Thông tin tiếng Việt
    student: (
      name: "Họ và Tên",
      id: "B2000001",
      class: "DI20V8A1",
      major: "Kỹ thuật Phần mềm",
      program: "Chương trình Chất lượng cao",
    ),
    advisor: (
      name: "TS. Tên GVHD",
      title: "TS.",
    ),
    thesis: (
      title: "Tên Luận Văn của Bạn",
      short_title: "Tên Rút Gọn",
      date: "Tháng 5, 2026",
      location: "Cần Thơ",
      degree: "KỸ SƯ CÔNG NGHỆ THÔNG TIN",
    ),
    keywords: ("kw1", "kw2", "kw3", "kw4", "kw5"),
    committee: (
      chairman: "TS. Tên Chủ Tịch",
      reviewer: "TS. Tên Phản Biện",
      advisor: "TS. Tên GVHD",
    ),
    abbreviations: (
      ("API", "Giao diện lập trình ứng dụng"),
      ("CTU", "Đại học Cần Thơ"),
    ),
  ),
)

#let settings = (
  primary_lang: "vi",            // "en" hoặc "vi"

  border_color: rgb(0, 51, 153),    // Xanh CTU #003399
  accent_color: rgb(0, 83, 159),    // Xanh CTU nhấn #00539F

  format: (
    font: "Times New Roman",
    font_size: 13pt,
    line_spacing: 1.2,
    margins: (
      left: 4cm,
      right: 2.5cm,
      top: 2.5cm,
      bottom: 2.5cm,
    ),
    paragraph_indent: 1cm,
    abstract_words: (200, 350),
  ),
)
```

### Mô tả các trường chính

| Trường | Bắt buộc | Mô tả |
|--------|----------|-------|
| `student.name` | Có | Họ tên (xuất hiện trên bìa) |
| `student.id` | Có | MSSV (định dạng B...) |
| `student.class` | Có | Mã lớp |
| `student.major` | Có | Tên ngành |
| `student.program` | Không | Loại chương trình (VD: Chất lượng cao) |
| `advisor.name` | Có | Họ tên GVHD |
| `advisor.title` | Có | Học hàm (TS., PGS., v.v.) |
| `thesis.title` | Có | Tên đề tài đầy đủ (2-3 dòng) |
| `thesis.short_title` | Có | Tên rút gọn cho header (tối đa 50 ký tự) |
| `thesis.date` | Có | Ngày hoàn thành |
| `thesis.location` | Có | Tên thành phố |
| `thesis.degree` | Có | Tên bằng cấp |
| `keywords` | Có | 3-5 từ khóa |
| `committee` | Có | Thành viên hội đồng |
| `abbreviations` | Không | Danh sách (viết tắt, giải thích) |

---

## `compliance.json`

Nằm trong bộ mẫu và được `validate` kiểm tra. Phản ánh các giá trị định dạng trong `info.typ`. Không nên sửa thủ công trừ khi bạn hiểu rõ.

```json
{
  "version": "1.0.0",
  "format": {
    "font": "Times New Roman",
    "font_size": "13pt",
    "margins": {
      "left": "4cm",
      "right": "2.5cm",
      "top": "2.5cm",
      "bottom": "2.5cm"
    },
    "line_spacing": 1.2,
    "paragraph_indent": "1cm"
  },
  "abstract": {
    "min_words": 200,
    "max_words": 350,
    "min_keywords": 3,
    "max_keywords": 5
  },
  "bibliography": {
    "style": "ieee",
    "min_references": 15
  }
}
```
