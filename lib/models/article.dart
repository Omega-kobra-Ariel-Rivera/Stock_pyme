import 'package:flutter/material.dart';

class ArticleSection {
  final String heading;
  final String body;
  final List<String> bullets;

  const ArticleSection({
    required this.heading,
    this.body = '',
    this.bullets = const [],
  });
}

class Article {
  final String id;
  final String title;
  final String category;
  final int minutes;
  final List<Color> colors;
  final IconData icon;
  final String intro;
  final List<ArticleSection> sections;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.minutes,
    required this.colors,
    required this.icon,
    required this.intro,
    required this.sections,
  });
}
