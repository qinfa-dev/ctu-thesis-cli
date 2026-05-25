# CTU Thesis CLI | CLI Luận văn ĐHCT

[![Made with Bash](https://img.shields.io/badge/made_with-Bash_4.2_-4EAA25.svg?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![CTU](https://img.shields.io/badge/Can_Tho-University-003399.svg)](https://www.ctu.edu.vn/)

[English](#english) | [Tiếng Việt](#tiếng-việt)

---

> # ⚠️  DISCLAIMER / LƯU Ý QUAN TRỌNG
>
> **This is NOT an official CTU tool.** It is a community-maintained CLI based on **Decision 4125/QĐ-ĐHCT** (August 6, 2024). Formatting requirements **vary by department** and **change without notice**. ✅ **Always confirm** your final document format with your **academic advisor** and **department office**.
>
> **Đây KHÔNG phải là công cụ chính thức của ĐHCT.** Đây là CLI do cộng đồng duy trì, dựa trên **Quyết định 4125/QĐ-ĐHCT** (06/08/2024). Quy định định dạng **có thể khác nhau tùy bộ môn** và **thay đổi không báo trước**. ✅ **Luôn xác nhận** định dạng cuối cùng với **giảng viên hướng dẫn** và **văn phòng khoa**.
>
> 🐛 Report bugs / Báo lỗi: [**GitHub Issues**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)  
> 📖 Full docs / Tài liệu đầy đủ: [`docs/en/`](docs/en/) · [`docs/vi/`](docs/vi/)

---

<a name="english"></a>
## 🇬🇧 English

### What is this?

A cross-platform Bash CLI for Can Tho University (CTU) students to scaffold, build, validate, and manage Typst thesis projects — compliant with Decision 4125/QĐ-ĐHCT (2024).

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
```

### Quick Start

```bash
# Create a new project
ctu-thesis init my-thesis --lang=en --title="My Research Topic"

# Build and watch
cd my-thesis
ctu-thesis build
ctu-thesis build --watch
```

### Commands

| Command | What it does |
|---|---|
| `ctu-thesis init PATH` | Scaffold a complete, compilable thesis project |
| `ctu-thesis build` | Compile to PDF (supports `--watch` and `--draft`) |
| `ctu-thesis validate` | Check CTU guideline compliance (structure, format, bibliography) |
| `ctu-thesis doctor` | Diagnose your environment (bash, typst, fonts, internet) |
| `ctu-thesis clean` | Remove build artifacts (`*.pdf`, `*.tmp`, `*.bak`) |
| `ctu-thesis config` | Manage user defaults (name, ID, language, advisor) |
| `ctu-thesis chapter` | Add, remove, list, or reorder chapters |
| `ctu-thesis update` | Refresh CLI and/or template cache |
| `ctu-thesis help` | Show command reference and usage |

### Requirements

- **Bash** >= 4.2
- **Typst** >= 0.12.0 (for `build`)
- **curl** (for install/update)
- **Times New Roman** font (recommended; Typst falls back if missing)

### CTU Format Compliance

Per Decision 4125/QĐ-ĐHCT (2024):

| Requirement | Value |
|---|---|
| Font | Times New Roman 13 pt |
| Margins | Left 4 cm, Others 2.5 cm |
| Line Spacing | 1.2 (main text); single for captions/code |
| Paragraph | Justified, first-line indent 1 cm |
| Abstract | 200–350 words, 3–5 keywords |
| Bibliography | IEEE style |
| Cover Color | CTU Blue (#003399) |

### Project Structure

```
my-thesis/
├── info.typ                  # ⚙️ Edit this first (your info)
├── main.typ                  # 📄 Entry point with marker regions
├── .ctu-thesisrc             # 📋 CLI project config
├── template/                 # 🎨 Style definitions (edit with care)
├── frontmatter/              # 📝 Cover, abstract, TOC, abbreviations
├── chapters/                 # 📚 Your thesis content
├── backmatter/               # 📎 References & appendices
└── images/                   # 🖼️ Image assets
```

### Development

```bash
git clone https://github.com/qinfa-dev/ctu-thesis-cli
cd ctu-thesis-cli

make lint       # shellcheck
make test       # bats tests
make bundle     # create distribution artifacts in dist/
```

---

<a name="tiếng-việt"></a>
## 🇻🇳 Tiếng Việt

### Giới thiệu

CLI đa nền tảng bằng Bash dành cho sinh viên Đại học Cần Thơ, giúp tạo, biên dịch, kiểm tra và quản lý dự án luận văn Typst — tuân thủ Quyết định 4125/QĐ-ĐHCT (2024).

### Cài đặt Nhanh

```bash
curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
```

### Bắt đầu Nhanh

```bash
# Tạo dự án mới
ctu-thesis init luan-van --lang=vi --title="Tên Đề Tài của Bạn"

# Biên dịch và theo dõi
cd luan-van
ctu-thesis build
ctu-thesis build --watch
```

### Câu lệnh

| Câu lệnh | Mô tả |
|---|---|
| `ctu-thesis init PATH` | Tạo dự án luận văn hoàn chỉnh, có thể biên dịch ngay |
| `ctu-thesis build` | Biên dịch ra PDF (hỗ trợ `--watch` và `--draft`) |
| `ctu-thesis validate` | Kiểm tra tuân thủ quy định CTU |
| `ctu-thesis doctor` | Chẩn đoán môi trường (bash, typst, phông chữ, internet) |
| `ctu-thesis clean` | Xóa file tạm và file build (`*.pdf`, `*.tmp`, `*.bak`) |
| `ctu-thesis config` | Quản lý cấu hình (tên, MSSV, ngôn ngữ, GVHD) |
| `ctu-thesis chapter` | Thêm, xóa, liệt kê, sắp xếp chương |
| `ctu-thesis update` | Cập nhật CLI và/hoặc bộ mẫu |
| `ctu-thesis help` | Hiển thị trợ giúp và danh sách câu lệnh |

### Yêu cầu

- **Bash** >= 4.2
- **Typst** >= 0.12.0 (để `build`)
- **curl** (để cài đặt/cập nhật)
- **Times New Roman** (khuyến nghị; Typst dùng phông thay thế nếu thiếu)

### Tuân thủ Định dạng CTU

Theo Quyết định 4125/QĐ-ĐHCT (2024):

| Yêu cầu | Giá trị |
|---|---|
| Phông chữ | Times New Roman 13 pt |
| Lề | Trái 4 cm, Còn lại 2.5 cm |
| Giãn dòng | 1.2 (văn bản chính); đơn cho chú thích/mã |
| Đoạn văn | Canh đều, thụt đầu dòng 1 cm |
| Tóm tắt | 200–350 từ, 3–5 từ khóa |
| Tài liệu tham khảo | Kiểu IEEE |
| Màu bìa | Xanh CTU (#003399) |

### Cấu trúc Dự án

```
luan-van/
├── info.typ                  # ⚙️ Sửa đầu tiên (thông tin của bạn)
├── main.typ                  # 📄 File chính với vùng đánh dấu
├── .ctu-thesisrc             # 📋 Cấu hình dự án CLI
├── template/                 # 🎨 Định nghĩa kiểu dáng (sửa cẩn thận)
├── frontmatter/              # 📝 Bìa, tóm tắt, mục lục, từ viết tắt
├── chapters/                 # 📚 Nội dung luận văn
├── backmatter/               # 📎 Tài liệu tham khảo & phụ lục
└── images/                   # 🖼️ Hình ảnh
```

### Phát triển

```bash
git clone https://github.com/qinfa-dev/ctu-thesis-cli
cd ctu-thesis-cli

make lint       # shellcheck
make test       # kiểm tra bats
make bundle     # tạo artifact phân phối trong dist/
```

---

## License / Giấy phép

MIT
