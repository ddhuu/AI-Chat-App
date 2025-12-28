import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/knowledge_model.dart';
import '../models/unit_model.dart';
import '../providers/import_provider.dart';
import '../services/import_service.dart';
import '../services/unit_service.dart';
import '../../../data/services/api_service.dart';
import '../widgets/add_knowledge_unit_dialog.dart';

class KnowledgeDetailPage extends StatefulWidget {
  final Knowledge knowledge;
  final ApiService apiService;

  const KnowledgeDetailPage({
    super.key,
    required this.knowledge,
    required this.apiService,
  });

  @override
  State<KnowledgeDetailPage> createState() => _KnowledgeDetailPageState();
}

class _KnowledgeDetailPageState extends State<KnowledgeDetailPage> {
  late UnitService _unitService;
  List<Unit> _units = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _unitService = UnitService(widget.apiService);
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _unitService.getUnits(
        knowledgeId: widget.knowledge.id,
      );

      if (mounted) {
        setState(() {
          _units = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddUnitDialog() async {

    final importService = ImportService(widget.apiService);
    final importProvider = ImportProvider(
      importService: importService,
      knowledge: widget.knowledge,
    );

    await showDialog(
      context: context,
      builder: (context) => AddKnowledgeUnitDialog(
        knowledgeId: widget.knowledge.id,
        importProvider: importProvider,
      ),
    );

    // Reload units after dialog closes
    _loadUnits();
  }

  Future<void> _deleteUnit(Unit unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete "${unit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _unitService.deleteUnit(
          knowledgeId: widget.knowledge.id,
          datasourceId: unit.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit deleted successfully')),
          );
          _loadUnits();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete unit: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.knowledge.knowledgeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: _loadUnits,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUnitDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.knowledge.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.folder_outlined,
                      '${_units.length} units',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.update,
                      _formatDate(widget.knowledge.updatedAt.toIso8601String()),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Units list
          Expanded(child: _buildUnitsList()),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading units',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUnits, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_units.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            const Text(
              'No units yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first knowledge unit',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddUnitDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Unit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _units.length,
      itemBuilder: (context, index) {
        final unit = _units[index];
        return _buildUnitCard(unit);
      },
    );
  }

  Widget _buildUnitCard(Unit unit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTypeColor(unit.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getTypeIcon(unit.type), color: _getTypeColor(unit.type)),
        ),
        title: Text(
          unit.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusBadge(unit.syncStatus),
                const SizedBox(width: 8),
                Text(
                  unit.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTypeColor(unit.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (unit.metadata.description != null) ...[
              const SizedBox(height: 4),
              Text(
                unit.metadata.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _deleteUnit(unit);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'synced':
        color = Colors.green;
        label = 'Synced';
        break;
      case 'syncing':
        color = Colors.orange;
        label = 'Syncing';
        break;
      case 'not_synced':
      default:
        color = Colors.grey;
        label = 'Not Synced';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'web':
        return Icons.language;
      case 'file':
        return Icons.insert_drive_file;
      case 'slack':
        return Icons.chat_bubble_outline;
      case 'confluence':
        return Icons.groups_outlined;
      case 'google_drive':
        return Icons.cloud_outlined;
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'web':
        return Colors.blue;
      case 'file':
        return Colors.green;
      case 'slack':
        return Colors.purple;
      case 'confluence':
        return Colors.indigo;
      case 'google_drive':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).floor()}y ago';
      } else if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()}mo ago';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
