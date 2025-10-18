import '../data/data_repository.dart';

class ParentService {
  final DataRepository _repository = DataRepository();

  List<Map<String, dynamic>> getChildren(int userId) {
    return _repository.getChildrenByParent(userId);
  }

  List<Map<String, dynamic>> getPhieuDiem(int treEmId) {
    return _repository.getPhieuDiemByChild(treEmId);
  }

  List<Map<String, dynamic>> getHoTro(int treEmId) {
    return _repository.getHoTroByChild(treEmId);
  }

  List<Map<String, dynamic>> getEvents() {
    return _repository.events;
  }

  List<Map<String, dynamic>> getNotifications() {
    return _repository.thongBao;
  }

  bool registerEvent(int suKienId, List<int> childrenIds, String note) {
    // Mock implementation
    return true;
  }
}
