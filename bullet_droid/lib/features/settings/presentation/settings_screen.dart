import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';

import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';

import 'package:bullet_droid/features/settings/providers/settings_provider.dart';
import 'package:bullet_droid/core/router/app_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: GeistColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: GeistSpacing.lg,
            right: GeistSpacing.lg,
            top: GeistSpacing.lg,
            bottom: GeistSpacing.lg + 85,
          ),
          child: Column(
            children: [
              Material(
                color: GeistColors.transparent,
                child: InkWell(
                  onTap: () => context.goNamed(AppRoute.hitsDb),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(GeistSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(GeistSpacing.sm),
                          decoration: BoxDecoration(
                            color: GeistColors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.storage,
                            color: GeistColors.white,
                            size: 20,
                          ),
                        ),

                        SizedBox(width: GeistSpacing.lg),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GeistText(
                                'Hits Database',
                                variant: GeistTextVariant.bodyLarge,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: GeistSpacing.xs),
                              GeistText(
                                'View and manage your successful hits',
                                variant: GeistTextVariant.bodySmall,
                                customColor: GeistColors.gray600,
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios,
                          color: GeistColors.gray600,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // General Settings
              _buildSettingsSection(
                context: context,
                ref: ref,
                title: 'General',
                description: 'Configure general application behavior',
                icon: Icons.settings,
                children: [
                  _buildToggleSetting(
                    'Enable Notifications',
                    'Show notifications when runners complete',
                    settings.enableNotifications,
                    (value) => ref
                        .read(settingsProvider.notifier)
                        .setEnableNotifications(value),
                  ),
                ],
              ),

              SizedBox(height: GeistSpacing.xl),

              // Runner Settings
              _buildSettingsSection(
                context: context,
                ref: ref,
                title: 'Runner',
                description: 'Configure job execution settings',
                icon: Icons.play_circle_outline,
                children: [
                  _buildTextSetting(
                    'Default Timeout',
                    'Request timeout in seconds',
                    settings.defaultTimeout.toString(),
                    '',
                    (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null && intValue > 0) {
                        ref
                            .read(settingsProvider.notifier)
                            .setDefaultTimeout(intValue);
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: GeistSpacing.xl),

              // Proxy Settings
              _buildSettingsSection(
                context: context,
                ref: ref,
                title: 'Proxy',
                description: 'Configure proxy behavior and retry logic',
                icon: Icons.vpn_lock,
                children: [
                  _buildDropdownSetting(
                    'Proxy Retry Count',
                    'Number of retries on proxy failure',
                    settings.proxyRetryCount.toString(),
                    List.generate(6, (index) => index.toString()),
                    (value) {
                      final intValue = int.tryParse(value);
                      if (intValue != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .setProxyRetryCount(intValue);
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: GeistSpacing.xl),

              // About Section
              _buildSettingsSection(
                context: context,
                ref: ref,
                title: 'About',
                description: null,
                icon: Icons.info_outline,
                children: [
                  _buildReadOnlySetting('Version', '2.0.0'),
                  _buildCustomSetting(
                    'Open Source Licenses',
                    'View third-party licenses',
                    GeistButton(
                      text: 'View Licenses',
                      onPressed: () => _showLicensePage(context),
                      variant: GeistButtonVariant.outline,
                      icon: Icon(Icons.code, size: 16),
                    ),
                  ),
                ],
              ),

              SizedBox(height: GeistSpacing.xl),

              // Reset Settings
              _buildResetSection(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String? description,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
              Icon(icon, color: GeistColors.gray600, size: 20),
              SizedBox(width: GeistSpacing.sm),
              GeistText(
                title,
                variant: GeistTextVariant.headingSmall,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          if (description != null) SizedBox(height: GeistSpacing.xs),
          if (description != null)
            GeistText(
              description,
              variant: GeistTextVariant.bodySmall,
              customColor: GeistColors.gray600,
            ),
          SizedBox(height: GeistSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String label,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GeistSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeistText(
                  label,
                  variant: GeistTextVariant.bodyMedium,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: GeistSpacing.xs),
                GeistText(
                  description,
                  variant: GeistTextVariant.bodySmall,
                  customColor: GeistColors.gray600,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: GeistColors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTextSetting(
    String label,
    String description,
    String value,
    String suffix,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GeistSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeistText(
            label,
            variant: GeistTextVariant.bodyMedium,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: GeistSpacing.xs),
          GeistText(
            description,
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray600,
          ),
          SizedBox(height: GeistSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: value,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: GeistSpacing.sm,
                      vertical: GeistSpacing.xs,
                    ),
                  ),
                ),
              ),
              SizedBox(width: GeistSpacing.sm),
              GeistText(
                suffix,
                variant: GeistTextVariant.bodySmall,
                customColor: GeistColors.gray600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(
    String label,
    String description,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GeistSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeistText(
            description,
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray600,
          ),
          SizedBox(height: GeistSpacing.sm),
          GeistDropdownFormField<String>(
            label: label,
            items: options,
            itemLabelBuilder: (String option) => option,
            initialValue: value,
            onChanged: (newValue) => onChanged(newValue),
            validator: (value) => null,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlySetting(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GeistSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeistText(
            label,
            variant: GeistTextVariant.bodyMedium,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: GeistSpacing.xs),
          GeistText(
            value,
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSetting(
    String label,
    String description,
    Widget customWidget,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GeistSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeistText(
            label,
            variant: GeistTextVariant.bodyMedium,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: GeistSpacing.xs),
          GeistText(
            description,
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray600,
          ),
          SizedBox(height: GeistSpacing.sm),
          customWidget,
        ],
      ),
    );
  }

  Widget _buildResetSection(BuildContext context, WidgetRef ref) {
    return Container(
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
              Icon(
                Icons.warning_outlined,
                color: GeistColors.warningColor,
                size: 20,
              ),
              SizedBox(width: GeistSpacing.sm),
              GeistText(
                'Reset Settings',
                variant: GeistTextVariant.headingSmall,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),

          SizedBox(height: GeistSpacing.xs),

          GeistText(
            'This will restore all settings to their default values. This action cannot be undone.',
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray600,
          ),

          SizedBox(height: GeistSpacing.md),

          SizedBox(
            width: double.infinity,
            child: GeistButton(
              text: 'Reset to Defaults',
              onPressed: () => _showResetDialog(context, ref),
              variant: GeistButtonVariant.outline,
              icon: Icon(
                Icons.restore,
                size: 16,
                color: GeistColors.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLicensePage(BuildContext context) {
    context.pushNamed(AppRoute.licenses);
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: GeistText(
          'Reset Settings',
          variant: GeistTextVariant.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GeistText(
              'Are you sure you want to reset all settings to defaults?',
              variant: GeistTextVariant.bodyMedium,
            ),
            SizedBox(height: GeistSpacing.md),
            Container(
              padding: EdgeInsets.all(GeistSpacing.sm),
              decoration: BoxDecoration(
                color: GeistColors.warningColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: GeistColors.warningColor.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: GeistColors.warningColor,
                    size: 16,
                  ),
                  SizedBox(width: GeistSpacing.sm),
                  Expanded(
                    child: GeistText(
                      'This action cannot be undone.',
                      variant: GeistTextVariant.bodySmall,
                      customColor: GeistColors.warningColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: GeistText('Cancel', variant: GeistTextVariant.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.of(context).pop();
              context.showSuccessToast('Settings reset to defaults');
            },
            child: GeistText(
              'Reset',
              variant: GeistTextVariant.bodyMedium,
              customColor: GeistColors.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
