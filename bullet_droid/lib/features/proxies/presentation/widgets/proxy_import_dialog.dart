import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_input.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';

import 'package:bullet_droid/features/proxies/models/proxy_model.dart';

class ProxyImportDialog extends StatefulWidget {
  final Function(List<ProxyModel>) onImport;

  const ProxyImportDialog({super.key, required this.onImport});

  @override
  State<ProxyImportDialog> createState() => _ProxyImportDialogState();
}

class _ProxyImportDialogState extends State<ProxyImportDialog> {
  late TextEditingController _proxyListController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  ProxyType _selectedProxyType = ProxyType.http;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _proxyListController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _proxyListController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
        ),
        title: GeistText.headingMedium('Import Proxies'),
        content: SingleChildScrollView(
          child: SizedBox(
            height: 415,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Load from File Button
                GeistButton(
                  text: 'Load from File',
                  variant: GeistButtonVariant.outline,
                  onPressed: _loadFromFile,
                  width: double.infinity,
                ),

                const SizedBox(height: GeistSpacing.md),

                // Proxy List Text Field
                GeistText.bodyMedium('Proxies List'),
                const SizedBox(height: GeistSpacing.sm),
                Expanded(
                  child: GeistInput(
                    controller: _proxyListController,
                    placeholder:
                        'Enter proxies (one per line)\n1.1.1.1:80\n2.2.2.2:8080\n3.3.3.3:3128:user:pass',
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: 4,
                  ),
                ),

                // Advanced Syntax Information
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeistSpacing.md,
                    vertical: GeistSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: GeistColors.lightSurface,
                    borderRadius: BorderRadius.circular(
                      GeistBorders.radiusMedium,
                    ),
                    border: Border.all(color: GeistColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      GeistText.bodyMedium('Advanced Syntax:'),
                      SizedBox(height: GeistSpacing.xs),
                      GeistText.bodySmall(
                        'Type: (http)1.1.1.1:80',
                        customColor: GeistColors.lightTextSecondary,
                      ),
                      GeistText.bodySmall(
                        'Auth: 1.1.1.1:80:username:password',
                        customColor: GeistColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: GeistSpacing.md),

                // Proxy Type Dropdown
                GeistText.bodyMedium('Proxy Type'),
                const SizedBox(height: GeistSpacing.xs),
                _GeistDropdown<ProxyType>(
                  label: 'Proxy Type',
                  value: _selectedProxyType,
                  items: ProxyType.values,
                  itemLabelBuilder: (type) => type.name.toUpperCase(),
                  onChanged: (ProxyType newValue) {
                    setState(() {
                      _selectedProxyType = newValue;
                    });
                  },
                ),

                const SizedBox(height: GeistSpacing.md),

                // Optional Authentication Fields
                Row(
                  children: [
                    Expanded(
                      child: GeistInput(
                        label: 'Username',
                        controller: _usernameController,
                        placeholder: 'Enter username',
                      ),
                    ),
                    const SizedBox(width: GeistSpacing.md),
                    Expanded(
                      child: GeistInput(
                        label: 'Password',
                        controller: _passwordController,
                        placeholder: 'Enter password',
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          GeistButton(
            text: 'Cancel',
            variant: GeistButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          GeistButton(
            text: _isLoading ? 'Importing...' : 'Import Proxies',
            variant: GeistButtonVariant.filled,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _importProxies,
          ),
        ],
      ),
    );
  }

  Future<void> _loadFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        setState(() {
          _proxyListController.text = content;
        });
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorToast('Failed to load file: $e');
      }
    }
  }

  Future<void> _importProxies() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final proxyLines = _proxyListController.text.split('\n');
      final proxies = <ProxyModel>[];
      final seenAddresses = <String>{};

      final globalUsername = _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim();
      final globalPassword = _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim();

      for (final line in proxyLines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        ProxyModel? proxy;
        if (trimmed.startsWith('(') && trimmed.contains(')')) {
          final typeEndIndex = trimmed.indexOf(')');
          if (typeEndIndex > 1) {
            final typeStr = trimmed.substring(1, typeEndIndex).toLowerCase();
            final addressPart = trimmed.substring(typeEndIndex + 1);
            final proxyType = _parseProxyType(typeStr);
            proxy = _parseProxyWithType(
              addressPart,
              proxyType,
              globalUsername,
              globalPassword,
            );
          }
        } else {
          proxy = _parseProxyWithType(
            trimmed,
            _selectedProxyType,
            globalUsername,
            globalPassword,
          );
        }

        if (proxy != null) {
          final address = '${proxy.address}:${proxy.port}';
          if (!seenAddresses.contains(address)) {
            seenAddresses.add(address);
            proxies.add(proxy);
          }
        }
      }

      if (proxies.isNotEmpty) {
        widget.onImport(proxies);
        if (context.mounted) Navigator.of(context).pop();
      } else {
        if (context.mounted) context.showWarningToast('No valid proxies found');
      }
    } catch (e) {
      if (context.mounted) context.showErrorToast('Import failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  ProxyType _parseProxyType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'http':
        return ProxyType.http;
      case 'socks4':
        return ProxyType.socks4;
      case 'socks5':
        return ProxyType.socks5;
      default:
        return ProxyType.http;
    }
  }

  ProxyModel? _parseProxyWithType(
    String proxyStr,
    ProxyType type,
    String? globalUsername,
    String? globalPassword,
  ) {
    try {
      final parts = proxyStr.split(':');
      if (parts.length < 2) return null;

      final address = parts[0].trim();
      final port = int.tryParse(parts[1].trim());
      if (port == null) return null;

      // Determine username/password
      String? username = globalUsername;
      String? password = globalPassword;

      // If proxy line has auth info, use it instead of global
      if (parts.length >= 4) {
        username = parts[2].trim().isEmpty ? null : parts[2].trim();
        password = parts[3].trim().isEmpty ? null : parts[3].trim();
      }

      // Generate unique ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (address.hashCode + port.hashCode).abs();
      final uniqueId = '${timestamp}_$random';

      return ProxyModel(
        id: uniqueId,
        address: address,
        port: port,
        type: type,
        status: ProxyStatus.untested,
        username: username,
        password: password,
      );
    } catch (_) {
      return null;
    }
  }
}

class _GeistDropdown<T> extends StatefulWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final Widget? Function(T)? itemWidgetBuilder;
  final ValueChanged<T> onChanged;
  final bool isExpanded;
  final GlobalKey? dropdownKey;

  const _GeistDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.itemWidgetBuilder,
    required this.onChanged,
    this.isExpanded = false,
    this.dropdownKey,
  });

  @override
  State<_GeistDropdown<T>> createState() => _GeistDropdownState<T>();
}

class _GeistDropdownState<T> extends State<_GeistDropdown<T>> {
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  late GlobalKey _dropdownKey;

  @override
  void initState() {
    super.initState();
    _dropdownKey = widget.dropdownKey ?? GlobalKey();
    _isExpanded = widget.isExpanded;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dropdownKey,
      height: 44,
      decoration: BoxDecoration(
        color: GeistColors.white,
        border: Border.all(
          color: const Color.fromRGBO(218, 211, 214, 1),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: GeistText(
                    widget.itemLabelBuilder(widget.value),
                    variant: GeistTextVariant.bodyMedium,
                    fontWeight: FontWeight.bold,
                    customColor: GeistColors.black,
                    fontSize: 12.5,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: GeistColors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: position.dx,
              top: position.dy + size.height,
              width: size.width,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      border: Border.all(
                        color: const Color.fromRGBO(218, 211, 214, 1),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: widget.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast = index == widget.items.length - 1;

                        return _buildDropdownItem(item: item, isLast: isLast);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isExpanded = false;
    });
  }

  Widget _buildDropdownItem({required T item, bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _removeOverlay();
          widget.onChanged(item);
        },
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : const Radius.circular(12),
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: GeistColors.gray200, width: 0.5),
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.itemWidgetBuilder != null
                    ? (widget.itemWidgetBuilder!(item) ??
                          GeistText(
                            widget.itemLabelBuilder(item),
                            variant: GeistTextVariant.bodyMedium,
                            customColor: GeistColors.gray800,
                          ))
                    : GeistText(
                        widget.itemLabelBuilder(item),
                        variant: GeistTextVariant.bodyMedium,
                        customColor: GeistColors.gray800,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
