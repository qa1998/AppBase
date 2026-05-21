# Domain samples (không gắn DI)

Các file dưới `UseCase/Home/`, `Repo/Home*`, `Service/Home*` là **mẫu phân trang** (`DataPage` + load more).

- Màn **Home** production dùng **VietQR banks**: `GetBankListUseCase`, `BankRepository`.
- Không thêm lại `homeList` vào `AppDependencies` trừ khi cần tab demo paging riêng.

Auth (`UseCase/Auth/`) — **UI demo** ở `Presentation/Login/`, chưa inject DI.
