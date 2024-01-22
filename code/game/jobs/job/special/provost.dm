/datum/job/special/provost
	supervisors = "the Provost Office"
	selection_class = "job_mp"
	entry_message_body = "<a href='"+WIKI_PLACEHOLDER+"'>You</a> are held by a higher standard and are required to obey not only the server rules but the <a href='"+LAW_PLACEHOLDER+"'>Marine Law</a>. Failure to do so may result in a job ban or server ban. Your primary job is to maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep! In addition, you are tasked with the mainting security records and overwatching any prisoners in Brig."
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADMIN_NOTIFY

//Provost Enforcer
/datum/job/special/provost/enforcer
	title = JOB_PROVOST_ENFORCER
	gear_preset = /datum/equipment_preset/uscm_event/provost/enforcer

//Provost Team Leader
/datum/job/special/provost/tml
	title = JOB_PROVOST_TML
	gear_preset = /datum/equipment_preset/uscm_event/provost/tml

//Provost Advisor
/datum/job/special/provost/advisor
	title = JOB_PROVOST_ADVISOR
	gear_preset = /datum/equipment_preset/uscm_event/provost/inspector/advisor

//Provost Inspector
/datum/job/special/provost/inspector
	title = JOB_PROVOST_INSPECTOR
	gear_preset = /datum/equipment_preset/uscm_event/provost/inspector

//Provost Marshal
/datum/job/special/provost/marshal
	title = JOB_PROVOST_MARSHAL
	supervisors = "the Provost Sector Marshal"
	gear_preset = /datum/equipment_preset/uscm_event/provost/marshal

//Provost Sector
/datum/job/special/provost/marshal/sector
	title = JOB_PROVOST_SMARSHAL
	supervisors = "the Provost Chief Marshal"
	gear_preset = /datum/equipment_preset/uscm_event/provost/marshal/sector

//Provost Chief Marshal
/datum/job/special/provost/marshal/chief
	title = JOB_PROVOST_CMARSHAL
	supervisors = "UA National Command Authority"
	gear_preset = /datum/equipment_preset/uscm_event/provost/marshal/chief
