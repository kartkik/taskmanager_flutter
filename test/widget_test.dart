import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanager/models/task_priority.dart';

void main() {
  test('TaskPriority values check', () {
    expect(TaskPriority.low.label, 'Low');
    expect(TaskPriority.medium.label, 'Medium');
    expect(TaskPriority.high.label, 'High');
    expect(TaskPriority.high.rank > TaskPriority.low.rank, isTrue);
  });
}
