import 'package:flutter/material.dart';
import 'package:numd/numd.dart';
import 'package:perceptron/core/configs/constants/app_constants.dart';
import 'package:perceptron/core/configs/theme/app_colors.dart';
import 'package:perceptron/core/widget/arrow_painter.dart';
import 'package:perceptron/data/training/shape_gen.dart';
import 'package:perceptron/data/training/training_data.dart';
import 'package:perceptron/data/training/training_pattern.dart';
import 'package:perceptron/presentation/home/widget/unit.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Connection> associationConnections = [];
  final List<Connection> responseConnections = [];
  final Map<String, GlobalKey> sensoryKeys = {};
  final Map<String, GlobalKey> associationKeys = {};
  final Map<String, GlobalKey> responseKeys = {};
  bool isGeneratingConnections = false;
  final double learningRate = 1;
  int epoch = 0;
  int currentEpochVariation = 0;

  var sensory = NDArray<double>.init([
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
  ]);

  var association = NDArray<double>.init([
    [0.0],
    [0.0],
    [0.0],
    [0.0],
    [0.0],
  ]);

  var response = NDArray<double>.init([
    [0.0],
    [1.0],
    [0.0],
  ]);

  @override
  void initState() {
    super.initState();
    // generateTrainingVariations();
    trainingData.addAll(ShapeGenerator.generateTrainingSet());
    for (int i = 0; i < sensory.rows; i++) {
      for (int j = 0; j < sensory.cols; j++) {
        sensoryKeys['$i-$j'] = GlobalKey();
      }
    }

    for (int i = 0; i < association.rows; i++) {
      for (int j = 0; j < association.cols; j++) {
        associationKeys['$i-$j'] = GlobalKey();
      }
    }

    for (int i = 0; i < response.rows; i++) {
      for (int j = 0; j < response.cols; j++) {
        responseKeys['$i-$j'] = GlobalKey();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateRandomConnections();
    });
  }

  double sigmoid(double x) {
    return 1.0 / (1.0 + math.exp(-x));
  }

  Offset getWidgetCenter(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;

    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final RenderBox? scaffoldBox = context.findRenderObject() as RenderBox?;
    final Offset scaffoldPosition =
        scaffoldBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    return Offset(
      position.dx + size.width / 2,
      position.dy + size.height / 25 - scaffoldPosition.dy - 25,
    );
  }

  NDArray<double> addNoise(NDArray<double> original, double noiseProbability) {
    final random = math.Random();
    var noisy = NDArray.copy(original);

    for (int i = 0; i < noisy.rows; i++) {
      for (int j = 0; j < noisy.cols; j++) {
        if (random.nextDouble() < noiseProbability) {
          noisy[i][j] = noisy[i][j] == 1 ? 0 : 1;
        }
      }
    }
    return noisy;
  }

  void generateTrainingVariations() {
    final variations = <TrainingPattern>[];

    for (var pattern in trainingData) {
      for (int i = 0; i < 20; i++) {
        variations.add(TrainingPattern(
          label: '${pattern.label}_variation_$i',
          input: addNoise(pattern.input, 0.1),
          expectedOutput: pattern.expectedOutput,
        ));
      }
    }

    trainingData.addAll(variations);
  }

  void generateRandomConnections() {
    if (isGeneratingConnections) return;
    isGeneratingConnections = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        associationConnections.clear();
        responseConnections.clear();
        generateAssociationConnections();
        generateResponseConnections();
        isGeneratingConnections = false;
      });
    });
  }

  void generateAssociationConnections() {
    final random = math.Random();

    for (int i = 0; i < sensory.rows; i++) {
      for (int j = 0; j < sensory.cols; j++) {
        final targetRow = random.nextInt(association.rows);
        final sourceKey = sensoryKeys['$i-$j'];
        final associationTargetKey = associationKeys['$targetRow-0'];
        // final responseTargetKey = responseKeys['$targetRow-0'];

        if (sourceKey != null && associationTargetKey != null) {
          final sourceCenter = getWidgetCenter(sourceKey);
          final associationTargetCenter = getWidgetCenter(associationTargetKey);
          final weight = random.nextInt(2);
          if (sourceCenter != Offset.zero &&
              associationTargetCenter != Offset.zero) {
            associationConnections.add(Connection(
                sourceId: '$i-$j',
                targetId: '$targetRow-0',
                source: sourceCenter,
                target: associationTargetCenter,
                width: 1.5,
                weight: -5 + random.nextDouble(),
                color: weight == 1 ? AppColors.green : AppColors.red));
          }
        }

        var newAssociations = List.generate(association.rows, (index) => [0.0]);
        for (int i = 0; i < association.rows; i++) {
          double sum = 0.0;
          final incomingConns = getIncomingConnectionsL1('$i-0');

          for (var conn in incomingConns) {
            final sourceIndices = conn.sourceId.split('-');
            final sourceRow = int.parse(sourceIndices[0]);
            final sourceCol = int.parse(sourceIndices[1]);

            sum += conn.weight * sensory.at(sourceRow, sourceCol);
          }

          newAssociations[i][0] = sum > AppConstants.threshold ? 1.0 : 0.0;
        }

        association = NDArray.init(newAssociations);
      }
    }
  }

  void generateResponseConnections() {
    final random = math.Random();
    responseConnections.clear();

    List<int> availableAssociationUnits =
        List.generate(association.rows, (i) => i);
    availableAssociationUnits.shuffle(random);

    for (int i = 0; i < response.rows; i++) {
      final associationIndex = availableAssociationUnits[i];
      final associationSourceKey = associationKeys['$associationIndex-0'];
      final responseTargetKey = responseKeys['$i-0'];

      if (responseTargetKey != null && associationSourceKey != null) {
        final associationCenter = getWidgetCenter(associationSourceKey);
        final responseCenter = getWidgetCenter(responseTargetKey);

        if (associationCenter != Offset.zero && responseCenter != Offset.zero) {
          responseConnections.add(Connection(
              sourceId: '$associationIndex-0',
              targetId: '$i-0',
              source: associationCenter,
              target: responseCenter,
              width: 1.5,
              weight: 0 + (random.nextDouble() * (10 - 0)),
              color: Colors.white,
              showWeight: true));
        }
      }
    }

    List<int> remainingAssociationUnits =
        availableAssociationUnits.sublist(response.shape[0]);
    for (final associationIndex in remainingAssociationUnits) {
      final targetRow = random.nextInt(response.rows);
      final associationSourceKey = associationKeys['$associationIndex-0'];
      final responseTargetKey = responseKeys['$targetRow-0'];

      if (responseTargetKey != null && associationSourceKey != null) {
        final associationCenter = getWidgetCenter(associationSourceKey);
        final responseCenter = getWidgetCenter(responseTargetKey);

        if (associationCenter != Offset.zero && responseCenter != Offset.zero) {
          responseConnections.add(Connection(
              sourceId: '$associationIndex-0',
              targetId: '$targetRow-0',
              source: associationCenter,
              target: responseCenter,
              width: 1.5,
              weight: 0 + (random.nextDouble() * (10 - 0)),
              color: Colors.white,
              showWeight: true));
        }
      }
    }

    var newResponse = List.generate(response.rows, (index) => [0.0]);
    for (int i = 0; i < response.rows; i++) {
      double sum = 0.0;
      final incomingConns = getIncomingConnectionsL1('$i-0');

      for (var conn in incomingConns) {
        final sourceIndices = conn.sourceId.split('-');
        final sourceRow = int.parse(sourceIndices[0]);

        sum += conn.weight * association.at(sourceRow, 0);
      }

      newResponse[i][0] = sum > 0 ? 1.0 : 0.0;
    }

    response = NDArray.init(newResponse);
  }

  void forwardPass(NDArray input) {
    for (int i = 0; i < association.rows; i++) {
      double sum = 0.0;
      final incomingConns = getIncomingConnectionsL1('$i-0');

      for (var conn in incomingConns) {
        final sourceIndices = conn.sourceId.split('-');
        final sourceRow = int.parse(sourceIndices[0]);
        final sourceCol = int.parse(sourceIndices[1]);
        sum += conn.weight * input.at(sourceRow, sourceCol);
      }

      association[i][0] = sigmoid(sum);
    }

    for (int i = 0; i < response.rows; i++) {
      double sum = 0.0;
      final incomingConns = getIncomingConnectionsL2('$i-0');

      for (var conn in incomingConns) {
        final sourceIndices = conn.sourceId.split('-');
        final sourceRow = int.parse(sourceIndices[0]);
        sum += conn.weight * association.at(sourceRow, 0);
      }

      response[i][0] = sigmoid(sum);
    }
  }

  void testPattern(TrainingPattern pattern) {
    sensory = pattern.input;
    forwardPass(pattern.input);
    setState(() {});
    print('Testing pattern: ${pattern.label}');
    print('Expected output: ${pattern.expectedOutput}');
    print('Actual output: $response');
  }

  void trainOneEpoch() {
    int correct = 0;
    int total = 0;
    print("\n=== Starting New Epoch ===");
    print("Training data size: ${trainingData.length}");
    for (var pattern in trainingData) {
      setState(() {
        sensory = pattern.input;
      });
      total++;
      forwardPass(pattern.input);

      bool isCorrect = true;
      for (int i = 0; i < response.rows; i++) {
        double predicted = response[i][0] > 0.5 ? 1.0 : 0.0;
        double expected = pattern.expectedOutput[i][0];

        if ((predicted > 0.5 && expected < 0.5) ||
            (predicted < 0.5 && expected > 0.5)) {
          isCorrect = false;
          print(
              "Incorrect prediction at output $i: predicted=$predicted, expected=$expected");
          break;
        }
      }

      if (isCorrect) correct++;

      // print('Training pattern: ${pattern.label}');
      // print('Expected: ${pattern.expectedOutput}');
      // print('Actual (raw): $response');
      List<double> thresholdedResponse = [];
      for (int i = 0; i < response.rows; i++) {
        thresholdedResponse.add(response[i][0] > 0.5 ? 1.0 : 0.0);
      }
      // print('Actual (thresholded): $thresholdedResponse');

      adjustWeights(pattern);
      print('Epoch accuracy: ${(correct / total * 100).toStringAsFixed(2)}%');
    }

    print('Epoch accuracy: ${(correct / total * 100).toStringAsFixed(2)}%');
  }

  void adjustWeights(TrainingPattern pattern) {
    forwardPass(pattern.input);
    print("\n== Adjusting Weights ==");
    // print("Pattern: ${pattern.label}");
    for (int i = 0; i < response.rows; i++) {
      double actual = response[i][0];
      double expected = pattern.expectedOutput[i][0];
      double error = expected - actual;

      final incomingConns = getIncomingConnectionsL2('$i-0');

      for (var conn in incomingConns) {
        final sourceIndices = conn.sourceId.split('-');
        final sourceRow = int.parse(sourceIndices[0]);
        final associationActivity = association[sourceRow][0];

        int connectionIndex = responseConnections.indexWhere(
            (c) => c.sourceId == conn.sourceId && c.targetId == conn.targetId);

        if (connectionIndex != -1) {
          double newWeight = responseConnections[connectionIndex].weight +
              (learningRate * error * associationActivity);

          setState(() {
            responseConnections[connectionIndex] = Connection(
                sourceId: conn.sourceId,
                targetId: conn.targetId,
                source: conn.source,
                target: conn.target,
                width: conn.width,
                weight: newWeight,
                showWeight: true,
                color: newWeight > 0
                    ? AppColors.green
                    : newWeight < -5
                        ? AppColors.red
                        : Colors.white);
          });
        }
      }
    }
  }

  void predictPattern(NDArray<double> userInput) {
    setState(() {
      sensory = userInput;
    });

    forwardPass(userInput);

    List<double> thresholdedResponse = [];
    String prediction = "";

    for (int i = 0; i < response.rows; i++) {
      thresholdedResponse.add(response[i][0] > 0.5 ? 1.0 : 0.0);
    }

    if (thresholdedResponse[0] == 1) {
      prediction = "Square";
    } else if (thresholdedResponse[1] == 1) {
      prediction = "Triangle";
    } else if (thresholdedResponse[2] == 1) {
      prediction = "Rectangle";
    } else {
      prediction = "Unknown Shape";
    }

    print('Network prediction: $prediction');
    print('Raw outputs: $response');
    print('Thresholded outputs: $thresholdedResponse');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Rosenblatt's perceptron"),
        actions: [
          Center(
            child: Text(
              '${associationConnections.length + responseConnections.length} connections',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isGeneratingConnections = false;
              });
              Future.delayed(const Duration(milliseconds: 200), () {
                generateRandomConnections();
              });
            },
            tooltip: 'Regenerate connections',
          ),
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              setState(() {
                isGeneratingConnections = false;
              });
              Future.delayed(const Duration(milliseconds: 200), () {
                predictPattern(sensory);
              });
            },
            tooltip: 'Regenerate connections',
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              for (int i = 0; i < 5; i++) {
                // print('Epoch ${i + 1}');
                trainOneEpoch();
              }
            },
            tooltip: 'Test network',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (associationConnections.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: NetworkPainter(connections: associationConnections),
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
              ),
            ),
          if (responseConnections.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: NetworkPainter(connections: responseConnections),
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sensory.rows,
                  (i) => Row(
                    children: List.generate(
                      sensory.cols,
                      (j) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Unit(
                            onClick: () {
                              setState(() {
                                sensory[i][j] =
                                    sensory.at(i, j) == 0.0 ? 1.0 : 0.0;
                              });
                            },
                            connections: getConnectionsForUnitL1('$i-$j'),
                            // onHover: (isHovered) {
                            //   if (isHovered) {
                            //     print("=========================");

                            //     print('Connections for unit $i-$j:');
                            //     for (var conn
                            //         in getConnectionsForUnitL1('$i-$j')) {
                            //       print(conn.toString());
                            //     }
                            //     print("=========================");
                            //   }
                            // },
                            key: sensoryKeys['$i-$j'],
                            value: sensory.at(i, j).toDouble(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  association.rows,
                  (i) => Row(
                    children: List.generate(
                      association.cols,
                      (j) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Unit(
                            onClick: () {
                              print('Clicked on unit $i-$j');
                            },
                            connections: getConnectionsForUnitL1('$i-$j'),
                            // onHover: (isHovered) {
                            //   if (isHovered) {
                            //     print("=========================");
                            //     print('Connections for unit $i-$j:');
                            //     for (var conn
                            //         in getConnectionsForUnitL1('$i-$j')) {
                            //       print(conn.toString());
                            //     }
                            //     print("=========================");
                            //   }
                            // },
                            key: associationKeys['$i-$j'],
                            value: association.at(i, j).toDouble(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  response.rows,
                  (i) => Row(
                    children: List.generate(
                      response.cols,
                      (j) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Unit(
                            onClick: () {
                              print('Clicked on unit $i-$j');
                            },
                            connections: getConnectionsForUnitL1('$i-$j'),
                            key: responseKeys['$i-$j'],
                            value: response.at(i, j).toDouble(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Connection> getConnectionsForUnitL1(String unitId) {
    return associationConnections
        .where((conn) => conn.sourceId == unitId || conn.targetId == unitId)
        .toList();
  }

  List<Connection> getOutgoingConnectionsL1(String unitId) {
    return associationConnections
        .where((conn) => conn.sourceId == unitId)
        .toList();
  }

  List<Connection> getIncomingConnectionsL1(String unitId) {
    return associationConnections
        .where((conn) => conn.targetId == unitId)
        .toList();
  }

  List<Connection> getConnectionsForUnitL2(String unitId) {
    return responseConnections
        .where((conn) => conn.sourceId == unitId || conn.targetId == unitId)
        .toList();
  }

  List<Connection> getOutgoingConnectionsL2(String unitId) {
    return responseConnections
        .where((conn) => conn.sourceId == unitId)
        .toList();
  }

  List<Connection> getIncomingConnectionsL2(String unitId) {
    return responseConnections
        .where((conn) => conn.targetId == unitId)
        .toList();
  }
}

class Connection {
  final String sourceId;
  final String targetId;
  final Offset source;
  final Offset target;
  final Color color;
  final double width;
  double weight;
  final bool showWeight;

  Connection({
    required this.sourceId,
    required this.targetId,
    required this.source,
    required this.target,
    required this.color,
    this.width = 5.0,
    required this.weight,
    this.showWeight = false,
  });

  void updateWeight(double newWeight) {
    weight = newWeight;
  }

  @override
  String toString() {
    return 'Connection(sourceId: $sourceId, targetId: $targetId, '
        'source: (${source.dx.toStringAsFixed(2)}, ${source.dy.toStringAsFixed(2)}), '
        'target: (${target.dx.toStringAsFixed(2)}, ${target.dy.toStringAsFixed(2)}), '
        'weight: $weight)';
  }
}

class NetworkPainter extends CustomPainter {
  final List<Connection> connections;

  NetworkPainter({required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    for (var connection in connections) {
      final painter = ArrowPainter(
          start: connection.source,
          end: connection.target,
          color: connection.color,
          strokeWidth: connection.width,
          weight: connection.weight.toDouble(),
          showWeight: connection.showWeight);
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
