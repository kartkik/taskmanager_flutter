import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_filter.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';
import '../repositories/task_repository.dart';
import '../services/connectivity_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySub;

  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  TaskFilterStatus _filterStatus = TaskFilterStatus.all;
  TaskSortBy _sortBy = TaskSortBy.dueDate;
  SortOrder _sortOrder = SortOrder.ascending;

  bool _isOnline = true;
  bool _isSyncing = false;

  TaskProvider({
    required TaskRepository repository,
    required ConnectivityService connectivityService,
  })  : _repository = repository,
        _connectivityService = connectivityService {
    _isOnline = _connectivityService.isOnline;
    _connectivitySub = _connectivityService.connectionStatusStream.listen((online) {
      _isOnline = online;
      notifyListeners();
      if (online) {
        refreshTasks();
      }
    });
    loadTasks();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TaskFilterStatus get filterStatus => _filterStatus;
  TaskSortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  int get totalTasksCount => _allTasks.where((t) => t.pendingAction != 'delete').length;
  int get completedTasksCount =>
      _allTasks.where((t) => t.isCompleted && t.pendingAction != 'delete').length;
  int get pendingTasksCount =>
      _allTasks.where((t) => !t.isCompleted && t.pendingAction != 'delete').length;
  int get unsyncedCount =>
      _allTasks.where((t) => !t.isSynced && t.pendingAction != 'delete').length;

  List<TaskModel> get tasks {
    // 1. Exclude pending delete tasks
    var filtered = _allTasks.where((t) => t.pendingAction != 'delete').toList();

    // 2. Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    // 3. Filter by Status
    switch (_filterStatus) {
      case TaskFilterStatus.completed:
        filtered = filtered.where((t) => t.isCompleted).toList();
        break;
      case TaskFilterStatus.pending:
        filtered = filtered.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilterStatus.all:
        break;
    }

    // 4. Sort tasks
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case TaskSortBy.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case TaskSortBy.priority:
          comparison = b.priority.rank.compareTo(a.priority.rank);
          break;
        case TaskSortBy.createdAt:
          comparison = b.createdAt.compareTo(a.createdAt);
          break;
        case TaskSortBy.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
      }

      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filtered;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTasks = await _repository.getInitialTasks();
    } catch (e) {
      _errorMessage = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTasks() async {
    try {
      _allTasks = _repository.localStorageService.getAllTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing tasks: $e');
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      _errorMessage = null;
      final newTask = await _repository.createTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      _allTasks.add(newTask);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      _errorMessage = null;
      final updatedTask = await _repository.updateTask(task);
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = updatedTask;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(TaskModel task) async {
    return await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<bool> deleteTask(String id) async {
    try {
      _errorMessage = null;
      await _repository.deleteTask(id);
      _allTasks.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> syncManual() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      await _repository.triggerManualSync();
      _allTasks = _repository.localStorageService.getAllTasks();
    } catch (e) {
      _errorMessage = 'Sync error: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(TaskFilterStatus status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSortBy(TaskSortBy sortBy) {
    if (_sortBy == sortBy) {
      // Toggle sort direction if same field is selected
      _sortOrder = _sortOrder == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending;
    } else {
      _sortBy = sortBy;
      _sortOrder = SortOrder.ascending;
    }
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
