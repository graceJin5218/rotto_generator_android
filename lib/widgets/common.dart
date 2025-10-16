import 'package:flutter/material.dart';
import '../theme.dart';

class LottoNumberChip extends StatelessWidget {
  final int number;
  final bool highlight;
  final double radius;
  const LottoNumberChip(this.number, {super.key, this.highlight = false, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: radius * 2, height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlight ? kAccentColor : Colors.grey[200],
        shape: BoxShape.circle,
        border: Border.all(color: highlight ? kAccentColor : Colors.grey[300]!),
      ),
      child: Text(
        number.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius,
          color: kMainColor,
        ),
      ),
    );
  }
}

class LottoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const LottoCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class LottoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  const LottoButton(this.text, {super.key, this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: color != null
            ? ElevatedButton.styleFrom(backgroundColor: color)
            : null,
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}
