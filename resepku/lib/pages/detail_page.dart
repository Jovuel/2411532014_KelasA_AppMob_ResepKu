import 'package:flutter/material.dart';
import 'package:resepku/models/recipe.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/recipe_image.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _servings;

  @override
  void initState(){
    super.initState();
    _servings = widget.recipe.servings;
  }

  void _addServing(){
    setState(() => _servings++);
  }

  void _removeServing(){
    if(_servings > 1){
      setState(() => _servings--);
    }
  }

  @override
  Widget build(BuildContext context){
    final recipe = widget.recipe;
    final totalCalories = recipe.caloriesPerServing * _servings;
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(recipe);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            flexibleSpace: FlexibleSpaceBar(
              background: RecipeImage(url: recipe.image),
              title: Text(recipe.name),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: () => context.read<FavoriteProvider>().toggle(recipe),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${recipe.cuisine} - ${recipe.difficulty} - ${recipe.totalTimeMinutes} menit',
                    style: textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Text('Porsi', style: textTheme.titleMedium),
                          const Spacer(),
                          IconButton.filledTonal(
                            onPressed: _servings > 1 ? _removeServing : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('$_servings', style: textTheme.titleLarge),
                          ),
                          IconButton.filledTonal(
                            onPressed: _addServing,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Total kalori: $totalCalories kkal', style: textTheme.titleMedium),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Bahan', style: textTheme.titleLarge),
                ),
              ],
            ),
          ),
          SliverList.builder(
            itemCount: recipe.ingredients.length,
            itemBuilder: (context, index) {
              final item = recipe.ingredients[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(item),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
