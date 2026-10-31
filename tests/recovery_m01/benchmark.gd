extends SceneTree
const Current=preload("res://scripts/enemy_navigation.gd")
const Previous=preload("res://tests/recovery_m01/navigation_baseline.gd")
func _initialize() -> void:
    var args:=OS.get_cmdline_user_args()
    var nav=Previous if not args.is_empty() and args[0]=="before" else Current
    if true:
        var crowd: Array=[]
        for i in range(100):crowd.append({"pos":Vector2(400+i%10*8,500+i/10*8)})
        var start:=Time.get_ticks_usec()
        for frame in range(3600):
            var goal:=Vector2(780,600) if frame<1800 else Vector2(1050,750)
            for enemy in crowd:
                if Vector2(enemy["pos"]).distance_to(goal)<40:continue
                enemy["pos"]=nav.move(enemy["pos"],goal,1.25,15,enemy)
        print("BENCH ","baseline" if nav==Previous else "corrected"," us=",Time.get_ticks_usec()-start)
    quit()
