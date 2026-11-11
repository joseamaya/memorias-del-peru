# ADR-0013 — Ritmo, orientación y cierre del slice

- Estado: Aceptado
- Fecha: 2026-11-11
- Sustituye en parte: [ADR-0012](0012-ajustes-tras-el-primer-piloto.md) (reloj del mensajero) y la regla del alcance v3.4 §2.2 «El final no muestra créditos ni fundido». Matiza la v3.3 (personajes estáticos).

## Contexto

Una revisión del slice tras ADR-0012 encontró cuatro problemas de ritmo y orientación, además de errores de HUD que ya se corrigieron sin ADR:

1. **La espera sigue pesando.** Con 120 s, más 60 s si el jugador no está en la plaza, las conversaciones y los dos objetos se agotan en un minuto.
2. **No hay un primer paso claro.** Tras la apertura, nada orienta al jugador hacia la plaza.
3. **El evento puede ocurrir lejos.** A los 180 s el mensajero sale aunque el jugador no esté en la plaza, y se pierde la mejor escena.
4. **No hay cierre de sesión.** Tras la partida de la comitiva no hay ninguna tarjeta ni forma de reiniciar.

Además, los personajes se deslizan al caminar (alcance v3.3).

El responsable del proyecto eligió las opciones recomendadas el 2026-11-11.

## Decisión

1. **Espera de 75 s que te espera:**
   - `arrival_delay` pasa a 75 s y `arrival_grace` a 75 s.
   - Si a los 75 s el jugador está en la plaza, el mensajero sale.
   - Si no, aparece «Desde la plaza llaman a la gente: el mensajero está por llegar» y el mensajero espera a que el jugador llegue, como tarde hasta los 150 s.
   - La señal intermedia pasa de los 70 a los **45 s**.
   - El progreso sigue garantizado (ADR-0007).
2. **Vecino que recibe al jugador:**
   - Un vecino (Habitante 3) espera junto al camino sur, en (3,2; 0; 18), y mira al jugador.
   - Cuando el jugador se acerca a 9 m, dice «¡Llegas a tiempo! Ven a la plaza: hoy esperamos noticias del Cusco» (licencia narrativa) y luego se une a su paseo.
3. **Tarjeta de fin:**
   - 50 s después de que la comitiva sale de la plaza (unos 60 s después del último subtítulo), un fundido muestra «Fin del fragmento» y «R para volver a empezar · Esc para salir».
   - Con la tarjeta a la vista, R recarga la escena y Esc cierra el juego de forma ordenada (`GameManager.request_quit()`) en lugar de pausar.
   - Coincide con el fin de sesión del protocolo (alcance §9.2).
4. **Balanceo de piernas:**
   - El generador exporta las piernas de cada personaje como nodos aparte (`LegL`, `LegR`), con el origen en lo alto de la pierna.
   - `NpcActor` las gira sobre su eje X al caminar, ±24° por cada 0,75 m de paso, y las endereza al pararse.
   - No es un rig: brazos, tronco y cabeza siguen rígidos.

## Consecuencias

- El alcance pasa a v3.5 (§2.2, §5, §6.4 y §10).
- La mediana estimada baja a unos 4–5 min. La métrica de 5–8 min de ADR-0009 se mide en las sesiones. Si queda corta, se añaden conversaciones o hitos, no espera.
- El guion del facilitador puede usar la tarjeta de fin como señal de fin de sesión.
- Pruebas:
  - `test_npc_talk_and_wander` cubre el vecino que recibe, el reloj y el balanceo.
  - `test_hud_feedback` cubre la tarjeta de fin.
  - `test_narrative_beats_order` mantiene la secuencia.
