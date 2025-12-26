import 'package:flutter/material.dart';

// Model nội bộ cho Quiz
class _QuizItem {
  final String question;
  final String answer;
  final String explanation;
  final String level; // NHẬN BIẾT, THÔNG HIỂU, VẬN DỤNG, VẬN DỤNG CAO

  _QuizItem({
    required this.question,
    required this.answer,
    required this.explanation,
    required this.level,
  });
}

class QuizDetailSecond extends StatefulWidget {
  const QuizDetailSecond({Key? key}) : super(key: key);

  @override
  State<QuizDetailSecond> createState() => _QuizDetailSecondState();
}

class _QuizDetailSecondState extends State<QuizDetailSecond> {
  // Trạng thái đóng/mở của 7 câu hỏi
  final List<bool> _isOpen = List.generate(7, (index) => false);

  // NỘI DUNG ĐƯỢC LẤY TỪ DỮ LIỆU BẠN CUNG CẤP (ĐÃ CLEAN LATEX)
  final List<_QuizItem> _quizData = [
    _QuizItem(
      level: "NHẬN BIẾT",
      question:
      "Phương trình bậc 2 nào dưới đây có dạng chuẩn?\n"
          "A. x² + 3x = 0\n"
          "B. 2x² + 5 = 0\n"
          "C. x² + 4x + 4 = 0\n"
          "D. 3x + 2 = 0",
      answer: "C. x² + 4x + 4 = 0",
      explanation:
      "Phương trình bậc 2 dạng chuẩn là ax² + bx + c = 0 với a ≠ 0. "
          "Đáp án C có đầy đủ các hệ số a = 1, b = 4, c = 4. "
          "Các đáp án khác hoặc thiếu hệ số hoặc là phương trình bậc 1.",
    ),
    _QuizItem(
      level: "THÔNG HIỂU",
      question:
      "Phương trình bậc 2 có dạng tổng quát nào sau đây?\n"
          "A. ax + b = 0 (a ≠ 0)\n"
          "B. ax² + bx + c = 0 (a ≠ 0)\n"
          "C. bx² + c = 0 (b ≠ 0)\n"
          "D. ax³ + bx² + c = 0 (a ≠ 0)",
      answer: "B. ax² + bx + c = 0 (a ≠ 0)",
      explanation:
      "Phương trình bậc 2 có số mũ cao nhất là 2 và hệ số a phải khác 0. "
          "Đáp án A là bậc nhất, C thiếu bx, D là phương trình bậc 3.",
    ),
    _QuizItem(
      level: "THÔNG HIỂU",
      question:
      "Tại sao phương trình 2x² - 8 = 0 có thể rút gọn về dạng x² = 4?\n"
          "A. Vì phương trình có hệ số b = 0\n"
          "B. Vì phương trình không có hằng số c\n"
          "C. Vì phương trình có dạng đặc biệt ax² + c = 0\n"
          "D. Vì phương trình có nghiệm duy nhất",
      answer: "C. Vì phương trình có dạng đặc biệt ax² + c = 0",
      explanation:
      "Phương trình 2x² - 8 = 0 có hệ số b = 0 nên thuộc dạng ax² + c = 0. "
          "Ta có thể chuyển vế và chia cho a để tìm x² trực tiếp.",
    ),
    _QuizItem(
      level: "VẬN DỤNG",
      question:
      "Một vật được thả từ độ cao 80 m. Chiều cao theo thời gian t (giây) là "
          "h = -5t² + 80. Hỏi sau bao nhiêu giây vật chạm đất?\n"
          "A. 4 giây\n"
          "B. 2 giây\n"
          "C. 8 giây\n"
          "D. 16 giây",
      answer: "A. 4 giây",
      explanation:
      "Khi vật chạm đất thì h = 0. "
          "Giải phương trình -5t² + 80 = 0 → t² = 16 → t = 4 (giây).",
    ),
    _QuizItem(
      level: "VẬN DỤNG CAO",
      question:
      "Một vật được ném lên cao với vận tốc ban đầu 20 m/s. "
          "Chiều cao theo thời gian t là h = -5t² + 20t. "
          "Khoảng thời gian nào vật đạt độ cao từ 15 m đến 20 m?\n"
          "A. 1 giây ≤ t ≤ 2 giây\n"
          "B. 0,5 giây ≤ t ≤ 1,5 giây\n"
          "C. 1 giây ≤ t ≤ 3 giây\n"
          "D. 0,5 giây ≤ t ≤ 2 giây",
      answer: "A. 1 giây ≤ t ≤ 2 giây",
      explanation:
      "Giải h = 15 được t = 1 và t = 3. "
          "Giải h = 20 được t = 2. "
          "Vật đi lên trong khoảng từ 1 giây đến 2 giây thì đạt độ cao từ 15 m đến 20 m.",
    ),
    _QuizItem(
      level: "VẬN DỤNG",
      question:
      "Giải phương trình x² - 5x + 6 = 0. Nghiệm của phương trình là:\n"
          "A. x = 1 và x = 6\n"
          "B. x = -2 và x = -3\n"
          "C. x = 2 và x = 3\n"
          "D. x = -1 và x = -6",
      answer: "C. x = 2 và x = 3",
      explanation:
      "Ta có Δ = (-5)² - 4·1·6 = 1. "
          "Nghiệm là x = (5 ± 1) / 2 → x = 2 và x = 3.",
    ),
    _QuizItem(
      level: "THÔNG HIỂU",
      question:
      "Để phương trình ax² + bx + c = 0 có hai nghiệm phân biệt thì điều kiện của Δ là gì?\n"
          "A. Δ = 0\n"
          "B. Δ < 0\n"
          "C. Δ > 0\n"
          "D. Δ ≤ 0",
      answer: "C. Δ > 0",
      explanation:
      "Khi biệt thức Δ lớn hơn 0 thì phương trình bậc 2 có hai nghiệm phân biệt.",
    ),
  ];


  Color _getLevelColor(String level) {
    switch (level) {
      case 'NHẬN BIẾT': return Colors.green;
      case 'THÔNG HIỂU': return Colors.blue;
      case 'VẬN DỤNG': return Colors.orange;
      case 'VẬN DỤNG CAO': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F2ED),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("HỆ THỐNG CÂU HỎI", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "LUYỆN TẬP\nTRẮC NGHIỆM",
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1.5),
            ),
            const SizedBox(height: 10),
            Container(height: 4, width: 60, color: Colors.black),
            const SizedBox(height: 30),

            // Danh sách 7 câu hỏi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quizData.length,
              itemBuilder: (context, index) {
                final item = _quizData[index];
                return _buildAccordion(index, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordion(int index, _QuizItem item) {
    bool isOpen = _isOpen[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOpen ? Colors.black : Colors.black12, width: isOpen ? 2 : 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isOpen[index] = !isOpen),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("0${index + 1}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isOpen ? Colors.black : Colors.black26)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLevelTag(item.level),
                        const SizedBox(height: 8),
                        Text(item.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4)),
                      ],
                    ),
                  ),
                  Icon(isOpen ? Icons.remove : Icons.add, color: Colors.black),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildAnswerDetail(item),
            crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTag(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: _getLevelColor(level).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getLevelColor(level))),
    );
  }

  Widget _buildAnswerDetail(_QuizItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 55, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 10),
          const Text("ĐÁP ÁN ĐÚNG:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.green, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(item.answer, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text("GIẢI THÍCH:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(item.explanation, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7), height: 1.5)),
        ],
      ),
    );
  }
}