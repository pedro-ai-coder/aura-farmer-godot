extends "res://tests/test_hero_appearance_selection.gd"

## Deterministic native movie fixture. Uses real simulation and disposable profile.
## Run with --write-movie <output.avi> --fixed-fps 30; no player saves are written.
func verify() -> void:
    if DisplayServer.get_name()=="headless":push_error("Native renderer required");quit(1);return
    root.size=Vector2i(960,540)
    var game:=TestRun.new();root.add_child(game);game.set_process(false)
    var records:Array=[]
    for appearance in ["original","female"]:
        game.mode="heroes";game.select_appearance(appearance)
        for index in range(3):
            game.start_run(index)
            expect(game.hero_appearance==appearance and game.mode=="playing","Movie starts requested appearance")
            for frame in range(120):
                game.touch_direction=Vector2.ZERO if frame<15 or frame>=105 else Vector2.RIGHT if frame<45 else Vector2.LEFT if frame<75 else Vector2.UP if frame<90 else Vector2.DOWN
                game._process(1.0/30.0)
                game.queue_redraw()
                await process_frame
                records.append({"hero":game.hero.id,"appearance":appearance,"frame":frame,"time":game.run_time,"pose":game.hero_pose()})
            print("RECORDED: ",game.hero.id," ",appearance," right/left/up/down/idle, real enemies and weapons")
    var args:=OS.get_cmdline_user_args()
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE)
        file.store_string(JSON.stringify(records,"  "));file.close()
    game.queue_free()
    if failures.is_empty():print("PASS: six continuous native gameplay sequences, canonical simulation and matching approved render routes");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
