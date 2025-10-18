import 'package:flutter/material.dart';

import '../../services/phu_huynh.dart';

class ParentEventsTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const ParentEventsTab({Key? key, required this.user}) : super(key: key);

  @override
  State<ParentEventsTab> createState() => _ParentEventsTabState();
}

class _ParentEventsTabState extends State<ParentEventsTab> {
  String _filter = 'Tất cả';
  final ParentService _service = ParentService();

  @override
  Widget build(BuildContext context) {
    var filteredEvents = _service.getEvents();
    if (_filter == 'Sắp diễn ra') {
      filteredEvents = filteredEvents
          .where((s) => s['trangThai'] == 'Sắp diễn ra')
          .toList();
    } else if (_filter == 'Đã kết thúc') {
      filteredEvents = filteredEvents
          .where((s) => s['trangThai'] == 'Đã kết thúc')
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sự kiện'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả'),
                  _buildFilterChip('Sắp diễn ra'),
                  _buildFilterChip('Đã kết thúc'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      // Navigate to detail
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event['tenSuKien'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Chip(
                                label: Text(event['trangThai'],
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: event['trangThai'] ==
                                    'Sắp diễn ra'
                                    ? Colors.blue[100]
                                    : Colors.grey[300],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 4),
                              Text(event['ngayBatDau']),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Expanded(child: Text(event['diaDiem'])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event['moTa'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filter = label);
        },
        selectedColor: Colors.blue[100],
      ),
    );
  }
}
