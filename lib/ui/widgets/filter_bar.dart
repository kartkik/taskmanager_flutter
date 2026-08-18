import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_filter.dart';
import '../../providers/task_provider.dart';
import '../theme/app_colors.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({super.key});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => provider.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Search tasks by title or description...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        provider.clearSearch();
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Filter Chips & Sort Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Filter Status Chips
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: TaskFilterStatus.values.map((status) {
                      final isSelected = provider.filterStatus == status;
                      int count = 0;
                      if (status == TaskFilterStatus.all) {
                        count = provider.totalTasksCount;
                      } else if (status == TaskFilterStatus.pending) {
                        count = provider.pendingTasksCount;
                      } else if (status == TaskFilterStatus.completed) {
                        count = provider.completedTasksCount;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${status.label} ($count)'),
                          selected: isSelected,
                          onSelected: (_) => provider.setFilterStatus(status),
                          showCheckmark: false,
                          backgroundColor: isThemeDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : (isThemeDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Sort Dropdown Menu
              PopupMenuButton<TaskSortBy>(
                tooltip: 'Sort Options',
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      provider.sortOrder == SortOrder.ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                onSelected: (sortBy) => provider.setSortBy(sortBy),
                itemBuilder: (context) => TaskSortBy.values.map((sortBy) {
                  final isSelected = provider.sortBy == sortBy;
                  return PopupMenuItem<TaskSortBy>(
                    value: sortBy,
                    child: Row(
                      children: [
                        Text(
                          sortBy.label,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        if (isSelected) ...[
                          const Spacer(),
                          Icon(
                            provider.sortOrder == SortOrder.ascending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
