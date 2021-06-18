class_name WelcomePanel
extends VBoxContainer


const DEFAULT_GUI_SCALE := 1.0
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
    
    Gs.gui.add_gui_to_scale(self, DEFAULT_GUI_SCALE)
    
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
    
    update_gui_scale(1.0)


func update_gui_scale(gui_scale: float) -> bool:
    for child in get_children():
        if child is Control:
            Gs.utils._scale_gui_recursively(child, gui_scale)
        
    rect_min_size *= gui_scale
    rect_size.x = rect_min_size.x
    rect_size.y = \
            $Header.rect_size.y + \
            $Subheader.rect_size.y + \
            $PanelContainer.rect_size.y
    rect_position = (get_viewport().size - rect_size) / 2.0
    
    return true


func _exit_tree() -> void:
    Gs.gui.remove_gui_to_scale(self)
