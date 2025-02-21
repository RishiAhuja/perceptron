import 'package:flutter/material.dart';
import 'package:numd/numd.dart';
import 'package:perceptron/core/configs/constants/app_constants.dart';
import 'package:perceptron/core/configs/theme/app_colors.dart';
import 'package:perceptron/core/widget/arrow_painter.dart';
import 'package:perceptron/presentation/home/widget/unit.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Connection> connections = [];
  final Map<String, GlobalKey> sensoryKeys = {};
  final Map<String, GlobalKey> associationKeys = {};
  bool isGeneratingConnections = false;

  var sensory = NDArray.init([
    [1, 0, 1],
    [0, 1, 0],
    [0, 1, 0],
    [0, 1, 0],
    [0, 1, 0],
  ]);

  var association = NDArray.init([
    [0],
    [0],
    [0],
    [0],
    [0],
  ]);

  @override
  void initState() {
    super.initState();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateRandomConnections();
    });
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

  void generateRandomConnections() {
    if (isGeneratingConnections) return;
    isGeneratingConnections = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      final random = math.Random();

      setState(() {
        connections.clear();

        for (int i = 0; i < sensory.rows; i++) {
          for (int j = 0; j < sensory.cols; j++) {
            final targetRow = random.nextInt(association.rows);
            final sourceKey = sensoryKeys['$i-$j'];
            final targetKey = associationKeys['$targetRow-0'];

            if (sourceKey != null && targetKey != null) {
              final sourceCenter = getWidgetCenter(sourceKey);
              final targetCenter = getWidgetCenter(targetKey);

              if (sourceCenter != Offset.zero && targetCenter != Offset.zero) {
                connections.add(Connection(
                  sourceId: '$i-$j',
                  targetId: '$targetRow-0',
                  source: sourceCenter,
                  target: targetCenter,
                  color: Colors.white.withOpacity(0.7),
                  width: 1.5,
                  weight: random.nextInt(2),
                ));
              }
            }

            var newAssociations =
                List.generate(association.rows, (index) => [0.0]);
            for (int i = 0; i < association.rows; i++) {
              double sum = 0.0;
              final incomingConns = getIncomingConnections('$i-0');

              for (var conn in incomingConns) {
                final sourceIndices = conn.sourceId.split('-');
                final sourceRow = int.parse(sourceIndices[0]);
                final sourceCol = int.parse(sourceIndices[1]);

                sum += conn.weight * sensory.at(sourceRow, sourceCol);
              }

              newAssociations[i][0] = sum > AppConstants.threshold ? 1.0 : 0.0;
            }

            // Update association NDArray
            association = NDArray.init(newAssociations
                .map((row) => row.map((value) => value.round()).toList())
                .toList());
          }
        }

        for (var connection in connections) {
          print(connection.toString());
        }

        isGeneratingConnections = false;
      });
    });
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
              '${connections.length} connections',
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
        ],
      ),
      body: Stack(
        children: [
          if (connections.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: NetworkPainter(connections: connections),
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
                            connections: getConnectionsForUnit('$i-$j'),
                            onHover: (isHovered) {
                              if (isHovered) {
                                print("=========================");

                                print('Connections for unit $i-$j:');
                                for (var conn
                                    in getConnectionsForUnit('$i-$j')) {
                                  print(conn.toString());
                                }
                                print("=========================");
                              }
                            },
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
                            connections: getConnectionsForUnit('$i-$j'),
                            onHover: (isHovered) {
                              if (isHovered) {
                                print("=========================");
                                print('Connections for unit $i-$j:');
                                for (var conn
                                    in getConnectionsForUnit('$i-$j')) {
                                  print(conn.toString());
                                }
                                print("=========================");
                              }
                            },
                            key: associationKeys['$i-$j'],
                            value: association.at(i, j).toDouble(),
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

  List<Connection> getConnectionsForUnit(String unitId) {
    return connections
        .where((conn) => conn.sourceId == unitId || conn.targetId == unitId)
        .toList();
  }

  List<Connection> getOutgoingConnections(String unitId) {
    return connections.where((conn) => conn.sourceId == unitId).toList();
  }

  List<Connection> getIncomingConnections(String unitId) {
    return connections.where((conn) => conn.targetId == unitId).toList();
  }
}

class Connection {
  final String sourceId; // Add source unit ID
  final String targetId; // Add target unit ID
  final Offset source;
  final Offset target;
  final Color? color;
  final double width;
  final int weight;

  Connection({
    required this.sourceId,
    required this.targetId,
    required this.source,
    required this.target,
    this.color = Colors.white,
    this.width = 2.0,
    required this.weight,
  });

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
        color: connection.weight == 1 ? AppColors.green : AppColors.red,
        strokeWidth: connection.width,
      );
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
