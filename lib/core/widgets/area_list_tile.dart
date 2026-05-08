import 'package:flutter/material.dart' ;

class AreaListTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const AreaListTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioGroup<String>(
          groupValue: isSelected ? title : null,
          onChanged: (_) => onTap(),
          child: RadioListTile<String>(
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF000000),
              ),
            ),
            value: title,
            activeColor: const Color(0xFF00872D),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        const Divider(
        height: 1,
        color: Color(0xFFEEEEEE)),
      ],
    );
  }
}