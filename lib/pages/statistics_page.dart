import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/song_database.dart';
import '../models/song.dart';
import 'song_detail_page.dart';
import '../l10n/app_localizations.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class ChartData {
  final String date;
  final int value;
  final Color color;

  ChartData(this.date, this.value, this.color);
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<List<Map<String, dynamic>>> _usageDataFuture;
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _usageDataFuture = SongDatabase.instance.getUsageWithSongs();
    _songsFuture = SongDatabase.instance.getAllSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.statistics)),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _usageDataFuture = SongDatabase.instance.getUsageWithSongs();
            _songsFuture = SongDatabase.instance.getAllSongs();
          });
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(),

                const SizedBox(height: 24),

                // Top Songs by Usage
                Text(
                  AppLocalizations.of(context)!.top_songs_by_usage,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildTopSongsList(),

                const SizedBox(height: 24),

                // Usage Chart
                Text(
                  AppLocalizations.of(context)!.usage_over_time,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildUsageChart(),

                const SizedBox(height: 24),

                // Meeting Types Breakdown
                Text(
                  AppLocalizations.of(context)!.usage_by_meeting_type,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildMeetingTypesChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usageDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final usageData = snapshot.data ?? [];

        // Calculate summary stats
        int totalUsages = usageData.length;
        Set<String> uniqueSongs = {};
        Set<DateTime> uniqueDates = {};

        for (var record in usageData) {
          uniqueSongs.add(record['title'].toString());

          DateTime date = DateTime.parse(record['used_at'].toString());
          uniqueDates.add(
            DateTime(date.year, date.month, date.day),
          ); // Normalize to day
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  AppLocalizations.of(context)!.total_usages,
                  totalUsages.toString(),
                  Icons.play_circle_outline,
                ),
                _buildStatCard(
                  AppLocalizations.of(context)!.unique_songs,
                  uniqueSongs.length.toString(),
                  Icons.music_note,
                ),
                _buildStatCard(
                  AppLocalizations.of(context)!.active_days,
                  uniqueDates.length.toString(),
                  Icons.calendar_today,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSongsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usageDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final usageData = snapshot.data ?? [];

        // Count usages per song
        Map<String, int> songUsageCounts = {};
        for (var record in usageData) {
          String title = record['title'].toString();
          songUsageCounts[title] = (songUsageCounts[title] ?? 0) + 1;
        }

        // Sort by usage count descending
        var sortedEntries = songUsageCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Get top 10 songs
        var topSongs = sortedEntries.take(10).toList();

        if (topSongs.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.no_collections_yet, // Reusing this text since it's similar
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topSongs.length,
            itemBuilder: (context, index) {
              final entry = topSongs[index];
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(
                  AppLocalizations.of(
                    context,
                  )!.times_used(entry.value.toString()),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  // Find the actual song object by title
                  final allSongs = await SongDatabase.instance.getAllSongs();
                  final song = allSongs.firstWhere(
                    (s) => s.title == entry.key,
                    orElse: () => allSongs.first,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailPage(song: song),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUsageChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usageDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final usageData = snapshot.data ?? [];

        // Group by date
        Map<DateTime, int> usageByDate = {};
        for (var record in usageData) {
          DateTime rawDate = DateTime.parse(record['used_at'].toString());
          DateTime date = DateTime(rawDate.year, rawDate.month, rawDate.day);
          usageByDate[date] = (usageByDate[date] ?? 0) + 1;
        }

        // Convert to chart data
        List<FlSpot> spots =
            usageByDate.entries
                .map(
                  (entry) => FlSpot(
                    entry.key.millisecondsSinceEpoch.toDouble(),
                    entry.value.toDouble(),
                  ),
                )
                .toList()
              ..sort((a, b) => a.x.compareTo(b.x));

        if (spots.isEmpty) {
          return Card(
            child: SizedBox(
              height: 200,
              child: const Center(
                child: Text(
                  'No usage data to display',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return Card(
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: spots.length > 1
                          ? (spots.last.x - spots.first.x) / 5
                          : spots.first.x,
                      getTitlesWidget: (value, meta) {
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          value.toInt(),
                        );
                        return Text("${date.month}/${date.day}");
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withAlpha(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeetingTypesChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usageDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final usageData = snapshot.data ?? [];

        // Group by meeting type
        Map<String, int> usageByType = {};
        for (var record in usageData) {
          String type = record['meeting_type'].toString();
          usageByType[type] = (usageByType[type] ?? 0) + 1;
        }

        // Create pie chart data
        List<PieChartSectionData> sections = usageByType.entries
            .toList()
            .asMap()
            .entries
            .map((entry) {
              int index = entry.key;
              var item = entry.value;
              double radius = 70.0; // Reduced radius to fit better in card
              double value = item.value.toDouble();

              return PieChartSectionData(
                color: _getColorForIndex(index),
                value: value,
                title: "${item.key}: ${item.value}",
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: 10, // Smaller font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            })
            .toList();

        if (sections.isEmpty) {
          return Card(
            child: SizedBox(
              height: 200,
              child: const Center(
                child: Text(
                  'No usage data to display',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return Card(
          child: SizedBox(
            height: 250, // Increased height to accommodate chart
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30, // Reduced center space
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback:
                      (FlTouchEvent event, PieTouchResponse? response) {},
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
