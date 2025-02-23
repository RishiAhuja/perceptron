import 'package:numd/numd.dart';

class TrainingPattern {
  final NDArray<double> input;
  final NDArray<double> expectedOutput;
  final String label;

  TrainingPattern({
    required this.input,
    required this.expectedOutput,
    required this.label,
  });
}
