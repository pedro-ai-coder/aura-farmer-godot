extends "res://tests/test_hero_appearance_selection.gd"
const Art=preload("res://scripts/proposed_cpk_art.gd")
class Gallery extends Node2D:
    const Renderer=preload("res://scripts/proposed_cpk_art.gd")
    func _draw():
        draw_rect(Rect2(0,0,1200,600),Color("184c60"))
        for hero in range(3):
            var kit="cool-kid" if hero==0 else "alpha"
            var appearance="original" if hero==1 else "female"
            for frame in range(24):
                var slot=hero*24+frame
                Renderer.draw(self,Vector2(slot%12*100+50,int(slot/12)*100+82),kit,{"sheet":Renderer.slug(kit,appearance)+"-proposed","frame":frame,"flip":false})
func verify():
    for slug in ["byte-baddie","alpha-chad","block-queen"]:
        var path="res://assets/art-candidates/"+slug+"/cpk-v1-proposed/atlas.png"
        var image=Image.new()
        expect(image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))==OK,"Actual PNG decodes")
        var imported:Image=(load(path) as Texture2D).get_image()
        expect(imported.detect_alpha()!=Image.ALPHA_NONE,"Godot import preserves alpha")
        expect(image.get_size()==Vector2i(1024,1536) and image.detect_alpha()!=Image.ALPHA_NONE,"RGBA atlas geometry and real transparency")
        for i in range(24):
            var cell=image.get_region(Rect2i(i%4*256,int(i/4)*256,256,256))
            var bounds=cell.get_used_rect()
            expect(bounds.has_area() and bounds.position.x>0 and bounds.position.y>0 and bounds.end.x<256 and bounds.end.y<256,"Nonempty isolated frame "+slug+str(i))
            expect(cell.get_pixel(0,0).a==0 and cell.get_pixel(255,255).a==0,"Transparent corners")
    for extent in [Vector2i(844,390),Vector2i(390,844),Vector2i(1280,720)]:
        root.size=extent
        var game=TestRun.new();root.add_child(game);game.set_process(false)
        game.presentation._window_changed(true);game.presentation.open_heroes()
        await process_frame
        for appearance in ["original","female"]:
            game.select_appearance(appearance)
            await process_frame
            await process_frame
            var skin=game.clean_cut_skin
            for parts in skin.hero_parts:
                var card:Control=parts.help.get_parent()
                for key in ["name","role","starter","flex","help"]:
                    var label:Label=parts[key]
                    expect(label.get_visible_line_count()==label.get_line_count(),"All text lines laid out at "+str(extent))
                    expect(label.position.y+label.size.y<=card.size.y-16,"Text fits card at "+str(extent)+key)
                expect(parts.portrait.stretch_mode==TextureRect.STRETCH_KEEP_ASPECT_CENTERED,"Selection uses full aspect fit")
            skin.hero_scroll.scroll_vertical=9999
            await process_frame
            var bottom:float=skin.hero_scroll.scroll_vertical+skin.hero_scroll.size.y
            var help:Label=skin.hero_parts[2].help
            expect(bottom>=help.get_parent().position.y+help.position.y+help.size.y,"Full last description reachable by scrolling")
        game.queue_free();await process_frame
    if DisplayServer.get_name()!="headless":
        root.content_scale_size=Vector2i.ZERO
        root.size=Vector2i(1200,600)
        var gallery=Gallery.new();root.add_child(gallery)
        await process_frame
        await RenderingServer.frame_post_draw
        var rendered=root.get_texture().get_image()
        rendered.save_png("user://hero-render-integration.png")
        for slot in range(72):
            var colored=0;var white=0
            for y in range(int(slot/12)*100,int(slot/12)*100+100):
                for x in range(slot%12*100,slot%12*100+100):
                    var c:Color=rendered.get_pixel(x,y)
                    if c.r>0.97 and c.g>0.97 and c.b>0.97:white+=1
                    if absf(c.r-Color("184c60").r)>0.05:colored+=1
            expect(colored>80 and white<100,"Actual textured GPU frame, no white rectangle: "+str(slot))
        gallery.queue_free()
    if failures.is_empty():print("PASS: PNG alpha/72 nonempty cells; complete scrollable descriptions; GPU texture lifetime/readback when available");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
