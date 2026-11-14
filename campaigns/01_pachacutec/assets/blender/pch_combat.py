"""Clips de combate para los personajes MakeHuman/Rocketbox.

Genera `assets/animation/pch_npc_combat.glb`, un GLB con **solo la armadura y dos acciones**:
`attack` (golpe con porra) y `hit` (reacción al golpe). Las mallas no se
exportan: el personaje ya las trae, y `CharacterModelVisual` copia las
animaciones a su `AnimationPlayer`.

Uso:
    blender --background --factory-startup --python pch_combat.py
    blender --background --factory-startup --python pch_combat.py -- --preview

Con `--preview` renderiza tres fotogramas de cada acción en /tmp para revisar
las poses antes de exportar. La armadura conserva el nombre `Human.rig` para
que las rutas de pista de Godot coincidan con las del personaje
(`Human_rig/Skeleton3D:Hueso`).

Procedencia: las poses son autoría del proyecto. La armadura es la del
personaje `pch_npc_commoner.glb` (MakeHuman/MPFB2 + Rocketbox, CC0/MIT); ver
`../models/LICENSE.md`.
"""

import math
import os
import sys

import bpy
from mathutils import Matrix, Quaternion, Vector

ASSETS = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ASSETS, "models", "pch_npc_commoner.glb")
TARGET = os.path.join(ASSETS, "animation", "pch_npc_combat.glb")
FPS = 24
PREVIEW_DIR = "/tmp/opencode/combat_preview"

# Huesos que se animan; el resto conserva su reposo.
ANIMATED = [
    "Hips", "Spine", "Spine1", "Neck", "Head",
    "RightShoulder", "RightArm", "RightForeArm", "RightHand",
    "LeftShoulder", "LeftArm", "LeftForeArm", "LeftHand",
    "RightUpLeg", "RightLeg", "LeftUpLeg", "LeftLeg",
]


def load_armature():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=SOURCE)
    armature = next(obj for obj in bpy.data.objects if obj.type == "ARMATURE")
    # El GLB de origen trae una Icosphere suelta, sin esqueleto ni material:
    # no forma parte del personaje y no debe salir en las capturas.
    for obj in bpy.data.objects:
        if obj.name == "Icosphere":
            obj.hide_render = True
    # Las acciones importadas no se tocan; se añaden las nuevas.
    bpy.context.scene.render.fps = FPS
    return armature


def reset_pose(armature):
    for bone in armature.pose.bones:
        bone.rotation_mode = "QUATERNION"
        bone.rotation_quaternion = Quaternion()
        bone.location = Vector()
        bone.scale = Vector((1.0, 1.0, 1.0))


def aim(armature, name, direction):
    """Orienta el hueso para que su eje Y mire a `direction` (espacio de armadura)."""
    bpy.context.view_layer.update()
    bone = armature.pose.bones[name]
    current = bone.matrix.copy()
    axis = (current.to_3x3() @ Vector((0.0, 1.0, 0.0))).normalized()
    target = Vector(direction).normalized()
    turn = axis.rotation_difference(target).to_matrix().to_4x4()
    posed = turn @ current
    posed.translation = current.translation
    bone.matrix = posed


def twist(armature, name, degrees):
    """Gira el hueso sobre su propio eje Y (torsión)."""
    bone = armature.pose.bones[name]
    bone.rotation_quaternion = bone.rotation_quaternion @ Quaternion(
        (0.0, 1.0, 0.0), math.radians(degrees))


def turn(armature, name, degrees, axis):
    """Gira el hueso sobre un eje local (X = flexión, Z = giro lateral)."""
    bone = armature.pose.bones[name]
    vector = {"x": (1.0, 0.0, 0.0), "z": (0.0, 0.0, 1.0)}[axis]
    bone.rotation_quaternion = bone.rotation_quaternion @ Quaternion(
        vector, math.radians(degrees))


def key(armature, action, frame):
    """Inserta la pose actual en [param action].

    La acción se asigna solo durante la inserción: con una acción activa, cada
    `view_layer.update()` reevalúa la animación en el fotograma actual y borra
    la pose que se acaba de construir.
    """
    armature.animation_data.action = action
    for name in ANIMATED:
        bone = armature.pose.bones[name]
        bone.keyframe_insert("rotation_quaternion", frame=frame, group=name)
        if name == "Hips":
            bone.keyframe_insert("location", frame=frame, group=name)
    armature.animation_data.action = None


def new_action(armature, name):
    action = bpy.data.actions.new(name)
    action.use_fake_user = True
    if armature.animation_data is None:
        armature.animation_data_create()
    armature.animation_data.action = None
    return action


def action_fcurves(action):
    """Curvas de la acción, con la API de capas de Blender 5 y la clásica."""
    if hasattr(action, "fcurves"):
        return action.fcurves
    curves = []
    for layer in action.layers:
        for strip in layer.strips:
            for bag in strip.channelbags:
                curves.extend(bag.fcurves)
    return curves


def smooth(action):
    for curve in action_fcurves(action):
        for point in curve.keyframe_points:
            point.interpolation = "BEZIER"
            point.handle_left_type = "AUTO_CLAMPED"
            point.handle_right_type = "AUTO_CLAMPED"


def build_attack(armature):
    """Golpe descendente con porra: anticipación, impacto y recuperación."""
    action = new_action(armature, "attack")

    # 1 — reposo de partida.
    reset_pose(armature)
    key(armature, action, 1)

    # 7 — anticipación: peso atrás, torso girado a la derecha, porra arriba.
    reset_pose(armature)
    twist(armature, "Spine", -14.0)
    twist(armature, "Spine1", -18.0)
    turn(armature, "Spine1", 6.0, "x")
    twist(armature, "Neck", 8.0)
    twist(armature, "Head", 6.0)
    aim(armature, "RightArm", (-0.40, 0.50, 0.76))
    turn(armature, "RightForeArm", 45.0, "x")
    aim(armature, "LeftArm", (0.55, 0.25, -0.80))
    turn(armature, "LeftForeArm", 25.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, -0.05, -0.02))
    turn(armature, "RightUpLeg", -8.0, "x")
    key(armature, action, 7)

    # 13 — impacto: torso girado a la izquierda, brazo delante y abajo.
    reset_pose(armature)
    twist(armature, "Spine", 16.0)
    twist(armature, "Spine1", 20.0)
    turn(armature, "Spine1", -10.0, "x")
    twist(armature, "Neck", -8.0)
    twist(armature, "Head", -7.0)
    aim(armature, "RightArm", (-0.25, -0.82, -0.52))
    turn(armature, "RightForeArm", 18.0, "x")
    aim(armature, "LeftArm", (0.55, 0.35, -0.75))
    turn(armature, "LeftForeArm", 35.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, 0.07, -0.03))
    turn(armature, "RightUpLeg", 10.0, "x")
    key(armature, action, 13)

    # 19 — seguimiento: el brazo cruza el cuerpo y el torso termina de girar.
    reset_pose(armature)
    twist(armature, "Spine", 20.0)
    twist(armature, "Spine1", 24.0)
    twist(armature, "Neck", -6.0)
    twist(armature, "Head", -5.0)
    aim(armature, "RightArm", (0.20, -0.50, -0.84))
    turn(armature, "RightForeArm", 30.0, "x")
    aim(armature, "LeftArm", (0.55, 0.25, -0.80))
    turn(armature, "LeftForeArm", 30.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, 0.05, -0.02))
    key(armature, action, 19)

    # 30 — vuelta al reposo.
    reset_pose(armature)
    key(armature, action, 30)

    smooth(action)
    return action


def build_hit(armature):
    """Reacción al golpe: el torso retrocede y la cabeza rebota."""
    action = new_action(armature, "hit")

    reset_pose(armature)
    key(armature, action, 1)

    # 4 — impacto: torso atrás, brazos sueltos, peso en la pierna de atrás.
    reset_pose(armature)
    turn(armature, "Spine", -10.0, "x")
    turn(armature, "Spine1", -14.0, "x")
    twist(armature, "Spine1", 6.0)
    turn(armature, "Neck", -11.0, "x")
    turn(armature, "Head", -7.0, "x")
    aim(armature, "RightArm", (-0.34, 0.16, -0.93))
    turn(armature, "RightForeArm", 34.0, "x")
    aim(armature, "LeftArm", (0.34, 0.16, -0.93))
    turn(armature, "LeftForeArm", 30.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, -0.06, -0.04))
    key(armature, action, 4)

    # 10 — recuperación: el torso vuelve, la cabeza todavía atrás.
    reset_pose(armature)
    turn(armature, "Spine", -4.0, "x")
    turn(armature, "Spine1", -6.0, "x")
    turn(armature, "Neck", -4.0, "x")
    aim(armature, "RightArm", (-0.40, 0.08, -0.91))
    turn(armature, "RightForeArm", 18.0, "x")
    aim(armature, "LeftArm", (0.40, 0.08, -0.91))
    turn(armature, "LeftForeArm", 16.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, -0.02, -0.01))
    key(armature, action, 10)

    # 18 — reposo.
    reset_pose(armature)
    key(armature, action, 18)

    smooth(action)
    return action


def build_death(armature):
    """Caída del derribado: impacto, rodillas que ceden y cuerpo al suelo."""
    action = new_action(armature, "death")

    reset_pose(armature)
    key(armature, action, 1)

    # 5 — impacto: el torso se va atrás y la cabeza rebota.
    reset_pose(armature)
    turn(armature, "Spine", -12.0, "x")
    turn(armature, "Spine1", -16.0, "x")
    turn(armature, "Neck", -12.0, "x")
    turn(armature, "Head", -8.0, "x")
    aim(armature, "RightArm", (-0.40, 0.20, -0.89))
    turn(armature, "RightForeArm", 26.0, "x")
    aim(armature, "LeftArm", (0.40, 0.20, -0.89))
    turn(armature, "LeftForeArm", 24.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, -0.04, 0.03))
    key(armature, action, 5)

    # 13 — las rodillas ceden: el cuerpo baja y el torso queda atrás.
    reset_pose(armature)
    turn(armature, "Hips", -14.0, "x")
    turn(armature, "Spine", -10.0, "x")
    turn(armature, "Spine1", -12.0, "x")
    turn(armature, "Neck", -8.0, "x")
    turn(armature, "RightUpLeg", 34.0, "x")
    turn(armature, "LeftUpLeg", 30.0, "x")
    turn(armature, "RightLeg", -46.0, "x")
    turn(armature, "LeftLeg", -42.0, "x")
    aim(armature, "RightArm", (-0.52, 0.30, -0.80))
    turn(armature, "RightForeArm", 34.0, "x")
    aim(armature, "LeftArm", (0.52, 0.30, -0.80))
    turn(armature, "LeftForeArm", 32.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, -0.30, 0.02))
    key(armature, action, 13)

    # 24 — pierde el equilibrio y cae de espaldas.
    reset_pose(armature)
    turn(armature, "Hips", -62.0, "x")
    turn(armature, "Spine", -6.0, "x")
    turn(armature, "Neck", -6.0, "x")
    turn(armature, "RightUpLeg", 26.0, "x")
    turn(armature, "LeftUpLeg", 22.0, "x")
    turn(armature, "RightLeg", -28.0, "x")
    turn(armature, "LeftLeg", -24.0, "x")
    aim(armature, "RightArm", (-0.62, 0.34, -0.70))
    turn(armature, "RightForeArm", 22.0, "x")
    aim(armature, "LeftArm", (0.62, 0.34, -0.70))
    turn(armature, "LeftForeArm", 20.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, -0.52, 0.16))
    key(armature, action, 24)

    # 32 — en el suelo, boca arriba.
    reset_pose(armature)
    turn(armature, "Hips", -88.0, "x")
    turn(armature, "Neck", 10.0, "x")
    turn(armature, "Head", 6.0, "x")
    turn(armature, "RightUpLeg", 12.0, "x")
    turn(armature, "LeftUpLeg", 8.0, "x")
    turn(armature, "RightLeg", -14.0, "x")
    turn(armature, "LeftLeg", -10.0, "x")
    aim(armature, "RightArm", (-0.86, 0.10, -0.50))
    turn(armature, "RightForeArm", 14.0, "x")
    aim(armature, "LeftArm", (0.86, 0.10, -0.50))
    turn(armature, "LeftForeArm", 12.0, "x")
    armature.pose.bones["Hips"].location = Vector((0.0, -0.66, 0.30))
    key(armature, action, 32)

    # 34 — quieto.
    key(armature, action, 34)

    smooth(action)
    return action


def render_preview(armature, actions):
    os.makedirs(PREVIEW_DIR, exist_ok=True)
    scene = bpy.context.scene
    # Workbench con luz de estudio: se lee la pose sin depender de texturas.
    scene.render.engine = "BLENDER_WORKBENCH"
    scene.display.shading.light = "STUDIO"
    scene.display.shading.color_type = "MATERIAL"
    scene.display.shading.show_shadows = True
    scene.render.resolution_x = 540
    scene.render.resolution_y = 720
    scene.render.film_transparent = False
    scene.world = bpy.data.worlds.new("PreviewWorld")
    scene.world.color = (0.22, 0.24, 0.28)

    # La armadura importada viene girada 180° en Z: el frente del personaje
    # mira al +Y del mundo, así que "adelante" en espacio de armadura es -Y.
    target = Vector((0.0, 0.0, 0.70))
    location = Vector((2.0, 3.0, 1.85))
    camera = bpy.data.objects.new("PreviewCamera", bpy.data.cameras.new("PreviewCamera"))
    camera.location = location
    camera.rotation_euler = (target - location).to_track_quat("-Z", "Y").to_euler()
    camera.data.lens = 52.0
    scene.collection.objects.link(camera)
    scene.camera = camera

    for action, frames in actions:
        armature.animation_data.action = action
        for frame in frames:
            scene.frame_set(frame)
            scene.render.filepath = f"{PREVIEW_DIR}/{action.name}_{frame:02d}.png"
            bpy.ops.render.render(write_still=True)
    print("PREVIEW_OK", PREVIEW_DIR)


def export(armature):
    # Solo viajan los dos clips nuevos: el resto de acciones viene del GLB de
    # origen y ya está en el personaje.
    for action in list(bpy.data.actions):
        if action.name not in ("attack", "hit", "death"):
            bpy.data.actions.remove(action)
    for obj in bpy.data.objects:
        obj.select_set(False)
    armature.select_set(True)
    bpy.context.view_layer.objects.active = armature
    bpy.ops.export_scene.gltf(
        filepath=TARGET,
        export_format="GLB",
        use_selection=True,
        export_animations=True,
        export_animation_mode="ACTIONS",
        export_force_sampling=True,
        export_bake_animation=True,
        export_optimize_animation_size=True,
        export_yup=True,
        export_apply=False,
        export_skins=True,
        export_morph=False,
    )
    print("EXPORT_OK", TARGET)


def main():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    armature = load_armature()
    attack = build_attack(armature)
    hit = build_hit(armature)
    death = build_death(armature)
    if "--preview" in args:
        render_preview(armature, [
            (attack, (1, 7, 13, 19)),
            (hit, (1, 4, 10)),
            (death, (5, 13, 24, 32)),
        ])
        return
    export(armature)


main()
