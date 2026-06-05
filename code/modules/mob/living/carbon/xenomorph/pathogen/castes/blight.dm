/datum/caste_datum/pathogen/blight
	caste_type = PATHOGEN_CREATURE_BLIGHT
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_4
	melee_damage_upper = XENO_DAMAGE_TIER_4
	melee_vehicle_damage = XENO_DAMAGE_TIER_4
	max_health = XENO_HEALTH_TIER_10
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_ARMOR_TIER_1
	evasion = XENO_EVASION_LOW
	speed = XENO_SPEED_TIER_9

	attack_delay = 1.7

	available_strains = list()
	behavior_delegate_type = /datum/behavior_delegate/pathogen_base/blight

	deevolves_to = list(PATHOGEN_CREATURE_SPRINTER)
	caste_desc = "A fast, powerful combatant."
	evolves_to = list(PATHOGEN_CREATURE_VENATOR, PATHOGEN_CREATURE_HARBINGER)

	heal_resting = 1.5

	minimap_icon = "blight"

/mob/living/carbon/xenomorph/blight
	caste_type = PATHOGEN_CREATURE_BLIGHT
	name = PATHOGEN_CREATURE_BLIGHT
	desc = "A sleek and stealthy hunter, always watching."
	icon_size = 48
	icon_state = "Blight Walking"
	plasma_types = list()
	pixel_x = -12
	old_x = -12
	tier = 2
	organ_value = 5000
	base_actions = list(
		/datum/action/xeno_action/onclick/toggle_seethrough,
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab,
		/datum/action/xeno_action/activable/pounce/lurker, // Macro 1
		/datum/action/xeno_action/onclick/lurker_invisibility, // Macro 2
		/datum/action/xeno_action/onclick/paralyzing_slash/blight_slash, //Macro 5
	)
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
	claw_type = CLAW_TYPE_SHARP

	tackle_min = 2
	tackle_max = 6

	icon_xeno = 'icons/mob/pathogen/blight.dmi'
	icon_xenonid = 'icons/mob/pathogen/blight.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	mycelium_food_icon = 'icons/mob/pathogen/pathogen_weeds_48x48.dmi'
	weed_food_states = list("Blight_1","Blight_2","Blight_3")
	weed_food_states_flipped = list("Blight_1","Blight_2","Blight_3")

	AUTOWIKI_SKIP(TRUE)
	hivenumber = XENO_HIVE_PATHOGEN
	speaking_noise = "pathogen_talk"
	acid_blood_damage = 0
	bubble_icon = "pathogen"
	fire_immunity = FIRE_VULNERABILITY

/datum/behavior_delegate/pathogen_base/blight
	name = "Base Blight Behavior Delegate"

/datum/behavior_delegate/pathogen_base/blight/melee_attack_additional_effects_self()
	..()

	var/datum/action/xeno_action/onclick/lurker_invisibility/lurker_invis_action = get_action(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
	if (lurker_invis_action)
		lurker_invis_action.invisibility_off() // Full cooldown

/datum/behavior_delegate/pathogen_base/blight/append_to_stat()
	. = list()

	// Invisible
	var/datum/action/xeno_action/onclick/lurker_invisibility/lurker_inv = get_action(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
	if(lurker_inv.invis_start_time != -1)
		var/time_left = (lurker_inv.invis_duration-(world.time - lurker_inv.invis_start_time)) / 10
		. += "Invisibility Remaining: [time_left] second\s."
		return

	var/datum/action/xeno_action/onclick/lurker_invisibility/lurker_invisibility_action = get_action(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
	if(!lurker_invisibility_action)
		return

	if(!bound_xeno.client?.prefs.show_cooldown_messages)
		return

	// Recharged
	if(lurker_invisibility_action.cooldown_timer_id == TIMER_ID_NULL)
		. += "Invisibility Recharge: Ready."
		return

	// Recharging
	var/time_left = timeleft(lurker_invisibility_action.cooldown_timer_id) / 10
	. += "Invisibility Recharge: [time_left] second\s."

	var/datum/hive_status/pathogen/hive = GLOB.hive_datum[XENO_HIVE_PATHOGEN]
	if(hive)
		. += "Pathogen Poppers: [hive.get_popper_num()]/[hive.max_poppers]"

/datum/behavior_delegate/pathogen_base/blight/on_collide(atom/movable/movable_atom)
	. = ..()

	if(!ishuman(movable_atom))
		return

	if(!bound_xeno || !bound_xeno.stealth)
		return

	var/datum/action/xeno_action/onclick/lurker_invisibility/lurker_invisibility_action = get_action(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
	if(!lurker_invisibility_action)
		return

	var/mob/living/carbon/human/bumped_into = movable_atom
	if(HAS_TRAIT(bumped_into, TRAIT_CLOAKED)) //ignore invisible scouts and preds
		return

	to_chat(bound_xeno, SPAN_XENOHIGHDANGER("We bumped into someone and lost our invisibility!"))
	lurker_invisibility_action.invisibility_off(0.5) // partial refund of remaining time
