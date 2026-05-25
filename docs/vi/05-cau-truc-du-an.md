# 05 - Cấu trúc Dự án

## Sơ đồ thư mục

```
luan-van/
├── info.typ                       # ⚙️  Thông tin luận văn — SỬA ĐẦU TIÊN
├── main.typ                       # 📄  File chính (entry point)
├── .ctu-thesisrc                  # 📋  Cấu hình dự án
│
├── template/                      # 🎨  Định nghĩa kiểu dáng (không nên sửa)
│   ├── ctu-styles.typ            # Quy tắc định dạng CTU
│   └── i18n.typ                  # Bản đồ nhãn song ngữ
│
├── frontmatter/                   # 📝  Phần đầu
│   ├── cover.typ                 # Trang bìa ngoài
│   ├── inner-cover.typ           # Trang bìa trong
│   ├── evaluation.typ            # Trang nhận xét GVHD
│   ├── acknowledgements.typ      # Lời cảm ơn
│   ├── abstract.typ              # Tóm tắt (200–350 từ)
│   ├── table-of-contents.typ     # Mục lục (tự động)
│   ├── list-of-figures.typ       # Danh mục hình (tự động)
│   ├── list-of-tables.typ        # Danh mục bảng (tự động)
│   └── abbreviations.typ         # Danh mục từ viết tắt
│
├── chapters/                      # 📚  Nội dung luận văn
│   ├── part1-introduction.typ    # Phần 1: Giới thiệu
│   ├── part2-content.typ         # Phần 2: Nội dung chính
│   ├── part3-conclusion.typ      # Phần 3: Kết luận
│   ├── part1/                    # Phần 1: các mục
│   │   ├── 01-context.typ
│   │   ├── 02-related-work.typ
│   │   ├── 03-objectives.typ
│   │   ├── 04-research-content.typ
│   │   └── 05-outline.typ
│   ├── part2/                    # Phần 2: các chương
│   │   ├── chapter1-background.typ
│   │   ├── chapter2-design.typ
│   │   └── chapter3-evaluation.typ
│   └── part3/                    # Phần 3: các mục
│       ├── 01-conclusion.typ
│       └── 02-future-work.typ
│
├── backmatter/                    # 📎  Phần cuối
│   ├── bibliography.bib          # Tài liệu tham khảo IEEE (BibTeX)
│   └── appendices.typ            # Phụ lục
│
└── images/                        # 🖼️  Hình ảnh
    ├── logo/                     # Logo CTU
    └── chapter1/                 # Hình theo chương
```

## Giải thích các file chính

### `info.typ`

Nguồn thông tin duy nhất cho tất cả metadata luận văn. Thông tin sinh viên, GVHD, tên đề tài, từ khóa, từ viết tắt, ngôn ngữ, tham số định dạng. Xem [Cấu hình](04-cau-hinh.md) để biết chi tiết.

### `main.typ`

File chính kết nối toàn bộ tài liệu:

1. Import `info.typ` và kiểu dáng mẫu
2. Thiết lập metadata tài liệu
3. Kết xuất phần đầu (bìa, mục lục, danh mục, tóm tắt, từ viết tắt)
4. Kết xuất các chương qua vùng đánh dấu
5. Kết xuất phần cuối (tài liệu tham khảo, phụ lục)

### Vùng đánh dấu chương

`main.typ` chứa vùng đánh dấu đặc biệt cho các chương:

```typst
// -- CTU-THESIS-CHAPTERS-START --
#include "chapters/part1-introduction.typ"
#include "chapters/part2-content.typ"
#include "chapters/part3-conclusion.typ"
// -- CTU-THESIS-CHAPTERS-END --
```

CLI chỉ đọc và ghi giữa các vùng đánh dấu này khi quản lý chương. Không sửa các dòng đánh dấu.

### `template/`

Chứa các định nghĩa kiểu dáng tuân thủ CTU. Triển khai các quy tắc định dạng từ Quyết định 4125/QĐ-ĐHCT (2024):

- `ctu-styles.typ` — thiết lập trang, lề, phông chữ, kiểu tiêu đề, header/footer, bố cục bìa
- `i18n.typ` — bản đồ nhãn song ngữ (VD: "Abstract" ↔ "Tóm tắt")

Chỉ sửa các file này nếu bạn cần tùy chỉnh định dạng ngoài yêu cầu CTU.

### `frontmatter/`

Mỗi file `.typ` kết xuất một trang phần đầu. Các file `abstract.typ` và `acknowledgements.typ` chứa văn bản mẫu bạn cần thay thế.

### `chapters/`

Nội dung luận văn thực tế. Tổ chức theo phần:

- **Phần 1 (Giới thiệu)**: Bối cảnh, nghiên cứu liên quan, mục tiêu, nội dung nghiên cứu, bố cục
- **Phần 2 (Nội dung)**: Các chương chính — cơ sở lý thuyết, thiết kế/hiện thực, kiểm thử/đánh giá
- **Phần 3 (Kết luận)**: Kết luận và hướng phát triển

### `backmatter/`

- `bibliography.bib` — Định dạng BibTeX. Tất cả tài liệu tham khảo kiểu IEEE. Trích dẫn bằng cú pháp `@khóa`.
- `appendices.typ` — Phụ lục tùy chọn (phiếu khảo sát, mã nguồn, hướng dẫn sử dụng)

### `.ctu-thesisrc`

Cấu hình ghi đè theo dự án. Được tạo bởi `ctu-thesis config init`. Ưu tiên hơn `~/.ctu-thesis/config`.

## Thêm hình ảnh

Đặt ảnh vào `images/` và tham chiếu trong chương:

```typst
// Trong bất kỳ file .typ của chương
#figure(
  image("../images/chapter1/so-do-he-thong.png", width: 80%),
  caption: [Sơ đồ Kiến trúc Hệ thống],
) <hinh-kien-truc>

Tham chiếu bằng @hinh-kien-truc.
```

Hình ảnh được đánh số tự động tuần tự trong mỗi chương (Hình 1.1, 1.2, v.v.).

## Thêm bảng biểu

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

Bảng được đánh số tuần tự trong mỗi chương (Bảng 1.1, 1.2, v.v.).

## Thêm trích dẫn

Sửa `backmatter/bibliography.bib` với tài liệu tham khảo của bạn:

```bibtex
@article{tran2024cnn,
  author  = {Trần, Văn A and Nguyễn, Thị B},
  title   = {Học sâu trong Phân loại Ảnh},
  journal = {Tạp chí CNTT&TT},
  volume  = {12},
  number  = {2},
  pages   = {45--60},
  year    = {2024}
}
```

Trích dẫn trong văn bản:

```typst
Theo @tran2024cnn, hệ thống...
Nhiều nghiên cứu @tran2024cnn @le2023 đã chỉ ra...
```

Tối thiểu 15 tài liệu tham khảo. Xem [Hướng dẫn: Trích dẫn](10-huong-dan-trich-dan.md).
