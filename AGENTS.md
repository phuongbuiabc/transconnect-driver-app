# Driver frontend

- Đọc [ARCHITECTURE.md](ARCHITECTURE.md), [Docs](../../TransConnect-Docs/AGENTS.md) và câu trả lời hiện hành trước thay đổi. Giữ nguyên design system/nghiệp vụ/API đã chốt; không tự thêm chức năng hoặc đổi nhóm tài khoản.
- Thực thi ranh giới app/core/features/shared trong ARCHITECTURE; app compose, feature sở hữu model/data/controller/presentation, core không phụ thuộc feature. Không thêm HTTP/token logic vào widget.
- Giữ public auth contract cho màn hình account/home; nghiệp vụ khác phối hợp qua app. Không import source giữa repo.
- Kiểm tra format, analyze và test bằng scripts/Check.ps1. Thay network/session phải kiểm tra list/null/field errors, refresh đồng thời, logout và account switch; thay UI phải kiểm tra state và màn hình nhỏ liên quan.
- Không commit token, .env thật, log dữ liệu cá nhân, build/cache. Cập nhật README/ARCHITECTURE nếu đổi cấu trúc/lệnh; bằng chứng/backlog chỉ ở progress-tracker Docs.
