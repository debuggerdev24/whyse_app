import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/providers/home/reading_appearance_provider.dart';

// ─── Bottom Sheet Function ───────────────────────────────────────────────────

/// Call this function from any button's onPressed to show the font/theme picker.
void showFontThemeBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FontThemeBottomSheet(),
  );
}

// ─── Internal Bottom Sheet Widget ───────────────────────────────────────────

class _FontThemeBottomSheet extends StatefulWidget {
  const _FontThemeBottomSheet();

  @override
  State<_FontThemeBottomSheet> createState() => _FontThemeBottomSheetState();
}

class _FontThemeBottomSheetState extends State<_FontThemeBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildTabBar(),
            const Divider(height: 1, color: Color(0xFFE5E5EA)),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [_buildFontsTab(), _buildThemesTab()],
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: const Color(0xFF0E9E96),
      unselectedLabelColor: const Color(0xFF707070),
      indicatorColor: const Color(0xFF0E9E96),
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      tabs: const [
        Tab(text: 'Fonts'),
        Tab(text: 'Themes'),
      ],
    );
  }

  Widget _buildFontsTab() {
    return Consumer<ReadingAppearanceProvider>(
      builder: (context, appearance, _) {
        final fonts = ReadingAppearanceProvider.fonts;
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 92,
                child: Row(
                  children: List.generate(
                    fonts.length,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < fonts.length - 1 ? 8 : 0,
                        ),
                        child: _FontCard(
                          font: fonts[index],
                          isSelected: appearance.selectedFontIndex == index,
                          onTap: () =>
                              appearance.setSelectedFontIndex(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE5E5EA)),
              const SizedBox(height: 14),
              const Text(
                'Size',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'A',
                    style: TextStyle(
                      fontSize: 28,
                      height: 1,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF0E9E96),
                        inactiveTrackColor: const Color(0xFFD1D1D6),
                        trackHeight: 4,
                        thumbColor: Colors.white,
                        overlayColor: Colors.transparent,
                        activeTickMarkColor: const Color(0xFF0E9E96),
                        inactiveTickMarkColor: const Color(0xFFB9B9C2),
                        tickMarkShape: const RoundSliderTickMarkShape(
                          tickMarkRadius: 1.2,
                        ),
                        thumbShape: const _RingThumbShape(
                          radius: 12,
                          ringColor: Color(0xFF1C1C1E),
                          ringWidth: 5,
                        ),
                      ),
                      child: Slider(
                        value: appearance.fontSizeNormalized,
                        onChanged: appearance.setFontSizeNormalized,
                        divisions: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'A',
                    style: TextStyle(
                      fontSize: 42,
                      height: 1,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemesTab() {
    return Consumer<ReadingAppearanceProvider>(
      builder: (context, appearance, _) {
        final themes = ReadingAppearanceProvider.themes;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: themes.length,
            itemBuilder: (context, index) => _ThemeCard(
              theme: themes[index],
              isSelected: appearance.selectedThemeIndex == index,
              onTap: () => appearance.setSelectedThemeIndex(index),
            ),
          ),
        );
      },
    );
  }
}

class _FontCard extends StatelessWidget {
  final ReadingFontOption font;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontCard({
    required this.font,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1C1C1E)
                : const Color(0xFFD1D1D6),
            width: isSelected ? 1.2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aa',
              style: font.useLibreBaskerville
                  ? GoogleFonts.libreBaskerville(
                      fontSize: 45,
                      height: 1,
                      color: const Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w400,
                    )
                  : TextStyle(
                      fontSize: 45,
                      height: 1,
                      fontFamily: font.fontFamily,
                      color: const Color(0xFF1C1C1E),
                      fontWeight: FontWeight.w400,
                    ),
            ),
            const SizedBox(height: 2),
            Text(
              font.name,
              style: const TextStyle(
                fontSize: 11,
                height: 1,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingThumbShape extends SliderComponentShape {
  final double radius;
  final Color ringColor;
  final double ringWidth;

  const _RingThumbShape({
    required this.radius,
    required this.ringColor,
    required this.ringWidth,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final fillPaint = Paint()..color = Colors.white;
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius - (ringWidth / 2), ringPaint);
  }
}

class _ThemeCard extends StatelessWidget {
  final ReadingThemeOption theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00B37D)
                    : const Color(0xFFD1D1D6),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Aa',
                style: TextStyle(
                  fontSize: 20,
                  color: theme.text,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            theme.name,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}
