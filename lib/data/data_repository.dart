class DataRepository {
  static final DataRepository instance = DataRepository._internal();
  factory DataRepository() => instance;
  DataRepository._internal();

  // Users data
  final List<Map<String, dynamic>> _usersData = [
    {
      'userId': 1,
      'email': 'phuhuynh@gmail.com',
      'password': '123456',
      'hoTen': 'Nguyễn Thị Lan',
      'vaiTro': 'PhuHuynh',
    },
    {
      'userId': 2,
      'email': 'tinhnguyen@gmail.com',
      'password': '123456',
      'hoTen': 'Trần Văn Nam',
      'vaiTro': 'TinhNguyenVien',
    },
  ];

  final List<Map<String, dynamic>> _childrenData = [
    {
      'treEmId': 1,
      'hoTen': 'Nguyễn Văn An',
      'ngaySinh': '2015-05-10',
      'gioiTinh': 'Nam',
      'truong': 'Trường Tiểu học Nguyễn Du',
      'lop': 'Lớp 3A',
      'phuHuynhId': 1,
      'avatar': '👦',
    },
    {
      'treEmId': 2,
      'hoTen': 'Nguyễn Thị Bình',
      'ngaySinh': '2018-08-20',
      'gioiTinh': 'Nữ',
      'truong': 'Trường Mầm non Hoa Mai',
      'lop': 'Lớp Chồi',
      'phuHuynhId': 1,
      'avatar': '👧',
    },
  ];

  final List<Map<String, dynamic>> _eventsData = [
    {
      'suKienId': 1,
      'tenSuKien': 'Ngày hội Trung thu 2024',
      'moTa': 'Tổ chức vui chơi và tặng quà cho các em',
      'diaDiem': 'Sân chơi khu phố 5',
      'ngayBatDau': '2024-09-15',
      'ngayKetThuc': '2024-09-15',
      'trangThai': 'Đã kết thúc',
    },
    {
      'suKienId': 2,
      'tenSuKien': 'Khám sức khỏe định kỳ',
      'moTa': 'Khám sức khỏe miễn phí cho trẻ em khu phố',
      'diaDiem': 'Trạm Y tế Phường 10',
      'ngayBatDau': '2024-11-20',
      'ngayKetThuc': '2024-11-20',
      'trangThai': 'Sắp diễn ra',
    },
    {
      'suKienId': 3,
      'tenSuKien': 'Đón Tết Thiếu nhi 2025',
      'moTa': 'Chương trình văn nghệ và trao quà',
      'diaDiem': 'Nhà văn hóa khu phố',
      'ngayBatDau': '2025-06-01',
      'ngayKetThuc': '2025-06-01',
      'trangThai': 'Sắp diễn ra',
    },
  ];

  final List<Map<String, dynamic>> _phieuDiemData = [
    {
      'phieuId': 1,
      'treEmId': 1,
      'diemTB': 8.5,
      'xepLoai': 'Giỏi',
      'hanhKiem': 'Tốt',
      'ghiChu': 'Em học tập tích cực',
      'ngayCapNhat': '2024-12-15',
      'hocKy': 'HK1 2024-2025',
    },
  ];

  final List<Map<String, dynamic>> _hoTroData = [
    {
      'hoTroId': 1,
      'treEmId': 1,
      'loaiHoTro': 'Học bổng',
      'moTa': 'Học bổng khuyến học học kỳ 1',
      'ngayCap': '2024-10-01',
      'nguoiChiuTrachNhiem': 'Ban điều hành khu phố',
    },
    {
      'hoTroId': 2,
      'treEmId': 2,
      'loaiHoTro': 'Quà tặng',
      'moTa': 'Quà trung thu năm 2024',
      'ngayCap': '2024-09-15',
      'nguoiChiuTrachNhiem': 'Ban điều hành khu phố',
    },
  ];

  final List<Map<String, dynamic>> _thongBaoData = [
    {
      'thongBaoId': 1,
      'loai': 'Sự kiện',
      'noiDung': 'Sự kiện "Khám sức khỏe định kỳ" sẽ diễn ra ngày 20/11/2024',
      'ngayThongBao': '2024-11-10',
      'daDoc': false,
    },
    {
      'thongBaoId': 2,
      'loai': 'Học tập',
      'noiDung': 'Phiếu điểm học kỳ 1 của bé Nguyễn Văn An đã được cập nhật',
      'ngayThongBao': '2024-12-15',
      'daDoc': false,
    },
    {
      'thongBaoId': 3,
      'loai': 'Hỗ trợ',
      'noiDung': 'Bé Nguyễn Văn An đã nhận học bổng khuyến học',
      'ngayThongBao': '2024-10-01',
      'daDoc': true,
    },
  ];

  // Volunteer data
  final List<Map<String, dynamic>> _volunteerData = [
    {
      'tinhNguyenVienId': 1,
      'userId': 2,
      'sdt': '0987654321',
      'ngaySinh': '1995-03-15',
      'chucVu': 'Tổ trưởng',
      'khuPhoId': 1,
    },
  ];

  final List<Map<String, dynamic>> _assignmentData = [
    {
      'phanCongId': 1,
      'suKienId': 2,
      'tinhNguyenVienId': 1,
      'congViec': 'Hỗ trợ đăng ký và hướng dẫn',
      'ghiChu': 'Có mặt trước 30 phút',
      'ngayPhanCong': '2024-11-05',
    },
    {
      'phanCongId': 2,
      'suKienId': 3,
      'tinhNguyenVienId': 1,
      'congViec': 'Tổ chức trò chơi cho trẻ',
      'ghiChu': 'Chuẩn bị đạo cụ',
      'ngayPhanCong': '2024-05-20',
    },
  ];

  final List<Map<String, dynamic>> _scheduleData = [
    {'thu': 'Thứ 2', 'buoi': 'Sáng', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 2', 'buoi': 'Chiều', 'trangThai': false, 'daPhanCong': false},
    {'thu': 'Thứ 2', 'buoi': 'Tối', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 3', 'buoi': 'Sáng', 'trangThai': true, 'daPhanCong': true},
    {'thu': 'Thứ 3', 'buoi': 'Chiều', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 3', 'buoi': 'Tối', 'trangThai': false, 'daPhanCong': false},
    {'thu': 'Thứ 4', 'buoi': 'Sáng', 'trangThai': false, 'daPhanCong': false},
    {'thu': 'Thứ 4', 'buoi': 'Chiều', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 4', 'buoi': 'Tối', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 5', 'buoi': 'Sáng', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 5', 'buoi': 'Chiều', 'trangThai': false, 'daPhanCong': false},
    {'thu': 'Thứ 5', 'buoi': 'Tối', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 6', 'buoi': 'Sáng', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 6', 'buoi': 'Chiều', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 6', 'buoi': 'Tối', 'trangThai': false, 'daPhanCong': false},
    {'thu': 'Thứ 7', 'buoi': 'Sáng', 'trangThai': false, 'daPhanCong': false},
    {'thu': 'Thứ 7', 'buoi': 'Chiều', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Thứ 7', 'buoi': 'Tối', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Chủ nhật', 'buoi': 'Sáng', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Chủ nhật', 'buoi': 'Chiều', 'trangThai': true, 'daPhanCong': false},
    {'thu': 'Chủ nhật', 'buoi': 'Tối', 'trangThai': false, 'daPhanCong': false},
  ];

  final List<Map<String, dynamic>> _childrenVanDongData = [
    {
      'treEmId': 3,
      'hoTen': 'Lê Văn Tùng',
      'ngaySinh': '2016-07-12',
      'gioiTinh': 'Nam',
      'truong': 'Trường Tiểu học Lê Văn Tám',
      'lop': 'Lớp 2B',
      'tinhTrang': 'Nguy cơ bỏ học',
      'loai': 'VanDong',
      'khuPhoId': 1,
    },
    {
      'treEmId': 4,
      'hoTen': 'Trần Thị Mai',
      'ngaySinh': '2017-04-25',
      'gioiTinh': 'Nữ',
      'truong': 'Trường Tiểu học Nguyễn Du',
      'lop': 'Lớp 1C',
      'tinhTrang': 'Nghỉ học',
      'loai': 'VanDong',
      'khuPhoId': 1,
    },
  ];

  final List<Map<String, dynamic>> _childrenHoTroData = [
    {
      'treEmId': 5,
      'hoTen': 'Phạm Văn Hùng',
      'ngaySinh': '2015-11-08',
      'gioiTinh': 'Nam',
      'truong': 'Trường Tiểu học Trần Hưng Đạo',
      'lop': 'Lớp 3A',
      'tinhTrang': 'Chưa nhận',
      'loai': 'HoTro',
      'hoTroId': 3,
      'tenHoTro': 'Quà tết Nguyên đán 2025',
      'khuPhoId': 1,
    },
    {
      'treEmId': 6,
      'hoTen': 'Nguyễn Thị Lan',
      'ngaySinh': '2016-02-14',
      'gioiTinh': 'Nữ',
      'truong': 'Trường Tiểu học Lý Tự Trọng',
      'lop': 'Lớp 2D',
      'tinhTrang': 'Đã phát thành công',
      'loai': 'HoTro',
      'hoTroId': 4,
      'tenHoTro': 'Học bổng tháng 10/2024',
      'khuPhoId': 1,
    },
  ];

  final List<Map<String, dynamic>> _notificationTNVData = [
    {
      'thongBaoId': 4,
      'loai': 'PhanCong',
      'noiDung': 'Bạn được phân công tham gia sự kiện "Khám sức khỏe định kỳ"',
      'ngayThongBao': '2024-11-05',
      'daDoc': false,
      'suKienId': 2,
    },
    {
      'thongBaoId': 5,
      'loai': 'NhacNho',
      'noiDung': 'Nhắc nhở: Sự kiện "Khám sức khỏe định kỳ" sẽ diễn ra vào ngày mai',
      'ngayThongBao': '2024-11-19',
      'daDoc': false,
      'suKienId': 2,
    },
    {
      'thongBaoId': 6,
      'loai': 'HeThong',
      'noiDung': 'Vui lòng cập nhật lịch trống cho tuần tới',
      'ngayThongBao': '2024-10-15',
      'daDoc': true,
    },
  ];

  // Getters
  List<Map<String, dynamic>> get users => _usersData;
  List<Map<String, dynamic>> get children => _childrenData;
  List<Map<String, dynamic>> get events => _eventsData;
  List<Map<String, dynamic>> get phieuDiem => _phieuDiemData;
  List<Map<String, dynamic>> get hoTro => _hoTroData;
  List<Map<String, dynamic>> get thongBao => _thongBaoData;
  List<Map<String, dynamic>> get volunteers => _volunteerData;
  List<Map<String, dynamic>> get assignments => _assignmentData;
  List<Map<String, dynamic>> get schedule => _scheduleData;
  List<Map<String, dynamic>> get childrenVanDong => _childrenVanDongData;
  List<Map<String, dynamic>> get childrenHoTro => _childrenHoTroData;
  List<Map<String, dynamic>> get notificationTNV => _notificationTNVData;

  // Methods
  Map<String, dynamic>? authenticateUser(String email, String password) {
    try {
      return _usersData.firstWhere(
            (u) => u['email'] == email && u['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getChildrenByParent(int userId) {
    return _childrenData.where((c) => c['phuHuynhId'] == userId).toList();
  }

  List<Map<String, dynamic>> getPhieuDiemByChild(int treEmId) {
    return _phieuDiemData.where((p) => p['treEmId'] == treEmId).toList();
  }

  List<Map<String, dynamic>> getHoTroByChild(int treEmId) {
    return _hoTroData.where((h) => h['treEmId'] == treEmId).toList();
  }

  Map<String, dynamic>? getVolunteerByUserId(int userId) {
    try {
      return _volunteerData.firstWhere((v) => v['userId'] == userId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getAssignmentsByVolunteer(int tnvId) {
    return _assignmentData.where((a) => a['tinhNguyenVienId'] == tnvId).toList();
  }
}