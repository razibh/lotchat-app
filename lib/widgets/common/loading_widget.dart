import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 40,
  }) : super(key: key);
  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...<>[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenLoading extends StatelessWidget {

  const FullScreenLoading({Key? key, this.message}) : super(key: key);
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <>[
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
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