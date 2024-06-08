import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Calculator'),
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
  String _output = "0";
  String _input = "";

  void _numberPressed(String number) {
    setState(() {
      if (_input.length < 10) {
        _input += number;
        _output = _input;
      }
    });
  }

  void _operatorPressed(String operator) {
    setState(() {
      if (_input.isNotEmpty && !"+-*/".contains(_input[_input.length - 1])) {
        _input += operator;
        _output = _input;
      }
    });
  }

  void _calculate() {
    setState(() {
      try {
        final result = _evaluate(_input);
        _output = result.toString();
        _input = _output;
      } catch (e) {
        _output = "Error";
      }
    });
  }

  void _clear() {
    setState(() {
      _input = "";
      _output = "0";
    });
  }

  double _evaluate(String input) {
    List<String> tokens = _tokenize(input);
    List<double> values = [];
    List<String> ops = [];
    
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == "(") {
        ops.add(tokens[i]);
      } else if (_isNumber(tokens[i])) {
        values.add(double.parse(tokens[i]));
      } else if (tokens[i] == ")") {
        while (ops.isNotEmpty && ops.last != "(") {
          double val2 = values.removeLast();
          double val1 = values.removeLast();
          String op = ops.removeLast();
          values.add(_applyOp(val1, val2, op));
        }
        ops.removeLast();
      } else if (_isOperator(tokens[i])) {
        while (ops.isNotEmpty && _precedence(ops.last) >= _precedence(tokens[i])) {
          double val2 = values.removeLast();
          double val1 = values.removeLast();
          String op = ops.removeLast();
          values.add(_applyOp(val1, val2, op));
        }
        ops.add(tokens[i]);
      }
    }

    while (ops.isNotEmpty) {
      double val2 = values.removeLast();
      double val1 = values.removeLast();
      String op = ops.removeLast();
      values.add(_applyOp(val1, val2, op));
    }

    return values.last;
  }

  List<String> _tokenize(String input) {
    List<String> tokens = [];
    String buffer = "";
    for (int i = 0; i < input.length; i++) {
      if ("0123456789.".contains(input[i])) {
        buffer += input[i];
      } else {
        if (buffer.isNotEmpty) {
          tokens.add(buffer);
          buffer = "";
        }
        tokens.add(input[i]);
      }
    }
    if (buffer.isNotEmpty) {
      tokens.add(buffer);
    }
    return tokens;
  }

  bool _isNumber(String token) {
    return double.tryParse(token) != null;
  }

  bool _isOperator(String token) {
    return "+-*/".contains(token);
  }

  int _precedence(String op) {
    if (op == "+" || op == "-") {
      return 1;
    }
    if (op == "*" || op == "/") {
      return 2;
    }
    return 0;
  }

  double _applyOp(double a, double b, String op) {
    switch (op) {
      case "+":
        return a + b;
      case "-":
        return a - b;
      case "*":
        return a * b;
      case "/":
        if (b == 0) {
          throw Exception("Cannot divide by zero");
        }
        return a / b;
      default:
        throw Exception("Unsupported operator");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Text(
                _output,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton("7"),
                _buildButton("8"),
                _buildButton("9"),
                _buildButton("/"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton("4"),
                _buildButton("5"),
                _buildButton("6"),
                _buildButton("*"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton("1"),
                _buildButton("2"),
                _buildButton("3"),
                _buildButton("-"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton("0"),
                _buildButton("C"),
                _buildButton("="),
                _buildButton("+"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label) {
    return FloatingActionButton(
      onPressed: () {
        if (label == "C") {
          _clear();
        } else if (label == "=") {
          _calculate();
        } else if ("+-*/".contains(label)) {
          _operatorPressed(label);
        } else {
          _numberPressed(label);
        }
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
