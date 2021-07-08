class_name ScreenTransitionHandler
extends Node


# --- Constants ---

const DEFAULT_OVERLAY_MASK_TRANSITION_FADE_IN_TEXTURE_PATH := \
        "res://addons/scaffolder/assets/images/radial_mask_transition_in.png"
const DEFAULT_OVERLAY_MASK_TRANSITION_FADE_OUT_TEXTURE_PATH := \
        "res://addons/scaffolder/assets/images/radial_mask_transition_in.png"
const DEFAULT_SCREEN_MASK_TRANSITION_FADE_TEXTURE_PATH := \
        "res://addons/scaffolder/assets/images/checkers_mask_transition.png"

# --- Configuration from app manifest ---

var overlay_mask_transition_fade_in_texture := \
        preload(DEFAULT_OVERLAY_MASK_TRANSITION_FADE_IN_TEXTURE_PATH)
var overlay_mask_transition_fade_out_texture := \
        preload(DEFAULT_OVERLAY_MASK_TRANSITION_FADE_OUT_TEXTURE_PATH)
var screen_mask_transition_fade_texture := \
        preload(DEFAULT_SCREEN_MASK_TRANSITION_FADE_TEXTURE_PATH)

var overlay_mask_transition_class: GDScript = OverlayMaskTransition
var screen_mask_transition_class: GDScript = ScreenMaskTransition

var slide_transition_duration := 0.3
var fade_transition_duration := 0.3
var overlay_mask_transition_duration := 1.2
var screen_mask_transition_duration := 1.2

var slide_transition_easing := "ease_in_out"
var fade_transition_easing := "ease_in_out"
var overlay_mask_transition_fade_in_easing := "ease_out"
var overlay_mask_transition_fade_out_easing := "ease_in"
var screen_mask_transition_easing := "ease_in"

var default_transition_type := ScreenTransition.FADE
var fancy_transition_type := ScreenTransition.SCREEN_MASK

var overlay_mask_transition_color := Color.black
var overlay_mask_transition_uses_pixel_snap = true
var overlay_mask_transition_smooth_size := 0.0

var screen_mask_transition_uses_pixel_snap := true
var screen_mask_transition_smooth_size := 0.0

# --- Run-time state ---

var _overlay_mask_transition: OverlayMaskTransition
var _screen_mask_transition: ScreenMaskTransition

var _start_transition_helper_timeout_id := -1
var _start_immediate_transition_timeout_id := -1
var _slide_transition_tween_id := -1
var _fade_transition_tween_id := -1


func _init() -> void:
    Gs.logger.on_global_init(self, "ScreenTransitionHandler")


func _destroy() -> void:
    if is_instance_valid(_overlay_mask_transition):
        _overlay_mask_transition.queue_free()
    if is_instance_valid(_screen_mask_transition):
        _screen_mask_transition.queue_free()
    queue_free()


func register_manifest(screen_manifest: Dictionary) -> void:
    if screen_manifest.has("overlay_mask_transition_fade_in_texture"):
        self.overlay_mask_transition_fade_in_texture = \
                screen_manifest.overlay_mask_transition_fade_in_texture
    if screen_manifest.has("overlay_mask_transition_fade_out_texture"):
        self.overlay_mask_transition_fade_out_texture = \
                screen_manifest.overlay_mask_transition_fade_out_texture
    if screen_manifest.has("screen_mask_transition_fade_texture"):
        self.screen_mask_transition_fade_texture = \
                screen_manifest.screen_mask_transition_fade_texture
    
    if screen_manifest.has("slide_transition_duration"):
        slide_transition_duration = screen_manifest.slide_transition_duration
    if screen_manifest.has("fade_transition_duration"):
        fade_transition_duration = screen_manifest.fade_transition_duration
    if screen_manifest.has("overlay_mask_transition_duration"):
        overlay_mask_transition_duration = \
                screen_manifest.overlay_mask_transition_duration
    if screen_manifest.has("screen_mask_transition_duration"):
        screen_mask_transition_duration = \
                screen_manifest.screen_mask_transition_duration
    
    if screen_manifest.has("slide_transition_easing"):
        slide_transition_easing = \
                screen_manifest.slide_transition_easing
    if screen_manifest.has("fade_transition_easing"):
        fade_transition_easing = \
                screen_manifest.fade_transition_easing
    if screen_manifest.has("overlay_mask_transition_fade_in_easing"):
        overlay_mask_transition_fade_in_easing = \
                screen_manifest.overlay_mask_transition_fade_in_easing
    if screen_manifest.has("overlay_mask_transition_fade_out_easing"):
        overlay_mask_transition_fade_out_easing = \
                screen_manifest.overlay_mask_transition_fade_out_easing
    if screen_manifest.has("screen_mask_transition_easing"):
        screen_mask_transition_easing = \
                screen_manifest.screen_mask_transition_easing
    
    assert(!screen_manifest.has("default_transition_type") or \
            (screen_manifest.default_transition_type != \
                    ScreenTransition.DEFAULT and \
            screen_manifest.default_transition_type != \
                    ScreenTransition.FANCY))
    if screen_manifest.has("default_transition_type"):
        default_transition_type = screen_manifest.default_transition_type
    
    assert(!screen_manifest.has("fancy_transition_type") or \
            (screen_manifest.fancy_transition_type != \
                    ScreenTransition.DEFAULT and \
            screen_manifest.fancy_transition_type != \
                    ScreenTransition.FANCY))
    if screen_manifest.has("fancy_transition_type"):
        fancy_transition_type = screen_manifest.fancy_transition_type
    
    if screen_manifest.has("overlay_mask_transition_class"):
        overlay_mask_transition_class = \
                screen_manifest.overlay_mask_transition_class
    _overlay_mask_transition = \
            screen_manifest.overlay_mask_transition_class.new()
    assert(_overlay_mask_transition is OverlayMaskTransition)
    _overlay_mask_transition.connect(
            "completed",
            self,
            "_on_overlay_mask_transition_complete")
    add_child(_overlay_mask_transition)
    
    if screen_manifest.has("screen_mask_transition_class"):
        screen_mask_transition_class = \
                screen_manifest.screen_mask_transition_class
    _screen_mask_transition = \
            screen_manifest.screen_mask_transition_class.new()
    assert(_screen_mask_transition is ScreenMaskTransition)
    _screen_mask_transition.connect(
            "completed",
            self,
            "_on_screen_mask_transition_complete")
    add_child(_screen_mask_transition)
    
    if screen_manifest.has("overlay_mask_transition_color"):
        overlay_mask_transition_color = \
                screen_manifest.overlay_mask_transition_color
    if screen_manifest.has("overlay_mask_transition_uses_pixel_snap"):
        overlay_mask_transition_uses_pixel_snap = \
                screen_manifest.overlay_mask_transition_uses_pixel_snap
    if screen_manifest.has("overlay_mask_transition_smooth_size"):
        overlay_mask_transition_smooth_size = \
                screen_manifest.overlay_mask_transition_smooth_size
    
    if screen_manifest.has("screen_mask_transition_uses_pixel_snap"):
        screen_mask_transition_uses_pixel_snap = \
                screen_manifest.screen_mask_transition_uses_pixel_snap
    if screen_manifest.has("screen_mask_transition_smooth_size"):
        screen_mask_transition_smooth_size = \
                screen_manifest.screen_mask_transition_smooth_size


func show_first_screen(screen_container: ScreenContainer) -> void:
    screen_container._on_transition_in_started(null)
    screen_container.pause_mode = Node.PAUSE_MODE_STOP
    
    _on_transition_completed(
            null,
            "",
            null,
            screen_container)


func start_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_type: int,
        transition_params: Dictionary,
        is_forward: bool) -> void:
    var transition_method_name: String
    var default_duration: float
    var default_easing: String
    match transition_type:
        ScreenTransition.DEFAULT:
            start_transition(
                    previous_screen_container,
                    next_screen_container,
                    default_transition_type,
                    transition_params,
                    is_forward)
            return
        ScreenTransition.FANCY:
            start_transition(
                    previous_screen_container,
                    next_screen_container,
                    fancy_transition_type,
                    transition_params,
                    is_forward)
            return
        ScreenTransition.IMMEDIATE:
            transition_method_name = "_start_immediate_transition"
            default_duration = INF
            default_easing = ""
        ScreenTransition.SLIDE:
            transition_method_name = "_start_slide_transition"
            default_duration = slide_transition_duration
            default_easing = slide_transition_easing
        ScreenTransition.FADE:
            transition_method_name = "_start_fade_transition"
            default_duration = fade_transition_duration
            default_easing = fade_transition_easing
        ScreenTransition.OVERLAY_MASK:
            transition_method_name = "_start_overlay_mask_transition"
            default_duration = overlay_mask_transition_duration
            default_easing = ""
        ScreenTransition.SCREEN_MASK:
            transition_method_name = "_start_screen_mask_transition"
            default_duration = screen_mask_transition_duration
            default_easing = screen_mask_transition_easing
        _:
            Gs.logger.error()
            transition_method_name = "_start_immediate_transition"
            default_duration = INF
            default_easing = ""
    
    var is_game_screen_next := \
            next_screen_container.contents.screen_name == "game" if \
            is_instance_valid(next_screen_container) else \
            false
    
    var duration: float = \
            transition_params.duration if \
            transition_params.has("duration") else \
            default_duration
    var delay: float = \
            transition_params.delay if \
            transition_params.has("delay") else \
            0.0
    var easing: String = \
            transition_params.easing if \
            transition_params.has("easing") else \
            default_easing
    
    clear_transitions()
    
    if is_instance_valid(previous_screen_container):
        previous_screen_container \
                ._on_transition_out_started(next_screen_container)
        previous_screen_container.pause_mode = Node.PAUSE_MODE_STOP
    
    if is_instance_valid(next_screen_container):
        next_screen_container \
                ._on_transition_in_started(previous_screen_container)
        next_screen_container.pause_mode = Node.PAUSE_MODE_STOP
    
    call(transition_method_name,
            previous_screen_container,
            next_screen_container,
            transition_params,
            is_forward,
            is_game_screen_next,
            duration,
            delay,
            easing)


func _start_immediate_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float,
        easing: String) -> void:
    if delay > 0.0:
        _start_immediate_transition_timeout_id = Gs.time.set_timeout( \
                funcref(self, "_start_immediate_transition"), \
                delay,
                [
                    previous_screen_container,
                    next_screen_container,
                    transition_params,
                    is_forward,
                    is_game_screen_next,
                    duration,
                    0.0,
                ])
    else:
        _update_z_indices(
                previous_screen_container,
                next_screen_container,
                is_forward)
        _on_transition_completed(
                null,
                "",
                previous_screen_container,
                next_screen_container)


func _start_slide_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float,
        easing: String) -> void:
    var tween_screen_container: ScreenContainer
    var start_position: Vector2
    var end_position: Vector2
    if is_game_screen_next:
        tween_screen_container = previous_screen_container
        if is_forward:
            start_position = Vector2.ZERO
            end_position = Vector2(
                    -get_viewport().size.x,
                    0.0)
        else:
            start_position = Vector2.ZERO
            end_position = Vector2(
                    get_viewport().size.x,
                    0.0)
    elif is_forward:
        tween_screen_container = next_screen_container
        start_position = Vector2(
                get_viewport().size.x,
                0.0)
        end_position = Vector2.ZERO
    else:
        tween_screen_container = previous_screen_container
        start_position = Vector2.ZERO
        end_position = Vector2(
                get_viewport().size.x,
                0.0)
    
    _update_visibilities(
            previous_screen_container,
            next_screen_container,
            true,
            true)
    _update_z_indices(
            previous_screen_container,
            next_screen_container,
            is_forward)
    
    tween_screen_container.position = start_position
    _slide_transition_tween_id = Gs.time.tween_property(
            tween_screen_container,
            "position",
            start_position,
            end_position,
            duration,
            easing,
            delay,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_transition_completed"),
            [previous_screen_container, next_screen_container])


func _start_fade_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float,
        easing: String) -> void:
    var tween_screen_container: ScreenContainer
    var start_opacity: float
    var end_opacity: float
    if is_game_screen_next:
        tween_screen_container = previous_screen_container
        start_opacity = 1.0
        end_opacity = 0.0
    elif is_forward:
        tween_screen_container = next_screen_container
        start_opacity = 0.0
        end_opacity = 1.0
    else:
        tween_screen_container = previous_screen_container
        start_opacity = 1.0
        end_opacity = 0.0
    
    _update_visibilities(
            previous_screen_container,
            next_screen_container,
            true,
            true)
    _update_z_indices(
            previous_screen_container,
            next_screen_container,
            is_forward)
    
    tween_screen_container.modulate.a = start_opacity
    _fade_transition_tween_id = Gs.time.tween_property(
            tween_screen_container,
            "modulate:a",
            start_opacity,
            end_opacity,
            duration,
            easing,
            delay,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_transition_completed"),
            [previous_screen_container, next_screen_container])


func _start_overlay_mask_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float,
        easing: String) -> void:
    var fade_out_texture: Texture = \
            transition_params.fade_out_texture if \
            transition_params.has("fade_out_texture") else \
            overlay_mask_transition_fade_out_texture
    var fade_in_texture: Texture = \
            transition_params.fade_in_texture if \
            transition_params.has("fade_in_texture") else \
            overlay_mask_transition_fade_in_texture
    var fade_in_easing: String = \
            transition_params.easing if \
            transition_params.has("fade_in_easing") else \
            overlay_mask_transition_fade_in_easing
    var fade_out_easing: String = \
            transition_params.easing if \
            transition_params.has("fade_out_easing") else \
            overlay_mask_transition_fade_out_easing
    var color: Color = \
            transition_params.color if \
            transition_params.has("color") else \
            overlay_mask_transition_color
    var pixel_snap: bool = \
            transition_params.pixel_snap if \
            transition_params.has("pixel_snap") else \
            overlay_mask_transition_uses_pixel_snap
    var smooth_size: float = \
            transition_params.smooth_size if \
            transition_params.has("smooth_size") else \
            overlay_mask_transition_smooth_size
    
    _overlay_mask_transition.fade_out_texture = fade_out_texture
    _overlay_mask_transition.fade_in_texture = fade_in_texture
    _overlay_mask_transition.color = color
    _overlay_mask_transition.pixel_snap = pixel_snap
    _overlay_mask_transition.smooth_size = smooth_size
    _overlay_mask_transition.fade_in_easing = fade_in_easing
    _overlay_mask_transition.fade_out_easing = fade_out_easing
    
    _update_visibilities(
            previous_screen_container,
            next_screen_container,
            true,
            false)
    
    _start_transition_helper_timeout_id = Gs.time.set_timeout( \
            funcref(_overlay_mask_transition, "start"), \
            delay,
            [
                duration,
                previous_screen_container,
                next_screen_container,
            ])
    
    _start_immediate_transition_timeout_id = Gs.time.set_timeout( \
            funcref(self, "_on_overlay_mask_transition_middle"), \
            duration / 2.0 + delay,
            [
                previous_screen_container,
                next_screen_container,
                is_forward,
            ])


func _on_overlay_mask_transition_middle(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        is_forward: bool) -> void:
    _update_visibilities(
            previous_screen_container,
            next_screen_container,
            false,
            true)


func _on_overlay_mask_transition_complete(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer) -> void:
    _on_transition_completed(
            null,
            "",
            previous_screen_container,
            next_screen_container)


func _start_screen_mask_transition(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        transition_params: Dictionary,
        is_forward: bool,
        is_game_screen_next: bool,
        duration: float,
        delay: float,
        easing: String) -> void:
    var tween_screen_container: ScreenContainer
    var is_fading_in: bool
    if is_game_screen_next:
        tween_screen_container = previous_screen_container
        is_fading_in = false
    elif is_forward:
#        tween_screen_container = next_screen_container
#        is_fading_in = true
        tween_screen_container = previous_screen_container
        is_fading_in = false
    else:
        tween_screen_container = previous_screen_container
        is_fading_in = false
    
    var texture: Texture = \
            transition_params.texture if \
            transition_params.has("texture") else \
            screen_mask_transition_fade_texture
    var pixel_snap: bool = \
            transition_params.pixel_snap if \
            transition_params.has("pixel_snap") else \
            screen_mask_transition_uses_pixel_snap
    var smooth_size: float = \
            transition_params.smooth_size if \
            transition_params.has("smooth_size") else \
            screen_mask_transition_smooth_size
    
    _screen_mask_transition.texture = texture
    _screen_mask_transition.pixel_snap = pixel_snap
    _screen_mask_transition.smooth_size = smooth_size
    _screen_mask_transition.easing = easing
    
    _update_visibilities(
            previous_screen_container,
            next_screen_container,
            true,
            false)
    _update_z_indices(
            previous_screen_container,
            next_screen_container,
            is_forward)
    
    _start_transition_helper_timeout_id = Gs.time.set_timeout( \
            funcref(self, "_on_screen_mask_transition_start"), \
            delay, \
            [
                tween_screen_container,
                is_fading_in,
                duration,
                previous_screen_container,
                next_screen_container,
            ])


func _on_screen_mask_transition_start(
            tween_screen_container: ScreenContainer,
            is_fading_in: bool,
            duration: float,
            previous_screen_container: ScreenContainer,
            next_screen_container: ScreenContainer) -> void:
    _screen_mask_transition.start(
            tween_screen_container,
            is_fading_in,
            duration,
            previous_screen_container,
            next_screen_container)
    _update_visibilities(
            previous_screen_container,
            next_screen_container,
            false,
            true)


func _on_screen_mask_transition_complete(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer) -> void:
    _on_transition_completed(
            null,
            "",
            previous_screen_container,
            next_screen_container)


func _update_visibilities(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        is_previous_screen_visible: bool,
        is_next_screen_visible: bool) -> void:
    if is_instance_valid(previous_screen_container):
        previous_screen_container.set_visible(is_previous_screen_visible)
    if is_instance_valid(next_screen_container):
        next_screen_container.set_visible(is_next_screen_visible)


# Assign z-indices according to whether we're transitioning "forward" or
# "backward" between screens.
func _update_z_indices(
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer,
        is_forward: bool) -> void:
    var previous_z_index: int
    var next_z_index: int
    if is_forward:
        previous_z_index = 0
        next_z_index = 1
    else:
        previous_z_index = 1
        next_z_index = 0
    if is_instance_valid(previous_screen_container):
        previous_screen_container.z_index = previous_z_index
    if is_instance_valid(next_screen_container):
        next_screen_container.z_index = next_z_index


func _on_transition_completed(
        _object: Object,
        _key: NodePath,
        previous_screen_container: ScreenContainer,
        next_screen_container: ScreenContainer) -> void:
    if is_instance_valid(previous_screen_container):
        previous_screen_container.set_visible(false)
        previous_screen_container.position = Vector2.ZERO
        previous_screen_container \
                ._on_transition_out_ended(next_screen_container)
        if !previous_screen_container.contents.is_always_alive:
            previous_screen_container._destroy()
    if is_instance_valid(next_screen_container):
        if next_screen_container == Gs.nav.current_screen_container:
            next_screen_container.set_visible(true)
            next_screen_container.position = Vector2.ZERO
            next_screen_container.pause_mode = Node.PAUSE_MODE_PROCESS
            next_screen_container \
                    ._on_transition_in_ended(previous_screen_container)
        else:
            # We already navigated to a different screen while this one was
            # activating.
            if !next_screen_container.contents.is_always_alive:
                next_screen_container._destroy()


func clear_transitions() -> void:
    Gs.time.clear_timeout(_start_transition_helper_timeout_id, true)
    Gs.time.clear_timeout(_start_immediate_transition_timeout_id, true)
    Gs.time.clear_tween(_slide_transition_tween_id, true)
    Gs.time.clear_tween(_fade_transition_tween_id, true)
    _overlay_mask_transition.stop(true)
    _screen_mask_transition.stop(true)
