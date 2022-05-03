class_name ScaffolderCamera
extends Camera2D


signal zoomed
signal panned

const _TWEEN_DURATION := 0.1

var is_active := false setget _set_is_active,_get_is_active

var transitions_smoothly_from_previous_camera := true

var _camera_swap_offset := Vector2.ZERO
var _controller_offset := Vector2.ZERO
var _misc_offset := Vector2.ZERO

var _camera_swap_zoom := 1.0
var _controller_zoom := 1.0
var _misc_zoom := 1.0

var _controller_tween: ScaffolderTween
var _camera_swap_tween: ScaffolderTween

var _target_controller_offset := Vector2.ZERO
var _target_controller_zoom := 1.0

var _max_zoom: float


func _init() -> void:
    self.smoothing_enabled = true
    self.smoothing_speed = Sc.camera.smoothing_speed
    
    _controller_tween = ScaffolderTween.new(self)
    _camera_swap_tween = ScaffolderTween.new(self)


func _ready() -> void:
    if Sc.camera.camera_also_limits_max_zoom_to_level_bounds:
        _max_zoom = min(
                Sc.camera.camera_max_zoom,
                _calculate_max_zoom_for_camera_bounds())
    else:
        _max_zoom = Sc.camera.camera_max_zoom


func _destroy() -> void:
    pass


func _validate() -> void:
    Sc.logger.error("Abstract ScaffolderCamera._validate is not implemented")


func reset(emits_signal := true) -> void:
    self._camera_swap_offset = Vector2.ZERO
    self._controller_offset = Vector2.ZERO
    self._misc_offset = Vector2.ZERO
    
    self._camera_swap_zoom = 1.0
    self._controller_zoom = 1.0
    self._misc_zoom = 1.0
    
    self._target_controller_offset = Vector2.ZERO
    self._target_controller_zoom = 1.0
    
    self._controller_tween.stop_all()
    self._camera_swap_tween.stop_all()
    
    _update_offset_and_zoom(true, emits_signal)


func _on_resized() -> void:
    _update_offset_and_zoom()


func _set_is_active(value: bool) -> void:
    var previous_camera: ScaffolderCamera = Sc.level.camera
    if value:
        Sc.level.camera = self
        self.make_current()
        _update_offset_and_zoom()
        # Pan smoothly from the old camera.
        if is_instance_valid(previous_camera) and \
                previous_camera != self and \
                transitions_smoothly_from_previous_camera:
            _transition_from_other_camera(previous_camera)
    else:
        if Sc.level.camera == self:
            Sc.level.camera = null


func _get_is_active() -> bool:
    return self == Sc.level.camera


func _process(_delta: float) -> void:
    # Manual override zooming.
    if Sc.level_button_input.is_action_pressed("zoom_in"):
        Sc.camera.manual_zoom = \
                Sc.camera.manual_zoom / Sc.camera.manual_zoom_key_step_ratio
    elif Sc.level_button_input.is_action_pressed("zoom_out"):
        Sc.camera.manual_zoom = \
                Sc.camera.manual_zoom * Sc.camera.manual_zoom_key_step_ratio
    
    # Manual override panning.
    if Sc.level_button_input.is_action_pressed("pan_up"):
        Sc.camera.manual_offset = Vector2(
                Sc.camera.manual_offset.x,
                Sc.camera.manual_offset.y - \
                    Sc.camera.manual_pan_key_step_distance)
    elif Sc.level_button_input.is_action_pressed("pan_down"):
        Sc.camera.manual_offset = Vector2(
                Sc.camera.manual_offset.x,
                Sc.camera.manual_offset.y + \
                    Sc.camera.manual_pan_key_step_distance)
    elif Sc.level_button_input.is_action_pressed("pan_left"):
        Sc.camera.manual_offset = Vector2(
                Sc.camera.manual_offset.x - \
                    Sc.camera.manual_pan_key_step_distance,
                Sc.camera.manual_offset.y)
    elif Sc.level_button_input.is_action_pressed("pan_right"):
        Sc.camera.manual_offset = Vector2(
                Sc.camera.manual_offset.x + \
                    Sc.camera.manual_pan_key_step_distance,
                Sc.camera.manual_offset.y)


func _unhandled_input(event: InputEvent) -> void:
    # Mouse wheel events are never considered pressed by Godot--rather they are
    # only ever considered to have just happened.
    if Sc.gui.is_player_interaction_enabled and \
            event is InputEventMouseButton:
        if event.button_index == BUTTON_WHEEL_UP or \
                event.button_index == BUTTON_WHEEL_DOWN:
            # Zoom toward the cursor.
            var zoom: float = \
                    _target_controller_zoom / Sc.camera.camera_zoom_speed_multiplier if \
                    event.button_index == BUTTON_WHEEL_UP else \
                    _target_controller_zoom * Sc.camera.camera_zoom_speed_multiplier
            var cursor_level_position: Vector2 = \
                    Sc.utils.get_level_touch_position(event)
            _zoom_to_position(zoom, cursor_level_position)


func match_camera(other: ScaffolderCamera) -> void:
    reset(false)
    _target_controller_offset = \
            other._target_controller_offset + other._misc_offset
    _target_controller_zoom = \
            other._target_controller_zoom * other._misc_zoom
    _controller_offset = _target_controller_offset
    _controller_zoom = _target_controller_zoom
    _update_offset_and_zoom(true, false)


func _transition_from_other_camera(
        previous_camera: ScaffolderCamera,
        duration := Sc.camera.offset_transition_duration) -> void:
    _transition_from_offset_and_zoom(
            previous_camera.get_camera_screen_center(),
            previous_camera.zoom.x,
            duration)


func _transition_from_offset_and_zoom(
        other_offset: Vector2,
        other_zoom: float,
        duration := Sc.camera.offset_transition_duration) -> void:
    # NOTE: We have to use camera.get_camera_screen_center, rather than
    #       calculating the position difference ourselves, because of
    #       Camera2D.smoothing_enabled.
    var current_camera_center := self.get_camera_screen_center()
    var start_offset := other_offset - current_camera_center
    var end_offset := Vector2.ZERO
    
    var start_zoom := other_zoom / self.zoom.x
    var end_zoom := 1.0
    
    _set_camera_swap_offset(start_offset)
    _set_camera_swap_zoom(start_zoom)
    
    _camera_swap_tween.stop_all()
    if end_offset == start_offset and \
            end_zoom == start_zoom:
        return
    # FIXME: ----------- Combine this into a single interpolate_method.
    _camera_swap_tween.interpolate_method(
            self,
            "_set_camera_swap_offset",
            start_offset,
            end_offset,
            duration,
            "ease_in_out",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    _camera_swap_tween.interpolate_method(
            self,
            "_set_camera_swap_zoom",
            start_zoom,
            end_zoom,
            duration,
            "ease_in_out",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    _camera_swap_tween.start()


func _zoom_to_position(
        zoom: float,
        zoom_target_level_position: Vector2,
        includes_tween := true) -> void:
    zoom = _clamp_zoom(zoom)
    var cursor_camera_position := zoom_target_level_position - self.offset
    var delta_offset := cursor_camera_position * (1 - zoom / _target_controller_zoom)
    var offset := _target_controller_offset + delta_offset
    _update_controller_pan_and_zoom(offset, zoom, includes_tween)


func get_visible_region() -> Rect2:
    var canvas_transform := self.get_canvas_transform()
    var position := \
            -canvas_transform.get_origin() / canvas_transform.get_scale()
    var size := self.get_viewport_rect().size / canvas_transform.get_scale()
    return Rect2(position, size)


func get_center() -> Vector2:
    return self.get_camera_screen_center()


func _calculate_max_zoom_for_camera_bounds() -> float:
    var viewport_size: Vector2 = self.get_viewport_rect().size
    var viewport_aspect_ratio := viewport_size.x / viewport_size.y
    var camera_bounds_size: Vector2 = Sc.level.camera_bounds.size
    var camera_bounds_aspect_ratio := \
            camera_bounds_size.x / camera_bounds_size.y
    if viewport_aspect_ratio > camera_bounds_aspect_ratio:
        # Limited by x dimension.
        return camera_bounds_size.x / viewport_size.x
    else:
        # Limited by y dimension.
        return camera_bounds_size.y / viewport_size.y


func _calculate_min_position_for_zoom_for_camera_bounds(zoom: float) -> Vector2:
    var camera_region_size: Vector2 = self.get_viewport_rect().size * zoom
    return Sc.level.camera_bounds.position + camera_region_size / 2.0


func _calculate_max_position_for_zoom_for_camera_bounds(zoom: float) -> Vector2:
    var camera_region_size: Vector2 = self.get_viewport_rect().size * zoom
    return Sc.level.camera_bounds.end - camera_region_size / 2.0


func _update_controller_pan_and_zoom(
        next_controller_offset: Vector2,
        next_controller_zoom: float,
        includes_tween := true) -> void:
    var previous_target_controller_offset := _target_controller_offset
    var previous_target_controller_zoom := _target_controller_zoom
    
    # Ensure the pan-controller keeps the camera in-bounds.
    next_controller_zoom = _clamp_zoom(next_controller_zoom)
    var other_zoom_factor: float = \
            self.zoom.x / Sc.camera.manual_zoom / _controller_zoom
    var accountable_camera_zoom := next_controller_zoom * other_zoom_factor
    var offset_without_controller_and_manual: Vector2 = \
            self.offset - Sc.camera.manual_offset - _controller_offset
    var min_offset := \
            _calculate_min_position_for_zoom_for_camera_bounds(
                accountable_camera_zoom) - \
            offset_without_controller_and_manual
    var max_offset := \
            _calculate_max_position_for_zoom_for_camera_bounds(
                accountable_camera_zoom) - \
            offset_without_controller_and_manual
    next_controller_offset.x = clamp(next_controller_offset.x, min_offset.x, max_offset.x)
    next_controller_offset.y = clamp(next_controller_offset.y, min_offset.y, max_offset.y)
    
    _target_controller_offset = next_controller_offset
    _target_controller_zoom = next_controller_zoom
    
    if !includes_tween:
        _controller_tween.stop_all()
        _interpolate_controller_offset(_target_controller_offset)
        _interpolate_controller_zoom(_target_controller_zoom)
    else:
        if Sc.geometry.are_points_equal_with_epsilon(
                    previous_target_controller_offset, _target_controller_offset) and \
                Sc.geometry.are_floats_equal_with_epsilon(
                    previous_target_controller_zoom, _target_controller_zoom) and \
                _controller_tween.is_active():
            return
        
        # FIXME: ---------------
        if !Sc.geometry.are_points_equal_with_epsilon(next_controller_offset, previous_target_controller_offset):
            pass
        
        # Transition to the new values.
        _controller_tween.stop_all()
        # FIXME: ----------- Combine this into a single interpolate_method.
        _controller_tween.interpolate_method(
                self,
                "_interpolate_controller_offset",
                _controller_offset,
                next_controller_offset,
                _TWEEN_DURATION,
                "linear",
                0.0,
                TimeType.PLAY_PHYSICS)
        _controller_tween.interpolate_method(
                self,
                "_interpolate_controller_zoom",
                _controller_zoom,
                next_controller_zoom,
                _TWEEN_DURATION,
                "linear",
                0.0,
                TimeType.PLAY_PHYSICS)
        _controller_tween.start()


func _clamp_zoom(zoom: float) -> float:
    var other_zoom_factor: float = \
            self.zoom.x / \
            Sc.camera.manual_zoom / \
            _controller_zoom
    return clamp(
            zoom,
            Sc.camera.camera_min_zoom / other_zoom_factor,
            _max_zoom / other_zoom_factor)


func _update_offset_and_zoom(
        skips_smoothing := false,
        emits_signal := true) -> void:
    var old_offset := offset
    var old_zoom := zoom.x
    
    var new_zoom: float = \
            Sc.camera.manual_zoom * \
            _camera_swap_zoom * \
            _controller_zoom * \
            _misc_zoom * \
            Sc.camera.gui_camera_zoom_factor / Sc.gui.scale
    var new_offset: Vector2 = \
            Sc.camera.manual_offset + \
            _camera_swap_offset + \
            _controller_offset + \
            _misc_offset
    
#    Sc.logger.print((
#        "CameraController._update_offset_and_zoom:" +
#        "\n  offset: %s (ma=%s, cs=%s, pc=%s, mi=%s)" +
#        "\n  zoom: %1.1f (ma=%1.1f, pc=%1.1f, mi=%1.1f, gu=%1.1f)"
#    ) % [
#        Sc.utils.get_vector_string(new_offset, 0),
#        Sc.utils.get_vector_string(Sc.camera.manual_offset, 0),
#        Sc.utils.get_vector_string(_camera_swap_offset, 0),
#        Sc.utils.get_vector_string(_controller_offset, 0),
#        Sc.utils.get_vector_string(_misc_offset, 0),
#        new_zoom,
#        Sc.camera.manual_zoom,
#        _camera_swap_zoom,
#        _controller_zoom,
#        _misc_zoom,
#        Sc.camera.gui_camera_zoom_factor / Sc.gui.scale,
#    ])
    
    assert(new_zoom != 0.0)
    
    # FIXME: ----------------- Remove? Does this do anything?
    if skips_smoothing:
        var was_smoothing_enabled := smoothing_enabled
        smoothing_enabled = false
        self.offset = new_offset
        self.zoom = Vector2(new_zoom, new_zoom)
        smoothing_enabled = was_smoothing_enabled
    else:
        self.offset = new_offset
        self.zoom = Vector2(new_zoom, new_zoom)
    
    if emits_signal:
        if old_offset != new_offset:
            emit_signal("panned")
            Sc.camera.emit_signal("panned")
        if old_zoom != new_zoom:
            emit_signal("zoomed")
            Sc.camera.emit_signal("zoomed")


func set_position(value: Vector2) -> void:
    .set_position(value)
    assert(value == Vector2.ZERO, "Use `offset` instead of `position`.")


func _set_camera_swap_offset(offset: Vector2) -> void:
    _camera_swap_offset = offset
    _update_offset_and_zoom()


func _interpolate_controller_offset(offset: Vector2) -> void:
    _controller_offset = offset
    _update_offset_and_zoom()


func _set_misc_offset(offset: Vector2) -> void:
    _misc_offset = offset
    _update_offset_and_zoom()


func _set_camera_swap_zoom(zoom: float) -> void:
    _camera_swap_zoom = zoom
    _update_offset_and_zoom()


func _interpolate_controller_zoom(zoom: float) -> void:
    _controller_zoom = zoom
    _update_offset_and_zoom()


func _set_misc_zoom(zoom: float) -> void:
    _misc_zoom = zoom
    _update_offset_and_zoom()
