# Product API Documentation

This document describes all API methods available for managing products (T-shirts), variants, and categories in the inventory system.

## Table of Contents
- [Product APIs](#product-apis)
- [Variant APIs](#variant-apis)
- [Category APIs](#category-apis)
- [Image Upload API](#image-upload-api)

---

## Product APIs

### 1. Get All Products
**Method:** `getTShirts()`

**Description:** Fetches all T-shirt products from the database with their variants, ordered by creation date (newest first).

**Return Type:** `Future<List<TShirt>>`

**Supabase Query:**
```dart
_client
  .from('tshirts')
  .select('*, variants(*)')
  .order('created_at', ascending: false)
```

**Usage Example:**
```dart
final products = await inventoryRepository.getTShirts();
```

---

### 2. Get Single Product
**Method:** `getTShirt(String id)`

**Description:** Fetches a specific T-shirt by its ID, including all variants.

**Parameters:**
- `id` (String): The UUID of the product

**Return Type:** `Future<TShirt>`

**Supabase Query:**
```dart
_client
  .from('tshirts')
  .select('*, variants(*)')
  .eq('id', id)
  .single()
```

**Usage Example:**
```dart
final product = await inventoryRepository.getTShirt('uuid-here');
```

---

### 3. Add New Product
**Method:** `addTShirt(TShirt tshirt)`

**Description:** Creates a new T-shirt product in the database. Automatically creates associated variants if provided.

**Parameters:**
- `tshirt` (TShirt): Product object containing all product details

**Fields Inserted:**
- `name`: Product name
- `description`: Product description
- `category_id`: UUID of the category
- `image_url`: URL of the product image (optional)
- `base_price`: Regular price
- `offer_price`: Discounted price (optional)
- `return_policy_days`: Return policy in days
- `priority_weight`: Display priority
- `is_active`: Whether product is active

**Return Type:** `Future<void>`

**Supabase Query:**
```dart
// Insert product
_client
  .from('tshirts')
  .insert({...})
  .select()
  .single()

// Insert variants (if any)
_client.from('variants').insert({
  'tshirt_id': tshirtId,
  'size': variant.size,
  'color': variant.color,
  'stock_quantity': variant.stockQuantity,
})
```

**Usage Example:**
```dart
final newProduct = TShirt(
  id: '',
  name: 'Classic White Tee',
  description: 'Comfortable cotton t-shirt',
  categoryId: 'category-uuid',
  basePrice: 29.99,
  // ... other fields
);
await inventoryRepository.addTShirt(newProduct);
```

---

### 4. Update Product
**Method:** `updateTShirt(TShirt tshirt)`

**Description:** Updates an existing T-shirt product. Note: This does not update variants.

**Parameters:**
- `tshirt` (TShirt): Product object with updated values

**Return Type:** `Future<void>`

**Supabase Query:**
```dart
_client
  .from('tshirts')
  .update({...})
  .eq('id', tshirt.id)
```

**Usage Example:**
```dart
product.basePrice = 34.99;
await inventoryRepository.updateTShirt(product);
```

---

### 5. Delete Product
**Method:** `deleteTShirt(String id)`

**Description:** Deletes a T-shirt product from the database. Variants are automatically deleted due to CASCADE constraints.

**Parameters:**
- `id` (String): The UUID of the product to delete

**Return Type:** `Future<void>`

**Supabase Query:**
```dart
_client.from('tshirts').delete().eq('id', id)
```

**Usage Example:**
```dart
await inventoryRepository.deleteTShirt('uuid-here');
```

---

## Variant APIs

### 6. Add Variant
**Method:** `addVariant(Variant variant)`

**Description:** Adds a new variant (size/color combination) to an existing product.

**Parameters:**
- `variant` (Variant): Variant object with size, color, and stock info

**Return Type:** `Future<void>`

**Supabase Query:**
```dart
_client.from('variants').insert(variant.toJson()..remove('id'))
```

**Usage Example:**
```dart
final variant = Variant(
  id: '',
  tshirtId: 'product-uuid',
  size: 'L',
  color: 'Blue',
  stockQuantity: 50,
);
await inventoryRepository.addVariant(variant);
```

---

### 7. Update Variant
**Method:** `updateVariant(Variant variant)`

**Description:** Updates an existing variant's details.

**Parameters:**
- `variant` (Variant): Variant object with updated values

**Return Type:** `Future<void>`

**Supabase Query:**
```dart
_client
  .from('variants')
  .update(variant.toJson()..remove('id')..remove('tshirt_id'))
  .eq('id', variant.id)
```

**Usage Example:**
```dart
variant.stockQuantity = 25;
await inventoryRepository.updateVariant(variant);
```

---

### 8. Delete Variant
**Method:** `deleteVariant(String id)`

**Description:** Deletes a specific variant.

**Parameters:**
- `id` (String): The UUID of the variant to delete

**Return Type:** `Future<void>`

**Supabase Query:**
```dart
_client.from('variants').delete().eq('id', id)
```

**Usage Example:**
```dart
await inventoryRepository.deleteVariant('variant-uuid');
```

---

## Category APIs

### 9. Get All Categories
**Method:** `getCategories()`

**Description:** Fetches all product categories from the database.

**Return Type:** `Future<List<Category>>`

**Supabase Query:**
```dart
_client.from('categories').select()
```

**Usage Example:**
```dart
final categories = await inventoryRepository.getCategories();
```

---

### 10. Add Category
**Method:** `addCategory(Category category)`

**Description:** Creates a new product category.

**Parameters:**
- `category` (Category): Category object with name and tax percentage

**Return Type:** `Future<void>`

**Supabase Query:**
```dart
_client.from('categories').insert({
  'name': category.name,
  'tax_percentage': category.taxPercentage,
})
```

**Usage Example:**
```dart
final category = Category(
  id: '',
  name: 'Hoodies',
  taxPercentage: 18.0,
);
await inventoryRepository.addCategory(category);
```

---

### 11. Get or Create Category
**Method:** `getOrCreateCategory(String name)`

**Description:** Searches for a category by name (case-insensitive). If found, returns it. If not found, creates a new category with default tax percentage (0%).

**Parameters:**
- `name` (String): Category name to search or create

**Return Type:** `Future<Category>`

**Supabase Queries:**
```dart
// Check if exists
_client
  .from('categories')
  .select()
  .ilike('name', name)
  .maybeSingle()

// Create if not found
_client
  .from('categories')
  .insert({
    'name': name,
    'tax_percentage': 0,
  })
  .select()
  .single()
```

**Usage Example:**
```dart
final category = await inventoryRepository.getOrCreateCategory('Oversized');
```

---

## Image Upload API

### 12. Upload Product Image
**Method:** `uploadImage(String filePath)`

**Description:** Uploads a product image to Supabase Storage and returns the public URL.

**Parameters:**
- `filePath` (String): Local file path of the image to upload

**Return Type:** `Future<String>` (Returns the public URL of the uploaded image)

**Supabase Storage Operations:**
```dart
// Upload file
_client.storage.from('products').upload(fileName, file)

// Get public URL
_client.storage.from('products').getPublicUrl(fileName)
```

**File Naming:** Files are named using timestamp + original filename:
`2024-12-30T12:15:00.000_image.jpg`

**Usage Example:**
```dart
final imageUrl = await inventoryRepository.uploadImage('/path/to/image.jpg');
// Use imageUrl when creating/updating product
```

---

## Database Tables

### tshirts
- `id` (UUID, Primary Key)
- `name` (TEXT)
- `description` (TEXT)
- `category_id` (UUID, Foreign Key → categories.id)
- `image_url` (TEXT, nullable)
- `base_price` (DECIMAL)
- `offer_price` (DECIMAL, nullable)
- `return_policy_days` (INTEGER)
- `priority_weight` (INTEGER)
- `is_active` (BOOLEAN)
- `created_at` (TIMESTAMP)

### variants
- `id` (UUID, Primary Key)
- `tshirt_id` (UUID, Foreign Key → tshirts.id, CASCADE DELETE)
- `size` (TEXT)
- `color` (TEXT)
- `stock_quantity` (INTEGER)

### categories
- `id` (UUID, Primary Key)
- `name` (TEXT, UNIQUE)
- `tax_percentage` (DECIMAL)

---

## Notes

1. **Authentication:** All APIs require authentication via Supabase RLS (Row Level Security)
2. **Error Handling:** All methods may throw exceptions on network/database errors
3. **Transactions:** Product insertion with variants is not atomic - if variant insertion fails, the product will still exist
4. **Cascade Deletes:** Deleting a product automatically deletes all its variants
5. **Ordering:** Product list is ordered by `created_at DESC` (newest first)
