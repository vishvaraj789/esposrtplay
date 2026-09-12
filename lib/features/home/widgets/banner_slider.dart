import 'package:flutter/material.dart';

import '../provider/home_provider.dart';

const _kGold = Color(0xFFFFC24B);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kPurple = Color(0xFF8B5CF6);
const _kHairline = Color(0xFF2A2C38);
const _kBrandGradient = LinearGradient(
  colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class BannerSlider extends StatefulWidget {
  final List<BannerItem> banners;

  const BannerSlider({super.key, required this.banners});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _buildBanner(widget.banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
                (i) => _dot(active: i == _index),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(BannerItem banner) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF241934), Color(0xFF3B1F3F), Color(0xFF5A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.sports_martial_arts, size: 160, color: Colors.black.withOpacity(0.18)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      banner.tag,
                      style: const TextStyle(color: _kGold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: banner.statusColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: banner.statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        banner.statusLabel,
                        style: TextStyle(color: banner.statusColor, fontSize: 9.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  banner.title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _chip(Icons.calendar_today, banner.dateLabel),
                    const SizedBox(width: 8),
                    _chip(Icons.groups, banner.modeLabel),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PRIZE POOL', style: TextStyle(color: _kTextSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(banner.prize, style: const TextStyle(color: _kGold, fontSize: 20, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(gradient: _kBrandGradient, borderRadius: BorderRadius.circular(10)),
                      child: TextButton(
                        onPressed: banner.onJoin,
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('JOIN NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _dot({required bool active}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? _kPurple : _kHairline,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}