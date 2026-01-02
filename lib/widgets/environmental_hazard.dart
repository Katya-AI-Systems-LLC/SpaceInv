import 'package:flutter/material.dart';
import '../models/environmental_hazard.dart';

class EnvironmentalHazardWidget extends StatelessWidget {
  final EnvironmentalHazard hazard;
  final double time;
  
  const EnvironmentalHazardWidget({
    super.key,
    required this.hazard,
    this.time = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main hazard body
        _buildHazardBody(),
        
        // Effect radius indicator for certain hazards
        if (hazard.affectsPlayer || hazard.affectsProjectiles)
          _buildEffectRadius(),
        
        // Animated effects
        _buildAnimatedEffects(),
      ],
    );
  }
  
  Widget _buildHazardBody() {
    switch (hazard.type) {
      case HazardType.asteroid:
        return Container(
          width: hazard.width,
          height: hazard.height,
          decoration: BoxDecoration(
            color: hazard.color,
            borderRadius: BorderRadius.circular(hazard.width * 0.3),
            border: Border.all(
              color: Colors.brown[600]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
          child: CustomPaint(
            painter: AsteroidPainter(),
          ),
        );
        
      case HazardType.spaceDebris:
        return Container(
          width: hazard.width,
          height: hazard.height,
          decoration: BoxDecoration(
            color: hazard.color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.grey[600]!,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.construction,
            color: Colors.grey[800]!,
            size: hazard.width * 0.6,
          ),
        );
        
      case HazardType.blackHole:
        return Container(
          width: hazard.width,
          height: hazard.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.black,
                Colors.purple[900]!,
                Colors.purple[700]!,
              ],
            ),
            borderRadius: BorderRadius.circular(hazard.width / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.8),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.radio_button_unchecked,
            color: Colors.white.withOpacity(0.8),
            size: hazard.width * 0.8,
          ),
        );
        
      case HazardType.solarFlare:
        return Container(
          width: hazard.width,
          height: hazard.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.yellow[400]!,
                Colors.orange[400]!,
                Colors.red[400]!,
              ],
            ),
            borderRadius: BorderRadius.circular(hazard.height * 0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: hazard.width * 0.6,
          ),
        );
        
      case HazardType.comet:
        return Container(
          width: hazard.width,
          height: hazard.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue[200]!,
                Colors.lightBlue[400]!,
                Colors.blue[600]!,
              ],
            ),
            borderRadius: BorderRadius.circular(hazard.width * 0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.lightBlue.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.ac_unit,
            color: Colors.white,
            size: hazard.width * 0.5,
          ),
        );
        
      case HazardType.nebula:
        return Container(
          width: hazard.width,
          height: hazard.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                hazard.color,
                hazard.color.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(hazard.width * 0.5),
          ),
          child: Icon(
            Icons.cloud,
            color: Colors.white.withOpacity(0.6),
            size: hazard.width * 0.7,
          ),
        );
    }
  }
  
  Widget _buildEffectRadius() {
    return Container(
      width: hazard.effectRadius * 2,
      height: hazard.effectRadius * 2,
      decoration: BoxDecoration(
        border: Border.all(
          color: hazard.color.withOpacity(0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(hazard.effectRadius),
      ),
    );
  }
  
  Widget _buildAnimatedEffects() {
    switch (hazard.type) {
      case HazardType.blackHole:
        return Transform.rotate(
          angle: hazard.rotation,
          child: Container(
            width: hazard.width * 1.2,
            height: hazard.height * 1.2,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.purple.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(hazard.width * 0.6),
            ),
          ),
        );
        
      case HazardType.solarFlare:
        return Transform.rotate(
          angle: hazard.rotation,
          child: Container(
            width: hazard.width * 1.3,
            height: hazard.height * 1.3,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange.withOpacity(0.4),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(hazard.height * 0.4),
            ),
          ),
        );
        
      case HazardType.nebula:
        return Container(
          width: hazard.width,
          height: hazard.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                hazard.color.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(hazard.width * 0.5),
          ),
        );
        
      default:
        return const SizedBox.shrink();
    }
  }
}

class AsteroidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw crater-like patterns
    final center = Offset(size.width / 2, size.height / 2);
    
    // Main crater
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.1),
      size.width * 0.15,
      paint,
    );
    
    // Secondary crater
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.2),
      size.width * 0.1,
      paint,
    );
    
    // Small crater
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.25),
      size.width * 0.08,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
