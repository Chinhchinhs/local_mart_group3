class ProcessCheckoutUseCase {
  Future<bool> execute() async {
    // Giả lập gọi API thanh toán
    await Future.delayed(const Duration(seconds: 2));

    // true = thanh toán thành công
    return true;
  }
}