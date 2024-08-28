import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';

class ScannerService with ChangeNotifier {
  late FlutterDataWedge fdw;
  String _scannedData = '';
  String _barcodeFormat = '';
  final TextEditingController _textController = TextEditingController();
  StreamSubscription? _onScanSubscription;

  String get scannedData => _scannedData;
  String get barcodeFormat => _barcodeFormat;
  TextEditingController get textController => _textController;

  ScannerService() {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      _initializeScanner();
    }
  }

  Future<void> _initializeScanner() async {
    try {
      if (_onScanSubscription == null) {
        print('Инициализация DataWedge...');
        await fdw.initialize();
        print('DataWedge инициализирован.');
        await fdw.createDefaultProfile(profileName: "Профиль примера приложения");
        print('Создан профиль по умолчанию.');

        _onScanSubscription = fdw.onScanResult.listen((ScanResult result) {
          print('Получен результат сканирования: ${result.data}');
          _processScanData(result.data);
        });
        print('Настроен слушатель результата сканирования.');
      }
    } catch (e) {
      print('Ошибка инициализации DataWedge: $e');
    }
  }

  void _processScanData(String data) {
    print('Обработка данных сканирования: $data');
    if (_isValidBarcodeLength(data)) {
      _scannedData = data;
      _barcodeFormat = _determineBarcodeFormat(data);

      _textController.text = _scannedData;
      print('Обновлены данные сканирования: $_scannedData');
      print('Формат штрих-кода: $_barcodeFormat');

      notifyListeners();
    } else {
      print('Неверная длина данных сканирования: ${data.length}');
    }
  }

  bool _isValidBarcodeLength(String data) {
    final length = data.length;
    return length == 8 || length == 12 || length == 13;
  }

  void updateManualInput(String data) {
    print('Обновление ручного ввода: $data');
    _scannedData = data;
    _barcodeFormat = _determineBarcodeFormat(data);
    notifyListeners();
  }

  void processManualInput() {
    print('Обработка ручного ввода');
    _processScanData(_scannedData);
    notifyListeners();
  }

  String _determineBarcodeFormat(String data) {
    switch (data.length) {
      case 13:
        return 'EAN-13';
      case 12:
        return 'UPC-A';
      case 8:
        return 'EAN-8';
      default:
        return 'Неизвестный формат';
    }
  }

  @override
  void dispose() {
    _onScanSubscription?.cancel();
    super.dispose();
  }
}
