GLOBAL_LIST_INIT(department_radio_prefixes, list(":", "."))

GLOBAL_LIST_INIT(department_radio_keys, list(
	// Location
	MODE_KEY_R_HAND = MODE_R_HAND,
	MODE_KEY_L_HAND = MODE_L_HAND,
	MODE_KEY_INTERCOM = MODE_INTERCOM,

	// Department
	MODE_KEY_DEPARTMENT = MODE_DEPARTMENT,
	RADIO_KEY_COMMAND = RADIO_CHANNEL_COMMAND,
	RADIO_KEY_SCIENCE = RADIO_CHANNEL_SCIENCE,
	RADIO_KEY_MEDICAL = RADIO_CHANNEL_MEDICAL,
	RADIO_KEY_ENGINEERING = RADIO_CHANNEL_ENGINEERING,
	RADIO_KEY_SECURITY = RADIO_CHANNEL_SECURITY,
	RADIO_KEY_SUPPLY = RADIO_CHANNEL_SUPPLY,
	RADIO_KEY_EXPLORATION = RADIO_CHANNEL_EXPLORATION,
	RADIO_KEY_SERVICE = RADIO_CHANNEL_SERVICE,

	// Faction
	RADIO_KEY_SYNDICATE = RADIO_CHANNEL_SYNDICATE,
	RADIO_KEY_CENTCOM = RADIO_CHANNEL_CENTCOM,

	// Admin
	MODE_KEY_ADMIN = MODE_ADMIN,
	MODE_KEY_DEADMIN = MODE_DEADMIN,

	// Misc
	RADIO_KEY_AI_PRIVATE = RADIO_CHANNEL_AI_PRIVATE, // AI Upload channel


	//kinda localization -- rastaf0
	//same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	// Location
	"r" = MODE_R_HAND,
	"l" = MODE_L_HAND,
	"i" = MODE_INTERCOM,

	// Department
	"h" = MODE_DEPARTMENT,
	"c" = RADIO_CHANNEL_COMMAND,
	"n" = RADIO_CHANNEL_SCIENCE,
	"m" = RADIO_CHANNEL_MEDICAL,
	"e" = RADIO_CHANNEL_ENGINEERING,
	"s" = RADIO_CHANNEL_SECURITY,
	"u" = RADIO_CHANNEL_SUPPLY,
	"v" = RADIO_CHANNEL_SERVICE,
	"q" = RADIO_CHANNEL_EXPLORATION,

	// Faction
	"t" = RADIO_CHANNEL_SYNDICATE,
	"y" = RADIO_CHANNEL_CENTCOM,

	// Admin
	"p" = MODE_ADMIN,
	"d" = MODE_DEADMIN,

	// Misc
	"o" = RADIO_CHANNEL_AI_PRIVATE
))

/**
 * Whitelist of saymodes or radio extensions that can be spoken through even if not fully conscious.
 * Associated values are their maximum allowed mob stats.
 */
GLOBAL_LIST_INIT(message_modes_stat_limits, list(
	MODE_INTERCOM = HARD_CRIT,
	MODE_ALIEN = HARD_CRIT,
	MODE_BINARY = HARD_CRIT, //extra stat check on human/binarycheck()
	MODE_MONKEY = HARD_CRIT,
	MODE_MAFIA = HARD_CRIT
))

/mob/living/proc/Ellipsis(original_msg, chance = 50, keep_words)
	if(chance <= 0)
		return "..."
	if(chance >= 100)
		return original_msg

	var/list/words = splittext(original_msg," ")
	var/list/new_words = list()

	var/new_msg = ""

	for(var/w in words)
		if(prob(chance))
			new_words += "..."
			if(!keep_words)
				continue
		new_words += w

	new_msg = jointext(new_words," ")

	return new_msg

/mob/living/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language = null,
	ignore_spam = FALSE,
	forced,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	var/ic_blocked = FALSE
	if(client && !forced && CHAT_FILTER_CHECK(message))
		//The filter doesn't act on the sanitized message, but the raw message.
		ic_blocked = TRUE

	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return
	if(ic_blocked)
		//The filter warning message shows the sanitized message though.
		to_chat(src, span_warning("Your message was blocked\n<span replaceRegex='show_filtered_ic_chat'>\"[message]\"</span>."))
		SSblackbox.record_feedback("tally", "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return

	var/original_message = message
	message = get_message_mods(message, message_mods)
	saymode = SSradio.saymodes[message_mods[RADIO_KEY]]

	if(!message)
		return

	if(message_mods[RADIO_EXTENSION] == MODE_ADMIN)
		client?.cmd_admin_say(message)
		return

	if(message_mods[RADIO_EXTENSION] == MODE_DEADMIN)
		client?.dsay(message)
		return

	// dead is the only state you can never emote
	if(stat != DEAD && check_emote(original_message, forced))
		return

	// Checks if the saymode or channel extension can be used even if not totally conscious.
	var/say_radio_or_mode = saymode || message_mods[RADIO_EXTENSION]
	if(say_radio_or_mode)
		var/mob_stat_limit = GLOB.message_modes_stat_limits[say_radio_or_mode]
		if(stat > (isnull(mob_stat_limit) ? CONSCIOUS : mob_stat_limit))
			saymode = null
			message_mods -= RADIO_EXTENSION

	switch(stat)
		if(SOFT_CRIT)
			message_mods[WHISPER_MODE] = MODE_WHISPER
		if(UNCONSCIOUS)
			return
		if(HARD_CRIT)
			if(!message_mods[WHISPER_MODE])
				return
		if(DEAD)
			say_dead(original_message)
			return
/*
	if(client && SSlag_switch.measures[SLOWMODE_SAY] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES) && !forced && src == usr)
		if(!COOLDOWN_FINISHED(client, say_slowmode))
			to_chat(src, span_warning("Message blocked by lagswitch. Please wait [SSlag_switch.slowmode_cooldown/10] seconds before sending new message.\n\"[message]\""))
			return
		COOLDOWN_START(client, say_slowmode, SSlag_switch.slowmode_cooldown)
*/
	if(!can_speak_basic(original_message, ignore_spam, forced))
		return

	language = message_mods[LANGUAGE_EXTENSION]

	if(!language)
		language = get_selected_language()
	var/mob/living/carbon/human/H = src
	if(!can_speak_vocal(message))
		if (HAS_TRAIT(src, TRAIT_SIGN_LANG) && H.mind.miming)
			to_chat(src, span_warning("You cannot sing!"))
			return
		else
			to_chat(src, span_warning("You cannot speak!"))
			return

	var/succumbed = FALSE

	if(message_mods[WHISPER_MODE] == MODE_WHISPER)
		message_range = 1
		log_talk(message, LOG_WHISPER, forced_by = forced)
		if(stat == HARD_CRIT)
			var/health_diff = round(-HEALTH_THRESHOLD_DEAD + health)
			// If we cut our message short, abruptly end it with a-..
			var/message_len = length_char(message)
			message = copytext_char(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
			message = Ellipsis(message, 10, 1)
			last_words = message
			message_mods[WHISPER_MODE] = MODE_WHISPER_CRIT
			succumbed = TRUE
	else
		log_talk(message, LOG_SAY, forced_by = forced)

	message = treat_message(message) // unfortunately we still need this
	var/sigreturn = SEND_SIGNAL(src, COMSIG_MOB_SAY, args)
	if (sigreturn & COMPONENT_UPPERCASE_SPEECH)
		message = uppertext(message)
	if(!message)
		return

	spans |= speech_span

	if(language)
		var/datum/language/L = GLOB.language_datum_instances[language]
		spans |= L.spans

	if(message_mods[MODE_SING])
		var/randomnote = pick("\u2669", "\u266A", "\u266B")
		message = "[randomnote] [message] [randomnote]"
		spans |= SPAN_SINGING

	//This is before anything that sends say a radio message, and after all important message type modifications, so you can scumb in alien chat or something
	if(saymode && !saymode.handle_message(src, message, language))
		return
	var/radio_message = message
	if(message_mods[WHISPER_MODE])
		// radios don't pick up whispers very well
		radio_message = stars(radio_message)
		spans |= SPAN_ITALICS

	send_speech(message, message_range, src, bubble_type, spans, language, message_mods, forced = forced)//roughly 58% of living/say()'s total cost

	if(succumbed)
		succumb(1)
		to_chat(src, compose_message(src, language, message, null, spans, message_mods))

	return TRUE

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)
	if(!client)
		return

	var/deaf_message
	var/deaf_type

	if(HAS_TRAIT(speaker, TRAIT_SIGN_LANG)) //Checks if speaker is using sign language
		deaf_message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)
		if(speaker != src)
			if(!radio_freq) //I'm about 90% sure there's a way to make this less cluttered
				deaf_type = 1
		else
			deaf_type = 2

		// Create map text prior to modifying message for goonchat, sign lang edition
		if (client?.prefs.chat_on_map && !(stat == UNCONSCIOUS || stat == HARD_CRIT || is_blind(src)) && (client.prefs.see_chat_non_mob || ismob(speaker)))
			create_chat_message(speaker, message_language, raw_message, spans)

		if(is_blind(src))
			return FALSE

		message = deaf_message

		show_message(message, MSG_VISUAL, deaf_message, deaf_type, avoid_highlighting = speaker == src)
		return message

	if(speaker != src)
		if(!radio_freq) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[capitalize(speaker.name)]</span> [speaker.verb_say] but you can't understand [speaker.p_them()]."
			deaf_type = 1
	else
		deaf_message = span_notice("You say something but can't hear yourself!")
		deaf_type = 2 // Since you should be able to hear yourself without looking

	// Create map text prior to modifying message for goonchat
	if (client?.prefs.chat_on_map && !(stat == UNCONSCIOUS || stat == HARD_CRIT) && (client.prefs.see_chat_non_mob || ismob(speaker)) && can_hear())
		create_chat_message(speaker, message_language, raw_message, spans)

	// Recompose message for AI hrefs, language incomprehension.
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)

	show_message(message, MSG_AUDIBLE, deaf_message, deaf_type, avoid_highlighting = speaker == src)
	return message

/mob/living/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans = list(), datum/language/message_language = null, list/message_mods = list(), forced = null)
	var/eavesdrop_range = 0
	var/list/listening = get_hearers_in_view(message_range+eavesdrop_range, source)
	var/list/the_dead = list()
	if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
		var/mob/living/carbon/mute = src
		if(istype(mute))
			var/empty_indexes = get_empty_held_indexes() //How many hands the player has empty
			if(length(empty_indexes) == 1 || !mute.get_bodypart(BODY_ZONE_L_ARM) || !mute.get_bodypart(BODY_ZONE_R_ARM))
				message = stars(message)
			if(length(empty_indexes) == 0 || (length(empty_indexes) < 2 && (!mute.get_bodypart(BODY_ZONE_L_ARM) || !mute.get_bodypart(BODY_ZONE_R_ARM))))//All existing hands full, can't sign
				mute.visible_message("tries to sign, but can't with [src.p_their()] hands full!</span.?>", visible_message_flags = EMOTE_MESSAGE)
				return FALSE
			if(!mute.get_bodypart(BODY_ZONE_L_ARM) && !mute.get_bodypart(BODY_ZONE_R_ARM))//Can't sign with no arms!
				to_chat(src, "<span class='warning'>You can't sign with no hands!</span.?>")
				return FALSE
			if(mute.handcuffed)//Can't sign when your hands are cuffed, but can at least make a visual effort to
				mute.visible_message("tries to sign, but can't with [src.p_their()] hands bound!</span.?>", visible_message_flags = EMOTE_MESSAGE)
				return FALSE
			if(HAS_TRAIT(mute, TRAIT_HANDS_BLOCKED) || HAS_TRAIT(mute, TRAIT_EMOTEMUTE))
				to_chat(src, "<span class='warning'>You can't sign at the moment!</span.?>")
				return FALSE

	if(client) //client is so that ghosts don't have to listen to mice
		for(var/_M in GLOB.player_list)
			var/mob/M = _M
			if(QDELETED(M))	//Some times nulls and deleteds stay in this list. This is a workaround to prevent ic chat breaking for everyone when they do.
				continue	//Remove if underlying cause (likely byond issue) is fixed. See TG PR #49004.
			if(M.stat != DEAD) //not dead, not important
				continue
			if(get_dist(M, src) > 7 || M.z != z) //they're out of range of normal hearing
				if(eavesdrop_range)
					if(!(M.client.prefs?.chat_toggles & CHAT_GHOSTWHISPER)) //they're whispering and we have hearing whispers at any range off
						continue
				else if(!(M.client.prefs?.chat_toggles & CHAT_GHOSTEARS)) //they're talking normally and we have hearing at any range off
					continue
			listening |= M
			the_dead[M] = TRUE

	var/eavesdropping
	var/eavesrendered
	if(eavesdrop_range)
		eavesdropping = stars(message)
		eavesrendered = compose_message(src, message_language, eavesdropping, null, spans, message_mods)

	var/rendered = compose_message(src, message_language, message, null, spans, message_mods)
	for(var/_AM in listening)
		var/atom/movable/AM = _AM
		if(eavesdrop_range && get_dist(source, AM) > message_range && !(the_dead[AM]))
			AM.Hear(eavesrendered, src, message_language, eavesdropping, null, spans, message_mods)
		else
			AM.Hear(rendered, src, message_language, message, null, spans, message_mods)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_LIVING_SAY_SPECIAL, src, message)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client || (SSlag_switch.measures[DISABLE_RUNECHAT] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES)))
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type][say_test(message)]", FLY_LAYER)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), I, speech_bubble_recipients, 30)

/mob/proc/binarycheck()
	return FALSE

/mob/living/can_speak(message) //For use outside of Say()
	if(can_speak_basic(message) && can_speak_vocal(message))
		return TRUE

/mob/living/proc/can_speak_basic(message, ignore_spam = FALSE, forced = FALSE) //Check BEFORE handling of xeno and ling channels
	if(client && !(ignore_spam || forced))
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, span_danger("You cannot speak in IC (muted)."))
			return FALSE
		if(client.handle_spam_prevention(message, MUTE_IC))
			return FALSE

	return TRUE

/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	var/mob/living/carbon/human/H = src
	if(HAS_TRAIT(src, TRAIT_MUTE))
		return (HAS_TRAIT(src, TRAIT_SIGN_LANG) && !H.mind.miming) //Makes sure mimes can't speak using sign language

	if(is_muzzled())
		return (HAS_TRAIT(src, TRAIT_SIGN_LANG) && !H.mind.miming)

	if(!IsVocal())
		return (HAS_TRAIT(src, TRAIT_SIGN_LANG) && !H.mind.miming)

	return TRUE



/mob/living/proc/treat_message(message)

	if(HAS_TRAIT(src, TRAIT_UNINTELLIGIBLE_SPEECH))
		message = unintelligize(message)

	if(derpspeech)
		message = derpspeech(message, stuttering)

	if(stuttering)
		message = stutter(message)

	if(slurring)
		message = slur(message)

	if(hydration <= HYDRATION_LEVEL_DEHYDRATED)
		message = thirstymessage(message)

	if(client?.prefs?.disabled_autocap)
		message = message
	else
		message = capitalize(message)

	return message

/mob/living/say_mod(input, list/message_mods = list())
	if(message_mods[WHISPER_MODE] == MODE_WHISPER)
		. = verb_whisper
	else if(message_mods[WHISPER_MODE] == MODE_WHISPER_CRIT)
		. = "[verb_whisper] last breath"
	else if(message_mods[MODE_SING])
		. = verb_sing
	else if(stuttering)
		if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
			. = "shakingly sings"
		else
			. = "stammers"
	else if(derpspeech)
		if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
			. = "incoherently sings"
		else
			. = "gibbers"
	else
		. = ..()

/mob/living/whisper(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced)
	if(!message)
		return
	say("#[message]", bubble_type, spans, sanitize, language, ignore_spam, forced)

/mob/living/get_language_holder(get_minds = TRUE)
	if(get_minds && mind)
		return mind.get_language_holder()
	. = ..()
