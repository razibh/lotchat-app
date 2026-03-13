import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';

class WebViewScreen extends StatefulWidget {

  const WebViewScreen({
    Key? key,
    required this.title,
    required this.url,
    this.showAppBar = true,
  }) : super(key: key);
  final String title;
  final String url;
  final bool showAppBar;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _refreshPage() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.reload();
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              if (widget.showAppBar) _buildAppBar(),
              Expanded(
                child: Stack(
                  children: <>[
                    WebViewWidget(controller: _controller),
                    if (_isLoading && _progress < 1.0)
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPurple),
                      ),
                    if (_hasError)
                      _buildErrorWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPage,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load page',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.url,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshPage,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Additional helper class for webview with different configurations
class WebViewScreenBuilder {
  static Widget privacyPolicy() {
    return const WebViewScreen(
      title: 'Privacy Policy',
      url: 'https://example.com/privacy',
    );
  }

  static Widget termsOfService() {
    return const WebViewScreen(
      title: 'Terms of Service',
      url: 'https://example.com/terms',
    );
  }

  static Widget aboutUs() {
    return const WebViewScreen(
      title: 'About Us',
      url: 'https://example.com/about',
    );
  }

  static Widget faq() {
    return const WebViewScreen(
      title: 'FAQ',
      url: 'https://example.com/faq',
    );
  }

  static Widget support() {
    return const WebViewScreen(
      title: 'Support',
      url: 'https://example.com/support',
    );
  }
}