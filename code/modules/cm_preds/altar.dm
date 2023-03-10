// A large amount of this file is placeholder stuff to test the concept.
/obj/structure/yautja_altar
	name = "Altar Root"
	desc = "Placeholder"//placeholder

	icon = 'icons/obj/items/hunter/pred_gear.dmi'//placeholder
	icon_state = "altar_base"//placeholder
	unacidable = TRUE
	density = TRUE
	color = "#b29082"

/obj/structure/yautja_altar/ex_act(severity)
	if(indestructible)
		return
	switch(severity)
		if(EXPLOSION_THRESHOLD_HIGH to INFINITY)
			qdel(src)
			return
	return

/obj/structure/yautja_altar/base
	name = "Altar Base"
	desc = "The base of a sandstone altar. Its carved with strange runes."

/obj/structure/yautja_altar/base/attackby(obj/item/hit_item, mob/user)
	if(istype(hit_item, /obj/item/stack/sheet/mineral/sandstone/runed))
		var/obj/item/stack/sandstone = hit_item
		if(sandstone.amount < 20)
			to_chat(user, SPAN_WARNING("Not enough sandstone!"))
			return
		if(do_after(user, 20, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
			sandstone.use(20)
			user.visible_message(SPAN_NOTICE("[user] builds an Altar."))//placeholder
			new /obj/structure/yautja_altar/core(loc)
			qdel(src)
	else if(istype(hit_item, /obj/item/weapon/wristblades))
		if(do_after(user, 20, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
			new /obj/item/stack/sheet/mineral/sandstone/runed/med_stack(loc)
			qdel(src)
	else
		return ..()

/obj/structure/yautja_altar/core
	name = "Altar"//placeholder
	desc = "The base and core of a sandstone altar. Many strange runes are spread across its surface."

	icon_state = "altar_core"//placeholder

/obj/structure/yautja_altar/core/attackby(obj/item/hit_item, mob/user)
	if(istype(hit_item, /obj/item/device/yautja_altar_core))
		if(do_after(user, 20, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
			user.visible_message(SPAN_NOTICE("[user] finishes the Sacred Altar."))//placeholder
			new /obj/structure/yautja_altar/built(loc)
			qdel(hit_item)
			qdel(src)
	else if(istype(hit_item, /obj/item/weapon/wristblades))
		if(do_after(user, 20, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_HOSTILE))
			new /obj/structure/yautja_altar/base(loc)
			new /obj/item/stack/sheet/mineral/sandstone/runed/small_stack(loc)
			qdel(src)
	else
		return ..()


/obj/structure/yautja_altar/built
	name = "Sacred Altar"//placeholder
	desc = "A sacred altar of runed sandstone. It resonates with importance."

	icon = 'icons/obj/items/hunter/pred_gear.dmi'//placeholder
	icon_state = "altar_finished"//placeholder

	var/cover_range = 5
	var/cover_strength = TURF_PROTECTION_OB
	var/list/linked_turfs = list()

/obj/structure/yautja_altar/built/Initialize(mapload)
	. = ..()
	build_roof()

/obj/structure/yautja_altar/built/Destroy()
	destroy_roof()
	. = ..()

/obj/structure/yautja_altar/built/proc/build_roof()
	for(var/turf/floor in range(round(cover_range*PYLON_COVERAGE_MULT), loc))
		LAZYADD(floor.linked_altars, src)
		linked_turfs += floor
	log_game("ALTAR: Roof Built")

/obj/structure/yautja_altar/built/proc/destroy_roof()
	for(var/turf/floor as anything in linked_turfs)
		LAZYREMOVE(floor.linked_altars, src)
		linked_turfs -= floor
	log_game("ALTAR: Roof Destroyed")

/obj/structure/yautja_altar/built/proc/rebuild_roof()
	log_game("ALTAR: Roof Rebuilt")
	destroy_roof()
	build_roof()


/obj/structure/yautja_altar/built/attackby(obj/item/hit_item, mob/user)
	if(istype(hit_item, /obj/item/stack/sheet/mineral/sandstone/runed))
		user.visible_message(SPAN_NOTICE("[user] rebuilds the temple roof."))
		rebuild_roof()
	else
		return ..()

/obj/item/device/yautja_altar_core
	name = "Signal Device"//placeholder
	desc= "A strange device you can't make sense of."//placeholder
	icon = 'icons/obj/items/hunter/pred_gear.dmi'
	icon_state = "yautja chocolate"
	serialed = FALSE
