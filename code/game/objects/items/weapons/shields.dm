/obj/item/weapon/shield
	name = "shield"
	var/base_icon_state = "shield"
	var/passive_block = 15 // Percentage chance used in prob() to block incoming attack
	var/readied_block = 30
	var/readied_slowdown = SLOWDOWN_ARMOR_VERY_LIGHT // Walking around in a readied shield stance slows you! The armor defs are a useful existing reference point.
	var/shield_readied = FALSE

// Toggling procs
/obj/item/weapon/shield/proc/raise_shield(mob/user as mob) // Prepare for an attack. Slows you down slightly, but increases chance to block.
	user.visible_message(SPAN_BLUE("\The [user] raises \the [src]."))
	shield_readied = TRUE
	icon_state = "[base_icon_state]_ready"

	var/mob/living/carbon/human/H = user
	var/current_shield_slowdown = H.shield_slowdown
	H.shield_slowdown = max(readied_slowdown, H.shield_slowdown)
	if(H.shield_slowdown != current_shield_slowdown)
		H.recalculate_move_delay = TRUE

/obj/item/weapon/shield/proc/lower_shield(mob/user as mob)
	user.visible_message(SPAN_BLUE("\The [user] lowers \the [src]."))
	shield_readied = FALSE
	icon_state = base_icon_state

	var/mob/living/carbon/human/H = user
	var/current_shield_slowdown = H.shield_slowdown
	var/set_shield_slowdown = 0
	var/obj/item/weapon/shield/offhand_shield
	if(H.l_hand == src && istype(H.r_hand, /obj/item/weapon/shield))
		offhand_shield = H.r_hand
	else if(H.r_hand == src && istype(H.l_hand, /obj/item/weapon/shield))
		offhand_shield = H.l_hand
	if(offhand_shield?.shield_readied)
		set_shield_slowdown = offhand_shield.readied_slowdown
	H.shield_slowdown = set_shield_slowdown
	if(H.shield_slowdown != current_shield_slowdown)
		H.recalculate_move_delay = TRUE

/obj/item/weapon/shield/proc/toggle_shield(mob/user as mob)
	if(shield_readied)
		lower_shield(user)
	else
		raise_shield(user)

// Making sure that debuffs don't stay
/obj/item/weapon/shield/dropped(mob/user as mob)
	if(shield_readied)
		lower_shield(user)
	..()

/obj/item/weapon/shield/equipped(mob/user, slot)
	if(shield_readied)
		lower_shield(user)
	..()

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/items/weapons/weapons.dmi'
	icon_state = "riot"
	item_state = "riot"
	base_icon_state = "riot"
	flags_equip_slot = SLOT_BACK
	force = 15
	passive_block = 20
	readied_block = 40
	readied_slowdown = SLOWDOWN_ARMOR_LIGHT
	throwforce = 5.0
	throw_speed = SPEED_FAST
	throw_range = 4
	w_class = SIZE_LARGE
	matter = list("glass" = 7500, "metal" = 1000)

	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/weapon/shield/riot/IsShield()
	return 1

/obj/item/weapon/shield/riot/attack_self(var/mob/user)
	..()
	toggle_shield(user)

/obj/item/weapon/shield/riot/attackby(obj/item/W as obj, mob/user as mob)
	if(cooldown < world.time - 25)
		if(istype(W, /obj/item/weapon/melee/baton) || istype(W, /obj/item/weapon/melee/claymore) || istype(W, /obj/item/weapon/melee/baseballbat) || istype(W, /obj/item/weapon/melee/katana) || istype(W, /obj/item/weapon/melee/twohanded/fireaxe) || istype(W, /obj/item/weapon/melee/chainofcommand))
			user.visible_message(SPAN_WARNING("[user] bashes [src] with [W]!"))
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 25, 1)
			cooldown = world.time
	else
		..()

/obj/item/weapon/shield/riot/flash
	name = "modified riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder. This one has had an industrial flash embedded within it."

	icon_state = "riot_f"
	item_state = "riot_f"
	base_icon_state = "riot_f"

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/brightness = 3

/obj/item/weapon/shield/riot/flash/proc/flash_recharge()
	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used -= 2
	last_used = world.time
	times_used = max(0,round(times_used)) //sanity


/obj/item/weapon/shield/riot/flash/attack(mob/living/M, mob/user)
	if(!user || !M)	return	//sanity
	if(!ishuman(M)) return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been flashed (attempt) with [src.name] by [key_name(user)]</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to flash [key_name(M)]</font>")
	msg_admin_attack("[key_name(user)] used the [src.name] to flash [key_name(M)] in [get_area(src)] ([src.loc.x],[src.loc.y],[src.loc.z]).", src.loc.x, src.loc.y, src.loc.z)

	if(!skillcheck(user, SKILL_POLICE, SKILL_POLICE_SKILLED))
		to_chat(user, SPAN_WARNING("You don't seem to know how to use [src]..."))
		return
	if(broken)
		to_chat(user, SPAN_WARNING("\The [src] is broken."))
		return
	flash_recharge()
	if(isXeno(M))
		to_chat(user, "You can't find any eyes!")
		return

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 3)
			last_used = world.time
			times_used++
		else	//can only use it 3 times a minute
			to_chat(user, SPAN_WARNING("*click* *click*"))
			return
	playsound(src.loc, 'sound/weapons/flash.ogg', 25, 1)
	var/flashfail = 0

	if(iscarbon(M))
		flashfail = !M.flash_eyes(brightness)
		if(!flashfail)
			M.KnockDown(15)
	else if(isSilicon(M))
		M.KnockDown(rand(10,15))
	else
		flashfail = 1

	if(!flashfail)
		if(!isSilicon(M))
			user.visible_message("<span class='disarm'>[user] blinds [M] with the [src]!</span>")
		else
			user.visible_message(SPAN_NOTICE("[user] overloads [M]'s sensors with the [src]!"))
	else
		user.visible_message(SPAN_NOTICE("[user] fails to blind [M] with the [src]!"))
	return

/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/items/weapons/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags_atom = FPRINT|CONDUCT|NOBLOODY
	force = 3
	passive_block = 50 // Shield activation takes over functionality, and no slowdown.
	readied_block = 50
	throwforce = 5.0
	throw_speed = SPEED_FAST
	throw_range = 4
	w_class = SIZE_SMALL

	attack_verb = list("shoved", "bashed")
	var/active = 0
