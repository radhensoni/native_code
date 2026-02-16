import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Vibration Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VibrationDemoPage(),
    );
  }
}

class VibrationDemoPage extends StatefulWidget {
  const VibrationDemoPage({super.key});

  @override
  State<VibrationDemoPage> createState() => _VibrationDemoPageState();
}

class _VibrationDemoPageState extends State<VibrationDemoPage>
    with SingleTickerProviderStateMixin {
  static const platform = MethodChannel('com.example.native_code/native');
  String _statusMessage = 'Press a button to vibrate';
  bool _isVibrating = false;

  // Visual feedback
  late AnimationController _visualController;
  List<bool> _vibrationPulses = [];
  int _currentPulseIndex = 0;

  final Map<String, List<int>> _patterns = {
    'pulse': [0, 200, 100, 200, 100, 200],
    'heartbeat': [0, 100, 50, 100, 400, 100, 50, 100],
    'alert': [0, 500, 200, 500, 200, 500],
    'sos': [
      0,
      100,
      100,
      100,
      100,
      100,
      300,
      300,
      100,
      300,
      100,
      300,
      300,
      100,
      100,
      100,
      100,
      100,
    ],
    'notification': [0, 50, 50, 50],
  };

  @override
  void initState() {
    super.initState();
    _visualController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _visualController.dispose();
    super.dispose();
  }

  Future<void> _triggerVibration(String patternName) async {
    if (_isVibrating) {
      setState(() {
        _statusMessage = 'Please wait for current vibration to finish';
      });
      return;
    }

    setState(() {
      _isVibrating = true;
      _statusMessage = 'Vibrating with $patternName pattern...';
    });

    try {
      final pattern = _patterns[patternName] ?? [0, 200];

      // Start visual feedback animation
      _startVisualFeedback(pattern);

      final bool result = await platform.invokeMethod('vibrate', {
        'pattern': pattern,
      });

      if (result) {
        setState(() {
          _statusMessage = '✅ $patternName vibration completed!';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Unexpected error: $e';
      });
    } finally {
      final pattern = _patterns[patternName] ?? [0, 200];
      final totalDuration = pattern.reduce((a, b) => a + b);

      await Future.delayed(Duration(milliseconds: totalDuration + 100));

      setState(() {
        _isVibrating = false;
        _vibrationPulses = [];
        _currentPulseIndex = 0;
      });
    }
  }

  void _startVisualFeedback(List<int> pattern) {
    setState(() {
      _vibrationPulses = [];
      _currentPulseIndex = 0;
    });

    // Create visual pulses based on pattern
    for (int i = 0; i < pattern.length; i++) {
      Future.delayed(
        Duration(milliseconds: pattern.sublist(0, i).fold(0, (a, b) => a + b)),
        () {
          if (mounted) {
            setState(() {
              _currentPulseIndex = i;
              // Odd indices are vibrations, even are pauses
              if (i % 2 == 1) {
                _vibrationPulses.add(true);
                _visualController.forward(from: 0);
              } else {
                _vibrationPulses.add(false);
              }
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Native Vibration Demo'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visual Vibration Indicator
                _buildVisualIndicator(),
                const SizedBox(height: 30),

                // Header
                const Icon(Icons.vibration, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 20),
                const Text(
                  'Unlocking Native Power',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'FlutterFlow Integration Demo',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Status Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isVibrating)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (_isVibrating) const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Vibration Buttons
                _buildVibrationButton(
                  context,
                  'Pulse',
                  'pulse',
                  Icons.graphic_eq,
                  Colors.blue,
                ),
                const SizedBox(height: 15),
                _buildVibrationButton(
                  context,
                  'Heartbeat',
                  'heartbeat',
                  Icons.favorite,
                  Colors.red,
                ),
                const SizedBox(height: 15),
                _buildVibrationButton(
                  context,
                  'Alert',
                  'alert',
                  Icons.warning_amber_rounded,
                  Colors.orange,
                ),
                const SizedBox(height: 15),
                _buildVibrationButton(
                  context,
                  'SOS',
                  'sos',
                  Icons.sos,
                  Colors.deepOrange,
                ),
                const SizedBox(height: 15),
                _buildVibrationButton(
                  context,
                  'Notification',
                  'notification',
                  Icons.notifications_active,
                  Colors.green,
                ),
                const SizedBox(height: 40),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple.shade200,
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.deepPurple,
                        size: 30,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Watch the visual indicator above to see vibration patterns',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Purple pulse = Device is vibrating',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isVibrating && _currentPulseIndex % 2 == 1
            ? Colors.deepPurple
            : Colors.deepPurple.shade100,
        boxShadow: _isVibrating && _currentPulseIndex % 2 == 1
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.6),
                  spreadRadius: 20,
                  blurRadius: 40,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Icon(
          Icons.vibration,
          size: 60,
          color: _isVibrating && _currentPulseIndex % 2 == 1
              ? Colors.white
              : Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildVibrationButton(
    BuildContext context,
    String label,
    String patternName,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isVibrating ? null : () => _triggerVibration(patternName),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
