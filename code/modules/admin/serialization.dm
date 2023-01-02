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
	var/list/equip_list = list()
	var/list/implant_list = list()
	data["limbs"] = limbs_list
	data["equip"] = equip_list
	data["implant_list"] = implant_list
	data["age"] = age

	// No being naked
	data["ushirt"] = undershirt
	data["uwear"] = underwear

	// Limbs
	for(var/limb in limbs)
		var/obj/limb/L = limbs[limb]
		if(!L)
			limbs_list[limb] = "missing"
			continue
		limbs_list[limb] = L.serialize()

	// Equipment
	equip_list.len = TOTAL_SLOTS
	for(var/i = 1, i < TOTAL_SLOTS, i++)
		var/obj/item/thing = get_item_by_slot(i)
		if(thing != null)
			equip_list[i] = thing.serialize()

	for(var/obj/item/implant/implant in src)
		implant_list[implant] = implant.serialize()

	return data

/mob/living/carbon/human/deserialize(list/data)
	var/list/limbs_list = data["limbs"]
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

	for(var/thing in implant_list)
		var/implant_data = implant_list[thing]
		var/path = text2path(implant_data["type"])
		var/obj/item/implant/implant = new path(T)
		if(!implant.implanted(src, src))
			qdel(implant)

//	UpdateAppearance()

	// De-serialize equipment
	// #1: Jumpsuit
	// #2: Outer suit
	// #3+: Everything else
	if(islist(equip_list[w_uniform]))
		var/obj/item/clothing/C = list_to_object(equip_list[w_uniform], T)
		equip_to_slot_if_possible(C, w_uniform)

	if(islist(equip_list[wear_suit]))
		var/obj/item/clothing/C = list_to_object(equip_list[wear_suit], T)
		equip_to_slot_if_possible(C, wear_suit)

	for(var/i = 1, i < TOTAL_SLOTS, i++)
		if(i == w_uniform || i == wear_suit)
			continue
		if(islist(equip_list[i]))
			var/obj/item/clothing/C = list_to_object(equip_list[i], T)
			equip_to_slot_if_possible(C, i)
	update_icons()

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

	data["btype"] = blood_type
	data["access"] = access
	data["job"] = assignment
	data["account"] = associated_account_number
	data["owner"] = registered_name
	data["item_name"] = name
	return data

/obj/item/card/id/deserialize(list/data)
	blood_type = data["btype"]
	access = data["access"] // No need for a copy, the list isn't getting touched
	assignment = data["job"]
	associated_account_number = data["account"]
	registered_name = data["owner"]
	name = data["item_name"]

	..()
