import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_input.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';

/// Form field with validation
class GeistFormField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;
  final String? helperText;
  final bool isRequired;
  final bool isDisabled;
  final bool obscureText;
  final GeistInputVariant variant;
  final GeistInputSize size;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final bool validateOnChange;
  final bool showCharacterCount;
  final EdgeInsetsGeometry? contentPadding;

  const GeistFormField({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.helperText,
    this.isRequired = false,
    this.isDisabled = false,
    this.obscureText = false,
    this.variant = GeistInputVariant.standard,
    this.size = GeistInputSize.medium,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
    this.validateOnChange = true,
    this.showCharacterCount = false,
    this.contentPadding,
  });

  @override
  State<GeistFormField> createState() => _GeistFormFieldState();
}

class _GeistFormFieldState extends State<GeistFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;
  bool _hasBeenFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _hasBeenFocused = true;
    } else if (_hasBeenFocused) {
      _validateField();
    }
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }

    if (widget.validateOnChange && _hasBeenFocused) {
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) _buildLabel(isMobile),
        _buildInput(isMobile),
        if (_errorText != null ||
            widget.helperText != null ||
            widget.showCharacterCount)
          _buildFooter(isMobile),
      ],
    );
  }

  Widget _buildLabel(bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: GeistSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: GeistText.labelMedium(
              widget.label!,
              color: GeistTextColor.primary,
            ),
          ),
          if (widget.isRequired) ...[
            SizedBox(width: GeistSpacing.xs),
            GeistText.labelMedium('*', color: GeistTextColor.error),
          ],
        ],
      ),
    );
  }

  Widget _buildInput(bool isMobile) {
    return GeistInput(
      placeholder: widget.placeholder,
      onChanged: (value) {
        // Handled by _onTextChanged
      },
      onEditingComplete: widget.onEditingComplete,
      errorText: _errorText,
      isDisabled: widget.isDisabled,
      obscureText: widget.obscureText,
      variant: widget.variant,
      size: widget.size,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction,
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(top: GeistSpacing.xs),
      child: Row(
        children: [
          Expanded(child: _buildHelperText()),
          if (widget.showCharacterCount && widget.maxLength != null)
            _buildCharacterCount(),
        ],
      ),
    );
  }

  Widget _buildHelperText() {
    if (_errorText != null) {
      return Row(
        children: [
          StatusIndicator(
            state: StatusIndicatorState.error,
            variant: StatusIndicatorVariant.dot,
            size: StatusIndicatorSize.small,
          ),
          SizedBox(width: GeistSpacing.xs),
          Expanded(
            child: GeistText.caption(_errorText!, color: GeistTextColor.error),
          ),
        ],
      );
    }

    if (widget.helperText != null) {
      return GeistText.caption(
        widget.helperText!,
        color: GeistTextColor.secondary,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCharacterCount() {
    final currentLength = _controller.text.length;
    final maxLength = widget.maxLength!;
    final isNearLimit = currentLength > maxLength * 0.8;
    final isOverLimit = currentLength > maxLength;

    return GeistText.caption(
      '$currentLength/$maxLength',
      color: isOverLimit
          ? GeistTextColor.error
          : isNearLimit
          ? GeistTextColor.warning
          : GeistTextColor.secondary,
    );
  }

  // Public method to validate field externally
  bool validate() {
    _validateField();
    return _errorText == null;
  }

  // Public method to clear validation
  void clearValidation() {
    setState(() {
      _errorText = null;
    });
  }
}

/// Specialized form field variants
class GeistFormFieldVariants {
  /// Email field with validation
  static Widget email({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    String? helperText,
    bool isRequired = false,
    bool isDisabled = false,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return GeistFormField(
      label: label ?? 'Email',
      placeholder: placeholder ?? 'Enter your email',
      value: value,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      helperText: helperText,
      isRequired: isRequired,
      isDisabled: isDisabled,
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Email is required';
        }
        if (value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        return null;
      },
    );
  }

  /// Password field with validation
  static Widget password({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    String? helperText,
    bool isRequired = false,
    bool isDisabled = false,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = false,
    int minLength = 8,
  }) {
    return GeistFormField(
      label: label ?? 'Password',
      placeholder: placeholder ?? 'Enter your password',
      value: value,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      helperText: helperText,
      isRequired: isRequired,
      isDisabled: isDisabled,
      obscureText: true,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Password is required';
        }
        if (value != null && value.isNotEmpty && value.length < minLength) {
          return 'Password must be at least $minLength characters';
        }
        return null;
      },
    );
  }

  /// Number field with validation
  static Widget number({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    String? helperText,
    bool isRequired = false,
    bool isDisabled = false,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = false,
    double? min,
    double? max,
    bool allowDecimals = true,
  }) {
    return GeistFormField(
      label: label ?? 'Number',
      placeholder: placeholder ?? 'Enter a number',
      value: value,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      helperText: helperText,
      isRequired: isRequired,
      isDisabled: isDisabled,
      keyboardType: allowDecimals
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: allowDecimals
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
          : [FilteringTextInputFormatter.digitsOnly],
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Number is required';
        }
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Please enter a valid number';
          }
          if (min != null && number < min) {
            return 'Number must be at least $min';
          }
          if (max != null && number > max) {
            return 'Number must not exceed $max';
          }
        }
        return null;
      },
    );
  }

  /// URL field with validation
  static Widget url({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    String? helperText,
    bool isRequired = false,
    bool isDisabled = false,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return GeistFormField(
      label: label ?? 'URL',
      placeholder: placeholder ?? 'https://example.com',
      value: value,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      helperText: helperText,
      isRequired: isRequired,
      isDisabled: isDisabled,
      keyboardType: TextInputType.url,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'URL is required';
        }
        if (value != null && value.isNotEmpty) {
          try {
            final uri = Uri.parse(value);
            if (!uri.hasScheme || !uri.hasAuthority) {
              return 'Please enter a valid URL';
            }
          } catch (e) {
            return 'Please enter a valid URL';
          }
        }
        return null;
      },
    );
  }

  /// Field with monospace font
  static Widget code({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    String? helperText,
    bool isRequired = false,
    bool isDisabled = false,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = false,
    int? maxLines,
    int? maxLength,
  }) {
    return GeistFormField(
      label: label ?? 'Code',
      placeholder: placeholder ?? 'Enter code',
      value: value,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      helperText: helperText,
      isRequired: isRequired,
      isDisabled: isDisabled,
      variant: GeistInputVariant.technical,
      maxLines: maxLines,
      maxLength: maxLength,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Code is required';
              }
              return null;
            }
          : null,
    );
  }

  /// Multi-line text area
  static Widget textarea({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    String? helperText,
    bool isRequired = false,
    bool isDisabled = false,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = false,
    int maxLines = 4,
    int? maxLength,
    bool showCharacterCount = false,
  }) {
    return GeistFormField(
      label: label ?? 'Message',
      placeholder: placeholder ?? 'Enter your message',
      value: value,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      helperText: helperText,
      isRequired: isRequired,
      isDisabled: isDisabled,
      maxLines: maxLines,
      maxLength: maxLength,
      showCharacterCount: showCharacterCount,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Message is required';
              }
              return null;
            }
          : null,
    );
  }
}

/// Form validation utilities
class GeistFormValidation {
  /// Check if all form fields are valid
  static bool validateForm(List<GlobalKey<_GeistFormFieldState>> fieldKeys) {
    bool allValid = true;

    for (final key in fieldKeys) {
      final field = key.currentState;
      if (field != null && !field.validate()) {
        allValid = false;
      }
    }

    return allValid;
  }

  /// Clear validation for all form fields
  static void clearFormValidation(
    List<GlobalKey<_GeistFormFieldState>> fieldKeys,
  ) {
    for (final key in fieldKeys) {
      key.currentState?.clearValidation();
    }
  }

  /// Common validation functions
  static String? required(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, {String? message}) {
    if (value != null && value.length < minLength) {
      return message ?? 'Must be at least $minLength characters';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, {String? message}) {
    if (value != null && value.length > maxLength) {
      return message ?? 'Must not exceed $maxLength characters';
    }
    return null;
  }

  static String? email(String? value, {String? message}) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid email address';
      }
    }
    return null;
  }

  static String? url(String? value, {String? message}) {
    if (value != null && value.isNotEmpty) {
      try {
        final uri = Uri.parse(value);
        if (!uri.hasScheme || !uri.hasAuthority) {
          return message ?? 'Please enter a valid URL';
        }
      } catch (e) {
        return message ?? 'Please enter a valid URL';
      }
    }
    return null;
  }

  static String? number(String? value, {String? message}) {
    if (value != null && value.isNotEmpty) {
      if (double.tryParse(value) == null) {
        return message ?? 'Please enter a valid number';
      }
    }
    return null;
  }

  static String? range(
    String? value,
    double min,
    double max, {
    String? message,
  }) {
    if (value != null && value.isNotEmpty) {
      final number = double.tryParse(value);
      if (number == null) {
        return 'Please enter a valid number';
      }
      if (number < min || number > max) {
        return message ?? 'Must be between $min and $max';
      }
    }
    return null;
  }
}
