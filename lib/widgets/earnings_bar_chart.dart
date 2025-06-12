import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:parking_system/theme/app_colors.dart';
import 'package:parking_system/utils/constants.dart';

class EarningsBarChart extends StatefulWidget {
  final List<int> weeklyEarnings;

  const EarningsBarChart({super.key, required this.weeklyEarnings});

  @override
  State<EarningsBarChart> createState() => _EarningsBarChartState();
}

class _EarningsBarChartState extends State<EarningsBarChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (widget.weeklyEarnings.reduce((a, b) => a > b ? a : b)) + 1000,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.spot == null) {
                touchedIndex = null;
                return;
              }
              touchedIndex = response.spot!.touchedBarGroupIndex;
            });
          },
          touchTooltipData: BarTouchTooltipData(
            // getTooltipColor:
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.toY.toInt();
              return BarTooltipItem(
                "${Globals.numberFormat(widget.weeklyEarnings[groupIndex])} RWF\n",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Day ${group.x + 1}",
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitles,
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups:
            widget.weeklyEarnings.asMap().entries.map((entry) {
              final index = entry.key;
              final amount = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: amount.toDouble(),
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                    width: 10,
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SideTitleWidget(
      space: 8,
      meta: meta,
      child: Text(days[value.toInt()], style: const TextStyle(fontSize: 12)),
    );
  }
}
