import 'package:flutter/material.dart';
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter demo app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter - HyperKYC Home Page'),
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
  // Controllers for runtime input on the home screen
  final TextEditingController _appIdController = TextEditingController();
  final TextEditingController _appKeyController = TextEditingController();
  final TextEditingController _workflowIdController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();

  // List of custom inputs, each with key and value controllers
  List<Map<String, TextEditingController>> _customInputs = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Start with one custom input pair
    _addCustomInput();
  }

  void _addCustomInput() {
    setState(() {
      _customInputs.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
      });
    });
  }

  void _removeCustomInput(int index) {
    setState(() {
      _customInputs[index]['key']!.dispose();
      _customInputs[index]['value']!.dispose();
      _customInputs.removeAt(index);
    });
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _appKeyController.dispose();
    _workflowIdController.dispose();
    _transactionIdController.dispose();
    for (var input in _customInputs) {
      input['key']!.dispose();
      input['value']!.dispose();
    }
    super.dispose();
  }

  // Optional static demo inputs; user can add one custom key/value via UI as well.
  final Map<String, String> demoInputs = {
    "key1": "value1",
  };

  Future<void> startKyc() async {
    final appId = _appIdController.text.trim();
    final appKey = _appKeyController.text.trim();
    final workflowId = _workflowIdController.text.trim();
    final transactionId = _transactionIdController.text.trim();

    if (appId.isEmpty || appKey.isEmpty || workflowId.isEmpty || transactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields before starting KYC')),
      );
      return;
    }

    setState(() => _loading = true);

    final hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
      appId: appId,
      appKey: appKey,
      workflowId: workflowId,
      transactionId: transactionId,
    );

    // Build inputs: start with demo inputs, then include custom key/values if provided
    final Map<String, String> inputs = Map<String, String>.from(demoInputs);
    for (var input in _customInputs) {
      final key = input['key']!.text.trim();
      final value = input['value']!.text.trim();
      if (key.isNotEmpty) {
        inputs[key] = value;
      }
    }

    // Log the final values we will send to the SDK (helps debugging incorrect inputs)
    debugPrint('Launching HyperKyc with appId=$appId, appKey=${appKey.replaceAll(RegExp('.'), '*')}, workflowId=$workflowId, transactionId=$transactionId, customInputs=$inputs');

    // If your flow contains inputs
    hyperKycConfig.setInputs(inputs: inputs);

    try {
      final HyperKycResult hyperKycResult =
          await HyperKyc.launch(hyperKycConfig: hyperKycConfig);

      final String? status = hyperKycResult.status?.value;
      switch (status) {
        case 'auto_approved':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workflow successful - auto approved')),
          );
          break;
        case 'auto_declined':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workflow successful - auto declined')),
          );
          break;
        case 'needs_review':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workflow successful - needs review')),
          );
          break;
        case 'error':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failure')),
          );
          break;
        case 'user_cancelled':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User cancelled')),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact HyperVerge for more details')),
          );
      }
    } catch (e) {
      // Log or show unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching HyperKyc: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // Use viewInsets bottom padding so the form scrolls above the keyboard
      body: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _appIdController,
                decoration: const InputDecoration(labelText: 'App ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _appKeyController,
                decoration: const InputDecoration(labelText: 'App Key'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _workflowIdController,
                decoration: const InputDecoration(labelText: 'Workflow ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _transactionIdController,
                decoration: const InputDecoration(labelText: 'Transaction ID'),
              ),
              const SizedBox(height: 8),
              // Dynamic custom inputs
              const Text('Custom Inputs (optional):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _customInputs.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customInputs[index]['key'],
                          decoration: InputDecoration(labelText: 'Key ${index + 1}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _customInputs[index]['value'],
                          decoration: InputDecoration(labelText: 'Value ${index + 1}'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _customInputs.length > 1 ? () => _removeCustomInput(index) : null,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addCustomInput,
                child: const Text('Add Custom Input'),
              ),
              const SizedBox(height: 16),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: startKyc,
                      child: const Text('Start KYC'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
