extends SceneTree
func _initialize() -> void:
    var root := "res://assets/ui-button-candidates/v1/"
    for family in ["primary","secondary","destructive","selection"]:
        for state in ["normal","hover","focus","pressed","selected","disabled"]:
            var id: String = family+"-"+state
            var image := Image.new()
            var source := FileAccess.get_file_as_string(root+"source/"+id+".svg")
            assert(image.load_svg_from_string(source,2.0) == OK)
            assert(image.save_png(root+id+".png") == OK)
    print("PASS: Godot rasterized 24 transparent candidate states at 2x")
    quit()
