import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_input.dart';
import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';

import 'package:bullet_droid/features/runner/models/runner_instance.dart';
import 'package:bullet_droid/features/runner/providers/runner_provider.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/wordlists/providers/wordlists_provider.dart';

class RunnerControls extends ConsumerWidget {
  final String runnerId;
  final RunnerInstance runnerInstance;
  final TextEditingController startCountController;
  final TextEditingController botsCountController;
  final ValueChanged<String> onStartCountChanged;
  final ValueChanged<String> onBotsCountChanged;
  final VoidCallback onStartPressed;
  final VoidCallback onStopPressed;
  final VoidCallback onUpdateDashboard;

  const RunnerControls({
    super.key,
    required this.runnerId,
    required this.runnerInstance,
    required this.startCountController,
    required this.botsCountController,
    required this.onStartCountChanged,
    required this.onBotsCountChanged,
    required this.onStartPressed,
    required this.onStopPressed,
    required this.onUpdateDashboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(configsProvider).configs;
    final wordlists = ref.watch(wordlistsProvider).wordlists;

    return Padding(
      padding: EdgeInsets.all(GeistSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: runnerInstance.isRunning
                              ? GeistColors.gray200
                              : const Color.fromRGBO(218, 211, 214, 1),
                          width: 1.2,
                        ),
                        color: runnerInstance.isRunning
                            ? GeistColors.gray50
                            : GeistColors.white,
                      ),
                      child: GeistInput(
                        label: "Start At",
                        controller: startCountController,
                        keyboardType: TextInputType.number,
                        isDisabled: runnerInstance.isRunning,
                        onChanged: onStartCountChanged,
                        placeholder: '',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: GeistSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: runnerInstance.isRunning
                              ? GeistColors.gray200
                              : const Color.fromRGBO(218, 211, 214, 1),
                          width: 1.2,
                        ),
                        color: runnerInstance.isRunning
                            ? GeistColors.gray50
                            : GeistColors.white,
                      ),
                      child: GeistInput(
                        label: "Bots",
                        controller: botsCountController,
                        keyboardType: TextInputType.number,
                        isDisabled: runnerInstance.isRunning,
                        onChanged: onBotsCountChanged,
                        placeholder: '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: GeistSpacing.md),

          // Config and Wordlist dropdowns
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: GeistDropdown<String>(
                    label:
                        runnerInstance.selectedConfigId != null &&
                            configs.any(
                              (c) => c.id == runnerInstance.selectedConfigId,
                            )
                        ? configs
                              .firstWhere(
                                (c) => c.id == runnerInstance.selectedConfigId,
                              )
                              .name
                        : 'Select Config',
                    value: runnerInstance.selectedConfigId == null
                        ? ''
                        : (configs.any(
                                (c) => c.id == runnerInstance.selectedConfigId,
                              )
                              ? runnerInstance.selectedConfigId!
                              : configs.isNotEmpty
                              ? configs.first.id
                              : ''),
                    items: runnerInstance.selectedConfigId == null
                        ? ['', ...configs.map((c) => c.id).toList()]
                        : configs.map((c) => c.id).toList(),
                    itemLabelBuilder: (String configId) => configId.isEmpty
                        ? 'Select Config'
                        : configs.firstWhere((c) => c.id == configId).name,
                    onChanged: runnerInstance.isRunning
                        ? (value) {}
                        : (value) {
                            ref
                                .read(multiRunnerProvider.notifier)
                                .updateSelectedConfigForRunner(
                                  runnerId,
                                  value.isEmpty ? null : value,
                                );
                            onUpdateDashboard();
                          },
                  ),
                ),
              ),
              SizedBox(width: GeistSpacing.xs),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: GeistDropdown<String>(
                    label:
                        runnerInstance.selectedWordlistId != null &&
                            wordlists.any(
                              (w) => w.id == runnerInstance.selectedWordlistId,
                            )
                        ? wordlists
                              .firstWhere(
                                (w) =>
                                    w.id == runnerInstance.selectedWordlistId,
                              )
                              .name
                        : 'Select Wordlist',
                    value: runnerInstance.selectedWordlistId == null
                        ? ''
                        : (wordlists.any(
                                (w) =>
                                    w.id == runnerInstance.selectedWordlistId,
                              )
                              ? runnerInstance.selectedWordlistId!
                              : wordlists.isNotEmpty
                              ? wordlists.first.id
                              : ''),
                    items: runnerInstance.selectedWordlistId == null
                        ? ['', ...wordlists.map((w) => w.id).toList()]
                        : wordlists.map((w) => w.id).toList(),
                    itemLabelBuilder: (String wordlistId) => wordlistId.isEmpty
                        ? 'Select Wordlist'
                        : wordlists.firstWhere((w) => w.id == wordlistId).name,
                    onChanged: runnerInstance.isRunning
                        ? (value) {}
                        : (value) {
                            ref
                                .read(multiRunnerProvider.notifier)
                                .updateSelectedWordlistForRunner(
                                  runnerId,
                                  value.isEmpty ? null : value,
                                );
                            onUpdateDashboard();
                          },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: GeistSpacing.sm),

          // Start/Stop button and Proxies dropdown
          Row(
            children: [
              Expanded(
                child: GeistButton(
                  fontSize: 14,
                  iconSize: 20,
                  text: runnerInstance.isRunning ? 'Stop Job' : 'Start Job',
                  variant: runnerInstance.isRunning
                      ? GeistButtonVariant.outline
                      : GeistButtonVariant.filled,
                  icon: Icon(
                    runnerInstance.isRunning ? Icons.stop : Icons.play_arrow,
                  ),
                  onPressed: () {
                    if (runnerInstance.isRunning) {
                      onStopPressed();
                    } else {
                      onStartPressed();
                    }
                  },
                ),
              ),
              SizedBox(width: GeistSpacing.xs),
              Expanded(
                child: GeistDropdown<String>(
                  label: 'Proxies: ${runnerInstance.selectedProxies}',
                  value: runnerInstance.selectedProxies,
                  items: const ['Off', 'Default', 'On'],
                  itemLabelBuilder: (String mode) => "Proxies: $mode",
                  onChanged: runnerInstance.isRunning
                      ? (value) {}
                      : (value) {
                          ref
                              .read(multiRunnerProvider.notifier)
                              .updateSelectedProxiesForRunner(runnerId, value);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
