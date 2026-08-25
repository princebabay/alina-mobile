import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/app_colors.dart';

class SessionCodeField extends StatefulWidget {
  const SessionCodeField({
    super.key,
    required this.onChanged,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<SessionCodeField> createState() => _SessionCodeFieldState();
}

class _SessionCodeFieldState extends State<SessionCodeField> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  String get _code => _controllers.map((controller) => controller.text).join();

  void _notifyChanged() => widget.onChanged(_code);

  void _handleChanged(int index, String value) {
    final characters = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (characters.length > 1) {
      for (
        var offset = 0;
        offset < characters.length && index + offset < 6;
        offset++
      ) {
        _controllers[index + offset].text = characters[offset];
      }
      final nextIndex = (index + characters.length).clamp(0, 5) as int;
      _focusNodes[nextIndex].requestFocus();
    } else if (characters.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (characters.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _notifyChanged();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 44,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            textInputAction: index == 5
                ? TextInputAction.done
                : TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            onChanged: (value) {
              final upper = value.toUpperCase();

              if (value != upper) {
                _controllers[index].value = TextEditingValue(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }

              _handleChanged(index, upper);
            },
            onSubmitted: (_) {
              if (index < 5) _focusNodes[index + 1].requestFocus();
            },
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceSecondary,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        );
      }),
    );
  }
}
