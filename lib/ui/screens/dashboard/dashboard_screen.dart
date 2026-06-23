import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/theme/app_theme.dart';
import 'package:health_track_app/domain/models/health_entry.dart';
import 'package:health_track_app/ui/widgets/health_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  MealType? _filter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showMealEditor([MealEntry? meal]) async {
    final appState = AppScope.read(context);
    final nameController = TextEditingController(text: meal?.name ?? '');
    final caloriesController = TextEditingController(
      text: '${meal?.calories ?? ''}',
    );
    final proteinController = TextEditingController(
      text: '${meal?.protein ?? ''}',
    );
    final carbsController = TextEditingController(text: '${meal?.carbs ?? ''}');
    final fatController = TextEditingController(text: '${meal?.fat ?? ''}');
    var type = meal?.type ?? MealType.breakfast;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  6,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            meal == null ? 'Add meal' : 'Edit meal',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          if (meal != null)
                            IconButton(
                              tooltip: 'Delete meal',
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                final route = ModalRoute.of(context);
                                await appState.deleteMeal(meal.id);
                                if (navigator.mounted &&
                                    (route?.isCurrent ?? false)) {
                                  navigator.pop();
                                }
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Meal name',
                          prefixIcon: Icon(Icons.restaurant_rounded),
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Enter a meal name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<MealType>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Meal type',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: MealType.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setSheetState(() => type = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberField(
                              controller: caloriesController,
                              label: 'Calories',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumberField(
                              controller: proteinController,
                              label: 'Protein g',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberField(
                              controller: carbsController,
                              label: 'Carbs g',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NumberField(
                              controller: fatController,
                              label: 'Fat g',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final nextMeal = MealEntry(
                            id:
                                meal?.id ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            name: nameController.text.trim(),
                            type: type,
                            calories: int.parse(caloriesController.text),
                            protein: int.parse(proteinController.text),
                            carbs: int.parse(carbsController.text),
                            fat: int.parse(fatController.text),
                            createdAt: meal?.createdAt ?? DateTime.now(),
                          );
                          final navigator = Navigator.of(context);
                          final route = ModalRoute.of(context);
                          if (meal == null) {
                            await appState.addMeal(
                              name: nextMeal.name,
                              type: nextMeal.type,
                              calories: nextMeal.calories,
                              carbs: nextMeal.carbs,
                              fat: nextMeal.fat,
                              protein: nextMeal.protein,
                            );
                          } else {
                            await appState.updateMeal(nextMeal);
                          }
                          if (navigator.mounted &&
                              (route?.isCurrent ?? false)) {
                            navigator.pop();
                          }
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(meal == null ? 'Save meal' : 'Update meal'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final profile = appState.profile;
    final meals = appState.searchMeals(_searchController.text, type: _filter);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 720 ? 4 : 2;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: _DashboardHeader(name: profile.name),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: width >= 720 ? 1.35 : 1.05,
                children: [
                  HealthStatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    value: '${appState.dailyCalories}',
                    subtitle: 'Target ${appState.dailyCalorieTarget}',
                    color: AppColors.accent,
                    progress:
                        appState.dailyCalories / appState.dailyCalorieTarget,
                  ),
                  HealthStatCard(
                    icon: Icons.fitness_center_rounded,
                    label: 'Protein',
                    value: '${appState.dailyProtein}g',
                    subtitle: 'Target ${appState.dailyProteinTarget}g',
                    color: AppColors.secondary,
                    progress:
                        appState.dailyProtein / appState.dailyProteinTarget,
                  ),
                  HealthStatCard(
                    icon: Icons.water_drop_rounded,
                    label: 'Water',
                    value: '${appState.metrics.waterMl}ml',
                    subtitle: 'Daily goal 2500ml',
                    color: AppColors.primary,
                    progress: appState.metrics.waterMl / 2500,
                  ),
                  HealthStatCard(
                    icon: Icons.monitor_weight_rounded,
                    label: 'BMI',
                    value: appState.bmi.toStringAsFixed(1),
                    subtitle:
                        '${appState.currentWeightKg.toStringAsFixed(1)}kg - ${appState.bmiCategory}',
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    const Text(
                      'Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _showMealEditor(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Meal'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search meals',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<MealType?>(
                      tooltip: 'Filter meals',
                      onSelected: (value) => setState(() => _filter = value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: null, child: Text('All')),
                        ...MealType.values.map(
                          (type) => PopupMenuItem(
                            value: type,
                            child: Text(type.name),
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.filter_list_rounded),
                    ),
                  ],
                ),
              ),
            ),
            if (meals.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'No meals yet',
                    message:
                        'Add breakfast, lunch, snacks, or dinner to calculate nutrition.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.separated(
                  itemCount: meals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tileColor: Theme.of(context).colorScheme.surface,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accent.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      title: Text(
                        meal.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        '${meal.type.name} - ${meal.protein}g protein',
                      ),
                      trailing: Text(
                        '${meal.calories} kcal',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onTap: () => _showMealEditor(meal),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your daily health plan is ready.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Image.asset('assets/logo.png', width: 58, height: 58),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final number = int.tryParse(value ?? '');
        if (number == null || number < 0) return 'Required';
        return null;
      },
    );
  }
}
