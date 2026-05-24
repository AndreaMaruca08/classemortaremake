import 'package:flutter/material.dart';
import 'grade.dart';
import 'grade_service.dart';

class IpotetichePage extends StatefulWidget {
  final List<Grade> voti;
  const IpotetichePage({
    super.key,
    required this.voti,
  });

  @override
  State<IpotetichePage> createState() => _IpotetichePageState();
}

class _IpotetichePageState extends State<IpotetichePage> {
  final List<double?> _newSelectedGrades = [];

  double _initialSum = 0.0;
  int _initialCount = 0;
  double _initialAverage = 0.0;

  double _hypotheticalAverage = 0.0;

  final List<double> _availableGrades =
  List.generate(21, (index) => index * 0.5);

  @override
  void initState() {
    super.initState();

    _addGradeField();

    for (var grade in widget.voti) {
      if (!grade.isCanceled) {
        _initialSum += grade.value;
        _initialCount++;
      }
    }
    _initialAverage =
    _initialCount > 0 ? _initialSum / _initialCount : 0.0;
    _hypotheticalAverage = _initialAverage;
  }

  void _addGradeField() {
    if (_newSelectedGrades.length < 10) {
      setState(() {
        _newSelectedGrades.add(null);
      });
      _calculateAverage();
    }
  }

  void _removeGradeField() {
    if (_newSelectedGrades.length > 1) {
      setState(() {
        _newSelectedGrades.removeLast();
        _calculateAverage();
      });
    }
  }

  void _calculateAverage() {
    double dynamicGradesSum = 0.0;
    int dynamicGradesCount = 0;

    for (final grade in _newSelectedGrades) {
      if (grade != null) {
        dynamicGradesSum += grade;
        dynamicGradesCount++;
      }
    }

    final newTotalSum = _initialSum + dynamicGradesSum;
    final newTotalCount = _initialCount + dynamicGradesCount;

    setState(() {
      _hypotheticalAverage =
      newTotalCount > 0 ? newTotalSum / newTotalCount : _initialAverage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medie Ipotetiche'),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.grey[900],
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'MEDIA IPOTETICA FINALE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          key: ValueKey<String>(
                              _hypotheticalAverage.toStringAsFixed(2)),
                          _hypotheticalAverage.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: GradeService.getGradeColor(_hypotheticalAverage),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aggiungi i voti che pensi di prendere:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _newSelectedGrades.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: DropdownButtonFormField<double>(
                      value: _newSelectedGrades[index],
                      hint: Text('Seleziona voto ${index + 1}'),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.calculate_outlined),
                      ),
                      items: _availableGrades.map((double value) {
                        return DropdownMenuItem<double>(
                          value: value,
                          child: Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: GradeService.getGradeColor(value),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (double? newValue) {
                        setState(() {
                          _newSelectedGrades[index] = newValue;
                        });
                        _calculateAverage();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.tonal(
                    onPressed: _newSelectedGrades.length > 1 ? _removeGradeField : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.3),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.remove),
                        SizedBox(width: 8),
                        Text('Rimuovi'),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _newSelectedGrades.length < 10 ? _addGradeField : null,
                    child: const Row(
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('Aggiungi'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}