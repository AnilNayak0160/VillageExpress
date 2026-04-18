import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (for OTP)
  await Firebase.initializeApp();

  // Initialize Supabase (for Storage & DB)
  await Supabase.initialize(
    url: 'https://zwwaimzznykyjmknzdhr.supabase.co', // Get from Supabase Project Settings > API
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3d2FpbXp6bnlreWpta256ZGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0OTA2MjMsImV4cCI6MjA5MjA2NjYyM30.5B6q00NnvomlTIjwKbNe44AVHY3j381-dYCS3FDir5Q', // Get from Supabase Project Settings > API
  );

  runApp(MyApp());
}

// Shortcut to use Supabase anywhere in your code
final supabase = Supabase.instance.client;


Color primaryColor = Color(0xFFFF5722);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/village.png', height: 100),
              SizedBox(height: 24),
              Text(
                "Welcome to Village Market",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF102C2E)),
              ),
              SizedBox(height: 12),
              Text(
                "How would you like to use the app?",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
              SizedBox(height: 40),

              // --- CUSTOMER CARD ---
              HoverCard(
                title: "I'm a Customer",
                subtitle: "Order from local shops, book\nrides & home services",
                icon: Icons.shopping_bag_outlined,
                themeColor: Color(0xFF328562), // Green
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerScreen())),
              ),

              SizedBox(height: 20),

              // --- SHOPKEEPER CARD ---
              HoverCard(
                title: "I'm a Shopkeeper",
                subtitle: "Register your shop & receive\norders from customers",
                icon: Icons.storefront_outlined,
                themeColor: Color(0xFFFF5722), // Orange
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final VoidCallback onTap;

  HoverCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.onTap,
  });

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool isPressed = false; // For Mobile touch feedback
  bool isHovered = false; // For Web mouse feedback

  @override
  Widget build(BuildContext context) {
    // Check if the card should look "highlighted"
    bool active = isHovered || isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // This handles the "Highlight" effect when you touch it on mobile
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // The Dark Border seen in your reference
            border: Border.all(
              color: active ? Color(0xFF102C2E) : Colors.grey.shade300,
              width: active ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(active ? 0.1 : 0.02),
                blurRadius: active ? 20 : 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.themeColor, size: 28),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF102C2E)
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.3
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: active ? Color(0xFF102C2E) : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// ================= COMMON =================
Widget buildInput(
    TextEditingController controller, String hint, String prefix) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        prefixText: prefix,
      ),
    ),
  );
}

Widget buildButton(String text, Function onTap) {
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(text,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    ),
  );
}

class CustomerScreen extends StatefulWidget {
  final bool isLogin;
  CustomerScreen({this.isLogin = false});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  late bool isLogin;
  int currentStep = 1; // Registration has 3 steps, Login has 2 (Mobile & OTP)
  bool otpSent = false;
  String verificationId = "";

  final Color primaryOrange = Color(0xFFFF5722);

  // Controllers
  final phoneController = TextEditingController();
  final villageController = TextEditingController();
  final addressController = TextEditingController();
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  // --- FIREBASE LOGIC WITH VALIDATION ---
  void sendOTP() async {
    // 1. Basic empty field check
    if (phoneController.text.isEmpty || phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid 10-digit mobile number")),
      );
      return;
    }

    // 2. CHECK IF ACCOUNT EXISTS (Only if isLogin is true)
    if (isLogin) {
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('customers')
            .where('phone', isEqualTo: phoneController.text)
            .get();

        if (userDoc.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No Account found. Please register first."),
              backgroundColor: Colors.redAccent,
            ),
          );
          return; // Stop here, do not send OTP
        }
      } catch (e) {
        print("Firestore Error: $e");
      }
    }

    // 3. SEND OTP (If registration OR account exists)
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text}",
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Verification Failed")),
        );
      },
      codeSent: (id, _) {
        setState(() {
          verificationId = id;
          otpSent = true;
          // UI Step management
          if (isLogin) {
            currentStep = 2;
          } else {
            currentStep = 3;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP Sent Successfully")),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  void verifyAndProceed() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the OTP")),
      );
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpController.text.trim());

      UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);

      if (isLogin) {
        // LOGIN SUCCESS: Go to App Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => CustomerHome()),
              (r) => false,
        );
      } else {
        // REGISTRATION SUCCESS: Save to Firestore then Success Screen
        await FirebaseFirestore.instance.collection('customers').doc(user.user!.uid).set({
          'phone': phoneController.text,
          'village': villageController.text,
          'address': addressController.text,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(), // Good practice to track date
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerSuccessScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP ❌"), backgroundColor: Colors.red),
      );
    }
  }

  // --- UI HELPER ---
  Widget buildStyledInput(TextEditingController controller, String label, String hint, IconData icon, {int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF102C2E))),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: TextField(
            controller: controller,
            maxLines: lines,
            keyboardType: label.contains("Mobile") || label.contains("OTP") ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey, size: 20),
              hintText: hint,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            Padding(
              padding: EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  if (currentStep > 1) setState(() => currentStep--);
                  else Navigator.pop(context);
                },
                child: Row(children: [Icon(Icons.arrow_back, size: 18, color: Colors.grey), Text(" Back", style: TextStyle(color: Colors.grey))]),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Icon(isLogin ? Icons.login : Icons.person_add_alt_1_outlined, color: primaryOrange, size: 30)
                    ),
                    SizedBox(height: 20),

                    // Dynamic Title
                    Text(
                        isLogin
                            ? (currentStep == 1 ? "Customer Login" : "Verify OTP")
                            : (currentStep == 1 ? "Contact Info" : (currentStep == 2 ? "Your Location" : "Verify OTP")),
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
                    ),

                    Text(
                        isLogin ? "Welcome back!" : "Step $currentStep of 3",
                        style: TextStyle(color: Colors.grey)
                    ),
                    SizedBox(height: 20),

                    // Progress Bars (Only show for Registration)
                    if (!isLogin) Row(children: [
                      Expanded(child: Container(height: 6, decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(10)))),
                      SizedBox(width: 8),
                      Expanded(child: Container(height: 6, decoration: BoxDecoration(color: currentStep >= 2 ? primaryOrange : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)))),
                      SizedBox(width: 8),
                      Expanded(child: Container(height: 6, decoration: BoxDecoration(color: currentStep == 3 ? primaryOrange : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)))),
                    ]),

                    SizedBox(height: 30),

                    // --- INPUT FIELDS ---
                    if (currentStep == 1)
                      buildStyledInput(phoneController, "Mobile Number *", "10-digit number", Icons.phone_android_outlined),

                    if (!isLogin && currentStep == 2) ...[
                      buildStyledInput(villageController, "Village / Area *", "e.g. Rampur", Icons.home_outlined),
                      SizedBox(height: 20),
                      buildStyledInput(addressController, "Home Address *", "House number, street...", Icons.location_on_outlined, lines: 3),
                    ],

                    if ((isLogin && currentStep == 2) || (!isLogin && currentStep == 3))
                      buildStyledInput(otpController, "Enter OTP *", "6-digit code", Icons.lock_outline),

                    SizedBox(height: 40),

                    // --- MAIN BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: () {
                          if (isLogin) {
                            if (currentStep == 1) sendOTP(); else verifyAndProceed();
                          } else {
                            if (currentStep == 1) setState(() => currentStep = 2);
                            else if (currentStep == 2) sendOTP();
                            else verifyAndProceed();
                          }
                        },
                        child: Text(
                          isLogin
                              ? (currentStep == 1 ? "Send OTP" : "Login")
                              : (currentStep == 1 ? "Continue" : (currentStep == 2 ? "Send OTP" : "Register")),
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    Center(
                      child: TextButton(
                        onPressed: () => setState(() { isLogin = !isLogin; currentStep = 1; }),
                        child: Text(isLogin ? "New user? Register here" : "Already have an account? Login", style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ================= CUSTOMER SUCCESS SCREEN =================
class CustomerSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text("Registered!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Your account is ready."),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5722),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  // CHANGED: Goes to Customer Login mode
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => CustomerScreen(isLogin: true)),
                          (r) => false
                  ),
                  child: Text("Continue to Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
            )
          ],
        ),
      ),
    );
  }
}


// ================= CUSTOMER HOME =================
class CustomerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9F8),
      appBar: AppBar(
        title: Text("Village Market"),
        backgroundColor: Color(0xFFFF5722), // Your Orange theme
        actions: [
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              "Welcome to the Marketplace!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Find shops near your village", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF5722)),
              onPressed: () {
                // This removes the Dashboard and takes the user back to the very first screen (HomeScreen)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                      (route) => false,
                );
              },
              child: Text("Logout", style: TextStyle(color: Colors.white)),
            )

          ],
        ),
      ),
    );
  }
}



// ================= SHOP SCREEN (ENHANCED) =================
class ShopScreen extends StatefulWidget {
  final bool isLogin;
  ShopScreen({this.isLogin = false});

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late bool isLogin;
  int currentStep = 1;

  // Timer variables
  Timer? _timer;
  int _start = 30;
  bool _canResend = true;

  final Color primaryOrange = Color(0xFFFF5722);
  final Color lightBg = Color(0xFFF8F9F8);

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final phone = TextEditingController();
  final otp = TextEditingController();
  final shopName = TextEditingController();
  final shopAddress = TextEditingController();

  String? category;
  String verificationId = "";
  bool otpSent = false;

  final categories = ["Food", "Grocery", "Cloth", "Medicine", "Electronics", "Hardware", "Stationary", "Other"];

  // Start Resend Timer
  void startTimer() {
    setState(() { _canResend = false; _start = 30; });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() { timer.cancel(); _canResend = true; });
      } else {
        setState(() { _start--; });
      }
    });
  }

  // --- VALIDATION ---
  bool validateInputs() {
    if (phone.text.length != 10) {
      showError("Enter a valid 10-digit number");
      return false;
    }
    if (!isLogin && currentStep == 1) {
      if (shopName.text.isEmpty) { showError("Shop Name is required"); return false; }
      if (category == null) { showError("Please select a category"); return false; }
    }
    if (!isLogin && currentStep == 2 && shopAddress.text.isEmpty) {
      showError("Shop Address is required");
      return false;
    }
    return true;
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void sendOTP() async {
    if (!validateInputs()) return;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${phone.text}",
      verificationCompleted: (_) {},
      verificationFailed: (e) => showError(e.message ?? "Verification Failed"),
      codeSent: (id, _) {
        setState(() { verificationId = id; otpSent = true; });
        startTimer();
      },
      codeAutoRetrievalTimeout: (id) => verificationId = id,
    );
  }

  void verifyOTP() async {
    if (otp.text.length < 6) { showError("Enter 6-digit OTP"); return; }
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp.text.trim());

      UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);

      if (isLogin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ShopDashboard(user.user!.uid)));
      } else {
        await FirebaseFirestore.instance.collection('shops').doc(user.user!.uid).set({
          'phone': phone.text,
          'shopName': shopName.text,
          'category': category,
          'address': shopAddress.text,
          'role': 'shop',
          'createdAt': FieldValue.serverTimestamp(),
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SuccessScreen()));
      }
    } catch (e) {
      showError("Invalid OTP ❌");
    }
  }

  Widget buildDesignInput(TextEditingController controller, String label, String hint, IconData icon, {int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF102C2E))),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: TextField(
            controller: controller,
            maxLines: lines,
            keyboardType: label.contains("Mobile") || label.contains("OTP") ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey, size: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Back Button
              InkWell(
                onTap: () {
                  if (!isLogin && currentStep > 1) setState(() => currentStep = 1);
                  else Navigator.pop(context);
                },
                child: Row(children: [Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey), Text("Back", style: TextStyle(color: Colors.grey))]),
              ),
              SizedBox(height: 30),
              Icon(Icons.storefront, color: primaryOrange, size: 40),
              SizedBox(height: 10),
              Text(isLogin ? "Shop Login" : (currentStep == 1 ? "Shop Details" : "Shop Address"), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(isLogin ? "Access your store dashboard" : "Step $currentStep of 2", style: TextStyle(color: Colors.grey)),

              if (!isLogin) ...[
                SizedBox(height: 20),
                Row(children: [
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(10)))),
                  SizedBox(width: 8),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: currentStep == 2 ? primaryOrange : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)))),
                ]),
              ],

              SizedBox(height: 30),

              if (isLogin) ...[
                buildDesignInput(phone, "Mobile Number *", "Enter 10 digit number", Icons.phone_android),
                if (otpSent) ...[
                  SizedBox(height: 20),
                  buildDesignInput(otp, "OTP Code", "Enter 6 digit code", Icons.lock_clock_outlined),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _canResend ? sendOTP : null, child: Text(_canResend ? "Resend OTP" : "Resend in ${_start}s"))),
                ]
              ] else ...[
                if (currentStep == 1) ...[
                  buildDesignInput(phone, "Mobile Number *", "Enter 10 digit number", Icons.phone_android),
                  SizedBox(height: 20),
                  buildDesignInput(shopName, "Shop Name *", "e.g. Maa Store", Icons.store),
                  SizedBox(height: 20),
                  Text("Category *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: category, isExpanded: true, hint: Text("Select Category"),
                        items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => category = v),
                      ),
                    ),
                  ),
                ] else ...[
                  buildDesignInput(shopAddress, "Full Address *", "Street, Landmark, Village...", Icons.map_outlined, lines: 3),
                  if (otpSent) ...[
                    SizedBox(height: 20),
                    buildDesignInput(otp, "OTP Code", "Enter code", Icons.lock_outline),
                  ]
                ]
              ],

              SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (isLogin) { if (!otpSent) sendOTP(); else verifyOTP(); }
                    else {
                      if (currentStep == 1) { if(validateInputs()) setState(() => currentStep = 2); }
                      else { if (!otpSent) sendOTP(); else verifyOTP(); }
                    }
                  },
                  child: Text(isLogin ? (otpSent ? "Login" : "Send OTP") : (currentStep == 1 ? "Continue" : (otpSent ? "Register Shop" : "Send OTP")), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              Center(child: TextButton(onPressed: () => setState(() { isLogin = !isLogin; otpSent = false; }), child: Text(isLogin ? "Don't have a shop? Register" : "Already have a shop? Login", style: TextStyle(color: Colors.grey)))),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SHOP DASHBOARD (WITH DATA FETCH) =================


class ShopDashboard extends StatelessWidget {
  final String uid;
  ShopDashboard(this.uid);

  // Theme Colors - Defined here so they are accessible to all methods
  final Color primaryOrange = Color(0xFFFF5722);
  final Color darkBlue = Color(0xFF102C2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9F8),
      appBar: AppBar(
        title: Text("Shop Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Add your logout logic here
            },
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('shops').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryOrange));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Shop details not found."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String shopKeeper = data['shopKeeperName'] ?? 'Srikant Nayak';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. SHOP DETAILS HEADER ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 30),
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Rectangular Shop Image
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/images/GrocoreyShop.jpg'),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      shopKeeper,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // ⭐ STAR RATING
                                    Icon(Icons.star, color: Colors.amber, size: 20),
                                    Text(" 4.8",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text(
                                  data['shopName'] ?? 'Maa Budhi Jagulei Store',
                                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Divider(color: Colors.white24, thickness: 1),
                      SizedBox(height: 15),
                      buildInfoRow(Icons.person, "Shopkeeper", shopKeeper),
                      buildInfoRow(Icons.phone, "Phone", data['phone'] ?? "N/A"),
                      buildInfoRow(Icons.location_on, "Address", data['address'] ?? "N/A"),
                    ],
                  ),
                ),

                // --- 2. ORDER NOTIFICATION SECTION ---
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 30, 24, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pending Orders",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlue)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                        child: Text("New",
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4)
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("Order #1024 - ₹450.00",
                              style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue)),
                          subtitle: Text("Items: Bread, Milk, Eggs..."),
                          trailing: Icon(Icons.shopping_bag_outlined, color: primaryOrange),
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  // Logic to Accept Order
                                },
                                child: Text("Accept"),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  // Logic to Reject Order
                                },
                                child: Text("Reject"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // --- 3. PRODUCT MANAGEMENT SECTION ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("Product Management",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlue)),
                ),

                SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      buildActionCard(context, "Add Product", Icons.add_box, Colors.green, () {}),
                      buildActionCard(context, "Edit Product", Icons.edit_note, Colors.blue, () {}),
                      buildActionCard(context, "Delete Product", Icons.delete_sweep, Colors.red, () {}),
                      buildActionCard(context, "View All", Icons.list_alt, Colors.orange, () {}),
                    ],
                  ),
                ),

                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER: INFO ROW ---
  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          SizedBox(width: 8),
          Text("$label: ",
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // --- HELPER: ACTION CARD ---
  Widget buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: Offset(0, 4)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(height: 12),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}



// ================= SUCCESS SCREEN =================
class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text("Registered!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Your shop is now live."),
            SizedBox(height: 30),
            ElevatedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => ShopScreen(isLogin: true)), (r) => false), child: Text("Login to Dashboard")),
          ],
        ),
      ),
    );
  }
}


