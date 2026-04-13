import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/market_summary.dart';
import '../theme/app_theme.dart';

class MarketSummaryCard extends StatelessWidget {
  final MarketSummary summary;
  final bool isMarketOpen;

  const MarketSummaryCard({
    super.key,
    required this.summary,
    this.isMarketOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2F5A), Color(0xFF0D1B36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A4070), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Market Summary',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMarketOpen
                        ? AppTheme.gain.withOpacity(0.15)
                        : AppTheme.textTertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMarketOpen
                          ? AppTheme.gain.withOpacity(0.4)
                          : AppTheme.textTertiary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isMarketOpen ? AppTheme.gain : AppTheme.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isMarketOpen ? 'LIVE' : 'CLOSED',
                        style: GoogleFonts.inter(
                          color: isMarketOpen ? AppTheme.gain : AppTheme.textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _formatCurrency(summary.totalTurnover),
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Total Turnover',
              style: GoogleFonts.inter(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatBox(
                  label: 'Transactions',
                  value: _formatNumber(summary.totalTransactions),
                  icon: Icons.receipt_long_rounded,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  label: 'Traded Shares',
                  value: _formatNumber(summary.totalTradedShares),
                  icon: Icons.bar_chart_rounded,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  label: 'Scrips Traded',
                  value: summary.totalScripsTraded.toString(),
                  icon: Icons.account_balance_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1e9) return 'Rs. ${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return 'Rs. ${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return 'Rs. ${(value / 1e3).toStringAsFixed(2)}K';
    return 'Rs. ${value.toStringAsFixed(0)}';
  }

  String _formatNumber(int value) {
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: AppTheme.primary.withOpacity(0.8)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppTheme.textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
