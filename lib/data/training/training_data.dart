import 'package:numd/numd.dart';
import 'package:perceptron/data/training/training_pattern.dart';

final List<TrainingPattern> trainingData = [
  // Square
  TrainingPattern(
    label: 'Square',
    input: NDArray.init([
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1],
    ]),
    expectedOutput: NDArray.init([
      [1],
      [0],
      [0]
    ]),
  ),

  // Triangle
  TrainingPattern(
    label: 'Triangle',
    input: NDArray.init([
      [0, 0, 1, 0, 0],
      [0, 1, 0, 1, 0],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1],
    ]),
    expectedOutput: NDArray.init([
      [0],
      [1],
      [0]
    ]),
  ),

  // Rectangle
  TrainingPattern(
    label: 'Rectangle',
    input: NDArray.init([
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
    ]),
    expectedOutput: NDArray.init([
      [0],
      [0],
      [1]
    ]),
  ),
];
