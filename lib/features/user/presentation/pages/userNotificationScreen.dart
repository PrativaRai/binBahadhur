import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/constants/global_variable.dart';
import 'package:binbahadhur/features/rewards/presentation/reward_page.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/auth/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:binbahadhur/core/widgets/user_bottom_nav.dart';

class UserNotificationScreen extends StatefulWidget {
  static const String routeName = '/user-notifications';
  const UserNotificationScreen({super.key});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  Future<Map<String, dynamic>>? _myRequestsFuture;
  bool _hasFetched = false;
  int currentIndex = 3; // notification tab

  final Map<String, Timer> _pendingDeletions = {};

  @override
  void dispose() {
    for (var timer in _pendingDeletions.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasFetched) {
      final token = Provider.of<UserProvider>(
        context,
        listen: false,
      ).user.token;
      _myRequestsFuture = _fetchMyRequests(token);
      _hasFetched = true;
    }
  }

  Future<void> _handleRefresh() async {
    final token = Provider.of<UserProvider>(context, listen: false).user.token;

    setState(() {
      _myRequestsFuture = _fetchMyRequests(token);
    });

    await _myRequestsFuture;
  }

  Future<Map<String, dynamic>> _fetchMyRequests(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$uri/api/user/my-requests'),
        headers: {'x-auth-token': token, 'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Network Error: $e'};
    }
  }

  Future<void> _deleteRequestPermanently(String requestId, String token) async {
    try {
      await http.delete(
        Uri.parse('$uri/api/user/dismiss-request/$requestId'),
        headers: {'x-auth-token': token, 'Content-Type': 'application/json'},
      );
    } catch (e) {
      debugPrint("Database deletion error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<UserProvider>(context, listen: false).user.token;

    return Scaffold(
      appBar: CommonAppBar(title: "My Request Updates"),
      backgroundColor: AppPallete.whiteColor,
      bottomNavigationBar: UserBottomNav(
        currentIndex: currentIndex,
        onIndexChanged: (index) {
          setState(() => currentIndex = index);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppPallete.blackColor,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _myRequestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildEmpty("Connection Error: ${snapshot.error}");
            }

            if (snapshot.data == null || snapshot.data!['success'] == false) {
              return _buildEmpty(
                snapshot.data?['error'] ?? "Failed to load updates",
              );
            }

            final List<dynamic> requestsList = snapshot.data!['tasks'] ?? [];

            if (requestsList.isEmpty) {
              return _buildEmpty(
                "No notifications or active requests found",
                icon: Icons.notifications_none_rounded,
              );
            }

            return ListView.builder(
              itemCount: requestsList.length,
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final request = requestsList[index];
                final employee = request['assignedTo'];
                final status = (request['status'] ?? 'pending').toLowerCase();

                final bool isHandled = employee != null || status != 'pending';
                final workerName = employee?['name'] ?? "Service Professional";
                final workerPhone =
                    employee?['phone'] ?? (request['phone'] ?? "Processing...");
                final requestId = request['_id'] ?? index.toString();

                return Dismissible(
                  key: Key(requestId),
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Dismiss",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    final dismissedItem = request;
                    final originalIndex = index;

                    setState(() {
                      requestsList.removeAt(index);
                    });

                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();

                    final deleteTimer = Timer(const Duration(seconds: 3), () {
                      _pendingDeletions.remove(requestId);
                      _deleteRequestPermanently(requestId, token);
                      messenger.hideCurrentSnackBar();
                    });

                    _pendingDeletions[requestId] = deleteTimer;

                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text("Notification dismissed"),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: () {
                            if (!mounted) return;

                            if (_pendingDeletions.containsKey(requestId)) {
                              _pendingDeletions[requestId]?.cancel();
                              _pendingDeletions.remove(requestId);
                            }

                            setState(() {
                              requestsList.insert(originalIndex, dismissedItem);
                            });

                            messenger.hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: AppPallete.whiteColor,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      iconColor: AppPallete.blackColor,
                      collapsedIconColor: Colors.black,
                      title: Text(
                        "${request['area'] ?? 'N/A'} - ${request['subArea'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppPallete.blackColor,
                        ),
                      ),
                      subtitle: Text(
                        isHandled
                            ? "Accepted by $workerName"
                            : "Waiting for assignment",
                        style: TextStyle(
                          fontSize: 12,
                          color: isHandled ? Colors.green : Colors.black,
                        ),
                      ),
                      trailing: _statusBadge(status),
                      children: [
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(
                            workerName,
                            style: const TextStyle(
                              color: AppPallete.blackColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            workerPhone,
                            style: const TextStyle(
                              color: AppPallete.blackColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (status == 'completed')
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Weight: ${request['weightCollected']} kg",
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Paid: रू ${request['moneyPaid']}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppPallete.backgroundColor,
                                      foregroundColor: AppPallete.whiteColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      int calculatedPoints = 0;
                                      if (request['weightCollected'] != null) {
                                        final double weight =
                                            double.tryParse(
                                              request['weightCollected']
                                                  .toString(),
                                            ) ??
                                            0.0;
                                        calculatedPoints = weight.round();
                                      }

                                      if (calculatedPoints == 0) {
                                        calculatedPoints = 10;
                                      }

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RewardPage(
                                            points: calculatedPoints,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "View Rewards",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(String text, {IconData? icon}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, size: 60, color: Colors.black),
                const SizedBox(height: 12),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.grey;

    if (status == 'completed') color = Colors.green;
    if (status == 'assigned') color = Colors.orange;
    if (status == 'started' || status == 'in-progress') {
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}