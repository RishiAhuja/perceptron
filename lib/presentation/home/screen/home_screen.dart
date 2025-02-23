import 'package:flutter/material.dart';
import 'package:numd/numd.dart';
// import 'package:perceptron/core/configs/constants/app_constants.dart';
import 'package:perceptron/core/configs/theme/app_colors.dart';
import 'package:perceptron/core/widget/arrow_painter.dart';
import 'package:perceptron/data/training/shape_gen.dart';
import 'package:perceptron/data/training/training_data.dart';
import 'package:perceptron/data/training/training_pattern.dart';
import 'package:perceptron/presentation/home/widget/unit.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

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
  // final double learningRate = 1;
  int epoch = 0;
  int currentEpochVariation = 0;

  static const int ASSOCIATION_UNITS = 20;

  final double learningRate = 1;

  var association =
      NDArray<double>.init(List.generate(ASSOCIATION_UNITS, (i) => [0.0]));

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

  // var association = NDArray<double>.init([
  //   [0.0],
  //   [0.0],
  //   [0.0],
  //   [0.0],
  //   [0.0],
  // ]);

  var response = NDArray<double>.init([
    [0.0],
    [1.0],
    [0.0],
  ]);

  bool isTraining = false;
  String currentStatus = '';
  double currentAccuracy = 0.0;

  final List<FlSpot> accuracyPoints = [];
  int dataPoint = 0;

  String trainingProgress = '0%';
  String elapsedTime = '0:00';
  DateTime? trainingStartTime;
  Timer? _timer;

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
      position.dy + size.height / 40 - scaffoldPosition.dy - 40,
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

  // void generateAssociationConnections() {
  //   final random = math.Random();

  //   for (int i = 0; i < sensory.rows; i++) {
  //     for (int j = 0; j < sensory.cols; j++) {
  //       final targetRow = random.nextInt(association.rows);
  //       final sourceKey = sensoryKeys['$i-$j'];
  //       final associationTargetKey = associationKeys['$targetRow-0'];
  //       // final responseTargetKey = responseKeys['$targetRow-0'];

  //       if (sourceKey != null && associationTargetKey != null) {
  //         final sourceCenter = getWidgetCenter(sourceKey);
  //         final associationTargetCenter = getWidgetCenter(associationTargetKey);
  //         final weight = random.nextInt(2);
  //         if (sourceCenter != Offset.zero &&
  //             associationTargetCenter != Offset.zero) {
  //           associationConnections.add(Connection(
  //               sourceId: '$i-$j',
  //               targetId: '$targetRow-0',
  //               source: sourceCenter,
  //               target: associationTargetCenter,
  //               width: 1.5,
  //               weight: -5 + random.nextDouble(),
  //               color: weight == 1 ? AppColors.green : AppColors.red));
  //         }
  //       }

  //       var newAssociations = List.generate(association.rows, (index) => [0.0]);
  //       for (int i = 0; i < association.rows; i++) {
  //         double sum = 0.0;
  //         final incomingConns = getIncomingConnectionsL1('$i-0');

  //         for (var conn in incomingConns) {
  //           final sourceIndices = conn.sourceId.split('-');
  //           final sourceRow = int.parse(sourceIndices[0]);
  //           final sourceCol = int.parse(sourceIndices[1]);

  //           sum += conn.weight * sensory.at(sourceRow, sourceCol);
  //         }

  //         newAssociations[i][0] = sum > AppConstants.threshold ? 1.0 : 0.0;
  //       }

  //       association = NDArray.init(newAssociations);
  //     }
  //   }
  // }

  // void generateResponseConnections() {
  //   final random = math.Random();
  //   responseConnections.clear();

  //   List<int> availableAssociationUnits =
  //       List.generate(association.rows, (i) => i);
  //   availableAssociationUnits.shuffle(random);

  //   for (int i = 0; i < response.rows; i++) {
  //     final associationIndex = availableAssociationUnits[i];
  //     final associationSourceKey = associationKeys['$associationIndex-0'];
  //     final responseTargetKey = responseKeys['$i-0'];

  //     if (responseTargetKey != null && associationSourceKey != null) {
  //       final associationCenter = getWidgetCenter(associationSourceKey);
  //       final responseCenter = getWidgetCenter(responseTargetKey);

  //       if (associationCenter != Offset.zero && responseCenter != Offset.zero) {
  //         responseConnections.add(Connection(
  //             sourceId: '$associationIndex-0',
  //             targetId: '$i-0',
  //             source: associationCenter,
  //             target: responseCenter,
  //             width: 1.5,
  //             weight: 0 + (random.nextDouble() * (10 - 0)),
  //             color: Colors.white,
  //             showWeight: true));
  //       }
  //     }
  //   }

  //   List<int> remainingAssociationUnits =
  //       availableAssociationUnits.sublist(response.shape[0]);
  //   for (final associationIndex in remainingAssociationUnits) {
  //     final targetRow = random.nextInt(response.rows);
  //     final associationSourceKey = associationKeys['$associationIndex-0'];
  //     final responseTargetKey = responseKeys['$targetRow-0'];

  //     if (responseTargetKey != null && associationSourceKey != null) {
  //       final associationCenter = getWidgetCenter(associationSourceKey);
  //       final responseCenter = getWidgetCenter(responseTargetKey);

  //       if (associationCenter != Offset.zero && responseCenter != Offset.zero) {
  //         responseConnections.add(Connection(
  //             sourceId: '$associationIndex-0',
  //             targetId: '$targetRow-0',
  //             source: associationCenter,
  //             target: responseCenter,
  //             width: 1.5,
  //             weight: 0 + (random.nextDouble() * (10 - 0)),
  //             color: Colors.white,
  //             showWeight: true));
  //       }
  //     }
  //   }

  //   var newResponse = List.generate(response.rows, (index) => [0.0]);
  //   for (int i = 0; i < response.rows; i++) {
  //     double sum = 0.0;
  //     final incomingConns = getIncomingConnectionsL1('$i-0');

  //     for (var conn in incomingConns) {
  //       final sourceIndices = conn.sourceId.split('-');
  //       final sourceRow = int.parse(sourceIndices[0]);

  //       sum += conn.weight * association.at(sourceRow, 0);
  //     }

  //     newResponse[i][0] = sum > 0 ? 1.0 : 0.0;
  //   }

  //   response = NDArray.init(newResponse);
  // }

  void generateAssociationConnections() {
    final random = math.Random();
    associationConnections.clear();

    for (int i = 0; i < sensory.rows; i++) {
      for (int j = 0; j < sensory.cols; j++) {
        // Each sensory unit connects to about 25% of association units randomly
        int numConnections = (ASSOCIATION_UNITS * 0.25).round();
        List<int> targetUnits = List.generate(ASSOCIATION_UNITS, (i) => i);
        targetUnits.shuffle(random);
        targetUnits = targetUnits.sublist(0, numConnections);

        for (int targetUnit in targetUnits) {
          final sourceKey = sensoryKeys['$i-$j'];
          final associationTargetKey = associationKeys['$targetUnit-0'];

          if (sourceKey != null && associationTargetKey != null) {
            final sourceCenter = getWidgetCenter(sourceKey);
            final associationTargetCenter =
                getWidgetCenter(associationTargetKey);

            // Better weight initialization: small random values
            final weight = -0.5 + random.nextDouble(); // Range: -0.5 to 0.5

            if (sourceCenter != Offset.zero &&
                associationTargetCenter != Offset.zero) {
              associationConnections.add(Connection(
                  sourceId: '$i-$j',
                  targetId: '$targetUnit-0',
                  source: sourceCenter,
                  target: associationTargetCenter,
                  width: 1.5,
                  weight: weight,
                  color: weight > 0 ? AppColors.green : AppColors.red));
            }
          }
        }
      }
    }
  }

  void generateResponseConnections() {
    final random = math.Random();
    responseConnections.clear();

    // Each response unit connects to all association units
    for (int i = 0; i < response.rows; i++) {
      for (int j = 0; j < ASSOCIATION_UNITS; j++) {
        final sourceKey = associationKeys['$j-0'];
        final targetKey = responseKeys['$i-0'];

        if (sourceKey != null && targetKey != null) {
          final sourceCenter = getWidgetCenter(sourceKey);
          final targetCenter = getWidgetCenter(targetKey);

          if (sourceCenter != Offset.zero && targetCenter != Offset.zero) {
            // Small random initial weights
            final weight = -0.5 + random.nextDouble(); // Range: -0.5 to 0.5

            responseConnections.add(Connection(
                sourceId: '$j-0',
                targetId: '$i-0',
                source: sourceCenter,
                target: targetCenter,
                width: 1.5,
                weight: weight,
                color: Colors.white,
                showWeight: true));
          }
        }
      }
    }
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

  Future<void> trainOneEpoch() async {
    int correct = 0;
    int total = 0;

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
          break;
        }
      }

      if (isCorrect) correct++;

      adjustWeights(pattern);

      setState(() {
        currentAccuracy = (correct / total) * 100;
        currentStatus = 'Accuracy: ${currentAccuracy.toStringAsFixed(2)}%';

        accuracyPoints.add(FlSpot(dataPoint.toDouble(), currentAccuracy));
        dataPoint++;

        if (accuracyPoints.length > 500) {
          accuracyPoints.removeAt(0);
        }
      });
      print("Accuracy: ${currentAccuracy.toStringAsFixed(2)}%");

      // Allow UI to update periodically
      if (total % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 5));
      }
    }
  }

  // void adjustWeights(TrainingPattern pattern) {
  //   forwardPass(pattern.input);
  //   print("\n== Adjusting Weights ==");
  //   // print("Pattern: ${pattern.label}");
  //   for (int i = 0; i < response.rows; i++) {
  //     double actual = response[i][0];
  //     double expected = pattern.expectedOutput[i][0];
  //     double error = expected - actual;

  //     final incomingConns = getIncomingConnectionsL2('$i-0');

  //     for (var conn in incomingConns) {
  //       final sourceIndices = conn.sourceId.split('-');
  //       final sourceRow = int.parse(sourceIndices[0]);
  //       final associationActivity = association[sourceRow][0];

  //       int connectionIndex = responseConnections.indexWhere(
  //           (c) => c.sourceId == conn.sourceId && c.targetId == conn.targetId);

  //       if (connectionIndex != -1) {
  //         double newWeight = responseConnections[connectionIndex].weight +
  //             (learningRate * error * associationActivity);

  //         setState(() {
  //           responseConnections[connectionIndex] = Connection(
  //               sourceId: conn.sourceId,
  //               targetId: conn.targetId,
  //               source: conn.source,
  //               target: conn.target,
  //               width: conn.width,
  //               weight: newWeight,
  //               showWeight: true,
  //               color: newWeight > 0
  //                   ? AppColors.green
  //                   : newWeight < -5
  //                       ? AppColors.red
  //                       : Colors.white);
  //         });
  //       }
  //     }
  //   }
  // }

  void adjustWeights(TrainingPattern pattern) {
    forwardPass(pattern.input);

    // Adjust response layer weights
    for (int i = 0; i < response.rows; i++) {
      double actual = response[i][0];
      double expected = pattern.expectedOutput[i][0];
      double error = expected - actual;
      double delta = error * actual * (1 - actual); // Derivative of sigmoid

      final incomingConns = getIncomingConnectionsL2('$i-0');
      for (var conn in incomingConns) {
        final sourceIndices = conn.sourceId.split('-');
        final sourceRow = int.parse(sourceIndices[0]);
        final associationActivity = association[sourceRow][0];

        int connectionIndex = responseConnections.indexWhere(
            (c) => c.sourceId == conn.sourceId && c.targetId == conn.targetId);

        if (connectionIndex != -1) {
          double weightUpdate = learningRate * delta * associationActivity;
          double newWeight =
              responseConnections[connectionIndex].weight + weightUpdate;

          setState(() {
            responseConnections[connectionIndex] = Connection(
                sourceId: conn.sourceId,
                targetId: conn.targetId,
                source: conn.source,
                target: conn.target,
                width: conn.width,
                weight: newWeight,
                showWeight: true,
                color: newWeight > 0 ? AppColors.green : AppColors.red);
          });
        }
      }
    }

    // Adjust association layer weights similarly
    for (var conn in associationConnections) {
      final sourceIndices = conn.sourceId.split('-');
      final targetIndices = conn.targetId.split('-');
      final sourceRow = int.parse(sourceIndices[0]);
      final sourceCol = int.parse(sourceIndices[1]);
      final targetRow = int.parse(targetIndices[0]);

      double input = sensory[sourceRow][sourceCol];
      double output = association[targetRow][0];
      double delta = output * (1 - output); // Derivative of sigmoid
      double weightUpdate = learningRate * delta * input;

      setState(() {
        conn.weight += weightUpdate;
      });
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

  Future<void> trainNetwork(int epochs) async {
    trainingStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (trainingStartTime != null) {
        final duration = DateTime.now().difference(trainingStartTime!);
        setState(() {
          elapsedTime =
              '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });

    try {
      for (int epoch = 0; epoch < epochs; epoch++) {
        setState(() {
          trainingProgress =
              '${((epoch + 1) / epochs * 100).toStringAsFixed(1)}%';
          currentStatus = 'Training epoch ${epoch + 1}/$epochs';
        });
        await trainOneEpoch();
        await Future.delayed(const Duration(milliseconds: 10));
      }
    } finally {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("Rosenblatt's perceptron"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              currentStatus,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
        actions: [
          if (isTraining)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
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
            onPressed: isTraining
                ? null
                : () async {
                    setState(() {
                      isTraining = true;
                      currentStatus = 'Starting training...';
                    });

                    try {
                      await trainNetwork(15); // Train for 20 epochs
                    } finally {
                      setState(() {
                        isTraining = false;
                        currentStatus = 'Training completed';
                      });
                    }
                  },
            tooltip: 'Train network',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Progress indicators
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress: $trainingProgress',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: $elapsedTime',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
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
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width / 4,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          reservedSize: 30,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: accuracyPoints.isEmpty ? 0 : accuracyPoints.first.x,
                    maxX: accuracyPoints.isEmpty ? 0 : accuracyPoints.last.x,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: accuracyPoints,
                        isCurved: true,
                        color: Colors.blue,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
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
