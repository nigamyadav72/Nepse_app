import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company.dart';
import '../services/nepse_api.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loader.dart';
import 'stock_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = NepseApiService();
  List<Company> _allCompanies = [];
  List<Company> _filtered = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSector = 'All';
  List<String> _sectors = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    try {
      final data = await _api.getCompanyList();
      final uniqueSectors = {...data.map((c) => c.sector ?? 'Other')}.toList()..sort();
      final sectors = ['All', ...uniqueSectors];
      if (mounted) {
        setState(() {
          _allCompanies = data;
          _filtered = data;
          _sectors = sectors;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _allCompanies.where((c) {
        final matchSearch = c.symbol.toLowerCase().contains(query) ||
            c.name.toLowerCase().contains(query);
        final matchSector = _selectedSector == 'All' ||
            (c.sector ?? 'Other') == _selectedSector;
        return matchSearch && matchSector;
      }).toList();
    });
  }

  void _setSector(String sector) {
    setState(() => _selectedSector = sector);
    _filter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text(
          'Companies',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${_filtered.length} listed',
                style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search company or symbol...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textTertiary, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          // Sector chips
          if (_sectors.length > 1)
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sectors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final sector = _sectors[i];
                  final selected = sector == _selectedSector;
                  return GestureDetector(
                    onTap: () => _setSector(sector),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        sector,
                        style: GoogleFonts.inter(
                          color: selected ? Colors.white : AppTheme.textTertiary,
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          // Company list
          Expanded(
            child: _loading
                ? ListView.builder(itemCount: 12, itemBuilder: (_, __) => const ShimmerCard())
                : _error != null
                    ? _buildError()
                    : _filtered.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _CompanyTile(
                              company: _filtered[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StockDetailScreen(symbol: _filtered[i].symbol),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppTheme.loss, size: 48),
          const SizedBox(height: 12),
          Text('Failed to load companies', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadCompanies,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, color: AppTheme.textTertiary, size: 48),
          const SizedBox(height: 12),
          Text(
            'No companies found for "${_searchController.text}"',
            style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CompanyTile extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  const _CompanyTile({required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
                company.symbol.length > 3
                    ? company.symbol.substring(0, 3)
                    : company.symbol,
                style: GoogleFonts.inter(
                  color: AppTheme.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.symbol,
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    company.name,
                    style: GoogleFonts.inter(color: AppTheme.textTertiary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (company.sector != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  company.sector!,
                  style: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
