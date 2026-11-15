"""Reasigna la ropa de los personajes del torso a los brazos y hombros.

Los GLB de `pch_people.py` traían el poncho, la lliclla y la túnica pesados a
los huesos del brazo. Al levantar el brazo —saludar, tejer, golpear con la
porra— la prenda se estiraba como una vela y el gesto dejaba de leerse.

Este paso, reproducible, importa cada GLB, mueve los pesos de los huesos de
brazo y hombro a `Spine1` en la malla `clothes` y vuelve a exportar con los
mismos ajustes que el generador. No toca huesos, UV, texturas ni animaciones:
el resultado conserva las acciones (`idle`, `walk`, `run`, `talk`…), el
esqueleto `Human.rig` y los materiales.

Uso (desde la raíz del repositorio):

    blender --background --factory-startup \\
        --python campaigns/01_pachacutec/assets/blender/pch_cloth_weights.py \\
        -- <entrada.glb> <salida.glb>

El archivo de salida puede sobrescribir al de entrada. Tras reexportar hay que
dejar que Godot reimporte (`godot --headless --path . --import`).
"""

import os
import sys

import bpy

# Huesos cuya influencia sobre la prenda se traslada al torso.
ARM_GROUPS = [
    "LeftArm", "LeftForeArm", "LeftHand", "LeftFingerBase", "LeftHandFinger1", "LThumb",
    "RightArm", "RightForeArm", "RightHand", "RightFingerBase", "RightHandFinger1", "RThumb",
    "LeftShoulder", "RightShoulder",
]
# Hueso que recibe el peso: gira con el tronco y no con el brazo.
TORSO_BONE = "Spine1"
# Malla de la prenda en todos los personajes del elenco.
CLOTH_MESH = "clothes"


def _args() -> tuple[str, str]:
    argv = sys.argv
    if "--" in argv:
        argv = argv[argv.index("--") + 1:]
    if len(argv) < 2:
        raise SystemExit("Uso: -- <entrada.glb> <salida.glb>")
    return argv[0], argv[1]


def _move_weights(mesh: bpy.types.Object) -> int:
    moved = 0
    for group_name in ARM_GROUPS:
        source = mesh.vertex_groups.get(group_name)
        if source is None:
            continue
        target = mesh.vertex_groups.get(TORSO_BONE)
        if target is None:
            target = mesh.vertex_groups.new(name=TORSO_BONE)
        index = source.index
        entries = []
        for vertex in mesh.data.vertices:
            for group in vertex.groups:
                if group.group == index and group.weight > 0.0:
                    entries.append((vertex.index, group.weight))
                    break
        for vertex_index, weight in entries:
            target.add([vertex_index], weight, 'ADD')
        for vertex_index, _weight in entries:
            source.remove([vertex_index])
        moved += len(entries)
    return moved


def main() -> None:
    source_path, target_path = _args()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=source_path)
    mesh = bpy.data.objects.get(CLOTH_MESH)
    moved = _move_weights(mesh) if mesh is not None else 0
    bpy.ops.export_scene.gltf(
        filepath=target_path,
        export_format="GLB",
        export_yup=True,
        export_apply=True,
        export_animations=True,
        export_animation_mode="NLA_TRACKS",
        export_skins=True,
        export_cameras=False,
        export_lights=False,
        export_extras=True,
        export_vertex_color="ACTIVE",
        export_image_format="WEBP",
        export_image_quality=88,
        export_texcoords=True,
        export_normals=True,
    )
    print("CLOTH_WEIGHTS %s pesos movidos %d -> %s (%d bytes)" % (
        CLOTH_MESH, moved, os.path.basename(target_path), os.path.getsize(target_path)))


if __name__ == "__main__":
    main()
