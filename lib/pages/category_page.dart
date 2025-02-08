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

  void openUpdateBox(Category category) {
    TextEditingController updateController =
        TextEditingController(text: category.name);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(9), topRight: Radius.circular(9))),
            height: MediaQuery.of(context).size.height * 0.49,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Text(
                  "Modifier la catégorie",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: MediaQuery.of(context).size.height * 0.019,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                MyTextField(
                    hintText: "Nom de catégorie",
                    isPhone: false,
                    controller: updateController),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                MyButton(
                    text: "Enregister",
                    onTap: () =>
                        updateCategory(category.id!, updateController.text))
              ],
            ),
          );
        });
  }

  //save_category method
  void saveCategory() async {
    if (nameCategory.text.isNotEmpty) {
      if (!fetchCategoriesName().contains(nameCategory.text)) {
        try {
          Category newCategory = Category(name: nameCategory.text);

          await _databaseHelper.insertCategory(newCategory);

          _loadCategories();

          if (!mounted) return;

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

  void updateCategory(int id, String newName) async {
    if (newName.isNotEmpty) {
      if (!fetchCategoriesName().contains(newName)) {
        try {
          Category updatedCategory = Category(id: id, name: newName);

          await _databaseHelper.updateCategory(updatedCategory);

          _loadCategories();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Catégorie modifié",
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              duration:
                  Duration(seconds: 2), // Durée d'affichage de la SnackBar
            ),
          );
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
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Text(
                        "Nouvelle catégorie",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: screenHeight * 0.019,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      MyTextField(
                          hintText: "Nom de catégorie",
                          isPhone: false,
                          controller: nameCategory),
                      SizedBox(
                        height: screenHeight * 0.05,
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
                onEditPressed: (p0) => openUpdateBox(category),
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
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "$error",
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
              backgroundColor: Colors.red,
              duration:
                  Duration(seconds: 2), // Durée d'affichage de la SnackBar
            ),
          );
        }
      },
      child: const Text(
        "Supprimer",
        style: TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        "Retour",
        style: TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }
}
