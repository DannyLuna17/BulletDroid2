import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';

class BulletDroidLicensePage extends StatefulWidget {
  const BulletDroidLicensePage({super.key});

  @override
  State<BulletDroidLicensePage> createState() => _BulletDroidLicensePageState();
}

class _BulletDroidLicensePageState extends State<BulletDroidLicensePage> {
  List<LicenseEntry>? _licenses;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLicenses();
  }

  Future<void> _loadLicenses() async {
    try {
      final licenses = <LicenseEntry>[];
      await for (final license in LicenseRegistry.licenses) {
        licenses.add(license);
      }

      // Sort licenses alphabetically by package name
      licenses.sort((a, b) => a.packages.first.compareTo(b.packages.first));

      if (mounted) {
        setState(() {
          _licenses = licenses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load licenses: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeistColors.white,
      appBar: AppBar(
        backgroundColor: GeistColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GeistColors.black),
          onPressed: () => context.pop(),
        ),
        title: GeistText(
          'Open Source Licenses',
          variant: GeistTextVariant.headingMedium,
          customColor: GeistColors.black,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            _buildHeaderSection(),

            // Licenses content
            Expanded(child: _buildLicensesContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(GeistSpacing.lg),
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        color: GeistColors.gray50,
        border: Border.all(color: GeistColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: GeistColors.gray600, size: 20),
              SizedBox(width: GeistSpacing.sm),
              GeistText(
                'BulletDroid',
                variant: GeistTextVariant.headingSmall,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),

          SizedBox(height: GeistSpacing.xs),

          GeistText(
            'Version 2.0.0',
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray600,
          ),

          SizedBox(height: GeistSpacing.md),

          GeistText(
            'This application uses open source software. The following is a list of all third-party libraries and their respective licenses.',
            variant: GeistTextVariant.bodyMedium,
            customColor: GeistColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildLicensesContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GeistColors.blue),
            ),
            SizedBox(height: GeistSpacing.md),
            GeistText(
              'Loading licenses...',
              variant: GeistTextVariant.bodyMedium,
              customColor: GeistColors.gray600,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(GeistSpacing.lg),
          padding: EdgeInsets.all(GeistSpacing.lg),
          decoration: BoxDecoration(
            color: GeistColors.errorColorSubtle,
            border: Border.all(
              color: GeistColors.errorColor.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: GeistColors.errorColor,
                size: 24,
              ),
              SizedBox(height: GeistSpacing.sm),
              GeistText(
                'Error Loading Licenses',
                variant: GeistTextVariant.headingSmall,
                customColor: GeistColors.errorColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: GeistSpacing.xs),
              GeistText(
                _error!,
                variant: GeistTextVariant.bodySmall,
                customColor: GeistColors.errorColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: GeistSpacing.md),
              GeistButton(
                text: 'Retry',
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadLicenses();
                },
                variant: GeistButtonVariant.outline,
                size: GeistButtonSize.small,
              ),
            ],
          ),
        ),
      );
    }

    if (_licenses == null || _licenses!.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(GeistSpacing.lg),
          padding: EdgeInsets.all(GeistSpacing.lg),
          decoration: BoxDecoration(
            color: GeistColors.gray50,
            border: Border.all(color: GeistColors.gray200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: GeistColors.gray600, size: 24),
              SizedBox(height: GeistSpacing.sm),
              GeistText(
                'No licenses found',
                variant: GeistTextVariant.headingSmall,
                customColor: GeistColors.gray600,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: GeistSpacing.xs),
              GeistText(
                'No third-party licenses were detected.',
                variant: GeistTextVariant.bodySmall,
                customColor: GeistColors.gray600,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: GeistSpacing.lg,
        right: GeistSpacing.lg,
        bottom: GeistSpacing.lg,
      ),
      itemCount: _licenses!.length,
      itemBuilder: (context, index) {
        final license = _licenses![index];
        return _LicenseCard(license: license);
      },
    );
  }
}

class _LicenseCard extends StatefulWidget {
  final LicenseEntry license;

  const _LicenseCard({required this.license});

  @override
  State<_LicenseCard> createState() => _LicenseCardState();
}

class _LicenseCardState extends State<_LicenseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final packageNames = widget.license.packages.join(', ');
    final licenseText = widget.license.paragraphs
        .map((p) => p.text)
        .join('\n\n');

    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      decoration: BoxDecoration(
        color: GeistColors.gray50,
        border: Border.all(color: GeistColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Package header (always visible)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(GeistSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GeistText(
                            packageNames,
                            variant: GeistTextVariant.bodyLarge,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: GeistSpacing.xs),
                          GeistText(
                            '${widget.license.paragraphs.length} license paragraph${widget.license.paragraphs.length == 1 ? '' : 's'}',
                            variant: GeistTextVariant.bodySmall,
                            customColor: GeistColors.gray600,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: GeistColors.gray600,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // License text (expandable)
          if (_isExpanded) ...[
            Divider(color: GeistColors.gray200, height: 1),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(GeistSpacing.lg),
              child: GeistText(
                licenseText,
                variant: GeistTextVariant.codeSmall,
                customColor: GeistColors.gray600,
                selectable: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
