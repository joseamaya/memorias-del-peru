# 00 — Especificación original

> **Estado de este documento.** Es la especificación técnica de origen (v1.0), conservada íntegra como referencia y punto de partida. **La dirección de producto cambió el 2026-11-19:** *Memorias del Perú* se redefine como antología de cuatro RPG históricos de mundo abierto regional. Este documento describe la versión lineal y **está superado** por [docs/01](01_vision_y_alcance.md), [docs/02](02_arquitectura.md), [docs/11](11_diseno_de_mundo.md) y [docs/12](12_campanas.md). Las desviaciones se justifican en la [bitácora](bitacora.md). Ante una contradicción, prevalece el orden de [AGENTS.md](../AGENTS.md) §3. No se edita: su valor es histórico.
>
> Los ADR se retiraron el 2026-11-14. Sus referencias en este repositorio son históricas y su registro vive en la [bitácora](bitacora.md).

---

# MEMORIAS DEL PERÚ
## Especificación técnica y plan de implementación
**Versión:** 1.0  
**Motor:** Godot 4.x  
**Lenguaje:** GDScript con tipado estricto  
**Renderizador:** Forward+  
**Género:** Aventura histórica / RPG / Exploración en primera persona

---

# 1. Visión del proyecto

Memorias del Perú es una antología de experiencias históricas en 3D que busca reconstruir y representar diferentes períodos de la historia peruana mediante exploración, narrativa, interacción y mecánicas de videojuego.

Cada campaña representa una época histórica independiente, pero comparte los sistemas fundamentales del juego.

La primera campaña será:

**Campaña 01: Pachacútec — La defensa del Cusco**

El jugador experimentará los acontecimientos relacionados con Cusi Yupanqui y la amenaza Chanca durante el siglo XV, recorriendo entornos andinos, interactuando con habitantes, explorando una llacta y participando en acontecimientos históricos.

La experiencia debe priorizar:

- Inmersión en primera persona.
- Reconstrucción histórica documentada.
- Exploración libre de entornos.
- Interacciones contextualizadas.
- Narrativa ambiental.
- Combate y progresión.
- Identidad visual andina.

# 2. Principios arquitectónicos obligatorios

## 2.1. Arquitectura modular

El proyecto debe separar tres niveles:

**Core**
Sistemas compartidos por todas las campañas.

**Shared Assets**
Recursos visuales, sonoros y componentes reutilizables.

**Campaigns**
Contenido, escenas, personajes, misiones y mecánicas particulares de cada campaña.

Una campaña no debe contener copias innecesarias de sistemas que ya existen en Core.

## 2.2. Independencia de campañas

Cada campaña debe poder desarrollar sus escenas y recursos sin modificar los sistemas centrales, salvo que exista una necesidad arquitectónica justificada.

La incorporación de una nueva campaña no debe requerir reescribir el controlador del jugador, el sistema de guardado, las interacciones o el gestor de audio.

## 2.3. Tipado estricto

El tipado explícito es obligatorio.

Ejemplo:

```gdscript
var health: float = 100.0
var movement_speed: float = 5.0
var is_running: bool = false

func calculate_damage(base_damage: float) -> float:
    return base_damage * 1.5
```

Reglas:

- Todas las variables deben tener tipo explícito.
- Todos los parámetros deben estar tipados.
- Todas las funciones deben declarar su tipo de retorno.
- Evitar `Variant` siempre que sea posible.
- Evitar inferencias de tipos cuando puedan generar ambigüedad.
- Evitar conversiones inseguras.
- Utilizar clases tipadas y señales.
- Las advertencias relevantes de GDScript deben configurarse como errores.

Configurar en `project.godot` los niveles de advertencia correspondientes a errores de tipado, declaraciones sin tipo, declaraciones inferidas y accesos inseguros.

No utilizar supresiones de advertencias para ocultar errores de diseño.

## 2.4. Calidad del código

El código debe cumplir:

- Responsabilidad única.
- Bajo acoplamiento.
- Alta cohesión.
- Nombres descriptivos.
- Funciones pequeñas y especializadas.
- Sin lógica de negocio innecesaria en escenas.
- Sin dependencias circulares.
- Sin código duplicado.
- Sin pseudocódigo ni implementaciones ficticias.

# 3. Estructura oficial del repositorio

```text
memorias-del-peru/
│
├── project.godot
├── README.md
├── AGENTS.md
│
├── core/
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   ├── audio_manager.gd
│   │   └── save_manager.gd
│   │
│   ├── player/
│   │   ├── player_fps.tscn
│   │   └── player_fps.gd
│   │
│   ├── interaction/
│   │   └── interactable.gd
│   │
│   └── systems/
│       ├── stamina/
│       ├── inventory/
│       ├── dialogue/
│       └── quest/
│
├── shared_assets/
│   ├── materials/
│   ├── shaders/
│   ├── fonts/
│   ├── textures/
│   ├── audio/
│   └── ui/
│
└── campaigns/
    └── 01_pachacutec/
        ├── scenes/
        │   ├── world/
        │   ├── characters/
        │   ├── objects/
        │   └── missions/
        │
        ├── scripts/
        │   ├── missions/
        │   ├── interactions/
        │   └── characters/
        │
        ├── assets/
        │   ├── models/
        │   ├── textures/
        │   ├── audio/
        │   └── animations/
        │
        └── documentation/
```

No crear carpetas vacías innecesarias. Crear cada directorio cuando se incorpore su primera funcionalidad.

# 4. Configuración del proyecto

Archivo principal: `project.godot`.

Requisitos:

1. Configurar Godot 4.x.
2. Utilizar Forward+ como renderizador.
3. Definir resolución inicial de 1920 × 1080.
4. Configurar escalado de ventana apropiado.
5. Configurar Input Map.
6. Configurar advertencias de GDScript como errores para las categorías relevantes.
7. Preparar la configuración para futuras opciones gráficas.
8. Mantener compatibilidad con sistemas de escritorio.

## 4.1. Input Map obligatorio

| Acción | Tecla |
|---|---|
| move_forward | W |
| move_backward | S |
| move_left | A |
| move_right | D |
| run | Shift izquierdo |
| interact | E |
| jump | Espacio (reservado para implementación posterior) |
| pause | Escape |

El agente debe configurar correctamente los eventos de entrada en Godot y verificar que las acciones se encuentren disponibles.

# 5. Sistema de jugador en primera persona

Archivo:
`core/player/player_fps.gd`

Escena:
`core/player/player_fps.tscn`

## 5.1. Estructura de nodos

```text
PlayerFPS (CharacterBody3D)
│
├── CollisionShape3D
│
└── Head (Node3D)
    │
    └── Camera3D
        │
        └── InteractionRay (RayCast3D)
```

La cámara debe tener su posición visual independiente del movimiento físico del jugador.

## 5.2. Movimiento

Implementar:

- Movimiento en cuatro direcciones.
- Caminar.
- Correr con Shift.
- Gravedad.
- Aceleración.
- Desaceleración.
- Movimiento relativo a la orientación horizontal del personaje.
- Colisiones físicas.

Parámetros configurables:

- Velocidad de caminata.
- Velocidad de carrera.
- Aceleración.
- Desaceleración.
- Sensibilidad del ratón.

No utilizar valores mágicos distribuidos por el código.

## 5.3. Cámara

Implementar:

- Captura inicial del ratón.
- Rotación horizontal del personaje.
- Rotación vertical de la cámara.
- Límite vertical entre -80° y +80°.
- Liberación del ratón mediante Escape.
- Recuperación de captura al reanudar el juego.

La rotación vertical no debe modificar la orientación física horizontal del personaje.

## 5.4. Head Bobbing

Implementar un balanceo sinusoidal de cámara.

Requisitos:

- Diferenciar amplitud y frecuencia al caminar y correr.
- Detener el balanceo cuando el jugador está quieto.
- Evitar saltos de posición al iniciar o detener el movimiento.
- Mantener una posición base de cámara.
- No modificar el origen físico del personaje.
- Evitar acumulación de desplazamientos entre fotogramas.

La implementación matemática debe ejecutarse mediante `_physics_process()` o utilizar una separación temporal explícita que garantice un resultado estable.

# 6. Sistema de interacción

Archivo:
`core/interaction/interactable.gd`

Utilizar una clase base reutilizable llamada `Interactable`.

Contrato inicial:

```gdscript
class_name Interactable
extends Node

func interact(interactor: Node3D) -> void:
    pass

func get_interaction_text() -> String:
    return "Interactuar"
```

El controlador del jugador debe detectar objetos mediante `RayCast3D`.

La detección debe permitir identificar objetos que implementen la clase base.

El jugador no debe contener condiciones particulares para cada objeto.

El sistema debe permitir posteriormente:

- Mostrar indicaciones de interacción.
- Mostrar nombres de objetos.
- Activar diálogos.
- Recoger objetos.
- Abrir puertas.
- Activar mecanismos.
- Realizar ofrendas.
- Consumir alimentos y bebidas.

La detección debe considerar correctamente la jerarquía de nodos: el collider detectado puede ser un hijo del objeto interactuable.

# 7. Primera interacción: Quero de Chicha de Jora

Escena futura:

`campaigns/01_pachacutec/scenes/objects/quero_chicha.tscn`

Script:

`campaigns/01_pachacutec/scripts/interactions/quero_chicha.gd`

Debe heredar de `Interactable`.

Comportamiento:

1. El jugador identifica el quero.
2. Aparece una indicación para interactuar.
3. Al presionar E, se ejecuta la interacción.
4. Se reproduce una animación o respuesta visual.
5. Se reproduce el sonido correspondiente.
6. Se recupera estamina.
7. Se actualiza la interfaz mediante señales.

La recuperación de estamina debe estar separada de la implementación visual del objeto.

Evitar que el objeto acceda directamente a nodos de UI mediante rutas rígidas.

La cantidad recuperada debe ser configurable.

# 8. Entorno atmosférico andino

Escena futura:

`campaigns/01_pachacutec/scenes/world/mundo_base.tscn`

Nodos principales:

```text
MundoBase (Node3D)
│
├── WorldEnvironment
├── DirectionalLight3D
├── Terrain (Node3D)
├── PlayerSpawn (Marker3D)
└── EnvironmentAudio (Node3D)
```

## 8.1. Cielo

Utilizar un material físico de cielo (`PhysicalSkyMaterial`).

Características:

- Azul profundo de altura andina.
- Horizonte atmosférico natural.
- Iluminación coherente con la posición del sol.
- Gradientes naturales.
- Sin apariencia artificial o excesivamente saturada.

## 8.2. Niebla

Utilizar niebla volumétrica cuando el hardware lo permita.

Objetivos visuales:

- Simular niebla matutina en valles andinos.
- Crear profundidad entre montañas.
- Integrar correctamente iluminación y terreno.
- Evitar ocultar innecesariamente los elementos importantes.

La niebla debe poder desactivarse o sustituirse por alternativas menos costosas.

## 8.3. Sol (Inti)

Configurar `DirectionalLight3D`:

- Tonalidad cálida de amanecer.
- Sombras de calidad configurable.
- Dirección coherente con la iluminación ambiental.
- Ajustes de intensidad y temperatura.
- Compatibilidad con los perfiles gráficos.

# 9. Convenciones históricas y artísticas

El proyecto no debe inventar reconstrucciones históricas y presentarlas como hechos comprobados.

Cada elemento histórico relevante debe tener una referencia o justificación documental.

Clasificar el contenido en:

1. Hecho histórico documentado.
2. Evidencia arqueológica.
3. Reconstrucción interpretativa.
4. Licencia narrativa.

La ambientación debe evitar anacronismos en:

- Arquitectura.
- Vestimenta.
- Armas.
- Herramientas.
- Alimentación.
- Organización social.
- Paisajes.
- Lenguaje y denominaciones.

La dirección artística debe buscar coherencia histórica antes que espectacularidad gratuita.

# 10. Rendimiento y escalabilidad

El proyecto debe contemplar desde su arquitectura:

- Niveles de detalle (LOD).
- Culling de objetos.
- Gestión eficiente de materiales.
- Reutilización de recursos.
- Carga de escenas.
- Optimización de iluminación.
- Perfiles gráficos configurables.

No implementar optimizaciones prematuras sin mediciones.

Establecer métricas de referencia antes de ampliar los escenarios.

# 11. Plan de implementación

## Fase 1: Fundación técnica

Entregables:

- `project.godot`.
- Configuración de Input Map.
- Configuración Forward+.
- Estructura de carpetas.
- `player_fps.gd`.
- `player_fps.tscn`.
- Documentación inicial.

Criterios de aceptación:

- El proyecto abre correctamente.
- El motor reconoce todos los scripts.
- El jugador puede caminar y correr.
- El ratón controla la cámara.
- La cámara respeta los límites verticales.
- El balanceo funciona correctamente.
- No hay errores de tipado.
- No hay errores de ejecución.

## Fase 2: Interacción

Entregables:

- `interactable.gd`.
- RayCast funcional.
- Detección de objetos.
- Sistema de indicaciones.
- Sistema básico de estamina.
- Quero de Chicha de Jora.

Criterios de aceptación:

- Los objetos pueden interactuar sin modificar el controlador.
- La detección funciona con jerarquías de nodos.
- La estamina se actualiza correctamente.
- Las interacciones no producen errores.

## Fase 3: Entorno

Entregables:

- `mundo_base.tscn`.
- WorldEnvironment.
- Cielo físico.
- Niebla.
- Iluminación solar.
- Configuración de calidad gráfica.

Criterios de aceptación:

- La escena carga correctamente.
- La iluminación es coherente.
- La niebla tiene profundidad visual.
- Se puede cambiar la calidad gráfica.

## Fase 4: Vertical Slice de Pachacútec

Construir una pequeña sección explorable de una llacta andina.

Incluir:

- Terreno.
- Viviendas.
- Caminos.
- Vegetación.
- Personajes.
- Objetos interactuables.
- Ambientación sonora.
- Primeras experiencias narrativas.

El objetivo es obtener una experiencia jugable completa, aunque pequeña.

# 12. Estrategia de pruebas

Cada fase debe incluir pruebas de aceptación.

El agente debe:

1. Ejecutar una validación de los scripts.
2. Comprobar que las escenas cargan.
3. Revisar errores de consola.
4. Ejecutar las pruebas automatizadas disponibles.
5. Verificar las interacciones en ejecución cuando corresponda.
6. Documentar limitaciones y errores pendientes.

No declarar una funcionalidad terminada solamente porque el código fue escrito.

Una funcionalidad se considera terminada cuando ha sido comprobada.

# 13. Reglas de trabajo para OpenCode

Antes de implementar:

- Inspeccionar el repositorio.
- Verificar la versión instalada de Godot.
- Identificar archivos existentes.
- No sobrescribir código sin analizarlo.
- Comprobar las capacidades reales del motor.

Durante la implementación:

- Trabajar por fases.
- Crear archivos completos y funcionales.
- Mantener tipado estricto.
- Evitar dependencias innecesarias.
- No inventar APIs de Godot.
- No introducir sistemas que no sean necesarios para la fase actual.

Después de implementar:

- Ejecutar las validaciones.
- Revisar los resultados.
- Corregir errores.
- Documentar archivos y decisiones.
- Informar funcionalidades completas, parciales y pendientes.

**Restricción fundamental:** no avanzar a la siguiente fase mientras existan errores críticos o incumplimientos de los criterios de aceptación de la fase actual.

# 14. Primer objetivo de ejecución

Comenzar exclusivamente con la Fase 1.

El agente debe entregar:

1. Estructura inicial del repositorio.
2. `project.godot` completo.
3. `core/player/player_fps.gd`.
4. `core/player/player_fps.tscn`.
5. Documentación de configuración y controles.
6. Evidencia de validación del proyecto.

No implementar todavía el combate, inventario, diálogos, misiones ni sistemas avanzados.

**Resultado esperado:** un proyecto Godot 4 funcional, limpio y tipado estrictamente, con un controlador FPS inmersivo preparado para convertirse en la base de todas las campañas de Memorias del Perú.
