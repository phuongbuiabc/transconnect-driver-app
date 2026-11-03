# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Tài xế thuộc nhóm Operator: quản lý hồ sơ, lời mời/cộng tác và tra cứu địa điểm phục vụ. Không đồng nhất tài khoản Owner và Driver.

## Product Purpose

VieGo Driver phục vụ hồ sơ/cộng tác theo quyền backend. User xác nhận 01/11/2026 redesign cả Driver và Customer, thêm tìm địa điểm để làm nền cho chức năng chuyến về sau. Không tự triển khai Trip, nhận chuyến, thu nhập hoặc điều hướng nội bộ khi backend chưa có.

## Operating Context

Flutter Material 3, http + ChangeNotifier + secure storage; Android emulator hiện có, iOS/web trong repo chưa được coi là đã nghiệm thu. Thao tác trên điện thoại, ưu tiên chữ rõ và vùng bấm 48dp.

## Capabilities and Constraints

- Giữ auth, xác thực email, submit/resubmit hồ sơ, lời mời/cộng tác, tài khoản, liên hệ và giấy demo NOT_VERIFIED.
- Tra cứu điểm VieGo đang công bố qua `/locations/shared`; không đọc sổ địa chỉ riêng của Customer hoặc tự thêm quyền công bố điểm.
- Google Maps/chỉ đường dùng tọa độ của điểm đã chọn; dữ liệu đường/ứng dụng nhận quyết định tuyến.
- Giữ screen → controller → repository → SessionClient và guard khi logout/đổi phiên.

## Brand Commitments

VieGo cho hiển thị, TransConnect giữ tên kỹ thuật; đỏ #D3171E/vàng #FFC72C. Cùng họ nhận diện với Customer nhưng ưu tiên công việc hồ sơ/cộng tác của tài xế.

## Evidence on Hand

ARCHITECTURE, APIs, source và tests hiện có; quyết định user/tracker Docs. Không có dữ liệu chuyến/thu nhập thực để hiển thị.

## Product Principles

1. Trạng thái hồ sơ và bước tiếp theo phải rõ.
2. Navigation không giấu nghiệp vụ đang có.
3. Điểm đến dùng id/version và tọa độ thật, không dựng danh sách giả trong ứng dụng.
4. Kiểm chứng native và provider/backend thật độc lập với fixture.
