import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robot_ampi_desktop/features/animation_editor/presentation/providers/animation_provider.dart';
import 'package:robot_ampi_desktop/features/animation_editor/domain/entities/animation_sequence.dart';

/// Widget for saving and loading animations
class AnimationSaveLoadWidget extends ConsumerWidget {
  const AnimationSaveLoadWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAnimations = ref.watch(savedAnimationsProvider);
    final currentAnimation = ref.watch(currentAnimationProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.save,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Save & Load',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: () {
                    ref.invalidate(savedAnimationsProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animation name input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Animation Name',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: currentAnimation.name),
              onChanged: (value) {
                ref.read(currentAnimationProvider.notifier).updateName(value);
              },
            ),
            const SizedBox(height: 12),

            // Description input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              controller: TextEditingController(text: currentAnimation.description),
              onChanged: (value) {
                ref.read(currentAnimationProvider.notifier).updateDescription(value);
              },
            ),
            const SizedBox(height: 12),

            // Loop mode selector
            DropdownButtonFormField<LoopMode>(
              value: currentAnimation.loopMode,
              decoration: const InputDecoration(
                labelText: 'Loop Mode',
                prefixIcon: Icon(Icons.repeat),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: LoopMode.once,
                  child: Text('Play Once'),
                ),
                DropdownMenuItem(
                  value: LoopMode.infinite,
                  child: Text('Loop Infinite'),
                ),
                DropdownMenuItem(
                  value: LoopMode.pingpong,
                  child: Text('Ping Pong'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(currentAnimationProvider.notifier).setLoopMode(mode);
                }
              },
            ),
            const SizedBox(height: 16),

            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: savedAnimations.hasValue
                      ? () => _saveAnimation(context, ref)
                      : null,
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Export C'),
                  onPressed: () => _exportCCode(context, ref),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.file_download),
                  label: const Text('Import'),
                  onPressed: () => _importAnimation(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Saved animations list
            if (savedAnimations.hasValue && savedAnimations.value != null)
              _buildSavedAnimationsList(context, ref, savedAnimations.value!)
            else if (savedAnimations.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (savedAnimations.hasError)
              _buildErrorMessage(context, 'Failed to load animations')
            else
              _buildInfoMessage(context, 'No saved animations'),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedAnimationsList(BuildContext context, WidgetRef ref, List<AnimationSequence> animations) {
    if (animations.isEmpty) {
      return _buildInfoMessage(context, 'No saved animations yet. Create your first one!');
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: animations.length,
        itemBuilder: (context, index) {
          final animation = animations[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.movie),
            ),
            title: Text(animation.name),
            subtitle: Text(
              '${animation.frames.length} frames • ${animation.totalDuration}ms',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  tooltip: 'Load',
                  onPressed: () {
                    ref.read(currentAnimationProvider.notifier).loadAnimation(animation);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete',
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () {
                    _confirmDelete(context, ref, animation);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoMessage(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAnimation(BuildContext context, WidgetRef ref) async {
    final animation = ref.read(currentAnimationProvider);
    final repository = ref.read(animationRepositoryProvider);

    try {
      await repository.saveAnimation(animation);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Animation "${animation.name}" saved!')),
        );
      }
      ref.invalidate(savedAnimationsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _exportCCode(BuildContext context, WidgetRef ref) async {
    final animation = ref.read(currentAnimationProvider);
    final repository = ref.read(animationRepositoryProvider);

    try {
      final cCode = repository.exportToCCode(animation, animation.name);
      // In a real app, show a file picker dialog
      // For now, just copy to clipboard
      await Clipboard.setData(ClipboardData(text: cCode));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('C code copied to clipboard!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    }
  }

  Future<void> _importAnimation(BuildContext context, WidgetRef ref) async {
    // Show a dialog to enter file path or use file picker
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Animation'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'File Path',
            hintText: '/path/to/animation.rampi',
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final repository = ref.read(animationRepositoryProvider);
        final animation = await repository.importFromFile(result);
        ref.read(currentAnimationProvider.notifier).loadAnimation(animation);
        ref.invalidate(savedAnimationsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Animation "${animation.name}" imported!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to import: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AnimationSequence animation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Animation'),
        content: Text('Are you sure you want to delete "${animation.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final repository = ref.read(animationRepositoryProvider);
        await repository.deleteAnimation(animation.id);
        ref.invalidate(savedAnimationsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Animation deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }
}
