import 'package:flutter/material.dart';

class ExplorerListView extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final Function(dynamic) onItemTap;
  final bool esNivelFinal;

  const ExplorerListView({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
    this.esNivelFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B7249),
          ),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          const Expanded(
            child: Center(child: Text("No hay elementos registrados aquí.")),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              itemBuilder: (context, i) => Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    esNivelFinal ? Icons.location_on : Icons.folder_open,
                    color: const Color(0xFF6B7249),
                  ),
                  title: Text(
                    items[i].name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: esNivelFinal
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: () => onItemTap(items[i]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
