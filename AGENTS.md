## Điểm vào hiện hành — 01/11/2026

Khi đổi tài khoản/agent, đọc [bàn giao](../../TransConnect-Docs/00-project/agent-handoff.md) và checkpoint `agent-current-state` trong progress-tracker Docs trước các mục lịch sử bên dưới. Kiểm tra source/Git thực tế: nhiều module/feature mới chưa commit; không reset/clean hoặc coi HEAD là toàn bộ code. Các ghi chú “chưa code/chưa import/Driver không đổi” cũ không ghi đè checkpoint mới. Hướng dẫn chung ở [AGENTS workspace](../../AGENTS.md).

# Driver frontend

- Đọc [ARCHITECTURE.md](ARCHITECTURE.md), [Docs](../../TransConnect-Docs/AGENTS.md) và câu trả lời hiện hành trước thay đổi. Giữ nguyên design system/nghiệp vụ/API đã chốt; không tự thêm chức năng hoặc đổi nhóm tài khoản.
- Thực thi ranh giới app/core/features/shared trong ARCHITECTURE; app compose, feature sở hữu model/data/controller/presentation, core không phụ thuộc feature. Không thêm HTTP/token logic vào widget.
- Cập nhật 20/10: Account có profile/password/avatar; Driver Rejected có resubmit. Feature foundation model/repository/controller/screen cho contact/reviews/collaborations/invitations/GPLX giả, app compose/clear/dispose. image_picker 1.2.2 chỉ ở UI; multipart/binary giữ guard session. Demo vẫn NOT_VERIFIED/Development-only; không cấp quyền vận tải từ giấy demo. Kiểm chứng và giới hạn live ở tracker Docs; đọc current-test trước thay contract.
- Giữ public auth contract cho màn hình account/home; nghiệp vụ khác phối hợp qua app. Không import source giữa repo.
- Kiểm tra format, analyze và test bằng scripts/Check.ps1. Thay network/session phải kiểm tra list/null/field errors, refresh đồng thời, logout và account switch; thay UI phải kiểm tra state và màn hình nhỏ liên quan.
- Không commit token, .env thật, log dữ liệu cá nhân, build/cache. Cập nhật README/ARCHITECTURE nếu đổi cấu trúc/lệnh; bằng chứng/backlog chỉ ở progress-tracker Docs.

## Quy trình theo nhánh — 21/10

Đọc [roadmap](../../TransConnect-Docs/00-project/roadmap.md) trước khi làm. Ghi đề xuất trong tracker: mã gói, nhánh/base/target, dependency A → B và WRITE/READ/VERIFY/GENERATED; câu hỏi theo Q-<GÓI>-<SỐ> trong Q&A, không tạo file hỏi riêng. Cập nhật phạm vi file trước khi sửa ngoài kế hoạch. PR dùng .github/pull_request_template.md; giữ test delta và bộ SHA liên repo. FND-00 đang thực hiện trên chore/fnd-00-delivery-workflow, không tự mở nhánh tương lai hoặc merge/push.

- FE-APPS-06 01/11: user đã giao cả Customer/Driver tìm địa điểm + redesign, chọn “Điểm đến dẫn lối”. `features/places` dùng điểm VieGo `/locations/shared`, `shared/map_actions` mở tọa độ ngoài; không đổi accountGroup hoặc tự tạo Trip/Booking. Hướng này thay giới hạn Driver chưa có Locations trong ghi chú cũ. PRODUCT/DESIGN và sidecar là tài liệu thiết kế hiện hành; preview fixture không thuộc production bootstrap.
