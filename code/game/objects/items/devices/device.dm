
//electronic devices

/obj/item/device
	icon = 'icons/obj/items/devices.dmi'
	var/serial_number
	var/serialed = TRUE

/obj/item/device/Initialize()
	. = ..()
	if(serialed)
		serial_number = "[rand(0,9)][pick(alphabet_uppercase)][rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)][pick(alphabet_uppercase)]"

/obj/item/device/get_examine_text(mob/user)
	. = ..()
	if(!isxeno(user) && (get_dist(user, src) < 2 || isobserver(user)) && serial_number)
		. += SPAN_INFO("The serial number is [serial_number].")
