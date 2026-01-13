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
  final hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
    appId: "g294ap",
    appKey: "uqj5aghpbkczl3v7ajpl",
    workflowId: "panLiveness",
    transactionId: "transaction_12345",
  );

  final Map<String, String> customInputs = {
    "key1": "value1",
    "key2": "value2",
  };

  void startKyc() async {
    hyperKycConfig.setInputs(inputs: customInputs); // If the flow contains inputs

    HyperKycResult hyperKycResult =
        await HyperKyc.launch(hyperKycConfig: hyperKycConfig);

    String? status = hyperKycResult.status?.value;
    switch (status) {
      case 'auto_approved':
        print('workflow successful - auto approved');
        break;
      case 'auto_declined':
        print('workflow successful - auto declined');
        break;
      case 'needs_review':
        print('workflow successful - needs review');
        break;
      case 'error':
        print('failure');
        break;
      case 'user_cancelled':
        print('user cancelled');
        break;
      default:
        print('contact HyperVerge for more details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: TextButton(
          onPressed: startKyc,
          child: const Text("Start KYC"),
        ),
      ),
    );
  }
}
