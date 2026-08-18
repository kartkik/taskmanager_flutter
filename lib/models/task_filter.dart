enum TaskFilterStatus {
  all('All'),
  pending('Pending'),
  completed('Completed');

  final String label;
  const TaskFilterStatus(this.label);
}

enum TaskSortBy {
  dueDate('Due Date'),
  priority('Priority'),
  createdAt('Created Date'),
  title('Title');

  final String label;
  const TaskSortBy(this.label);
}

enum SortOrder {
  ascending('Ascending'),
  descending('Descending');

  final String label;
  const SortOrder(this.label);
}
