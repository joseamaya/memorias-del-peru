"""Prototipo NO integrado: injerta una cabeza MakeHuman en la Sisa Quaternius.

El pipeline MPFB2 funciona en Blender 5.3 con
`BLENDER_USER_RESOURCES=/home/jamaya/.config/blender/5.2`, pero el primer
injerto no está resuelto: la cabeza queda pequeña/hundida, el paño de cabeza
flota y la piel sale pálida. Se conserva como banco de pruebas para el
siguiente pase de alineación, pesos y materiales. No lo usa el juego.
"""
import bpy, bmesh, os, sys, math
from mathutils import Matrix, Vector

SCRIPT='/home/jamaya/Projects/memorias-del-peru/campaigns/01_pachacutec/assets/blender'
sys.path.insert(0, SCRIPT)
import pch_dressed as kit
people = kit._PEOPLE
REPO='/home/jamaya/Projects/memorias-del-peru'
QGLB=REPO + '/campaigns/01_pachacutec/assets/models/pch_npc_sisa_q.glb'
OUT='/tmp/opencode/pch_npc_sisa_q_mh.glb'
PREVIEW='/tmp/opencode/mh_graft'

bpy.ops.wm.read_factory_settings(use_empty=True)
# 1. Cargar la Sisa Q
bpy.ops.import_scene.gltf(filepath=QGLB)
q_arm = next(o for o in bpy.data.objects if o.type=='ARMATURE')
print('Q_ARM', q_arm.name, [b.name for b in q_arm.data.bones][:10])
q_head_bone = q_arm.data.bones.get('Head')
print('Q_HEAD_BONE', q_head_bone, tuple(round(x,3) for x in (q_arm.matrix_world @ q_head_bone.head_local)))
q_neck_bone = q_arm.data.bones.get('neck_01')
print('Q_NECK_BONE', q_neck_bone, tuple(round(x,3) for x in (q_arm.matrix_world @ q_neck_bone.head_local)))
q_body = bpy.data.objects.get('Body')
q_clothes = bpy.data.objects.get('Clothes')
print('Q_BODY', q_body, 'Q_CLOTHES', q_clothes)
for n in ['Hair','Eyes','Eyebrows','TupuDisc','TupuPin']:
    o=bpy.data.objects.get(n); print('Q_PART', n, o)
# 2. Construir la base MakeHuman con cabeza
HumanService, TargetService, data = people['mpfb']()
macro = TargetService.get_default_macro_info_dict()
macro.update({"gender": 0.0, "age": 0.32, "muscle": 0.45, "weight": 0.5, "height": 0.2, "proportions": 0.45})
macro['race'] = {"asian": 0.62, "caucasian": 0.10, "african": 0.28}
base = HumanService.create_human(macro_detail_dict=macro)
for target, weight in people['MOUTH_TARGETS']:
    TargetService.load_target(base, TargetService.target_full_path(target), weight=weight)
mh_rig = HumanService.add_builtin_rig(base, 'cmu_mb')
proxy = None
try:
    proxy_name = 'female1605'
    proxy = HumanService.add_mhclo_asset(os.path.join(data,'proxymeshes',proxy_name,proxy_name+'.proxy'), base, asset_type='Proxymeshes', subdiv_levels=0)
    HumanService.set_character_skin(os.path.join(data,'skins','young_african_female','young_african_female.mhmat'), base, bodyproxy=proxy, skin_type='GAMEENGINE')
    if proxy.data.materials:
        base.data.materials.clear()
        for material in proxy.data.materials:
            base.data.materials.append(material)
except Exception as e:
    print('SKIN_FAIL', e)
extras=[]
for folder,name,kind in [('eyes/low-poly','low-poly','Eyes'),('eyebrows/eyebrow001','eyebrow001','Eyebrows'),('eyelashes/eyelashes01','eyelashes01','Eyelashes'),('hair/long01','long01','Hair')]:
    try:
        extras.append(HumanService.add_mhclo_asset(os.path.join(data,folder,name+'.mhclo'), base, asset_type=kind, subdiv_levels=0, material_type='MAKESKIN'))
    except Exception as e:
        print('PART_FAIL',kind,e)
people['tint_materials'](proxy if proxy is not None else base, extras)
mh_head_bone = mh_rig.data.bones.get('Head')
print('MH_HEAD_BONE', tuple(round(x,3) for x in (mh_rig.matrix_world @ mh_head_bone.head_local)))
# 3. Cortar la cabeza MakeHuman: conservar por encima del cuello
mh_cut_z = 0.93
me = base.data
bm = bmesh.new(); bm.from_mesh(me)
geom = [v for v in bm.verts if v.co.z < mh_cut_z]
bmesh.ops.delete(bm, geom=geom, context='VERTS')
bm.to_mesh(me); bm.free(); me.update()
base.name='MH_Head'
# Las piezas oculares/hair no se cortan
for o in extras:
    o.name = 'MH_' + o.name.split('.')[-1]
# 4. Escala/alineación
mh_head = (mh_rig.matrix_world @ mh_head_bone.head_local)
q_head = (q_arm.matrix_world @ q_head_bone.head_local)
# altura de la cabeza: coronilla frente al cuello
mh_top = max((base.matrix_world @ v.co).z for v in base.data.vertices)
mh_neck = mh_head.z
q_top = 1.84
q_neck = (q_arm.matrix_world @ q_neck_bone.head_local).z
scale = (q_top - q_neck) / max(0.02, (mh_top - mh_neck))
offset = Vector((q_head.x - mh_head.x*scale, q_head.y - mh_head.y*scale, q_neck - mh_head.z*scale))
print('ALIGN scale',round(scale,3),'offset',tuple(round(x,3) for x in offset),'mh_top',round(mh_top,3),'mh_neck',round(mh_neck,3),'q_top',q_top,'q_neck',round(q_neck,3))
xform = Matrix.Translation(offset) @ Matrix.Scale(scale,4)
# Quitar rig/parent de las piezas MakeHuman y aplicar transformación al mundo
if proxy is not None:
    bpy.data.objects.remove(proxy, do_unlink=True)
for o in [base]+extras:
    o.parent = None
    for m in list(o.modifiers):
        if m.type == 'ARMATURE':
            o.modifiers.remove(m)
    o.matrix_world = xform @ o.matrix_world
# 5. Cortar la cabeza UBC del cuerpo Q
me = q_body.data
bm = bmesh.new(); bm.from_mesh(me)
geom = [v for v in bm.verts if (q_body.matrix_world @ v.co).z > q_neck + 0.015]
bmesh.ops.delete(bm, geom=geom, context='VERTS')
bm.to_mesh(me); bm.free(); me.update()
# 6. Quitar pelo/ojos/cejas UBC
for n in ['Hair','Eyes','Eyebrows']:
    o = bpy.data.objects.get(n)
    if o is not None:
        bpy.data.objects.remove(o, do_unlink=True)
# 7. Parentar la cabeza MakeHuman al hueso Head de la Q (rígido)
for o in [base]+extras:
    world = o.matrix_world.copy()
    o.parent = q_arm
    o.parent_type = 'BONE'
    o.parent_bone = 'Head'
    o.matrix_world = world
# 8. Exportar
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=OUT, export_format='GLB', export_yup=True, export_apply=False,
    export_animations=False, export_skins=True, export_cameras=False, export_lights=False,
    export_extras=True, export_image_format='AUTO', use_selection=False)
print('EXPORTED', OUT)
# 9. Render de comprobación
os.makedirs(PREVIEW, exist_ok=True)
bpy.ops.object.camera_add(location=(0.0,-0.9,1.65)); cam=bpy.context.active_object; cam.data.lens=85
target=Vector((0.0,0.0,1.65)); d=target-cam.location; cam.rotation_euler=d.to_track_quat('-Z','Y').to_euler(); bpy.context.scene.camera=cam
for loc,energy in [((-0.6,-0.9,1.95),180),((0.7,-0.5,1.65),60),((0.1,0.8,1.95),100)]:
    bpy.ops.object.light_add(type='AREA',location=loc); l=bpy.context.active_object; l.data.energy=energy; l.data.size=0.8
bpy.context.scene.render.engine='CYCLES'; bpy.context.scene.cycles.samples=32
bpy.context.scene.render.resolution_x=800; bpy.context.scene.render.resolution_y=800
bpy.context.scene.view_settings.view_transform='AgX'
bpy.context.scene.render.filepath='/tmp/opencode/mh_graft_face.png'; bpy.ops.render.render(write_still=True)
bpy.ops.object.camera_add(location=(0.0,-2.6,1.1)); cam2=bpy.context.active_object; cam2.data.lens=55
target2=Vector((0.0,0.0,1.0)); d=target2-cam2.location; cam2.rotation_euler=d.to_track_quat('-Z','Y').to_euler(); bpy.context.scene.camera=cam2
bpy.context.scene.render.filepath='/tmp/opencode/mh_graft_full.png'; bpy.ops.render.render(write_still=True)
print('RENDERED')
