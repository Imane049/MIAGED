import 'dart:io';

Future<void> startFlaskServer() async {
  const flaskUrl = 'http://127.0.0.1:5000'; // Replace with your Flask URL

  // Function to check if Flask server is running
  Future<bool> isFlaskRunning() async {
    try {
      final response = await HttpClient().getUrl(Uri.parse(flaskUrl));
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Check and start Flask if not running
  if (!(await isFlaskRunning())) {
    print('Starting Flask API...');
    Process.start('python', ['lib/assets/main.py']); // Adjust path
    await Future.delayed(const Duration(seconds: 3)); // Wait for Flask to start
  } else {
    print('Flask API is already running.');
  }
}
