// import 'package:flutter/material.dart';
// import 'package:master_mind/providers/Auth_provider.dart';
// import 'package:master_mind/screens/Landing_screen.dart';
// import 'package:provider/provider.dart';

// class RegistrationForm extends StatefulWidget {
//   @override
//   _RegistrationFormState createState() => _RegistrationFormState();
// }

// class _RegistrationFormState extends State<RegistrationForm> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();

//   bool _isPrivacyAccepted = false; // ✅ Checkbox state

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => RegistrationProvider(),
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
//             child: Form(
//               key: _formKey,
//               child: Consumer<RegistrationProvider>(
//                 builder: (context, provider, child) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Image.asset('assets/loginScreen/logo.png'),
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: const Text("Create your account",
//                             style: TextStyle(
//                                 fontSize: 24, fontWeight: FontWeight.bold)),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _nameController,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: const Color.fromARGB(87, 187, 199, 207),
//                           labelText: "Name",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           prefixIcon: const Icon(Icons.person),
//                         ),
//                         validator: (value) =>
//                             value!.isEmpty ? "Enter your name" : null,
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: const Color.fromARGB(87, 187, 199, 207),
//                           labelText: "Email",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           prefixIcon: const Icon(Icons.email),
//                         ),
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) =>
//                             !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
//                                     .hasMatch(value!)
//                                 ? "Enter a valid email"
//                                 : null,
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _phoneController,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: const Color.fromARGB(87, 187, 199, 207),
//                           labelText: "Mobile Number",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           prefixIcon: const Icon(Icons.phone),
//                         ),
//                         keyboardType: TextInputType.phone,
//                         validator: (value) =>
//                             value!.length != 10 ? "Enter a valid number" : null,
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: const Color.fromARGB(87, 187, 199, 207),
//                           labelText: "Password",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           prefixIcon: const Icon(Icons.lock),
//                         ),
//                         validator: (value) =>
//                             value!.length < 6 ? "Password too short" : null,
//                       ),
//                       const SizedBox(height: 20),

//                       /// ✅ Privacy Policy Checkbox
//                       Row(
//                         children: [
//                           Checkbox(
//                             value: _isPrivacyAccepted,
//                             onChanged: (bool? newValue) {
//                               setState(() {
//                                 _isPrivacyAccepted = newValue!;
//                               });
//                             },
//                           ),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 // Show Privacy Policy Dialog or Navigate to Policy Page
//                               },
//                               child: const Text(
//                                 "I agree to the Privacy Policy & Terms",
//                                 style: TextStyle(
//                                   decoration: TextDecoration.underline,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       /// OTP Section
//                       provider.isOTPSent
//                           ? Column(
//                               children: [
//                                 TextFormField(
//                                   controller: _otpController,
//                                   decoration: InputDecoration(
//                                     filled: true,
//                                     fillColor:
//                                         const Color.fromARGB(87, 187, 199, 207),
//                                     labelText: "Enter Your OTP",
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     prefixIcon: const Icon(Icons.email),
//                                   ),
//                                   keyboardType: TextInputType.number,
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     ElevatedButton(
//                                       onPressed: () async {
//                                         if (_formKey.currentState!.validate()) {
//                                           await provider.verifyOTP(
//                                               _otpController.text.trim());
//                                           Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     BottomNavbar()),
//                                           );
//                                         }
//                                       },
//                                       child: const Text("Verify OTP"),
//                                     ),
//                                     TextButton(
//                                       onPressed: () async {
//                                         await provider.sendOTP(
//                                             "+91${_phoneController.text.trim()}");
//                                       },
//                                       child: const Text("Resend OTP"),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             )
//                           : SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: _isPrivacyAccepted
//                                     ? () async {
//                                         if (_formKey.currentState!.validate()) {
//                                           await provider.sendOTP(
//                                               "+91${_phoneController.text.trim()}");
//                                         }
//                                       }
//                                     : null, // ✅ Disabled if unchecked
//                                 child: provider.isLoading
//                                     ? const CircularProgressIndicator(
//                                         color: Colors.white)
//                                     : const Text("Send OTP"),
//                               ),
//                             ),
//                       const SizedBox(height: 25),
//                       Center(child: Text("Or connect via")),
//                       const SizedBox(height: 25),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               width: 85,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border:
//                                     Border.all(color: Colors.black, width: 1),
//                               ),
//                               child: Image.asset(
//                                   "assets/loginScreen/Google logo.png"),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               width: 85,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border:
//                                     Border.all(color: Colors.black, width: 1),
//                               ),
//                               child:
//                                   Image.asset("assets/loginScreen/Facbook.png"),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               width: 85,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border:
//                                     Border.all(color: Colors.black, width: 1),
//                               ),
//                               child:
//                                   Image.asset("assets/loginScreen/Vector.png"),
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
