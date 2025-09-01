import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid2/bullet_droid.dart';
import 'package:bullet_droid/shared/providers/custom_input_provider.dart';
import 'dart:async';
import 'package:bullet_droid/core/utils/logging.dart';

class CustomInputValueField extends ConsumerStatefulWidget {
  final CustomInput customInput;
  final String configId;

  const CustomInputValueField({
    super.key,
    required this.customInput,
    required this.configId,
  });

  @override
  ConsumerState<CustomInputValueField> createState() =>
      _CustomInputValueFieldState();
}

class _CustomInputValueFieldState extends ConsumerState<CustomInputValueField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasUnsavedChanges = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    // Listen for changes and auto-save with debounce
    _controller.addListener(_onTextChanged);

    // Initialize with saved value after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWithSavedValue();
    });
  }

  Future<void> _initializeWithSavedValue() async {
    if (!mounted) return;

    try {
      final savedValue = await ref
          .read(customInputProvider.notifier)
          .getCustomInputValue(
            widget.configId,
            widget.customInput.variableName,
          );

      if (mounted) {
        _controller.text = savedValue ?? '';
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      Log.w(
        'Error loading saved value for ${widget.customInput.variableName}: $e',
      );
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer for auto-save
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveValue();
    });
  }

  Future<void> _saveValue() async {
    if (mounted) {
      try {
        await ref
            .read(customInputProvider.notifier)
            .setCustomInputValue(
              widget.configId,
              widget.customInput.variableName,
              _controller.text,
            );

        if (mounted) {
          setState(() {
            _hasUnsavedChanges = false;
          });
        }
      } catch (e) {
        Log.w('Error saving custom input value: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isRequired = widget.customInput.isRequired;
    final hasValue = _controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.customInput.description,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (isRequired)
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (_hasUnsavedChanges)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Variable: ${widget.customInput.variableName}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: isRequired ? 'Required value' : 'Optional value',
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isRequired && !hasValue
                    ? Colors.red
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isRequired && !hasValue
                    ? Colors.red.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isRequired && !hasValue
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            suffixIcon: hasValue
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                    },
                  )
                : null,
          ),
          onChanged: (_) {
            // Text change is already handled by the listener
          },
        ),
        if (isRequired && !hasValue)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
