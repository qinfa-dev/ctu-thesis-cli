# 06 - Hướng dẫn: Tổng quan

> # ⚠️  TUYÊN BỐ MIỄN TRỪ TRÁCH NHIỆM — VUI LÒNG ĐỌC
>
> **Đây KHÔNG phải là tài liệu chính thức của ĐHCT.** Đây là diễn giải của cộng đồng dựa trên **Quyết định 4125/QĐ-ĐHCT** (06/08/2024).
>
> - Quy định định dạng **có thể khác nhau tùy bộ môn** và **thay đổi không báo trước**.
> - **Luôn xác nhận** với giảng viên hướng dẫn và văn phòng khoa trước khi nộp bài chính thức.
> - Phát hiện lỗi? [**Báo lỗi tại đây.**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)

> Dựa trên Quyết định 4125/QĐ-ĐHCT (2024) — Quy định chính thức về định dạng luận văn tốt nghiệp ĐHCT.

## Yêu cầu chung

### Loại tài liệu

- **Loại Luận văn**: Luận văn tốt nghiệp
- **Bằng cấp**: Kỹ sư Công nghệ Thông tin
- **Ngôn ngữ**: Tiếng Anh hoặc Tiếng Việt

### Thiết lập trang

| Thành phần | Quy định |
|------------|----------|
| **Khổ giấy** | A4 (210mm x 297mm) |
| **Hướng giấy** | Dọc (Portrait) |
| **Lề** | Trái: 4.0 cm, Phải: 2.5 cm, Trên: 2.5 cm, Dưới: 2.5 cm |
| **Gáy sách** | Bên trái (lề 4cm để đóng bìa) |

### Kiểu chữ

| Thành phần | Quy định |
|------------|----------|
| **Phông chữ** | Times New Roman |
| **Cỡ chữ** | 13 pt (văn bản chính) |
| **Giãn dòng** | 1.2 (văn bản chính), 1.0 (bảng, hình, tài liệu tham khảo) |
| **Đoạn văn** | Thụt đầu dòng: 1.0 cm, Canh đều hai bên |

## Cấu trúc tài liệu

```
LUẬN VĂN TỐT NGHIỆP
├── PHẦN ĐẦU (Số La Mã: i, ii, iii...)
│   ├── Trang Bìa (bìa ngoài)
│   ├── Trang Bìa Phụ (bìa trong)
│   ├── Trang Nhận xét
│   ├── Lời Cảm ơn
│   ├── Mục lục
│   ├── Danh mục Hình ảnh
│   ├── Danh mục Bảng biểu
│   ├── Danh mục Từ viết tắt
│   └── Tóm tắt (200-350 từ)
│
├── NỘI DUNG CHÍNH (Số Ả Rập: 1, 2, 3...)
│   ├── PHẦN 1: GIỚI THIỆU
│   │   ├── 1. Bối cảnh và Đặt vấn đề
│   │   ├── 2. Các nghiên cứu liên quan
│   │   ├── 3. Mục tiêu và Phạm vi
│   │   ├── 4. Nội dung nghiên cứu
│   │   └── 5. Bố cục luận văn
│   │
│   ├── PHẦN 2: NỘI DUNG LUẬN VĂN
│   │   ├── CHƯƠNG 1: Cơ sở lý thuyết
│   │   ├── CHƯƠNG 2: Phân tích và Thiết kế
│   │   └── CHƯƠNG 3: Kiểm thử và Đánh giá
│   │
│   └── PHẦN 3: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN
│       ├── I. Kết luận
│       └── II. Hướng phát triển
│
└── PHẦN CUỐI
    ├── Tài liệu tham khảo (kiểu IEEE)
    └── Phụ lục (tùy chọn)
```

## Yêu cầu số trang tối thiểu

| Phần | Số trang tối thiểu |
|------|--------------------|
| Giới thiệu (Phần 1) | 8-12 trang |
| Nội dung chính (Phần 2) | 30-50 trang |
| Kết luận (Phần 3) | 5-8 trang |
| **Tổng Nội dung Chính** | **50-80 trang** |

## Kiểu tiêu đề

### Tiêu đề Phần (Part)

| Thuộc tính | Giá trị |
|-----------|---------|
| Định dạng | Canh giữa, in đậm, chữ in hoa, 14pt |
| Khoảng cách | Trên 2cm, dưới 1cm |
| Đánh số | Không |
| Ví dụ | `PHẦN 1: GIỚI THIỆU` |

### Tiêu đề Chương (Cấp 1)

| Thuộc tính | Giá trị |
|-----------|---------|
| Định dạng | Canh giữa, in đậm, chữ in hoa, 14pt |
| Khoảng cách | Trên 1.5cm, dưới 1cm |
| Đánh số | `CHƯƠNG 1:`, `CHƯƠNG 2:`, v.v. |
| Ví dụ | `CHƯƠNG 1: CƠ SỞ LÝ THUYẾT` |

### Tiêu đề Mục (Cấp 2)

| Thuộc tính | Giá trị |
|-----------|---------|
| Định dạng | Canh trái, in đậm, chữ in hoa, 13pt |
| Khoảng cách | 0.6cm trên và dưới |
| Đánh số | `1.1`, `1.2`, v.v. |
| Ví dụ | `1.1 LÝ DO CHỌN ĐỀ TÀI` |

### Tiêu đề Tiểu mục (Cấp 3)

| Thuộc tính | Giá trị |
|-----------|---------|
| Định dạng | Canh trái, in đậm, chữ thường, 13pt |
| Khoảng cách | 0.3cm trên và dưới |
| Đánh số | `1.1.1`, `1.1.2`, v.v. |
| Ví dụ | `1.1.1 Đặt vấn đề` |

### Tiêu đề Tiểu mục nhỏ (Cấp 4)

| Thuộc tính | Giá trị |
|-----------|---------|
| Định dạng | Canh trái, in đậm, chữ thường, 13pt |
| Khoảng cách | 0.3cm trên và dưới |
| Đánh số | `1.1.1.1`, `1.1.1.2`, v.v. |

## Đánh số trang

### Phần đầu

| Thuộc tính | Giá trị |
|-----------|---------|
| Kiểu | Số La Mã thường (i, ii, iii...) |
| Vị trí | Dưới cùng, canh giữa |
| Bắt đầu | Từ Mục lục (trang i) |
| Loại trừ | Các trang bìa |

### Nội dung chính

| Thuộc tính | Giá trị |
|-----------|---------|
| Kiểu | Số Ả Rập (1, 2, 3...) |
| Vị trí | Dưới cùng, canh giữa |
| Bắt đầu | Từ Phần 1 Giới thiệu (trang 1) |
| Header | Tên luận văn rút gọn (in nghiêng, 9pt) + đường gạch ngang |

## Đầu trang và Chân trang

### Đầu trang (chỉ nội dung chính)

```
Tên Luận văn Rút gọn (tối đa 50 ký tự, in nghiêng, 9pt)
_______________________________________________ (đường kẻ 0.5pt)
```

### Chân trang (tất cả các trang)

```
_______________________________________________ (đường kẻ 0.5pt)
                    Số trang
```

## Tham khảo nhanh

```
Giấy:      A4
Lề:        Trái:4cm, Phải:2.5cm, Trên:2.5cm, Dưới:2.5cm
Phông:     Times New Roman, 13pt
Giãn dòng: 1.2 văn bản chính, 1.0 bảng/hình/tltk
Thụt dòng: 1cm
```

```
Kiểu tiêu đề:
  Phần:      14pt, In đậm, In hoa, Canh giữa
  Chương:    14pt, In đậm, In hoa, Canh giữa
  Mục:       13pt, In đậm, In hoa, Canh trái
  Tiểu mục:  13pt, In đậm, Chữ thường, Canh trái
```

```
Đánh số:
  Phần đầu:      i, ii, iii, iv...
  Nội dung chính: 1, 2, 3, 4...
  Chương:         CHƯƠNG 1, CHƯƠNG 2...
  Mục:            1.1, 1.2, 2.1, 2.2...
  Hình:           Hình 1.1, Hình 2.1...
  Bảng:           Bảng 1.1, Bảng 2.1...
```

---

## Nguồn Tham Khảo Chính Thức

Các hướng dẫn này dựa trên các văn bản chính thức của ĐHCT:

| # | Văn bản | Liên kết |
|---|---------|----------|
| 1 | **Quyết định 4125/QĐ-ĐHCT** (06/08/2024) — Quy định hình thức trình bày luận văn toàn trường | Liên hệ văn phòng khoa |
| 2 | **Trường CNTT&TT** — Yêu cầu luận văn tốt nghiệp | [cict.ctu.edu.vn](https://cict.ctu.edu.vn/) |
| 3 | **Trung tâm Học liệu ĐHCT** — Quy cách đóng bìa và lưu chiểu | [lrc.ctu.edu.vn](https://lrc.ctu.edu.vn/) |
| 4 | **Sổ tay IEEE Editorial Style** | [ieeeauthorcenter.ieee.org](https://journals.ieeeauthorcenter.ieee.org/your-role-in-article-production/ieee-editorial-style-manual/) |

> **Lưu ý**: Quy định của từng bộ môn có thể bổ sung hoặc thay thế các yêu cầu chung của toàn trường. Luôn kiểm tra với văn phòng khoa để có phiên bản mới nhất.
