import 'dart:io'; // <--- THIS FIXES THE ERROR
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:image_picker/image_picker.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (for OTP)
  await Firebase.initializeApp();

  // Initialize Supabase (for Storage & DB)
  await Supabase.initialize(
    url: 'https://zwwaimzznykyjmknzdhr.supabase.co', // Get from Supabase Project Settings > API
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3d2FpbXp6bnlreWpta256ZGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0OTA2MjMsImV4cCI6MjA5MjA2NjYyM30.5B6q00NnvomlTIjwKbNe44AVHY3j381-dYCS3FDir5Q', // Get from Supabase Project Settings > API
  );

  runApp(VillageExpressApp());
}

final supabase = Supabase.instance.client;

class VillageExpressApp extends StatelessWidget {
  const VillageExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Village Express',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// --- AUTH WRAPPER ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginPage();
      },
    );
  }
}

// --- HOME PAGE (DESIGN RESTORED & OVERFLOW FIXED) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // ✅ FIXED: Added scrolling to prevent yellow overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Village Logo
                Image.asset(
                  'assets/images/village.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront, size: 100, color: Color(0xFF102C2E)),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Welcome to Village Market",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF102C2E)),
                ),
                const SizedBox(height: 12),
                Text(
                  "How would you like to use the app?",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 40),

                // --- CUSTOMER CARD ---
                HoverCard(
                  title: "I'm a Customer",
                  subtitle: "Order from local shops, book\nrides & home services",
                  icon: Icons.shopping_bag_outlined,
                  themeColor: const Color(0xFF328562),
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerPage()));
                  },
                ),

                const SizedBox(height: 20),

                // --- SHOPKEEPER CARD ---
                HoverCard(
                  title: "I'm a Shopkeeper",
                  subtitle: "Register your shop & receive\norders from customers",
                  icon: Icons.storefront_outlined,
                  themeColor: const Color(0xFFFF5722),
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => ShopkeeperPage()));
                  },
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HOVER CARD WIDGET ---
class HoverCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final VoidCallback onTap;

  const HoverCard({super.key, required this.title, required this.subtitle, required this.icon, required this.themeColor, required this.onTap});

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool isPressed = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool active = isHovered || isPressed;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? const Color(0xFF102C2E) : Colors.grey.shade300, width: active ? 2.0 : 1.0),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(active ? 0.1 : 0.02), blurRadius: active ? 20 : 10, offset: const Offset(0, 6))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: widget.themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(widget.icon, color: widget.themeColor, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102C2E))),
                      const SizedBox(height: 4),
                      Text(widget.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.3)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: active ? const Color(0xFF102C2E) : Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  String _vId = "";
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Village Market Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: "Phone", prefixText: "+91 ")),
            if (_otpSent) TextField(controller: _otp, decoration: const InputDecoration(labelText: "OTP")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _otpSent ? _verify : _send, child: Text(_otpSent ? "Verify" : "Get OTP")),
          ],
        ),
      ),
    );
  }

  void _send() async {
    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${_phone.text}",
      verificationCompleted: (c) {},
      verificationFailed: (e) {},
      codeSent: (vId, t) => setState(() { _vId = vId; _otpSent = true; }),
      codeAutoRetrievalTimeout: (v) {},
    );
  }

  void _verify() async {
    final cred = firebase_auth.PhoneAuthProvider.credential(verificationId: _vId, smsCode: _otp.text);
    await firebase_auth.FirebaseAuth.instance.signInWithCredential(cred);
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Form Controllers
  final _shopName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _ownerName = TextEditingController();
  final _otpController = TextEditingController();

  // Selection Data
  String? _selectedCategory;
  final List<String> _categories = ["Food", "Grocery", "Cloth", "Medicine", "Electronics", "Hardware", "Stationary", "Other"];

  // Files
  File? _shopImage;
  File? _aadharImage;

  // Status Logic
  bool _isLoading = false;
  bool _otpSent = false;
  String _vId = "";
  bool _isSuccess = false;

  // Image Picker Logic
  Future<void> _pickFile(bool isShopImage) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() => isShopImage ? _shopImage = File(picked.path) : _aadharImage = File(picked.path));
    }
  }

  // --- REGISTRATION LOGIC ---
  Future<void> _handleRegistration() async {
    if (_vId.isEmpty || _otpController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // 1. Verify OTP first
      final cred = firebase_auth.PhoneAuthProvider.credential(verificationId: _vId, smsCode: _otpController.text);
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(cred);

      // 2. Upload Images to Supabase
      String shopUrl = await _uploadToSupabase(_shopImage!, "shop_");
      String aadharUrl = await _uploadToSupabase(_aadharImage!, "aadhar_");

      // 3. Save Shop Data to 'shops' table
      await supabase.from('shops').insert({
        'shop_name': _shopName.text,
        'category': _selectedCategory,
        'address': _address.text,
        'phone': _phone.text,
        'owner_name': _ownerName.text,
        'shop_image': shopUrl,
        'aadhar_image': aadharUrl,
        'status': 'pending'
      });

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<String> _uploadToSupabase(File file, String prefix) async {
    final name = '$prefix${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabase.storage.from('registrations').upload(name, file);
    return supabase.storage.from('registrations').getPublicUrl(name);
  }

  void _sendOtp() async {
    if (_phone.text.isEmpty) return;
    setState(() => _isLoading = true);
    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${_phone.text}",
      verificationCompleted: (_) {},
      verificationFailed: (e) => setState(() => _isLoading = false),
      codeSent: (vId, _) => setState(() { _vId = vId; _otpSent = true; _isLoading = false; }),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessUI();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Shopkeeper Registration"), backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Shop Details"),
            _buildTextField(_shopName, "Shop Name", Icons.store),
            const SizedBox(height: 15),
            _buildCategoryDropdown(),
            _buildTextField(_address, "Full Shop Address", Icons.location_on, maxLines: 2),

            const SizedBox(height: 30),
            _buildSectionTitle("Owner Details"),
            _buildTextField(_ownerName, "Shopkeeper Name", Icons.person),
            _buildTextField(_phone, "Phone Number", Icons.phone, isPhone: true),

            const SizedBox(height: 30),
            _buildSectionTitle("Upload Documents"),
            _buildImagePicker("Shop Image", _shopImage, () => _pickFile(true)),
            _buildImagePicker("Aadhar Card Copy", _aadharImage, () => _pickFile(false)),

            const SizedBox(height: 40),
            if (_otpSent) _buildTextField(_otpController, "Enter 6-digit OTP", Icons.lock_clock),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _otpSent ? _handleRegistration : _sendOtp,
              child: Text(_otpSent ? "Register Shop" : "Send OTP", style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- CUSTOM UI COMPONENTS ---

  Widget _buildSuccessUI() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text("Successfully Registered!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Your shop is now listed with Village Express App.", textAlign: TextAlign.center),
            ),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Go to Home"))
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102C2E))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          labelText: label,
          prefixText: isPhone ? "+91 " : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.category, color: Colors.grey),
          labelText: "Shop Category",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() => _selectedCategory = val),
      ),
    );
  }

  Widget _buildImagePicker(String label, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: file == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_a_photo, color: Colors.grey), Text(label, style: const TextStyle(color: Colors.grey))])
            : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover)),
      ),
    );
  }
}
