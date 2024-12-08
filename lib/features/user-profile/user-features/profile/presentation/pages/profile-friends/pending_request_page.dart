import 'package:doko_react/features/user-profile/user-features/profile/presentation/widgets/pending-requests/pending_incoming_request.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/widgets/pending-requests/pending_outgoing_request.dart';
import 'package:flutter/material.dart';

class PendingRequestPage extends StatelessWidget {
  const PendingRequestPage({super.key});

  static List<Tab> _tabList() {
    return const [
      Tab(
        text: "Incoming",
      ),
      Tab(
        text: "Outgoing",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pending Requests"),
          bottom: TabBar(
            tabs: _tabList(),
          ),
        ),
        body: const TabBarView(
          children: [
            PendingIncomingRequest(),
            PendingOutgoingRequest(),
          ],
        ),
      ),
    );
  }
}
