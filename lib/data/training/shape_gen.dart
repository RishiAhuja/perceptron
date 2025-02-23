import 'dart:math' as math;
import 'package:numd/numd.dart';
import 'package:perceptron/data/training/training_pattern.dart';

class ShapeGenerator {
  static const int MATRIX_SIZE = 5;
  static final math.Random _random = math.Random();

  // Basic shape patterns
  static final List<List<List<double>>> squarePatterns = [
    [
      [1, 1, 1, 0, 0],
      [1, 0, 1, 0, 0],
      [1, 1, 1, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ],
    [
      [0, 1, 1, 1, 0],
      [0, 1, 0, 1, 0],
      [0, 1, 1, 1, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0, 0],
      [0, 1, 1, 1, 0],
      [0, 1, 0, 1, 0],
      [0, 1, 1, 1, 0],
      [0, 0, 0, 0, 0],
    ],
  ];

  static final List<List<List<double>>> trianglePatterns = [
    [
      [0, 0, 1, 0, 0],
      [0, 1, 0, 1, 0],
      [1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0, 0],
      [0, 0, 1, 0, 0],
      [0, 1, 0, 1, 0],
      [1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0, 0],
      [0, 1, 1, 0, 0],
      [0, 1, 0, 1, 0],
      [0, 1, 1, 1, 1],
      [0, 0, 0, 0, 0],
    ],
  ];

  static final List<List<List<double>>> rectanglePatterns = [
    [
      [1, 1, 1, 1, 0],
      [1, 0, 0, 1, 0],
      [1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ],
    [
      [1, 1, 0, 0, 0],
      [1, 0, 0, 0, 0],
      [1, 0, 0, 0, 0],
      [1, 0, 0, 0, 0],
      [1, 1, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0, 0],
      [1, 1, 1, 1, 0],
      [1, 0, 0, 1, 0],
      [1, 1, 1, 1, 0],
      [0, 0, 0, 0, 0],
    ],
  ];

  static List<TrainingPattern> generateTrainingSet(
      {int variationsPerPattern = 1000}) {
    final patterns = <TrainingPattern>[];

    // Generate variations for each base pattern
    for (var squarePattern in squarePatterns) {
      for (int i = 0; i < variationsPerPattern; i++) {
        patterns.add(_generateVariation(squarePattern, 'Square', [
          [1.0],
          [0.0],
          [0.0]
        ]));
      }
    }

    for (var trianglePattern in trianglePatterns) {
      for (int i = 0; i < variationsPerPattern; i++) {
        patterns.add(_generateVariation(trianglePattern, 'Triangle', [
          [0.0],
          [1.0],
          [0.0]
        ]));
      }
    }

    for (var rectanglePattern in rectanglePatterns) {
      for (int i = 0; i < variationsPerPattern; i++) {
        patterns.add(_generateVariation(rectanglePattern, 'Rectangle', [
          [0.0],
          [0.0],
          [1.0]
        ]));
      }
    }
    patterns.shuffle();
    return patterns;
  }

  static TrainingPattern _generateVariation(List<List<double>> basePattern,
      String label, List<List<double>> expectedOutput) {
    var matrix = List.generate(MATRIX_SIZE,
        (i) => List.generate(MATRIX_SIZE, (j) => basePattern[i][j]));

    // Apply random transformations
    if (_random.nextBool()) {
      matrix = _flipHorizontal(matrix);
    }

    if (_random.nextBool()) {
      matrix = _flipVertical(matrix);
    }

    return TrainingPattern(
        label: label,
        input: NDArray.init(matrix),
        expectedOutput: NDArray.init(expectedOutput));
  }

  static List<List<double>> _flipHorizontal(List<List<double>> matrix) {
    return List.generate(
        MATRIX_SIZE,
        (i) =>
            List.generate(MATRIX_SIZE, (j) => matrix[i][MATRIX_SIZE - 1 - j]));
  }

  static List<List<double>> _flipVertical(List<List<double>> matrix) {
    return List.generate(
        MATRIX_SIZE,
        (i) =>
            List.generate(MATRIX_SIZE, (j) => matrix[MATRIX_SIZE - 1 - i][j]));
  }
}
