#define PRACTICE_LEVEL_LOW list(XENO_HEALTH_RUNNER, XENO_NO_ARMOR) //runner
#define PRACTICE_LEVEL_MEDIUM_LOW list(XENO_HEALTH_TIER_6, XENO_NO_ARMOR)//drone
#define PRACTICE_LEVEL_MEDIUM list(XENO_HEALTH_TIER_6, XENO_ARMOR_TIER_1) //warrior
#define PRACTICE_LEVEL_HIGH list(XENO_HEALTH_TIER_10, XENO_ARMOR_TIER_3)//crusher
#define PRACTICE_LEVEL_VERY_HIGH list(XENO_HEALTH_QUEEN, XENO_ARMOR_TIER_2)//queen
#define PRACTICE_LEVEL_EXTREMELY_HIGH list(XENO_HEALTH_KING, XENO_ARMOR_FACTOR_TIER_5)//king

/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/structures/props/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = TRUE
	anchored = TRUE
	health = 250

/obj/structure/showcase/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(xeno.a_intent == INTENT_HARM)
		if(unslashable)
			return
		xeno.animation_attack_on(src)
		playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
		xeno.visible_message(SPAN_DANGER("[xeno] slices [src] apart!"),
		SPAN_DANGER("We slice [src] apart!"), null, 5, CHAT_TYPE_XENO_COMBAT)
		deconstruct(FALSE)
		return XENO_ATTACK_ACTION
	else
		attack_hand(xeno)
		return XENO_NONCOMBAT_ACTION

/obj/structure/showcase/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if (PF)
		PF.flags_can_pass_all = PASS_HIGH_OVER_ONLY

/obj/structure/showcase/bullet_act(obj/projectile/P)
	var/damage = P.damage
	health -= damage
	..()
	healthcheck()
	return 1

/obj/structure/showcase/proc/explode()
	src.visible_message(SPAN_DANGER("<B>[src] blows apart!</B>"), null, null, 1)
	deconstruct(FALSE)

/obj/structure/showcase/deconstruct(disassembled = TRUE)
	if(!disassembled)
		var/turf/Tsec = get_turf(src)

		new /obj/item/stack/sheet/metal(Tsec)
		new /obj/item/stack/rods(Tsec)
		new /obj/item/stack/rods(Tsec)

		new /obj/effect/spawner/gibspawner/robot(Tsec)
	return ..()

/obj/structure/showcase/proc/healthcheck()
	if(health <= 0)
		explode()

/obj/structure/showcase/ex_act(severity)
	switch(severity)
		if(EXPLOSION_THRESHOLD_LOW to EXPLOSION_THRESHOLD_MEDIUM)
			if(prob(50))
				deconstruct(FALSE)
		if(EXPLOSION_THRESHOLD_MEDIUM to INFINITY)
			deconstruct(FALSE)

/obj/structure/showcase/yautja
	name = "alien warrior statue"
	desc = "A statue of some armored alien humanoid."
	icon = 	'icons/obj/structures/machinery/yautja_machines.dmi'
	icon_state = "statue_sandstone"

/obj/structure/showcase/yautja/alt
	icon_state = "statue_grey"

/obj/structure/target
	name = "shooting target"
	desc = "A shooting target. Installed on a holographic display mount to help assess the damage done. While being a close replica of real threats a marine would encounter, its not a real target - special firing procedures seen in weapons such as XM88 or Holotarget ammo wont have any effect."
	icon = 'icons/obj/structures/props/target_dummies.dmi'
	icon_state = "target_a"
	density = FALSE
	health = 10000
	wrenchable = TRUE
	anchored = TRUE
	///mode that dictates how difficult the target should be to flatten(kill)
	var/list/practice_mode = PRACTICE_LEVEL_LOW
	///health of the target mode
	var/practice_health = 230
/obj/structure/target/Initialize(mapload, ...)
	. = ..()
	icon_state = pick("target_a", "target_q")

/obj/structure/target/get_examine_text(mob/user)
	. = ..()
	. += SPAN_BOLDNOTICE("It seems to have a control panel on it.")
	. += SPAN_NOTICE("It appears to be at [floor(max(1, practice_health)/practice_mode[1]*100)]% health.")
	if(practice_health <= 0)
		. += SPAN_WARNING("[src] is currently rebooting!")

/obj/structure/target/bullet_act(obj/projectile/bullet)
	. = ..()
	if(practice_health <= 0 || !anchored)
		return
	var/damage_dealt = floor(armor_damage_reduction(GLOB.xeno_ranged, bullet.damage, practice_mode[2], bullet.ammo.penetration))
	langchat_speech(damage_dealt, get_mobs_in_view(7, src) , GLOB.all_languages, skip_language_check = TRUE, animation_style = LANGCHAT_FAST_POP, additional_styles = list("langchat_small"))
	practice_health -= damage_dealt
	animation_flash_color(src, "#FF0000", 1)
	playsound(loc, get_sfx("ballistic_hit"), 20, TRUE, 7)
	if(practice_health <= 0)
		start_practice_health_reset()

/obj/structure/target/attack_hand(mob/user)
	. = ..()
	var/list/sorted_options = list("Very light target" = PRACTICE_LEVEL_LOW, "Light target" = PRACTICE_LEVEL_MEDIUM_LOW, "Standard target" = PRACTICE_LEVEL_MEDIUM, "Heavy target" = PRACTICE_LEVEL_HIGH, "Super-heavy target" = PRACTICE_LEVEL_VERY_HIGH, "Impossible" = PRACTICE_LEVEL_EXTREMELY_HIGH)
	var/picked_option = tgui_input_list(user, "Select target difficulty.", "Target difficulty", sorted_options,  20 SECONDS)
	if(picked_option)
		practice_mode = sorted_options[picked_option]
		practice_health = practice_mode[1]
		user.visible_message(SPAN_NOTICE("[user] adjusted the difficulty of [src]."), SPAN_NOTICE("You adjusted the difficulty of [src] to [lowertext(picked_option)]"))

/obj/structure/target/proc/start_practice_health_reset()
	animate(src, transform = matrix(0, MATRIX_ROTATE), time = 1, easing = EASE_IN)
	animate(transform = matrix(270, MATRIX_ROTATE), time = 1, easing = EASE_OUT)
	langchat_speech("[src] folds to the ground!", get_mobs_in_view(7, src) , GLOB.all_languages, skip_language_check = TRUE, additional_styles = list("langchat_small"))
	playsound(loc, 'sound/machines/chime.ogg', 50, TRUE, 7)
	addtimer(CALLBACK(src, PROC_REF(raise_target)), 5 SECONDS)

/obj/structure/target/proc/raise_target()
	animate(src, transform = matrix(0, MATRIX_ROTATE), time = 1, easing = EASE_OUT)
	langchat_speech("[src] raises back into position!", get_mobs_in_view(7, src) , GLOB.all_languages, skip_language_check = TRUE, additional_styles = list("langchat_small"))
	practice_health = practice_mode[1]

/obj/structure/target/syndicate
	icon_state = "target_s"
	desc = "A shooting target that looks like a hostile agent."
	health = 7500

/obj/structure/target/alien
	icon_state = "target_q"
	desc = "A shooting target with a threatening silhouette."
	health = 6500

/obj/structure/monorail
	name = "monorail track"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "monorail"
	density = FALSE
	anchored = TRUE
	layer = ATMOS_PIPE_LAYER + 0.01


//ICE COLONY RESEARCH DECORATION-----------------------//
//Most of icons made by ~Morrinn
/obj/structure/xenoautopsy
	name = "Research thingies"
	icon = 'icons/obj/structures/props/alien_autopsy.dmi'
	icon_state = "jarshelf_9"

/obj/structure/xenoautopsy/jar_shelf
	name = "jar shelf"
	icon_state = "jarshelf_0"
	var/randomise = 1 //Random icon

/obj/structure/xenoautopsy/jar_shelf/New()
	if(randomise)
		icon_state = "jarshelf_[rand(0,9)]"

/obj/structure/xenoautopsy/tank
	name = "cryo tank"
	desc = "It is empty."
	icon_state = "tank_empty"
	density = TRUE
	unacidable = TRUE
	///Whatever is contained in the tank
	var/obj/occupant
	///What this tank is replaced by when broken
	var/obj/structure/broken_state = /obj/structure/xenoautopsy/tank/broken

/obj/structure/xenoautopsy/tank/deconstruct(disassembled = TRUE)
	if(!broken_state)
		return ..()

	new broken_state(loc)
	new /obj/item/shard(loc)
	playsound(src, "shatter", 25, 1)

	if(occupant)
		occupant = new occupant(loc) //needed for the hugger variant

	return ..()

/obj/structure/xenoautopsy/tank/attackby(obj/item/attacking_item, mob/user)
	. = ..()
	playsound(user.loc, 'sound/effects/Glasshit.ogg', 25, 1)
	take_damage(attacking_item.demolition_mod*attacking_item.force)

/obj/structure/xenoautopsy/tank/proc/take_damage(damage)
	if(!damage)
		return FALSE
	health = max(0, health - damage)

	if(health == 0)
		visible_message(loc, SPAN_DANGER("[src] shatters!"))
		deconstruct(FALSE)
		return TRUE

	return FALSE

/obj/structure/xenoautopsy/tank/bullet_act(obj/projectile/Proj)
	bullet_ping(Proj)
	if(Proj.ammo.damage)
		take_damage(floor(Proj.ammo.damage / 2))
		if(Proj.ammo.damage_type == BRUTE)
			playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)
	return TRUE

/obj/structure/xenoautopsy/tank/attack_alien(mob/living/carbon/xenomorph/user)
	. = ..()
	user.animation_attack_on(src)
	playsound(src, 'sound/effects/Glasshit.ogg', 25, 1)
	take_damage(25)
	return XENO_ATTACK_ACTION


/obj/structure/xenoautopsy/tank/ex_act(severity)
	switch(severity)
		if(0 to EXPLOSION_THRESHOLD_LOW)
			if (prob(25))
				deconstruct(FALSE)
				return
		if(EXPLOSION_THRESHOLD_LOW to EXPLOSION_THRESHOLD_MEDIUM)
			if (prob(50))
				deconstruct(FALSE)
				return
		if(EXPLOSION_THRESHOLD_MEDIUM to INFINITY)
			deconstruct(FALSE)

/obj/structure/xenoautopsy/tank/Destroy()
	occupant = null
	return ..()

/obj/structure/xenoautopsy/tank/broken
	name = "cryo tank"
	desc = "Something broke it..."
	icon_state = "tank_broken"
	broken_state = null

/obj/structure/xenoautopsy/tank/alien
	name = "cryo tank"
	desc = "There is something big inside..."
	icon_state = "tank_alien"
	occupant = /obj/item/alien_embryo

/obj/structure/xenoautopsy/tank/hugger
	name = "cryo tank"
	desc = "There is something spider-like inside..."
	icon_state = "tank_hugger"
	occupant = /obj/item/clothing/mask/facehugger

/obj/structure/xenoautopsy/tank/hugger/yautja
	desc = "There's something floating in the tank, perhaps it's kept for someones mere amusement..."
	icon = 'icons/obj/structures/machinery/yautja_machines.dmi'
	broken_state = /obj/structure/xenoautopsy/tank/broken/yautja

/obj/structure/xenoautopsy/tank/broken/yautja
	icon = 'icons/obj/structures/machinery/yautja_machines.dmi'

/obj/structure/xenoautopsy/tank/larva
	name = "cryo tank"
	desc = "There is something worm-like inside..."
	icon_state = "tank_larva"
	occupant = /obj/item/alien_embryo
	broken_state = /obj/structure/xenoautopsy/tank/broken

/obj/item/alienjar
	name = "sample jar"
	desc = "Used to store organic samples inside for preservation."
	icon = 'icons/obj/structures/props/alien_autopsy.dmi'
	icon_state = "jar_sample"
	desc = "Used to store organic samples inside for preservation. You aren't sure what's inside."
	var/list/overlay_options = list(
		"sample_egg",
		"sample_larva",
		"sample_hugger",
		"sample_runner_tail",
		"sample_runner",
		"sample_runner_head",
		"sample_drone_tail",
		"sample_drone",
		"sample_drone_head",
		"sample_sentinel_tail",
		"sample_sentinel",
		"sample_sentinel_head",
	)

/obj/item/alienjar/ovi
	desc = "Used to store organic samples inside for preservation. Looks like maybe an egg?"
	overlay_options = list(
		"sample_egg",
		"sample_larva",
		"sample_hugger",
	)

/obj/item/alienjar/runner
	desc = "Used to store organic samples inside for preservation. Looks like its part of a red one."
	overlay_options = list(
		"sample_runner_tail",
		"sample_runner",
		"sample_runner_head",
	)

/obj/item/alienjar/drone
	desc = "Used to store organic samples inside for preservation. Looks like a common part."
	overlay_options = list(
		"sample_drone_tail",
		"sample_drone",
		"sample_drone_head",
	)

/obj/item/alienjar/sentinel
	desc = "Used to store organic samples inside for preservation. Looks like its part of a red one."
	overlay_options = list(
		"sample_sentinel_tail",
		"sample_sentinel",
		"sample_sentinel_head",
	)

/obj/item/alienjar/Initialize(mapload, ...)
	. = ..()

	underlays += image('icons/obj/structures/props/alien_autopsy.dmi', pick(overlay_options))
	pixel_x += rand(-3,3)
	pixel_y += rand(-3,3)


//stairs

/obj/structure/stairs
	name = "Stairs"
	desc = "Stairs.  You walk up and down them."
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "rampbottom"
	gender = PLURAL
	unslashable = TRUE
	unacidable = TRUE
	health = null
	layer = ABOVE_TURF_LAYER//Being on turf layer was causing issues with cameras. This SHOULDN'T cause any problems.
	plane = FLOOR_PLANE
	density = FALSE
	opacity = FALSE

/obj/structure/stairs/multiz
	var/direction
	layer = OBJ_LAYER // Cannot be obstructed by weeds
	var/list/blockers = list()

/obj/structure/stairs/multiz/Initialize(mapload, ...)
	. = ..()
	RegisterSignal(loc, COMSIG_TURF_ENTERED, PROC_REF(on_turf_entered))
	for(var/turf/blocked_turf in range(1, src))
		blockers += new /obj/effect/build_blocker(blocked_turf, src)
		new /obj/structure/blocker/anti_cade(blocked_turf)

/obj/structure/stairs/multiz/Destroy()
	QDEL_LIST(blockers)

	. = ..()

/obj/structure/stairs/multiz/proc/on_turf_entered(turf/source, atom/movable/enterer)
	if(!istype(enterer, /mob))
		return

	RegisterSignal(enterer, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_premove))
	RegisterSignal(enterer, COMSIG_MOVABLE_MOVED, PROC_REF(on_leave))

/obj/structure/stairs/multiz/proc/on_leave(atom/movable/mover, atom/oldloc, newDir)
	SIGNAL_HANDLER
	if(mover.loc == loc)
		return
	UnregisterSignal(mover, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))

/obj/structure/stairs/multiz/proc/on_premove(atom/movable/mover, atom/newLoc)
	SIGNAL_HANDLER

	if(direction == UP && get_dir(src, newLoc) != dir || direction == DOWN && get_dir(src, newLoc) != REVERSE_DIR(dir))
		return

	var/turf/target_turf = get_step(src, direction == UP ? dir : REVERSE_DIR(dir))
	var/turf/actual_turf
	if(direction == UP)
		actual_turf = SSmapping.get_turf_above(target_turf)
	else
		actual_turf = SSmapping.get_turf_below(target_turf)

	if(actual_turf)
		if(istype(mover, /mob))
			var/mob/mover_mob = mover
			mover_mob.trainteleport(actual_turf)
		else
			mover.forceMove(actual_turf)
		if(!(mover.flags_atom & DIRLOCK))
			mover.setDir(direction == UP ? dir : REVERSE_DIR(dir))

	return COMPONENT_CANCEL_MOVE

/obj/structure/stairs/multiz/up
	direction = UP

/obj/structure/stairs/multiz/down
	direction = DOWN

/obj/structure/stairs/perspective //instance these for the required icons
	icon = 'icons/obj/structures/stairs/perspective_stairs.dmi'
	icon_state = "np_stair"

/obj/structure/stairs/perspective/kutjevo
	icon = 'icons/obj/structures/stairs/perspective_stairs_kutjevo.dmi'

/obj/structure/stairs/perspective/ice
	icon = 'icons/obj/structures/stairs/perspective_stairs_ice.dmi'


// Prop
/obj/structure/ore_box
	name = "ore box"
	desc = "A heavy box used for storing ore."
	icon = 'icons/obj/structures/props/mining.dmi'
	icon_state = "orebox0"
	density = TRUE
	anchored = FALSE

/obj/structure/ore_box/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if (PF)
		PF.flags_can_pass_all = PASS_HIGH_OVER_ONLY|PASS_OVER_THROW_ITEM


/obj/structure/ore_box/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(xeno.a_intent == INTENT_HARM)
		if(unslashable)
			return
		xeno.animation_attack_on(src)
		xeno.visible_message(SPAN_DANGER("[xeno] slices [src] apart!"))
		playsound(src, 'sound/effects/woodhit.ogg')
		to_chat(xeno, SPAN_WARNING("We slice the [src] apart!"))
		deconstruct(FALSE)
		return XENO_ATTACK_ACTION
	else
		attack_hand(xeno)
		return XENO_NONCOMBAT_ACTION


/obj/structure/computer3frame
	density = TRUE
	anchored = FALSE
	name = "computer frame"
	icon = 'icons/obj/structures/machinery/stock_parts.dmi'
	icon_state = "0"
	var/state = 0

/obj/structure/computer3frame/server
	name = "server frame"

/obj/structure/computer3frame/wallcomp
	name = "wall-computer frame"

/obj/structure/computer3frame/laptop
	name = "laptop frame"

// Dartboard
#define DOUBLE_BAND 2
#define TRIPLE_BAND 3

/obj/structure/dartboard
	name = "dartboard"
	desc = "A dartboard, loosely secured."
	icon = 'icons/obj/structures/props/props.dmi'
	icon_state = "dart_board"
	density = TRUE
	unslashable = TRUE

/obj/structure/dartboard/get_examine_text()
	. = ..()
	if(length(contents))
		var/is_are = "is"
		if(length(contents) != 1)
			is_are = "are"

		. += SPAN_NOTICE("There [is_are] [length(contents)] item\s embedded into [src].")

/obj/structure/dartboard/initialize_pass_flags(datum/pass_flags_container/pass_flags)
	..()
	if(pass_flags)
		pass_flags.flags_can_pass_all = PASS_MOB_IS

/obj/structure/dartboard/get_projectile_hit_boolean(obj/projectile/projectile)
	. = ..()
	visible_message(SPAN_DANGER("[projectile] hits [src], collapsing it!"))
	collapse()

/obj/structure/dartboard/proc/flush_contents()
	for(var/atom/movable/embedded_items as anything in contents)
		embedded_items.forceMove(loc)

/obj/structure/dartboard/proc/collapse()
	playsound(src, 'sound/effects/thud1.ogg', 50)
	new /obj/item/dartboard/(loc)
	qdel(src)

/obj/structure/dartboard/attack_hand(mob/user)
	if(length(contents))
		user.visible_message(SPAN_NOTICE("[user] starts recovering items from [src]..."), SPAN_NOTICE("You start recovering items from [src]..."))
		if(do_after(user, 1 SECONDS, INTERRUPT_ALL, BUSY_ICON_FRIENDLY, user, INTERRUPT_MOVED, BUSY_ICON_GENERIC))
			flush_contents()
	else
		to_chat(user, SPAN_WARNING("[src] has nothing embedded!"))

/obj/structure/dartboard/Destroy()
	flush_contents()
	.  = ..()

/obj/structure/dartboard/hitby(obj/item/thrown_item)
	if(thrown_item.sharp != IS_SHARP_ITEM_ACCURATE && !istype(thrown_item, /obj/item/weapon/dart))
		visible_message(SPAN_DANGER("[thrown_item] hits [src], collapsing it!"))
		collapse()
		return

	contents += thrown_item
	playsound(src, 'sound/weapons/tablehit1.ogg', 50)
	var/score = rand(1,21)
	if(score == 21)
		visible_message(SPAN_DANGER("[thrown_item] embeds into [src], striking the bullseye! 50 points."))
		return

	var/band = "single"
	var/band_number = rand(1,3)
	score *= band_number
	switch(band_number)
		if(DOUBLE_BAND)
			band = "double"
		if(TRIPLE_BAND)
			band = "triple"
	visible_message(SPAN_DANGER("[thrown_item] embeds into [src], striking [band] for [score] point\s."))

/obj/structure/dartboard/attackby(obj/item/item, mob/user)
	user.visible_message(SPAN_DANGER("[user] hits [src] with [item], collapsing it!"), SPAN_DANGER("You collapse [src] with [item]!"))
	collapse()

/obj/structure/dartboard/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object != usr || !Adjacent(usr))
		return

	if(!ishuman(usr))
		return

	visible_message(SPAN_NOTICE("[usr] unsecures [src]."))
	var/obj/item/dartboard/unsecured_board = new(loc)
	usr.put_in_hands(unsecured_board)
	qdel(src)

/obj/item/dartboard
	name = "dartboard"
	desc = "A dartboard for darts."
	icon = 'icons/obj/structures/props/props.dmi'
	icon_state = "dart_board"

/obj/item/dartboard/attack_self(mob/user)
	. = ..()

	var/turf_ahead = get_step(user, user.dir)
	if(!istype(turf_ahead, /turf/closed))
		to_chat(user, SPAN_WARNING("[src] needs a wall to be secured to!"))
		return

	var/obj/structure/dartboard/secured_board = new(user.loc)
	switch(user.dir)
		if(NORTH)
			secured_board.pixel_y = 32
		if(EAST)
			secured_board.pixel_x = 32
		if(SOUTH)
			secured_board.pixel_y = -32
		if(WEST)
			secured_board.pixel_x = -32

	to_chat(user, SPAN_NOTICE("You secure [secured_board] to [turf_ahead]."))
	qdel(src)

#undef DOUBLE_BAND
#undef TRIPLE_BAND
#undef PRACTICE_LEVEL_LOW
#undef PRACTICE_LEVEL_MEDIUM_LOW
#undef PRACTICE_LEVEL_MEDIUM
#undef PRACTICE_LEVEL_HIGH
#undef PRACTICE_LEVEL_VERY_HIGH
#undef PRACTICE_LEVEL_EXTREMELY_HIGH
