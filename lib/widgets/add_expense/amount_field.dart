import 'package:flutter/material.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;

  const AmountField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing label, kept as-is
        const Text(
          'Amount (GH₵)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),

        // Existing amount input field, kept as-is
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  'GH₵',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              hintText: '0.00',
              hintStyle: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 12),
            ),
          ),
        ),

        // Adds spacing between the input field and the new chips
        const SizedBox(height: 16),

        // NEW: Section label that tells users what the chips below are for
        const Text(
          'Quick Amounts',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),

        // NEW: Wrap widget displays preset amount chips in a row
        // that automatically wraps to the next line on smaller screens
        Wrap(
          spacing: 8,    // horizontal gap between chips
          runSpacing: 8, // vertical gap when chips wrap to a new line
          children: [10, 50, 100, 200, 500].map((preset) {
            return GestureDetector(
              // NEW: When tapped, fill the amount field with the preset value
              onTap: () {
                controller.text = preset.toString();

                // NEW: Move the cursor to the end of the text
                // so the user can keep typing to adjust the amount
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              },

              // NEW: The chip itself, styled to match the Set Budget screen
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'GH₵$preset',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        //
      ],
    );
  }
}