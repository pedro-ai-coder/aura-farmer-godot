extends SceneTree
const Solo=preload("res://scripts/solo_run.gd")
class IsolatedRun extends Solo:
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var game:=IsolatedRun.new();root.add_child(game)
    assert(root.title=="CLUTCHPUNKS")
    assert(game.headline.text=="CLUTCHPUNKS")
    assert(ProjectSettings.get_setting("application/config/name")=="Aura Farmer")
    assert(OS.get_user_data_dir().ends_with("Aura Farmer"))
    assert(game.ProfileStoreScript.SAVE_KEY=="aura-farmer:profile:v2")
    assert(game.ProfileStoreScript.LEGACY_KEY=="aura-farmer:profile:v1")
    var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://web/aura.webmanifest"))
    assert(manifest.name=="CLUTCHPUNKS" and manifest.short_name=="CLUTCHPUNKS")
    assert(FileAccess.get_file_as_string("res://web/cpk-shell.html").contains("<title>CLUTCHPUNKS</title>"))
    game.queue_free();await process_frame
    print("PASS: Visible CPK title, branded shell/PWA and unchanged native user directory/browser save identifiers")
    quit()
