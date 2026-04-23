import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:pos_nimirik/core/i18n/i18n.dart';

class PosWebViewPage extends StatefulWidget {
  const PosWebViewPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<PosWebViewPage> createState() => _PosWebViewPageState();
}

class _PosWebViewPageState extends State<PosWebViewPage> {
  WebViewController? _controller;
  bool _loading = true;

  bool get _supportsInAppWebView {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    if (_supportsInAppWebView) {
      final ctrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (!mounted) return;
              setState(() => _loading = true);
            },
            onPageFinished: (_) {
              if (!mounted) return;
              setState(() => _loading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
      _controller = ctrl;
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : tr('WebView');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: tr('Ouvrir externe'),
            onPressed: _openExternal,
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: _supportsInAppWebView
          ? Stack(
              children: [
                if (_controller != null)
                  WebViewWidget(controller: _controller!),
                if (_loading) const LinearProgressIndicator(minHeight: 2),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.public, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      tr('WebView non supportée sur cette plateforme.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _openExternal,
                      icon: const Icon(Icons.open_in_new),
                      label: Text(tr('Ouvrir dans le navigateur')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
