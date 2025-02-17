/obj/item/food/dish
	var/plate_type

/obj/item/food/dish/on_consume(mob/living/eater, mob/living/feeder)
	. = ..()
	if(plate_type)
		var/mob/living/carbon/human/H = feeder
		var/held_index = H.is_holding(src)
		if(held_index)
			var/obj/item/I = new plate_type
			qdel(src)
			H.put_in_hand(I, held_index)
		else
			new plate_type(get_turf(feeder))

//**********************FIRST TIER DISHES*****************************//
/obj/item/food/dish/plump_with_steak
	name = "plump with steak"
	desc = "A simple dish containing all essential vitamins for a dwarf."
	icon_state = "plump_n_steak"
	plate_type = /obj/item/reagent_containers/glass/plate/regular
	food_reagents = list(/datum/reagent/consumable/nutriment=150)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/plump_skewer
	name = "plump skewer"
	desc = "Quick snack, not really nutritious."
	icon_state = "plump_kebab"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=50)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/crab_leg_skewer
	name = "crab leg skewer"
	desc = "A whole roasted leg of crab."
	icon_state = "crab_leg_skewer"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=50)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/meat_skewer
	name = "steak skewer"
	desc = "A steak on its own. Tastes of soot. Could do with some plump helmets."
	icon_state = "meat_skewer"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=100)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/meat_slice_skewer
	name = "meat skewer"
	desc = "The chef is definitely trying to make food stretch... Better than nothing."
	icon_state = "meatslice1_skewer"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=25)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/meat_slice_skewer_2
	name = "half meat skewer"
	desc = "The chef is definitely trying to make food stretch... At least it's filling."
	icon_state = "meatslice2_skewer"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=50)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/meat_slice_skewer_3
	name = "tripple meat skewer"
	desc = "The chef is definitely trying to make food stretch... I would still rather have a steak. This seems wasteful!"
	icon_state = "meatslice3_skewer"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=100)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/meat_slice_skewer_4
	name = "full meat skewer"
	desc = "More meat than a whole steak, but its dry and flavorless. Are we out of plump helmets?"
	icon_state = "meatslice4_skewer"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=125)
	mood_event_type = /datum/mood_event/ate_meal

/obj/item/food/dish/salad
	name = "salad"
	desc = "Eat your veggies, son."
	icon_state = "salad"
	plate_type = /obj/item/reagent_containers/glass/plate/bowl
	food_reagents = list(/datum/reagent/consumable/nutriment=150)
	mood_event_type = /datum/mood_event/ate_meal

//**********************SECOND TIER DISHES*****************************//

/obj/item/food/dish/dwarven_stew
	name = "dwarven stew"
	desc = "A simple yet tasteful stew that dwarves would cook in their hold."
	icon_state = "dwarven_stew"
	plate_type = /obj/item/reagent_containers/glass/plate/bowl
	food_reagents = list(/datum/reagent/consumable/nutriment=250)
	mood_event_type = /datum/mood_event/ate_meal/decent

/obj/item/food/dish/plump_pie
	name = "plump pie"
	desc = "Mushroom pie. A bit weird combination, but dwarves like it."
	icon_state = "plump_pie"
	plate_type = /obj/item/reagent_containers/glass/plate/bowl
	food_reagents = list(/datum/reagent/consumable/nutriment=250)
	mood_event_type = /datum/mood_event/ate_meal/decent

/obj/item/food/dish/beer_wurst
	name = "roasted beer wurst"
	desc = "Ich liebe dich."
	icon_state = "beer_wurst"
	plate_type = /obj/item/reagent_containers/glass/plate/regular
	food_reagents = list(/datum/reagent/consumable/nutriment=250)
	mood_event_type = /datum/mood_event/ate_meal/decent

/obj/item/food/dish/crab_cake
	name = "crab cakes"
	desc = "Steamed crab cakes. Get 'em while they're hot!"
	icon_state = "crab_cakes"
	plate_type = /obj/item/reagent_containers/glass/plate/regular
	food_reagents = list(/datum/reagent/consumable/nutriment=250)
	mood_event_type = /datum/mood_event/ate_meal/decent

/obj/item/food/dish/crab_claw_skewer
	name = "crab claw skewer"
	desc = "A savorey, smokey, and sweet tasting meat. Best eaten on its own."
	icon_state = "crab_claw_skewer"
	plate_type = /obj/item/stick
	food_reagents = list(/datum/reagent/consumable/nutriment=250)
	mood_event_type = /datum/mood_event/ate_meal/decent

//**********************THIRD TIER DISHES*****************************//

/obj/item/food/dish/balanced_roll
	name = "balanced roll"
	desc = "Coming from the eastern human cities, this dish became popular among dwarves."
	icon_state = "gyros"
	plate_type = /obj/item/reagent_containers/glass/plate/flat
	food_reagents = list(/datum/reagent/consumable/nutriment=300)
	mood_event_type = /datum/mood_event/ate_meal/luxurious

/obj/item/food/dish/trolls_delight
	name = "troll's delight"
	desc = "A decadent dish, fit for a king's feast."
	icon_state = "trolls_delight"
	plate_type = /obj/item/reagent_containers/glass/plate/flat
	food_reagents = list(/datum/reagent/consumable/nutriment=300)
	mood_event_type = /datum/mood_event/ate_meal/luxurious

/obj/item/food/dish/allwurst
	name = "allwurst"
	desc = "Not sure whose wicked brain made this recipe, but it seems not poisonous."
	icon_state = "allwurst"
	plate_type = /obj/item/reagent_containers/glass/plate/regular
	food_reagents = list(/datum/reagent/consumable/nutriment=300)
	mood_event_type = /datum/mood_event/ate_meal/luxurious
