/obj/item/sconce
	name = "sconce"
	desc = "Can be attached to a wall."
	icon = 'dwarfs/icons/items/components.dmi'
	icon_state = "sconce"
	w_class = WEIGHT_CLASS_SMALL
	var/result_path = /obj/structure/sconce

/obj/item/sconce/proc/try_build(turf/on_wall, mob/user)
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinals))
		return
	if(locate(/obj/structure/sconce) in view(1))
		to_chat(user, span_warning("There is something already attached to [on_wall]!"))
		return

	return TRUE

/obj/item/sconce/proc/attach(turf/on_wall, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
		user.visible_message(span_notice("[user.name] attaches [src] to the wall."), \
			span_notice("You attach the handle to the wall."), span_hear("You hear a metal click."))
		var/ndir = get_dir(on_wall, user)

		new result_path(get_turf(user), ndir)
	qdel(src)

/obj/item/sconce/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(isclosedturf(target))
		var/turf/closed/W = target
		W.try_wallmount(src, user)

/obj/structure/sconce
	name = "sconce"
	desc = "A small fixture that can hold torches."
	icon = 'dwarfs/icons/structures/wall_mount.dmi'
	icon_state = "sconce_empty"
	layer = BELOW_MOB_LAYER
	max_integrity = 100
	var/light_range_boost = 5
	var/obj/item/flashlight/fueled/torch/torch
	var/obj/item/stack/sheet/mineral/gem/glowgem

/obj/structure/sconce/Initialize(mapload, ndir=null)
	. = ..()
	if(ndir)
		dir = ndir
	switch(dir)
		if(WEST)	pixel_x = 32
		if(EAST)	pixel_x = -32
		if(SOUTH)	pixel_y = 32

/obj/structure/sconce/lit
	icon_state = "sconce_on"

/obj/structure/sconce/lit/Initialize(mapload, ndir)
	. = ..()
	torch = new /obj/item/flashlight/fueled/torch/lit(src)
	update_appearance()

/obj/structure/sconce/update_icon_state()
	. = ..()
	if(!torch && !glowgem)
		icon_state = "sconce_empty"
		return;
	if (torch)
		if(torch.on)
			icon_state = "sconce_on"
			return
		if(torch.fuel)
			icon_state = "sconce_off"
			return
		icon_state = "sconce_burned"
		return
	if (glowgem)
		icon_state = "sconce_glowgem"

/obj/structure/sconce/update_appearance(updates)
	. = ..()
	_update_light()

/obj/structure/sconce/proc/_update_light()
	if(torch)
		if(torch.on)
			set_light(torch.light_range+light_range_boost, torch.light_power, torch.light_color)
			return
	if(glowgem)
		set_light(glowgem.light_range+light_range_boost, glowgem.light_power, glowgem.light_color)
		return
	set_light(0, 0, 0)


/obj/structure/sconce/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/flashlight/fueled/torch))
		if(torch)
			to_chat(user, span_warning("There is a torch already!"))
			return
		if(glowgem)
			to_chat(user, span_warning("There is a glowgem already!"))
			return
		src.add_fingerprint(user)
		var/obj/item/flashlight/fueled/torch/L = W
		if(!user.temporarilyRemoveItemFromInventory(L))
			return
		src.add_fingerprint(user)
		to_chat(user, span_notice("You place [L] inside."))
		torch = L
		L.forceMove(src)
		update_appearance()
	else if(istype(W, /obj/item/stack/sheet/mineral/gem/glowgem))
		if(torch)
			to_chat(user, span_warning("There is a torch already!"))
			return
		if(glowgem)
			to_chat(user, span_warning("There is a glowgem already!"))
			return
		src.add_fingerprint(user)
		var/obj/item/stack/sheet/mineral/gem/glowgem/L = W
		if(!user.temporarilyRemoveItemFromInventory(L))
			return
		src.add_fingerprint(user)
		to_chat(user, span_notice("You place [L] inside."))
		glowgem = L
		L.forceMove(src)
		update_appearance()
	else
		return ..()

/obj/structure/sconce/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(torch)
		torch.add_fingerprint(user)
		user.put_in_active_hand(torch)
		torch = null
		update_appearance()
		return
	else if(glowgem)
		glowgem.add_fingerprint(user)
		user.put_in_active_hand(glowgem)
		glowgem = null
		update_appearance()
		return
	to_chat(user, span_warning("There is no torch or glowgem!"))

