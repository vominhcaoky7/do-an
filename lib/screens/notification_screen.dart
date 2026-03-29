import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/app_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // ⚠️ SỬA IP CHO ĐÚNG
  final String baseUrl = "http://10.0.2.2:5182/api/notification";

  List<AppNotification> notifications = [];
  bool isLoading = true;

  // Màu chủ đạo
  final Color primaryColor = const Color(0xFF2563EB); // Xanh dương hiện đại
  final Color bgColor = const Color(0xFFF3F4F6); // Xám nền nhẹ

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          notifications = data.map((e) => AppNotification.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  // Hàm format ngày giờ thủ công (để không cần cài thêm thư viện intl)
  String _formatDate(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      String hour = dt.hour.toString().padLeft(2, '0');
      String minute = dt.minute.toString().padLeft(2, '0');
      return "$hour:$minute - ${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: primaryColor),
            tooltip: "Đánh dấu đã đọc hết",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã đánh dấu tất cả là đã đọc")),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : notifications.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: notifications.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return _buildModernNotificationItem(item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 80, color: Colors.blue[200]),
          ),
          const SizedBox(height: 20),
          const Text(
            "Bạn chưa có thông báo nào",
            style: TextStyle(
                color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNotificationItem(AppNotification item) {
    // Logic màu sắc dựa trên trạng thái đọc
    final bool isUnread = !item.isRead;
    final Color cardColor = isUnread ? Colors.white : const Color(0xFFFAFAFA);
    final Color textColor = isUnread ? Colors.black87 : Colors.black54;
    final FontWeight titleWeight = isUnread ? FontWeight.w800 : FontWeight.w600;

    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        // Xử lý xóa ở đây (gọi API xóa nếu cần)
        setState(() {
          notifications.remove(item);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa thông báo")),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          // Nếu chưa đọc, thêm một viền xanh nhỏ bên trái để gây chú ý
          border: isUnread
              ? Border.all(color: primaryColor.withOpacity(0.1), width: 1)
              : Border.all(color: Colors.transparent),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Icon
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUnread
                            ? [Colors.blue[100]!, Colors.blue[50]!]
                            : [Colors.grey[200]!, Colors.grey[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: isUnread ? primaryColor : Colors.grey,
                      size: 24,
                    ),
                  ),
                  // Dấu chấm đỏ nếu chưa đọc
                  if (isUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // 2. Nội dung text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: titleWeight,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Thời gian
                        Text(
                          _formatDate(item.createdAt)
                              .split(' - ')[0], // Chỉ lấy giờ
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnread ? Colors.grey[800] : Colors.grey[500],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Ngày tháng
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.createdAt)
                              .split(' - ')[1], // Lấy ngày
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
