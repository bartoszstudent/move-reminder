import 'package:flutter/material.dart';
import '../models/tip_model.dart';

class TipCard extends StatelessWidget {
  final ActivityTip tip;

  const TipCard({Key? key, required this.tip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  tip.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            tip.description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Row(
              //   children: [
              //     Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
              //     SizedBox(width: 4),
              //     // Text(
              //     //   '${tip.durationMinutes} min',
              //     //   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              //     // ),
              //   ],
              // ),
              // Row(
              //   children: [
              //     Icon(
              //       Icons.local_fire_department,
              //       size: 16,
              //       color: Colors.orange,
              //     ),
              //     SizedBox(width: 4),
              //     // Text(
              //     //   '${tip.caloriesBurned} kcal',
              //     //   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              //     // ),
              //   ],
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
