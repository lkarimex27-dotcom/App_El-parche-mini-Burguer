import 'package:flutter/material.dart';

class DomiciliarioCard extends StatelessWidget {
  final Widget child;
  final Color? borde;

  const DomiciliarioCard({super.key, required this.child, this.borde});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: borde == null ? null : Border.all(color: borde!, width: 1.4),
      ),
      child: child,
    );
  }
}
