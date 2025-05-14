import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuScreen extends StatelessWidget {
  final int daysLeft = 148;
  final String expirationDate = "22 октября 2021 года";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Cercle de progression
            Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/circle_background.svg',
                    width: 120,
                    height: 120,
                  ),
                  CustomPaint(
                    size: Size(120, 120),
                    painter: CircleProgressPainter(
                      progress: (daysLeft / 365) * 251.2,
                    ),
                  ),
                  Positioned(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Истекать', style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                        Text('$daysLeft', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Дни', style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            // Texte expiration
            Column(
              children: [
                Text('Вы в безопасности до тех пор, пока', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(expirationDate, style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            SizedBox(height: 40),
            // Options
            Expanded(
              child: ListView(
                children: [
                  OptionItem(
                    icon: Icons.settings_outlined,
                    title: 'Предпочтения',
                    onTap: () {},
    
                  ),
                  Divider(color: Colors.white),
                  OptionItem(
                    icon: Icons.speed,
                    title: 'Тест на скорость',
                    onTap: () {
                      Navigator.pushNamed(context, '/speedTest');
                    },
                  ),
                  Divider(color: Colors.white),
                  OptionItem(
                    icon: Icons.gif_outlined,
                    title: 'Приглашайте друзей',
                    onTap: () {},
                  ),
                  Divider(color: Colors.white),
                  OptionItem(
                    icon: Icons.help_outline,
                    title: 'Помощь и поддержка',
                    onTap: () {},
                  ),
                  SizedBox(height: 20),
                  Center(child: Text('App version 1.2.2', style: TextStyle(color: Colors.white, fontSize: 15))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  OptionItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFE76A2F), size: 32),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Caption', style: TextStyle(fontSize: 15, color: Colors.white)),
              ],
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xFFE76A2F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius - 2);
    canvas.drawArc(rect, -90 * 3.1416 / 180, progress * 3.1416 / 180, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
