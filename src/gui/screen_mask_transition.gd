class_name ScreenMaskTransition
extends Node


signal completed(previous_screen_container, next_screen_container)

var SHADER := \
        preload("res://addons/scaffolder/src/gui/screen_mask_transition.shader")

var _tween_id: int
var is_transitioning := false

var pixel_snap := true setget _set_pixel_snap
var smooth_size := 0.0 setget _set_smooth_size

var sprite: Sprite
var material: ShaderMaterial
var mask_texture: ImageTexture

var active_screen_container: ScreenContainer
var previous_screen_container: ScreenContainer
var next_screen_container: ScreenContainer


func _init() -> void:
    name = "ScreenMaskTransition"


func _ready() -> void:
    material = ShaderMaterial.new()
    material.shader = SHADER
    
    material.set_shader_param("smooth_size", smooth_size)
    material.set_shader_param("pixel_snap", pixel_snap)
    
    var flipped_image: Image = \
            Gs.nav.transition_handler.screen_mask_transition_fade_texture.get_data()
    flipped_image.flip_y()
    mask_texture = ImageTexture.new()
    mask_texture.create_from_image(flipped_image)
    material.set_shader_param("mask", mask_texture)
    material.set_shader_param("mask_size", mask_texture.get_size())
    
    _set_cutoff(0)
    
    Gs.utils.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _on_resized() -> void:
    var viewport_size := get_viewport().size
    var mask_size := mask_texture.get_size()
    
    var viewport_aspect := viewport_size.x / viewport_size.y
    var mask_aspect := mask_size.x / mask_size.y
    var mask_scale: Vector2
    var mask_offset: Vector2
    if viewport_aspect > mask_aspect:
        mask_scale = Vector2(1, mask_aspect / viewport_aspect)
        mask_offset = Vector2(0, mask_aspect / viewport_aspect / 2.0)
    else:
        mask_scale = Vector2(viewport_aspect / mask_aspect, 1)
        mask_offset = Vector2(viewport_aspect / mask_aspect / 2.0, 0)
    material.set_shader_param("mask_scale", mask_scale)
    material.set_shader_param("mask_offset", mask_offset)
    
    if is_instance_valid(sprite):
        sprite.scale = viewport_size / mask_size


func start(
        active_screen_container: ScreenContainer,
        is_fading_in: bool,
        duration: float,
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer) -> void:
    self.active_screen_container = active_screen_container
    self.previous_screen_container = previous_screen_container
    self.next_screen_container = next_screen_container
    
    is_transitioning = true
    
    var screenshot_image := get_viewport().get_texture().get_data()
    var screenshot_texture := ImageTexture.new()
    screenshot_texture.create_from_image(screenshot_image)
    sprite = Sprite.new()
    sprite.texture = screenshot_texture
    sprite.material = material
    sprite.centered = false
    sprite.flip_v = true
    sprite.scale = get_viewport().size / sprite.texture.get_size()
    Gs.canvas_layers.layers.top.add_child(sprite)
    
    # Fading-in isn't currently supported (we would need to get a screenshot of
    # the new screen that has yet to be shown).
    assert(!is_fading_in)
    var start_cutoff := 0.0
    var end_cutoff := 1.0
    
    Gs.time.clear_tween(_tween_id)
    
    _tween_id = Gs.time.tween_method(
            self,
            "_set_cutoff",
            start_cutoff,
            end_cutoff,
            duration,
            "ease_in_out",
            0.0,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_tween_complete"))


func _set_cutoff(value: float) -> void:
    material.set_shader_param(
            "cutoff",
            value)


func stop(triggers_completed := false) -> bool:
    if !is_transitioning:
        return false
    Gs.time.clear_tween(_tween_id)
    is_transitioning = false
    if is_instance_valid(sprite):
        sprite.queue_free()
        sprite = null
    if triggers_completed:
        emit_signal(
                "completed",
                previous_screen_container,
                next_screen_container)
    return true


func _on_tween_complete(
        _object: Object,
        _key: NodePath) -> void:
    is_transitioning = false
    if is_instance_valid(sprite):
        sprite.queue_free()
        sprite = null
    emit_signal(
            "completed",
            previous_screen_container,
            next_screen_container)


func _set_pixel_snap(value: bool) -> void:
    pixel_snap = value
    if is_instance_valid(material):
        material.set_shader_param("pixel_snap", pixel_snap)


func _set_smooth_size(value: float) -> void:
    smooth_size = value
    if is_instance_valid(material):
        material.set_shader_param("smooth_size", smooth_size)
