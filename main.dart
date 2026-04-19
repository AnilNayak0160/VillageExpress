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
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerPortalPage()),
                      );
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


class CustomerRegistrationPage extends StatefulWidget {
  const CustomerRegistrationPage({super.key});

  @override
  _CustomerRegistrationPageState createState() => _CustomerRegistrationPageState();
}

class _CustomerRegistrationPageState extends State<CustomerRegistrationPage> {
  // --- CONTROLLERS ---
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _otpController = TextEditingController();

  // --- STATE VARIABLES ---
  bool _isSent = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _vId = "";
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Orange Header Background
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5722),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          SafeArea(
            child: _isSuccess ? _buildSuccessView() : _buildRegistrationForm(),
          ),
        ],
      ),
    );
  }

  // --- VIEW: REGISTRATION FORM ---
  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const Text(
            "Customer Registration",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Create your account to start shopping",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 30),

          // Details Card
          _buildFormCard(
            title: "Contact Information",
            children: [
              _buildTextField(_nameController, "Full Name", Icons.person_rounded),
              const SizedBox(height: 15),
              _buildTextField(_phoneController, "Phone Number", Icons.phone_android_rounded, prefix: "+91 "),
              const SizedBox(height: 15),
              _buildTextField(_addressController, "Full Address", Icons.location_on_rounded, maxLines: 2),
            ],
          ),

          // OTP Card (Shows only after SMS is sent)
          if (_isSent) ...[
            const SizedBox(height: 20),
            _buildFormCard(
              title: "Security Verification",
              children: [
                _buildTextField(_otpController, "Enter 6-digit OTP", Icons.lock_outline_rounded, isNumber: true),
              ],
            ),
          ],

          const SizedBox(height: 30),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_isSent ? _verifyAndRegister : _sendOtp),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                _isSent ? "VERIFY & REGISTER" : "SEND OTP",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // --- VIEW: SUCCESS MESSAGE ---
  Widget _buildSuccessView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 100),
            const SizedBox(height: 25),
            const Text(
              "Registration Successful!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF102C2E)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your profile has been created. You can now log in to the portal.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722), // 👈 Original Orange Color
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: const Text(
                    "BACK TO LOGIN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- LOGIC: FIREBASE & SUPABASE ---

  void _sendOtp() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91${_phoneController.text}",
        codeSent: (id, t) => setState(() {
          _vId = id;
          _isSent = true;
          _isLoading = false;
        }),
        verificationCompleted: (c) {},
        verificationFailed: (e) {
          setState(() => _isLoading = false);
          _showError(e.message ?? "Verification Failed");
        },
        codeAutoRetrievalTimeout: (s) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("An unexpected error occurred.");
    }
  }

  void _verifyAndRegister() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      // 1. Verify OTP with Firebase
      final cred = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _vId,
        smsCode: _otpController.text,
      );
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(cred);

      // 2. Save Data to Supabase
      await _supabase.from('customers').insert({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      });

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Invalid OTP or Database error. Please try again.");
    }
  }

  // --- UI COMPONENTS ---

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

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, String? prefix, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: (prefix != null || isNumber) ? TextInputType.number : TextInputType.text,
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}


class CustomerPortalPage extends StatelessWidget {
  const CustomerPortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView( // 👈 Added to allow scrolling
        child: Column( // 👈 Changed from Stack to Column
          children: [
            // Orange Gradient Header
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Customer Portal",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Order fresh items from your local market",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Portal Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // 👈 Adjusted padding
              child: Column(
                children: [
                  _buildPortalCard(
                    title: "Shop Now",
                    subtitle: "Browse products and place orders",
                    buttonText: "LOGIN NOW",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerLoginPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildPortalCard(
                    title: "Join as Member",
                    subtitle: "Create an account for faster checkout",
                    buttonText: "START REGISTRATION",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CustomerRegistrationPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 40), // 👈 Replaced Spacer with fixed height

                  // Back Button
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 18, color: Colors.grey),
                    label: const Text("Back to Role Selection", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF5722).withOpacity(0.8), const Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF5722).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}



class CustomerLoginPage extends StatefulWidget {
  const CustomerLoginPage({super.key});

  @override
  _CustomerLoginPageState createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends State<CustomerLoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String _verificationId = "";
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Orange Header
          Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Customer Login",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your registered number to continue",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Login Form Card
          Padding(
            padding: const EdgeInsets.only(top: 240),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Phone Input
                    _buildInputContainer(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_isOtpSent,
                        decoration: const InputDecoration(
                          hintText: "Phone Number",
                          prefixText: "+91 ",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    if (_isOtpSent) ...[
                      const SizedBox(height: 20),
                      _buildInputContainer(
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Enter 6-digit OTP",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _checkAndSendOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          _isOtpSent ? "LOGIN" : "GET OTP",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC ---

  Future<void> _checkAndSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) return;

    setState(() => _isLoading = true);

    try {
      // 1. Check if customer exists in Supabase
      final data = await _supabase.from('customers').select().eq('phone', phone).maybeSingle();

      if (data == null) {
        _showError("Number not registered. Please sign up first.");
        setState(() => _isLoading = false);
        return;
      }

      // 2. Trigger Firebase OTP
      await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$phone",
        codeSent: (id, t) => setState(() {
          _verificationId = id;
          _isOtpSent = true;
          _isLoading = false;
        }),
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          setState(() => _isLoading = false);
          _showError(e.message ?? "Verification failed");
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Something went wrong");
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    try {
      final cred = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );

      // 1. Sign in to Firebase
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(cred);

      // 2. Navigate to Dashboard and remove Login from history
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CustomerDashboard()),
              (route) => false, // This clears the navigation stack
        );
      }
    } catch (e) {
      _showError("Invalid OTP. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // --- UI HELPERS ---

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}




class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final _supabase = Supabase.instance.client;

  // Logic Variables
  Map<String, dynamic>? _userData;
  List<dynamic> _shops = [];
  bool _isLoading = true;
  String _selectedCategory = "Grocery";

  // Category Data matching the image you sent
  final List<Map<String, dynamic>> _categories = [
    {"name": "Food", "icon": Icons.restaurant_rounded, "color": Color(0xFFFFF3E0)},
    {"name": "Grocery", "icon": Icons.shopping_cart_rounded, "color": Color(0xFFE8F5E9)},
    {"name": "Dress", "icon": Icons.checkroom_rounded, "color": Color(0xFFF3E5F5)},
    {"name": "Medicine", "icon": Icons.medical_services_rounded, "color": Color(0xFFFFEBEE)},
    {"name": "Electronics", "icon": Icons.devices_rounded, "color": Color(0xFFE3F2FD)},
    {"name": "Hardware", "icon": Icons.build_rounded, "color": Color(0xFFFFFDE7)},
    {"name": "Stationary", "icon": Icons.edit_note_rounded, "color": Color(0xFFF1F8E9)},
    {"name": "Other", "icon": Icons.grid_view_rounded, "color": Color(0xFFECEFF1)},
  ];

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  // Combine both fetches into one initialization
  Future<void> _initDashboard() async {
    await _fetchUserData();
    await _fetchShops(_selectedCategory);
  }


// 2. Update the function
  Future<void> _fetchUserData() async {
    // 👈 Use Firebase Auth instead of Supabase Auth to get the current user
    final fbUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (fbUser != null && fbUser.phoneNumber != null) {
      String fullPhone = fbUser.phoneNumber!; // e.g. +919692421929

      // Extract last 10 digits to match your Supabase table '9692421929'
      String shortPhone = fullPhone.substring(fullPhone.length - 10);

      print("DEBUG: Searching Supabase 'customers' table for: $shortPhone");

      try {
        final response = await _supabase
            .from('customers')
            .select()
            .eq('phone', shortPhone)
            .maybeSingle();

        if (mounted) {
          setState(() {
            // If response is found, this will change 'Searching...' to the Name
            _userData = response;
          });

          if (response == null) {
            print("DEBUG: No record found in Supabase for $shortPhone");
            // Fallback so it doesn't stay on 'Searching...' forever
            setState(() => _userData = {'name': 'Guest User'});
          }
        }
      } catch (e) {
        print("DEBUG: Supabase Error: $e");
        setState(() => _userData = {'name': 'Error Loading'});
      }
    } else {
      print("DEBUG: No Firebase user session found.");
      setState(() => _userData = {'name': 'Login Required'});
    }
  }




  Future<void> _fetchShops(String category) async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('shops')
          .select()
          .eq('category', category)
          .eq('status', 'approved');
      if (mounted) {
        setState(() {
          _shops = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              const SizedBox(height: 25),
              _buildSearchBar(),
              const SizedBox(height: 25),
              _buildServiceActions(),
              const SizedBox(height: 30),
              _buildSectionHeader("Shop by Category"),
              const SizedBox(height: 20),
              _buildCategoryGrid(),
              const SizedBox(height: 30),
              _buildSectionHeader("Shops in $_selectedCategory"),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                  : _buildShopList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text(
              "${_userData?['name'] ?? 'Anil Kumar Nayak'} 👋",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102C2E)),
            ),
          ],
        ),
        // --- MODERN LOGOUT BUTTON ---
        InkWell(
          onTap: () => _handleLogout(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFF5722).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFFF5722).withOpacity(0.05),
            ),
            child: Row(
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFFFF5722), size: 18),
                SizedBox(width: 5),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Color(0xFFFF5722),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


// --- Logout Logic ---
  Future<void> _handleLogout(BuildContext context) async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerPortalPage()),
            (route) => false,
      );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(15)),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search shops, products...",
          icon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildServiceActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem("Book a Ride", Icons.directions_car_rounded, const Color(0xFFE3F2FD), Colors.blue),
        _actionItem("Home Service", Icons.build_circle_rounded, const Color(0xFFFFFDE7), Colors.orange),
        _actionItem("My Orders", Icons.shopping_bag_rounded, const Color(0xFFF3E5F5), Colors.purple),
      ],
    );
  }

  Widget _actionItem(String label, IconData icon, Color bg, Color iconColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF102C2E))),
        const Text("See All →", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 0.8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        bool isSelected = _selectedCategory == cat['name'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedCategory = cat['name']);
            _fetchShops(cat['name']);
          },
          child: Column(
            children: [
              Container(
                height: 65, width: 65,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF5722) : cat['color'],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(cat['icon'], color: isSelected ? Colors.white : const Color(0xFFFF5722), size: 30),
              ),
              const SizedBox(height: 8),
              Text(cat['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopList() {
    if (_shops.isEmpty) return const Center(child: Text("No shops found in this category"));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _shops.length,
      itemBuilder: (context, index) {
        final shop = _shops[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  shop['shop_image'] ?? '',
                  height: 140, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 140, color: Colors.grey[200], child: const Icon(Icons.store)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shop['shop_name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(shop['address'], style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
