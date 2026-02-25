import 'package:customer_order_app/core/themes/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  String title;
  IconData icon;
  Function(bool)? onChanged;
  bool? value;
  SettingCard({
    super.key,
    required this.title,
    required this.icon,
    this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // SvgPicture.asset(icon, width: 24, height: 24),
              Icon(icon),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          value != null
              ? CupertinoSwitch(
                  value: value!,
                  activeTrackColor: Colors.black,
                  inactiveTrackColor: ThemesApp.secondaryColor.withOpacity(0.5),
                  onChanged: (value) {
                    if (onChanged != null) {
                      onChanged!(value);
                    }
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
