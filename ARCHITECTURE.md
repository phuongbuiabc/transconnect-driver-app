# Cấu trúc Driver — cập nhật 18/10/2026

Repo Flutter build độc lập. Giữ `http`, `ChangeNotifier` và secure storage; chưa thêm tầng domain/use case khi chưa có nhu cầu. Quy tắc sản phẩm và thiết kế tiếp tục theo [Docs](../../TransConnect-Docs/AGENTS.md), [Design System](../../TransConnect-Docs/06-ui/VIEGO_DESIGN_SYSTEM.md) và [API baseline](../../TransConnect-Docs/09-decisions/api-baseline.md).

```text
lib/
  main.dart
  app/                     # bootstrap, MaterialApp, navigation, composition các controller
  core/
    config/                # API_BASE_URL và mặc định local theo nền tảng
    errors/                # ApiException, giữ message/status/code/fields
    network/               # HTTP transport, decoder, PagedResult<T>
    session/               # AuthSession, SessionClient: refresh/persistence/generation
    storage/               # TokenStore và SecureTokenStore
  features/
    auth/
      models/              # CurrentUser
      data/                # AuthRepository
      presentation/
        controllers/       # AuthController: user/verified/profileLoaded
        screens/           # form xác thực và OTP
    account/               # giao diện tài khoản
    driver_profile/, invitations/ # mỗi feature có models/data/presentation/controllers/screens
  shared/
    theme/                 # theme và token trình bày, không nằm trong app/core
    widgets/
    validation/
test/
  core/network_test.dart
  api_test.dart
  widget_test.dart
scripts/Check.ps1
```

## Ranh giới code

- Luồng feature: screen → controller → repository → SessionClient → ApiClient. Screen chỉ giữ state trình bày/form, không gọi HTTP hay secure storage. JSON thô chỉ ở biên API/form request; user/profile/receipt dùng model typed.
- `app` là composition root: tạo, truyền và dispose dependency; điều phối liên feature. `core` không import app/features/shared; shared UI không import app/features. Repository không biết widget/controller.
- AuthController là API công khai của feature auth, được account/home sử dụng cho phiên hiện tại; OTP là UI công khai của auth. Các feature nghiệp vụ không import implementation/controller của nhau. Phối hợp profile và invitations qua app composition.
- DriverController chỉ phối hợp auth + DriverProfileController + InvitationController. Profile và receipt thuộc feature tương ứng; session kết thúc phải clear cả hai. DriverBootstrap sở hữu vòng đời controller.
- Các controller nhận dependency tường minh. Không tạo singleton token/controller trong widget, không import source repo bên cạnh. HTTP client truyền vào được composition sở hữu và đóng khi dispose.

## Quy ước viết code

- Dart: file snake_case, class PascalCase; mỗi file một trách nhiệm chính. Relative import trong cùng layer/feature; package import khi UI tham chiếu feature/shared ở nơi khác. Không tạo thư mục/lớp rỗng cho chức năng tương lai.
- Model immutable; decoder báo sai contract, không biến list/null thành object rỗng. `PagedResult<T>` theo envelope Docs. Dùng fields để gắn lỗi server vào form khi triển khai form mới; vẫn giữ message tổng thể.
- Session chỉ có một chủ sở hữu. Refresh gộp theo generation; retry 401 tối đa một lần; 403 không refresh; lỗi mạng/5xx giữ phiên để thử lại. Không tự retry mutation do timeout. Logout xóa local kể cả revoke thất bại; không khẳng định revoke thành công khi offline.
- Phản hồi cũ sau logout/đổi account/dispose phải bị bỏ. State form cục bộ, state dữ liệu feature ở controller; có loading/error/empty, không coi lỗi tải là rỗng. Driver chỉ coi 404 hồ sơ là chưa nộp.
- AccountGroup cố định `Operator`; backend quyết định quyền. Không hardcode secret, không log OTP/token; giữ khóa storage riêng của app. Token phiên cũ được đọc theo cấu trúc tương thích; lần ghi tiếp theo chỉ lưu dữ liệu token cần thiết.
- Theme và widget theo Docs; không đưa nghiệp vụ vào shared. Không đổi quy tắc xác minh/duyệt để làm UI dễ hơn. Chưa mở Trip/Booking hoặc hồ sơ pháp lý thật.

## Phát triển và kiểm tra

`API_BASE_URL` mặc định Android native/emulator là `http://10.0.2.2:5267`; web/desktop/iOS simulator là `http://localhost:5267`. Điện thoại thật: truyền `--dart-define=API_BASE_URL=http://<IP-LAN>:5267` và cấu hình BE lắng nghe địa chỉ phù hợp. Production phải truyền URL HTTPS. Không nhúng secret qua dart-define.

Chạy `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Check.ps1`; thêm `-NoRestore` khi cache đầy đủ. Script fail ngay khi format/analyze/test lỗi. Test API dùng MockClient + TokenStore; test widget kiểm tra màn hình hẹp. Native build, HTTP live, DB/email và nghiệm thu UX phải kiểm chứng riêng.

Thêm feature: chốt contract/quyền theo Docs → model/repository → controller → screen/widget → nối route ở app → test request/state và UI liên quan. Chỉ thêm domain/use case khi có logic phức tạp thực tế.
