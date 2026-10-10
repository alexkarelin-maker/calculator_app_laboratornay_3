import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная работа 3',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const InputScreen(),
    );
  }
}

/// ЭКРАН 1: Форма ввода данных и валидация
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // Ключ формы для проверки валидации
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для получения текста из полей ввода
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Состояние чекбокса
  bool _isAgreed = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //
        title: const Text('Карелин А.С. - ЛР №3'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Привязываем ключ к форме
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Калькулятор ИМТ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Поле ввода веса
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number, // Числовая клавиатура
                  decoration: const InputDecoration(
                    labelText: 'Введите вес (кг)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  // Валидация веса
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите вес';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Введите корректное число больше 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Поле ввода роста
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number, // Числовая клавиатура
                  decoration: const InputDecoration(
                    labelText: 'Введите рост (см)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.height),
                  ),
                  // Валидация роста
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Пожалуйста, введите рост';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Введите корректное число больше 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Валидируемый Чекбокс согласия
                FormField<bool>(
                  initialValue: _isAgreed,
                  validator: (value) {
                    if (_isAgreed == false) {
                      return 'Необходимо дать согласие на обработку данных';
                    }
                    return null;
                  },
                  builder: (FormFieldState<bool> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: const Text('Согласен на обработку персональных данных'),
                          value: _isAgreed,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isAgreed = newValue ?? false;
                              field.didChange(newValue);
                            });
                          },
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                            child: Text(
                              field.errorText ?? '',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Кнопка отправки данных и перехода
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Проверка валидации всей формы
                    if (_formKey.currentState!.validate()) {
                      // Получаем данные из контроллеров формы
                      double weight = double.parse(_weightController.text);
                      double height = double.parse(_heightController.text);

                      // Переход на второй экран (метод push) с передачей параметров
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            weight: weight,
                            height: height,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Рассчитать результат', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ЭКРАН 2: Прием параметров, вычисление и отображение результата
class ResultScreen extends StatelessWidget {
  final double weight;
  final double height;

  const ResultScreen({
    super.key,
    required this.weight,
    required this.height,
  });

  // Метод расчета ИМТ
  double _calculateBMI() {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Метод определения категории
  String _getInterpretation(double bmi) {
    if (bmi < 18.5) return 'Недостаточная масса тела';
    if (bmi < 25.0) return 'Нормальная масса тела';
    if (bmi < 30.0) return 'Избыточная масса тела';
    return 'Ожирение';
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBMI();
    final resultText = _getInterpretation(bmi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты расчета'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ваш индекс массы тела:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              bmi.toStringAsFixed(1), // Округляем до 1 знака после запятой
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            Text(
              resultText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 50),
            
            // Кнопка возврата (метод pop)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.pop(context); // Возврат на предыдущий экран
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Вернуться назад', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
