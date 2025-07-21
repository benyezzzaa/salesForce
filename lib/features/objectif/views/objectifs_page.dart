// 📁 lib/features/objectifs/views/objectifs_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pfe/features/objectif/controller/objectifs_controller.dart';
import '../models/objectif_model.dart';

class ObjectifsPage extends StatelessWidget {
  const ObjectifsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ObjectifsController controller = Get.put(ObjectifsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Objectifs", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F51B5)),
            ),
          );
        }

        if (controller.objectifs.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildGlobalObjectiveCard(controller),
              const SizedBox(height: 24),
              _buildObjectivesChart(controller),
              const SizedBox(height: 24),
              _buildObjectivesList(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF3F51B5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.track_changes,
              size: 60,
              color: Color(0xFF3F51B5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Aucun objectif disponible",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F51B5),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vos objectifs apparaîtront ici",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vos Objectifs",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Suivez vos performances",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalObjectiveCard(ObjectifsController controller) {
    // Calculer l'objectif global
    double totalObjective = 0;
    double totalRealised = 0;
    
    for (var obj in controller.objectifs) {
      totalObjective += obj.objectif ?? 0;
      totalRealised += obj.realise ?? 0;
    }
    
    double globalPercentage = totalObjective > 0 ? (totalRealised / totalObjective) * 100 : 0;
    bool isGlobalAchieved = globalPercentage >= 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: isGlobalAchieved ? Colors.green : const Color(0xFF3F51B5),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Objectif Global",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${globalPercentage.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isGlobalAchieved ? Colors.green : const Color(0xFF3F51B5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: globalPercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGlobalAchieved ? Colors.green : const Color(0xFF3F51B5),
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isGlobalAchieved ? Colors.green.shade50 : const Color(0xFF3F51B5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isGlobalAchieved ? Icons.check_circle : Icons.trending_up,
                  color: isGlobalAchieved ? Colors.green : const Color(0xFF3F51B5),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Réalisé", "${totalRealised.toStringAsFixed(1)}%", Colors.green),
              _buildStatItem("Objectif", "${totalObjective.toStringAsFixed(1)}%", const Color(0xFF3F51B5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildObjectivesChart(ObjectifsController controller) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Color(0xFF3F51B5)),
              SizedBox(width: 12),
              Text(
                "Graphique des Objectifs",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 120,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < controller.objectifs.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              controller.objectifs[value.toInt()].categorie ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: controller.objectifs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final obj = entry.value;
                  final isAchieved = obj.atteint ?? false;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: obj.objectif ?? 0,
                        color: const Color(0xFF3F51B5).withOpacity(0.3),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: obj.realise ?? 0,
                        color: isAchieved ? Colors.green : const Color(0xFF3F51B5),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesList(ObjectifsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.list, color: Color(0xFF3F51B5)),
                const SizedBox(width: 12),
                const Text(
                  "Détail des Objectifs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.objectifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final obj = controller.objectifs[index];
              final isAtteint = obj.atteint ?? false;
              final realiseValue = obj.realise ?? 0.0;
              final objectifValue = obj.objectif ?? 0.0;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAtteint ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAtteint ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAtteint ? Icons.check_circle : Icons.pending,
                          color: isAtteint ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Période : '
                                '${obj.dateDebut.day.toString().padLeft(2, '0')}/'
                                '${obj.dateDebut.month.toString().padLeft(2, '0')}/'
                                '${obj.dateDebut.year} - '
                                '${obj.dateFin.day.toString().padLeft(2, '0')}/'
                                '${obj.dateFin.month.toString().padLeft(2, '0')}/'
                                '${obj.dateFin.year}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAtteint ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAtteint ? "Atteint" : "En cours",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Objectif: ${objectifValue.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Réalisé: ${realiseValue.toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isAtteint ? Colors.green : const Color(0xFF3F51B5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: objectifValue > 0 ? realiseValue / objectifValue : 0,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isAtteint ? Colors.green : const Color(0xFF3F51B5),
                            ),
                            strokeWidth: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
