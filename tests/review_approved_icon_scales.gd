extends SceneTree
const Registry = preload("res://scripts/approved_icon_registry.gd")
const Style = preload("res://scripts/arcade_theme.gd")
class Gallery extends Control:
    var registry = Registry.new()
    var entries: Array = []
    var pixels := 64
    func _draw() -> void:
        draw_rect(Rect2(Vector2.ZERO,size),Style.BLUE)
        for index in range(entries.size()):
            var row: Dictionary = entries[index]
            var at := Vector2((index%5)*320+8,int(index/5)*125+8)
            draw_string(Style.NUMBERS,at+Vector2(0,16),row["id"],HORIZONTAL_ALIGNMENT_LEFT,310,16,Style.PAPER)
            draw_string(Style.NUMBERS,at+Vector2(0,35),row["category"]+" / "+str(pixels)+"px",HORIZONTAL_ALIGNMENT_LEFT,310,13,Style.PAPER)
            for side in range(2):
                var rect := Rect2(at+Vector2(side*(pixels+20),44),Vector2.ONE*pixels)
                draw_rect(rect,Style.DEEP if side==0 else Style.PAPER)
                draw_texture_rect(registry.texture(row["category"],row["id"]),rect,false)
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
    var args := OS.get_cmdline_user_args()
    if args.is_empty(): quit(1); return
    DirAccess.make_dir_recursive_absolute(args[0])
    root.size = Vector2i(1600,1000)
    root.content_scale_size = root.size
    var gallery := Gallery.new()
    gallery.size = Vector2(root.size)
    gallery.entries = JSON.parse_string(FileAccess.get_file_as_string(Registry.MANIFEST))["icons"]
    var started := Time.get_ticks_usec()
    var decoded_bytes := 0
    for row: Dictionary in gallery.entries:
        decoded_bytes += gallery.registry.texture(row["category"],row["id"]).get_image().get_data().size()
    var first_lookup_us := Time.get_ticks_usec()-started
    started = Time.get_ticks_usec()
    for repeat in range(1000):
        for row: Dictionary in gallery.entries: gallery.registry.texture(row["category"],row["id"])
    var cached_lookup_us := Time.get_ticks_usec()-started
    var evidence := {"engine":Engine.get_version_info()["string"],"approved_textures":gallery.entries.size(),"first_lookup_batch_us":first_lookup_us,"cached_lookup_count":gallery.entries.size()*1000,"cached_lookup_batch_us":cached_lookup_us,"decoded_image_bytes":decoded_bytes,"boundary":"Native Compatibility llvmpipe; warm OS file cache; CPU lookup timing, not browser startup, FPS or physical-device VRAM acceptance"}
    var file := FileAccess.open(str(args[0]).path_join("lookup-performance.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify(evidence,"  ")+"\n")
    root.add_child(gallery)
    for pixels in [32,64]:
        gallery.pixels = pixels
        gallery.queue_redraw()
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        gallery.queue_redraw() # Rebuild commands after first-use glyph atlas updates.
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        var image := root.get_texture().get_image()
        image.save_png(str(args[0]).path_join("approved-%dpx.png" % pixels))
        print("APPROVED SCALE CAPTURE ",pixels,"px viewport=",image.get_size())
    quit(0)
