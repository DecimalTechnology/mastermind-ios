import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/utils/platform_text_field.dart';

class OneToOne extends StatefulWidget {
  const OneToOne({super.key});

  @override
  State<OneToOne> createState() => _OneToOneState();
}

class _OneToOneState extends State<OneToOne> {
  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        title: const Text("One-To One Slip"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Center(
            child: SizedBox(
              height: 45,
              width: 350,
              child: Center(
                child: PlatformTextField(
                  placeholder: 'Met With:',
                  onChanged: (query) {
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: SizedBox(
              height: 45,
              width: 350,
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Initiated By',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: SizedBox(
              height: 45,
              width: 350,
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Where did you meet?',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: SizedBox(
              height: 45,
              width: 350,
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tuesday, February 25, 2025',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 170,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black),
            ),
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: "Topics of Conversation",
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: PlatformButton(
              onPressed: () {},
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
