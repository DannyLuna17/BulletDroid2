import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/typography.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';

enum GeistInputVariant { standard, technical }

enum GeistInputSize { small, medium, large }

class GeistInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final String? errorText;
  final String? helperText;
  final bool isDisabled;
  final bool isRequired;
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

  const GeistInput({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.onEditingComplete,
    this.errorText,
    this.helperText,
    this.isDisabled = false,
    this.isRequired = false,
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
  });

  @override
  State<GeistInput> createState() => _GeistInputState();
}

class _GeistInputState extends State<GeistInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  // ignore: unused_field
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    if (widget.onChanged != null) {
      _controller.addListener(() {
        widget.onChanged!(_controller.text);
      });
    }
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
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInput(context, hasError),
        if (widget.errorText != null || widget.helperText != null) ...[
          SizedBox(height: 4),
          _buildHelperText(hasError),
        ],
      ],
    );
  }

  Widget _buildInput(BuildContext context, bool hasError) {
    final backgroundColor = _getBackgroundColor();
    final textStyle = _getTextStyle();
    final height = _getHeight();
    final padding = _getPadding();

    return Container(
      height: widget.maxLines == 1 ? height : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: GeistBorders.inputRadius,
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(left: GeistSpacing.md),
              child: IconTheme(
                data: IconThemeData(
                  color: GeistColors.lightTextSecondary,
                  size: _getIconSize(),
                ),
                child: widget.prefixIcon!,
              ),
            ),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !widget.isDisabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              autofocus: widget.autofocus,
              textInputAction: widget.textInputAction,
              onEditingComplete: widget.onEditingComplete,
              style: textStyle,
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: textStyle.copyWith(
                  fontSize: 17,
                  color: GeistColors.lightTextPrimary,
                ),
                hintText: widget.placeholder,
                hintStyle: textStyle.copyWith(
                  color: GeistColors.lightTextTertiary,
                ),
                border: InputBorder.none,
                contentPadding: padding,
                counterText: '',
              ),
            ),
          ),
          if (widget.suffixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(right: GeistSpacing.md),
              child: IconTheme(
                data: IconThemeData(
                  color: GeistColors.lightTextSecondary,
                  size: _getIconSize(),
                ),
                child: widget.suffixIcon!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHelperText(bool hasError) {
    final text = hasError ? widget.errorText! : widget.helperText!;
    final color = hasError
        ? GeistColors.errorColor
        : GeistColors.lightTextSecondary;

    return Text(text, style: GeistTypography.caption.copyWith(color: color));
  }

  Color _getBackgroundColor() {
    if (widget.isDisabled) {
      return GeistColors.gray100;
    }

    return GeistColors.lightSurface;
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.variant == GeistInputVariant.technical
        ? _getTechnicalTextStyle()
        : _getStandardTextStyle();

    final color = widget.isDisabled
        ? GeistColors.lightTextTertiary
        : GeistColors.lightTextPrimary;

    return baseStyle.copyWith(color: color);
  }

  TextStyle _getStandardTextStyle() {
    switch (widget.size) {
      case GeistInputSize.small:
        return GeistTypography.bodySmall;
      case GeistInputSize.medium:
        return GeistTypography.bodyMedium;
      case GeistInputSize.large:
        return GeistTypography.bodyLarge;
    }
  }

  TextStyle _getTechnicalTextStyle() {
    switch (widget.size) {
      case GeistInputSize.small:
        return GeistTypography.codeSmall;
      case GeistInputSize.medium:
        return GeistTypography.codeMedium;
      case GeistInputSize.large:
        return GeistTypography.codeLarge;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case GeistInputSize.small:
        return 32;
      case GeistInputSize.medium:
        return GeistSpacing.touchTargetMin;
      case GeistInputSize.large:
        return GeistSpacing.touchTargetComfortable;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case GeistInputSize.small:
        return EdgeInsets.symmetric(
          horizontal: GeistSpacing.sm,
          vertical: GeistSpacing.xs,
        );
      case GeistInputSize.medium:
        return EdgeInsets.symmetric(
          horizontal: GeistSpacing.md,
          vertical: GeistSpacing.sm,
        );
      case GeistInputSize.large:
        return EdgeInsets.symmetric(
          horizontal: GeistSpacing.lg,
          vertical: GeistSpacing.md,
        );
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case GeistInputSize.small:
        return 16;
      case GeistInputSize.medium:
        return 18;
      case GeistInputSize.large:
        return 20;
    }
  }
}
