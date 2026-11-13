# Autovalidación — 2026-11-13

Validación de autor de [ADR-0031](../../../../docs/adr/0031-validacion-por-el-autor.md).
Cuatro pasadas: AUTO-1 a AUTO-3 sobre el commit `0b2fe00` (alcance v4.18) y
AUTO-4 sobre el commit `2aadcce` (alcance v4.20, con el mirador). En la GPU
integrada de referencia. Sin datos personales, sin vídeo ni audio.

## 1. Pasadas

| Marca | AUTO-1 | AUTO-2 | AUTO-3 | AUTO-4 |
|---|---|---|---|---|
| Perfil | Medio | Medio | Bajo | Medio |
| Introducción → control | 10,5 s | 8,7 s | 9,0 s | 6,8 s |
| Primera interacción (desde el control) | 12,8 s | 10,9 s | 11,1 s | 13,8 s |
| Tareas completadas | 43,7 s | 33,7 s | 34,7 s | 33,5 s |
| Mirador | — | — | — | 65,9 s |
| Aviso de espera | 30,5 s | 28,7 s | 29,0 s | 65,9 s |
| Llegada del mensajero | 51,1 s | 37,5 s | 34,7 s | 77,7 s |
| Evento terminado | 94,6 s | 83,1 s | 74,7 s | 118,8 s |
| **Duración total** | **97,9 s** | **86,3 s** | **77,7 s** | **121,2 s** |
| Bloqueos | 0 | 0 | 0 | 0 |
| Errores de consola | fuga al salir | — | fuga al salir | **—** |

Registros: `AUTO-1.log` a `AUTO-4.log` en esta carpeta.

## 2. Cuestionario

Respondido por escrito antes de releer el registro histórico.

1. **¿Quién amenaza al Cusco?** «Los chancas.»
2. **¿Qué han hecho el inca y su heredero?** «Han huido.»
3. **¿Qué hacen el curaca y los hombres de la llacta?** «Acuden al llamado de Cusi Yupanqui.»
4. **¿Qué hiciste en la plaza y para qué servía cada cosa?** «Tomé chicha, dejé una ofrenda, escuché al mensajero y toqué el pututo.»
5. **¿Qué te ha quedado claro y qué no?** «Todo claro.»

## 3. Resultado

| Criterio (ADR-0031) | Resultado |
|---|---|
| Preguntas 1 y 2 correctas | **Superado** |
| Primera interacción ≤ 20 s | **Superado** (10,9–13,8 s) |
| Cero bloqueos | **Superado** |
| Cero errores de consola | **Superado** en AUTO-4 (fuga corregida) |
| Duración 2–3 min ([ADR-0033](../../../../docs/adr/0033-duracion-del-slice.md)) | **Superado**: 121,2 s en AUTO-4 |

Observaciones de diagnóstico:

- La pregunta 4 enumera las acciones pero no su propósito, y omite la
  conversación. Las interacciones se entienden; su significado cultural no
  llega. Es material para la siguiente pasada de contenido.
- El aviso «El sol sube…» llegó mientras el HUD pedía todavía una tarea.

## 4. Correcciones posteriores

- Fuga al salir: se pausa el árbol antes del barrido de audio, se sueltan los
  flujos y se amplía el drenaje ([bitácora](../../../../docs/bitacora.md)).
  AUTO-4 cierra sin errores.
- Duración y aviso: cuarto objetivo del mirador y anuncio de la espera al
  llegar ([ADR-0032](../../../../docs/adr/0032-objetivo-del-mirador.md),
  alcance v4.20). AUTO-4 confirma el aviso en el mirador (65,9 s) y sube la
  duración a 121,2 s; **sigue por debajo de 4 min**.

La decisión sobre la duración se resolvió rebaseando el objetivo a **2–3 min**
([ADR-0033](../../../../docs/adr/0033-duracion-del-slice.md)): el slice es un
fragmento que valida el bucle, y la campaña completa mantiene el horizonte de
10–15 min. Con eso, la Fase 4 cerró el 2026-11-13.
