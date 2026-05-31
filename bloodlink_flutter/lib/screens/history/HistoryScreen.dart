import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/BloodProvider.dart';
import '../../providers/AuthProvider.dart';
import '../../models/BloodRequest.dart';
import 'package:intl/intl.dart';
import '../home/RequestDetailScreen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  
  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final blood = Provider.of<BloodProvider>(context, listen: false);
    blood.fetchMyRequests('all', status: 'History');
    blood.startPolling('all', status: 'History');
  }

  @override
  void dispose() {
    Provider.of<BloodProvider>(context, listen: false).stopPolling();
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blood = Provider.of<BloodProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _mainTabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Sent Requests'),
            Tab(text: 'Received Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _buildNestedTabView(blood.myRequests.where((r) => r.sender == auth.user?.id).toList()),
          _buildNestedTabView(blood.myRequests.where((r) => r.receiver == auth.user?.id).toList()),
        ],
      ),
    );
  }

  Widget _buildNestedTabView(List<BloodRequest> requests) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.red,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.red,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Accepted'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRequestList(requests.where((r) => r.status == 'Pending').toList()),
                _buildRequestList(requests.where((r) => r.status == 'Accepted').toList()),
                _buildRequestList(requests.where((r) => r.status == 'Rejected').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<BloodRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No requests found in this category.', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final req = requests[index];
        final minutesLeft = req.minutesLeft;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              req.patientName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${req.bloodGroup} | ${req.hospitalName}'),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(req.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusChip(req.status),
                if (req.status == 'Pending' && minutesLeft > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('$minutesLeft mins', style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestDetailScreen(request: req),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.grey;
    if (status == 'Accepted') color = Colors.green;
    if (status == 'Rejected') color = Colors.red;
    if (status == 'Pending') color = Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
