import 'package:flutter/material.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_tile.dart';
import 'package:resepku/pages/settings_page.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false;
  String? _cuisine;

  List<String> get _cuisines {
    final cuisines = dummyRecipes.map((r) => r.cuisine).toSet().toList()..sort();
    return ['Semua', ...cuisines];
  }

  List<Recipe> get _filteredRecipes {
    if(_cuisine == null || _cuisine == 'Semua') {
      return dummyRecipes;
    }
    return dummyRecipes.where((r) => r.cuisine == _cuisine).toList();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height:32),
            const SizedBox(width: 8),
            const Text('Resepku'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : "Tampilan grid",
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          const FavoriteBadgeButton(),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _cuisines.length,
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                final selected = (_cuisine == null && cuisine == 'Semua') || _cuisine == cuisine;
                return ChoiceChip(
                  label: Text(cuisine),
                  selected: selected,
                  onSelected: (bool picked) {
                    setState(() {
                      _cuisine = picked && cuisine != 'Semua' ? cuisine : null;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _isGrid ? _buildGrid(_filteredRecipes) : _buildList(_filteredRecipes),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeTile(recipe: recipes[index]);
      },
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 3 / 4,),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeGridCard(recipe: recipes[index]);
      },
    );
  }
}
