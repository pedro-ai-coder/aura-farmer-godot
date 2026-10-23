extends SceneTree

## Offline source review only. Does not register or promote candidate artwork.
func _initialize() -> void:
    var args := OS.get_cmdline_user_args()
    if args.is_empty():
        push_error("Provide an absolute scratch output directory")
        quit(1)
        return
    var output: String = args[0]
    DirAccess.make_dir_recursive_absolute(output)
    var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art-production/character-hype-clean-cut/v1/manifests/ASSET_MANIFEST.json"))
    var count := 0
    for row: Dictionary in manifest["assets"]:
        for file: Dictionary in row["files"]:
            if file["format"] != "SVG": continue
            var source: String = "res://assets/art-production/character-hype-clean-cut/v1/" + file["path"]
            var image := Image.new()
            if image.load_svg_from_string(FileAccess.get_file_as_string(source)) != OK:
                push_error("SVG decode failed: " + source)
                quit(1)
                return
            if image.save_png(output.path_join(str(row["asset_id"]) + ".png")) != OK:
                quit(1)
                return
            count += 1
    print("SOURCE REVIEW: Godot decoded ",count," SVG candidates into scratch; none promoted")
    quit(0)
