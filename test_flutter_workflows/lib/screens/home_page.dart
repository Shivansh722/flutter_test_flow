
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';
import 'package:hyperkyc_flutter/hyperkyc_theme_mode.dart';
import 'package:test_flutter_workflows/components/text_fields.dart';
import 'package:test_flutter_workflows/components/custom_submit_button.dart';
import 'package:test_flutter_workflows/components/custom_keyValue.dart';
import 'package:test_flutter_workflows/utils/logger.dart';
import 'package:test_flutter_workflows/screens/logs_screen.dart';
import 'package:test_flutter_workflows/utils/ocr_service.dart';
import 'package:test_flutter_workflows/utils/version_manager.dart';

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
  final FocusNode _appIdFocusNode = FocusNode();

  // List of custom inputs, each with key and value controllers and focus node
  List<Map<String, dynamic>> _customInputs = [];

  bool _loading = false;
  bool _persistLogs = true;
  // start with a placeholder; real value loaded asynchronously
  String _runtimeSdkVersion = 'unknown';

  final OCRService _ocrService = OCRService();

  // Predefined eSign inputs
  final Map<String, String> eSignInputs = {
    "userName": "Priyansh Manoj Sinha",
    "userEmail": "priyanshs2000@gmail.com",
    "templateId": "goldenpi_1",
    "coordinates": '[{"x1": 383, "x2": 503, "y1": 48, "y2": 88, "page": 1}]',
    "baseDocument": "",
  };

  @override
  void initState() {
    super.initState();
    _loadInputs();
    // Load persisted runtime version (if any)
    VersionManager.getCurrentHyperKycVersion().then((v) {
      setState(() {
        _runtimeSdkVersion = v;
      });
    }).ignore;
  }

  void _loadInputs() async {
    // Set main fields
    _appIdController.text = '1u6n6s';
    _appKeyController.text = 'ijtbaxysugwm3doztgxv';
    _workflowIdController.text = 'eSign';

    // Load baseDocument from file
    try {
      final content = await rootBundle.loadString('assets/eSign_req.txt');
      eSignInputs['baseDocument'] = content.trim();
    } catch (e) {
      debugPrint('Error reading assets/eSign_req.txt: $e');
    }

    // Add custom inputs
    setState(() {
      _customInputs.clear();
      eSignInputs.forEach((key, value) {
        final focusNode = FocusNode();
        _customInputs.add({
          'key': TextEditingController(text: key),
          'value': TextEditingController(text: value),
          'focusNode': focusNode,
        });
      });
    });
  }

  // OCR handler methods for each field
  Future<void> _handleOCRForAppId() async {
    final text = await _ocrService.captureAndRecognizeText(context);
    if (text != null) {
      _appIdController.text = text;
    }
  }

  Future<void> _handleOCRForAppKey() async {
    final text = await _ocrService.captureAndRecognizeText(context);
    if (text != null) {
      _appKeyController.text = text;
    }
  }

  Future<void> _handleOCRForWorkflowId() async {
    final text = await _ocrService.captureAndRecognizeText(context);
    if (text != null) {
      _workflowIdController.text = text;
    }
  }

  Future<void> _handleOCRForTransactionId() async {
    final text = await _ocrService.captureAndRecognizeText(context);
    if (text != null) {
      _transactionIdController.text = text;
    }
  }

  void _addCustomInput() {
    setState(() {
      final focusNode = FocusNode();
      _customInputs.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
        'focusNode': focusNode,
      });
      // Request focus on the new input after the widget builds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (!mounted) return;
          // Ensure the focus node is still part of the current inputs (not removed)
          final stillPresent = _customInputs.any((m) => identical(m['focusNode'], focusNode));
          if (stillPresent) {
            focusNode.requestFocus();
          }
        } catch (e, st) {
          debugPrint('Focus request failed: $e\n$st');
        }
      });
    });
  }

  /// Add a custom input row with empty controllers but display the given hints
  /// as placeholder text until the user types into the fields.
  void _addCustomInputWithHints(String? keyHint, String? valueHint) {
    setState(() {
      final focusNode = FocusNode();
      _customInputs.add({
        'key': TextEditingController(),
        'value': TextEditingController(),
        'focusNode': focusNode,
        'keyHint': keyHint,
        'valueHint': valueHint,
      });
    });
  }

  

  void _removeCustomInput(int index) {
    setState(() {
      _customInputs[index]['key']!.dispose();
      _customInputs[index]['value']!.dispose();
      _customInputs[index]['focusNode']!.dispose();
      _customInputs.removeAt(index);
    });
  }

  /// Open a bottom sheet where user can paste JSON. The JSON must be an object
  /// mapping keys to values. On successful parsing we add those key/value pairs
  /// as custom inputs.
  void _openJsonInputSheet() {
    final TextEditingController jsonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste JSON',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: jsonController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: '{"key1": "value1", "key2": "value2"}',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final raw = jsonController.text.trim();
                      if (raw.isEmpty) {
                        _showSnack('Please paste a JSON payload');
                        return;
                      }

                      try {
                        final decoded = json.decode(raw);
                        if (decoded is Map<String, dynamic>) {
                          _addCustomInputsFromMap(decoded);
                          Navigator.of(context).pop();
                        } else {
                          _showSnack('JSON must be an object mapping keys to values');
                        }
                      } catch (e) {
                        _showSnack('Invalid JSON: ${e.toString()}');
                      }
                    },
                    child: const Text('Add custom inputs'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _addCustomInputsFromMap(Map<String, dynamic> map) {
    // Store old inputs for disposal after frame
    final oldInputs = List<Map<String, dynamic>>.from(_customInputs);
    
    // Replace with new inputs immediately
    setState(() {
      _customInputs.clear();
      
      map.forEach((k, v) {
        final focusNode = FocusNode();
        _customInputs.add({
          'key': TextEditingController(text: k),
          'value': TextEditingController(text: v?.toString() ?? ''),
          'focusNode': focusNode,
        });
      });
    });
    
    // Dispose old controllers and focus nodes after the frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var input in oldInputs) {
        try {
          input['key']?.dispose();
          input['value']?.dispose();
          input['focusNode']?.dispose();
        } catch (e) {
          debugPrint('Error disposing old custom input: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _appIdFocusNode.dispose();
    _appKeyController.dispose();
    _workflowIdController.dispose();
    _transactionIdController.dispose();
    for (var input in _customInputs) {
      input['key']!.dispose();
      input['value']!.dispose();
      input['focusNode']!.dispose();
    }
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> startKyc() async {
    final appId = _appIdController.text.trim();
    final appKey = _appKeyController.text.trim();
    final workflowId = _workflowIdController.text.trim();
    final transactionId = _transactionIdController.text.trim();

    if (appId.isEmpty || appKey.isEmpty || workflowId.isEmpty || transactionId.isEmpty) {
      _showSnack('Please fill all fields before starting KYC');
      return;
    }

    setState(() => _loading = true);

    // ensure we have the latest version string before proceeding
    final sdkVersion = await VersionManager.getCurrentHyperKycVersion();
    setState(() { _runtimeSdkVersion = sdkVersion; });

    final hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
      appId: appId,
      appKey: appKey,
      workflowId: workflowId,
      transactionId: transactionId,
    );

    // Set the theme mode for HyperKYC SDK
    // Options: HKThemeMode.light, HKThemeMode.dark, HKThemeMode.system
    hyperKycConfig.setHKThemeMode(hkThemeMode: HKThemeMode.dark);

    // Build inputs from custom key/values (demo inputs are shown as prefilled custom inputs)
    final Map<String, String> inputs = <String, String>{};
    for (var input in _customInputs) {
      final key = input['key']!.text.trim();
      final value = input['value']!.text.trim();
      if (key.isNotEmpty) {
        inputs[key] = value;
      }
    }

    // Log the final values we will send to the SDK (helps debugging incorrect inputs)
    debugPrint('Launching HyperKyc with appId=$appId, appKey=${appKey.replaceAll(RegExp('.'), '*')}, workflowId=$workflowId, transactionId=$transactionId, sdkVersion=$sdkVersion, customInputs=$inputs');

    // Persist the request (redact appKey) if enabled
    if (_persistLogs) {
      try {
        await Logger.instance.logJson({
          'event': 'startKyc.request',
          'appId': appId,
          'appKey': appKey.replaceAll(RegExp('.'), '*'),
          'workflowId': workflowId,
          'transactionId': transactionId,
          'sdkVersion': sdkVersion,
          'inputs': inputs,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Failed to persist startKyc.request: $e');
      }
    }

    // If your flow contains inputs
    hyperKycConfig.setInputs(inputs: inputs);

    // Include the runtime SDK version in the inputs so it's sent to the SDK
    // (This allows you to track which version string was used when triggering the workflow)
    final allInputs = <String, String>{
      ...inputs,
      'sdkVersion': sdkVersion,
    };
    hyperKycConfig.setInputs(inputs: allInputs);

    try {
      final HyperKycResult hyperKycResult = await HyperKyc.launch(hyperKycConfig: hyperKycConfig);

      // Persist the result
      if (_persistLogs) {
        try {
          await Logger.instance.logJson({
            'event': 'startKyc.result',
            'status': hyperKycResult.status?.value,
            'sdkVersion': sdkVersion,
            'raw': hyperKycResult.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Failed to persist startKyc.result: $e');
        }
      }

      final String? status = hyperKycResult.status?.value;
      switch (status) {
        case 'auto_approved':
          _showSnack('Workflow successful - auto approved');
          break;
        case 'auto_declined':
          _showSnack('Workflow successful - auto declined');
          break;
        case 'needs_review':
          _showSnack('Workflow successful - needs review');
          break;
        case 'error':
          _showSnack('Failure');
          break;
        case 'user_cancelled':
          _showSnack('User cancelled');
          break;
        default:
          _showSnack('Contact HyperVerge for more details');
      }
    } catch (e, stackTrace) {
      // Log or show unexpected errors
      if (_persistLogs) {
        try {
          await Logger.instance.logJson({
            'event': 'startKyc.exception',
            'error': e.toString(),
            'sdkVersion': sdkVersion,
            'stack': stackTrace.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Failed to persist startKyc.exception: $e');
        }
      }

      _showSnack('Error launching HyperKyc: $e');
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.article_outlined,
              color: Color.fromARGB(255, 164, 164, 219),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogsScreen()),
              );
            },
            tooltip: 'View Logs',
          ),
        ],
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
                Row(
                  children: [
                    const Text(
                      'Configurations',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 164, 164, 219),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Persist logs', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Switch(
                          value: _persistLogs,
                          activeColor: const Color.fromARGB(255, 164, 164, 219),
                          onChanged: (v) => setState(() => _persistLogs = v),
                        ),
                      ],
                    ),
                  ],
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
                  enableOCR: true,
                  onOCRTap: _handleOCRForAppId,
                  focusNode: _appIdFocusNode,
                  requestFocus: true,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: _appKeyController,
                  label: 'App Key',
                  hint: 'Enter your application key',
                  prefixIcon: Icons.key,
                  enableOCR: true,
                  onOCRTap: _handleOCRForAppKey,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: _workflowIdController,
                  label: 'Workflow ID',
                  hint: 'Enter workflow identifier',
                  prefixIcon: Icons.account_tree,
                  enableOCR: true,
                  onOCRTap: _handleOCRForWorkflowId,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: _transactionIdController,
                  label: 'Transaction ID',
                  hint: 'Enter transaction identifier',
                  prefixIcon: Icons.receipt_long,
                  enableOCR: true,
                  onOCRTap: _handleOCRForTransactionId,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: const Color.fromARGB(255, 164, 164, 219).withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: const Text(
                        //     'Optional',
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //       color: Color.fromARGB(255, 164, 164, 219),
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _openJsonInputSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 164, 164, 219).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'json i/p',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 164, 164, 219),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                      keyFocusNode: _customInputs[index]['focusNode']!,
                      keyHint: _customInputs[index]['keyHint'] as String?,
                      valueHint: _customInputs[index]['valueHint'] as String?,
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
