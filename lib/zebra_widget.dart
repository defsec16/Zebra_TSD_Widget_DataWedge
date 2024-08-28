import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterDataWedge fdw;
  String scannedData = '';
  String barcodeFormat = '';
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  StreamSubscription? onScanSubscription;
  String accumulatedData = ''; // Для накопления данных
  Timer? dataProcessingTimer;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      initializeScanner();
    }
  }

  Future<void> initializeScanner() async {
    try {
      if (onScanSubscription == null) {
        await fdw.initialize();
        await fdw.createDefaultProfile(profileName: "Example app profile");

        onScanSubscription = fdw.onScanResult.listen((ScanResult result) {
          print('Полученные данные: ${result.data}');

          // Накопление данных
          accumulatedData = result.data; // Перезаписываем накопленные данные новым результатом
          print('Накопленные данные: $accumulatedData');

          // Обработка накопленных данных с задержкой
          dataProcessingTimer?.cancel(); // Отменяем предыдущий таймер
          dataProcessingTimer = Timer(Duration(milliseconds: 500), () {
            _processScanData(accumulatedData);
          });
        });
      } else {
        print('Уже подписан на результаты сканирования');
      }
    } catch (e) {
      print('Ошибка инициализации DataWedge: $e');
    }
  }

  void _processScanData(String data) {
    // Проверка длины данных
    if (data.length >= 8 && data.length <= 13) {
      setState(() {
        scannedData = data;
        barcodeFormat = determineBarcodeFormat(data);
      });
      _updateTextController(data);
      accumulatedData = ''; // Очистка накопленных данных после обработки
      print('Обработанные данные: $scannedData');
      print('Формат штрих-кода: $barcodeFormat');
    } else {
      print('Неверная длина данных сканирования: $data');
      accumulatedData = ''; // Очистка накопленных данных в случае ошибки
    }
  }

  void _updateTextController(String data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textController.text != data) {
        _textController.text = data;
        _focusNode.requestFocus();
        // Автоматически нажимаем кнопку "Отправить штрих-код"
        _handleManualInput();
      }
    });
  }

  String determineBarcodeFormat(String data) {
    print('Определение формата штрих-кода для данных: $data');
    if (data.length == 13) {
      return 'EAN-13';
    } else if (data.length == 12) {
      return 'UPC-A';
    } else if (data.length == 8) {
      return 'EAN-8';
    }
    return 'Unknown Format';
  }

  void _handleManualInput() {
    setState(() {
      scannedData = _textController.text;
      barcodeFormat = determineBarcodeFormat(scannedData);
    });
    print('Ручной ввод: $scannedData');
    print('Формат штрих-кода: $barcodeFormat');
  }

  @override
  void dispose() {
    onScanSubscription?.cancel();
    dataProcessingTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DataWedge Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter DataWedge Scanner'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Введите штрих-код',
                ),
                onChanged: (value) {
                  setState(() {
                    scannedData = value;
                    barcodeFormat = determineBarcodeFormat(value);
                    print('Поле Ввода изменено: $scannedData');
                    print('Barcode Format123: $barcodeFormat');
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleManualInput,
                child: Text('Отправить штрих-код'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
