import 'package:flutter/material.dart';

import '../models/plan_task.dart';

const planTasks = <PlanTask>[
  PlanTask(
    id: 'worries',
    title: 'Escribe tus preocupaciones antes de dormir',
    description:
        'Sacar los pendientes de la cabeza y dejarlos por escrito ayuda a que tu mente deje de repasarlos cuando apagas la luz.',
    icon: Icons.psychology_outlined,
    action: PlanAction.worries,
  ),
  PlanTask(
    id: 'luna',
    title: 'Pregunta a Luna sobre tu sueño',
    description:
        'Luna revisa tus últimas noches y te da recomendaciones simples para descansar mejor.',
    icon: Icons.cloud_outlined,
    action: PlanAction.askLuna,
  ),
  PlanTask(
    id: 'noise',
    title: 'Duérmete con ruido blanco esta noche',
    description:
        'Un sonido constante tapa los ruidos sueltos de la casa o la calle, así tu cerebro deja de estar en alerta y se relaja.',
    icon: Icons.graphic_eq,
    action: PlanAction.whiteNoise,
  ),
  PlanTask(
    id: 'breath',
    title: 'Configura tu recordatorio de respiración',
    description:
        'Elige la hora en que quieres hacer un ejercicio de respiración para preparar el cuerpo antes de acostarte.',
    icon: Icons.alarm,
    action: PlanAction.breathingReminder,
  ),
];

const sleepTips = <String>[
  'Mantén tu dormitorio fresco, entre 18 °C y 20 °C, para favorecer un sueño profundo y continuo.',
  'Intenta acostarte y levantarte a la misma hora, incluso el fin de semana.',
  'Evita la cafeína después de las 15:00; su efecto puede durar más de 6 horas.',
  'Baja el brillo de las pantallas y usa luz cálida una hora antes de dormir.',
  'Una cena liviana 2 a 3 horas antes de acostarte facilita la digestión y el descanso.',
  'Si no te duermes en 20 minutos, levántate, haz algo tranquilo con poca luz y vuelve cuando tengas sueño.',
  'Exponerte a la luz natural por la mañana ayuda a ordenar tu reloj biológico.',
  'Usa la cama solo para dormir: así tu cerebro la asocia con descanso.',
  'Una ducha tibia antes de dormir ayuda a que la temperatura corporal baje después.',
  'El alcohol puede darte sueño, pero fragmenta el descanso en la segunda mitad de la noche.',
  'Una siesta de 20 minutos recarga energía sin afectar tu sueño nocturno.',
  'Ventila tu pieza durante el día; el aire fresco mejora la sensación de descanso.',
];
