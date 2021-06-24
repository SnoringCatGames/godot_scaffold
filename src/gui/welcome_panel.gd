class_name WelcomePanel
extends VBoxContainer


const _FADE_IN_DURATION := 0.2

var post_tween_opacity: float


func _init() -> void:
    post_tween_opacity = modulate.a
    modulate.a = 0.0


func _enter_tree() -> void:
    Gs.time.tween_property(
            self,
            "modulate:a",
            0.0,
            post_tween_opacity,
            _FADE_IN_DURATION)


func _ready() -> void:
    theme = Gs.gui.theme
    
    set_meta("gs_rect_min_size", rect_min_size)
    
    Gs.gui.add_gui_to_scale(self)
    
    var faded_color: Color = Gs.colors.zebra_stripe_even_row
    faded_color.a *= 0.3
    
    var items := []
    for item in Gs.gui.welcome_panel_manifest.items:
        if item.size() == 1:
            items.push_back(HeaderLabeledControlItem.new(item[0]))
        else:
            assert(item.size() == 2)
            items.push_back(StaticTextLabeledControlItem.new(item[0], item[1]))
    
    $PanelContainer/LabeledControlList.even_row_color = faded_color
    $PanelContainer/LabeledControlList.items = items
    
    if Gs.gui.welcome_panel_manifest.has("header") and \
            !Gs.gui.welcome_panel_manifest.header.empty():
        $Header.text = Gs.gui.welcome_panel_manifest.header
    else:
        $Header.text = Gs.app_metadata.app_name
    
    if Gs.gui.welcome_panel_manifest.has("subheader") and \
            !Gs.gui.welcome_panel_manifest.subheader.empty():
        $Subheader.text = Gs.gui.welcome_panel_manifest.subheader
    
    if Gs.gui.welcome_panel_manifest.has("is_subheader_shown") and \
            !Gs.gui.welcome_panel_manifest.is_subheader_shown:
        $Subheader.visible = false
    
    update_gui_scale()


func update_gui_scale() -> bool:
    var original_rect_min_size: Vector2 = get_meta("gs_rect_min_size")

    for child in get_children():
        if child is Control:
            Gs.utils._scale_gui_recursively(child)
        
    rect_min_size = original_rect_min_size * Gs.gui.scale
    rect_size.x = rect_min_size.x
    rect_size.y = \
            $Header.rect_size.y + \
            $Subheader.rect_size.y + \
            $PanelContainer.rect_size.y
    rect_position = (get_viewport().size - rect_size) / 2.0
    
    return true


func _exit_tree() -> void:
    Gs.gui.remove_gui_to_scale(self)
