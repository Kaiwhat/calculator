import 'package:flutter/material.dart';
import 'currency.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ 新增

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // 打開 Email App 寫信
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'your_support_email@example.com', // TODO: 換成客服信箱
      query: encodeQueryParameters(<String, String>{
        'subject': '旅遊記帳 App 客戶服務',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw Exception('無法開啟 Email App');
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 常用貨幣
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('常用貨幣'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencyPage()),
              );
            },
          ),
          const Divider(),

          // 移除廣告
          ListTile(
            leading: const Icon(Icons.remove_circle_outline),
            title: const Text('移除廣告'),
            trailing: const Icon(Icons.lock, size: 16),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('功能尚未開放')));
            },
          ),
          const Divider(),

          // 語言設定
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('語言設定'),
            trailing: const Icon(Icons.settings, size: 16),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('功能尚未開放')));
            },
          ),
          const Divider(),

          // 聯絡我們
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('聯絡我們'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _launchEmail,
          ),
        ],
      ),
    );
  }
}
