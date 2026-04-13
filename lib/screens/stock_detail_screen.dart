import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company.dart';
import '../services/nepse_api.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loader.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final _api = NepseApiService();
  CompanyDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getCompanyDetails(widget.symbol);
      if (mounted) setState(() { _detail = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppTheme.background,
          leading: _backButton(),
          expandedHeight: 200,
          flexibleSpace: const FlexibleSpaceBar(
            background: ShimmerSummaryCard(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const ShimmerCard(),
            childCount: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: _backButton(),
        title: Text(widget.symbol),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.loss, size: 56),
            const SizedBox(height: 16),
            Text(
              'Could not load ${widget.symbol}',
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'The API may not have details for this stock.\nTry again later.',
              style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final d = _detail!;
    final isGain = d.isGain;
    final color = isGain ? AppTheme.gain : AppTheme.loss;

    return CustomScrollView(
      slivers: [
        // Header
        SliverAppBar(
          backgroundColor: AppTheme.background,
          leading: _backButton(),
          expandedHeight: 220,
          pinned: true,
          title: Text(
            d.symbol,
            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeader(d, color, isGain),
          ),
        ),
        // Stats Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Today\'s Trading'),
                const SizedBox(height: 12),
                _buildStatsGrid(d),
                const SizedBox(height: 20),
                if (_hasFundamentals(d)) ...[
                  _sectionTitle('Fundamentals'),
                  const SizedBox(height: 12),
                  _buildFundamentals(d),
                  const SizedBox(height: 20),
                ],
                if (d.weeks52High != null || d.weeks52Low != null) ...[
                  _sectionTitle('52-Week Range'),
                  const SizedBox(height: 12),
                  _build52WeekRange(d),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(CompanyDetail d, Color color, bool isGain) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGain
              ? [const Color(0xFF0D2A22), AppTheme.background]
              : [const Color(0xFF2A0D14), AppTheme.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      d.symbol,
                      style: GoogleFonts.inter(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (d.sector != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.sector!,
                        style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                d.companyName,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    d.ltp != null ? 'Rs. ${d.ltp!.toStringAsFixed(2)}' : 'N/A',
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (d.change != null && d.percentChange != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isGain ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            size: 12,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${d.change!.abs().toStringAsFixed(2)} (${d.percentChange!.abs().toStringAsFixed(2)}%)',
                            style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(CompanyDetail d) {
    final items = <MapEntry<String, String?>>[
      MapEntry('Open', d.openPrice != null ? 'Rs. ${d.openPrice!.toStringAsFixed(2)}' : 'N/A'),
      MapEntry('High', d.highPrice != null ? 'Rs. ${d.highPrice!.toStringAsFixed(2)}' : 'N/A'),
      MapEntry('Low', d.lowPrice != null ? 'Rs. ${d.lowPrice!.toStringAsFixed(2)}' : 'N/A'),
      MapEntry('Prev. Close', d.previousClose != null ? 'Rs. ${d.previousClose!.toStringAsFixed(2)}' : 'N/A'),
      MapEntry('Volume', d.totalVolume != null ? _formatNumber(d.totalVolume!) : 'N/A'),
      MapEntry('Turnover', d.totalTurnover != null ? _formatCurrency(d.totalTurnover!) : 'N/A'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatCell(label: items[i].key, value: items[i].value ?? 'N/A'),
    );
  }

  bool _hasFundamentals(CompanyDetail d) =>
      d.eps != null || d.pe != null || d.bookValue != null || d.pbv != null || d.marketCap != null;

  Widget _buildFundamentals(CompanyDetail d) {
    final items = <MapEntry<String, String?>>[
      if (d.eps != null) MapEntry('EPS', d.eps!.toStringAsFixed(2)),
      if (d.pe != null) MapEntry('P/E Ratio', d.pe!.toStringAsFixed(2)),
      if (d.bookValue != null) MapEntry('Book Value', d.bookValue!.toStringAsFixed(2)),
      if (d.pbv != null) MapEntry('P/BV', d.pbv!.toStringAsFixed(2)),
      if (d.marketCap != null) MapEntry('Market Cap', _formatCurrency(d.marketCap!)),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: items.length < 3 ? items.length : 3,
        childAspectRatio: 1.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatCell(label: items[i].key, value: items[i].value ?? 'N/A'),
    );
  }

  Widget _build52WeekRange(CompanyDetail d) {
    final high = d.weeks52High;
    final low = d.weeks52Low;
    final ltp = d.ltp;

    double progress = 0.5;
    if (high != null && low != null && ltp != null && high != low) {
      progress = ((ltp - low) / (high - low)).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('52W Low', style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 11)),
                  Text(
                    low != null ? 'Rs. ${low.toStringAsFixed(2)}' : 'N/A',
                    style: GoogleFonts.inter(color: AppTheme.loss, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('52W High', style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 11)),
                  Text(
                    high != null ? 'Rs. ${high.toStringAsFixed(2)}' : 'N/A',
                    style: GoogleFonts.inter(color: AppTheme.gain, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                d.isGain ? AppTheme.gain : AppTheme.loss,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          if (ltp != null)
            Center(
              child: Text(
                'Current: Rs. ${ltp.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: AppTheme.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _backButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary, size: 18),
      ),
      onPressed: () => Navigator.pop(context),
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

class _StatCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
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
        ],
      ),
    );
  }
}
