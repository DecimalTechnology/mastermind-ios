import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/utils/platform_text_field.dart';

class RefferalScreen extends StatefulWidget {
  const RefferalScreen({super.key});

  @override
  State<RefferalScreen> createState() => _RefferalScreenState();
}

class _RefferalScreenState extends State<RefferalScreen> {
  bool isChecked1 = false;
  bool isChecked2 = false;
  String selectedReferralType = "Inside"; // Default selected type
  int selectedBar = 1; // Default selected bar

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        title: const Text("Refferal Slip"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
      ),
      drawer: Drawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 45,
                  width: 350,
                  child: PlatformTextField(
                    placeholder: 'To',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    onChanged: (query) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(width: 15),
                    Text(
                      "Refferal Type",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedReferralType = "Inside";
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1),
                        color: selectedReferralType == "Inside"
                            ? Color.fromARGB(134, 217, 98, 238)
                            : Colors.white,
                      ),
                      height: 30,
                      width: 100,
                      child: Center(
                        child: Text(
                          "Inside",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedReferralType = "Outside";
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1),
                        color: selectedReferralType == "Outside"
                            ? Color.fromARGB(134, 217, 98, 238)
                            : Colors.white,
                      ),
                      height: 30,
                      width: 100,
                      child: Center(
                        child: Text(
                          "Outside",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    "Refferal Status",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 15),
                  Checkbox(
                    value: isChecked1,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked1 = value!;
                      });
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Told Them You"),
                      Text("Would Call"),
                    ],
                  ),
                  SizedBox(width: 20),
                  Checkbox(
                    value: isChecked2,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked2 = value!;
                      });
                    },
                  ),
                  Text("Given Your Card"),
                ],
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 45,
                  width: 350,
                  child: PlatformTextField(
                    placeholder: 'Refferal',
                    suffixIcon: const Icon(Icons.contact_mail),
                    onChanged: (query) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 45,
                  width: 350,
                  child: PlatformTextField(
                    placeholder: 'Telephone',
                    keyboardType: TextInputType.phone,
                    onChanged: (query) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 45,
                  width: 350,
                  child: PlatformTextField(
                    placeholder: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (query) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                    hintText: " Address",
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
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
                    hintText: " Comment",
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Text(
                      "How hot is this referral?",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: (index + 1) * 20.0,
                        width: 20,
                        color: Colors.blue,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Radio(
                        value: index + 1,
                        groupValue: selectedBar,
                        onChanged: (int? value) {
                          setState(() {
                            selectedBar = value!;
                          });
                        },
                      ),
                    ],
                  );
                }),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: const Text("Submit"),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
