import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zebra_suka_test/ScannerService.dart';
import 'input_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ScannerService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DataWedge Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      routes: {
        '/input': (context) => InputScreen(), // Добавляем маршрут к экрану ввода
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scannerService = Provider.of<ScannerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Главный экран'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Отсканированные данные: ${scannerService.scannedData}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Формат штрих-кода: ${scannerService.barcodeFormat}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/input'); // Переход на экран ввода
              },
              child: Text('Открыть экран ввода'),
            ),
          ],
        ),
      ),
    );
  }
}
