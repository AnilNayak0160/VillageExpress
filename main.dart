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
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddProductPage())
                    );
                  },

                ),

                const SizedBox(height: 20),

               // Inside your HomeScreen
HoverCard(
  title: "I'm a Shopkeeper",
  subtitle: "Register your shop & receive\norders from customers",
  icon: Icons.storefront_outlined,
  themeColor: const Color(0xFFFF5722), 
  onTap: () {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ShopChoicePage()) // <--- GO HERE
    );
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Image Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFF5722)),
              title: const Text("Take Photo (Recommended for Emulator)"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => isShopImage ? _shopImage = File(picked.path) : _aadharImage = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFFF5722)),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => isShopImage ? _shopImage = File(picked.path) : _aadharImage = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
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

class ShopChoicePage extends StatelessWidget {
  const ShopChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF102C2E))),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 80, color: Color(0xFFFF5722)),
            const SizedBox(height: 20),
            const Text("Shopkeeper Portal", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF102C2E))),
            const SizedBox(height: 40),
            
            // --- LOGIN OPTION ---
            // Inside ShopChoicePage
_buildChoiceButton(
  context,
  title: "Login to Shop Dashboard",
  subtitle: "Manage your existing shop",
  icon: Icons.dashboard_customize,
  color: const Color(0xFF102C2E),
  onTap: () {
     // Navigate to the new Login Page
     Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopLoginPage()));
  },
),


            const SizedBox(height: 20),

            // --- REGISTER OPTION ---
            _buildChoiceButton(
              context,
              title: "Register Your Shop",
              subtitle: "Join Village Market place",
              icon: Icons.app_registration_rounded,
              color: const Color(0xFFFF5722),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class ShopLoginPage extends StatefulWidget {
  const ShopLoginPage({super.key});

  @override
  _ShopLoginPageState createState() => _ShopLoginPageState();
}

class _ShopLoginPageState extends State<ShopLoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String _vId = "";

  // 1. Validate Phone in Supabase & Send OTP
  void _checkAndSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid phone number")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if phone exists in Supabase 'shops' table
      final shop = await supabase
          .from('shops')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (shop == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This number is not registered as a Shopkeeper!")),
        );
        return;
      }

      // If exists, send Firebase OTP
      await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$phone",
        verificationCompleted: (cred) {},
        verificationFailed: (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
        },
        codeSent: (vId, token) {
          setState(() {
            _vId = vId;
            _otpSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (v) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("System Error. Try again.")));
    }
  }

  // 2. Verify OTP & Open Dashboard
  void _verifyAndLogin() async {
    setState(() => _isLoading = true);
    try {
      final cred = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _vId,
        smsCode: _otpController.text.trim(),
      );

      // Sign in to Firebase
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(cred);

      // Fetch shop data one last time to pass to Dashboard
      final shopData = await supabase
          .from('shops')
          .select()
          .eq('phone', _phoneController.text.trim())
          .single();

      setState(() => _isLoading = false);
      
      // Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ShopDashboard(shopData: shopData)),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopkeeper Login"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_person, size: 80, color: Color(0xFF102C2E)),
            const SizedBox(height: 20),
            const Text("Login to your Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !_otpSent,
              decoration: InputDecoration(
                prefixText: "+91 ",
                labelText: "Registered Phone Number",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter 6-digit OTP",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator(color: Color(0xFFFF5722))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _otpSent ? _verifyAndLogin : _checkAndSendOtp,
                  child: Text(_otpSent ? "Verify & Login" : "Send OTP", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
          ],
        ),
      ),
    );
  }
}
class ShopDashboard extends StatelessWidget {
  final Map<String, dynamic> shopData;
  const ShopDashboard({super.key, required this.shopData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(shopData['shop_name'] ?? "My Shop"),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              firebase_auth.FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const VillageExpressApp()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- SHOP PROFILE HEADER ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5722),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30), 
                bottomRight: Radius.circular(30)
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(shopData['shop_image'] ?? ''),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopData['owner_name'] ?? 'Owner', 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        shopData['address'] ?? 'Address', 
                        style: const TextStyle(color: Colors.white70, fontSize: 13)
                      ),
                      Text(
                        "Phone: ${shopData['phone']}", 
                        style: const TextStyle(color: Colors.white, fontSize: 12)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- TOOLS GRID ---
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
               // Inside ShopDashboard, find the _buildTool for "Add Product"
_buildTool(context, "Add Product", Icons.add_box, Colors.green, () {
  Navigator.push(
    context, 
    MaterialPageRoute(builder: (_) => AddShopProductPage(shopId: shopData['id']))
  );
}),
                _buildTool(context, "View Products", Icons.inventory_2_outlined, Colors.blue),
                _buildTool(context, "Orders", Icons.notifications_active_outlined, Colors.orange),
                _buildTool(context, "Delete Items", Icons.delete_sweep_outlined, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
// Update this function at the bottom of ShopDashboard
Widget _buildTool(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap, // Now it correctly uses the 5th argument
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    ),
  );
}


class AddShopProductPage extends StatefulWidget {
  final dynamic shopId;
  const AddShopProductPage({super.key, required this.shopId});

  @override
  _AddShopProductPageState createState() => _AddShopProductPageState();
}

class _AddShopProductPageState extends State<AddShopProductPage> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _unit = TextEditingController();
  File? _img;
  bool _loading = false;

  Future<void> _pick() async {
    final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
    if (p != null) setState(() => _img = File(p.path));
  }

  Future<void> _upload() async {
    if (_img == null || _name.text.isEmpty || _price.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      // 1. Upload to registrations bucket (or create a 'products' bucket)
      final fileName = 'item_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('registrations').upload(fileName, _img!);
      final url = supabase.storage.from('registrations').getPublicUrl(fileName);

      // 2. Save to shop_products table
      await supabase.from('shop_products').insert({
        'shop_id': widget.shopId,
        'product_name': _name.text,
        'price': double.parse(_price.text),
        'unit': _unit.text,
        'product_image': url,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product added!")));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Item"), backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          GestureDetector(
            onTap: _pick,
            child: Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
              child: _img == null ? const Icon(Icons.add_a_photo, size: 40) : Image.file(_img!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          TextField(controller: _name, decoration: const InputDecoration(labelText: "Product Name (e.g. Rice)")),
          TextField(controller: _price, decoration: const InputDecoration(labelText: "Price (₹)"), keyboardType: TextInputType.number),
          TextField(controller: _unit, decoration: const InputDecoration(labelText: "Unit (e.g. 1kg, 500g, 1 Packet)")),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), minimumSize: const Size(double.infinity, 50)),
            onPressed: _upload,
            child: const Text("Add to Shop", style: TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}


