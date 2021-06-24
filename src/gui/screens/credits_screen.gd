class_name CreditsScreen
extends Screen


const GODOT_URL := "https://godotengine.org"

const NAME := "credits"
const LAYER_NAME := "menu_screen"
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true


func _init().(
        NAME,
        LAYER_NAME,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY,
        INCLUDES_NAV_BAR,
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass


func _ready() -> void:
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/Title.texture = \
            Gs.app_metadata.app_logo
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/Title.texture_scale = \
            Vector2(Gs.app_metadata.app_logo_scale,
                    Gs.app_metadata.app_logo_scale)
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer4/ \
            DeveloperLogoLink/DeveloperLogo.visible = \
            Gs.gui.is_developer_logo_shown
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer4/ \
            DeveloperLogoLink/DeveloperLogo.texture = \
            Gs.app_metadata.developer_logo
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer4/ \
            DeveloperNameLink.text = Gs.app_metadata.developer_name
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer4/ \
            DeveloperUrlLink.text = Gs.app_metadata.developer_url
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/SpecialThanksContainer/ \
            SpecialThanks.text = Gs.gui.special_thanks_text
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/SpecialThanksContainer.visible = \
            Gs.gui.is_special_thanks_shown
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            TermsAndConditionsLink.visible = Gs.app_metadata.is_data_tracked
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            PrivacyPolicyLink.visible = Gs.app_metadata.is_data_tracked
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AccordionPanel/VBoxContainer/ \
            DataDeletionButton.visible = \
                    Gs.app_metadata.is_data_tracked and \
                    Gs.gui.is_data_deletion_button_shown
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AccordionPanel/VBoxContainer/ \
            DataDeletionButtonPadding.visible = \
                    Gs.app_metadata.is_data_tracked and \
                    Gs.gui.is_data_deletion_button_shown
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/VBoxContainer2/ \
            SupportLink.visible = Gs.gui.is_support_shown
    
    $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer/ \
            CenterContainer/VBoxContainer/AccordionPanel/VBoxContainer/ \
            ThirdPartyLicensesButton.visible = \
            Gs.gui.is_third_party_licenses_shown


func _on_snoring_cat_games_link_pressed():
    Gs.utils.give_button_press_feedback()
    OS.shell_open(Gs.app_metadata.developer_url)


func _on_godot_link_pressed():
    Gs.utils.give_button_press_feedback()
    OS.shell_open(GODOT_URL)


func _on_PrivacyPolicyLink_pressed():
    Gs.utils.give_button_press_feedback()
    OS.shell_open(Gs.app_metadata.privacy_policy_url)


func _on_TermsAndConditionsLink_pressed():
    Gs.utils.give_button_press_feedback()
    OS.shell_open(Gs.app_metadata.terms_and_conditions_url)


func _on_SupportLink_pressed():
    Gs.utils.give_button_press_feedback()
    OS.shell_open(Gs.get_support_url_with_params())


func _on_DataDeletionButton_pressed():
    Gs.utils.give_button_press_feedback()
    Gs.nav.open("confirm_data_deletion")


func _on_ThirdPartyLicensesButton_pressed():
    Gs.utils.give_button_press_feedback()
    Gs.nav.open("third_party_licenses")
