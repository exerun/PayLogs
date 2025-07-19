import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScreenshotsPage extends StatefulWidget {
  const ScreenshotsPage({super.key});

  @override
  State<ScreenshotsPage> createState() => _ScreenshotsPageState();
}

class _ScreenshotsPageState extends State<ScreenshotsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // In-memory list to store screenshot data
  final List<Map<String, dynamic>> _screenshots = [];

  void _importScreenshot() {
    // Simulate importing a new screenshot
    setState(() {
      _screenshots.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now(),
        'type': 'placeholder', // For now, all are placeholders
      });
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screenshot imported successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onScreenshotTap(int index) {
    // Placeholder function for tapping on a screenshot
    final screenshot = _screenshots[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped screenshot ${screenshot['id']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildScreenshotTile(int index) {
    final screenshot = _screenshots[index];
    final timestamp = screenshot['timestamp'] as DateTime;

    return GestureDetector(
      onTap: () => _onScreenshotTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.image,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            // Timestamp
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _formatTimestamp(timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.monitor,
            size: 64,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 16),
          Text(
            'No screenshots yet',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to import your first screenshot',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin

    return Scaffold(
      key: const PageStorageKey('screenshots'),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Screenshots',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: _screenshots.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _screenshots.length,
              itemBuilder: (context, index) => _buildScreenshotTile(index),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton.extended(
          onPressed: _importScreenshot,
          backgroundColor: Colors.orange,
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: const Text(
            'Add',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 6,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
} 