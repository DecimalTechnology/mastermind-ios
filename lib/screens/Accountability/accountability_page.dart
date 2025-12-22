import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Removed unused import
import 'package:master_mind/screens/create_accountability_page.dart';
import 'package:master_mind/screens/Accountability/accountability_detail_page.dart';
import 'package:master_mind/providers/accountability_provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/screens/Accountability/accountability_slip_card.dart';
import 'package:master_mind/utils/const.dart';

class AccountabilityPage extends StatefulWidget {
  const AccountabilityPage({super.key});

  @override
  State<AccountabilityPage> createState() => _AccountabilityPageState();
}

class _AccountabilityPageState extends State<AccountabilityPage> {
  @override
  void initState() {
    super.initState();
    _fetchSlips();
  }

  Future<void> _fetchSlips() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accountabilityProvider =
        Provider.of<AccountabilityProvider>(context, listen: false);
    final String? token = await authProvider.authRepository.getAuthToken();
    if (token == null) return;
    await accountabilityProvider.fetchSlips(token: token);
  }

  @override
  Widget build(BuildContext context) {
    final accountabilityProvider = Provider.of<AccountabilityProvider>(context);
    final slips = accountabilityProvider.slips;
    final isLoading = accountabilityProvider.isLoading;
    final error = accountabilityProvider.error;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Accountability Slips',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // backgroundColor: kPrimaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading accountability slips...',
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: kRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading slips',
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _fetchSlips,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (slips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Accountability Slips',
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first accountability slip\nto get started',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final created = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateAccountabilityPage(),
                        ),
                      );
                      if (created == true) {
                        await _fetchSlips();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Slip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchSlips,
            color: kPrimaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: slips.length,
              itemBuilder: (context, index) {
                final slip = slips[index];
                return AccountabilitySlipCard(
                  slip: slip,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountabilityDetailPage(slip: slip),
                      ),
                    );
                  },
                  onEdit: () async {
                    final now = DateTime.now();

                    // Convert UTC date to local time first
                    final localDate = slip.date.toLocal();

                    // Check if the meeting date is in the past (without time consideration)
                    final meetingDate = DateTime(
                      localDate.year,
                      localDate.month,
                      localDate.day,
                    );
                    final today = DateTime(now.year, now.month, now.day);

                    // If the meeting date is before today, it's definitely past
                    if (meetingDate.isBefore(today)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot edit past meetings'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // If the meeting is today, check the time
                    if (meetingDate.isAtSameMomentAs(today)) {
                      // Create meeting DateTime in local timezone
                      final meetingDateTime = DateTime(
                        localDate.year,
                        localDate.month,
                        localDate.day,
                        localDate.hour,
                        localDate.minute,
                      );
                      final isPast = meetingDateTime.isBefore(now);

                      if (isPast) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot edit past meetings'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                    }

                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAccountabilityPage(
                          initialSlip: slip,
                          isEdit: true,
                        ),
                      ),
                    );
                    if (updated == true) {
                      await _fetchSlips();
                    }
                  },
                  onDelete: () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Slip?'),
                        content: const Text(
                            'Are you sure you want to delete this slip?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      final String? token =
                          await authProvider.authRepository.getAuthToken();
                      if (token != null) {
                        final provider = Provider.of<AccountabilityProvider>(
                            context,
                            listen: false);
                        await provider.deleteSlip(
                            token: token, slipId: slip.id!);
                        await _fetchSlips();
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAccountabilityPage()),
          );
          if (created == true) {
            await _fetchSlips();
          }
        },
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Slip'),
      ),
    );
  }
}
