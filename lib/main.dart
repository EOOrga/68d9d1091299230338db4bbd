import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appName = 'DREISER RENEE LILIANE';
const developerName = 'DREISER RENEE LILIANE';
const supportEmail = 'support@dreiser-renee-liliane.com';
const _screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

const _ink = Color(0xFF334053);
const _steel = Color(0xFF4E596F);
const _teal = Color(0xFF0F8B8D);
const _amber = Color(0xFFC2872B);
const _paper = Color(0xFFF6F8FB);
const _mist = Color(0xFFE7EDF3);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = _screenshotMode
      ? AppState.screenshot()
      : await AppState.load(OperationsRepository());
  runApp(DreiserOpsApp(state: state));
}

class DreiserOpsApp extends StatelessWidget {
  const DreiserOpsApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          home: OperationsShell(state: state),
        );
      },
    );
  }
}

ThemeData _buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: _ink,
        brightness: Brightness.light,
      ).copyWith(
        primary: _ink,
        onPrimary: Colors.white,
        secondary: _teal,
        onSecondary: Colors.white,
        tertiary: _amber,
        surface: _paper,
        surfaceContainerHighest: _mist,
        outline: _steel.withValues(alpha: 0.42),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: _paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: _paper,
      foregroundColor: _ink,
      centerTitle: false,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: _teal.withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : null,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _ink.withValues(alpha: 0.08)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _ink.withValues(alpha: 0.14)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

enum WorkType { container, incident, supply, appointment }

extension WorkTypeDetails on WorkType {
  String get label {
    return switch (this) {
      WorkType.container => 'Container tracking',
      WorkType.incident => 'Incident report',
      WorkType.supply => 'Supply order',
      WorkType.appointment => 'Appointment',
    };
  }

  String get shortLabel {
    return switch (this) {
      WorkType.container => 'Container',
      WorkType.incident => 'Incident',
      WorkType.supply => 'Supply',
      WorkType.appointment => 'Appointment',
    };
  }

  IconData get icon {
    return switch (this) {
      WorkType.container => Icons.inventory_2_outlined,
      WorkType.incident => Icons.report_problem_outlined,
      WorkType.supply => Icons.local_shipping_outlined,
      WorkType.appointment => Icons.event_available_outlined,
    };
  }
}

enum WorkStatus { open, scheduled, awaiting, complete }

extension WorkStatusDetails on WorkStatus {
  String get label {
    return switch (this) {
      WorkStatus.open => 'Open',
      WorkStatus.scheduled => 'Scheduled',
      WorkStatus.awaiting => 'Awaiting',
      WorkStatus.complete => 'Complete',
    };
  }

  Color get color {
    return switch (this) {
      WorkStatus.open => _teal,
      WorkStatus.scheduled => _ink,
      WorkStatus.awaiting => _amber,
      WorkStatus.complete => const Color(0xFF2E7D55),
    };
  }
}

enum WorkPriority { routine, elevated, urgent }

extension WorkPriorityDetails on WorkPriority {
  String get label {
    return switch (this) {
      WorkPriority.routine => 'Routine',
      WorkPriority.elevated => 'Elevated',
      WorkPriority.urgent => 'Urgent',
    };
  }
}

class WorkItem {
  WorkItem({
    required this.id,
    required this.type,
    required this.title,
    required this.reference,
    required this.owner,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final WorkType type;
  final String title;
  final String reference;
  final String owner;
  final DateTime dueDate;
  final WorkStatus status;
  final WorkPriority priority;
  final String notes;
  final DateTime createdAt;

  WorkItem copyWith({
    String? title,
    String? reference,
    String? owner,
    DateTime? dueDate,
    WorkStatus? status,
    WorkPriority? priority,
    String? notes,
  }) {
    return WorkItem(
      id: id,
      type: type,
      title: title ?? this.title,
      reference: reference ?? this.reference,
      owner: owner ?? this.owner,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'reference': reference,
      'owner': owner,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkItem.fromJson(Map<String, Object?> json) {
    return WorkItem(
      id: json['id'] as String,
      type: WorkType.values.byName(json['type'] as String),
      title: json['title'] as String,
      reference: json['reference'] as String,
      owner: json['owner'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: WorkStatus.values.byName(json['status'] as String),
      priority: WorkPriority.values.byName(json['priority'] as String),
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OperatorSettings {
  const OperatorSettings({
    required this.siteLabel,
    required this.coordinator,
    required this.highlightDueItems,
  });

  final String siteLabel;
  final String coordinator;
  final bool highlightDueItems;

  static const fallback = OperatorSettings(
    siteLabel: 'Main operations desk',
    coordinator: 'Operations lead',
    highlightDueItems: true,
  );

  OperatorSettings copyWith({
    String? siteLabel,
    String? coordinator,
    bool? highlightDueItems,
  }) {
    return OperatorSettings(
      siteLabel: siteLabel ?? this.siteLabel,
      coordinator: coordinator ?? this.coordinator,
      highlightDueItems: highlightDueItems ?? this.highlightDueItems,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'siteLabel': siteLabel,
      'coordinator': coordinator,
      'highlightDueItems': highlightDueItems,
    };
  }

  factory OperatorSettings.fromJson(Map<String, Object?> json) {
    return OperatorSettings(
      siteLabel: json['siteLabel'] as String? ?? fallback.siteLabel,
      coordinator: json['coordinator'] as String? ?? fallback.coordinator,
      highlightDueItems:
          json['highlightDueItems'] as bool? ?? fallback.highlightDueItems,
    );
  }
}

class OperationsRepository {
  static const _itemsKey = 'dreiser_ops_items_v1';
  static const _settingsKey = 'dreiser_ops_settings_v1';

  Future<List<WorkItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (entry) => WorkItem.fromJson(Map<String, Object?>.from(entry as Map)),
        )
        .toList();
  }

  Future<OperatorSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return OperatorSettings.fallback;
    }
    return OperatorSettings.fromJson(
      Map<String, Object?>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> saveItems(List<WorkItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itemsKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> saveSettings(OperatorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}

class AppState extends ChangeNotifier {
  AppState._({
    required List<WorkItem> items,
    required OperatorSettings settings,
    OperationsRepository? repository,
  }) : _items = items,
       _settings = settings,
       _repository = repository {
    _sortItems();
  }

  final OperationsRepository? _repository;
  List<WorkItem> _items;
  OperatorSettings _settings;

  List<WorkItem> get items => List.unmodifiable(_items);
  OperatorSettings get settings => _settings;

  static Future<AppState> load(OperationsRepository repository) async {
    final items = await repository.loadItems();
    final settings = await repository.loadSettings();
    return AppState._(
      items: items.isEmpty ? _starterItems() : items,
      settings: settings,
      repository: repository,
    );
  }

  factory AppState.screenshot() {
    return AppState._(
      items: _screenshotItems(),
      settings: const OperatorSettings(
        siteLabel: 'North dock operations',
        coordinator: 'Renee desk',
        highlightDueItems: true,
      ),
    );
  }

  factory AppState.emptyForTest() {
    return AppState._(items: [], settings: OperatorSettings.fallback);
  }

  int countByStatus(WorkStatus status) {
    return _items.where((item) => item.status == status).length;
  }

  List<WorkItem> byType(WorkType type) {
    return _items.where((item) => item.type == type).toList();
  }

  List<WorkItem> dueSoon({int limit = 4}) {
    final today = DateTime.now();
    return _items
        .where((item) => item.status != WorkStatus.complete)
        .where((item) => item.dueDate.difference(today).inDays <= 7)
        .take(limit)
        .toList();
  }

  void upsertItem(WorkItem item) {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      _items = [item, ..._items];
    } else {
      _items[index] = item;
    }
    _sortItems();
    notifyListeners();
    _saveItems();
  }

  void updateStatus(String id, WorkStatus status) {
    _items = [
      for (final item in _items)
        if (item.id == id) item.copyWith(status: status) else item,
    ];
    _sortItems();
    notifyListeners();
    _saveItems();
  }

  void deleteItem(String id) {
    _items = _items.where((item) => item.id != id).toList();
    notifyListeners();
    _saveItems();
  }

  void updateSettings(OperatorSettings settings) {
    _settings = settings;
    notifyListeners();
    if (_repository != null) {
      unawaited(_repository.saveSettings(settings));
    }
  }

  void _sortItems() {
    _items.sort((a, b) {
      final statusCompare = a.status.index.compareTo(b.status.index);
      if (statusCompare != 0) {
        return statusCompare;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  void _saveItems() {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    unawaited(repository.saveItems(_items));
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key, required this.state});

  final AppState state;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        state: widget.state,
        onCreate: _openCreate,
        onOpenItem: _openDetail,
      ),
      WorkQueueScreen(
        state: widget.state,
        onCreate: _openCreate,
        onOpenItem: _openDetail,
      ),
      AppointmentScreen(
        state: widget.state,
        onCreate: () => _openCreate(WorkType.appointment),
        onOpenItem: _openDetail,
      ),
      SettingsScreen(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'docs/icon.png',
              width: 34,
              height: 34,
              semanticLabel: '$appName icon',
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Work',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _openCreate(WorkType type) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => WorkItemForm(state: widget.state, initialType: type),
      ),
    );
  }

  Future<void> _openDetail(WorkItem item) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => WorkItemDetailScreen(state: widget.state, item: item),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.state,
    required this.onCreate,
    required this.onOpenItem,
  });

  final AppState state;
  final ValueChanged<WorkType> onCreate;
  final ValueChanged<WorkItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final dueSoon = state.dueSoon();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _HeroPanel(settings: state.settings),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: WorkType.values
              .map(
                (type) => _QuickActionButton(
                  type: type,
                  onPressed: () => onCreate(type),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'Operations snapshot',
          actionLabel: '${state.items.length} active records',
        ),
        const SizedBox(height: 10),
        _MetricGrid(state: state),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'Due next',
          actionLabel: state.settings.highlightDueItems ? 'Highlighted' : null,
        ),
        const SizedBox(height: 10),
        if (dueSoon.isEmpty)
          const _EmptyState(
            icon: Icons.done_all_outlined,
            title: 'No near-term work',
            message:
                'Add containers, orders, reports, or bookings as they come in.',
          )
        else
          ...dueSoon.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkItemTile(item: item, onTap: () => onOpenItem(item)),
            ),
          ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.settings});

  final OperatorSettings settings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 174,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('docs/featured.png', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _ink.withValues(alpha: 0.92),
                    _ink.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    settings.siteLabel,
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daily operations desk',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track containers, reports, supplies, and appointments from one local workspace.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.type, required this.onPressed});

  final WorkType type;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 42) / 2,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(type.icon),
        label: Text(type.shortLabel, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric('Open', state.countByStatus(WorkStatus.open), _teal),
      _Metric('Scheduled', state.countByStatus(WorkStatus.scheduled), _ink),
      _Metric('Awaiting', state.countByStatus(WorkStatus.awaiting), _amber),
      _Metric(
        'Complete',
        state.countByStatus(WorkStatus.complete),
        const Color(0xFF2E7D55),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.85,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _steel,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: metric.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${metric.count}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: _ink, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Metric {
  const _Metric(this.label, this.count, this.color);

  final String label;
  final int count;
  final Color color;
}

class WorkQueueScreen extends StatefulWidget {
  const WorkQueueScreen({
    super.key,
    required this.state,
    required this.onCreate,
    required this.onOpenItem,
  });

  final AppState state;
  final ValueChanged<WorkType> onCreate;
  final ValueChanged<WorkItem> onOpenItem;

  @override
  State<WorkQueueScreen> createState() => _WorkQueueScreenState();
}

class _WorkQueueScreenState extends State<WorkQueueScreen> {
  WorkType? _filter;

  @override
  Widget build(BuildContext context) {
    final items = _filter == null
        ? widget.state.items
        : widget.state.byType(_filter!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _SectionHeader(
          title: 'Work queue',
          actionLabel: _filter?.shortLabel ?? 'All work',
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
              ),
              ...WorkType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(type.icon, size: 18),
                    label: Text(type.shortLabel),
                    selected: _filter == type,
                    onSelected: (_) => setState(() => _filter = type),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const Key('new-work-item'),
          onPressed: () => widget.onCreate(_filter ?? WorkType.container),
          icon: const Icon(Icons.add),
          label: const Text('New work item'),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const _EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No work recorded',
            message:
                'Create a local record for the next container, order, report, or appointment.',
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkItemTile(
                item: item,
                onTap: () => widget.onOpenItem(item),
              ),
            ),
          ),
      ],
    );
  }
}

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({
    super.key,
    required this.state,
    required this.onCreate,
    required this.onOpenItem,
  });

  final AppState state;
  final VoidCallback onCreate;
  final ValueChanged<WorkItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final appointments = state.byType(WorkType.appointment);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        const _SectionHeader(
          title: 'Appointment book',
          actionLabel: 'Carrier windows',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.event_available),
          label: const Text('Book appointment'),
        ),
        const SizedBox(height: 14),
        if (appointments.isEmpty)
          const _EmptyState(
            icon: Icons.calendar_month_outlined,
            title: 'No appointments',
            message: 'Book receiving, pickup, or vendor service windows here.',
          )
        else
          ...appointments.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkItemTile(item: item, onTap: () => onOpenItem(item)),
            ),
          ),
      ],
    );
  }
}

class WorkItemTile extends StatelessWidget {
  const WorkItemTile({super.key, required this.item, required this.onTap});

  final WorkItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.type.icon, color: item.status.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${item.type.label} • ${item.reference}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _steel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _StatusPill(status: item.status),
                        _InfoPill(
                          icon: Icons.event_outlined,
                          label: formatShortDate(item.dueDate),
                        ),
                        _InfoPill(
                          icon: Icons.flag_outlined,
                          label: item.priority.label,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: _steel),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkItemDetailScreen extends StatelessWidget {
  const WorkItemDetailScreen({
    super.key,
    required this.state,
    required this.item,
  });

  final AppState state;
  final WorkItem item;

  @override
  Widget build(BuildContext context) {
    final current = state.items.firstWhere(
      (entry) => entry.id == item.id,
      orElse: () => item,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(current.type.shortLabel),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => WorkItemForm(
                  state: state,
                  initialType: current.type,
                  existing: current,
                ),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(current.type.icon, color: current.status.color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          current.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: _ink,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusPill(status: current.status),
                      _InfoPill(
                        icon: Icons.confirmation_number_outlined,
                        label: current.reference,
                      ),
                      _InfoPill(
                        icon: Icons.person_outline,
                        label: current.owner,
                      ),
                      _InfoPill(
                        icon: Icons.event_outlined,
                        label: formatShortDate(current.dueDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(current.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Update status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...WorkStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => state.updateStatus(current.id, status),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          current.status == status
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: status.color,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(status.label)),
                        Icon(Icons.circle, color: status.color, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              state.deleteItem(current.id);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove record'),
          ),
        ],
      ),
    );
  }
}

class WorkItemForm extends StatefulWidget {
  const WorkItemForm({
    super.key,
    required this.state,
    required this.initialType,
    this.existing,
  });

  final AppState state;
  final WorkType initialType;
  final WorkItem? existing;

  @override
  State<WorkItemForm> createState() => _WorkItemFormState();
}

class _WorkItemFormState extends State<WorkItemForm> {
  final _formKey = GlobalKey<FormState>();
  late WorkType _type;
  late WorkStatus _status;
  late WorkPriority _priority;
  late DateTime _dueDate;
  late final TextEditingController _titleController;
  late final TextEditingController _referenceController;
  late final TextEditingController _ownerController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? widget.initialType;
    _status = existing?.status ?? WorkStatus.open;
    _priority = existing?.priority ?? WorkPriority.routine;
    _dueDate = existing?.dueDate ?? DateTime.now().add(const Duration(days: 2));
    _titleController = TextEditingController(text: existing?.title ?? '');
    _referenceController = TextEditingController(
      text: existing?.reference ?? '',
    );
    _ownerController = TextEditingController(text: existing?.owner ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _referenceController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit work item' : 'New work item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            DropdownButtonFormField<WorkType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Work type'),
              items: WorkType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: editing
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('work-title-field'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Container released to carrier',
              ),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('work-reference-field'),
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference',
                hintText: 'CNTR-2048 or PO-104',
              ),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('work-owner-field'),
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: 'Owner',
                hintText: 'Desk, carrier, vendor, or team',
              ),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<WorkStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: WorkStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<WorkPriority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: WorkPriority.values
                        .map(
                          (priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text('Due ${formatShortDate(_dueDate)}'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('work-notes-field'),
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: 6,
              validator: _required,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('save-work-item'),
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(editing ? 'Save changes' : 'Create record'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: _dueDate,
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    final existing = widget.existing;
    final item = WorkItem(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      type: _type,
      title: _titleController.text.trim(),
      reference: _referenceController.text.trim(),
      owner: _ownerController.text.trim(),
      dueDate: _dueDate,
      status: _status,
      priority: _priority,
      notes: _notesController.text.trim(),
      createdAt: existing?.createdAt ?? now,
    );
    widget.state.upsertItem(item);
    Navigator.of(context).pop();
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _siteController;
  late final TextEditingController _coordinatorController;
  late bool _highlightDueItems;

  @override
  void initState() {
    super.initState();
    final settings = widget.state.settings;
    _siteController = TextEditingController(text: settings.siteLabel);
    _coordinatorController = TextEditingController(text: settings.coordinator);
    _highlightDueItems = settings.highlightDueItems;
  }

  @override
  void dispose() {
    _siteController.dispose();
    _coordinatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _SectionHeader(
          title: 'Settings',
          actionLabel: 'Local device only',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _siteController,
                  decoration: const InputDecoration(
                    labelText: 'Workspace label',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _coordinatorController,
                  decoration: const InputDecoration(labelText: 'Coordinator'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _highlightDueItems,
                  onChanged: (value) =>
                      setState(() => _highlightDueItems = value),
                  title: const Text('Highlight due items'),
                  subtitle: const Text(
                    'Shows urgent local records first on the dashboard.',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save settings'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Records and preferences stay on this device. The app has no account sign-in, sync service, analytics, advertising identifiers, or network features.',
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  developerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(supportEmail),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    widget.state.updateSettings(
      OperatorSettings(
        siteLabel: _siteController.text.trim().isEmpty
            ? OperatorSettings.fallback.siteLabel
            : _siteController.text.trim(),
        coordinator: _coordinatorController.text.trim().isEmpty
            ? OperatorSettings.fallback.coordinator
            : _coordinatorController.text.trim(),
        highlightDueItems: _highlightDueItems,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved on this device')),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel});

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          Text(
            actionLabel!,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _steel,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: status.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _mist,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _steel),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _steel,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, size: 42, color: _steel),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: _steel),
            ),
          ],
        ),
      ),
    );
  }
}

String formatShortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

List<WorkItem> _starterItems() {
  final today = DateTime.now();
  return [
    WorkItem(
      id: 'starter-container',
      type: WorkType.container,
      title: 'Confirm inbound container release',
      reference: 'CNTR-1001',
      owner: 'Operations desk',
      dueDate: today.add(const Duration(days: 1)),
      status: WorkStatus.open,
      priority: WorkPriority.elevated,
      notes:
          'Record vessel arrival, carrier handoff, seal status, and dock position.',
      createdAt: today,
    ),
  ];
}

List<WorkItem> _screenshotItems() {
  final today = DateTime(2026, 5, 12, 9);
  return [
    WorkItem(
      id: 'shot-1',
      type: WorkType.container,
      title: 'Track container DSRU 418204',
      reference: 'CNTR-418204',
      owner: 'North dock',
      dueDate: today.add(const Duration(days: 1)),
      status: WorkStatus.open,
      priority: WorkPriority.elevated,
      notes: 'Confirm customs release, carrier slot, and final gate-out time.',
      createdAt: today.subtract(const Duration(days: 1)),
    ),
    WorkItem(
      id: 'shot-2',
      type: WorkType.incident,
      title: 'Log pallet damage in bay 3',
      reference: 'INC-057',
      owner: 'Receiving team',
      dueDate: today,
      status: WorkStatus.awaiting,
      priority: WorkPriority.urgent,
      notes:
          'Secure the area, attach internal notes, and assign follow-up before close.',
      createdAt: today.subtract(const Duration(hours: 5)),
    ),
    WorkItem(
      id: 'shot-3',
      type: WorkType.supply,
      title: 'Reorder seals and wrap rolls',
      reference: 'SUP-214',
      owner: 'Stock room',
      dueDate: today.add(const Duration(days: 3)),
      status: WorkStatus.scheduled,
      priority: WorkPriority.routine,
      notes:
          'Prepare quantities for container seals, wrap rolls, pallet labels, and spill pads.',
      createdAt: today.subtract(const Duration(days: 2)),
    ),
    WorkItem(
      id: 'shot-4',
      type: WorkType.appointment,
      title: 'Carrier pickup window',
      reference: 'APT-0930',
      owner: 'Gate office',
      dueDate: today.add(const Duration(days: 2)),
      status: WorkStatus.scheduled,
      priority: WorkPriority.elevated,
      notes:
          'Reserve 09:30 slot, verify vehicle details, and keep dock lane two open.',
      createdAt: today.subtract(const Duration(days: 1, hours: 2)),
    ),
    WorkItem(
      id: 'shot-5',
      type: WorkType.container,
      title: 'Close export container checklist',
      reference: 'CNTR-772901',
      owner: 'Export desk',
      dueDate: today.add(const Duration(days: 5)),
      status: WorkStatus.complete,
      priority: WorkPriority.routine,
      notes:
          'Seal number, photos, and handoff notes have been checked locally.',
      createdAt: today.subtract(const Duration(days: 4)),
    ),
    WorkItem(
      id: 'shot-6',
      type: WorkType.appointment,
      title: 'Vendor maintenance visit',
      reference: 'APT-1400',
      owner: 'Facilities',
      dueDate: today.add(const Duration(days: 6)),
      status: WorkStatus.open,
      priority: WorkPriority.routine,
      notes:
          'Confirm visitor name and service area before the day shift starts.',
      createdAt: today.subtract(const Duration(days: 1)),
    ),
  ];
}
