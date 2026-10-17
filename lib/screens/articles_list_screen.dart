import 'package:flutter/material.dart';

import '../data/articles_data.dart';
import '../widgets/common.dart';
import '../widgets/night_background.dart';
import 'article_screen.dart';

class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda para dormir')),
      extendBodyBehindAppBar: true,
      body: NightBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              for (final a in articles)
                ArticleTile(
                  article: a,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => ArticleScreen(article: a)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
