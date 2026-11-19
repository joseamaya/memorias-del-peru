# AGENTS.md — Reglas de trabajo

## 1. Idea fuerza

**Memorias del Perú** es un RPG histórico en primera persona: exploración, narrativa ambiental, decisiones y combate al servicio de una reconstrucción histórica rigurosa. Es una antología de cuatro campañas; la campaña en desarrollo es *Pachacútec — El despertar del Sol*, estructurada en cinco actos.

La biblia narrativa general es [docs/09](docs/09_biblia_narrativa.md). Manda en lo narrativo; las fases, los sistemas y las pruebas viven en `docs/01`–`08`, y la puesta en escena se fija con la [plantilla de guion de escena](docs/10_plantilla_guion_de_escena.md).

La prioridad es que el juego **se juegue bien y se vea bien**. El proceso está al servicio del resultado; si una regla impide un resultado mejor, se simplifica y se anota en la [bitácora](docs/bitacora.md).

## 2. Fase actual

**Fase 4 — Arte, audio y equilibrio.** Criterio de salida: el fijado en [docs/05](docs/05_plan_de_implementacion.md) §Fase 4. La partida humana cronometrada de 40–50 min se mide en la Fase 5.

- Estado y criterios de fase: [docs/05](docs/05_plan_de_implementacion.md).
- Tareas, dependencias y evidencia de la fase: [ficha de F4](docs/fases/F4-arte-audio-equilibrio.md).
- Fases cerradas: 0 (documentación), 1 (fundación y núcleo RPG), 2 (guion de la campaña 01) y 3 (arco jugable I–V).
- Deudas heredadas de la Fase 3: las que recoge la [ficha de la fase activa](docs/fases/F4-arte-audio-equilibrio.md).

Solo se trabaja en la fase activa o en el pulido que la cierre. **Nada de la fase siguiente se adelanta.** Si una tarea parece necesitar algo de una fase futura, se para y se consulta.

## 3. Fuentes de verdad

1. **Este archivo** (reglas de proceso y prioridad de producto).
2. **`docs/01`–`10`** (visión, arquitectura, estándares, configuración, plan, pruebas, convenciones, rendimiento, biblia narrativa y plantilla de guion de escena).
3. **[`docs/00_especificacion.md`](docs/00_especificacion.md)** — especificación original.
4. **`campaigns/<campaña>/documentation/`** — prevalece dentro del ámbito de su campaña.

Reparto de documentos para no duplicar:

| Documento | Manda sobre |
|---|---|
| [docs/05](docs/05_plan_de_implementacion.md) | Estado de las fases y criterios de aceptación de fase |
| `docs/fases/` | Tareas de la fase, dependencias, criterios por tarea y evidencia |
| [docs/06](docs/06_estrategia_de_pruebas.md) | Cómo se prueba: niveles, comandos y validación manual |
| [docs/08](docs/08_entorno_y_rendimiento.md) | Protocolo y presupuesto de rendimiento |
| [bitácora](docs/bitacora.md) | Por qué se hizo y qué se aprendió |

La [bitácora](docs/bitacora.md) es el registro cronológico de cambios y decisiones. No crea reglas, pero conserva el porqué. Una decisión relevante se anota con su motivación, las alternativas consideradas y sus consecuencias; no hace falta un documento aparte.

**Los ADR se retiraron el 2026-11-14.** Las referencias históricas a ADR que queden en documentos son registro, no normas. No se exige un ADR para arte, herramientas, assets o cambios de alcance: solo licencia/procedencia y pruebas.

## 4. Stack fijado

- **Godot 4.7.2** estable, edición estándar; no se cambia de versión a mitad de fase.
- **Renderizador Forward+**; no se cambia por esta línea de trabajo.
- **GDScript con tipado estricto** según [docs/03](docs/03_estandares_de_codigo.md).
- **Pruebas:** ejecutor propio en `tests/run_tests.gd` y recorridos de integración en `tests/`.
- **CI:** GitHub Actions (importación, límites, pruebas, exportación y arranque).
- **Lint y formato:** `gdtoolkit 4.5.0` (`requirements-dev.txt`); los archivos nuevos pasan `gdlint` y `gdformat --check`. Los heredados no se reformatean en masa.
- **Plataformas verificadas:** Linux y Windows. macOS es objetivo, no una plataforma probada.

## 5. Antes de implementar

- Leer este archivo, la ficha de la fase activa, los documentos afectados y **el código que se va a tocar**.
- Identificar la tarea concreta y su criterio de aceptación. Si no existe, se escribe antes de programar y se acuerda con el responsable.
- Para un cambio importante —arquitectura, sistema nuevo, escena de mundo, personaje, interfaz o rendimiento—, presentar un plan breve con archivos, enfoque, verificación y riesgos, y **esperar aprobación**.
- Verificar la versión de Godot (`godot --version`) y que la API exista en esa versión. **No inventar APIs.**
- Comprobar la licencia y la procedencia de cualquier asset externo. Solo se admiten recursos gratuitos y compatibles con uso comercial.
- Si el cambio necesita una decisión de producto, discutirla y anotarla en la bitácora. No bloquear el trabajo por papeleo.

## 6. Durante la implementación

- Una tarea, una rama y un PR. Si la tarea crece, se divide antes de seguir.
- Trabajar por fases; no introducir sistemas de fases futuras ni funcionalidades no pedidas.
- No reescribir un sistema que funciona sin justificarlo por escrito. Un cambio de contrato se anota en la bitácora.
- Crear archivos completos y funcionales. Prohibido el pseudocódigo, los `TODO` que oculten funcionalidad requerida y las implementaciones ficticias.
- Tipado estricto según [docs/03](docs/03_estandares_de_codigo.md). No suprimir advertencias con `@warning_ignore` para ocultar errores de diseño; cualquier supresión requiere comentario justificativo.
- Respetar las capas: `campaigns/` puede depender de `core/` y `shared_assets/`; `core/` **nunca** depende de `campaigns/`; una campaña no referencia a otra.
- Todo texto visible para el jugador pasa por `tr()`; nunca literales en código.
- No añadir dependencias nuevas (addons, paquetes, MCP, actions de terceros) sin aprobación.
- No crear carpetas vacías. Cada directorio nace con su primer archivo funcional.
- **Recursos gratuitos permitidos**: CC0, Mixamo, Blender, MCP de Blender, packs gratuitos y generación de referencias o texturas con IA. Registrar autor, origen, licencia y fecha en el `LICENSE.md` correspondiente. No usar assets de pago.
- **Assets 3D finales**: preferir un script reproducible (`tools/` o `assets/blender/`). Si se edita a mano, documentar el proceso y versionar el `.blend` o el GLB con su procedencia.
- No mezclar cambios no relacionados en una misma entrega.

## 7. Después de implementar

1. Validar según el alcance, con los comandos de [docs/06](docs/06_estrategia_de_pruebas.md):
   - **Solo documentación:** enlaces relativos resueltos y sin afirmaciones que contradigan el código.
   - **Código de Core o sistemas:** suite completa.
   - **Mundo, jugador o evento:** suite completa, partida de extremo a extremo y arranque del build exportado.
   - **Escena, arte, audio o interfaz:** además, capturas fijas y medición de rendimiento según [docs/08](docs/08_entorno_y_rendimiento.md).
2. Revisar la salida completa: **cero errores y cero advertencias de GDScript procedentes de `res://`**.
3. Corregir y volver a validar. Si algo no se pudo comprobar, se declara como *no verificado*.
4. Actualizar lo que corresponda: [docs/05](docs/05_plan_de_implementacion.md), la ficha de la fase, [docs/06](docs/06_estrategia_de_pruebas.md) y la [bitácora](docs/bitacora.md).
5. Informar con este formato:

```text
## Informe de entrega
Fase: <n>
Completo (verificado): <lista + cómo se verificó>
Parcial: <lista + qué falta>
Pendiente: <lista>
Validaciones ejecutadas: <comandos + resultado>
Limitaciones / riesgos: <lista>
No verificado: <lista>
Decisiones tomadas: <lista o enlace a la bitácora>
```

Una funcionalidad **no** está terminada porque el código fue escrito: está terminada cuando se comprobó.

## 8. Flujo por tarea

1. Rama propia desde `main`: `feat/…`, `fix/…`, `chore/…` o `docs/…`.
2. Commits pequeños, en español y en imperativo, con prefijo de área.
3. PR a `main` con la plantilla del repositorio: qué cambia, criterio de aceptación, verificación, evidencia visual y *no verificado*.
4. CI en verde. El **responsable del proyecto prueba y hace el merge**.
5. **El agente nunca hace push directo a `main` ni merge.** Tampoco reescribe el historial.

## 9. Lo que no decide un agente

Dirección artística, sensación de combate, canon histórico, alcance y prioridades. El agente propone con evidencia; el responsable decide. Una propuesta no aprobada no se implementa «de paso».

## 10. Definición de terminado

- Pruebas nuevas o actualizadas, en verde en local y en CI.
- Cero errores y cero advertencias de GDScript procedentes de `res://`.
- El proyecto se importa y la escena principal se ejecuta.
- Documentación afectada y bitácora actualizadas.
- Informe con qué cambió, cómo se probó y qué **no** se pudo verificar.

## 11. Restricción fundamental

No avanzar a la siguiente fase mientras existan errores críticos o criterios de aceptación incumplidos en la fase actual.

## 12. Contenido histórico

Todo elemento histórico relevante (personajes, arquitectura, vestimenta, objetos, eventos, textos en pantalla) debe registrarse con su clasificación y fuente según [docs/07](docs/07_convenciones_historicas.md). Un agente nunca presenta una reconstrucción o licencia narrativa como hecho documentado.

## 13. Idioma

- Identificadores de código (clases, funciones, variables, señales, acciones de entrada): inglés.
- Nombres de archivos de contenido de campaña: pueden estar en español.
- Comentarios, documentación y textos para el jugador: español.
- Términos quechuas: grafía según la convención de la campaña.
