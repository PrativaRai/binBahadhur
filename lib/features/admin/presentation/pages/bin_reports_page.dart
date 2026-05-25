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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    var data = await adminServices.fetchAllReports(context);
    if (mounted) {
      setState(() {
        reports = data;
        _showNoReportsText = reports == null || reports!.isEmpty;
      });
    }
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
    // Loading
    if (reports == null && !_showNoReportsText) {
      return const Center(
        child: CircularProgressIndicator(color: AppPallete.backgroundColor),
      );
    }

    // Empty
    if (_showNoReportsText || (reports != null && reports!.isEmpty)) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Icon(Icons.delete_outline, size: 100, color: AppPallete.greyColor),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "No Bin Reports Yet",
              style: TextStyle(fontSize: 18, color: AppPallete.greyColor, fontWeight: FontWeight.w500),
            ),
          ),
          const Center(child: Text("Swipe down to check for updates")),
        ],
      );
    }

    // Show List
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: reports!.length,
      itemBuilder: (context, index) {
        final data = reports![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppPallete.whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: Colors.orange),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Area: ${data['area'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          Text(
                            'Sub Area: ${data['subArea'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${data['status'] ?? 'pending'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: data['status'] == 'completed' ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}