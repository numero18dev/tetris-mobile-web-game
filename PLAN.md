# Plan de Desarrollo - Tetris

A continuación se detallan las fases planificadas para el desarrollo de nuestro clon de Tetris en Godot:

## Fase 1: Configuración base y tablero lógico ✅
- [x] Setup del proyecto en Godot (resolución, settings básicos).
- [x] Creación de la cuadrícula o matriz lógica (10x20).
- [x] Límites del área de juego y renderizado visual del tablero vacío.

## Fase 2: Lógica de los Tetrominós y Movimiento Base ✅
- [x] Definición de las 7 piezas clásicas (I, J, L, O, S, T, Z) y sus colores.
- [x] Spawn de piezas en la parte superior del tablero.
- [x] Caída automática de las piezas según un temporizador (gravedad).
- [x] Movimiento horizontal del jugador (izquierda/derecha) y caída rápida (soft drop).

## Fase 3: Rotación y Detección de Colisiones ✅
- [x] Lógica de rotación de las matrices de las piezas (90 grados).
- [x] Sistema de detección de colisiones (evitar que las piezas salgan del tablero o se superpongan con otras).
- [x] Fijación de las piezas ("Lock") cuando tocan el suelo o la pila de piezas existentes.

## Fase 4: Limpieza de Líneas y Puntuación ✅
- [x] Detección de líneas completadas una vez que una pieza se fija.
- [x] Eliminación de las líneas y desplazamiento hacia abajo del resto de bloques.
- [x] Sistema básico de puntuación (Score), líneas eliminadas y niveles (aumentando la velocidad de caída).

## Fase 5: Mejoras de Gameplay (Opcional) ✅
- [x] Previsualización de la siguiente pieza (Next Piece).
- [x] Guardar pieza para más tarde (Hold Piece).
- [x] Sombra de la pieza donde va a caer (Ghost Piece).
- [x] Hard Drop (caída instantánea al fondo).

## Fase 6: UI, Audio y Pulido Final ✅
- [x] Menú principal y pantallas de "Game Over".
- [x] Música de fondo y efectos de sonido (rotación, bloqueo, limpieza de líneas).
- [x] Transiciones, efectos visuales de limpieza de líneas y pulido general.