import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:powebvpn/auth_pages/logged_in_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomeScreen extends StatefulWidget {
  final String googleId; 

  const HomeScreen({Key? key, required this.googleId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  // Ajoute cette variable ici
  Map<String, dynamic> userData = {
    "name": "John Doe",
    "avatarUrl": null // ou une URL d'image : "https://example.com/avatar.jpg"
  };

  bool isLoading = true;


  
  bool connected = false;
  double speed = 0.00;
  FlutterV2ray? flutterV2ray;
  V2RayURL? v2rayURL;
  String status = '';
  Timer? _timer;
  Duration duration = Duration();
  String countryName = "Неизвестный";
  String countryFlag = "https://flagcdn.com/w40/unknown.png";


  @override
  void initState() {
    super.initState();
    initV2ray();
    getUserProfile();
    
  }





  /// Récupère les informations de l'utilisateur à partir de l'API avec googleId
  Future<void> getUserProfile() async {
  //final googleId = widget.googleId;
    final uri = Uri.parse('http://192.168.1.105:8000/api/user-info/${widget.googleId}');
    try {
      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        print('❌ Erreur lors de la récupération : ${response.statusCode}');
        print('📥 Corps : ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Exception HTTP : $e');
      setState(() {
        isLoading = false;
      });
    }
}









  ///initialisation country
  Future<void> getVPNCountry() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String country = data['country'];  // Ex: "Germany"
        String countryCode = data['countryCode'].toLowerCase();  // Ex: "de"

        setState(() {
          countryName = country;
          countryFlag = "https://flagcdn.com/w40/$countryCode.png"; // Drapeau du pays
        });
      } else {
        print("Erreur API : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la récupération du pays du VPN : $e");
    }
  }





  /// Initialisation de V2Ray
  void initV2ray() async {
    flutterV2ray = FlutterV2ray(onStatusChanged: (status) {
      setState(() {
        this.status = status.state;
      });
    });

    await flutterV2ray!.initializeV2Ray();
  }

  void connect() async {
    String key = 'vless://adb80248-2df8-40ff-91ae-64e56a1ca2b6@91.108.241.166:443?type=tcp&security=reality&pbk=WgUXAECx2379Lpg34Z3oQJ2RaSy_v8wxnrIhU1nTt1k&fp=chrome&sni=cloudflare.com&sid=25d6cbd85a5bfea9&spx=%2F&flow=xtls-rprx-vision#gael';

    if (key.isEmpty) {
      _showErrorDialog("Erreur", "Veuillez insérer une clé VLESS valide.");
      return;
    }

    if (!key.startsWith("vless://")) {
      _showErrorDialog("Clé invalide", "Le format de la clé VLESS est incorrect.");
      return;
    }


    v2rayURL = FlutterV2ray.parseFromURL(key);
    if (v2rayURL == null) {
      _showErrorDialog("Clé invalide", "Impossible d'analyser la clé VLESS.");
      return;
    }

    if (await flutterV2ray!.requestPermission()) {
      flutterV2ray!.startV2Ray(
        remark: v2rayURL!.remark,
        config: v2rayURL!.getFullConfiguration(),
      );
      setState(() {
        connected = true;
        duration = Duration(); // Réinitialisation du chronomètre
      });
      startTimer();
      await Future.delayed(Duration(seconds: 2)); // Attendre que la connexion s'établisse
      await getVPNCountry(); // Récupérer le pays du VPN
    }
  }

  /// Démarrage du chronomètre
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        duration = Duration(seconds: duration.inSeconds + 1);
      });
    });
  }


  /// Déconnexion du VPN
  void disconnect() async {
    await flutterV2ray!.stopV2Ray();
    _timer?.cancel(); // Arrêter le chronomètre
    setState(() {
      connected = false;
      status = '';
      duration = Duration(); // Réinitialisation de la durée
    });
  }


  /// Formatage du temps écoulé
  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }


  /// Affichage d'une boîte de dialogue d'erreur
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _logoPoweb(),

                _userProfile(userData)

              ],
             
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconButton(Icons.grid_view, Colors.grey, () {
                  Navigator.pushNamed(context, "/menu");
                }),

                _premiumButton(),
              ],
            ),

            SizedBox(height: 24),

            // Download & Upload Speed
            _speedContainer(),

            SizedBox(height: 30),



            // Start/Stop Button
            _vpnButton(),

            SizedBox(height: 16),

            /// Statut de connexion
            Center(
              child: Column(
                children: [
                  Text(
                    connected ? "Безопасное подключение" : "Не подключен",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(formatDuration(duration),
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),

            SizedBox(height: 10),



            // Country Selection
            _countrySelector(context),
          ],
        ),
      ),
    );
  }

  

  Widget _logoPoweb() {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        child: Image.asset("assets/images/logo.png", width: 220, height: 170),
      ),
    );
  }

  Widget _userProfile(Map<String, dynamic> userData) {
  final avatarUrl = userData['avatarUrl'];
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoggedInPage(googleId: widget.googleId),
        ),
      );
    },
    child: CircleAvatar(
      radius: 30,
      backgroundImage: (userData!['avatar'] != null && userData!['avatar'].toString().isNotEmpty)
                            ? NetworkImage(userData!['avatar'])
                            : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
    ),
  );
}


  Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        // Logique de navigation ici
        Navigator.pushNamed(context, "/menu"); // Navigue vers le MenuScreen
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _premiumButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/premium");
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.star, color: Colors.white),
            SizedBox(width: 8),
            Text("Высший сорт", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _speedContainer() {
    return Container(
      height: 130,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _speedBox("Скачать", Icons.arrow_downward, speed),
          _divider(),
          _speedBox("Загружать", Icons.arrow_upward, speed),
        ],
      ),
    );
  }

  Widget _speedBox(String title, IconData icon, double speed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Container(
                  decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.rectangle),
                  padding: EdgeInsets.all(6),
                  child: Icon(icon, color: Colors.orange),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  speed.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: speed > 0.00 ? Colors.black : Colors.grey,
                  ),
                ),
                SizedBox(width: 5),
                Text("mb/s",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: speed > 0.00 ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: double.infinity, color: Colors.grey);
  }




  /// Bouton de connexion/déconnexion
  Widget _vpnButton() {
    return GestureDetector(
      onTap: connected ? disconnect : connect,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(color: connected ? Colors.orange : Colors.white, shape: BoxShape.circle),
        child: Center(child: Icon(Icons.power_settings_new, size: 32, color: connected ? Colors.white : Colors.orange)),
      ),
    );
  }

  Widget _countrySelector(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(countryFlag),
                  radius: 18,
                ),
                SizedBox(width: 8),
                Text(countryName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            ///Icon(Icons.keyboard_arrow_up, color: Colors.black),
          ],
        ),
      ),
    );
  }



}
