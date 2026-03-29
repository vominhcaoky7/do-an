import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/community_post.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // ⚠️ ĐÃ SỬA: Xóa dấu "/" ở cuối chuỗi baseUrl để tránh bị lỗi 2 dấu gạch chéo
  final String baseUrl = "http://10.0.2.2:5182/api/community";

  List<CommunityPost> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeed();
  }

  // 1. Lấy danh sách bài viết
  Future<void> fetchFeed() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/feed'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data.map((json) => CommunityPost.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print("Lỗi tải dữ liệu: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. Gửi bài viết mới
  Future<void> createPost(String title, String content) async {
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng nhập đầy đủ tiêu đề và nội dung")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "title": title,
          "content": content,
          "authorName": "Bệnh nhân (App)",
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã gửi bài! Vui lòng chờ Admin duyệt."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Lỗi đăng bài: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    }
  }

  // ... (Phần UI bên dưới giữ nguyên không cần sửa) ...
  // Hộp thoại nhập bài mới
  void showCreateDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đăng câu hỏi/Chia sẻ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tiêu đề",
                hintText: "Ví dụ: Hỏi về lịch tiêm...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: "Nội dung",
                hintText: "Nhập nội dung chi tiết...",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () =>
                createPost(titleController.text, contentController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            child: const Text("Gửi bài"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CLB Người Bệnh"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.forum_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      const Text("Chưa có bài viết nào.",
                          style: TextStyle(color: Colors.grey)),
                      const Text("Hãy là người đầu tiên chia sẻ!",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    String dateDisplay =
                        post.createdAt.split('.')[0].replaceAll('T', ' ');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.pink[100],
                                  child: Text(
                                    post.authorName.isNotEmpty
                                        ? post.authorName[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                        color: Colors.pink,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.authorName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      dateDisplay,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              post.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.blueAccent),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.content,
                              style: const TextStyle(fontSize: 15, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showCreateDialog,
        backgroundColor: Colors.pinkAccent,
        icon: const Icon(Icons.edit),
        label: const Text("Đăng bài"),
      ),
    );
  }
}
