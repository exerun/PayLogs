import 'package:flutter/material.dart';

Future<String?> showCategoryPicker(BuildContext context, List<String> categories, String? selectedCategory) async {
  // Use a map to store category name to emoji
  final Map<String, String> categoryEmojiMap = {
    "food": "🍽️",
    "grocery": "🛒",
    "shopping": "🛍️",
    "transport": "🚗",
    "bike": "🏍️",
    "fuel": "⛽",
    "travel": "✈️",
    "flight": "��",
    "train": "🚆",
    "bus": "🚌",
    "taxi": "🚕",
    "car": "🚘",
    "rent": "🏠",
    "home": "🏡",
    "electricity": "💡",
    "water": "🚰",
    "internet": "🌐",
    "mobile": "📱",
    "education": "📚",
    "books": "📖",
    "stationery": "✏️",
    "health": "🩺",
    "medical": "💊",
    "hospital": "🏥",
    "insurance": "🛡️",
    "pet": "🐾",
    "dog": "🐶",
    "cat": "🐱",
    "entertainment": "🎮",
    "movie": "🎬",
    "music": "🎵",
    "games": "🕹️",
    "sports": "⚽",
    "fitness": "🏋️",
    "gym": "💪",
    "subscription": "📦",
    "netflix": "📺",
    "spotify": "🎧",
    "loan": "📄",
    "emi": "💳",
    "bank": "🏦",
    "investment": "📈",
    "salary": "💰",
    "income": "💸",
    "bonus": "🎉",
    "gift": "🎁",
    "donation": "🙏",
    "charity": "❤️",
    "clothing": "👕",
    "electronics": "💻",
    "repair": "🔧",
    "others": "🗂️"
  };
  // Store categories as a list of maps: [{name: ..., emoji: ...}]
  List<Map<String, String>> allCategories = [
    for (final c in categories)
      {
        'name': c,
        'emoji': (() {
          final lc = c.toLowerCase();
          for (final k in categoryEmojiMap.keys) {
            if (lc.contains(k)) return categoryEmojiMap[k]!;
          }
          return '📦';
        })(),
      }
  ];
  String? newCategory;
  String? result;
  while (true) {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Choose a Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 0),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allCategories.length + 1,
                itemBuilder: (_, i) {
                  if (i == allCategories.length) {
                    // Add Category tile
                    return ListTile(
                      leading: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                      title: Text('Add Category', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      onTap: () async {
                        Navigator.pop(context, '__add__');
                      },
                    );
                  }
                  final category = allCategories[i];
                  return ListTile(
                    leading: Text(category['emoji'] ?? '📦', style: const TextStyle(fontSize: 24)),
                    title: Text(category['name'] ?? ''),
                    selected: category['name'] == selectedCategory,
                    onTap: () => Navigator.pop(context, category['name']),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 0),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null) {
      result = null;
      break;
    }
    if (picked == '__add__') {
      // Show dialog to add new category
      final controller = TextEditingController();
      final saved = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add New Category'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Category name'),
              onSubmitted: (_) => Navigator.of(context).pop(controller.text.trim()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (saved != null && saved.isNotEmpty &&
          !allCategories.any((c) => c['name'] == saved)) {
       // Assign emoji based on keyword
       final lc = saved.toLowerCase();
       String emoji = '📦';
       for (final k in categoryEmojiMap.keys) {
         if (lc.contains(k)) {
           emoji = categoryEmojiMap[k]!;
           break;
         }
       }
       allCategories.add({'name': saved, 'emoji': emoji});
        newCategory = saved;
      }
      // Loop again to show updated list
    } else {
      result = picked;
      break;
    }
  }
  // If a new category was added and selected, return it
  if (newCategory != null) return newCategory;
  return result;
}

class CategorySelectorSheet extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySelectorSheet({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Deprecated: use showCategoryPicker instead
    return const SizedBox.shrink();
  }
} 