import 'package:flutter/material.dart';
import '../grade.dart';
import '../grade_detail.dart';
import '../../core/widgets/circular_progress_bar.dart';

class GradeCircle extends StatefulWidget {
  final Grade grade;
  final Grade? previousGrade;
  final double size;
  final double fontSize;
  final int animationMs;
  final VoidCallback? onTap;
  final bool showDetailOnTap;

  const GradeCircle({
    super.key,
    required this.grade,
    this.previousGrade,
    this.size = 100,
    this.fontSize = 20,
    required this.animationMs,
    this.onTap,
    this.showDetailOnTap = false,
  });

  @override
  State<GradeCircle> createState() => _GradeCircleState();
}

class _GradeCircleState extends State<GradeCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationMs),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.grade.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Wait for the page transition to finish before starting
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant GradeCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.grade.value != widget.grade.value) {
      _animation = Tween<double>(
        begin: oldWidget.grade.value,
        end: widget.grade.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getGradeColor(double value) {
    if (value >= 6) return Colors.green;
    if (value >= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ??
          (widget.showDetailOnTap
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GradeDetail(
                        grade: widget.grade,
                        previousGrade: widget.previousGrade,
                        animationMs: widget.animationMs,
                      ),
                    ),
                  );
                }
              : null),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CircularProgressBar(
            currentValue: _animation.value,
            maxValue: 10,
            size: widget.size,
            strokeWidth: widget.size / 10,
            color: _getGradeColor(widget.grade.value),
            child: Center(
              child: Text(
                widget.grade.displayValue,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
