import 'package:flutter/material.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';

class AnimatedPriceText extends StatefulWidget {
  final double begin;
  final double end;
  final TextStyle style;

  const AnimatedPriceText({super.key, required this.begin, required this.end, required this.style});

  @override
  State<AnimatedPriceText> createState() => _AnimatedPriceTextState();
}

class _AnimatedPriceTextState extends State<AnimatedPriceText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween<double>(begin: widget.begin, end: widget.end).animate(CurvedAnimation(
      parent: _controller, curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPriceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _animation = Tween<double>(begin: oldWidget.end, end: widget.end).animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Text(CurrencyFormatter.formatVND(_animation.value), style: widget.style),
    );
  }
}

class OrderNoteField extends StatefulWidget {
  final Function(String) onChanged;
  final String initialValue;
  const OrderNoteField({super.key, required this.onChanged, this.initialValue = ""});

  @override
  State<OrderNoteField> createState() => _OrderNoteFieldState();
}

class _OrderNoteFieldState extends State<OrderNoteField> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        icon: Icon(Icons.note_alt_outlined, size: 18, color: Colors.grey),
        hintText: "Ghi chú cho shipper...",
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }
}
