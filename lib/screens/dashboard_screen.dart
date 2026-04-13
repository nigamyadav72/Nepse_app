import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/market_summary.dart';
import '../models/nepse_index.dart';
import '../models/stock.dart';
import '../services/nepse_api.dart';
import '../theme/app_theme.dart';
import '../widgets/index_card.dart';
import '../widgets/market_summary_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/stock_tile.dart';
import 'stock_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = NepseApiService();
  Timer? _refreshTimer;

  MarketSummary? _summary;
  List<NepseIndex> _indices = [];
  List<StockItem> _gainers = [];
  List<StockItem> _losers = [];

  bool _loadingSummary = true;
  bool _loadingIndices = true;
  bool _loadingGainers = true;
  bool _loadingLosers = true;
  String? _error;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) => _loadAll());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _error = null);
    await Future.wait([
      _loadSummary(),
      _loadIndices(),
      _loadGainers(),
      _loadLosers(),
    ]);
    setState(() => _lastUpdated = DateTime.now());
  }

  Future<void> _loadSummary() async {
    try {
      final data = await _api.getMarketSummary();
      if (mounted) setState(() { _summary = data; _loadingSummary = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingSummary = false; _error = e.toString(); });
    }
  }

  Future<void> _loadIndices() async {
    try {
      final data = await _api.getNepseIndex();
      if (mounted) setState(() { _indices = data; _loadingIndices = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingIndices = false);
    }
  }

  Future<void> _loadGainers() async {
    try {
      final data = await _api.getTopGainers();
      if (mounted) setState(() { _gainers = data.take(5).toList(); _loadingGainers = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingGainers = false);
    }
  }

  Future<void> _loadLosers() async {
    try {
      final data = await _api.getTopLosers();
      if (mounted) setState(() { _losers = data.take(5).toList(); _loadingLosers = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingLosers = false);
    }
  }

  bool get _isMarketOpen {
    final now = DateTime.now();
    final weekday = now.weekday;
    // NEPSE trades Sun–Thu, ~11am–3pm Nepal time (UTC+5:45)
    if (weekday == DateTime.friday || weekday == DateTime.saturday) return false;
    final hour = now.hour;
    final minute = now.minute;
    final timeInMinutes = hour * 60 + minute;
    return timeInMinutes >= 11 * 60 && timeInMinutes <= 15 * 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.card,
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            if (_error != null) _buildErrorBanner(),
            SliverToBoxAdapter(child: _buildSummarySection()),
            SliverToBoxAdapter(child: _buildIndicesSection()),
            SliverToBoxAdapter(child: _buildGainersSection()),
            SliverToBoxAdapter(child: _buildLosersSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      floating: true,
      snap: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEPSE',
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (_lastUpdated != null)
                Text(
                  'Updated ${_formatTime(_lastUpdated!)}',
                  style: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loadAll,
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.loss.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.loss.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppTheme.loss, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Could not connect to NEPSE API. Pull to retry.',
                style: GoogleFonts.inter(color: AppTheme.loss, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      child: _loadingSummary
          ? const ShimmerSummaryCard()
          : _summary != null
              ? MarketSummaryCard(summary: _summary!, isMarketOpen: _isMarketOpen)
              : _emptyState('Market summary unavailable'),
    );
  }

  Widget _buildIndicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Market Indices', null),
        if (_loadingIndices)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => ShimmerBox(width: 160, height: 100, borderRadius: 14),
            ),
          )
        else if (_indices.isEmpty)
          _emptyState('No index data available')
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _indices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => IndexCard(index: _indices[i]),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGainersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Top Gainers 📈', () => _showFullList(true)),
        if (_loadingGainers)
          ...List.generate(3, (_) => const ShimmerCard())
        else if (_gainers.isEmpty)
          _emptyState('No gainers data available')
        else
          ..._gainers.asMap().entries.map(
            (e) => StockTile(
              stock: e.value,
              rank: e.key + 1,
              showRank: true,
              onTap: () => _navigateToDetail(e.value.symbol),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLosersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Top Losers 📉', () => _showFullList(false)),
        if (_loadingLosers)
          ...List.generate(3, (_) => const ShimmerCard())
        else if (_losers.isEmpty)
          _emptyState('No losers data available')
        else
          ..._losers.asMap().entries.map(
            (e) => StockTile(
              stock: e.value,
              rank: e.key + 1,
              showRank: true,
              onTap: () => _navigateToDetail(e.value.symbol),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(String title, VoidCallback? onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 13),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  void _navigateToDetail(String symbol) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: symbol)),
    );
  }

  void _showFullList(bool isGainers) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullListScreen(isGainers: isGainers),
      ),
    );
  }
}

class _FullListScreen extends StatefulWidget {
  final bool isGainers;
  const _FullListScreen({required this.isGainers});

  @override
  State<_FullListScreen> createState() => _FullListScreenState();
}

class _FullListScreenState extends State<_FullListScreen> {
  final _api = NepseApiService();
  List<StockItem> _stocks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = widget.isGainers
          ? await _api.getTopGainers()
          : await _api.getTopLosers();
      if (mounted) setState(() { _stocks = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text(widget.isGainers ? 'Top Gainers' : 'Top Losers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? ListView.builder(
              itemCount: 10,
              itemBuilder: (_, __) => const ShimmerCard(),
            )
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppTheme.loss)))
              : ListView.builder(
                  itemCount: _stocks.length,
                  itemBuilder: (_, i) => StockTile(
                    stock: _stocks[i],
                    rank: i + 1,
                    showRank: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StockDetailScreen(symbol: _stocks[i].symbol),
                      ),
                    ),
                  ),
                ),
    );
  }
}
