import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  final Color? color;
  final double? size;
  final Duration timeout;
  final VoidCallback? onTimeout;
  final Widget? timeoutWidget;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size,
    this.timeout = const Duration(seconds: 30),
    this.onTimeout,
    this.timeoutWidget,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    _setupTimeout();
  }

  void _setupTimeout() {
    Future.delayed(widget.timeout, () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
        });

        if (widget.onTimeout != null) {
          widget.onTimeout!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasTimedOut && widget.timeoutWidget != null) {
      return widget.timeoutWidget!;
    }

    return Center(
      child:
          // Container(
          //   width: 140,
          //   height: 140,
          //   clipBehavior: Clip.antiAlias,
          //   decoration: ShapeDecoration(
          //     color: Colors.white.withValues(alpha: 204),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(32),
          //     ),
          //   ),
          //   child: Stack(
          //     children: [
          //       Positioned(
          //         left: 38,
          //         top: 38,
          //         child: Container(
          //           width: 64,
          //           height: 64,
          //           decoration: ShapeDecoration(
          //             shape: OvalBorder(
          //               side: BorderSide(
          //                 width: 10,
          //                 strokeAlign: BorderSide.strokeAlignCenter,
          //                 color: Colors.blue,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CupertinoActivityIndicator(
          color: widget.color ?? Colors.blueAccent,
          radius: widget.size ?? 24.0,
        ),
      ),
    );
  }
}
