import 'package:flutter/material.dart';
import 'package:the_budget_iq/models/date_range.dart';

// A pill-shaped button showing the currently selected date range.
// Tap it to open a dropdown menu of options.
class DateRangeDropdown extends StatelessWidget {
  final DateRangeOption selected;
  final ValueChanged<DateRangeOption> onSelected;

  const DateRangeDropdown({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  // Show all options in the menu, with the current one checked.
  Future<void> _showMenu(BuildContext context) async {
    // Get the position of this widget so the menu appears anchored to it.
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final picked = await showMenu<DateRangeOption>(
      context: context,
      position: position,
      // Use white background, clean rounded corners.
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: DateRangeOption.values.map((opt) {
        final isCurrent = opt == selected;
        return PopupMenuItem<DateRangeOption>(
          value: opt,
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCurrent
                        ? const Color(0xFF4338CA)
                        : const Color(0xFF111827),
                    fontWeight:
                    isCurrent ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isCurrent)
                const Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF4338CA),
                ),
            ],
          ),
        );
      }).toList(),
    );

    // showMenu returns null if the user dismisses without picking.
    if (picked != null && picked != selected) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Color(0xFF4B5563),
            ),
            const SizedBox(width: 6),
            Text(
              selected.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xFF4B5563),
            ),
          ],
        ),
      ),
    );
  }
}