# AGENTS.md — Reglas de trabajo para agentes

Este archivo es de lectura obligatoria para cualquier agente de IA (OpenCode, Claude Code u otros) y para colaboradores humanos antes de modificar el repositorio.

## 1. Fuentes de verdad

Orden de precedencia (el número menor prevalece):

1. **ADR aceptados** (`docs/adr/`). Entre dos ADR, prevalece el más reciente. Un ADR aceptado prevalece también sobre este archivo; si lo modifica, el mismo cambio debe actualizar el texto de `AGENTS.md`.
2. **Este archivo** (reglas de proceso).
3. **`docs/01`–`08`** (visión, arquitectura, estándares, configuración, plan, pruebas, convenciones, rendimiento).
4. **[`docs/00_especificacion.md`](docs/00_especificacion.md)** — especificación original v1.0. Es el origen del proyecto; los documentos anteriores la concretan y, donde difieren, la sustituyen de forma justificada.
5. **`campaigns/<campaña>/documentation/`** — prevalece dentro del ámbito de su campaña siempre que no contradiga los niveles 1–4.

Si dos documentos se contradicen sin que la precedencia lo resuelva claramente, detener el trabajo afectado, señalar la contradicción y proponer un ADR. No resolverla en silencio.

## 2. Antes de implementar

- Inspeccionar el repositorio y leer los archivos que se van a tocar.
- Verificar la versión instalada de Godot (`godot --version`) y compararla con [ADR-0002](docs/adr/0002-version-de-godot.md).
- No sobrescribir código sin haberlo analizado.
- Confirmar que la API de Godot que se va a usar existe en la versión instalada (documentación oficial de esa versión o `godot --doctool`). **No inventar APIs.**
- Identificar la fase activa en [docs/05_plan_de_implementacion.md](docs/05_plan_de_implementacion.md). Solo se trabaja en la fase activa.

## 3. Durante la implementación

- Trabajar por fases; no introducir sistemas de fases futuras.
- Crear archivos completos y funcionales. Prohibido el pseudocódigo, los `TODO` que oculten funcionalidad requerida y las implementaciones ficticias.
- Tipado estricto según [docs/03_estandares_de_codigo.md](docs/03_estandares_de_codigo.md). No suprimir advertencias con `@warning_ignore` para ocultar errores de diseño; cualquier supresión requiere comentario justificativo y debe mencionarse en el informe.
- Respetar las capas: `campaigns/` puede depender de `core/` y `shared_assets/`; `core/` **nunca** depende de `campaigns/`.
- No crear carpetas vacías. Cada directorio nace con su primer archivo funcional.
- Sin dependencias externas (addons) sin un ADR aceptado.
- No mezclar cambios no relacionados en una misma entrega.

## 4. Después de implementar

1. Ejecutar las validaciones de [docs/06_estrategia_de_pruebas.md](docs/06_estrategia_de_pruebas.md).
2. Revisar la salida completa: cero errores y cero advertencias de GDScript procedentes de `res://` (la política de advertencias está en [docs/04](docs/04_configuracion_del_proyecto.md) §5 y no deja ninguna categoría en nivel “advertencia”, por lo que el criterio siempre es satisfacible).
3. Corregir y volver a validar.
4. Actualizar la documentación afectada y la tabla de estado de [docs/05](docs/05_plan_de_implementacion.md). Fuera de eso, la documentación está congelada según el criterio de suficiencia de la Fase 0 (docs/05): no se reescriben documentos por iniciativa propia.
5. Informar con este formato:

```text
## Informe de entrega
Fase: <n>
Completo (verificado): <lista + cómo se verificó>
Parcial: <lista + qué falta>
Pendiente: <lista>
Validaciones ejecutadas: <comandos + resultado>
Limitaciones / riesgos: <lista>
Decisiones tomadas: <lista o enlace a ADR>
```

Una funcionalidad **no** está terminada porque el código fue escrito: está terminada cuando se comprobó. Si algo no pudo verificarse (por ejemplo, prueba visual sin pantalla), declararlo explícitamente como *no verificado*.

## 5. Restricción fundamental

No avanzar a la siguiente fase mientras existan errores críticos o criterios de aceptación incumplidos en la fase actual.

## 6. Contenido histórico

Todo elemento histórico relevante (personajes, arquitectura, vestimenta, objetos, eventos, textos en pantalla) debe registrarse con su clasificación y fuente según [docs/07_convenciones_historicas.md](docs/07_convenciones_historicas.md). Un agente nunca presenta una reconstrucción o licencia narrativa como hecho documentado.

## 7. Idioma

- Identificadores de código (clases, funciones, variables, señales, acciones de entrada): inglés.
- Nombres de archivos de contenido de campaña: pueden estar en español (`quero_chicha.gd`, `mundo_base.tscn`).
- Comentarios, documentación y textos para el jugador: español.
- Términos quechuas: grafía según la convención de la campaña (ver documentación de campaña).
