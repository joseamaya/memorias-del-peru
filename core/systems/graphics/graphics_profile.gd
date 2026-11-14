class_name GraphicsProfile
extends Resource
## Perfil de calidad gráfica.
##
## Los valores los aplica GraphicsSettings a nivel global y
## EnvironmentQualityController a cada mundo.

@export var profile_name: String = "Bajo"
@export var volumetric_fog_enabled: bool = false
@export var ssao_enabled: bool = false
@export var ssil_enabled: bool = false
@export var sdfgi_enabled: bool = false
@export var shadow_distance: float = 40.0
@export var shadow_atlas_size: int = 1024
@export var shadow_filter_quality: RenderingServer.ShadowQuality = RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW
@export var render_scale: float = 0.75
## Upscaler del búfer 3D. El bilineal es más barato en la GPU de referencia:
## a 0,83 de escala da 72 FPS frente a 66 con FSR 1 (docs/08). FSR queda
## disponible por perfil si en otro equipo compensa el detalle extra.
@export var scaling_3d_mode: Viewport.Scaling3DMode = Viewport.SCALING_3D_MODE_BILINEAR
@export var msaa_3d: Viewport.MSAA = Viewport.MSAA_DISABLED
@export var screen_space_aa: Viewport.ScreenSpaceAA = Viewport.SCREEN_SPACE_AA_FXAA
