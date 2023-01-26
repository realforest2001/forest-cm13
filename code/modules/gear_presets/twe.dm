/*Commented out so it's not accidentally used

/datum/equipment_preset/twe
	name = FACTION_TWE
	languages = list(LANGUAGE_JAPANESE, LANGUAGE_ENGLISH)
	assignment = JOB_TWE_CDO
	rank = JOB_TWE_CDO
	faction = FACTION_TWE
	origin_override = ORIGIN_CIVILIAN
	idtype = /obj/item/card/id/twe

/datum/equipment_preset/twe/New()
	. = ..()
	access = get_all_accesses()

/datum/equipment_preset/twe/load_name(mob/living/carbon/human/H, var/randomise)
	H.gender = pick(70;MALE, 30;FEMALE)
	var/random_name
	var/first_name
	var/last_name
	//gender checks
	if(H.gender == MALE)
		if(prob(20))
			first_name = "[capitalize(randomly_generate_japanese_word(rand(1, 3)))]"
		else
			first_name = "[pick(first_names_male_twe)]"
		H.f_style = pick("3 O'clock Shadow", "3 O'clock Moustache", "5 O'clock Shadow", "5 O'clock Moustache")
	else
		if(prob(20))
			first_name = "[capitalize(randomly_generate_japanese_word(rand(1, 3)))]"
		else
			first_name = "[pick(first_names_female_twe)]"
	//surname
	if(prob(20))
		last_name = "[capitalize(randomly_generate_japanese_word(rand(1, 4)))]"
	else
		last_name = "[pick(last_names_twe)]"
	//put them together
	random_name = "[first_name] [last_name]"
	H.change_real_name(H, random_name)
	H.age = rand(17,45)

/datum/equipment_preset/twe/load_id(mob/living/carbon/human/H, client/mob_client)
	if(human_versus_human)
		var/obj/item/clothing/under/uniform = H.w_uniform
		if(istype(uniform))
			uniform.has_sensor = UNIFORM_HAS_SENSORS
			uniform.sensor_faction = FACTION_TWE
	return ..()
//#####################################

/datum/equipment_preset/twe/cdo_standard
	name = "3WE Commando (Standard)"
	flags = EQUIPMENT_PRESET_EXTRA

	assignment = JOB_TWE_CDO
	rank = JOB_TWE_CDO
	paygrade = "3W-C1"
	skills = /datum/skills/pmc
	role_comm_title = "RMC"

/datum/equipment_preset/twe/cdo_engineer
	name = "3WE Commando (Engineer)"
	flags = EQUIPMENT_PRESET_EXTRA

	assignment = JOB_TWE_CDO_ENG
	rank = JOB_TWE_CDO_ENG
	paygrade = "3W-C2"
	skills = /datum/skills/pmc
	role_comm_title = "RMC-Tech"

/datum/equipment_preset/twe/cdo_medic
	name = "3WE Commando (Medic)"
	flags = EQUIPMENT_PRESET_EXTRA

	assignment = JOB_TWE_CDO_MED
	rank = JOB_TWE_CDO_MED
	paygrade = "3W-C2"
	skills = /datum/skills/pmc
	role_comm_title = "RMC-Med"

/datum/equipment_preset/twe/cdo_specialist
	name = "3WE Commando (Specialist)"
	flags = EQUIPMENT_PRESET_EXTRA

	assignment = JOB_TWE_CDO_SPEC
	rank = JOB_TWE_CDO_SPEC
	paygrade = "3W-C3"
	skills = /datum/skills/pmc
	role_comm_title = "RMC-Spc"

/datum/equipment_preset/twe/cdo_leader
	name = "3WE Commando (Leader)"
	flags = EQUIPMENT_PRESET_EXTRA

	assignment = JOB_TWE_CDO_SL
	rank = JOB_TWE_CDO_SL
	paygrade = "3W-C4"
	skills = /datum/skills/pmc
	role_comm_title = "RMC-SL"
*/
