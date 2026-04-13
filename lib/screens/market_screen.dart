import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stock.dart';
import '../services/nepse_api.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/stock_tile.dart';
import 'stock_detail_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  final _api = NepseApiService();
  late TabController _tabController;
  Timer? _refreshTimer;

  List<StockItem> _liveMarket = [];
  List<StockItem> _filteredMarket = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'volume'; // volume, change, ltp

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLiveMarket();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadLiveMarket());
    _searchController.addListener(_filterStocks);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveMarket() async {
    try {
      final data = await _api.getLiveMarket();
      if (mounted) {
        setState(() {
          _liveMarket = data;
          _filteredMarket = _applySort(data);
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _filterStocks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      final filtered = _liveMarket.where((s) {
        return s.symbol.toLowerCase().contains(query) ||
            (s.companyName?.toLowerCase().contains(query) ?? false);
      }).toList();
      _filteredMarket = _applySort(filtered);
    });
  }

  List<StockItem> _applySort(List<StockItem> stocks) {
    final copy = List<StockItem>.from(stocks);
    switch (_sortBy) {
      case 'change':
        copy.sort((a, b) => b.percentageChange.abs().compareTo(a.percentageChange.abs()));
        break;
      case 'ltp':
        copy.sort((a, b) => b.ltp.compareTo(a.ltp));
        break;
      case 'volume':
      default:
        copy.sort((a, b) => (b.totalVolume ?? 0).compareTo(a.totalVolume ?? 0));
        break;
    }
    return copy;
  }

  void _changeSort(String sort) {
    setState(() {
      _sortBy = sort;
      _filteredMarket = _applySort(_filteredMarket);
    });
  }

  List<StockItem> get _gainers => _filteredMarket.where((s) => s.isGain).toList();
  List<StockItem> get _losers => _filteredMarket.where((s) => !s.isGain).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppTheme.background,
            floating: true,
            snap: true,
            elevation: 0,
            title: Text(
              'Live Market',
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                onPressed: _loadLiveMarket,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search symbol or company...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppTheme.textTertiary, size: 18),
                                onPressed: () { _searchController.clear(); _filterStocks(); },
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Sort Row + Tab
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Text(
                          'Sort by: ',
                          style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 12),
                        ),
                        _SortChip(label: 'Volume', value: 'volume', selected: _sortBy, onTap: _changeSort),
                        const SizedBox(width: 6),
                        _SortChip(label: '% Change', value: 'change', selected: _sortBy, onTap: _changeSort),
                        const SizedBox(width: 6),
                        _SortChip(label: 'Price', value: 'ltp', selected: _sortBy, onTap: _changeSort),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'All (${_filteredMarket.length})'),
                      Tab(text: 'Gainers (${_gainers.length})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: _loading
            ? ListView.builder(itemCount: 12, itemBuilder: (_, __) => const ShimmerCard())
            : _error != null
                ? _buildError()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStockList(_filteredMarket),
                      _buildStockList(_gainers),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStockList(List<StockItem> stocks) {
    if (stocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, color: AppTheme.textTertiary, size: 48),
            const SizedBox(height: 12),
            Text('No stocks found', style: GoogleFonts.inter(color: AppTheme.textTertiary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: stocks.length,
      itemBuilder: (_, i) => StockTile(
        stock: stocks[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: stocks[i].symbol)),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppTheme.loss, size: 48),
          const SizedBox(height: 16),
          Text('Failed to load market data', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadLiveMarket,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;

  const _SortChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? AppTheme.primary : AppTheme.textTertiary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
