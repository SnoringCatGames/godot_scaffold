tool
class_name FrameworkManifestSchema
extends Reference


const TYPE_SCRIPT := 1001
const TYPE_TILESET := 1002
const TYPE_RESOURCE := 1003
const TYPE_CUSTOM := 1004

const VALID_TYPES := {
    TYPE_BOOL: true,
    TYPE_STRING: true,
    TYPE_INT: true,
    TYPE_REAL: true,
    TYPE_COLOR: true,
    TYPE_SCRIPT: true,
    TYPE_TILESET: true,
    TYPE_RESOURCE: true,
    TYPE_CUSTOM: true,
}

var display_name: String
var folder_name: String
var auto_load_name: String
var auto_load_deps: Array
var auto_load_path: String
var icon_directory_path: String
var properties: Dictionary


func _init(
        display_name: String,
        folder_name: String,
        auto_load_name: String,
        auto_load_deps: Array,
        auto_load_path: String,
        icon_directory_path: String,
        properties: Dictionary) -> void:
    self.display_name = display_name
    self.folder_name = folder_name
    self.auto_load_name = auto_load_name
    self.auto_load_deps = auto_load_deps
    self.auto_load_path = auto_load_path
    self.icon_directory_path = icon_directory_path
    self.properties = properties


func get_manifest_path() -> String:
    return "res://addons/%s/manifest.json" % folder_name


static func get_default_value(schema):
    if schema is Dictionary:
        return {}
    elif schema is Array:
        if schema.size() == 1:
            return []
        else:
            return schema[1]
    else:
        Sc.logger.error("FrameworkManifestSchema.get_default_value")


static func get_is_expected_type(
        value,
        expected_type) -> bool:
    if expected_type is int:
        var actual_type := get_type(value)
        match expected_type:
            actual_type:
                return true
            TYPE_SCRIPT, \
            TYPE_TILESET, \
            TYPE_RESOURCE:
                return value == null
            TYPE_INT, \
            TYPE_REAL:
                return actual_type == TYPE_INT or actual_type == TYPE_REAL
            _:
                return false
    elif expected_type is Dictionary:
        return value is Dictionary
    elif expected_type is Array:
        return value is Array
    else:
        return false


static func get_matches_schema(
        value,
        schema) -> bool:
    if schema is Dictionary:
        return value is Dictionary
    elif schema is Array:
        if schema.size() == 1:
            return value is Array
        else:
            return get_is_expected_type(value, schema[0])
    else:
        Sc.logger.error("FrameworkManifestSchema.get_matches_schema")
        return false


static func get_type(value) -> int:
    if value is Script:
        if value.get_base_script() == FrameworkManifestCustomProperty:
            return TYPE_CUSTOM
        else:
            return TYPE_SCRIPT
    elif value is TileSet:
        return TYPE_TILESET
    elif value is Resource:
        return TYPE_RESOURCE
    else:
        return typeof(value)


static func get_type_string(type) -> String:
    if type is int:
        pass
    elif type is Dictionary:
        type = TYPE_DICTIONARY
    elif type is Array:
        type = TYPE_ARRAY
    elif type is Script:
        return "TYPE_CUSTOM"
    else:
        Sc.logger.error("FrameworkManifestSchema.get_type_string")
        return ""
    
    match type:
        TYPE_SCRIPT:
            return "TYPE_SCRIPT"
        TYPE_TILESET:
            return "TYPE_TILESET"
        TYPE_RESOURCE:
            return "TYPE_RESOURCE"
        TYPE_CUSTOM:
            return "TYPE_CUSTOM"
        _:
            return Sc.utils.get_type_string(type)


static func get_resource_class_name(type: int) -> String:
    match type:
        TYPE_SCRIPT:
            return "Script"
        TYPE_TILESET:
            return "TileSet"
        TYPE_RESOURCE:
            return "Resource"
        TYPE_CUSTOM:
            return "Script"
        _:
            Sc.logger.error("FrameworkManifestSchema.get_resource_class_name")
            return ""
