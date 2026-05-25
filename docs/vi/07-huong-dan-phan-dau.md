# 07 - Hướng dẫn: Phần Đầu (Front Matter)

> # ⚠️  LƯU Ý QUAN TRỌNG — VUI LÒNG ĐỌC
>
> **Đây KHÔNG phải là tài liệu chính thức của ĐHCT.** Đây là diễn giải của cộng đồng dựa trên **Quyết định 4125/QĐ-ĐHCT** (06/08/2024).
>
> - Quy định định dạng **có thể khác nhau tùy bộ môn** và **thay đổi không báo trước**.
> - **Luôn xác nhận** với giảng viên hướng dẫn và văn phòng khoa trước khi nộp bài chính thức.
> - Phát hiện lỗi? [**Báo lỗi tại đây.**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)

## Trang bìa (ngoài)

### Các yếu tố bắt buộc (theo thứ tự, canh giữa)

**1. Tiêu đề Trường** (13pt, in đậm, chữ in hoa):

```
BỘ GIÁO DỤC VÀ ĐÀO TẠO
TRƯỜNG ĐẠI HỌC CẦN THƠ
TRƯỜNG CÔNG NGHỆ THÔNG TIN VÀ TRUYỀN THÔNG
KHOA CÔNG NGHỆ PHẦN MỀM
```

**2. Logo Trường** (đường kính 3cm, canh giữa)

**3. Loại Luận văn** (14pt, in đậm, chữ in hoa):

```
LUẬN VĂN TỐT NGHIỆP
KỸ SƯ CÔNG NGHỆ THÔNG TIN
(Chương trình Chất lượng cao)
```

**4. Tên Đề tài** (18pt, in đậm, chữ in hoa, tối đa 2-3 dòng)

**5. Thông tin Sinh viên** (13pt, bố cục hai cột):

```
Sinh viên thực hiện: [Họ và Tên]
Mã số sinh viên:     [B1234567]
Lớp:                 [Tên Lớp]
Cán bộ hướng dẫn:    [TS./PGS. Tên Giảng viên]
```

**6. Địa điểm và Thời gian** (13pt):

```
Cần Thơ, Tháng/Năm
```

**Khung viền**: Viền đôi màu xanh đậm 2pt (#003399 — Xanh CTU) cách lề 1.5cm

## Trang bìa phụ (trong)

Giống như bìa ngoài nhưng:
- Viền đơn 3pt
- Cách lề 1cm
- Logo lớn hơn một chút (3.5cm)

## Trang nhận xét

**Tiêu đề**: "NHẬN XÉT CỦA CÁN BỘ HƯỚNG DẪN" (canh giữa, in đậm, chữ in hoa)

**Nội dung**:
- 20 dòng trống để giáo viên viết nhận xét
- Phần ký tên:

```
Cán bộ hướng dẫn: _______________

[Khoảng trống ký tên]

TS./PGS. [Tên Giảng viên]
```

## Lời cảm ơn

**Tiêu đề**: "LỜI CẢM ƠN" (canh giữa, in đậm, chữ in hoa)

**Nội dung** (1-2 trang):
- Cảm ơn giảng viên hướng dẫn
- Cảm ơn nhà trường/khoa/bộ môn
- Cảm ơn gia đình và bạn bè
- Chữ ký cá nhân và ngày tháng

**Định dạng**:
- Thụt đầu dòng: 1cm
- Canh đều hai bên
- Chữ ký: canh phải

## Tóm tắt

**Tiêu đề**: "TÓM TẮT" (canh giữa, in đậm, chữ in hoa)

| Yêu cầu | Giá trị |
|---------|---------|
| **Độ dài** | 200-350 từ (tuân thủ nghiêm ngặt) |
| **Từ khóa** | 3-5 từ khóa |
| **Định dạng từ khóa** | `Từ khóa: từ khóa 1, từ khóa 2, từ khóa 3` |
| **Vị trí từ khóa** | Sau phần tóm tắt, cách 1 dòng (1cm) |

### Cấu trúc tóm tắt

1. Bối cảnh và động lực nghiên cứu (2-3 câu)
2. Mục tiêu và phương pháp luận (3-4 câu)
3. Kết quả chính và phát hiện (3-4 câu)
4. Kết luận và ý nghĩa (2-3 câu)

## Mục lục

Tự động tạo bởi Typst từ cấu trúc tiêu đề. Hiển thị:
- Tiêu đề Phần
- Tiêu đề Chương
- Tiêu đề Mục (Cấp 2)
- Tiêu đề Tiểu mục (Cấp 3)

## Danh mục hình ảnh

Tự động. Mỗi mục được đánh số `Hình <chương>.<số>`.

Ví dụ:

```
Hình 1.1. Sơ đồ Kiến trúc Hệ thống ..................... 12
Hình 2.1. Lược đồ Cơ sở dữ liệu ......................... 25
Hình 2.2. Mô phỏng Giao diện Người dùng .................. 28
```

## Danh mục bảng biểu

Tự động. Mỗi mục được đánh số `Bảng <chương>.<số>`.

Ví dụ:

```
Bảng 2.1. Kết quả So sánh Hiệu năng ..................... 30
Bảng 3.1. Tóm tắt Trường hợp Kiểm thử ................... 42
```

## Danh mục từ viết tắt

**Tiêu đề**: "DANH MỤC TỪ VIẾT TẮT" (canh giữa, in đậm, chữ in hoa)

**Định dạng**: Bảng hai cột

| Từ viết tắt | Giải thích |
|-------------|------------|
| API | Giao diện lập trình ứng dụng |
| CTU | Đại học Cần Thơ |
| HTTP | Giao thức truyền tải siêu văn bản |

**Sắp xếp**: Theo thứ tự bảng chữ cái

Sửa trong `info.typ` tại mục `abbreviations`:

```typst
abbreviations: (
  ("API", "Giao diện lập trình ứng dụng"),
  ("CTU", "Đại học Cần Thơ"),
  ("HTTP", "Giao thức truyền tải siêu văn bản"),
)
```

## Đánh số trang phần đầu

- Số La Mã thường (i, ii, iii...)
- Vị trí dưới cùng, canh giữa
- Bắt đầu từ Mục lục (trang i)
- Các trang bìa không đánh số

---

## Nguồn Tham Khảo Chính Thức

- **Quyết định 4125/QĐ-ĐHCT** (06/08/2024) — Quy định hình thức trình bày luận văn toàn trường (liên hệ văn phòng khoa)
- **Trường CNTT&TT** — [cict.ctu.edu.vn](https://cict.ctu.edu.vn/)
- **Trung tâm Học liệu ĐHCT** — Quy cách đóng bìa và lưu chiểu: [lrc.ctu.edu.vn](https://lrc.ctu.edu.vn/)

> Luôn đối chiếu với văn phòng khoa để có yêu cầu mới nhất.
