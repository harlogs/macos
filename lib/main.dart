import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: MacOSDock(),
        ),
      ),
    );
  }
}

class MacOSDock extends StatefulWidget {
  @override
  _MacOSDockState createState() => _MacOSDockState();
}

class _MacOSDockState extends State<MacOSDock> {
  List<String> appIcons = [
    'assets/chrome.png',
    'assets/vscode.png',
    'assets/spotify.png',
    'assets/terminal.png',
    'assets/photos.png',
  ];

  int draggingIndex = -1; // Index of the icon being dragged
  int hoveredIndex = -1;  // Target index for hover logic
  int previousIndex = -1; // Track the original position of the dragged icon

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          appIcons.length + (draggingIndex != -1 ? 1 : 0),
          (index) {
            // Create space for hovering
            if (draggingIndex != -1 && index == hoveredIndex) {
              return const SizedBox(width: 60);
            }

            final actualIndex = draggingIndex != -1 && index > hoveredIndex
                ? index - 1
                : index;

            // Prevent out-of-bounds errors
            if (actualIndex < 0 || actualIndex >= appIcons.length) {
              return const SizedBox();
            }

            final isDragging = actualIndex == draggingIndex;

            return isDragging
                ? const SizedBox() // Hide dragged icon's space
                : Draggable<int>(
                    data: actualIndex,
                    feedback: _buildDockIcon(actualIndex, scale: 1.2),
                    childWhenDragging: const SizedBox(width: 0),
                    onDragStarted: () {
                      setState(() {
                        draggingIndex = actualIndex;
                        previousIndex = actualIndex;
                      });
                    },
                    onDragEnd: (details) {
                      setState(() {
                        // Reset if dropped outside the dock
                        if (hoveredIndex == -1) {
                          appIcons.insert(previousIndex, appIcons.removeAt(draggingIndex));
                        }
                        draggingIndex = -1;
                        hoveredIndex = -1;
                      });
                    },
                    child: DragTarget<int>(
                      onWillAccept: (draggedIndex) {
                        setState(() {
                          hoveredIndex = actualIndex;
                        });
                        return true;
                      },
                      onLeave: (_) {
                        setState(() {
                          hoveredIndex = -1;
                        });
                      },
                      onAccept: (draggedIndex) {
                        setState(() {
                          final draggedIcon = appIcons[draggedIndex];
                          appIcons.removeAt(draggedIndex);
                          appIcons.insert(actualIndex, draggedIcon); // while inserting
                          draggingIndex = -1;
                          hoveredIndex = -1;
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return MouseRegion(
                          onEnter: (_) => setState(() => hoveredIndex = actualIndex), // Slide towards left on hover
                          onExit: (_) => setState(() => hoveredIndex = -1),
                          child: _buildDockIcon(actualIndex),
                        );
                      },
                    ),
                  );
          },
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
    );
  }

  Widget _buildDockIcon(int index, {double scale = 1.0}) {
    final isHovered = index == hoveredIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: isHovered ? 80 * scale : 60 * scale,
      height: isHovered ? 80 * scale : 60 * scale,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Image.asset(appIcons[index], fit: BoxFit.contain),
    );
  }
}
