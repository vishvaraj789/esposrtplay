import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final TextStyle? valueStyle;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Text(
            value,
            style: valueStyle,
          ),
        ),
        const Divider(),
      ],
    );
  }
}