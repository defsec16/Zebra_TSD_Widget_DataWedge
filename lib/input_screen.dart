import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zebra_suka_test/ScannerService.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final scannerService = Provider.of<ScannerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Экран ввода'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Поле ввода данных с иконкой поиска
            TextField(
              controller: scannerService.textController, // Привязываем контроллер
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Введите штрих-код',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Обработка нажатия на иконку поиска
                    print('Нажата иконка поиска'); // Принт для отладки
                    scannerService.processManualInput();
                  },
                ),
              ),
              onChanged: (value) {
                // Обновляем данные при ручном вводе
                print('Ручной ввод: $value'); // Принт для отладки
                scannerService.updateManualInput(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
