import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/AuthProvider.dart';
import '../../providers/BloodProvider.dart';
import '../search/SearchDonorScreen.dart';
import '../../models/BloodRequest.dart';
import 'RequestDetailScreen.dart';
import '../../utils/Constants.dart';
import '../../widgets/CustomDrawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDonorMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final blood = Provider.of<BloodProvider>(context, listen: false);
    
    setState(() => _isDonorMode = auth.isDonorMode);
    
    String role = auth.isDonorMode ? 'receiver' : 'sender';
    blood.fetchMyRequests(role);
    blood.startPolling(role);
    blood.fetchCitiesAndBloodGroups();
  }

  @override
  void dispose() {
    Provider.of<BloodProvider>(context, listen: false).stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final blood = Provider.of<BloodProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isDonorMode ? 'Donor Dashboard' : 'BloodLink',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isDonorMode)
            Switch(
              value: auth.user?.profile?.available ?? true,
              onChanged: (v) {
                auth.updateProfile({'available': v});
              },
              activeColor: Colors.greenAccent,
            ),
        ],
      ),
      drawer: CustomDrawer(
        onChangePasswordPressed: () => _showChangePasswordDialog(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchInitialData();
        },
        child: _isDonorMode ? _buildDonorView(blood) : _buildRecipientView(blood),
      ),
    );
  }

  Widget _buildRecipientView(BloodProvider blood) {
    final bloodGroups = blood.bloodGroups;
    final activeRequests = blood.myRequests.where((r) => r.status == 'Pending').toList();
    final recentResponses = blood.myRequests.where((r) => r.status == 'Accepted' || r.status == 'Rejected').toList();
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeRequests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Active Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: activeRequests.length,
                itemBuilder: (context, index) {
                  final req = activeRequests[index];
                  final minsLeft = req.minutesLeft;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailScreen(request: req),
                        ),
                      );
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryColor.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need ${req.bloodGroup} for ${req.patientName}', 
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(req.hospitalName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pending', 
                                    style: TextStyle(
                                      color: Colors.orange, 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 13
                                    )
                                  ),
                                  if (minsLeft > 0)
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 12, color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Text('$minsLeft mins left', style: const TextStyle(fontSize: 11, color: Colors.orange)),
                                      ],
                                    )
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white, 
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: primaryColor.withOpacity(0.2))
                                ),
                                child: Text(
                                  'View', 
                                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          if (recentResponses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Recent Responses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: recentResponses.length,
                itemBuilder: (context, index) {
                  final req = recentResponses[index];
                  final isAccepted = req.status == 'Accepted';
                  final statusColor = isAccepted ? Colors.green : Colors.red;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestDetailScreen(request: req),
                        ),
                      );
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: statusColor.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need ${req.bloodGroup} for ${req.patientName}', 
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(req.hospitalName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isAccepted ? Icons.check_circle_outline : Icons.cancel_outlined, 
                                    color: statusColor, 
                                    size: 16
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    req.status, 
                                    style: TextStyle(
                                      color: statusColor, 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 13
                                    )
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white, 
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: statusColor.withOpacity(0.2))
                                ),
                                child: Text(
                                  isAccepted ? 'Call Donor' : 'View', 
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Need Blood?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Select a blood group to find donors near you.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: bloodGroups.length,
            itemBuilder: (context, index) {
              return _bloodGroupCard(bloodGroups[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _bloodGroupCard(String group) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SearchDonorScreen(bloodGroup: group)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype, color: Theme.of(context).primaryColor, size: 30),
            const SizedBox(height: 8),
            Text(group, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorView(BloodProvider blood) {
    if (blood.isLoading) return const Center(child: CircularProgressIndicator());
    if (blood.myRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No blood requests received yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: blood.myRequests.length,
      itemBuilder: (context, index) {
        final req = blood.myRequests[index];
        final minsLeft = req.minutesLeft;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            title: Text('Need ${req.bloodGroup} for ${req.patientName}', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('${req.hospitalName} | ${req.city}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(req.status, 
                    style: TextStyle(
                      color: req.status == 'Accepted' ? Colors.green : (req.status == 'Pending' ? Colors.orange : Colors.red),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    )),
                if (req.status == 'Pending' && minsLeft > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('$minsLeft mins', style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: Color(0xFFC62828), size: 28),
                  SizedBox(width: 10),
                  Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              content: SizedBox(
                width: 320,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: oldPasswordController,
                          obscureText: obscureOld,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => obscureOld = !obscureOld),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: obscureNew,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_open),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => obscureNew = !obscureNew),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm new password';
                            }
                            if (value != newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const Center(child: CircularProgressIndicator()),
                      );

                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final error = await auth.changePassword(
                        oldPasswordController.text,
                        newPasswordController.text,
                      );

                      // Pop loading dialog
                      if (!context.mounted) return;
                      Navigator.pop(context);

                      if (error == null) {
                        // Pop Change Password dialog
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('UPDATE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
