import 'package:flutter/material.dart';
import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';
import 'package:binbahadhur/features/admin/data/admin_services.dart';

class BinReportsPage extends StatefulWidget {
  static const String routeName = '/BinReportsPage';
  const BinReportsPage({super.key});

  @override
  State<BinReportsPage> createState() => _BinReportsPageState();
}

class _BinReportsPageState extends State<BinReportsPage> {
  final AdminServices adminServices = AdminServices();

  List<dynamic>? reports;
  bool _showNoReportsText = false;
  int? expandedIndex;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    var data = await adminServices.fetchAllReports(context);

    if (!mounted) return;

    setState(() {
      reports = data;
      _showNoReportsText = reports == null || reports!.isEmpty;
    });
  }

  Future<void> acceptReport(String id, int index) async {
    setState(() => isProcessing = true);

    await adminServices.acceptReport(context, id);

    if (!mounted) return;

    setState(() {
      reports![index]['status'] = 'accepted';
      isProcessing = false;
    });
  }

  Future<void> rejectReport(String id, int index) async {
    setState(() => isProcessing = true);

    await adminServices.rejectReport(context, id);

    if (!mounted) return;

    setState(() {
      reports![index]['status'] = 'rejected';
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Bin Overflow Reports"),
      backgroundColor: AppPallete.whiteColor,
      body: RefreshIndicator(
        onRefresh: () async => fetchData(),
        color: AppPallete.backgroundColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (reports == null && !_showNoReportsText) {
      return const Center(
        child: CircularProgressIndicator(color: AppPallete.backgroundColor),
      );
    }

    if (_showNoReportsText || (reports != null && reports!.isEmpty)) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Icon(Icons.delete_outline, size: 100, color: Colors.grey),
          SizedBox(height: 10),
          Center(
            child: Text(
              "No Bin Reports Yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: reports!.length,
      itemBuilder: (context, index) {
        final data = reports![index];
        final isExpanded = expandedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              expandedIndex = isExpanded ? null : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER (always visible)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['phone'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppPallete.backgroundColor,
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Area: ${data['area'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.black),
                  ),

                  Text(
                    "Sub Area: ${data['subArea'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "Status: ${data['status'] ?? 'pending'}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: data['status'] == 'accepted'
                          ? Colors.green
                          : data['status'] == 'rejected'
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),

                  /// EXPANDED SECTION
                  if (isExpanded) ...[
                    const SizedBox(height: 12),

                    if (data['imageUrl'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          data['imageUrl'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 10),

                    Text(
                      data['description'] ?? "No description provided",
                      style: const TextStyle(color: Colors.black87),
                    ),

                    const SizedBox(height: 12),

                    /// ACTION BUTTONS
                    if (data['status'] == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: isProcessing
                                  ? null
                                  : () => acceptReport(data['_id'], index),
                              child: const Text(
                                "Accept",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: isProcessing
                                  ? null
                                  : () => rejectReport(data['_id'], index),
                              child: const Text(
                                "Reject",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        "Already ${data['status']}!",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
