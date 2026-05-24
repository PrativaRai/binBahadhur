import 'dart:async';
import 'package:binbahadhur/core/constants/common_appbar.dart';
import 'package:binbahadhur/core/constants/utils.dart';
import 'package:binbahadhur/features/admin/data/admin_services.dart';
import 'package:binbahadhur/features/employee/Data/complain_model.dart';
import 'package:flutter/material.dart';
import 'package:binbahadhur/core/theme/app_pallete.dart';

class ReportsPage extends StatefulWidget {
  static const String routeName = '/ReportsPage';
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final AdminServices adminServices = AdminServices();
  List<ComplainModel>? complaints;
  bool _showNoComplainText = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    startTimeout();
  }

  void startTimeout() {
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted && (complaints == null || complaints!.isEmpty)) {
        setState(() {
          _showNoComplainText = true;
        });
      }
    });
  }

  void fetchData() async {
    var data = await adminServices.fetchAllComplain(context);
    if (mounted) {
      setState(() {
        complaints = data;
        if (complaints != null && complaints!.isNotEmpty) {
          _showNoComplainText = false;
        }
      });
    }
  }

  void resolveComplain(ComplainModel complain, int index) {
    adminServices.deleteComplain(
      context: context,
      complain: complain,
      onSuccess: () {
        setState(() {
          complaints!.removeAt(index);
        });
        showSnackBar(context, "Complaint resolved and deleted!");
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Reports"),
      backgroundColor: AppPallete.whiteColor,
      body: RefreshIndicator(
        onRefresh: () async => fetchData(),
        color: AppPallete.backgroundColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    //Loading
    if (complaints == null && !_showNoComplainText) {
      return const Center(
        child: CircularProgressIndicator(color: AppPallete.backgroundColor),
      );
    }

    //Empty / Timeout
    if (_showNoComplainText || (complaints != null && complaints!.isEmpty)) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          const Icon(
            Icons.verified_user_outlined,
            size: 100,
            color: AppPallete.greyColor,
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "No Pending Complaints",
              style: TextStyle(
                fontSize: 18,
                color: AppPallete.greyColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Center(child: Text("Swipe down to check for updates")),
        ],
      );
    }

    //Show List
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: complaints!.length,
      itemBuilder: (context, index) {
        final data = complaints![index];
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
                  Container(width: 6, color: AppPallete.red),
                  Expanded(
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
                                  data.phoneNumber, // CHANGED from data.email
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppPallete.backgroundColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.phone_android,
                                size: 18,
                                color: AppPallete.backgroundColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.description,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Reported by:",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    data.employee,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPallete.backgroundColor,
                                  foregroundColor: AppPallete.whiteColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                onPressed: () => resolveComplain(data, index),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text(
                                  "Resolve",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
