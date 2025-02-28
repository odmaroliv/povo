import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class FilterSelector extends StatelessWidget {
  final List<AwesomeFilter> filters;
  final AwesomeFilter currentFilter;
  final Function(AwesomeFilter) onFilterSelected;

  const FilterSelector({
    Key? key,
    required this.filters,
    required this.currentFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == currentFilter;

          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Filter thumbnail
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Text(
                            _getFilterInitials(filter.name),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Filter name
                  Text(
                    _getFilterDisplayName(filter.name),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper to get filter initials
  String _getFilterInitials(String filterName) {
    if (filterName == 'None') return 'N';

    // Split by uppercase letters
    final words = filterName.split(RegExp(r'(?<=[a-z])(?=[A-Z])'));

    if (words.length == 1) {
      return filterName.substring(0, 1);
    }

    // Get first letter of each word
    return words.map((word) => word.substring(0, 1)).join('');
  }

  // Helper to get display name
  String _getFilterDisplayName(String filterName) {
    if (filterName == 'None') return 'Normal';

    // Add spaces before uppercase letters
    final displayName = filterName
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();

    return displayName;
  }
}
