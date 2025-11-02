import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/xem_anh_screen.dart';
import 'package:provider/provider.dart';

import '../../models/tab_con_toi.dart';
import '../../providers/phu_huynh.dart';
import 'chi_tiet_tre_em_screen.dart';

class DanhSachConEmScreen extends StatelessWidget {
  const DanhSachConEmScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách con em'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.danhSachCon.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadDanhSachCon();
            });
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.danhSachCon.length,
            itemBuilder: (context, index) {
              return _buildConCard(context, provider.danhSachCon[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildConCard(BuildContext context, TreEmBasicInfo con) {
    final isMale = con.gioiTinh.toLowerCase() == 'nam';
    final avatarColor = isMale ? Colors.blue.shade100 : Colors.pink.shade100;
    final iconColor = isMale ? Colors.blue.shade700 : Colors.pink.shade700;

    const baseUrl = 'http://10.0.2.2:5035';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: GestureDetector(
          onTap: () {
            if (con.anh != null && con.anh!.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewerScreen(
                    imageUrl: '$baseUrl${con.anh}',
                    title: con.hoTen,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: ClipOval(
              child: con.anh != null && con.anh!.isNotEmpty
                  ? Image.network(
                '$baseUrl${con.anh}',
                fit: BoxFit.cover,
                loadingBuilder: (context, imageChild, loadingProgress) {
                  if (loadingProgress == null) return imageChild;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Nếu load ảnh lỗi thì hiển thị icon theo giới tính
                  return Icon(
                    isMale ? Icons.boy : Icons.girl,
                    size: 32,
                    color: iconColor,
                  );
                },
              )
                  : Icon(
                isMale ? Icons.boy : Icons.girl,
                size: 32,
                color: iconColor,
              ),
            ),
          ),
        ),
        title: Text(
          con.hoTen,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Ngày sinh: ${con.ngaySinh}'),
            Text('Trường: ${con.tenTruong}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () async {
            final provider = context.read<PhuHuynhProvider>();

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
              const Center(child: CircularProgressIndicator()),
            );

            try {
              await provider.loadThongTinTreEm(con.treEmID);
              Navigator.pop(context);

              if (provider.thongTinTreEm != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ThongTinTreEmScreen(thongTin: provider.thongTinTreEm!),
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi: ${e.toString()}')),
              );
            }
          },
        ),
      ),
    );
  }
}
