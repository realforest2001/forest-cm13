/datum/caste_datum/pathogen/matriarch
	caste_type = PATHOGEN_CREATURE_MATRIARCH
	tier = 4

	melee_damage_lower = XENO_DAMAGE_TIER_6
	melee_damage_upper = XENO_DAMAGE_TIER_8
	melee_vehicle_damage = XENO_DAMAGE_TIER_8
	max_health = XENO_HEALTH_KING
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_PLASMA_TIER_10
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_10
	armor_deflection = XENO_ARMOR_TIER_4
	evasion = XENO_EVASION_LOW
	speed = XENO_SPEED_TIER_1

	attack_delay = 0

	available_strains = list()
	behavior_delegate_type = /datum/behavior_delegate/pathogen_base/matriarch

	deevolves_to = list()
	caste_desc = "Fury and death..."
	evolves_to = list()

	heal_resting = 1.6
	is_intelligent = TRUE

	minimap_icon = "matriarch"
	evolution_allowed = FALSE
	royal_caste = TRUE

/mob/living/carbon/xenomorph/matriarch
	caste_type = PATHOGEN_CREATURE_MATRIARCH
	name = PATHOGEN_CREATURE_MATRIARCH
	desc = "Nothing will survive..."
	icon_size = 48
	icon_state = "Matriarch Walking"
	plasma_types = list()
	pixel_x = -16
	old_x = -16
	tier = 4
	organ_value = 15000
	base_actions = list(
		/datum/action/xeno_action/onclick/toggle_seethrough,
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/release_haul,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/onclick/plant_weeds/pathogen,
		/datum/action/xeno_action/onclick/emit_pheromones,
		/datum/action/xeno_action/activable/tail_stab/pathogen_t3,
		/datum/action/xeno_action/activable/tail_stab/mycotoxin/matriarch,
		/datum/action/xeno_action/onclick/shatter, // Macro 1
		/datum/action/xeno_action/activable/rav_spikes, // Macro 2
		/datum/action/xeno_action/onclick/spike_shed, // Macro 3
		/datum/action/xeno_action/onclick/blight_wave, // Macro 4
		/datum/action/xeno_action/onclick/paralyzing_slash/blight_slash, //Macro 5
	)
	claw_type = CLAW_TYPE_VERY_SHARP

	tackle_min = 2
	tackle_max = 5
	tackle_chance = 45

	icon_xeno = 'icons/mob/pathogen/matriarch.dmi'
	icon_xenonid = 'icons/mob/pathogen/matriarch.dmi'

	weed_food_icon = 'icons/mob/xenos/weeds_48x48.dmi'
	mycelium_food_icon = 'icons/mob/pathogen/pathogen_weeds_48x48.dmi'
	weed_food_states = list("Matriarch_1","Matriarch_2","Matriarch_3")
	weed_food_states_flipped = list("Matriarch_1","Matriarch_2","Matriarch_3")

	AUTOWIKI_SKIP(TRUE)
	hivenumber = XENO_HIVE_PATHOGEN
	speaking_noise = "pathogen_talk"

	mob_size = MOB_SIZE_BIG
	acid_blood_damage = 0
	bubble_icon = "pathogenroyal"
	fire_immunity = FIRE_VULNERABILITY
	counts_for_slots = FALSE
	aura_strength = 5
	langchat_height = 64

/mob/living/carbon/xenomorph/matriarch/Initialize()
	. = ..()
	make_pathogen_speaker()
	ADD_TRAIT(src, TRAIT_ABILITY_NEOS_TAILSTAB, TRAIT_SOURCE_ABILITY("neos_tailstab"))
	ADD_TRAIT(src, TRAIT_ABILITY_BLIGHT_WAVE, TRAIT_SOURCE_ABILITY("blight_wave"))
	ADD_TRAIT(src, TRAIT_ABILITY_TAILSTAB_MYCOTOXIN, TRAIT_SOURCE_ABILITY("tailstab_mycotoxin"))
	AddComponent(/datum/component/footstep, 2 , 35, 11, 4, "alien_footstep_large")
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_block))

/mob/living/carbon/xenomorph/matriarch/proc/check_block(mob/queen, turf/new_loc)
	SIGNAL_HANDLER
	if(body_position == LYING_DOWN || stat == UNCONSCIOUS)
		return
	for(var/mob/living/carbon/xenomorph/xeno in new_loc.contents)
		if(xeno.stat == DEAD)
			continue
		if(xeno.pass_flags.flags_pass & (PASS_MOB_THRU_XENO|PASS_MOB_THRU) || xeno.flags_pass_temp & PASS_MOB_THRU)
			continue
		if(xeno.hivenumber == hivenumber && !(queen.client?.prefs?.toggle_prefs & TOGGLE_AUTO_SHOVE_OFF))
			xeno.KnockDown((5 DECISECONDS) / GLOBAL_STATUS_MULTIPLIER)
			playsound(src, 'sound/weapons/alien_knockdown.ogg', 25, 1)


/datum/behavior_delegate/pathogen_base/matriarch
	name = "Base Matriarch Behavior Delegate"

	// Shard config
	var/max_shards = 300
	var/shard_gain_onlife = 2
	var/shards_per_projectile = 7
	var/shards_per_slash = 10
	var/armor_buff_per_fifty_shards = 2.50
	var/shard_lock_duration = 150
	var/shard_lock_speed_mod = 0.45

	// Shard state
	var/shards = 0
	var/shards_locked = FALSE //are we locked at 0 shards?

	// Armor buff state
	var/times_armor_buffed = 0

/datum/behavior_delegate/pathogen_base/matriarch/append_to_stat()
	. = list()
	. += "Bone Shards: [shards]/[max_shards]"
	. += "Shards Armor Bonus: [times_armor_buffed*armor_buff_per_fifty_shards]"

	var/datum/hive_status/pathogen/hive = GLOB.hive_datum[XENO_HIVE_PATHOGEN]
	if(hive)
		. += "Pathogen Poppers: [hive.get_popper_num()]/[hive.max_poppers]"

/datum/behavior_delegate/pathogen_base/matriarch/proc/lock_shards()
	if (!bound_xeno)
		return

	to_chat(bound_xeno, SPAN_XENODANGER("You have shed your spikes and cannot gain any more for [shard_lock_duration/10] seconds!"))

	bound_xeno.speed_modifier -= shard_lock_speed_mod
	bound_xeno.recalculate_speed()

	shards = 0
	shards_locked = TRUE
	addtimer(CALLBACK(src, PROC_REF(unlock_shards)), shard_lock_duration)

/datum/behavior_delegate/pathogen_base/matriarch/proc/unlock_shards()
	if (!bound_xeno)
		return

	to_chat(bound_xeno, SPAN_XENODANGER("You feel your ability to gather shards return!"))

	bound_xeno.speed_modifier += shard_lock_speed_mod
	bound_xeno.recalculate_speed()
	shards_locked = FALSE

// Return true if we have enough shards, false otherwise
/datum/behavior_delegate/pathogen_base/matriarch/proc/check_shards(amount)
	if (!amount)
		return FALSE
	else
		return (shards >= amount)

/datum/behavior_delegate/pathogen_base/matriarch/proc/use_shards(amount)
	if (!amount)
		return
	shards = max(0, shards - amount)

/datum/behavior_delegate/pathogen_base/matriarch/on_life()
	if (!shards_locked)
		shards = min(max_shards, shards + shard_gain_onlife)

	var/armor_buff_count = shards/50 //0-6
	bound_xeno.armor_modifier -= times_armor_buffed * armor_buff_per_fifty_shards
	bound_xeno.armor_modifier += armor_buff_count * armor_buff_per_fifty_shards
	bound_xeno.recalculate_armor()
	times_armor_buffed = armor_buff_count

	var/image/holder = bound_xeno.hud_list[PLASMA_HUD]
	holder.overlays.Cut()
	var/percentage_shards = round((shards / max_shards) * 100, 10)
	if(percentage_shards)
		holder.overlays += image('icons/mob/hud/hud.dmi', "xenoenergy[percentage_shards]")

	if(percentage_shards >= 50)
		bound_xeno.small_explosives_stun = FALSE
		bound_xeno.add_filter("hedge_unstunnable", 1, list("type" = "outline", "color" = "#421313", "size" = 1))
	else
		bound_xeno.small_explosives_stun = TRUE
		bound_xeno.remove_filter("hedge_unstunnable", 1, list("type" = "outline", "color" = "#421313", "size" = 1))
	return

/datum/behavior_delegate/pathogen_base/matriarch/handle_death(mob/M)
	var/image/holder = bound_xeno.hud_list[PLASMA_HUD]
	holder.overlays.Cut()

/datum/behavior_delegate/pathogen_base/matriarch/on_hitby_projectile()
	if (!shards_locked)
		shards = min(max_shards, shards + shards_per_projectile)
	return

/datum/behavior_delegate/pathogen_base/matriarch/melee_attack_additional_effects_self()
	if (!shards_locked)
		shards = min(max_shards, shards + shards_per_slash)
	return




/// Screech which puts out lights in a 7 tile radius, slows and dazes.
/datum/action/xeno_action/onclick/blight_wave
	name = "Blight Wave"
	action_icon_state = "screech"
	macro_path = /datum/action_xeno_action/verb/verb_doom
	xeno_cooldown = 90 SECONDS
	plasma_cost = 200
	ability_primacy = XENO_PRIMARY_ACTION_4

	var/daze_length_seconds = 1
	var/slow_length_seconds = 4

/datum/action/xeno_action/onclick/blight_wave/overmind
	xeno_cooldown = 120 SECONDS
	plasma_cost = 400
	ability_primacy = XENO_NOT_PRIMARY_ACTION

/datum/action/xeno_action/onclick/blight_wave/overmind/can_use_action(silent = FALSE, override_flags)
	if(owner?.status_flags & INCORPOREAL)
		return FALSE
	return ..()

/datum/action/xeno_action/onclick/blight_wave/use_ability(atom/target, daze_length_seconds, slow_length_seconds)
	var/mob/living/carbon/xenomorph/xeno_player = owner
	cast_doom(daze_length_seconds, slow_length_seconds)
	if(!HAS_TRAIT(xeno_player, TRAIT_ABILITY_BLIGHT_WAVE)) //In case matriarch will be overmind, they can lose this ability.
		ADD_TRAIT(xeno_player, TRAIT_ABILITY_BLIGHT_WAVE, TRAIT_SOURCE_ABILITY("blight_wave"))
	..()

/datum/effect_system/smoke_spread/blight_wave
	smoke_type = /obj/effect/particle_effect/smoke/blight

/obj/effect/particle_effect/smoke/blight
	name = "blight cloud"
	opacity = FALSE
	color = "#000000"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = BELOW_OBJ_LAYER
	time_to_live = 5
	spread_speed = 1
	pixel_x = 0
	pixel_y = 0

/obj/effect/particle_effect/smoke/blight/affect(mob/living/carbon/creature)
	. = ..()
	if(!.)
		return FALSE
	if(creature.stat == DEAD)
		return FALSE
	if(issynth(creature))
		return FALSE
	if(can_not_harm(creature))
		return FALSE

	var/mob/living/carbon/xenomorph/xeno_creature
	var/mob/living/carbon/human/human_creature
	if(isxeno(creature))
		xeno_creature = creature
	else if(ishuman(creature))
		human_creature = creature

	if(isyautja(creature) && prob(75))
		return FALSE

	var/block_chance = 0
	if(creature.wear_mask && (creature.wear_mask.flags_inventory & BLOCKGASEFFECT))
		block_chance += 30
		if(creature.wear_mask.flags_inventory & SPOREPROOF)
			return FALSE

	if(human_creature && (human_creature.head && (human_creature.head.flags_inventory & BLOCKGASEFFECT)))
		block_chance += 30
		if(human_creature.head.flags_inventory & SPOREPROOF)
			return FALSE

	if(prob(block_chance))
		return FALSE

	var/effect_amt = floor(6 + amount*6)

	if(xeno_creature)
		xeno_creature.AddComponent(/datum/component/status_effect/interference, 10, 10)
		xeno_creature.blinded = TRUE
	else
		creature.apply_damage(12, OXY)

	creature.SetEarDeafness(max(creature.ear_deaf, floor(effect_amt*1.5))) //Paralysis of hearing system, aka deafness
	if(!xeno_creature && !creature.eye_blind) //Eye exposure damage
		to_chat(creature, SPAN_DANGER("Your eyes sting. You can't see!"))
		creature.SetEyeBlind(floor(effect_amt/3))

	if(human_creature && creature.coughedtime < world.time && !creature.stat) //Coughing/gasping
		creature.coughedtime = world.time + 1.5 SECONDS
		if(prob(50))
			creature.emote("cough")
		else
			creature.emote("gasp")

	var/stun_chance = 35
	if(prob(stun_chance))
		creature.KnockDown(2)

	//Topical damage (neurotoxin on exposed skin)
	if(xeno_creature)
		to_chat(xeno_creature, SPAN_XENODANGER("You are struggling to move, it's as if you're paralyzed!"))
	else
		to_chat(creature, SPAN_DANGER("Your body is going numb, almost as if paralyzed!"))
	if(prob(60 + floor(amount*15))) //Highly likely to drop items due to arms/hands seizing up
		creature.drop_held_item()
	if(human_creature)
		human_creature.temporary_slowdown = max(human_creature.temporary_slowdown, 4) //One tick every two second
		human_creature.recalculate_move_delay = TRUE
		if(prob(1)) //Very rare chance to infect
			attempt_infection(human_creature)
	return TRUE

/obj/effect/particle_effect/smoke/blight/proc/can_not_harm(mob/living/carbon/attempt_harm_mob)
	if(!istype(attempt_harm_mob))
		return FALSE
	var/datum/hive_status/hive = GLOB.hive_datum[XENO_HIVE_PATHOGEN]
	if(!hive)
		return FALSE
	if(HAS_TRAIT(attempt_harm_mob, TRAIT_HAULED))
		return TRUE
	return hive.is_ally(attempt_harm_mob)

/obj/effect/particle_effect/smoke/blight/proc/attempt_infection(mob/living/carbon/human/target)
	var/embryos = 0
	for(var/obj/item/alien_embryo/embryo in target) // already got one, stops doubling up
		if(embryo.hivenumber == XENO_HIVE_PATHOGEN)
			embryos++
		else
			qdel(embryo)
	if(!embryos)
		var/obj/item/alien_embryo/embryo = new /obj/item/alien_embryo/bloodburster(target)
		GLOB.player_embryo_list += embryo

		if(target.species)
			target.species.larva_impregnated(embryo)

		target.visible_message(SPAN_DANGER("[target] inhales [src] as they walk through it!"), SPAN_HIGHDANGER("You inhale [src] as you walk through it!"))
		var/area/breath_area = get_area(src)
		if(breath_area)
			notify_ghosts(header = "Infected", message = "[target] has been infected with pathogen spores at [breath_area]!", source = target, action = NOTIFY_ORBIT)
			to_chat(src, SPAN_DEADSAY("<b>[target]</b> has been infected with pathogen spores at \the <b>[breath_area]</b>"))
		else
			notify_ghosts(header = "Infected", message = "[target] has been infected with pathogen spores!", source = target, action = NOTIFY_ORBIT)
			to_chat(src, SPAN_DEADSAY("<b>[target]</b> has been infected with pathogen spores"))
		return TRUE
	return FALSE


/datum/action/xeno_action/onclick/shatter
	name = "Shatter"
	action_icon_state = "butchering"
	action_type = XENO_ACTION_ACTIVATE
	ability_primacy = XENO_PRIMARY_ACTION_1
	plasma_cost = 100
	xeno_cooldown = 45 SECONDS
	var/shatter_range = 1
	var/shatter_damage = 35

/datum/action/xeno_action/onclick/shatter/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno = owner
	if (!istype(xeno))
		return

	if(!xeno.check_state())
		return

	if (!action_cooldown_check())
		return

	xeno.visible_message(SPAN_XENOWARNING("[xeno] sweeps its huge arm in a wide circle!"),
	SPAN_XENOWARNING("We sweep our huge arm in a wide circle!"))

	if(!check_and_use_plasma_owner())
		return

	xeno.spin_circle()

	for(var/mob/living/carbon/human in orange(shatter_range, get_turf(xeno)))
		if (!isxeno_human(human) || xeno.can_not_harm(human))
			continue
		if(human.stat == DEAD)
			continue
		if(HAS_TRAIT(human, TRAIT_NESTED))
			continue
		step_away(human, xeno, shatter_range, 2)
		xeno.flick_attack_overlay(human, "punch")
		human.last_damage_data = create_cause_data(xeno.caste_type, xeno)
		human.apply_armoured_damage(get_xeno_damage_slash(xeno, shatter_damage), ARMOR_MELEE, BRUTE)
		shake_camera(human, 2, 1)

		if(human.mob_size < MOB_SIZE_BIG)
			human.apply_effect(get_xeno_stun_duration(human, 2), WEAKEN)

		to_chat(human, SPAN_XENOWARNING("You are struck by [xeno]'s huge arm!"))
		playsound(human,'sound/weapons/alien_claw_block.ogg', 50, 1)

	apply_cooldown()
	return ..()

/mob/living/carbon/xenomorph/matriarch/death(cause, gibbed)
	notify_ghosts(header = "Matriarch Death", message = "The Pathogen Matriarch has been slain!", source = src, action = NOTIFY_ORBIT)
	xeno_message(SPAN_XENOANNOUNCE("A sudden tremor ripples through the confluence... the Matriarch has been slain! Vengeance!"), 3, XENO_HIVE_PATHOGEN)

	return ..()

/mob/living/carbon/xenomorph/matriarch/is_xeno_grabbable()
	return TRUE
