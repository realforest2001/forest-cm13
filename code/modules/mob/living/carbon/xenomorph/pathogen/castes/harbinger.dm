/// The minimum number of people to hit on the first spin to trigger the extra spins.
#define PATHOGEN_CYCLONE_MIN_HITS 2

/datum/caste_datum/pathogen/harbinger
	caste_type = PATHOGEN_CREATURE_HARBINGER
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_6 //Stats TBC
	melee_damage_upper = XENO_DAMAGE_TIER_7
	melee_vehicle_damage = XENO_DAMAGE_TIER_7
	max_health = XENO_HEALTH_TIER_12
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_8
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_4
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_LOW
	speed = XENO_SPEED_TIER_5

	attack_delay = 0

	available_strains = list()
	behavior_delegate_type = /datum/behavior_delegate/pathogen_base/harbinger

	deevolves_to = list(PATHOGEN_CREATURE_BLIGHT)
	caste_desc = "Death is no sanctuary."
	evolves_to = list()

	heal_resting = 1.6
	is_intelligent = TRUE

	minimap_icon = "harbinger"
	evolution_allowed = FALSE
	royal_caste = TRUE

/mob/living/carbon/xenomorph/harbinger
	caste_type = PATHOGEN_CREATURE_HARBINGER
	name = PATHOGEN_CREATURE_HARBINGER
	desc = "Doom is walking."
	icon_size = 48
	icon_state = "Harbinger Walking"
	plasma_types = list()
	pixel_x = -16
	old_x = -16
	tier = 3
	organ_value = 8000
	base_actions = list(
		/datum/action/xeno_action/onclick/toggle_seethrough,
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab/pathogen_t3,
		/datum/action/xeno_action/activable/pounce/charge, // Macro 1
		/datum/action/xeno_action/activable/prae_impale/venator, //Macro 2
		/datum/action/xeno_action/activable/cyclone, // Macro 3
		/datum/action/xeno_action/activable/tail_stab/mycotoxin, // Macro 4
		/datum/action/xeno_action/onclick/paralyzing_slash/blight_slash, //Macro 5
	)
	claw_type = CLAW_TYPE_VERY_SHARP

	tackle_min = 2
	tackle_max = 5
	tackle_chance = 45

	icon_xeno = 'icons/mob/pathogen/harbinger.dmi'
	icon_xenonid = 'icons/mob/pathogen/harbinger.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	mycelium_food_icon = 'icons/mob/pathogen/pathogen_weeds_48x48.dmi'
	weed_food_states = list("Harbinger_1","Harbinger_2","Harbinger_3")
	weed_food_states_flipped = list("Harbinger_1","Harbinger_2","Harbinger_3")

	AUTOWIKI_SKIP(TRUE)
	hivenumber = XENO_HIVE_PATHOGEN
	speaking_noise = "pathogen_talk"

	mob_size = MOB_SIZE_BIG
	acid_blood_damage = 0
	bubble_icon = "pathogenroyal"
	fire_immunity = FIRE_VULNERABILITY



/datum/behavior_delegate/pathogen_base/harbinger
	name = "Base Harbinger Behavior Delegate"





/datum/action/xeno_action/activable/cyclone
	name = "Cyclone"
	action_icon_state = "spin_slash"
	macro_path = /datum/action/xeno_action/verb/verb_cyclone
	action_type = XENO_ACTION_ACTIVATE
	ability_primacy = XENO_PRIMARY_ACTION_3
	plasma_cost = 0
	xeno_cooldown = 23 SECONDS

	// Config values
	var/activation_delay = 2 SECONDS

	var/armor_pen = 20
	var/base_damage = 25
	var/base_range = 2
	var/cycles = 4
	var/cycle_damage = 15
	var/cycle_delay = 3 SECONDS
	/// Less than the delay between cycles, the longer one stands spinning the less safe it is.
	var/cycle_shield_duration = 2 SECONDS
	var/cycle_shield_value = 50

/datum/action/xeno_action/activable/cyclone/use_ability(atom/affected_atom)
	var/mob/living/carbon/xenomorph/xeno = owner
	var/range = base_range

	if(xeno.action_busy)
		return

	XENO_ACTION_CHECK(xeno)

	apply_cooldown()

	// To-Do, change message.
	xeno.visible_message(SPAN_XENOHIGHDANGER("[xeno] begins digging in for a massive strike!"), SPAN_XENOHIGHDANGER("We begin digging in for a massive strike!"))

	ADD_TRAIT(xeno, TRAIT_IMMOBILIZED, TRAIT_SOURCE_ABILITY("Cyclone"))
	xeno.anchored = TRUE

	var/found_target = 0
	if(do_after(xeno, activation_delay, INTERRUPT_ALL | BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
		xeno.emote("roar")
		xeno.spin_circle()

		for(var/mob/living/carbon/targets_to_hit in orange(xeno, base_range))
			if(!isxeno_human(targets_to_hit) || xeno.can_not_harm(targets_to_hit))
				continue

			if(targets_to_hit.stat == DEAD)
				continue

			if(HAS_TRAIT(targets_to_hit, TRAIT_NESTED))
				continue

			if(!check_clear_path_to_target(xeno, targets_to_hit))
				continue

			found_target++
			xeno.visible_message(SPAN_XENODANGER("[xeno] stabs [targets_to_hit]!"), SPAN_XENODANGER("We stab [targets_to_hit]!"))
			targets_to_hit.apply_effect(get_xeno_stun_duration(targets_to_hit, 1), WEAKEN)
			playsound(get_turf(targets_to_hit), 'sound/weapons/alien_tail_attack.ogg', 30, TRUE)

			targets_to_hit.apply_armoured_damage(get_xeno_damage_slash(targets_to_hit, base_damage), ARMOR_MELEE, BRUTE, "chest", armor_pen)


	if(found_target < PATHOGEN_CYCLONE_MIN_HITS)
		REMOVE_TRAIT(xeno, TRAIT_IMMOBILIZED, TRAIT_SOURCE_ABILITY("Cyclone"))
		xeno.anchored = FALSE
		return..()

	var/total_shield_value = cycle_shield_value * cycles
	var/total_shield_duration = (cycle_shield_duration * cycles) - min(0.5 SECONDS * cycles, 2 SECONDS)
	xeno.add_xeno_shield(total_shield_value, XENO_SHIELD_SOURCE_CYCLONE, /datum/xeno_shield/harbinger)
	xeno.overlay_shields()
	addtimer(CALLBACK(src, PROC_REF(remove_shield)), total_shield_duration)

	REMOVE_TRAIT(xeno, TRAIT_IMMOBILIZED, TRAIT_SOURCE_ABILITY("Cyclone"))
	xeno.anchored = FALSE

	var/current_cycle = 0
	while(current_cycle < cycles)
		var/cycle_delay_modifier = 0.5 SECONDS * current_cycle
		current_cycle++

		var/current_cycle_delay = max(1.5 SECONDS, cycle_delay - cycle_delay_modifier)
		if(!do_after(xeno, current_cycle_delay, INTERRUPT_INCAPACITATED, BUSY_ICON_HOSTILE))
			break

		xeno.spin_circle(6)
		xeno.emote("growl")

		var/cycle_range = min(range, 4)
		for(var/mob/living/carbon/targets_to_hit in orange(xeno, cycle_range))
			if(!isxeno_human(targets_to_hit) || xeno.can_not_harm(targets_to_hit))
				continue

			if(targets_to_hit.stat == DEAD)
				continue

			if(HAS_TRAIT(targets_to_hit, TRAIT_NESTED))
				continue

			if(!check_clear_path_to_target(xeno, targets_to_hit))
				continue

			xeno.visible_message(SPAN_XENODANGER("[xeno] lashes out at [targets_to_hit]!"), SPAN_XENODANGER("We lash out at [targets_to_hit]!"))
			targets_to_hit.apply_effect(get_xeno_stun_duration(targets_to_hit, 1), SLOW)
			playsound(get_turf(targets_to_hit), "alien_claw_flesh", 30, 1)

			targets_to_hit.apply_armoured_damage(get_xeno_damage_slash(targets_to_hit, cycle_damage), ARMOR_MELEE, BRUTE, "chest", armor_pen / 2)
		range++

	return ..()



/datum/action/xeno_action/activable/cyclone/proc/remove_shield()
	var/mob/living/carbon/xenomorph/xeno = owner
	if (!istype(xeno))
		return

	var/datum/xeno_shield/found
	for(var/datum/xeno_shield/shield in xeno.xeno_shields)
		if(shield.shield_source == XENO_SHIELD_SOURCE_CYCLONE)
			found = shield
			break

	if(istype(found))
		found.on_removal()
		qdel(found)
		to_chat(xeno, SPAN_XENOHIGHDANGER("We feel our shield end!"))
		button.icon_state = "template_xeno"

	xeno.overlay_shields()

/datum/action/xeno_action/verb/verb_cyclone()
	set category = "Alien"
	set name = "Cyclone"
	set hidden = TRUE
	var/action_name = "Cyclone"
	handle_xeno_macro(src, action_name)


/datum/action/xeno_action/activable/tail_stab/mycotoxin
	name = "Mycotoxin Injection (100)"
	action_icon_state = "mycotoxin"
	charge_time = 2 SECONDS
	xeno_cooldown = 3 MINUTES
	ability_primacy = XENO_PRIMARY_ACTION_4
	plasma_cost = 100

/datum/action/xeno_action/activable/tail_stab/mycotoxin/matriarch
	name = "Mycotoxin Injection (150)"
	plasma_cost = 150
	matriarch_stab = TRUE
	xeno_cooldown = 5 MINUTES
	stab_range = 3
	ability_primacy = XENO_NOT_PRIMARY_ACTION

/datum/action/xeno_action/activable/tail_stab/mycotoxin/use_ability()
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_player = owner
	ADD_TRAIT(xeno_player, TRAIT_ABILITY_TAILSTAB_MYCOTOXIN, TRAIT_SOURCE_ABILITY("tailstab_mycotoxin"))
