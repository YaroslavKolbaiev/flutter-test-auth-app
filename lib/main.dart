import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Debug: Print loaded environment variables
  print('Loaded WEBVIEW_URL: ${dotenv.env['WEBVIEW_URL']}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController? _controller;
  String? _loggedInUserId;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeController();
    }
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar if needed
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // Inject JavaScript interface for mobile
            _controller?.runJavaScript('''
              window.flutter_inappwebview = {
                callHandler: function(handlerName, data) {
                  if (handlerName === 'authCallback') {
                    authCallback.postMessage(JSON.stringify(data));
                  }
                }
              };
            ''');
          },          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            print('Error code: ${error.errorCode}');
            print('Error type: ${error.errorType}');

            // Show user-friendly error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load webpage: ${error.description}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          },
        ),
      )
      ..addJavaScriptChannel(
        'authCallback',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final authData = jsonDecode(message.message);
            _handleAuthCallback(Map<String, dynamic>.from(authData));
          } catch (e) {
            print('Error parsing auth callback: $e');
          }
        },
      );
  }

  void _handleAuthCallback(Map<String, dynamic> authData) {
    try {
      print('Received auth data: $authData');

      if (authData['type'] == 'AUTH_SUCCESS') {
        final data = authData['data'];
        final authToken = data['auth_token']?.toString();
        final userId = data['user_id']?.toString();
        final availableDomain = data['available_domain']?.toString();
        final disableLogout = data['disable_logout'];

        // Close the WebView by navigating back to home
        Navigator.of(context).popUntil((route) => route.isFirst);

        // Store user information
        setState(() {
          _loggedInUserId = userId;
          _authToken = authToken;
        });

        // Show success message on home view
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful for user: $userId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Here you can handle the authentication data
        print('Auth Token: $authToken');
        print('User ID: $userId');
        print('Available Domain: $availableDomain');
        print('Disable Logout: $disableLogout');

      } else {
        throw Exception('Invalid auth data type');
      }
    } catch (e) {
      print('Error handling auth callback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openWebView() {
    if (kIsWeb) {
      // Show message that this is mobile-only
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WebView is only supported on mobile platforms'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_controller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WebView not initialized'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final webviewUrl = dotenv.env['WEBVIEW_URL'] ?? 'https://flutter.dev';
    print('Loading WebView URL: $webviewUrl');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Web View'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: WebViewWidget(
            controller: _controller!..loadRequest(Uri.parse(webviewUrl)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.web,
              color: Colors.blue,
              size: 80,
            ),
            const SizedBox(height: 30),
            const Text(
              'Welcome to Flutter Mobile App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'This app opens your React app in a mobile WebView',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_loggedInUserId != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Logged in as: $_loggedInUserId',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loggedInUserId = null;
                    _authToken = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _openWebView,
                icon: const Icon(Icons.phone_android),
                label: const Text('Open Mobile WebView'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
