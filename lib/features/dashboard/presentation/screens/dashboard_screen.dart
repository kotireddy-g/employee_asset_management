import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/recent_activities_card.dart';
import '../widgets/quick_actions_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboardData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    await ref.read(dashboardProvider.notifier).loadDashboardData();
    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    // Show error snackbar if any
    ref.listen(dashboardProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                ref.read(dashboardProvider.notifier).clearError();
                _loadDashboardData();
              },
            ),
          ),
        );
      }
    });

    if (dashboardState.isLoading && dashboardState.stats == null) {
      return _buildLoadingState();
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 32),
              _buildStatsGrid(dashboardState.stats),
              const SizedBox(height: 32),
              _buildChartsSection(dashboardState.stats),
              const SizedBox(height: 32),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Admin! 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Here\'s what\'s happening with your assets today.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 500.ms)
                          .slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.calendar,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Today, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 700.ms, duration: 500.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Iconsax.chart_2,
                    color: Colors.white,
                    size: 60,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 500.ms)
                    .scale(begin: const Offset(0.5, 0.5))
                    .rotate(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats? dashboardStats) {
    // Default values for when data is loading or unavailable
    final stats = dashboardStats != null ? [
      StatsData(
        title: 'Total Employees',
        value: dashboardStats.totalEmployees.toString(),
        change: dashboardStats.employeeTrend,
        isPositive: dashboardStats.employeeTrend.startsWith('+'),
        icon: Iconsax.people,
        color: const Color(0xFF10B981),
      ),
      StatsData(
        title: 'Total Assets',
        value: dashboardStats.totalAssets.toString(),
        change: dashboardStats.assetTrend,
        isPositive: dashboardStats.assetTrend.startsWith('+'),
        icon: Iconsax.monitor,
        color: const Color(0xFF3B82F6),
      ),
      StatsData(
        title: 'Active Subscriptions',
        value: dashboardStats.activeSubscriptions.toString(),
        change: dashboardStats.subscriptionTrend,
        isPositive: dashboardStats.subscriptionTrend.startsWith('+'),
        icon: Icons.subscriptions,
        color: const Color(0xFF8B5CF6),
      ),
      StatsData(
        title: 'Pending Reminders',
        value: dashboardStats.pendingReminders.toString(),
        change: dashboardStats.reminderTrend,
        isPositive: dashboardStats.reminderTrend.startsWith('+'),
        icon: Iconsax.notification,
        color: const Color(0xFFF59E0B),
      ),
    ] : [
      // Loading placeholders
      StatsData(
        title: 'Total Employees',
        value: '--',
        change: '--',
        isPositive: true,
        icon: Iconsax.people,
        color: const Color(0xFF10B981),
      ),
      StatsData(
        title: 'Total Assets',
        value: '--',
        change: '--',
        isPositive: true,
        icon: Iconsax.monitor,
        color: const Color(0xFF3B82F6),
      ),
      StatsData(
        title: 'Active Subscriptions',
        value: '--',
        change: '--',
        isPositive: true,
        icon: Icons.subscriptions,
        color: const Color(0xFF8B5CF6),
      ),
      StatsData(
        title: 'Pending Reminders',
        value: '--',
        change: '--',
        isPositive: true,
        icon: Iconsax.notification,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return Stack(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: 4,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: StatsCard(data: stats[index]),
                ),
              ),
            );
          },
        ),
        // Loading overlay for stats
        if (ref.watch(dashboardProvider).isLoading && dashboardStats != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChartsSection(DashboardStats? dashboardStats) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AnimationConfiguration.staggeredList(
            position: 4,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ChartCard(
                  title: 'Asset Distribution',
                  child: _buildAssetChart(dashboardStats),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: AnimationConfiguration.staggeredList(
            position: 5,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: QuickActionsCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return AnimationConfiguration.staggeredList(
      position: 6,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: RecentActivitiesCard(),
        ),
      ),
    );
  }

  Widget _buildAssetChart(DashboardStats? dashboardStats) {
    final dashboardState = ref.watch(dashboardProvider);
    final assetDistribution = dashboardState.assetDistribution;

    return Container(
      height: 300,
      child: assetDistribution == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading asset distribution...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : assetDistribution.total == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.monitor,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No assets found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  if (assetDistribution.laptops > 0)
                    PieChartSectionData(
                      value: assetDistribution.laptops.toDouble(),
                      title: 'Laptops\n${assetDistribution.laptopsPercent.toInt()}%',
                      color: const Color(0xFF6366F1),
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (assetDistribution.desktops > 0)
                    PieChartSectionData(
                      value: assetDistribution.desktops.toDouble(),
                      title: 'Desktops\n${assetDistribution.desktopsPercent.toInt()}%',
                      color: const Color(0xFF8B5CF6),
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (assetDistribution.mobiles > 0)
                    PieChartSectionData(
                      value: assetDistribution.mobiles.toDouble(),
                      title: 'Mobiles\n${assetDistribution.mobilesPercent.toInt()}%',
                      color: const Color(0xFF10B981),
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (assetDistribution.tablets > 0)
                    PieChartSectionData(
                      value: assetDistribution.tablets.toDouble(),
                      title: 'Tablets\n${assetDistribution.tabletsPercent.toInt()}%',
                      color: const Color(0xFFF59E0B),
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (assetDistribution.others > 0)
                    PieChartSectionData(
                      value: assetDistribution.others.toDouble(),
                      title: 'Others\n${assetDistribution.othersPercent.toInt()}%',
                      color: const Color(0xFF6B7280),
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (assetDistribution.laptops > 0)
                _buildLegendItem('Laptops', assetDistribution.laptops, const Color(0xFF6366F1)),
              if (assetDistribution.desktops > 0)
                _buildLegendItem('Desktops', assetDistribution.desktops, const Color(0xFF8B5CF6)),
              if (assetDistribution.mobiles > 0)
                _buildLegendItem('Mobiles', assetDistribution.mobiles, const Color(0xFF10B981)),
              if (assetDistribution.tablets > 0)
                _buildLegendItem('Tablets', assetDistribution.tablets, const Color(0xFFF59E0B)),
              if (assetDistribution.others > 0)
                _buildLegendItem('Others', assetDistribution.others, const Color(0xFF6B7280)),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 800.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class StatsData {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  StatsData({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}