import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {

  const AppLoader({
    Key? key,
    this.size = 40,
    this.color,
    this.message,
  }) : super(key: key);
  final double size;
  final Color? color;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...<>[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {

  const FullScreenLoader({Key? key, this.message}) : super(key: key);
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              const CircularProgressIndicator(),
              if (message != null) ...<>[
                const SizedBox(height: 16),
                Text(message!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}