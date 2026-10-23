class_name SpotlightHud
extends Control

## Presentation-only, active-clock feedback. No gameplay RNG, collision or timers are changed.
const Style = preload("res://scripts/arcade_theme.gd")
const WAVES := ["FIRST POST","COMMENT SECTION","GOING VIRAL","CANCEL STORM","FINAL RATIO"]
var game
var run_id := ""
var last_wave := 1
var last_berserk := false
var banner_until := 0.0
var banner_title := ""
var banner_subtitle := ""

func install(owner_game) -> void:
    game = owner_game
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func sync(view: Vector2) -> void:
    size = view
    visible = game.mode == "playing"
    if run_id != game.run_id:
        run_id = game.run_id
        last_wave = game.wave
        last_berserk = false
        banner_until = 0.0
    if game.wave != last_wave:
        last_wave = game.wave
        banner_title = "WAVE %d" % game.wave
        banner_subtitle = WAVES[clampi(game.wave-1,0,4)]
        banner_until = game.run_time+1.8
    var berserk: bool = game.boss_spawned and game.run_time >= game.SoloClock.BERSERK_AT
    if berserk and not last_berserk:
        banner_title = "FULL HATER MODE"
        banner_subtitle = "REGEN / RESISTANCE / HEAVY HITS"
        banner_until = game.run_time+1.8
    last_berserk = berserk
    queue_redraw()

func banner_visible() -> bool:
    if game.mode != "playing" or game.run_time >= banner_until: return false
    # Enemy warnings remain readable above optional friendly transition emphasis.
    for hazard: Dictionary in game.hazard_zones:
        if game._hazard_contains(hazard,game.player_pos,48.0): return false
    for enemy: Dictionary in game.enemies:
        if str(enemy.get("phase","")) in ["warning","charge-warning","charging"]: return false
    return true

static func rectangles(view: Vector2) -> Array[Rect2]:
    if view.x < 700:
        var half := (view.x-52)/2
        return [Rect2(16,16,view.x-208,54),Rect2(16,82,half,50),Rect2(28+half,82,half,50)]
    var available := minf(view.x-224,850)
    var width := (available-24)/3
    return [Rect2(16,16,width,58),Rect2(28+width,16,width,58),Rect2(40+width*2,16,width,58)]

func _text(at: Vector2, caption: String, pixels: int = 18, color: Color = Style.CARD, display: bool = false) -> void:
    draw_string(Style.BLACK if display else Style.NUMBERS,at,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels,color)

func _plate(rect: Rect2, caption: String, progress: float, accent: Color) -> void:
    draw_style_box(Style.box(Style.DEEP,Style.BLUE.lightened(0.25),8,2),rect)
    _text(rect.position+Vector2(10,24),caption,17)
    var track := Rect2(rect.position+Vector2(10,rect.size.y-16),Vector2(rect.size.x-20,7))
    draw_rect(track,Style.BLUE)
    track.size.x *= clampf(progress,0,1)
    draw_rect(track,accent)

func boss_rectangle(enemy: Dictionary) -> Rect2:
    var width := minf(580,size.x-48)
    var top := 186.0 if size.x < 700 else 86.0
    var rect := Rect2((size.x-width)/2,top,width,42)
    var screen: Vector2 = (Vector2(enemy["pos"])-game.camera.position)*game.camera.zoom+game.get_viewport_rect().size*0.5-get_global_position()
    var silhouette := Rect2(screen+Vector2(-105,-190)*game.camera.zoom,Vector2(210,210)*game.camera.zoom)
    if rect.intersects(silhouette):
        rect = Rect2(16,top+42,minf(300,size.x-48),42)
        if rect.intersects(silhouette): rect = Rect2((size.x-width)/2,size.y-170,width,42)
    return rect

func _draw() -> void:
    if game == null or not visible: return
    var bars := rectangles(size)
    _plate(bars[0],"HP %d / %d" % [ceili(game.hp),int(game.max_hp)],game.hp/maxf(1,game.max_hp),Style.CORAL)
    _plate(bars[1],"XP / LEVEL %d" % game.level,game.xp/(30+8*game.level+game.level*game.level),Style.SKY)
    _plate(bars[2],"AURA %d%%" % int(game.aura),game.aura/100,Style.GOLD)
    var clock := "%02d:%02d" % [int(game.run_time)/60,int(game.run_time)%60]
    var info_y := 144.0 if size.x < 700 else 86.0
    var status := Rect2(16,info_y,minf(350,size.x-32),30)
    draw_style_box(Style.box(Style.BLUE,Style.DEEP,6,0),status)
    _text(status.position+Vector2(8,21),"SHIELD %d  /  %s  /  %s" % [ceili(game.shield),"BOSS" if game.boss_spawned else "WAVE %d/5" % game.wave,clock],16)
    if not game.boss_spawned and game.run_time >= game.SoloClock.BOSS_WARNING:
        var warning := Rect2(16,info_y+40,minf(350,size.x-32),32)
        draw_style_box(Style.box(Style.DEEP,Style.GOLD,8,0),warning)
        _text(warning.position+Vector2(10,23),game.SoloClock.warning(game.run_time),18,Style.GOLD)
    for enemy: Dictionary in game.enemies:
        if enemy["kind"] != "boss": continue
        var boss_rect := boss_rectangle(enemy)
        var width := boss_rect.size.x
        _plate(boss_rect,"BIG HATER / %d HP" % ceili(enemy["hp"]),float(enemy["hp"])/maxf(1,float(enemy["max"])),Style.CORAL)
        var warning := Rect2(boss_rect.position+Vector2(0,50),Vector2(width,30))
        draw_style_box(Style.box(Style.DEEP,Style.GOLD,6,0),warning)
        _text(warning.position+Vector2(10,22),"FULL HATER / LAST PUSH!" if game.run_time >= game.SoloClock.LAST_EFFORT_AT else game.SoloClock.warning(game.run_time),17,Style.GOLD)
        break
    if banner_visible():
        var width := minf(420,size.x-48)
        var rect := Rect2((size.x-width)/2,size.y*0.25,width,90)
        for enemy: Dictionary in game.enemies:
            if enemy["kind"] != "boss": continue
            var screen: Vector2 = (Vector2(enemy["pos"])-game.camera.position)*game.camera.zoom+game.get_viewport_rect().size*0.5-get_global_position()
            if rect.intersects(Rect2(screen+Vector2(-105,-190)*game.camera.zoom,Vector2(210,210)*game.camera.zoom)):
                rect.position.y = size.y*0.65
        draw_style_box(Style.box(Style.DEEP,Style.GOLD,12,4),rect)
        _text(rect.position+Vector2(20,36),banner_title,26,Style.GOLD,true)
        _text(rect.position+Vector2(20,65),banner_subtitle,15)
