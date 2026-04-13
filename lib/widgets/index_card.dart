import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/nepse_index.dart';
import '../theme/app_theme.dart';

class IndexCard extends StatelessWidget {
  final NepseIndex index;

  const IndexCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final isGain = index.isGain;
    final color = isGain ? AppTheme.gain : AppTheme.loss;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isGain ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: color,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  index.index,
                  style: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            index.currentValue.toStringAsFixed(2),
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isGain ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 11,
                color: color,
              ),
              const SizedBox(width: 2),
              Text(
                '${index.change.abs().toStringAsFixed(2)} (${index.percentChange.abs().toStringAsFixed(2)}%)',
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
