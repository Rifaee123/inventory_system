import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/locator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../domain/entities/tshirt.dart';

import '../domain/entities/variant.dart';
import '../domain/repositories/inventory_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../interactor/inventory_bloc.dart';
import '../interactor/inventory_event.dart';
import '../interactor/inventory_state.dart';
import '../domain/entities/category.dart';

class InventoryFormPage extends StatelessWidget {
  final TShirt? tshirt;

  const InventoryFormPage({super.key, this.tshirt});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryBloc(
        repository: getIt<InventoryRepository>(),
        categoryRepository: getIt<CategoryRepository>(),
      )..add(LoadInventory()), // Load categories
      child: InventoryFormView(tshirt: tshirt),
    );
  }
}

class InventoryFormView extends StatefulWidget {
  final TShirt? tshirt;

  const InventoryFormView({super.key, this.tshirt});

  @override
  State<InventoryFormView> createState() => _InventoryFormViewState();
}

class _InventoryFormViewState extends State<InventoryFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _basePriceController;
  late TextEditingController _offerPriceController;
  late TextEditingController _returnPolicyController;
  late TextEditingController _weightController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  bool _isActive = true;

  // String? _selectedCategoryId; // Removed
  List<Variant> _variants = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tshirt?.name ?? '');
    _descController = TextEditingController(
      text: widget.tshirt?.description ?? '',
    );
    _basePriceController = TextEditingController(
      text: widget.tshirt?.basePrice.toString() ?? '',
    );
    _offerPriceController = TextEditingController(
      text: widget.tshirt?.offerPrice?.toString() ?? '',
    );
    _returnPolicyController = TextEditingController(
      text: widget.tshirt?.returnPolicyDays.toString() ?? '7',
    );
    _weightController = TextEditingController(
      text: widget.tshirt?.priorityWeight.toString() ?? '0',
    );
    _categoryController = TextEditingController();
    _imageUrlController = TextEditingController(
      text: widget.tshirt?.imageUrl ?? '',
    );
    _isActive = widget.tshirt?.isActive ?? true;

    // _selectedCategoryId = widget.tshirt?.categoryId; // Removed

    if (widget.tshirt != null && widget.tshirt!.variants.isNotEmpty) {
      _variants = List.from(widget.tshirt!.variants);
    } else {
      // Add one default empty variant
      _variants.add(
        const Variant(
          id: '',
          tshirtId: '',
          size: 'M',
          color: 'Black',
          stockQuantity: 0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _offerPriceController.dispose();
    _returnPolicyController.dispose();
    _weightController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // Logic for selected category ID removed
      /*
      if (_selectedCategoryId == null) {
        ...
      }
      */

      final newTShirt = TShirt(
        id: widget.tshirt?.id ?? '',
        name: _nameController.text,
        description: _descController.text,
        categoryId: '', // Will be resolved by Bloc
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
        basePrice: double.tryParse(_basePriceController.text) ?? 0,
        offerPrice: double.tryParse(_offerPriceController.text),
        returnPolicyDays: int.tryParse(_returnPolicyController.text) ?? 7,
        priorityWeight: int.tryParse(_weightController.text) ?? 0,
        isActive: _isActive,
        variants: _variants,
      );

      final categoryName = _categoryController.text.trim();

      if (widget.tshirt == null) {
        context.read<InventoryBloc>().add(
          AddTShirtWithCategoryName(newTShirt, categoryName),
        );
      } else {
        context.read<InventoryBloc>().add(
          UpdateTShirtWithCategoryName(newTShirt, categoryName),
        );
      }

      // Wait a bit and pop
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) context.pop();
      });
    }
  }

  void _addVariant() {
    setState(() {
      _variants.add(
        const Variant(
          id: '',
          tshirtId: '',
          size: 'M',
          color: 'Black',
          stockQuantity: 0,
        ),
      );
    });
  }

  void _removeVariant(int index) {
    setState(() {
      _variants.removeAt(index);
    });
  }

  void _updateVariant(int index, Variant updated) {
    setState(() {
      _variants[index] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tshirt != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state.status == InventoryStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          } else if (state.status == InventoryStatus.success) {
            // Listener to auto-fill category name if editing
            if (widget.tshirt != null &&
                _categoryController.text.isEmpty &&
                state.categories.isNotEmpty) {
              final cat = state.categories.firstWhere(
                (c) => c.id == widget.tshirt!.categoryId,
                orElse: () =>
                    const Category(id: '', name: '', taxPercentage: 0),
              );
              if (cat.id.isNotEmpty) {
                _categoryController.text = cat.name;
              }
            }

            if (state.tshirts.isNotEmpty) {
              // In a real app we might want a distinct "SubmissionSuccess" state
            }
          }
        },
        builder: (context, state) {
          if (state.status == InventoryStatus.loading &&
              state.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Product Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              border: OutlineInputBorder(),
                              helperText: 'Enter a valid image URL',
                            ),
                          ),
                          const SizedBox(height: 16),
                          RawAutocomplete<Category>(
                            textEditingController: _categoryController,
                            focusNode: FocusNode(),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<Category>.empty();
                                  }
                                  return state.categories.where((
                                    Category option,
                                  ) {
                                    return option.name.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },
                            displayStringForOption: (Category option) =>
                                option.name,
                            optionsViewBuilder:
                                (
                                  BuildContext context,
                                  AutocompleteOnSelected<Category> onSelected,
                                  Iterable<Category> options,
                                ) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                            80, // Approximate width
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                final Category option = options
                                                    .elementAt(index);
                                                return ListTile(
                                                  title: Text(option.name),
                                                  onTap: () {
                                                    onSelected(option);
                                                  },
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                            fieldViewBuilder:
                                (
                                  BuildContext context,
                                  TextEditingController
                                  fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted,
                                ) {
                                  return TextFormField(
                                    controller: fieldTextEditingController,
                                    focusNode: fieldFocusNode,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: OutlineInputBorder(),
                                      helperText:
                                          'Type to search or add a new one',
                                    ),
                                    validator: (v) =>
                                        v!.isEmpty ? 'Required' : null,
                                  );
                                },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pricing
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pricing & Policy',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _basePriceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Base Price (\$)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _offerPriceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Offer Price (\$)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _returnPolicyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Return Policy (Days)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Priority Weight',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Is Active'),
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Variants
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Variants',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton.icon(
                                onPressed: _addVariant,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Variant'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._variants.asMap().entries.map((entry) {
                            final index = entry.key;
                            final variant = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      initialValue: variant.size,
                                      decoration: const InputDecoration(
                                        labelText: 'Size',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      onChanged: (v) => _updateVariant(
                                        index,
                                        variant.copyWith(size: v),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      initialValue: variant.color,
                                      decoration: const InputDecoration(
                                        labelText: 'Color',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      onChanged: (v) => _updateVariant(
                                        index,
                                        variant.copyWith(color: v),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      initialValue: variant.stockQuantity
                                          .toString(),
                                      decoration: const InputDecoration(
                                        labelText: 'Qty',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) => _updateVariant(
                                        index,
                                        variant.copyWith(
                                          stockQuantity: int.tryParse(v) ?? 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeVariant(index),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: CustomButton(
                      label: isEditing ? 'Update Product' : 'Create Product',
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
