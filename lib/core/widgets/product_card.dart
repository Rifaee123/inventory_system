import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/tshirt.dart';

class ProductCard extends StatelessWidget {
  final TShirt tshirt;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.tshirt, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine status based on "stock" (using variants for calculation in real app, mock for now)
    // For demo purposes, we will assume some properties or mock them as Entity doesn't have totalStock property directly available on top level properly without aggregation.
    // We will simulate the look based on the design.

    // Calculate total stock from all variants
    final int stockCount = tshirt.variants.fold<int>(
      0,
      (sum, variant) => sum + variant.stockQuantity,
    );
    final bool isLowStock = stockCount < 10 && stockCount > 0;
    final bool isOutOfStock = stockCount == 0;

    Color statusColor = const Color(0xFF078841); // Green
    Color statusBg = const Color(0xFFDCFCE7);
    String statusText = 'In Stock';

    if (isLowStock) {
      statusColor = const Color(0xFFCA8A04); // Yellow/Gold
      statusBg = const Color(0xFFFEF9C3);
      statusText = 'Low Stock';
    } else if (isOutOfStock) {
      statusColor = const Color(0xFFDC2626); // Red
      statusBg = const Color(0xFFFEE2E2);
      statusText = 'Out of Stock';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7F3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1313EC).withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 16,
              spreadRadius: -4,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // For rounded corners on image
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  tshirt.imageUrl != null
                      ? Image.network(
                          tshirt.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  // "Hover" type quick actions overlay (simulated as always visible or just bottom)
                  // In mobile/touch, hover isn't great. We can put quick select dots at bottom of image maybe?
                  // Following design:
                  /*
                <div class="flex gap-2">
                  <button>S</button>...
                </div>
                */
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category', // Should be cat name
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4C4C9A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tshirt.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0D0D1B),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE7E7F3)),
                        ),
                        child: Text(
                          '\$${tshirt.basePrice.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0D0D1B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stock Bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: stockCount / 100, // Normalized
                            backgroundColor: const Color(0xFFE7E7F3),
                            color: statusColor,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$stockCount left',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4C4C9A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
