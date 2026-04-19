import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io'; // Fixes 'File' error
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
        primarySwatch: Colors.deepOrange,
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
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
        }

        // --- THE CHANGE IS HERE ---
        // Even if the user is NOT logged in, show the Home Screen (Role Selection).
        // The individual pages (like Shop Dashboard) will ask for login if needed.
        return const HomeScreen();
      },
    );
  }
}


// --- HOME SCREEN (ROLE SELECTION - YOUR ORIGINAL DESIGN) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color primaryOrange = Color(0xFFFF5722);
    const Color lightOrange = Color(0xFFFF9100);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // --- BRANDED ORANGE HEADER ---
          Container(
            width: double.infinity,
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, lightOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -30, right: -30,
                  child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Logo Container
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                        ),
                        child: Image.asset('assets/images/village.png', height: 70,
                            errorBuilder: (c,e,s) => const Icon(Icons.home_work, size: 65, color: primaryOrange)),
                      ),
                      const SizedBox(height: 20),
                      const Text("Village Market",
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const Text("Your community, digitally connected",
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- ROLE SELECTION ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                  const Text("How would you like to proceed?", style: TextStyle(color: Colors.grey, fontSize: 15)),
                  const SizedBox(height: 30),

                  // CUSTOMER CARD
                  _buildModernRoleCard(
                    context,
                    title: "I'm a Customer",
                    subtitle: "Order fresh items from local shops",
                    icon: Icons.shopping_basket_rounded,
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerScreen()));
                    },
                  ),

                  const SizedBox(height: 20),

                  // SHOPKEEPER CARD
                  _buildModernRoleCard(
                    context,
                    title: "I'm a Shopkeeper",
                    subtitle: "Manage your shop and receive orders",
                    icon: Icons.storefront_rounded,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopChoicePage()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernRoleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF5722), Color(0xFFFF9100)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.2)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}


class ShopChoicePage extends StatelessWidget {
  const ShopChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining our primary orange colors for consistency
    const Color primaryOrange = Color(0xFFFF5722);
    const Color lightOrange = Color(0xFFFF9100);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // --- UNIFIED ORANGE HEADER ---
          Container(
            width: double.infinity,
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, lightOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Glowing Shop Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.storefront_rounded, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text("Shopkeeper Portal",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const Text("Grow your village business digitally",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          // --- OPTIONS SECTION ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // LOGIN CARD (Now Orange)
                  _buildProChoiceCard(
                    context,
                    title: "Shop Dashboard",
                    subtitle: "Manage inventory, orders & profile",
                    actionText: "LOGIN NOW",
                    icon: Icons.dashboard_rounded,
                    gradient: [primaryOrange.withOpacity(0.85), lightOrange.withOpacity(0.9)],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopLoginPage())),
                  ),

                  const SizedBox(height: 20),

                  // REGISTER CARD (Orange)
                  _buildProChoiceCard(
                    context,
                    title: "Register New Shop",
                    subtitle: "Join the Village Market family today",
                    actionText: "START REGISTRATION",
                    icon: Icons.add_business_rounded,
                    gradient: const [primaryOrange, lightOrange],
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductPage())),
                  ),

                  const Spacer(),
                  // Subtle back button
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                    label: const Text("Back to Role Selection", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProChoiceCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String actionText,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20, top: -20,
              child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(actionText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Icon(icon, color: Colors.white.withOpacity(0.2), size: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// --- SHOP DASHBOARD (YOUR DESIGN + LIVE DATA) ---
class ShopDashboard extends StatelessWidget {
  final Map<String, dynamic> shopData;
  const ShopDashboard({super.key, required this.shopData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(shopData['shop_name'] ?? ""),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // --- NEW LOGOUT BUTTON ---
          TextButton.icon(
            onPressed: () async {
              // 1. Sign out from Firebase
              await firebase_auth.FirebaseAuth.instance.signOut();

              // 2. Go back to the very first screen (Home/AuthWrapper)
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthWrapper()),
                      (route) => false, // This clears all previous screens from memory
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            label: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF5722),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(shopData['shop_image'] ?? '')
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shopData['owner_name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(shopData['address'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text("Phone: ${shopData['phone']}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildTool(context, "Add Product", Icons.add_business_rounded, Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AddShopProductPage(shopId: shopData['id'])));
                }),
                // Inside ShopDashboard GridView
                _buildTool(context, "View Products", Icons.inventory_2_outlined, Colors.blue, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewProductsPage(shopId: shopData['id']))
                  );
                }),

                _buildTool(context, "Orders", Icons.notifications_active_outlined, Colors.orange, () {}),
                _buildTool(context, "Delete Items", Icons.delete_sweep_outlined, Colors.red, () {}),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTool(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ),
    );
  }
}

// --- ADD SHOP PRODUCT PAGE ---
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Item"), backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          GestureDetector(
            // Inside AddShopProductPage -> Column -> GestureDetector
            onTap: () async {
              final ImagePicker picker = ImagePicker();

              // Show a menu to choose between Camera or Gallery
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text("Choose from Gallery"),
                      onTap: () async {
                        Navigator.pop(context);
                        final p = await picker.pickImage(source: ImageSource.gallery);
                        if (p != null) setState(() => _img = File(p.path));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text("Take a Photo"),
                      onTap: () async {
                        Navigator.pop(context);
                        final p = await picker.pickImage(source: ImageSource.camera);
                        if (p != null) setState(() => _img = File(p.path));
                      },
                    ),
                  ],
                ),
              );
            },

            child: Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
              child: _img == null ? const Icon(Icons.add_a_photo, size: 40) : Image.file(_img!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          TextField(controller: _name, decoration: const InputDecoration(labelText: "Product Name")),
          TextField(controller: _price, decoration: const InputDecoration(labelText: "Price (₹)"), keyboardType: TextInputType.number),
          TextField(controller: _unit, decoration: const InputDecoration(labelText: "Unit (e.g. 1kg, 1pc)")),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), minimumSize: const Size(double.infinity, 50)),
            onPressed: _save,
            child: const Text("Add to Shop", style: TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }

  void _save() async {
    if (_img == null || _name.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final fileName = 'p_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('registrations').upload(fileName, _img!);
      final url = supabase.storage.from('registrations').getPublicUrl(fileName);

      await supabase.from('shop_products').insert({
        'shop_id': widget.shopId,
        'product_name': _name.text,
        'price': double.parse(_price.text),
        'unit': _unit.text,
        'product_image': url
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
class ShopLoginPage extends StatefulWidget {
  const ShopLoginPage({super.key});
  @override
  _ShopLoginPageState createState() => _ShopLoginPageState();
}

class _ShopLoginPageState extends State<ShopLoginPage> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  String _vId = "";
  bool _sent = false;
  bool _loading = false;

  void _send() async {
    final phone = _phone.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit number")),
      );
      return;
    }
    setState(() => _loading = true);

    final shop = await supabase.from('shops').select().eq('phone', phone).maybeSingle();
    if (shop == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This number is not registered as a shop!")));
      return;
    }

    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91$phone",
      codeSent: (id, t) => setState(() { _vId = id; _sent = true; _loading = false; }),
      verificationCompleted: (c) {},
      verificationFailed: (e) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
      },
      codeAutoRetrievalTimeout: (s) {},
    );
  }

  void _verify() async {
    setState(() => _loading = true);
    try {
      final cred = firebase_auth.PhoneAuthProvider.credential(verificationId: _vId, smsCode: _otp.text);
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(cred);
      final shopData = await supabase.from('shops').select().eq('phone', _phone.text).single();

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ShopDashboard(shopData: shopData)));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP, please try again")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFFFF5722), Color(0xFFFF9100)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text("Shopkeeper Login",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Enter your registered number to continue",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              enabled: !_sent,
                              decoration: const InputDecoration(
                                hintText: "Phone Number",
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixText: "+91 ",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                            if (_sent) ...[
                              const Divider(height: 1, indent: 20, endIndent: 20),
                              TextField(
                                controller: _otp,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Enter 6-digit OTP",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(20),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _loading
                          ? const CircularProgressIndicator(color: Color(0xFFFF5722))
                          : MaterialButton(
                        onPressed: _sent ? _verify : _send,
                        height: 55,
                        minWidth: double.infinity,
                        color: const Color(0xFFFF5722),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          _sent ? "LOGIN TO DASHBOARD" : "GET OTP",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_sent)
                        TextButton(
                          onPressed: () => setState(() => _sent = false),
                          child: const Text("Edit Phone Number", style: TextStyle(color: Colors.grey)),
                        ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- HOVER CARD WIDGET ---
class HoverCard extends StatefulWidget {
  final String title; final String subtitle; final IconData icon; final Color themeColor; final VoidCallback onTap;
  const HoverCard({super.key, required this.title, required this.subtitle, required this.icon, required this.themeColor, required this.onTap});
  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool active = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => active = true),
      onTapUp: (_) => setState(() => active = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: active ? Colors.black : Colors.grey.shade300, width: active ? 2 : 1)
        ),
        child: Row(children: [
          Icon(widget.icon, color: widget.themeColor),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13))
          ])),
        ]),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _shopName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _ownerName = TextEditingController();
  String? _selectedCategory;
  File? _shopImg;
  File? _aadharImg;
  bool _isLoading = false;

  final List<String> _categories = ["Food", "Grocery", "Cloth", "Medicine", "Electronics", "Hardware", "Stationary", "Other"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Register Your Shop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Header Gradient
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5722),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
            ),
          ),

          // Form Content
          SafeArea(
            child: SingleChildScrollView( // ✅ FIXED: Prevents yellow overflow/white screen
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildFormCard(
                    title: "Store Information",
                    children: [
                      _buildTextField(_shopName, "Shop Name", Icons.store_rounded),
                      const SizedBox(height: 15),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 15),
                      _buildTextField(_address, "Full Address", Icons.location_on_rounded, maxLines: 2),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFormCard(
                    title: "Owner Details",
                    children: [
                      _buildTextField(_ownerName, "Owner Name", Icons.person_rounded),
                      const SizedBox(height: 15),
                      _buildTextField(_phone, "Phone Number", Icons.phone_android_rounded, prefix: "+91 "),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFormCard(
                    title: "Verification Documents",
                    children: [
                      _buildImagePicker("Shop Image", _shopImg, (f) => setState(() => _shopImg = f)),
                      const SizedBox(height: 15),
                      _buildImagePicker("Aadhar Card Copy", _aadharImg, (f) => setState(() => _aadharImg = f)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Professional Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => print("Send OTP Clicked"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5722),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("SEND OTP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN UI COMPONENTS ---

  Widget _buildFormCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF102C2E))),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, String? prefix}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: const Color(0xFFFF5722), size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: "Select Category",
        prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFFFF5722), size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
    );
  }

  Widget _buildImagePicker(String label, File? file, Function(File) onPick) {
    return GestureDetector(
      onTap: () async {
        final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
        if (p != null) onPick(File(p.path));
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: file == null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.cloud_upload_outlined, color: Colors.grey), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))])
            : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover)),
      ),
    );
  }
}


// --- PHONE AUTH PAGE ---
class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _sent = false; String _vId = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextField(controller: _phone, decoration: const InputDecoration(labelText: "Login Phone")),
        if (_sent) TextField(controller: _otp, decoration: const InputDecoration(labelText: "OTP")),
        ElevatedButton(onPressed: _sent ? _verify : _send, child: Text(_sent ? "Verify" : "Get OTP"))
      ])),
    );
  }
  void _send() async {
    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${_phone.text}",
      codeSent: (id, t) => setState(() { _vId = id; _sent = true; }),
      verificationCompleted: (c) {}, verificationFailed: (e) {}, codeAutoRetrievalTimeout: (s) {},
    );
  }
  void _verify() async {
    final cred = firebase_auth.PhoneAuthProvider.credential(verificationId: _vId, smsCode: _otp.text);
    await firebase_auth.FirebaseAuth.instance.signInWithCredential(cred);
  }
}


class ViewProductsPage extends StatelessWidget {
  final dynamic shopId;
  const ViewProductsPage({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Products"),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Fetch only products belonging to THIS shop
        stream: supabase.from('shop_products').stream(primaryKey: ['id']).eq('shop_id', shopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products added yet."));
          }

          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(context, product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Action Buttons
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    product['product_image'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5, right: 5,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, product),
                    ),
                  ),
                ),
                Positioned(
                  top: 5, left: 5,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      onPressed: () => _confirmDelete(context, product['id']),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['product_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("₹${product['price']} / ${product['unit']}", style: const TextStyle(color: Colors.deepOrange)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- EDIT LOGIC ---
  void _showEditDialog(BuildContext context, Map<String, dynamic> product) {
    final nameCtrl = TextEditingController(text: product['product_name']);
    final priceCtrl = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await supabase.from('shop_products').update({
                'product_name': nameCtrl.text,
                'price': double.parse(priceCtrl.text),
              }).eq('id', product['id']);
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // --- DELETE LOGIC ---
  void _confirmDelete(BuildContext context, dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await supabase.from('shop_products').delete().eq('id', id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
