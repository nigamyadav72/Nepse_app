import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stock.dart';
import '../theme/app_theme.dart';

class StockTile extends StatelessWidget {
  final StockItem stock;
  final VoidCallback? onTap;
  final bool showRank;
  final int? rank;

  const StockTile({
    super.key,
    required this.stock,
    this.onTap,
    this.showRank = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isGain = stock.isGain;
    final color = isGain ? AppTheme.gain : AppTheme.loss;
    final bgColor = isGain ? AppTheme.gain.withOpacity(0.08) : AppTheme.loss.withOpacity(0.08);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Symbol avatar / rank
            if (showRank && rank != null) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Symbol Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              alignment: Alignment.center,
              child: Text(
                stock.symbol.length > 3
                    ? stock.symbol.substring(0, 3)
                    : stock.symbol,
                style: GoogleFonts.inter(
                  color: AppTheme.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Company info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (stock.companyName != null && stock.companyName!.isNotEmpty)
                    Text(
                      stock.companyName!,
                      style: GoogleFonts.inter(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      stock.totalVolume != null
                          ? 'Vol: ${_formatVolume(stock.totalVolume!)}'
                          : '',
                      style: GoogleFonts.inter(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            // Price & change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${_formatPrice(stock.ltp)}',
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGain ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 10,
                        color: color,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${stock.percentageChange.abs().toStringAsFixed(2)}%',
                        style: GoogleFonts.inter(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(1);
    }
    return price.toStringAsFixed(2);
  }

  String _formatVolume(int volume) {
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(1)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(1)}K';
    return volume.toString();
  }
}
