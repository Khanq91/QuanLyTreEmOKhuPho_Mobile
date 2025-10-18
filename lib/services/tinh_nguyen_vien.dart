import '../data/data_repository.dart';

class VolunteerService {
  final DataRepository _repository = DataRepository();

  Map<String, dynamic>? getVolunteerInfo(int userId) {
    return _repository.getVolunteerByUserId(userId);
  }

  List<Map<String, dynamic>> getAssignments(int tnvId) {
    return _repository.getAssignmentsByVolunteer(tnvId);
  }

  List<Map<String, dynamic>> getEvents() {
    return _repository.events;
  }

  List<Map<String, dynamic>> getSchedule() {
    return _repository.schedule;
  }

  List<Map<String, dynamic>> getChildrenVanDong() {
    return _repository.childrenVanDong;
  }

  List<Map<String, dynamic>> getChildrenHoTro() {
    return _repository.childrenHoTro;
  }

  List<Map<String, dynamic>> getNotifications() {
    return _repository.notificationTNV;
  }

  bool updateChildStatus(int treEmId, String status, String note, String? imagePath) {
    // Mock implementation
    return true;
  }

  bool updateSupportStatus(int treEmId, String status, DateTime? date, String note, String imagePath) {
    // Mock implementation
    return true;
  }

  bool saveSchedule(List<Map<String, dynamic>> schedule) {
    // Mock implementation
    return true;
  }
}