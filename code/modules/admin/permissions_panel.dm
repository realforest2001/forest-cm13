/client/load_player_data_info(datum/entity/player/player)
	. = ..()

	if(CLIENT_HAS_RIGHTS(src, R_HOST) || CLIENT_HAS_RIGHTS(src, R_PERMISSIONS))
		add_verb(src, /client/proc/permissions_panel)

/client
	var/datum/permissions_panel/perms_panel

/client/proc/permissions_panel()
	set name = "Permissions Panel"
	set category = "Admin.Panels"

	if(!check_rights(R_PERMISSIONS|R_HOST))
		message_admins(SPAN_ALERTWARNING("WARNING: [key_name(usr)] attempted to open the Permissions Panel!"))
		return FALSE

	if(perms_panel)
		qdel(perms_panel)
	perms_panel = new
	perms_panel.tgui_interact(mob)

#define PERMS_NONE 0
#define PERMS_MANAGER 1
#define PERMS_HOST 2

GLOBAL_LIST_INIT(staff_administration_flags, list(
	list(name = "Mod", bitflag = R_MOD, permission = PERMS_MANAGER),
	list(name = "Admin", bitflag = R_ADMIN, permission = PERMS_MANAGER),
	list(name = "Ban", bitflag = R_BAN, permission = PERMS_MANAGER),
	list(name = "Server", bitflag = R_SERVER, permission = PERMS_MANAGER),
))
GLOBAL_PROTECT(staff_administration_flags)
GLOBAL_LIST_INIT(staff_development_flags, list(
	list(name = "Variable Edit", bitflag = R_VAREDIT, permission = PERMS_MANAGER),
	list(name = "Spawn", bitflag = R_SPAWN, permission = PERMS_MANAGER),
	list(name = "Debug", bitflag = R_DEBUG, permission = PERMS_MANAGER),
	list(name = "Profiler", bitflag = R_PROFILER, permission = PERMS_MANAGER),
))
GLOBAL_PROTECT(staff_development_flags)
GLOBAL_LIST_INIT(staff_event_flags, list(
	list(name = "Minor Events", bitflag = R_EVENT, permission = PERMS_MANAGER),
	list(name = "Buildmode", bitflag = R_BUILDMODE, permission = PERMS_MANAGER),
	list(name = "Sound", bitflag = R_SOUNDS, permission = PERMS_MANAGER),
))
GLOBAL_PROTECT(staff_event_flags)
GLOBAL_LIST_INIT(staff_misc_flags, list(
	list(name = "Mentor", bitflag = R_MENTOR, permission = PERMS_MANAGER),
	list(name = "OOC Color", bitflag = R_COLOR, permission = PERMS_MANAGER),
	list(name = "Possess", bitflag = R_POSSESS, permission = PERMS_MANAGER),
	list(name = "Skip Timelocks", bitflag = R_NOLOCK, permission = PERMS_MANAGER),
))
GLOBAL_PROTECT(staff_misc_flags)
GLOBAL_LIST_INIT(staff_manager_flags, list(
	list(name = "Stealth", bitflag = R_STEALTH, permission = PERMS_MANAGER),
	list(name = "Edit Permissions", bitflag = R_PERMISSIONS, permission = PERMS_HOST),
))
GLOBAL_PROTECT(staff_manager_flags)

/datum/permissions_panel
	var/viewed_player = list()
	var/current_menu = "Panel"
	var/user_rights = 0
	var/target_rights = 0
	var/target_title
	var/new_rights = 0
	var/new_title

/datum/permissions_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PermissionsPanel", "Permissions Panel")
		ui.open()

/datum/permissions_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/permissions_panel/ui_close(mob/user)
	. = ..()
	if(user?.client.wl_panel)
		qdel(user.client.wl_panel)

/datum/permissions_panel/vv_edit_var(var_name, var_value)
	return FALSE

/datum/permissions_panel/ui_data(mob/user)
	var/list/data = list()

	data["current_menu"] = current_menu
	data["user_rights"] = user_rights
	data["viewed_player"] = viewed_player
	data["target_rights"] = target_rights
	data["target_title"] = target_title
	data["new_rights"] = new_rights

	return data

/datum/permissions_panel/ui_static_data(mob/user)
	. = list()
	.["admin_flags"] = GLOB.staff_administration_flags
	.["dev_flags"] = GLOB.staff_development_flags
	.["event_flags"] = GLOB.staff_event_flags
	.["misc_flags"] = GLOB.staff_misc_flags
	.["manager_flags"] = GLOB.staff_manager_flags
	.["staff_presets"] = GLOB.admin_ranks

	var/list/datum/view_record/players/players_view = DB_VIEW(/datum/view_record/players, DB_COMP("admin_status", DB_NOTEQUAL, ""))

	var/list/staff_list = list()
	for(var/datum/view_record/players/staff_member in players_view)
		var/list/current_player = list()
		current_player["ckey"] = staff_member.ckey
		current_player["title"] = staff_member.admin_title
		var/list/unreadable_list = splittext(staff_member.admin_status, "|")
		var/readable_list = unreadable_list.Join(" | ")
		current_player["status"] = readable_list
		staff_list += list(current_player)
	.["staff_list"] = staff_list

/datum/permissions_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(!CLIENT_HAS_RIGHTS(user.client, R_PERMISSIONS))
		message_admins(SPAN_ALERTWARNING("WARNING: [key_name(user)] attempted to trigger a Permissions Panel command!"))
		return FALSE
	switch(action)
		if("go_back")
			go_back()
			return
		if("select_player")
			select_player(user, params["player"])
			return
		if("add_player")
			select_player(user, TRUE)
			return
		if("update_number")
			new_rights = text2num(params["perm_flag"])
			return
		if("apply_preset")
			to_chat(user, SPAN_HELPFUL("Preset applied!."))
			var/rights_checker = params["preset"]
			if((rights_checker & R_PERMISSIONS || rights_checker & R_HOST) && !CLIENT_HAS_RIGHTS(user.client, R_HOST))
				return FALSE
			new_rights = rights_checker
			new_title = params["title"]
			return

		if("update_perms")
			var/player_key = params["player"]
			var/reason = tgui_input_text(user, "What is the reason for this change?", "Update Reason")
			if(!reason)
				return
			var/datum/entity/player/player = get_player_from_key(player_key)
			player.set_admin_status(new_rights)
			player.admin_title = new_title
			to_chat(user, SPAN_HELPFUL("Admin rights for [player_key] updated."))
			message_admins("Admin rights for [player_key] updated by [key_name(user)]. Reason: '[reason]'.")
			log_admin("PERMISSIONS: Flags for [player_key] changed from [target_rights] to [new_rights]. Reason: '[reason]'.")
			update_static_data(user, ui)
			go_back()
			return
		if("refresh_data")
			update_static_data(user, ui)
			to_chat(user, SPAN_NOTICE("Permissions data refreshed."))
			return

/datum/permissions_panel/proc/select_player(mob/user, player_key)
	if(IsAdminAdvancedProcCall())
		return PROC_BLOCKED
	var/target_key = player_key
	if(!target_key)
		return FALSE

	if(target_key == TRUE)
		var/new_player = tgui_input_text(user, "Enter the new ckey you wish to add. Do not include spaces or special characters.", "New Staff")
		if(!new_player)
			return FALSE
		target_key = new_player

	var/datum/entity/player/player = get_player_from_key(target_key)
	var/check_rights = get_user_rights(user)
	if((player.admin_flags & R_PERMISSIONS) && !(check_rights & PERMS_HOST))
		to_chat(SPAN_BOLDWARNING("You cannot edit a manager's permissions."))
		return FALSE
	var/list/current_player = list()
	current_player["ckey"] = target_key
	current_player["status"] = player.admin_status
	current_player["title"] = player.admin_title

	target_rights = player.admin_flags
	target_title = player.admin_title
	new_rights = player.admin_flags
	viewed_player = current_player
	current_menu = "Update"
	user_rights = check_rights
	return

/datum/permissions_panel/proc/go_back()
	viewed_player = list()
	user_rights = 0
	current_menu = "Panel"
	target_rights = 0
	new_rights = 0

/datum/permissions_panel/proc/get_user_rights(mob/user)
	if(!user.client)
		return
	var/client/person = user.client
	var/rights
	if(CLIENT_HAS_RIGHTS(person, R_HOST))
		rights |= PERMS_HOST
	if(CLIENT_HAS_RIGHTS(person, R_PERMISSIONS))
		rights |= PERMS_MANAGER
	return rights

#undef PERMS_MANAGER
#undef PERMS_HOST
