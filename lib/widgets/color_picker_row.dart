import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:monny/utils/picker_options.dart';

class ColorPickerRow extends StatelessWidget {
  final int selectedColorValue;
  final void Function(int colorValue) onChanged;

  const ColorPickerRow({
    super.key,
    required this.selectedColorValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('pick_color'.tr,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: colors.outline)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: kPickerColors.map((color) {
              final isSelected = color.toARGB32() == selectedColorValue;
              return GestureDetector(
                onTap: () => onChanged(color.toARGB32()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: colors.onSurface, width: 2.5)
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check,
                          color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
