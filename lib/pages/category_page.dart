import 'package:expense_tracker/components/category_tile.dart';
import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/components/my_textfield.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/category_model.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController nameCategory = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<Category> categories = await _databaseHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  List<String> fetchCategoriesName() {
    return _categories.map((a) => a.name).toList();
  }

  void openDeleteBox(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Voulez-vous supprimez cette catégorie ?",
          style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontFamily: "Poppins",
              fontSize: 15),
        ),
        actions: [
          _cancelButton(),
          _deleteButton(category.id!),
        ],
      ),
    );
  }

  //save_category method
  void saveCategory() async {
    if (nameCategory.text.isNotEmpty) {
      if (!fetchCategoriesName().contains(nameCategory.text)) {
        try {
          Category newCategory = Category(name: nameCategory.text);

          await _databaseHelper.insertCategory(newCategory);

          _loadCategories();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Catégorie ajouté",
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              duration:
                  Duration(seconds: 2), // Durée d'affichage de la SnackBar
            ),
          );
          nameCategory.clear();
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Erreur : $e",
                style: const TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(
                  seconds: 2), // Durée d'affichage de la SnackBar
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Erreur !"),
            content: const Text(
              "Cette catégorie existe déjà",
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
            actions: [
              _cancelButton(),
            ],
          ),
        );
        nameCategory.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir le champ",
            style: TextStyle(
              fontFamily: "Poppins",
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2), // Durée d'affichage de la SnackBar
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(9),
                          topRight: Radius.circular(9))),
                  height: screenHeight * 0.49,
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      MyTextField(
                          hintText: "Nom de catégorie",
                          isPhone: false,
                          controller: nameCategory),
                      SizedBox(
                        height: screenHeight * 0.07,
                      ),
                      MyButton(text: "Enregister", onTap: saveCategory)
                    ],
                  ),
                );
              });
        },
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.02,
          ),
          Expanded(
              child: ListView.separated(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryTile(
                category: category,
                onEditPressed: (context) {},
                onDelPressed: (p0) => openDeleteBox(category),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                  height: 10); // Espace de 10 pixels entre les éléments
            },
          )),
        ],
      ),
    );
  }

  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);
        try {
          await _databaseHelper.deleteCategory(id);
          _loadCategories();
        } catch (error) {
          print(error);
        }
      },
      child: const Text("Supprimer"),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Retour"),
    );
  }
}
