import 'package:flutter/material.dart';
import '../../models/sud_system.dart';
import '../../services/systems_service.dart';
import 'system_detail_screen.dart';

class SystemsDirectoryScreen extends StatefulWidget {
  const SystemsDirectoryScreen({super.key});

  @override
  State<SystemsDirectoryScreen> createState() => _SystemsDirectoryScreenState();
}

class _SystemsDirectoryScreenState extends State<SystemsDirectoryScreen>
    with SingleTickerProviderStateMixin {
  final SystemsService _service = SystemsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: SystemCategory.values.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sud Axborot Tizimlari'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Barchasi'),
            ...SystemCategory.values.map((category) {
              return Tab(text: category.displayName);
            }),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSystemList(null), // All systems
          ...SystemCategory.values.map((category) {
            return _buildSystemList(category);
          }),
        ],
      ),
    );
  }

  Widget _buildSystemList(SystemCategory? category) {
    Stream<List<SudSystem>> stream;
    if (category != null) {
      stream = _service.getSystemsByCategory(category);
    } else {
      stream = _service.getAllSystems();
    }

    return StreamBuilder<List<SudSystem>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final systems = snapshot.data ?? [];

        if (systems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.computer, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Tizimlar mavjud emas',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: systems.length,
          itemBuilder: (context, index) {
            return _buildSystemCard(systems[index]);
          },
        );
      },
    );
  }

  Widget _buildSystemCard(SudSystem system) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SystemDetailScreen(system: system),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  image: system.logoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(system.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: system.logoUrl == null
                    ? Icon(Icons.computer,
                        size: 30, color: Theme.of(context).primaryColor)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      system.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      system.fullName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(system.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SystemStatus status) {
    Color color;
    switch (status) {
      case SystemStatus.active:
        color = Colors.green;
        break;
      case SystemStatus.maintenance:
        color = Colors.orange;
        break;
      case SystemStatus.deprecated:
        color = Colors.grey;
        break;
      case SystemStatus.offline:
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
