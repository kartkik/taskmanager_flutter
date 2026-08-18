import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../models/task_priority.dart';
import '../../providers/task_provider.dart';
import '../theme/app_colors.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  bool get isEditing => task != null;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  TaskPriority _selectedPriority = TaskPriority.medium;
  late DateTime _selectedDueDate;
  late TimeOfDay _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existingTask = widget.task;
    if (existingTask != null) {
      _titleController = TextEditingController(text: existingTask.title);
      _descriptionController =
          TextEditingController(text: existingTask.description);
      _selectedPriority = existingTask.priority;
      _selectedDueDate = existingTask.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(existingTask.dueDate);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDueDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 17, minute: 0); // 5:00 PM default
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime get _fullDueDateTime {
    return DateTime(
      _selectedDueDate.year,
      _selectedDueDate.month,
      _selectedDueDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<TaskProvider>();
    bool success = false;

    if (widget.isEditing) {
      final updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _fullDueDateTime,
      );
      success = await provider.updateTask(updated);
    } else {
      success = await provider.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dueDate: _fullDueDateTime,
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Task updated successfully'
                  : 'Task created successfully',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to save task'),
            backgroundColor: AppColors.priorityHigh,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Create New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              Text(
                'Task Title *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isThemeDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Enter task title...',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (val.trim().length < 3) {
                    return 'Title must be at least 3 characters long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Description Input
              Text(
                'Description (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isThemeDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add details or context about this task...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              // Priority Selector
              Text(
                'Priority Level',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isThemeDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priority.backgroundColor
                                : (isThemeDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? priority.color
                                  : (isThemeDark
                                      ? AppColors.darkCardBorder
                                      : AppColors.lightCardBorder),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                priority.icon,
                                color: priority.color,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                priority.label,
                                style: TextStyle(
                                  color: priority.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Due Date & Time Picker
              Text(
                'Due Date & Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isThemeDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Date Chip
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isThemeDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isThemeDark
                                ? AppColors.darkCardBorder
                                : AppColors.lightCardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('MMM d, yyyy').format(_selectedDueDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time Chip
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isThemeDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isThemeDark
                                ? AppColors.darkCardBorder
                                : AppColors.lightCardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Save Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'Update Task' : 'Create Task',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
