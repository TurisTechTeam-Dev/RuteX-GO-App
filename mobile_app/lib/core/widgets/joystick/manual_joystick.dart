import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:provider/provider.dart';

import '../../../features/mission/presentation/provider/trip_provider.dart';

class ManualJoystick extends StatelessWidget {
  const ManualJoystick({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10),
      child: Joystick(
        mode: JoystickMode.all,
        listener: (details) {
          context.read<TripSimulationProvider>().movePositionManual(
            details.x,
            details.y,
          );
        },
      ),
    );
  }
}