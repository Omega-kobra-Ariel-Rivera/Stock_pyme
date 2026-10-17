import 'package:flutter/material.dart';

import '../models/article.dart';

const articles = <Article>[
  Article(
    id: 'posturas',
    title: 'Tu postura al dormir y cómo afecta tu descanso',
    category: 'Artículo',
    minutes: 4,
    colors: [Color(0xFF2B1B5A), Color(0xFF8E4A8C), Color(0xFFE88A6B)],
    icon: Icons.bed_outlined,
    intro:
        'Pasamos cerca de un tercio de la vida en la cama, y la posición en la que dormimos influye en cómo amanecemos: con energía o con el cuello rígido. No hay una postura correcta para todos, pero sí señales que vale la pena observar.',
    sections: [
      ArticleSection(
        heading: 'De lado',
        body:
            'Es la postura más común en adultos. Suele reducir los ronquidos porque la vía aérea queda más despejada. Si duermes así, una almohada entre las rodillas mantiene la cadera alineada y alivia la zona lumbar.',
      ),
      ArticleSection(
        heading: 'Boca arriba',
        body:
            'Reparte el peso de forma pareja y mantiene la columna en una línea neutra. Una almohada baja bajo la cabeza y otra pequeña bajo las rodillas puede hacerla más cómoda. En personas que roncan, puede empeorar los ronquidos.',
      ),
      ArticleSection(
        heading: 'Boca abajo',
        body:
            'Obliga a girar el cuello durante horas y puede tensar la espalda. Si es la única forma en que logras dormir, prueba con una almohada muy delgada o ninguna.',
      ),
      ArticleSection(
        heading: 'Escucha a tu cuerpo',
        bullets: [
          'Anota cómo te sientes al despertar durante una semana.',
          'Si amaneces con dolor, cambia una sola cosa a la vez: almohada, colchón o postura.',
          'Moverse durante la noche es normal y ayuda a evitar molestias.',
          'Registra tus noches en NutrySleep para encontrar patrones.',
        ],
      ),
    ],
  ),
  Article(
    id: 'ciclos',
    title: 'Ciclos del sueño: lo que pasa mientras duermes',
    category: 'Artículo',
    minutes: 5,
    colors: [Color(0xFF0B1A3A), Color(0xFF1F3B6E), Color(0xFF6C8FC7)],
    icon: Icons.nightlight_round,
    intro:
        'Dormir no es apagar el cerebro. Durante la noche pasamos varias veces por un ciclo de etapas, cada una con una función distinta para el cuerpo y la mente.',
    sections: [
      ArticleSection(
        heading: 'Sueño ligero',
        body:
            'Es la puerta de entrada: el pulso y la respiración se hacen más lentos y los músculos se relajan. Ocupa cerca de la mitad de la noche y es cuando más fácil despertamos.',
      ),
      ArticleSection(
        heading: 'Sueño profundo',
        body:
            'Las ondas cerebrales se vuelven lentas y amplias. Es la etapa más reparadora para el cuerpo: se recuperan músculos y tejidos y se refuerza el sistema inmune. Predomina en la primera mitad de la noche.',
      ),
      ArticleSection(
        heading: 'Sueño REM',
        body:
            'El cerebro se activa casi como despierto y aparecen los sueños más vívidos. Es clave para la memoria, el aprendizaje y el equilibrio emocional. Se alarga hacia la madrugada.',
      ),
      ArticleSection(
        heading: 'Ciclos de unos 90 minutos',
        bullets: [
          'Una noche completa tiene entre 4 y 6 ciclos.',
          'Despertar al final de un ciclo suele sentirse más liviano.',
          'Acortar la noche recorta sobre todo el sueño REM de la madrugada.',
          'Horarios regulares ayudan a que los ciclos se ordenen solos.',
        ],
      ),
    ],
  ),
  Article(
    id: 'ruidos',
    title: 'Ruido blanco, rosa o marrón: cuál elegir',
    category: 'Guía',
    minutes: 3,
    colors: [Color(0xFF071F2E), Color(0xFF0F4C5C), Color(0xFF2BB3A6)],
    icon: Icons.graphic_eq,
    intro:
        'Los sonidos constantes funcionan como una cortina: tapan los ruidos repentinos que te despiertan. Cada "color" de ruido tiene un carácter distinto.',
    sections: [
      ArticleSection(
        heading: 'Blanco',
        body:
            'Tiene la misma energía en todas las frecuencias. Suena como una radio sin sintonizar. Es el que mejor tapa ruidos agudos, como voces o tráfico.',
      ),
      ArticleSection(
        heading: 'Rosa',
        body:
            'Más suave en los agudos, parecido a la lluvia constante. A muchas personas les resulta más agradable que el blanco para toda la noche.',
      ),
      ArticleSection(
        heading: 'Marrón',
        body:
            'Grave y profundo, como el mar a lo lejos o un avión en vuelo. Ideal si los sonidos agudos te molestan.',
      ),
      ArticleSection(
        heading: 'Consejos de uso',
        bullets: [
          'Mantén un volumen bajo, similar a una conversación suave.',
          'Deja el parlante lejos de la cabeza.',
          'Combina sonidos en la pestaña Sonidos para crear tu mezcla.',
          'Usa el temporizador si prefieres que se apague solo.',
        ],
      ),
    ],
  ),
  Article(
    id: 'rutina',
    title: 'Una rutina de 30 minutos para dormir mejor',
    category: 'Rutina',
    minutes: 3,
    colors: [Color(0xFF1A1036), Color(0xFF3D2A7A), Color(0xFF7B5CFF)],
    icon: Icons.self_improvement,
    intro:
        'El cuerpo agradece las señales repetidas. Una rutina corta y siempre igual le avisa que se acerca la hora de dormir.',
    sections: [
      ArticleSection(
        heading: 'Minuto 30: desconecta',
        body:
            'Deja el celular cargando lejos de la cama, baja las luces y prepara la ropa del día siguiente para no pensar en eso después.',
      ),
      ArticleSection(
        heading: 'Minuto 20: vacía la mente',
        body:
            'Escribe tus preocupaciones o tareas pendientes. Dejarlas en papel le quita peso a la cabeza.',
      ),
      ArticleSection(
        heading: 'Minuto 10: respira',
        body:
            'Haz el ejercicio de Aliento o Meditación del Kit de Sueño. Cinco minutos bastan para bajar las pulsaciones.',
      ),
      ArticleSection(
        heading: 'Minuto 0: a dormir',
        bullets: [
          'Activa tu sonido favorito con temporizador.',
          'Toca "Iniciar sueño" para registrar la noche.',
          'Al despertar, califica cómo dormiste.',
        ],
      ),
    ],
  ),
];
