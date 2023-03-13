/datum/action/xeno_action/activable/acid_lance/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner

	if (!istype(xeno_owner) || !xeno_owner.check_state())
		return

	if (!activated_once && !action_cooldown_check())
		return

	if(!target || target.layer >= FLY_LAYER || !isturf(xeno_owner.loc))
		return

	if (!activated_once)
		// Start our 'charging'
		if (!check_and_use_plasma_owner())
			return

		xeno_owner.create_empower()
		xeno_owner.visible_message(SPAN_XENODANGER("[xeno_owner] starts to gather its acid for a massive blast!"), SPAN_XENODANGER("You start to gather your acid for a massive blast!"))
		activated_once = TRUE
		stack()
		addtimer(CALLBACK(src, PROC_REF(timeout)), max_stacks*stack_time + time_after_max_before_end)
		apply_cooldown()
		return ..()

	else
		activated_once = FALSE
		var/range = base_range + stacks*range_per_stack
		var/damage = base_damage + stacks*damage_per_stack
		var/turfs_visited = 0
		for (var/turf/T in getline2(get_turf(xeno_owner), target))
			if(T.density || T.opacity)
				break

			var/should_stop = FALSE
			for(var/obj/structure/S in T)
				if(istype(S, /obj/structure/window/framed))
					var/obj/structure/window/framed/window_hit = S
					if(!window_hit.unslashable)
						window_hit.deconstruct(disassembled = FALSE)

				if(S.opacity)
					should_stop = TRUE
					break

			if (should_stop)
				break

			if (turfs_visited >= range)
				break

			turfs_visited++

			new /obj/effect/xenomorph/acid_damage_delay(T, damage, 7, FALSE, "You are blasted with a stream of high-velocity acid!", xeno_owner)

		xeno_owner.visible_message(SPAN_XENODANGER("[xeno_owner] fires a massive blast of acid at [target]!"), SPAN_XENODANGER("You fire a massive blast of acid at [target]!"))
		remove_stack_effects("You feel your speed return to normal!")

/datum/action/xeno_action/activable/acid_lance/proc/stack()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if (!istype(xeno_owner))
		return

	if (!activated_once)
		return

	stacks = min(max_stacks, stacks + 1)
	if (stacks != max_stacks)
		xeno_owner.speed_modifier += movespeed_per_stack
		movespeed_nerf_applied += movespeed_per_stack
		xeno_owner.recalculate_speed()
		addtimer(CALLBACK(src, PROC_REF(stack)), stack_time)
		return
	else
		to_chat(xeno_owner, SPAN_XENOHIGHDANGER("You have charged your acid lance to maximum!"))
		return

/datum/action/xeno_action/activable/acid_lance/proc/remove_stack_effects(message = null)
	var/mob/living/carbon/xenomorph/xeno_owner = owner

	if (!istype(xeno_owner))
		return

	if (stacks <= 0)
		return

	if (message)
		to_chat(xeno_owner, SPAN_XENODANGER(message))

	stacks = 0
	xeno_owner.speed_modifier -= movespeed_nerf_applied
	movespeed_nerf_applied = 0
	xeno_owner.recalculate_speed()

/datum/action/xeno_action/activable/acid_lance/proc/timeout()
	if (activated_once)
		activated_once = FALSE
		remove_stack_effects("You have waited too long and can no longer use your acid lance!")


/datum/action/xeno_action/activable/acid_lance/action_cooldown_check()
	return (activated_once || ..())

/datum/action/xeno_action/activable/xeno_spit/bombard/use_ability(atom/A)
	..()
	var/mob/living/carbon/xenomorph/xeno = owner
	if(!action_cooldown_check()) // activate c/d only if we already spit
		for (var/action_type in action_types_to_cd)
			var/datum/action/xeno_action/xeno_action = get_xeno_action_by_type(xeno, action_type)
			if (!istype(xeno_action))
				continue

			xeno_action.apply_cooldown_override(cooldown_duration)

/datum/action/xeno_action/onclick/acid_shroud/use_ability(atom/atom)
	var/datum/effect_system/smoke_spread/xeno_acid/spicy_gas
	var/mob/living/carbon/xenomorph/xeno = owner
	if (!isxeno(owner))
		return

	if (!action_cooldown_check())
		return

/*
var/mob/living/carbon/xenomorph/xeno_owner = owner

	if (!xeno_owner.check_state())
		return

	RegisterSignal(xeno_owner, COMSIG_MOB_MOVE_OR_LOOK, PROC_REF(handle_mob_move_or_look))
	addtimer(CALLBACK(src, PROC_REF(remove_speed_buff)), buffs_duration)
	xeno_owner.speed_modifier -= speed_buff_amount
	movespeed_buff_applied = TRUE
	xeno_owner.recalculate_speed()

	to_chat(xeno_owner, SPAN_XENOHIGHDANGER("You dump your acid, disabling your offensive abilities to escape!"))

	for (var/action_type in action_types_to_cd)
		var/datum/action/xeno_action/XA = get_xeno_action_by_type(xeno_owner, action_type)
		if (!istype(XA))
*/

	if (!xeno.check_state())
		return
	if(sound_play)
		playsound(xeno,"acid_strike", 35, 1)
		sound_play = FALSE
		addtimer(VARSET_CALLBACK(src, sound_play, TRUE), 2 SECONDS)
	if (!do_after(xeno, xeno.ammo.spit_windup/6.5, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE, numticks = 2)) /// 0.7 seconds
		to_chat(xeno, SPAN_XENODANGER("You decide to cancel your gas shroud."))
		return
	playsound(xeno,"acid_sizzle", 50, 1)
	if(xeno.ammo == GLOB.ammo_list[/datum/ammo/xeno/boiler_gas/acid])
		spicy_gas = new /datum/effect_system/smoke_spread/xeno_acid
	else if(xeno.ammo == GLOB.ammo_list[/datum/ammo/xeno/boiler_gas])
		spicy_gas = new /datum/effect_system/smoke_spread/xeno_weaken
	else
		CRASH("Globber has unknown ammo [xeno.ammo]! Oh no!")
	spicy_gas.set_up(1, 0, get_turf(xeno), null, 6)
	spicy_gas.start()
	to_chat(xeno, SPAN_XENOHIGHDANGER("You dump your acid through your pores, creating a shroud of gas!"))
	for (var/action_type in action_types_to_cd)
		var/datum/action/xeno_action/xeno_action = get_xeno_action_by_type(xeno, action_type)
		if (!istype(xeno_action))
			continue

		xeno_action.apply_cooldown_override(cooldown_duration)

	apply_cooldown()
	return

/datum/action/xeno_action/onclick/dump_acid/proc/remove_speed_buff()
	if (movespeed_buff_applied && isxeno(owner))
		var/mob/living/carbon/xenomorph/xeno = owner
		xeno.speed_modifier += speed_buff_amount
		xeno.recalculate_speed()
		movespeed_buff_applied = FALSE
		UnregisterSignal(owner, COMSIG_MOB_MOVE_OR_LOOK)

/datum/action/xeno_action/onclick/dump_acid/proc/handle_mob_move_or_look(mob/living/carbon/xenomorph/mover, actually_moving, direction, specific_direction)
	SIGNAL_HANDLER

	if(!actually_moving)
		return

	var/obj/effect/particle_effect/smoke/smoke_effect = new /obj/effect/particle_effect/smoke/xeno_burn(get_turf(mover), 1, create_cause_data(initial(mover.caste_type), mover))
	smoke_effect.time_to_live = 3
	smoke_effect.spread_speed = 1000000

/datum/action/xeno_action/onclick/dump_acid/remove_from()
	remove_speed_buff()
	..()

/datum/action/xeno_action/onclick/shift_spits/boiler/use_ability(atom/A)
	. = ..()
	apply_cooldown()

/////////////////////////////// Trapper boiler powers

/datum/action/xeno_action/activable/boiler_trap/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner

	if (!istype(xeno_owner))
		return

	if (!action_cooldown_check())
		return

	if (!xeno_owner.check_state())
		return

	if (!can_see(xeno_owner, target, TRAPPER_VIEWRANGE))
		to_chat(xeno_owner, SPAN_XENODANGER("You cannot see that location!"))
		return

	if (!check_and_use_plasma_owner())
		return

	// 5-long line of turfs orthogonal to the line between us and our target as precisely as we can figure it
	var/dir_between = Get_Compass_Dir(xeno_owner, target)
	var/list/target_turfs = list()
	var/target_turf = get_turf(target)
	var/left_turf = get_step(target_turf, turn(dir_between, -90))
	var/right_turf = get_step(target_turf, turn(dir_between, 90))
	target_turfs += target_turf
	target_turfs += left_turf
	target_turfs += right_turf
	target_turfs += get_step(left_turf, turn(dir_between, -90))
	target_turfs += get_step(right_turf, turn(dir_between, 90))


	for (var/turf/T in target_turfs)
		if (!istype(T) || T.density)
			continue

		var/trap_found = FALSE
		for (var/obj/effect/alien/resin/boilertrap/BT in T)
			trap_found = TRUE
			break

		if (trap_found)
			continue

		var/obj/effect/alien/resin/boilertrap/BT
		if(empowered)
			BT = new /obj/effect/alien/resin/boilertrap/empowered(T, xeno_owner)
		else
			BT = new /obj/effect/alien/resin/boilertrap/(T, xeno_owner)
		QDEL_IN(BT, trap_ttl)

	if(empowered)
		empowered = FALSE
		empowering_charge_counter = 0
		button.overlays -= "+empowered"
		var/datum/action/xeno_action/activable/acid_mine/mine = get_xeno_action_by_type(xeno_owner, /datum/action/xeno_action/activable/acid_mine)
		if(!mine.empowered)
			mine.empowered = TRUE
			mine.button.overlays += "+empowered"
			to_chat(xeno_owner, SPAN_XENODANGER("You tap in your reserves to prepare a stronger [mine.name]!"))

	apply_cooldown()
	..()
	return


/datum/action/xeno_action/activable/acid_mine/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner

	if (!istype(xeno_owner))
		return

	if (!xeno_owner.check_state())
		return

	if (!action_cooldown_check())
		return

	if(!target || target.layer >= FLY_LAYER || !isturf(xeno_owner.loc))
		return

	if(!check_clear_path_to_target(xeno_owner, target, TRUE, TRAPPER_VIEWRANGE))
		to_chat(xeno_owner, SPAN_XENOWARNING("Something is in the way!"))
		return

	if (!check_and_use_plasma_owner())
		return

	var/turf/T = get_turf(target)
	var/acid_bolt_message = "a bolt of acid"
	if(empowered)
		acid_bolt_message = "a powerful bolt of acid"

	xeno_owner.visible_message(SPAN_XENODANGER("[xeno_owner] fires " + acid_bolt_message + " at [target]!"), SPAN_XENODANGER("You fire " + acid_bolt_message + " at [target]!"))
	new /obj/effect/xenomorph/acid_damage_delay/boiler_landmine(T, damage, delay, empowered, "You are blasted with " + acid_bolt_message + "!", xeno_owner, )

	for (var/turf/targetTurf in orange(1, T))
		new /obj/effect/xenomorph/acid_damage_delay/boiler_landmine(targetTurf, damage, delay, empowered, "You are blasted with a " + acid_bolt_message + "!", xeno_owner)

	if(empowered)
		empowered = FALSE
		button.overlays -= "+empowered"

	apply_cooldown()
	..()
	return

/datum/action/xeno_action/activable/acid_shotgun/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if (!istype(xeno_owner))
		return

	if (!action_cooldown_check())
		return

	if(!target || target.layer >= FLY_LAYER || !isturf(xeno_owner.loc) || !xeno_owner.check_state())
		return

	xeno_owner.visible_message(SPAN_XENOWARNING("The [xeno_owner] fires a blast of acid at [target]!"), SPAN_XENOWARNING("You fire a blast of acid at [target]!"))

	var/turf/target_turf = locate(target.x, target.y, target.z)
	var/obj/item/projectile/acid_blast = new /obj/item/projectile(xeno_owner.loc, create_cause_data(initial(xeno_owner.caste_type), xeno_owner))

	var/datum/ammo/blast_datum = new ammo_type()

	acid_blast.generate_bullet(blast_datum)

	acid_blast.fire_at(target_turf, xeno_owner, xeno_owner, blast_datum.max_range, blast_datum.shell_speed)

	apply_cooldown()
	..()
	return

/datum/action/xeno_action/activable/tail_stab/boiler/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/stabbing_xeno = owner
	var/target = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		if(stabbing_xeno.ammo == GLOB.ammo_list[/datum/ammo/xeno/boiler_gas/acid])
			carbon_target.reagents.add_reagent("molecularacid", 6)
		else if(stabbing_xeno.ammo == GLOB.ammo_list[/datum/ammo/xeno/boiler_gas])
			var/datum/effects/neurotoxin/neuro_effect = locate() in carbon_target.effects_list
			if(!neuro_effect)
				neuro_effect = new /datum/effects/neurotoxin(carbon_target)
			neuro_effect.duration += 16
			to_chat(carbon_target,SPAN_HIGHDANGER("You are injected with something from [stabbing_xeno]'s tailstab!"))
		else
			CRASH("Globber has unknown ammo [stabbing_xeno.ammo]! Oh no!")
