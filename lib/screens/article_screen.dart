import 'package:flutter/material.dart';

import '../models/article.dart';
import '../utils/app_colors.dart';
import '../widgets/night_background.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;
  const ArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: AppColors.bg,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, c) {
                final collapsed = c.biggest.height <= kToolbarHeight + topPad + 12;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedOpacity(
                      opacity: collapsed ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: ArtHero(colors: article.colors, icon: article.icon, iconSize: 120, seed: article.id.length + 5),
                    ),
                    if (collapsed)
                      Positioned(
                        left: 64,
                        right: 20,
                        bottom: 0,
                        height: kToolbarHeight,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            article.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 8),
                  Text('${article.category} · ${article.minutes} min de lectura',
                      style: const TextStyle(color: AppColors.primaryLight, fontSize: 15)),
                  const SizedBox(height: 18),
                  _Body(article.intro),
                  for (final s in article.sections) ...[
                    const SizedBox(height: 22),
                    Text(s.heading,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 23, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    if (s.body.isNotEmpty) _Body(s.body),
                    for (final b in s.bullets)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 8, right: 12),
                              child: Icon(Icons.circle, size: 7, color: AppColors.primaryLight),
                            ),
                            Expanded(child: _Body(b)),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 28),
                  const Text(
                    'Información general de bienestar. Si tienes problemas de sueño persistentes, consulta a un profesional de la salud.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 17, height: 1.55));
  }
}
