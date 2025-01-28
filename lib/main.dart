import 'dart:ffi' as ffi;          // Core Dart FFI
import 'dart:io' show Platform;    // Detect if running on Android
import 'package:ffi/ffi.dart' as ffi_utc; // For easy Utf8 conversion
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
      _helloLib = ffi.DynamicLibrary.open('libhello.so');

      // Lookup the 'helloFromC' symbol
      _helloFromC = _helloLib
          .lookup<ffi.NativeFunction<HelloFromCFunc>>('helloFromC')
          .asFunction<HelloFromCDart>();

      // Call 'helloFromC'
      final ptr = _helloFromC(); // Returns a pointer to a C string

      // Cast to Pointer<Int8> so we can interpret it as UTF8 text
      // Cast to Pointer<Utf8>, not Pointer<Int8> after trying the above and doesnt work
      final messagePtr = ptr.cast<ffi_utc.Utf8>();

      // Use the 'toDartString()' extension method
      final dartString = messagePtr.toDartString();


      setState(() {
        _message = dartString;
      });
    } else {
      setState(() {
        _message = 'Not running on Android device/emulator :(.';
      });
    }
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
