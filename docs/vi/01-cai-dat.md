# 01 - Cài đặt

## Yêu cầu tiên quyết

| Phần mềm | Phiên bản tối thiểu | Mục đích |
|----------|---------------------|----------|
| **Bash** | 4.2+ | Môi trường chạy |
| **Typst** | 0.12.0+ | Biên dịch PDF (`build`) |
| **curl** | bất kỳ | Tải mẫu (`install`/`update`) |
| **Times New Roman** | — | Phông chữ yêu cầu của CTU (không bắt buộc; Typst sẽ dùng phông thay thế) |

### Kiểm tra phiên bản Bash

```bash
bash --version
# GNU bash, version 5.2.15  (hoặc cao hơn)
```

### Cài đặt Typst

```bash
# Linux (từ binary chính thức)
curl -fsSL https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz | tar xJ
sudo mv typst-x86_64-unknown-linux-musl/typst /usr/local/bin/

# macOS (qua Homebrew)
brew install typst

# Hoặc tải từ: https://github.com/typst/typst/releases
```

Kiểm tra:

```bash
typst --version
# typst 0.12.0 (hoặc cao hơn)
```

### Cài đặt Times New Roman (Linux)

```bash
# Ubuntu/Debian
sudo apt install ttf-mscorefonts-installer

# Fedora
sudo dnf install curl cabextract xorg-x11-font-utils
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# Arch
paru -S ttf-ms-fonts
```

## Cài đặt CTU Thesis CLI

### Một dòng lệnh (khuyên dùng)

```bash
curl -fsSL https://raw.githubusercontent.com/qinfa-dev/ctu-thesis-cli/main/install.sh | bash
```

Lệnh này tải CLI vào `~/.local/bin/` và bộ mẫu vào `~/.ctu-thesis/templates/`.

### Cài đặt thủ công

```bash
git clone https://github.com/qinfa-dev/ctu-thesis-cli
cd ctu-thesis-cli
make install
```

### Kiểm tra cài đặt

```bash
ctu-thesis --version
# ctu-thesis v2.0.0

ctu-thesis help
# Hiển thị danh sách lệnh
```

## Vị trí cài đặt

```
~/.local/bin/ctu-thesis          # File thực thi CLI
~/.ctu-thesis/templates/         # Bộ mẫu (dùng bởi `init`)
~/.ctu-thesis/config             # Cấu hình người dùng toàn cục
```

## Thiết lập PATH

Nếu không tìm thấy `ctu-thesis` sau khi cài đặt, thêm dòng này vào `~/.bashrc` hoặc `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Sau đó tải lại:

```bash
source ~/.bashrc  # hoặc ~/.zshrc
```

## Tự động hoàn thành lệnh (Tab-completion)

```bash
# Bash
source <(ctu-thesis completion bash)
echo 'source <(ctu-thesis completion bash)' >> ~/.bashrc

# Zsh
source <(ctu-thesis completion zsh)
echo 'source <(ctu-thesis completion zsh)' >> ~/.zshrc
```

## Gỡ cài đặt

```bash
rm -rf ~/.ctu-thesis ~/.local/bin/ctu-thesis
# Tùy chọn: xóa dòng PATH trong ~/.bashrc
```
