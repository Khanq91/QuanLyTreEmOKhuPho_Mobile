import 'package:flutter/material.dart';
import 'package:mobile/screen/phuhuynh/xem_anh_screen.dart';
import 'package:provider/provider.dart';

import '../../models/tab_tai_khoan_ph.dart';
import '../../providers/phu_huynh.dart';
import 'chi_tiet_phu_huynh_screen.dart';

class DanhSachPhuHuynhScreen extends StatelessWidget {
  const DanhSachPhuHuynhScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách phụ huynh'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PhuHuynhProvider>(
        builder: (context, provider, child) {
          if (provider.danhSachPhuHuynh.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadDanhSachPhuHuynh();
            });
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadDanhSachPhuHuynh(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDanhSachPhuHuynh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.danhSachPhuHuynh.length,
              itemBuilder: (context, index) {
                return _buildPhuHuynhCard(
                  context,
                  provider.danhSachPhuHuynh[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
  Widget _buildPhuHuynhCard(
      BuildContext context, PhuHuynhVoiMoiQuanHe phuHuynh) {
    const baseUrl = 'http://10.0.2.2:5035';
    final hasAvatar = phuHuynh.anh.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với avatar và thông tin cơ bản
            Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: hasAvatar
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewerScreen(
                          imageUrl: '$baseUrl${phuHuynh.anh}',
                          title: phuHuynh.hoTen,
                        ),
                      ),
                    );
                  }
                      : null,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade700, width: 2),
                    ),
                    child: ClipOval(
                      child: hasAvatar
                          ? Image.network(
                        '$baseUrl${phuHuynh.anh}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person,
                              size:40,
                              color: Colors.blue.shade700);
                        },
                      )
                          : Icon(Icons.person,
                          size: 40, color: Colors.blue.shade700),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Thông tin cơ bản
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phuHuynh.hoTen,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            phuHuynh.sdt,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (phuHuynh.ngheNghiep.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.work, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                phuHuynh.ngheNghiep,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Nút Edit
                IconButton(
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
                      await provider.loadChiTietPhuHuynh(phuHuynh.phuHuynhID);
                      Navigator.pop(context);

                      if (provider.chiTietPhuHuynh != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChiTietPhuHuynhScreen(
                              phuHuynh: provider.chiTietPhuHuynh!,
                            ),
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
              ],
            ),

            // Divider
            if (phuHuynh.danhSachMoiQuanHe.isNotEmpty) ...[
              const Divider(height: 24, thickness: 1),
              // Mối quan hệ với trẻ em
              Row(
                children: [
                  Icon(Icons.family_restroom,
                      size: 20, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Mối quan hệ:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...phuHuynh.danhSachMoiQuanHe.map((mqh) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 28),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                            children: [
                              TextSpan(
                                text: '${mqh.moiQuanHe} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const TextSpan(text: 'của '),
                              TextSpan(
                                text: mqh.tenTreEm,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}