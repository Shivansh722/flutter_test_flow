
import 'package:flutter/material.dart';
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';
import 'package:test_flutter_workflows/components/text_fields.dart';
import 'package:test_flutter_workflows/components/custom_submit_button.dart';
import 'package:test_flutter_workflows/components/custom_keyValue.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color.fromARGB(255, 164, 164, 219),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                const Text(
                  'Configurations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 164, 164, 219),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to start the KYC workflow',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ModernTextField(
                  controller: _appIdController,
                  label: 'App ID',
                  hint: 'Enter your application ID',
                  prefixIcon: Icons.app_settings_alt,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: _appKeyController,
                  label: 'App Key',
                  hint: 'Enter your application key',
                  prefixIcon: Icons.key,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: _workflowIdController,
                  label: 'Workflow ID',
                  hint: 'Enter workflow identifier',
                  prefixIcon: Icons.account_tree,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: _transactionIdController,
                  label: 'Transaction ID',
                  hint: 'Enter transaction identifier',
                  prefixIcon: Icons.receipt_long,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Text(
                      'Custom Inputs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 164, 164, 219),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 164, 164, 219).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Optional',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 164, 164, 219),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Add custom key-value pairs for your workflow',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _customInputs.length,
                  itemBuilder: (context, index) {
                    return CustomKeyValueInput(
                      keyController: _customInputs[index]['key']!,
                      valueController: _customInputs[index]['value']!,
                      index: index,
                      canRemove: _customInputs.length > 1,
                      onRemove: () => _removeCustomInput(index),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ModernButton(
                  text: 'Add Custom Input',
                  onPressed: _addCustomInput,
                  isPrimary: false,
                  icon: Icons.add,
                ),
                const SizedBox(height: 32),
                ModernButton(
                  text: 'Start KYC Workflow',
                  onPressed: startKyc,
                  isPrimary: true,
                  icon: Icons.rocket_launch,
                  isLoading: _loading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
