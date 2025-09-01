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

class WordlistsScreen extends ConsumerStatefulWidget {
  const WordlistsScreen({super.key});

  @override
  ConsumerState<WordlistsScreen> createState() => _WordlistsScreenState();
}

class _WordlistsScreenState extends ConsumerState<WordlistsScreen> {
  late TextEditingController _searchController;
  bool _showDeleteConfirmation = false;
  String? _wordlistDeleteConfirmation;

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
    final wordlistsState = ref.watch(wordlistsProvider);
    final filteredWordlists = ref.watch(filteredWordlistsProvider);

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
                            bottom: GeistSpacing.md + _floatingNavClearance(context),
                          ),
                          itemCount: filteredWordlists.length,
                          itemBuilder: (context, index) {
                            final wordlist = filteredWordlists[index];
                            return _WordlistCard(
                              wordlist: wordlist,
                              isConfirming:
                                  _wordlistDeleteConfirmation == wordlist.id,
                              onDelete: () {},
                              onConfirmationToggle: () {
                                setState(() {
                                  if (_wordlistDeleteConfirmation ==
                                      wordlist.id) {
                                    _wordlistDeleteConfirmation = null;
                                  } else {
                                    _wordlistDeleteConfirmation = wordlist.id;
                                    _showDeleteConfirmation = false;
                                  }
                                });
                              },
                              onCancelConfirmations: () {
                                if (_showDeleteConfirmation ||
                                    _wordlistDeleteConfirmation != null) {
                                  setState(() {
                                    _showDeleteConfirmation = false;
                                    _wordlistDeleteConfirmation = null;
                                  });
                                }
                              },
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

class _WordlistCard extends ConsumerWidget {
  final WordlistModel wordlist;
  final VoidCallback onDelete;
  final bool isConfirming;
  final VoidCallback onConfirmationToggle;
  final VoidCallback onCancelConfirmations;

  const _WordlistCard({
    required this.wordlist,
    required this.onDelete,
    required this.isConfirming,
    required this.onConfirmationToggle,
    required this.onCancelConfirmations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      decoration: BoxDecoration(
        color: GeistColors.white,
        border: Border.all(color: GeistColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCancelConfirmations,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(GeistSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    GestureDetector(
                      onTap: () {
                        if (isConfirming) {
                          // Confirm deletion
                          ref
                              .read(wordlistsProvider.notifier)
                              .deleteWordlist(wordlist.id);
                          onConfirmationToggle();
                          context.showSuccessToast(
                            'Wordlist "${wordlist.name}" deleted',
                          );
                        } else {
                          // Show confirmation
                          onConfirmationToggle();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          isConfirming ? Icons.check : Icons.delete_outline,
                          size: 20,
                          color: isConfirming ? Colors.green : GeistColors.red,
                        ),
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
                        label: wordlist.type,
                        value: wordlist.type,
                        width: 125,
                        items: const [
                          'Default',
                          'Email',
                          'Credentials',
                          'Numeric',
                          'URLs',
                        ],
                        itemLabelBuilder: (String type) => type,
                        onChanged: (value) {
                          if (value != wordlist.type) {
                            ref
                                .read(wordlistsProvider.notifier)
                                .updateWordlistType(wordlist.id, value);
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
          ),
        ),
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
