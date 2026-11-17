import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/recipe_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({ super.key });

  @override
  Widget build(BuildContext context){
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFavoritesEmpty = favoriteProvider.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit saya'),
        actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          tooltip: "Hapus semua",
          onPressed: isFavoritesEmpty ? null : () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Hapus Semua Favorit'),
                  content: const Text('Apakah  anda yakin ingin menghapus semua resep dari daftar favorit?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<FavoriteProvider>().clear();
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
        ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favorite, child) {
          if(favorite.count == 0) {
            return const Center(
              child: Text(
                'Belum ada resep favorit.\nTekan ikon hati di daftar resep.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: favorite.items.length,
            separatorBuilder: (a, b) => const Divider(),
            itemBuilder: (context, index) {
              final recipe = favorite.items[index];
              return Dismissible(
                key: ValueKey(recipe.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  context.read<FavoriteProvider>().toggle(recipe);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${recipe.name} dihapus dari favorit')),
                  );
                },
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: RecipeImage(url: recipe.image, cacheWidth: 168),
                    ),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(recipe.cuisine),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => favorite.toggle(recipe),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
