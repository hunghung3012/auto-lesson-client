import 'package:flutter/material.dart';

// Model nội bộ để quản lý dữ liệu slide
class _SlideItem {
  final String title;
  final String content;
  final String note;

  _SlideItem({
    required this.title,
    required this.content,
    required this.note,
  });
}

class SlideDetailScreen extends StatefulWidget {
  // Không nhận bất kỳ biến nào từ bên ngoài
  const SlideDetailScreen({Key? key}) : super(key: key);

  @override
  State<SlideDetailScreen> createState() => _SlideDetailScreenState();
}

class _SlideDetailScreenState extends State<SlideDetailScreen> {
  int _currentIndex = 0;

  // TOÀN BỘ NỘI DUNG ĐÃ ĐƯỢC FIX CỨNG TẠI ĐÂY
  final List<_SlideItem> _data = [
    _SlideItem(
      title: "PHƯƠNG TRÌNH BẬC 2",
      content: "• Môn học: Toán\n• Lớp: 7\n• Chủ đề: Phương trình bậc 2\n• Thời lượng: 45 phút\n• Sách giáo khoa: Kết nối tri thức với cuộc sống",
      note: "Đây là slide mở đầu, giới thiệu thông tin cơ bản về bài học. Giáo viên có thể chào học sinh và nhắc lại nội dung bài trước.",
    ),
    _SlideItem(
      title: "MỤC TIÊU BÀI HỌC",
      content: "• Kiến thức: Hiểu khái niệm và nhận dạng phương trình bậc 2.\n• Kỹ năng: Biết xác định hệ số a, b, c và giải bằng công thức nghiệm.\n• Phẩm chất: Rèn luyện tính cẩn thận, kiên trì trong tính toán.",
      note: "Giáo viên nêu rõ mục tiêu để học sinh hiểu bài học sẽ đạt được gì.",
    ),
    _SlideItem(
      title: "KHỞI ĐỘNG",
      content: "• Tình huống: Ném quả bóng lên cao với h = -5t² + 20t.\n• Câu hỏi: Sau bao lâu bóng chạm đất?\n• Liên hệ: Đây chính là một dạng phương trình bậc 2 thực tế.",
      note: "Giáo viên đặt câu hỏi gợi ý để học sinh suy nghĩ, dẫn dắt vào nội dung chính.",
    ),
    _SlideItem(
      title: "DẠNG TỔNG QUÁT",
      content: "Phương trình: ax² + bx + c = 0 (với a ≠ 0)\n\n• a: hệ số của x²\n• b: hệ số của x\n• c: hằng số tự do\n\nVí dụ: 3x² + 5x - 2 = 0 có a=3, b=5, c=-2.",
      note: "Giáo viên giải thích kỹ từng thành phần và cho học sinh tập nhận diện hệ số.",
    ),
    _SlideItem(
      title: "CÔNG THỨC NGHIỆM",
      content: "Biệt thức: Δ = b² - 4ac\n\nCông thức nghiệm tổng quát:\nx = (-b ± √Δ) / 2a\n\nĐiều kiện quan trọng: Hệ số a phải khác 0.",
      note: "Giáo viên giải thích ý nghĩa của biệt thức Delta và cách sử dụng dấu ±.",
    ),
    _SlideItem(
      title: "VÍ DỤ MINH HỌA",
      content: "Giải: 2x² - 3x - 2 = 0\n\n• Bước 1: Xác định a=2, b=-3, c=-2.\n• Bước 2: Δ = (-3)² - 4(2)(-2) = 25.\n• Bước 3: x = (3 ± 5) / 4\n\nKết quả: x₁ = 2, x₂ = -1/2.",
      note: "Học sinh theo dõi từng bước giải chi tiết và đặt câu hỏi nếu chưa rõ.",
    ),
    _SlideItem(
      title: "BÀI TẬP THỰC HÀNH",
      content: "Giải các phương trình sau:\n\n1) x² - 5x + 6 = 0\n2) 3x² + 7x - 10 = 0\n3) 2x² - 3x = 0",
      note: "Giáo viên chia bài tập theo nhóm hoặc yêu cầu học sinh làm cá nhân.",
    ),
    _SlideItem(
      title: "ỨNG DỤNG THỰC TẾ",
      content: "Vật rơi tự do: h = -5t² + 20t + 80\n\n• Để tìm lúc chạm đất, ta đặt h = 0.\n• Giải phương trình bậc 2 để tìm thời gian t.\n• Lưu ý: Chỉ chọn nghiệm dương vì t là thời gian.",
      note: "Giáo viên hướng dẫn cách đưa bài toán thực tế về dạng phương trình toán học.",
    ),
    _SlideItem(
      title: "TÓM TẮT KIẾN THỨC",
      content: "• Nhận dạng: ax² + bx + c = 0\n• Cách tính Δ và công thức nghiệm.\n• Quy trình giải: Xác định hệ số → Tính Δ → Tìm nghiệm.\n• Luôn cẩn thận với dấu của các hệ số.",
      note: "Học sinh ghi nhớ sơ đồ tư duy giải phương trình bậc 2.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _data[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2ED), // Màu nền kem đặc trưng
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F2ED),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "SLIDE ${_currentIndex + 1} / ${_data.length}",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TIÊU ĐỀ (Bold Black Aesthetic)
                  Text(
                    current.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.1,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Đường kẻ ngang tinh tế
                  Container(height: 3, width: 80, color: Colors.black),
                  const SizedBox(height: 40),

                  // NỘI DUNG CHÍNH
                  Text(
                    current.content,
                    style: const TextStyle(
                      fontSize: 19,
                      height: 1.8,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // GHI CHÚ
                  if (current.note.isNotEmpty) ...[
                    const Divider(color: Colors.black26, thickness: 1),
                    const SizedBox(height: 15),
                    const Text(
                      "GHI CHÚ GIÁO VIÊN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.note,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // THANH ĐIỀU HƯỚNG TỐI GIẢN
          Container(
            padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navBtn("PREVIOUS", _currentIndex > 0 ? () {
                  setState(() => _currentIndex--);
                } : null),

                Text(
                  "${_currentIndex + 1}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),

                _navBtn("NEXT", _currentIndex < _data.length - 1 ? () {
                  setState(() => _currentIndex++);
                } : null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navBtn(String label, VoidCallback? action) {
    return TextButton(
      onPressed: action,
      child: Text(
        label,
        style: TextStyle(
          color: action == null ? Colors.black26 : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}