# Kiến trúc ứng dụng tài xế

Dự án Flutter độc lập này tổ chức thư mục theo chức năng, truyền dependency qua constructor và sử dụng ChangeNotifier. Không bổ sung dependency mới hay các lớp quản lý trạng thái được sinh tự động. Việc tái cấu trúc giữ nguyên giao diện tiếng Việt và cách tương tác với API hiện tại.

## Sơ đồ thư mục

```text
lib/
  main.dart                         Chỉ chứa điểm khởi chạy
  app/
    bootstrap.dart                  Khởi tạo Flutter và tập trung lắp ghép dependency
    driver_app.dart                 Cấu hình MaterialApp, bản địa hóa và theme
    navigation/driver_shell.dart    Khôi phục phiên, kiểm tra email và ba tab
    session/driver_controller.dart  Trạng thái phiên có thể theo dõi và điều phối giữa các chức năng
    theme/app_theme.dart            Cấu hình theme Material
  core/
    config/app_config.dart          API_BASE_URL được cấu hình khi biên dịch
    errors/api_exception.dart       Lỗi HTTP có kiểu dữ liệu, thông báo dễ hiểu cho người dùng
    network/api_client.dart         HTTP, thời gian chờ, ánh xạ phản hồi bao ngoài/lỗi
    network/api_request.dart        Chữ ký hàm gửi yêu cầu có xác thực được truyền vào
    network/json.dart               Bí danh kiểu dữ liệu theo hợp đồng JSON của backend
    storage/token_store.dart        Giao diện lưu trữ phiên
    storage/secure_token_store.dart Triển khai lưu trữ bảo mật trên nền tảng
    theme/app_colors.dart           Các giá trị màu thương hiệu dùng chung
  features/
    auth/
      data/auth_repository.dart     Các endpoint tài khoản và nhóm Operator
      presentation/screens/
        auth_screen.dart            Đăng nhập, đăng ký, quên/đặt lại mật khẩu
        email_verification_screen.dart Xác thực bằng mã email và gửi lại mã
    account/presentation/screens/
      account_screen.dart           Tên, email và trạng thái xác thực của người đã đăng nhập
    driver_profile/
      data/driver_profile_repository.dart Các endpoint tra cứu và gửi hồ sơ tài xế
      presentation/screens/driver_profile_screen.dart Gửi hồ sơ và trạng thái xét duyệt
    invitations/
      data/invitation_repository.dart Endpoint chấp nhận lời mời bằng token
      presentation/screens/invitation_screen.dart Biểu mẫu chấp nhận và kết quả tiếp nhận
  shared/
    validation/form_validators.dart Hàm kiểm tra trường bắt buộc dùng lại
    widgets/brand.dart              Nhận diện thương hiệu ứng dụng
    widgets/panel.dart              Khung nội dung dùng chung
    widgets/notice.dart             Hiển thị lỗi/thông tin dùng chung
 test/                              Kiểm tra vòng đời phiên và giao diện màn hình hẹp
```

## Trách nhiệm và quan hệ phụ thuộc

Nơi lắp ghép dependency tạo DriverController và truyền đối tượng này qua constructor. DriverShell xử lý điều hướng và khôi phục trạng thái ứng dụng. Mỗi màn hình sở hữu trạng thái biểu mẫu tạm thời cùng các controller của biểu mẫu và tự giải phóng chúng. DriverController quản lý trạng thái xác thực có thể theo dõi, dữ liệu người dùng/tài xế, việc làm mới token và điều phối lưu trữ. Nó kết hợp các repository của từng chức năng; repository nhận hàm ApiRequest và không bao giờ import controller hoặc UI. ApiClient chỉ xử lý truyền tải dữ liệu, không biết đến widget Flutter hay endpoint của từng chức năng.

Chiều phụ thuộc được phép: presentation -> controller ứng dụng được truyền vào/widget dùng chung/các giá trị cấu hình trong core; controller ứng dụng -> data của chức năng/core; data của chức năng -> hợp đồng mạng trong core; shared -> core/Flutter; core -> API của Dart/Flutter/plugin. Data của chức năng không import presentation và một chức năng không import chức năng khác. Controller ứng dụng đóng vai trò điều phối nhỏ ở cấp ứng dụng, được các màn hình dùng chung, để tránh lặp lại logic phiên ở từng màn hình. Kiến trúc này hướng đến nhu cầu thực tế, không tạo các thư mục domain/use-case rỗng. Bổ sung controller riêng khi một chức năng phát triển trạng thái đáng kể cần được theo dõi độc lập.

## Các nguyên tắc bất biến của phiên và API

Operator là nhóm tài khoản. Khóa lưu trữ bảo mật driver_session được giữ nguyên. Tại một thời điểm chỉ thực hiện một yêu cầu làm mới token; cơ chế kiểm tra thế hệ phiên loại bỏ phản hồi đến muộn sau khi phiên thay đổi; các thao tác lưu trữ vẫn được thực hiện tuần tự. Đăng xuất chờ quá trình xoay vòng token hoàn tất trước khi thu hồi token và xóa trạng thái cục bộ ngay cả khi thao tác thất bại. Kết quả 404 khi tra cứu tài xế có nghĩa là chưa gửi hồ sơ; các thất bại khác vẫn được xử lý là lỗi. Chấp nhận lời mời yêu cầu email đã xác thực và trạng thái xét duyệt Approved. Không giả lập các endpoint mà backend chưa có.

## Thêm màn hình

1. Thêm màn hình Dart vào thư mục features/<feature>/presentation/screens của chức năng tương ứng.
2. Đặt widget chỉ dùng trong chức năng đó tại presentation/widgets. Chỉ chuyển UI đã chứng minh được khả năng tái sử dụng sang shared/widgets.
3. Đặt logic về endpoint trong repository data của chức năng đó; truyền ApiRequest vào. Đặt phần điều phối liên quan đến phiên trong DriverController, kèm kiểm tra thế hệ phiên.
4. Kết nối điều hướng tại app/navigation/driver_shell.dart. Giữ main.dart không chứa màn hình và logic nghiệp vụ.
5. Thêm kiểm thử hành vi trong test bằng client và kho token được truyền vào. Chạy phân tích mã, kiểm thử và build cho một nền tảng mục tiêu.

## Chia sẻ giữa hai ứng dụng

Trong repository này, core chứa hạ tầng kỹ thuật và shared chứa thành phần giao diện có thể tái sử dụng. Ứng dụng khách hàng và tài xế vẫn là các repository có thể build độc lập. Không import file từ repository bên cạnh. Trong tương lai, một package Dart/Flutter có quản lý phiên bản có thể chia sẻ các giá trị màu ổn định, widget tổng quát, logic phân tích phản hồi API bao ngoài và giao diện lưu trữ, sau khi cả hai ứng dụng thể hiện nhu cầu giống nhau. Giữ accountGroup, không gian tên lưu trữ, repository chức năng, điều hướng, quyền truy cập và màn hình riêng cho từng ứng dụng. Hiện chưa cần thêm package hay repository thứ ba.

## File nền tảng và xác minh

android/, ios/ và web/ chứa cấu hình nền tảng và mã khung khởi chạy, không chứa màn hình Dart của các chức năng. pubspec.yaml quản lý dependency và tài nguyên của dự án. test/ kiểm tra vòng đời phiên HTTP và luồng bắt đầu sử dụng ở chiều rộng điện thoại; kiểm thử với dữ liệu giả lập không thay thế việc build native hoặc xác minh với backend/email thực tế.
