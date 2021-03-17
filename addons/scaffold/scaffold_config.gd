extends Node

# --- Static configuration state ---

var debug: bool
var playtest: bool

var debug_window_size: Vector2

var app_name: String
var app_id: String
var app_version: String

var main_font_normal: Font
var main_font_large: Font
var main_font_xl: Font

var cell_size: Vector2

var aspect_ratio_max: float
var aspect_ratio_min: float

var screen_background_color: Color
var button_normal_color: Color
var button_hover_color: Color
var button_pressed_color: Color
var shiny_button_highlight_color: Color
var key_value_even_row_color: Color
var option_button_normal_color: Color
var option_button_hover_color: Color
var option_button_pressed_color: Color

var screen_exclusions: Array
var screen_inclusions: Array

var main_menu_music: String

var third_party_license_text: String
var special_thanks_text: String

var app_logo: Texture
var developer_name: String
var developer_url: String

var developer_logo: Texture
var developer_splash: Texture

var godot_splash_sound := "achievement"
var developer_splash_sound: String

var godot_splash_screen_duration_sec := 0.8
var developer_splash_screen_duration_sec := 1.0

var main_menu_image_scene_path: String

var fade_in_transition_texture := \
        preload("res://addons/scaffold/assets/images/transition_in.png")
var fade_out_transition_texture := \
        preload("res://addons/scaffold/assets/images/transition_out.png")

var google_analytics_id: String
var terms_and_conditions_url: String
var privacy_policy_url: String
var android_app_store_url: String
var ios_app_store_url: String
var support_url_base: String
var log_gestures_url: String

var input_vibrate_duration_sec := 0.01

var display_resize_throttle_interval_sec := 0.1

var recent_gesture_events_for_debugging_buffer_size := 1000

# --- Derived configuration ---

var is_special_thanks_shown: bool
var is_third_party_licenses_shown: bool
var is_data_tracked: bool
var is_rate_app_shown: bool
var is_support_shown: bool
var is_gesture_logging_supported: bool
var is_developer_logo_shown: bool
var is_developer_splash_shown: bool
var is_main_menu_image_shown: bool

# --- Global state ---

var is_app_ready := false
var agreed_to_terms: bool
var is_giving_haptic_feedback: bool
var is_debug_panel_shown: bool setget \
        _set_is_debug_panel_shown, _get_is_debug_panel_shown
var is_debug_time_shown: bool

var canvas_layers: CanvasLayers
var camera_controller: CameraController
var debug_panel: DebugPanel
var gesture_record: GestureRecord
var next_level_resource_path: String
var level: ScaffoldLevel

# ---

const AGREED_TO_TERMS_SETTINGS_KEY := "agreed_to_terms"
const IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY := "is_giving_haptic_feedback"
const IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY := "is_debug_panel_shown"
const IS_DEBUG_TIME_SHOWN_SETTINGS_KEY := "is_debug_time_shown"
const IS_MUSIC_ENABLED_SETTINGS_KEY := "is_music_enabled"
const IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY := "is_sound_effects_enabled"

const _DEBUG_PANEL_RESOURCE_PATH := "res://addons/scaffold/gui/debug_panel.tscn"

# ---

func _init() -> void:
    print("ScaffoldConfig._init")

func register_app_config(config: Dictionary) -> void:
    self.debug = config.debug
    self.playtest = config.playtest
    self.debug_window_size = config.debug_window_size
    self.app_name = config.app_name
    self.app_id = config.app_id
    self.app_version = config.app_version
    self.main_font_normal = config.main_font_normal
    self.main_font_large = config.main_font_large
    self.main_font_xl = config.main_font_xl
    self.cell_size = config.cell_size
    self.aspect_ratio_max = config.aspect_ratio_max
    self.aspect_ratio_min = config.aspect_ratio_min
    self.screen_background_color = config.screen_background_color
    self.button_normal_color = config.button_normal_color
    self.button_hover_color = config.button_hover_color
    self.button_pressed_color = config.button_pressed_color
    self.shiny_button_highlight_color = config.shiny_button_highlight_color
    self.key_value_even_row_color = config.key_value_even_row_color
    self.option_button_normal_color = config.option_button_normal_color
    self.option_button_hover_color = config.option_button_hover_color
    self.option_button_pressed_color = config.option_button_pressed_color
    self.screen_exclusions = config.screen_exclusions
    self.screen_inclusions = config.screen_inclusions
    self.main_menu_music = config.main_menu_music
    self.third_party_license_text = \
            config.third_party_license_text.strip_edges()
    self.special_thanks_text = config.special_thanks_text.strip_edges()
    self.app_logo = config.app_logo
    self.developer_name = config.developer_name
    self.developer_url = config.developer_url
    
    if config.has("developer_logo"):
        self.developer_logo = config.developer_logo
    if config.has("developer_splash"):
        self.developer_splash = config.developer_splash
    if config.has("godot_splash_sound"):
        self.godot_splash_sound = config.godot_splash_sound
    if config.has("developer_splash_sound"):
        self.developer_splash_sound = config.developer_splash_sound
    if config.has("godot_splash_screen_duration_sec"):
        self.godot_splash_screen_duration_sec = \
                config.godot_splash_screen_duration_sec
    if config.has("developer_splash_screen_duration_sec"):
        self.developer_splash_screen_duration_sec = \
                config.developer_splash_screen_duration_sec
    if config.has("main_menu_image_scene_path"):
        self.main_menu_image_scene_path = config.main_menu_image_scene_path
    if config.has("fade_in_transition_texture"):
        self.fade_in_transition_texture = config.fade_in_transition_texture
    if config.has("fade_out_transition_texture"):
        self.fade_out_transition_texture = config.fade_out_transition_texture
    if config.has("google_analytics_id"):
        self.google_analytics_id = config.google_analytics_id
    if config.has("terms_and_conditions_url"):
        self.terms_and_conditions_url = config.terms_and_conditions_url
    if config.has("privacy_policy_url"):
        self.privacy_policy_url = config.privacy_policy_url
    if config.has("android_app_store_url"):
        self.android_app_store_url = config.android_app_store_url
    if config.has("ios_app_store_url"):
        self.ios_app_store_url = config.ios_app_store_url
    if config.has("support_url_base"):
        self.support_url_base = config.support_url_base
    if config.has("log_gestures_url"):
        self.log_gestures_url = config.log_gestures_url
    if config.has("input_vibrate_duration_sec"):
        self.input_vibrate_duration_sec = \
                config.input_vibrate_duration_sec
    if config.has("display_resize_throttle_interval_sec"):
        self.display_resize_throttle_interval_sec = \
                config.display_resize_throttle_interval_sec
    if config.has("recent_gesture_events_for_debugging_buffer_size"):
        self.recent_gesture_events_for_debugging_buffer_size = \
                config.recent_gesture_events_for_debugging_buffer_size
    
    assert(self.google_analytics_id.empty() == \
            self.privacy_policy_url.empty() and \
            self.privacy_policy_url.empty() == \
            self.terms_and_conditions_url.empty())
    assert((self.developer_splash == null) == \
            self.developer_splash_sound.empty())
    
    self.is_special_thanks_shown = !self.special_thanks_text.empty()
    self.is_third_party_licenses_shown = !self.third_party_license_text.empty()
    self.is_data_tracked = \
            !self.privacy_policy_url.empty() and \
            !self.terms_and_conditions_url.empty() and \
            !self.google_analytics_id.empty()
    self.is_rate_app_shown = \
            !self.android_app_store_url.empty() and \
            !self.ios_app_store_url.empty()
    self.is_support_shown = !self.support_url_base.empty()
    self.is_gesture_logging_supported = !self.log_gestures_url.empty()
    self.is_developer_logo_shown = config.has("developer_logo")
    self.is_developer_splash_shown = \
            config.has("developer_splash") and \
            config.has("developer_splash_sound")
    self.is_main_menu_image_shown = config.has("main_menu_image_scene_path")

func register_main(main: Node) -> void:
    camera_controller = CameraController.new()
    main.add_child(camera_controller)
    
    canvas_layers = CanvasLayers.new()
    main.add_child(canvas_layers)
    
    debug_panel = ScaffoldUtils.add_scene( \
            canvas_layers.layers.top, \
            _DEBUG_PANEL_RESOURCE_PATH, \
            true, \
            true)
    debug_panel.z_index = 1000
    debug_panel.visible = is_debug_panel_shown
    
    if debug or playtest:
        gesture_record = GestureRecord.new()
        canvas_layers.layers.top.add_child(ScaffoldConfig.gesture_record)

func load_state() -> void:
    agreed_to_terms = SaveState.get_setting( \
            AGREED_TO_TERMS_SETTINGS_KEY, \
            false)
    is_giving_haptic_feedback = SaveState.get_setting( \
            IS_GIVING_HAPTIC_FEEDBACK_SETTINGS_KEY, \
            ScaffoldUtils.get_is_android_device())
    is_debug_panel_shown = SaveState.get_setting( \
            IS_DEBUG_PANEL_SHOWN_SETTINGS_KEY, \
            false)
    is_debug_time_shown = SaveState.get_setting( \
            IS_DEBUG_TIME_SHOWN_SETTINGS_KEY, \
            false)
    Audio.is_music_enabled = SaveState.get_setting( \
            IS_MUSIC_ENABLED_SETTINGS_KEY, \
            true)
    Audio.is_sound_effects_enabled = SaveState.get_setting( \
            IS_SOUND_EFFECTS_ENABLED_SETTINGS_KEY, \
            true)

func set_agreed_to_terms() -> void:
    agreed_to_terms = true
    SaveState.set_setting( \
            ScaffoldConfig.AGREED_TO_TERMS_SETTINGS_KEY, \
            true)

func _set_is_debug_panel_shown(is_visible: bool) -> void:
    is_debug_panel_shown = is_visible
    if debug_panel != null:
        debug_panel.visible = is_visible

func _get_is_debug_panel_shown() -> bool:
    return is_debug_panel_shown
