extends "res://tests/weapon_presence/review_run.gd"
func equip(id: String, lv: int=1) -> void:
    passives.append({"id":id,"level":lv,"rarity":SoloOfferRulesScript.PASSIVE_DATA[id].rarity})
func confirm_card(card: Dictionary) -> void:
    card["label"]=str(WEAPONS[card.id].name) if WEAPONS.has(card.id) else PassiveFeedbackScript.name_for(card.id)
    selection.assign([card]);pending_choices=1;mode="choice";selected_card_index=0;_show_ui();_confirm_selection()
func prepare(state: String) -> void:
    var ranged: bool=state in ["timed-active","timed-expired","cinema-flex","wsquad-flex"]
    fixture("no-cap" if ranged else "cope-shield" if state in ["shield","absorption","too-sigma","dense"] else "keyboard-warrior","female",state=="dense")
    passives.clear()
    for enemy: Dictionary in enemies:enemy.hp=100000;enemy.max=100000;enemy.born=0
    if state!="dense":run_time=25;wave=1;spawn_timer=INF
    match state:
        "acquired":confirm_card({"type":"passive","id":"main-character","rarity":"common","level":1})
        "level":
            equip("main-character");confirm_card({"type":"upgrade_passive","id":"main-character","rarity":"common","level":2})
        "timed-active","timed-expired":
            equip("w-wifi");equip("aura-viral",2)
            passive_timers["wifi_next"]=run_time
            _tick_passives(0);aura=100;_use_flex()
        "stack-low","stack-six","stack-burst","healing":
            equip("let-him-cook");equip("six-to-seven");equip("homie-check")
            hp=max_hp*.5
            if state!="stack-low":
                # Seed a legitimate preceding-hit history; the visible change
                # is caused by the next real weapon collision in the arena.
                cook_stacks=4;cook_expires=run_time+3
                passive_timers["six_counter"]=6 if state=="stack-burst" else 5
                if state=="healing":passive_timers["homie_count"]=7
        "shield","absorption":
            equip("big-chad");equip("certified-w",2)
            passive_timers["big_chad_next"]=run_time;_tick_passives(0)
        "legendary":
            run_time=360;wave=4
            _open_legendary()
            for i in range(legendary_offers.size()):
                if legendary_offers[i].id=="w-squad":selected_card_index=i;break
            if selected_card_index<0:selected_card_index=3
            _confirm_selection()
        "cinema-flex","wsquad-flex":
            equip("absolute-cinema" if state=="cinema-flex" else "w-squad");aura=100;_use_flex()
        "too-sigma":equip("too-sigma");_deal_damage_to_player(max_hp*.9)
        "no-u":equip("no-u");passive_timers["no_u_next"]=run_time;_tick_passives(0)
        "dense":
            equip("big-chad");equip("six-to-seven");equip("so-back");equip("certified-w");equip("no-u")
            passive_timers["no_u_next"]=run_time;_tick_passives(0)
        "build":
            equip("main-character",3);equip("let-him-cook",2);equip("homie-check",2);equip("so-back",2);equip("six-to-seven",2)
    # Only presentation uses this clock. Source simulation remains canonical.
    _show_ui();_update_text();clean_cut_skin.layout_key="";clean_cut_skin.refresh()
