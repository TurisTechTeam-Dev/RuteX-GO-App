import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

class AdminFooter extends StatelessWidget {
  const AdminFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.blancoPuro,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.email_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Correo electronico: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text('turistechteam@gmail.com', style: TextStyle(fontSize: 12)),
            ],
          ),
          Text(
            'PANEL ADMINISTRADOR',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.2,
              color: Color(0xFF6B7249),
            ),
          ),
          Row(
            children: [
              Icon(Icons.code, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'GitHub: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                'TurisTechTeam-Dev/RuteX-Go-App',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
