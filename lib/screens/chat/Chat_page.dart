import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Removed unused import
import 'package:master_mind/screens/chat/Chat_Screen.dart'; // Ensure this file exports a widget named ChatScreen
// Removed unused import
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/shimmer_avatar.dart';
// Removed unused import

class ChatPages extends StatelessWidget {
  const ChatPages({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        titleSpacing: 2,
        title: const Text("Chat"),
        centerTitle: true,
        actions: [
          // Search icon launches the search delegate
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ChatSearchDelegate());
            },
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      drawer: const Drawer(),
      backgroundColor: Colors.white,
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: 10, // Replace with your dynamic data count
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (PlatformUtils.isIOS) {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ChatPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                // Uncomment the following to add a shadow:
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withValues(alpha: 0.3),
                //     blurRadius: 5,
                //     offset: const Offset(0, 3),
                //   ),
                // ],
                // border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ListTile(
                leading: const ShimmerAvatar(
                  radius: 20,
                ),
                title: Text("John Doe $index"),
                subtitle: Text("Last message $index"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom SearchDelegate for ChatPages
class ChatSearchDelegate extends SearchDelegate {
  // Sample list of chat contacts
  final List<Map<String, String>> chatContacts = [
    {"name": "John Doe", "subtitle": "Hello there!"},
    {"name": "Alice Smith", "subtitle": "How are you?"},
    {"name": "Bob Johnson", "subtitle": "Let's catch up."},
    {"name": "Carol White", "subtitle": "Good morning."},
    {"name": "David Brown", "subtitle": "See you soon."},
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(CupertinoIcons.back, color: Colors.black54, size: 28),
      onPressed: () {
        close(context, null); // close search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = chatContacts
        .where((contact) =>
            contact["name"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final contact = results[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(contact["name"]!),
          subtitle: Text(contact["subtitle"]!),
          onTap: () {
            // Handle tapping a search result.
            close(context, null);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = chatContacts
        .where((contact) =>
            contact["name"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final contact = suggestions[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(contact["name"]!),
          subtitle: Text(contact["subtitle"]!),
          onTap: () {
            query = contact["name"]!;
            showResults(context);
          },
        );
      },
    );
  }
}
