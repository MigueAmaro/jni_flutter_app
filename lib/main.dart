import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart' as ffi_utc;
import 'package:flutter/material.dart';

// 1. Define the C function signatures
//    In C: const char* helloFromC();
//    So we represent it as a function returning Pointer<Utf8>, but we can also use Pointer<Void> and cast later.
typedef HelloFromCFunc = ffi.Pointer<ffi.Void> Function();
typedef HelloFromCDart = ffi.Pointer<ffi.Void> Function();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = 'Loading...';

  late final ffi.DynamicLibrary _helloLib;
  late final HelloFromCDart _helloFromC;

  @override
  void initState() {
    super.initState();
    initFFI();
  }

  void initFFI() {
    if (Platform.isAndroid) {
      // Load the Android library
      _helloLib = ffi.DynamicLibrary.open('libhello.so');
    } else if (Platform.isMacOS) {
      // Load the macOS library
      _helloLib = ffi.DynamicLibrary.open('libhello.dylib');
    } else {
      setState(() {
        _message = 'Not running on Android or macOS.';
      });
      return;
    }

    // Lookup the 'helloFromC' symbol
    _helloFromC = _helloLib
        .lookup<ffi.NativeFunction<HelloFromCFunc>>('helloFromC')
        .asFunction<HelloFromCDart>();

    // Call 'helloFromC'
    final ptr = _helloFromC();
    final messagePtr = ptr.cast<ffi_utc.Utf8>();
    final dartString = messagePtr.toDartString();

    setState(() {
      _message = dartString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello FFI Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello from C Contest!')),
        body: Center(
          child: Text(_message, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
