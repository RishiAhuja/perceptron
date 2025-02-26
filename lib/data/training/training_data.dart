import 'package:numd/numd.dart';
import 'package:perceptron/data/training/training_pattern.dart';

final List<TrainingPattern> trainingData = [
  // Square
  TrainingPattern(
    label: 'Square 5x5',
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
    label: 'Triangle 5x5',
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
    label: 'Rectangle 5x5',
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
  )
];
final List<TrainingPattern> trainingData10x10 = [
  // Square - Perfect 10x10 square with hollow center
  TrainingPattern(
    label: 'Square',
    input: NDArray.init([
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [1, 1, 1, 0, 0, 0, 0, 1, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 1, 0, 0, 0, 0, 1, 1, 1],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
    ]),
    expectedOutput: NDArray.init([
      [1], // Square
      [0], // Triangle
      [0] // Rectangle
    ]),
  ),

  // Triangle - Symmetrical triangle with clear point and base
  TrainingPattern(
    label: 'Triangle',
    input: NDArray.init([
      [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
      [0, 1, 1, 0, 0, 0, 0, 1, 1, 0],
      [0, 1, 0, 0, 0, 0, 0, 0, 1, 0],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ]),
    expectedOutput: NDArray.init([
      [0], // Square
      [1], // Triangle
      [0] // Rectangle
    ]),
  ),

  // Rectangle - Clearly taller than wide
  TrainingPattern(
    label: 'Rectangle',
    input: NDArray.init([
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
    ]),
    expectedOutput: NDArray.init([
      [0], // Square
      [0], // Triangle
      [1] // Rectangle
    ]),
  ),
];
