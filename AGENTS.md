# AGENTS.md — Reglas de trabajo

## 1. Idea fuerza

**Memorias del Perú** es un RPG histórico en primera persona: exploración, narrativa ambiental, decisiones y combate al servicio de una reconstrucción histórica rigurosa. Es una antología de cuatro campañas; la campaña en desarrollo es *Pachacútec — El despertar del Sol*, estructurada en cinco actos.

La biblia narrativa general es [docs/09](docs/09_biblia_narrativa.md). Manda en lo narrativo; las fases, los sistemas y las pruebas viven en `docs/01`–`08`.

La prioridad es que el juego **se juegue bien y se vea bien**. El proceso está al servicio del resultado; si una regla impide un resultado mejor, se simplifica y se anota en la [bitácora](docs/bitacora.md).

## 2. Fuentes de verdad

1. **Este archivo** (reglas de proceso y prioridad de producto).
2. **`docs/01`–`09`** (visión, arquitectura, estándares, configuración, plan, pruebas, convenciones, rendimiento y biblia narrativa).
3. **[`docs/00_especificacion.md`](docs/00_especificacion.md)** — especificación original.
4. **`campaigns/<campaña>/documentation/`** — prevalece dentro del ámbito de su campaña.

La [bitácora](docs/bitacora.md) es el registro cronológico de cambios y decisiones. No crea reglas, pero conserva el porqué.

**Los ADR se retiraron el 2026-11-14.** Las referencias históricas a ADR que queden en documentos son registro, no normas. No se exige un ADR para arte, herramientas, assets o cambios de alcance: solo licencia/procedencia y pruebas.

## 3. Antes de implementar

- Inspeccionar el repositorio y leer los archivos que se van a tocar.
- Verificar la versión de Godot (`godot --version`) y que la API exista en esa versión. **No inventar APIs.**
- Identificar la fase activa en [docs/05](docs/05_plan_de_implementacion.md). Solo se trabaja en la fase activa o en el pulido que la cierre.
- Comprobar la licencia y la procedencia de cualquier asset externo. Solo se admiten recursos gratuitos y compatibles con uso comercial.
- Si el cambio necesita una decisión de producto, discutirla y anotarla en la bitácora. No bloquear el trabajo por papeleo.

## 4. Durante la implementación

- Trabajar por fases; no introducir sistemas de fases futuras.
- Crear archivos completos y funcionales. Prohibido el pseudocódigo, los `TODO` que oculten funcionalidad requerida y las implementaciones ficticias.
- Tipado estricto según [docs/03](docs/03_estandares_de_codigo.md). No suprimir advertencias con `@warning_ignore` para ocultar errores de diseño; cualquier supresión requiere comentario justificativo.
- Respetar las capas: `campaigns/` puede depender de `core/` y `shared_assets/`; `core/` **nunca** depende de `campaigns/`.
- No crear carpetas vacías. Cada directorio nace con su primer archivo funcional.
- **Recursos gratuitos permitidos**: CC0, Mixamo, Blender, MCP de Blender, packs gratuitos y generación de referencias o texturas con IA. Registrar autor, origen, licencia y fecha en el `LICENSE.md` correspondiente. No usar assets de pago.
- **Assets 3D finales**: preferir un script reproducible (`tools/` o `assets/blender/`). Si se edita a mano, documentar el proceso y versionar el `.blend` o el GLB con su procedencia.
- No mezclar cambios no relacionados en una misma entrega.

## 5. Después de implementar

1. Ejecutar las validaciones de [docs/06](docs/06_estrategia_de_pruebas.md) según el alcance: suite completa al cerrar un lote; partida de extremo a extremo y prueba de humo si se toca el mundo, el evento o el jugador; rendimiento si cambia la escena.
2. Revisar la salida completa: cero errores y cero advertencias de GDScript procedentes de `res://`.
3. Corregir y volver a validar.
4. Actualizar la documentación afectada, la tabla de estado de [docs/05](docs/05_plan_de_implementacion.md) y la [bitácora](docs/bitacora.md).
5. Informar con este formato:

```text
## Informe de entrega
Fase: <n>
Completo (verificado): <lista + cómo se verificó>
Parcial: <lista + qué falta>
Pendiente: <lista>
Validaciones ejecutadas: <comandos + resultado>
Limitaciones / riesgos: <lista>
Decisiones tomadas: <lista o enlace a la bitácora>
```

Una funcionalidad **no** está terminada porque el código fue escrito: está terminada cuando se comprobó. Si algo no pudo verificarse, declararlo como *no verificado*.

## 6. Restricción fundamental

No avanzar a la siguiente fase mientras existan errores críticos o criterios de aceptación incumplidos en la fase actual.

## 7. Contenido histórico

Todo elemento histórico relevante (personajes, arquitectura, vestimenta, objetos, eventos, textos en pantalla) debe registrarse con su clasificación y fuente según [docs/07](docs/07_convenciones_historicas.md). Un agente nunca presenta una reconstrucción o licencia narrativa como hecho documentado.

## 8. Idioma

- Identificadores de código (clases, funciones, variables, señales, acciones de entrada): inglés.
- Nombres de archivos de contenido de campaña: pueden estar en español.
- Comentarios, documentación y textos para el jugador: español.
- Términos quechuas: grafía según la convención de la campaña.
