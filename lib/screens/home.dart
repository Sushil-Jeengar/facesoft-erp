import 'package:flutter/material.dart';
import 'package:facesoft/widget/home_company.dart';
import 'package:facesoft/widget/profile_data.dart';
import 'package:facesoft/widget/slider.dart';
import 'package:facesoft/widget/special_plan_section.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onSeeAllPressed; // Callback to pass to CompanyOverviewCard

  const HomePage({super.key, required this.onSeeAllPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: [
          const SliderWidget(),
          const DashboardCard(),
          SpecialPlanSection(),
          CompanyOverviewCard(onSeeAllPressed: onSeeAllPressed),
        ],
      ),
    );
  }
}
