/client/proc/admin_serialize()
	set name = "Serialize Marked Datum"
	set desc = "Turns your marked object into a JSON string you can later use to re-create the object"
	set category = "Debug.Serializer"

	if(!check_rights(R_DEBUG))
		to_chat("You require DEBGUG to perform this action.")
		return

	var/datum/selected_mark
	if(!admin_holder.marked_datums.len)
		to_chat(usr, "You don't have any datum marked.")
		return
	else
		selected_mark = input_marked_datum(admin_holder.marked_datums)
		if(!selected_mark)
			return
		if(!istype(selected_mark,/atom/movable))
			to_chat(usr, "The datum you have marked cannot be used as a target. Target must be of type /atom/movable.")
			return

	var/atom/movable/serialize_target = selected_mark
	to_chat(usr, json_encode(serialize_target.serialize()))
	log_game(json_encode(serialize_target.serialize()))

/client/proc/admin_deserialize()
	set name = "Deserialize JSON datum"
	set desc = "Creates an object from a JSON string"
	set category = "Debug.Serializer"

	if(!check_rights(R_DEBUG))
		to_chat("You require DEBGUG to perform this action.")
		return

	var/json_text = input("Enter the JSON code:","Text") as message|null
	if(json_text)
		json_to_object(json_text, get_turf(usr))
		message_admins("[key_name_admin(usr)] spawned an atom from a custom JSON object.")
		log_admin("[key_name(usr)] spawned an atom from a custom JSON object, JSON Text: [json_text]")



/// Humans
/mob/living/carbon/human/serialize()
	// Currently: Limbs/organs only
	var/list/data = ..()
	var/list/limbs_list = list()
	var/list/organs_list = list()
	var/list/equip_list = list()
	var/list/implant_list = list()
	data["limbs"] = limbs_list
	data["iorgans"] = organs_list
	data["equip"] = equip_list
	data["implant_list"] = implant_list
	data["age"] = age

	// No being naked
	data["ushirt"] = undershirt
	data["uwear"] = underwear

	// Limbs
	for(var/limb in limbs)
		var/obj/limb/L = bodyparts_by_name[limb]
		if(!L)
			limbs_list[limb] = "missing"
			continue

		limbs_list[limb] = O.serialize()

	// Internal organs/augments
	for(var/organ in internal_organs)
		var/obj/item/organ/O = organ
		organs_list[O.name] = O.serialize()

	// Equipment
	equip_list.len = slots_amt
	for(var/i = 1, i < slots_amt, i++)
		var/obj/item/thing = get_item_by_slot(i)
		if(thing != null)
			equip_list[i] = thing.serialize()

	for(var/obj/item/implant/implant in src)
		implant_list[implant] = implant.serialize()

	return data

/mob/living/carbon/human/deserialize(list/data)
	var/list/limbs_list = data["limbs"]
	var/list/organs_list = data["iorgans"]
	var/list/equip_list = data["equip"]
	var/list/implant_list = data["implant_list"]
	var/turf/T = get_turf(src)
	if(!islist(data["limbs"]))
		throw EXCEPTION("Expected a limbs list, but found none")

	age = data["age"]
	undershirt = data["ushirt"]
	underwear = data["uwear"]

	for(var/limb in limbs_list)
		// Missing means skip this part - it's missing
		if(limbs_list[limb] == "missing")
			continue

	for(var/organ in organs_list)
		// As above, "New" code handles insertion, DNA sync
		list_to_object(organs_list[organ], src)

	for(var/thing in implant_list)
		var/implant_data = implant_list[thing]
		var/path = text2path(implant_data["type"])
		var/obj/item/implant/implant = new path(T)
		if(!implant.implant(src, src))
			qdel(implant)

	UpdateAppearance()

	// De-serialize equipment
	// #1: Jumpsuit
	// #2: Outer suit
	// #3+: Everything else
	if(islist(equip_list[slot_w_uniform]))
		var/obj/item/clothing/C = list_to_object(equip_list[slot_w_uniform], T)
		equip_to_slot_if_possible(C, slot_w_uniform)

	if(islist(equip_list[slot_wear_suit]))
		var/obj/item/clothing/C = list_to_object(equip_list[slot_wear_suit], T)
		equip_to_slot_if_possible(C, slot_wear_suit)

	for(var/i = 1, i < slots_amt, i++)
		if(i == slot_w_uniform || i == slot_wear_suit)
			continue
		if(islist(equip_list[i]))
			var/obj/item/clothing/C = list_to_object(equip_list[i], T)
			equip_to_slot_if_possible(C, i)
	update_icons()

	..()


/// Organs
/obj/item/organ/serialize()
	var/data = ..()
	if(status)
		data["status"] = status
	return data

/obj/item/organ/deserialize(data)
	if(isnum(data["status"]))
		if(data["status"] & ORGAN_ROBOT)
			robotize()
		status = data["status"]
	..()

/// Storage
/obj/item/clothing/suit/storage/serialize()
	var/list/data = ..()
	data["pockets"] = pockets.serialize()
	return data

/obj/item/clothing/suit/storage/deserialize(list/data)
	qdel(pockets)
	pockets = list_to_object(data["pockets"], src)


/obj/item/storage/serialize()
	var/data = ..()
	var/list/content_list = list()
	data["content"] = content_list
	data["slots"] = storage_slots
	data["max_w_class"] = max_w_class
	data["max_c_w_class"] = max_combined_w_class
	for(var/thing in contents)
		var/atom/movable/AM = thing
		// This code does not watch out for infinite loops
		// But then again a tesseract would destroy the server anyways
		// Also I wish I could just insert a list instead of it reading it the wrong way
		content_list.len++
		content_list[content_list.len] = AM.serialize()
	return data

/obj/item/storage/deserialize(list/data)
	if(isnum(data["slots"]))
		storage_slots = data["slots"]
	if(isnum(data["max_w_class"]))
		max_w_class = data["max_w_class"]
	if(isnum(data["max_c_w_class"]))
		max_combined_w_class = data["max_c_w_class"]
	for(var/thing in contents)
		qdel(thing) // out with the old
	for(var/thing in data["content"])
		if(islist(thing))
			list_to_object(thing, src)
		else if(thing == null)
			stack_trace("Null entry found in storage/deserialize.")
		else
			stack_trace("Non-list thing found in storage/deserialize (Thing: [thing])")
	..()


/obj/item/storage/belt/deserialize(list/data)
	..()
	update_icon()


/// Clothing
/obj/item/clothing/under/serialize()
	var/data = ..()
	var/list/accessories_list = list()
	data["accessories"] = accessories_list
	for(var/obj/item/clothing/accessory/A in accessories)
		accessories_list.len++
		accessories_list[accessories_list.len] = A.serialize()

	return data

/obj/item/clothing/under/deserialize(list/data)
	for(var/thing in accessories)
		remove_accessory(src, thing)
	for(var/thing in data["accessories"])
		if(islist(thing))
			var/obj/item/clothing/accessory/A = list_to_object(thing, src)
			A.has_suit = src
			accessories += A
	..()


/// ID Card
/obj/item/card/id/serialize()
	var/list/data = ..()

	data["sex"] = sex
	data["age"] = age
	data["btype"] = blood_type
	data["dna_hash"] = dna_hash
	data["fprint_hash"] = fingerprint_hash
	data["access"] = access
	data["job"] = assignment
	data["account"] = associated_account_number
	data["owner"] = registered_name
	return data

/obj/item/card/id/deserialize(list/data)
	sex = data["sex"]
	age = data["age"]
	blood_type = data["btype"]
	dna_hash = data["dna_hash"]
	fingerprint_hash = data["fprint_hash"]
	access = data["access"] // No need for a copy, the list isn't getting touched
	assignment = data["job"]
	associated_account_number = data["account"]
	registered_name = data["owner"]
	mining_points = data["mining"]
	// We'd need to use icon serialization(b64) to save the photo, and I don't feel like i
	UpdateName()
	RebuildHTML()
	..()
