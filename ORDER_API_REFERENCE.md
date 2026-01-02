# Order Module API Reference

This document provides a technical overview of the Order module, including its data models, repository methods, and database structure.

## 1. Data Models (Entities)

### `Order`
The primary entity for a sales transaction.

| Property | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique UUID (Primary Key). |
| `customerName` | `String` | Full name of the customer. |
| `customerEmail` | `String` | Contact email address. |
| `customerPhone` | `String` | Contact phone number. |
| `deliveryAddress` | `String` | Full shipping address. |
| `totalAmount` | `double` | Grand total (calculated as items + tax + shipping). |
| `taxAmount` | `double` | Tax component of the total. |
| `deliveryCharges` | `double` | Fees for delivery/shipping. |
| `status` | `String` | Enum: `pending`, `packing`, `dispatched`, `delivered`, `cancelled`. |
| `createdAt` | `DateTime` | Timestamp of order creation. |
| `items` | `List<OrderItem>` | Collection of products in this order. |

### `OrderItem`
A specific product variant added to an order.

| Property | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique UUID. |
| `orderId` | `String` | Reference to parent Order. |
| `variantId` | `String` | Reference to the T-shirt variant. |
| `quantity` | `int` | Number of units purchased. |
| `salePrice` | `double` | Unit price at time of sale. |
| `costPrice` | `double` | Unit cost at time of sale (for profit calculation). |

---

## 2. OrderRepository (Service Interface)

The `OrderRepository` defines the abstract contract for interacting with order data.

### Fetching Data
- **`getOrders({String? statusFilter, String? searchQuery})`**
  - Returns: `Future<List<Order>>`
  - Purpose: Fetches orders with optional filtering.
- **`getOrder(String id)`**
  - Returns: `Future<Order>`
  - Purpose: Fetches a single order including all its line items.

### Mutations
- **`createOrder(Order order)`**
  - Returns: `Future<void>`
  - Purpose: Inserts a new order and its items.
- **`updateOrder(Order order)`**
  - Returns: `Future<void>`
  - Purpose: Updates order metadata (customer info, total, etc).
- **`updateOrderStatus(String id, String status)`**
  - Returns: `Future<void>`
  - Purpose: Specific method to transition order status.
- **`deleteOrder(String id)`**
  - Returns: `Future<void>`
  - Purpose: Deletes an order and its associated items.

### Utilities
- **`calculateDeliveryCharges(double orderTotal)`**
  - Returns: `double`
  - Purpose: Logic for automated shipping calculation.

---

## 3. Database Schema (Supabase)

### Table: `orders`
```sql
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT,
    delivery_address TEXT,
    total_amount DECIMAL(12, 2) NOT NULL,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    delivery_charges DECIMAL(12, 2) DEFAULT 0,
    status TEXT DEFAULT 'pending'
);
```

### Table: `order_items`
```sql
CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES public.variants(id),
    quantity INTEGER NOT NULL,
    sale_price DECIMAL(12, 2) NOT NULL,
    cost_price DECIMAL(12, 2) NOT NULL
);
```

---

## 4. Integration Logic

### Stock Triggers
The module is integrated with database-level triggers (`handle_order_status_stock_change`):
- **PENDING -> PACKING**: Deducts `item.quantity` from `variants.stock_quantity`.
- **ANY -> CANCELLED**: Restores items to stock.

### Analytics Integration
The `AnalyticsPage` and `DashboardPage` consume order data via the `DashboardRepository`, which aggregates:
- `totalSales`: Sum of `total_amount`.
- `netProfit`: Sum of `(sale_price - cost_price) * quantity`.
- `topSizes`: Aggregated `quantity` grouped by `size`.
