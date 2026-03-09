import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF74B3CE), Color(0xFF4895D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF4895D0).withAlpha(77), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: const Row(
        children: [
          Text('☀️', style: TextStyle(fontSize: 48)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이번 주 토요일', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('등산하기 딱 좋은 날씨!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('맑음 · 12°C · 바람 약함', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
