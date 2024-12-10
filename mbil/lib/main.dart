import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        backgroundColor: Colors.blue,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            icon: Icons.calculate,
            label: "CALCULATOR",
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalculatorPage()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.mosque,
            label: "DHIKR",
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaceholderPage(label: "Dhikr"),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.image,
            label: "GALLERY",
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GalleryPage()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.contact_page,
            label: "CONTACT",
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaceholderPage(label: "Contact"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  final String apiUrl =
      'https://api.slingacademy.com/v1/sample-data/photos?offset=0&limit=60';

  Future<List<dynamic>> fetchImages() async {
    final response = await http.get(Uri.parse(apiUrl));
    return jsonDecode(response.body)['photos'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading images."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No images available."));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    snapshot.data![index]['url'],
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;

  void _onPressed(String value) {
    setState(() {
      _display = _display == '0' ? value : _display + value;
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      _firstOperand = double.parse(_display);
      _operator = operator;
      _display = '0';
    });
  }

  void _onCalculate() {
    if (_firstOperand != null && _operator != null) {
      double secondOperand = double.parse(_display);
      double result;

      switch (_operator) {
        case '+':
          result = _firstOperand! + secondOperand;
          break;
        case '-':
          result = _firstOperand! - secondOperand;
          break;
        case '*':
          result = _firstOperand! * secondOperand;
          break;
        case '/':
          result = _firstOperand! / secondOperand;
          break;
        default:
          result = 0.0;
      }

      setState(() {
        _display = result % 1 == 0 ? result.toStringAsFixed(0) : result.toString();
        _firstOperand = null;
        _operator = null;
      });
    }
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                children: [
                  ...['1', '2', '3', '+'].map((value) => _buildButton(value)),
                  ...['4', '5', '6', '-'].map((value) => _buildButton(value)),
                  ...['7', '8', '9', '*'].map((value) => _buildButton(value)),
                  _buildButton('0'),
                  _buildButton('CLR', isOperator: true),
                  _buildButton('=', isOperator: true),
                  _buildButton('/', isOperator: true),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildButton(String value, {bool isOperator = false}) {
    return GestureDetector(
      onTap: () {
        if (value == 'CLR') {
          _onClear();
        } else if (value == '=') {
          _onCalculate();
        } else if (['+', '-', '*', '/'].contains(value)) {
          _onOperatorPressed(value);
        } else {
          _onPressed(value);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isOperator ? Colors.red : Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String label;

  const PlaceholderPage({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          "Halaman $label sedang dalam pengembangan.",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
