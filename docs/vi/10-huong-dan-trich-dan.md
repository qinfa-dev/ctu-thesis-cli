# 10 - Hướng dẫn: Trích dẫn và Tài liệu Tham khảo

> # ⚠️  TUYÊN BỐ MIỄN TRỪ TRÁCH NHIỆM — VUI LÒNG ĐỌC
>
> **Đây KHÔNG phải là tài liệu chính thức của ĐHCT.** Đây là diễn giải của cộng đồng dựa trên **Quyết định 4125/QĐ-ĐHCT** (06/08/2024).
>
> - Quy định định dạng **có thể khác nhau tùy bộ môn** và **thay đổi không báo trước**.
> - **Luôn xác nhận** với giảng viên hướng dẫn và văn phòng khoa trước khi nộp bài chính thức.
> - Phát hiện lỗi? [**Báo lỗi tại đây.**](https://github.com/qinfa-dev/ctu-thesis-cli/issues)

## Kiểu trích dẫn

**Kiểu IEEE** (đánh số) là bắt buộc.

## Trích dẫn trong văn bản

### Định dạng cơ bản

| Loại | Định dạng | Ví dụ |
|------|-----------|-------|
| Một tài liệu | `[1]` | `Theo Smith [1], hệ thống...` |
| Nhiều tài liệu | `[1], [3], [5]` | `Nhiều nghiên cứu [1], [3], [5] đã chỉ ra...` |
| Tài liệu liên tiếp | `[1]-[4]` | `Các công trình gần đây [1]-[4] chứng minh...` |

### Cách dùng trong Typst

```typst
// Khóa BibTeX trong backmatter/bibliography.bib
@tran2024cnn

// Nhiều trích dẫn
@tran2024cnn @le2023 @nguyen2024
```

## Định dạng danh sách tài liệu tham khảo

Tất cả tài liệu trong `backmatter/bibliography.bib` (BibTeX).

### Bài báo tạp chí

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

Hiển thị dạng:

```
[1] V. A. Trần and T. B. Nguyễn, "Học sâu trong Phân loại Ảnh,"
    Tạp chí CNTT&TT, vol. 12, no. 2, pp. 45-60, 2024.
```

### Sách

```bibtex
@book{brown2024,
  author    = {Brown, David},
  title     = {Software Engineering Principles},
  edition   = {3rd},
  address   = {New York, NY, USA},
  publisher = {McGraw-Hill},
  year      = {2024}
}
```

### Bài báo hội nghị

```bibtex
@inproceedings{lee2023,
  author    = {Lee, Alice},
  title     = {Microservices Architecture},
  booktitle = {Proc. Int. Conf. Software Eng.},
  year      = {2023},
  pages     = {45--52}
}
```

### Website (hạn chế sử dụng)

```bibtex
@misc{react2024,
  author       = {{Meta Platforms}},
  title        = {React Documentation},
  year         = {2024},
  howpublished = {[Online]. Available: \url{https://react.dev}},
  note         = {[Accessed: Jan. 1, 2026]}
}
```

## Yêu cầu

| Yêu cầu | Tối thiểu |
|---------|-----------|
| Tổng số tài liệu | 15 |
| Tài liệu gần đây (5 năm trở lại) | 5 |
| Loại nguồn | Kết hợp tạp chí, sách, hội nghị |

## Kiểm tra

Lệnh `ctu-thesis validate` kiểm tra:
- Số tài liệu tham khảo >= 15
- File bibliography tồn tại và là BibTeX hợp lệ
- Tài liệu được trích dẫn trong văn bản tồn tại trong bibliography

## Thực hành tốt nhất

1. Bắt đầu thu thập tài liệu sớm — thêm vào `bibliography.bib` trong quá trình nghiên cứu
2. Sử dụng Zotero, Mendeley hoặc EndNote với xuất BibTeX
3. Ưu tiên bài báo tạp chí và hội nghị hơn website
4. Bao gồm DOI khi có (thêm trường `doi = {...}`)
5. Kiểm tra tất cả trích dẫn xuất hiện trong danh sách tài liệu và ngược lại
6. Sắp xếp tài liệu theo thứ tự xuất hiện trong văn bản

## Tài nguyên hữu ích

- Hướng dẫn Trích dẫn IEEE: https://ieee-dataport.org/sites/default/files/analysis/27/IEEE%20Citation%20Guidelines.pdf
- Sổ tay IEEE Editorial Style: https://journals.ieeeauthorcenter.ieee.org/your-role-in-article-production/ieee-editorial-style-manual/
- Zotero (quản lý tài liệu miễn phí): https://www.zotero.org/
- Tham khảo định dạng BibTeX: https://www.bibtex.com/g/bibtex-format/

---

## Nguồn Tham Khảo Chính Thức

- **Quyết định 4125/QĐ-ĐHCT** (06/08/2024) — Quy định bắt buộc kiểu trích dẫn IEEE cho luận văn ĐHCT
- **Sổ tay IEEE Editorial Style** — [ieeeauthorcenter.ieee.org](https://journals.ieeeauthorcenter.ieee.org/your-role-in-article-production/ieee-editorial-style-manual/)
- **Hướng dẫn Trích dẫn IEEE** — [PDF](https://ieee-dataport.org/sites/default/files/analysis/27/IEEE%20Citation%20Guidelines.pdf)

> Luôn đối chiếu với văn phòng khoa để có yêu cầu mới nhất.
