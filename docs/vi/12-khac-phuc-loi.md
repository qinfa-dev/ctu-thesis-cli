# 12 - Khắc phục Lỗi

## Không tìm thấy Typst

**Triệu chứng**: `ctu-thesis build` báo lỗi "typst: command not found"

**Cách sửa**: Cài đặt Typst CLI.

```bash
# Linux
curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz | tar xJ
sudo mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/

# macOS
brew install typst

# Kiểm tra
typst --version
```

Chạy `ctu-thesis doctor` để chẩn đoán.

## Không tạo được PDF

**Triệu chứng**: Build chạy nhưng không có PDF đầu ra.

**Danh sách kiểm tra**:

1. Bạn đang ở trong thư mục dự án? Chạy `ls info.typ` để xác nhận.
2. Kiểm tra lỗi cú pháp Typst trong file `.typ` — thông báo lỗi hiển thị trong output build.
3. Thử `ctu-thesis build --draft` để phát hiện lỗi nhanh hơn.
4. Chạy `ctu-thesis doctor` để kiểm tra thiếu phụ thuộc.

## Hình ảnh không hiển thị

**Triệu chứng**: Hình hiển thị trống hoặc lỗi trong PDF.

**Cách sửa**:

1. Kiểm tra đường dẫn ảnh — dùng đường dẫn tương đối từ file chương:
   ```typst
   image("../images/chapter1/so-do.png")  // đúng
   image("images/chapter1/so-do.png")      // sai từ chapters/
   ```
2. Đảm bảo file ảnh tồn tại: `ls images/chapter1/so-do.png`
3. Định dạng hỗ trợ: PNG, JPG, SVG, PDF
4. File có dấu cách phải đặt trong ngoặc kép: `image("images/ảnh của tôi.png")`

## Thiếu phông chữ Times New Roman

**Triệu chứng**: `ctu-thesis doctor` báo không tìm thấy phông, PDF dùng phông thay thế.

**Cách sửa**:

```bash
# Ubuntu/Debian
sudo apt install ttf-mscorefonts-installer

# Fedora
sudo dnf install curl cabextract xorg-x11-font-utils
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Arch
paru -S ttf-ms-fonts
```

Typst sẽ dùng phông serif thay thế nếu không có Times New Roman, nhưng PDF có thể không đáp ứng đúng yêu cầu CTU. Cài phông để đảm bảo tuân thủ đầy đủ.

## `ctu-thesis: command not found`

**Triệu chứng**: Terminal không tìm thấy `ctu-thesis`.

**Cách sửa**:

1. Chạy lại script cài đặt:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
   ```
2. Thêm `~/.local/bin` vào PATH:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```
3. Kiểm tra file binary: `ls -la ~/.local/bin/ctu-thesis`

## Bộ mẫu bị thiếu hoặc hỏng

**Triệu chứng**: `ctu-thesis init` thất bại hoặc tạo dự án không đầy đủ.

**Cách sửa**:

```bash
# Làm mới bộ mẫu
ctu-thesis update --templates

# Hoặc cài lại thủ công
rm -rf ~/.ctu-thesis/templates
curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
```

## Kiểm tra validate thất bại

**Nguyên nhân và cách sửa phổ biến**:

| Lỗi | Cách sửa |
|------|----------|
| "Số từ tóm tắt: 180 (tối thiểu: 200)" | Mở rộng tóm tắt lên 200+ từ |
| "Số từ khóa: 2 (tối thiểu: 3)" | Thêm 1+ từ khóa trong `info.typ` |
| "Số tài liệu tham khảo: 8 (tối thiểu: 15)" | Thêm mục vào `backmatter/bibliography.bib` |
| "Thiếu file: backmatter/bibliography.bib" | Tạo file (chạy lại `init` hoặc sao chép từ mẫu) |
| "Không tìm thấy file chương" | Chạy `ctu-thesis chapter list` để kiểm tra |

Dùng `ctu-thesis validate --fix` để tự động sửa một số lỗi.

## Phiên bản Bash quá cũ

**Triệu chứng**: CLI gặp sự cố hoặc hoạt động không như mong đợi.

**Kiểm tra**: `bash --version`

**Cách sửa**: Nâng cấp lên Bash 4.2+ (macOS đi kèm Bash 3.2; cài qua Homebrew):

```bash
# macOS
brew install bash
# Thêm vào /etc/shells và đặt làm shell mặc định

# Linux — thường đã có sẵn >= 4.2
```

## Build chậm

**Cách khắc phục**:

1. Dùng chế độ `--draft` khi viết: `ctu-thesis build --draft`
2. Dùng `--watch` để biên dịch liên tục (chỉ biên dịch lại file đã thay đổi)
3. Giảm kích thước ảnh — tránh file PNG/JPG quá lớn
4. Chia chương lớn thành các file nhỏ hơn

## Vẫn gặp lỗi?

Chạy chẩn đoán đầy đủ:

```bash
ctu-thesis doctor
```

Lệnh này kiểm tra tất cả phụ thuộc, bộ mẫu, kết nối internet và file cấu hình. Chia sẻ kết quả khi báo lỗi.

Để báo lỗi và đề xuất tính năng, mở issue tại: https://github.com/qinfa-dev/ctu-thesis-cli/issues
