/datum/caste_datum/pathogen/venator
	caste_type = PATHOGEN_CREATURE_VENATOR
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
	behavior_delegate_type = /datum/behavior_delegate/pathogen_base/venator

	deevolves_to = list(PATHOGEN_CREATURE_BLIGHT)
	caste_desc = "Rage, rage, and rage some more."
	evolves_to = list()

	heal_resting = 1.6
	is_intelligent = TRUE

	minimap_icon = "venator"
	evolution_allowed = FALSE
	royal_caste = TRUE

/mob/living/carbon/xenomorph/venator
	caste_type = PATHOGEN_CREATURE_VENATOR
	name = PATHOGEN_CREATURE_VENATOR
	desc = "A wandering ball of death."
	icon_size = 48
	icon_state = "Venator Walking"
	plasma_types = list()
	pixel_x = -8
	old_x = -8
	tier = 3
	organ_value = 8000
	base_actions = list(
		/datum/action/xeno_action/onclick/toggle_seethrough,
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab/pathogen_t3,
		/datum/action/xeno_action/activable/prae_abduct/venator, // Macro 1
		/datum/action/xeno_action/activable/prae_impale/venator, //Macro 2
		/datum/action/xeno_action/activable/scissor_cut/venator, // Macro 3
		//, // Macro 4
		/datum/action/xeno_action/onclick/paralyzing_slash/blight_slash, //Macro 5
	)
	claw_type = CLAW_TYPE_VERY_SHARP

	tackle_min = 2
	tackle_max = 5
	tackle_chance = 45

	icon_xeno = 'icons/mob/pathogen/venator.dmi'
	icon_xenonid = 'icons/mob/pathogen/venator.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	mycelium_food_icon = 'icons/mob/pathogen/pathogen_weeds_48x48.dmi'
	weed_food_states = list("Venator_1","Venator_2","Venator_3")
	weed_food_states_flipped = list("Venator_1","Venator_2","Venator_3")

	AUTOWIKI_SKIP(TRUE)
	hivenumber = XENO_HIVE_PATHOGEN
	speaking_noise = "pathogen_talk"

	mob_size = MOB_SIZE_BIG
	acid_blood_damage = 0
	bubble_icon = "pathogenroyal"
	fire_immunity = FIRE_VULNERABILITY

/datum/action/xeno_action/activable/tail_stab/pathogen_t3
	name = "Spike Lash"
	stab_range = 3

/datum/action/xeno_action/activable/prae_abduct/venator
	name = "Tentacle Grab"

/datum/action/xeno_action/activable/scissor_cut/venator
	name = "Savage"

/datum/action/xeno_action/activable/prae_impale/venator
	ability_primacy = XENO_PRIMARY_ACTION_2


/datum/behavior_delegate/pathogen_base/venator
	name = "Base Venator Behavior Delegate"
