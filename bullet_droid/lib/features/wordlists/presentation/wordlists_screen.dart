import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:file_picker/file_picker.dart';

import 'package:bullet_droid/core/design_tokens/spacing.dart';

import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_fab.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';

import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';
import 'package:bullet_droid/features/wordlists/providers/wordlists_provider.dart';
import 'package:bullet_droid/features/wordlists/models/wordlist_model.dart';
import 'package:bullet_droid/features/wordlists/providers/custom_wordlist_types_provider.dart';

class WordlistsScreen extends ConsumerStatefulWidget {
  const WordlistsScreen({super.key});

  @override
  ConsumerState<WordlistsScreen> createState() => _WordlistsScreenState();
}

class _WordlistsScreenState extends ConsumerState<WordlistsScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  bool _showDeleteConfirmation = false;
  String? _wordlistDeleteConfirmation;

  final Map<String, AnimationController> _swipeControllers = {};
  final Map<String, Animation<double>> _swipeAnimations = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _swipeControllers.values) {
      controller.dispose();
    }
    _swipeControllers.clear();
    _swipeAnimations.clear();
    super.dispose();
  }

  AnimationController _getSwipeController(String id) {
    if (!_swipeControllers.containsKey(id)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _swipeControllers[id] = controller;
      _swipeAnimations[id] = Tween<double>(
        begin: 0.0,
        end: -60.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }
    return _swipeControllers[id]!;
  }

  void _resetSwipe(String id) {
    final controller = _swipeControllers[id];
    if (controller != null) {
      controller.reverse();
    }
  }

  void _resetAllSwipes() {
    for (final controller in _swipeControllers.values) {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordlistsState = ref.watch(wordlistsProvider);
    final filteredWordlists = ref.watch(filteredWordlistsProvider);
    final customTypes = ref.watch(customWordlistTypesProvider).types;

    return Scaffold(
      backgroundColor: GeistColors.gray50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: GestureDetector(
          onTap: () {
            if (_showDeleteConfirmation ||
                _wordlistDeleteConfirmation != null) {
              setState(() {
                _showDeleteConfirmation = false;
                _wordlistDeleteConfirmation = null;
              });
            }
            _resetAllSwipes();
          },
          child: AppBar(
            backgroundColor: GeistColors.white,
            elevation: 0,
            title: GeistText(
              'Wordlists',
              variant: GeistTextVariant.headingMedium,
              customColor: GeistColors.black,
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_showDeleteConfirmation || _wordlistDeleteConfirmation != null) {
            setState(() {
              _showDeleteConfirmation = false;
              _wordlistDeleteConfirmation = null;
            });
          }
          _resetAllSwipes();
        },
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Statistics Header
                GestureDetector(
                  onTap: () {
                    if (_showDeleteConfirmation) {
                      setState(() {
                        _showDeleteConfirmation = false;
                      });
                    }
                    _resetAllSwipes();
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: GeistSpacing.md,
                      right: GeistSpacing.md,
                      top: GeistSpacing.xs,
                      bottom: GeistSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: GeistColors.gray200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildStatisticsHeader(wordlistsState),
                  ),
                ),

                // Error message
                if (wordlistsState.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Text(
                      wordlistsState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),

                // Wordlist cards
                Expanded(
                  child: wordlistsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : wordlistsState.wordlists.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt_outlined,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No wordlists loaded',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to import a wordlist',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            left: GeistSpacing.md,
                            right: GeistSpacing.md,
                            top: GeistSpacing.md,
                            bottom:
                                GeistSpacing.md +
                                _floatingNavClearance(context),
                          ),
                          itemCount: filteredWordlists.length,
                          itemBuilder: (context, index) {
                            final wordlist = filteredWordlists[index];
                            return _buildWordlistCard(
                              wordlist,
                              customTypes.map((t) => t.name).toList(),
                            );
                          },
                        ),
                ),
              ],
            ),

            // Floating Action Button positioned above floating navigation (responsive)
            Positioned(
              bottom: _floatingNavClearance(context),
              right: 16,
              child: GeistFab(
                onPressed: () async {
                  // Cancel any active confirmations
                  if (_showDeleteConfirmation ||
                      _wordlistDeleteConfirmation != null) {
                    setState(() {
                      _showDeleteConfirmation = false;
                      _wordlistDeleteConfirmation = null;
                    });
                  }
                  _resetAllSwipes();

                  // Open file picker directly
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['txt'],
                    allowMultiple: false,
                  );

                  if (result != null && result.files.isNotEmpty) {
                    await ref
                        .read(wordlistsProvider.notifier)
                        .addWordlistFromFile(
                          filePath: result.files.first.path!,
                          fileName: result.files.first.name,
                        );
                  }
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader(WordlistsState wordlistsState) {
    final totalWordlists = wordlistsState.wordlists.length;

    return Row(
      children: [
        // Search Input
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_showDeleteConfirmation ||
                  _wordlistDeleteConfirmation != null) {
                setState(() {
                  _showDeleteConfirmation = false;
                  _wordlistDeleteConfirmation = null;
                });
              }
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  // Search icon
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.search,
                      size: 22,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  // Text field
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          ref
                              .read(wordlistsProvider.notifier)
                              .updateSearchQuery(query);
                        },
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF374151),
                          fontFamily: 'Geist',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search…',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'Geist',
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          fillColor: GeistColors.transparent,
                          filled: true,
                          contentPadding: EdgeInsets.only(
                            left: 12,
                            right: 16,
                            top: 12,
                            bottom: 12,
                          ),
                        ),
                        cursorColor: Color(0xFF374151),
                        cursorHeight: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: GeistSpacing.sm),

        // Delete All Button
        GestureDetector(
          onTap: wordlistsState.wordlists.isEmpty
              ? null
              : () {
                  if (_showDeleteConfirmation) {
                    // Confirm deletion
                    ref.read(wordlistsProvider.notifier).deleteAllWordlists();
                    setState(() {
                      _showDeleteConfirmation = false;
                    });
                    context.showSuccessToast('All wordlists deleted');
                  } else {
                    // Show confirmation
                    setState(() {
                      _showDeleteConfirmation = true;
                      _wordlistDeleteConfirmation = null;
                    });
                  }
                },
          child: Container(
            height: 44,
            width: 88,
            padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
            decoration: BoxDecoration(
              color: _showDeleteConfirmation
                  ? GeistColors.red
                  : GeistColors.transparent,
              border: Border.all(color: GeistColors.gray300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showDeleteConfirmation ? Icons.check : Icons.delete,
                  size: 20,
                  color: _showDeleteConfirmation
                      ? GeistColors.white
                      : GeistColors.gray600,
                ),
                SizedBox(width: GeistSpacing.sm),
                GeistText(
                  'All',
                  variant: GeistTextVariant.headingMedium,
                  customColor: _showDeleteConfirmation
                      ? GeistColors.white
                      : (wordlistsState.wordlists.isEmpty
                            ? GeistColors.gray400
                            : GeistColors.black),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: GeistSpacing.sm),

        // Total Wordlists Pill
        GestureDetector(
          onTap: () {
            if (_showDeleteConfirmation ||
                _wordlistDeleteConfirmation != null) {
              setState(() {
                _showDeleteConfirmation = false;
                _wordlistDeleteConfirmation = null;
              });
            }
          },
          child: SizedBox(
            height: 44,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
              decoration: BoxDecoration(
                color: GeistColors.gray100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GeistColors.gray200),
              ),
              child: Center(
                child: GeistText(
                  '$totalWordlists Wordlist${totalWordlists == 1 ? '' : 's'}',
                  variant: GeistTextVariant.bodyMedium,
                  customColor: GeistColors.gray700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordlistCard(WordlistModel wordlist, List<String> customTypes) {
    const builtInTypes = ['Default', 'Email', 'MailPass/Credentials', 'Numeric', 'URLs'];
    final dropdownItems = [...builtInTypes, ...customTypes];
    final hasValue = dropdownItems.contains(wordlist.type);

    final controller = _getSwipeController(wordlist.id);
    final animation = _swipeAnimations[wordlist.id]!;

    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      child: Stack(
        children: [
          // Delete background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: GeistSpacing.md),
              child: GestureDetector(
                onTap: () {
                  ref
                      .read(wordlistsProvider.notifier)
                      .deleteWordlist(wordlist.id);
                  if (mounted) {
                    context.showSuccessToast(
                      'Wordlist "${wordlist.name}" deleted',
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(GeistSpacing.sm),
                  child: Icon(Icons.delete, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          // Main content
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(animation.value, 0),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final currentValue = controller.value;
                    final delta = details.delta.dx / 300;

                    // Allow left swipe to open and right swipe to close
                    if (details.delta.dx < 0) {
                      final newValue = (currentValue - delta).clamp(0.0, 1.0);
                      controller.value = newValue;
                    } else if (details.delta.dx > 0 && currentValue > 0) {
                      final newValue = (currentValue - delta).clamp(0.0, 1.0);
                      controller.value = newValue;
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    // Consider both position and velocity for more natural feel
                    final velocity = details.velocity.pixelsPerSecond.dx;

                    if (velocity < -500) {
                      controller.forward();
                    } else if (velocity > 500) {
                      controller.reverse();
                    } else if (controller.value > 0.3) {
                      controller.forward();
                    } else {
                      controller.reverse();
                    }
                  },
                  onTap: () {
                    // Cancel any active confirmations first
                    if (_showDeleteConfirmation ||
                        _wordlistDeleteConfirmation != null) {
                      setState(() {
                        _showDeleteConfirmation = false;
                        _wordlistDeleteConfirmation = null;
                      });
                      return;
                    }
                    _resetSwipe(wordlist.id);
                  },
                  child: Container(
                    padding: EdgeInsets.all(GeistSpacing.md),
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      border: Border.all(color: GeistColors.gray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GeistText(
                                        wordlist.name,
                                        variant: GeistTextVariant.headingSmall,
                                      ),
                                      SizedBox(height: GeistSpacing.xs),
                                      GeistText(
                                        wordlist.path,
                                        variant: GeistTextVariant.bodyMedium,
                                        customColor: GeistColors.gray600,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: GeistSpacing.md),

                            // Type dropdown and metadata row
                            Row(
                              children: [
                                SizedBox(
                                  height: 32,
                                  child: GeistDropdown<String>(
                                    label: hasValue
                                        ? wordlist.type
                                        : 'Select type',
                                    value: hasValue
                                        ? wordlist.type
                                        : (dropdownItems.isNotEmpty
                                              ? dropdownItems.first
                                              : ''),
                                    width: 125,
                                    items: dropdownItems,
                                    itemLabelBuilder: (String type) =>
                                        type.isEmpty ? 'Select type' : type,
                                    onChanged: (value) {
                                      if (value != wordlist.type) {
                                        ref
                                            .read(wordlistsProvider.notifier)
                                            .updateWordlistType(
                                              wordlist.id,
                                              value,
                                            );
                                      }
                                    },
                                  ),
                                ),

                                SizedBox(width: GeistSpacing.md),

                                GeistText(
                                  '${wordlist.totalLines} lines',
                                  variant: GeistTextVariant.bodySmall,
                                  customColor: GeistColors.gray600,
                                ),

                                const Spacer(),

                                if (wordlist.lastUsed != null)
                                  GeistText(
                                    'Used ${_formatDate(wordlist.lastUsed!)}',
                                    variant: GeistTextVariant.bodySmall,
                                    customColor: GeistColors.gray400,
                                  )
                                else if (wordlist.createdAt != null)
                                  GeistText(
                                    _formatDate(wordlist.createdAt!),
                                    variant: GeistTextVariant.bodySmall,
                                    customColor: GeistColors.gray400,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Tooltip(
                            message: 'Swipe left to delete this wordlist',
                            preferBelow: false,
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(
                              Icons.info_outline,
                              size: 18,
                              color: GeistColors.gray400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

extension _WordlistsFabClearance on _WordlistsScreenState {
  double _floatingNavClearance(BuildContext context) {
    const double navHeight = 64.0;
    final double navBottomMargin = GeistSpacing.lg * 2;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final double extraSpacing = GeistSpacing.lg;
    return safeBottom + navHeight + navBottomMargin + extraSpacing;
  }
}
