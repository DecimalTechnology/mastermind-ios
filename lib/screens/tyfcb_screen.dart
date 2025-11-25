import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/tyfcb_provider.dart';
import 'package:master_mind/providers/connection_Provider.dart';
import 'package:master_mind/models/search_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:master_mind/models/tyfcb_model.dart';

class TYFCBScreen extends StatefulWidget {
  const TYFCBScreen({Key? key}) : super(key: key);

  @override
  State<TYFCBScreen> createState() => _TYFCBScreenState();
}

class _TYFCBScreenState extends State<TYFCBScreen> {
  final TextEditingController thankYouToController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  int businessType = 0; // 0: New, 1: Repeat

  List<SearchResult> filteredConnections = [];
  bool showDropdown = false;
  SearchResult? selectedConnection;

  @override
  void initState() {
    super.initState();
    // Load connections when the screen initializes
    Future.microtask(() {
      Provider.of<ConnectionProvider>(context, listen: false)
          .ensureConnectionsLoaded();
    });
  }

  String get businessTypeString => businessType == 0 ? 'New' : 'Repeat';

  void _submit(BuildContext context) async {
    final provider = Provider.of<TYFCBProvider>(context, listen: false);
    final thankYouTo = thankYouToController.text.trim();
    final amount = amountController.text.trim();
    final comments = commentsController.text.trim();

    if (thankYouTo.isEmpty ||
        amount.isEmpty ||
        selectedConnection == null ||
        selectedConnection!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill all required fields and select a valid connection.')),
      );
      return;
    }

    final model = TYFCBModel(
      id: selectedConnection!.id ?? '',
      message: comments,
      amount: int.tryParse(amount) ?? 0,
      createdAt: DateTime.now(),
      image: selectedConnection!.image ?? '',
      name: thankYouTo,
      email: selectedConnection!.company ?? '',
      businessType: businessTypeString,
    );

    await provider.submitTYFCB(model);

    if (provider.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TYFCB submitted successfully!')),
      );
      thankYouToController.clear();
      amountController.clear();
      commentsController.clear();
      setState(() {
        businessType = 0;
      });
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${provider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused variable
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: kPrimaryColor),
          onPressed: () {}, // Add drawer logic if needed
        ),
        title: const Text(
          'Record TYFCB',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: kPrimaryColor),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: FutureBuilder(
          future: Provider.of<ConnectionProvider>(context, listen: false)
              .ensureConnectionsLoaded(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading your connections...'),
                  ],
                ),
              );
            }
            final allConnections =
                Provider.of<ConnectionProvider>(context, listen: false)
                        .allconnectionsDetails ??
                    [];
            return Consumer<TYFCBProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownSearch<String>(
                      items: (String? filter, _) {
                        final names = allConnections
                            .map((conn) => conn.name ?? '')
                            .toList();
                        if (filter == null || filter.isEmpty) return names;
                        return names
                            .where((name) => name
                                .toLowerCase()
                                .contains(filter.toLowerCase()))
                            .toList();
                      },
                      selectedItem: thankYouToController.text,
                      onChanged: (String? selected) {
                        thankYouToController.text = selected ?? '';
                        selectedConnection = allConnections.firstWhere(
                          (conn) => conn.name == selected,
                          orElse: () => SearchResult(),
                        );
                      },
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: "Thank you to",
                          hintText: "Search and select a connection",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        fit: FlexFit.loose,
                        constraints: BoxConstraints(),
                        showSearchBox: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Business Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => businessType = 0),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: businessType == 0
                                    ? kPrimaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: kPrimaryColor),
                              ),
                              child: Center(
                                child: Text(
                                  'New',
                                  style: TextStyle(
                                    color: businessType == 0
                                        ? Colors.white
                                        : kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => businessType = 1),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: businessType == 1
                                    ? kPrimaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: kPrimaryColor),
                              ),
                              child: Center(
                                child: Text(
                                  'Repeat',
                                  style: TextStyle(
                                    color: businessType == 1
                                        ? Colors.white
                                        : kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Comments:',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 100,
                        maxHeight: 150,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: commentsController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: PlatformButton(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        isLoading: provider.isLoading,
                        onPressed:
                            provider.isLoading ? null : () => _submit(context),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Bottom padding for safe area
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
