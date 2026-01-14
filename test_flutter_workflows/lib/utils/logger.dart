import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Simple file-backed logger for workflow debugging.
///
/// Usage:
///   await Logger.instance.log('message');
///   Logger.instance.logJson({'a': 1});
class Logger {
  Logger._internal();

  static final Logger instance = Logger._internal();

  File? _file;
  bool _initialized = false;
  final _queue = StreamController<String>();

  Future<void> _init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/workflow_logs.txt');
      _file = file;
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      // start writer
      _queue.stream.listen((line) async {
        try {
          await _file?.writeAsString(line + '\n', mode: FileMode.append, flush: true);
        } catch (e) {
          // ignore file write errors in production; still print
          debugPrint('Logger write error: $e');
        }
      });
      _initialized = true;
    } catch (e) {
      debugPrint('Logger init failed: $e');
      _initialized = false;
    }
  }

  Future<void> log(String message, {String level = 'INFO'}) async {
    final ts = DateTime.now().toIso8601String();
    final line = '[$ts] [$level] $message';
    // print immediately for dev
    debugPrint(line);
    try {
      if (!_initialized) await _init();
      if (_initialized) {
        _queue.add(line);
      }
    } catch (e) {
      debugPrint('Logger error: $e');
    }
  }

  Future<void> logJson(Object obj, {String level = 'DEBUG'}) async {
    try {
      final json = const JsonEncoder.withIndent('  ').convert(obj);
      await log(json, level: level);
    } catch (e) {
      await log('Failed to JSON-encode object: $e', level: 'ERROR');
    }
  }

  /// Read all logs from the file
  Future<String> readLogs() async {
    try {
      if (!_initialized) await _init();
      if (_file != null && await _file!.exists()) {
        return await _file!.readAsString();
      }
      return 'No logs available yet';
    } catch (e) {
      debugPrint('Failed to read logs: $e');
      return 'Error reading logs: $e';
    }
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    try {
      if (!_initialized) await _init();
      if (_file != null && await _file!.exists()) {
        await _file!.writeAsString('');
      }
    } catch (e) {
      debugPrint('Failed to clear logs: $e');
    }
  }

  /// Convenience to close background writer (useful in tests)
  Future<void> close() async {
    await _queue.close();
  }
}
