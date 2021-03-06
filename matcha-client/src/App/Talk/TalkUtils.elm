module App.Talk.TalkUtils exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (..)
import App.Talk.TalkModel exposing (..)


updateTalks : TalksModel -> Talk -> TalksModel
updateTalks model talk =
    let
      newTalks =
            if List.any (\t -> t.username_with == talk.username_with) model.talks then
                List.map
                    (\t ->
                        if talk.username_with == t.username_with then
                            talk
                        else
                            t
                    )
                    model.talks
            else
                talk :: model.talks
    in
      { model | talks = newTalks }

getTalkWith : String -> List Talk -> Maybe Talk
getTalkWith username talks =
    List.head <| List.filter (\t -> t.username_with == username) talks


getTalkNotif : List Talk -> Int
getTalkNotif talks =
    List.sum <| List.map .unreadMsgs talks


emoticon : String -> Html Msg
emoticon em =
    i [ class <| "em " ++ em ] []


emoToString : String -> String
emoToString em =
    "::__" ++ em ++ "__::"


emoticonList : List String
emoticonList =
    [ "em-a", "em-ab", "em-abc", "em-abcd", "em-accept", "em-admission_tickets", "em-adult", "em-aerial_tramway", "em-airplane", "em-airplane_arriving", "em-airplane_departure", "em-alarm_clock", "em-alembic", "em-alien", "em-ambulance", "em-amphora", "em-anchor", "em-angel", "em-anger", "em-angry", "em-anguished", "em-ant", "em-apple", "em-aquarius", "em-aries", "em-arrow_backward", "em-arrow_double_down", "em-arrow_double_up", "em-arrow_down", "em-arrow_down_small", "em-arrow_forward", "em-arrow_heading_down", "em-arrow_heading_up", "em-arrow_left", "em-arrow_lower_left", "em-arrow_lower_right", "em-arrow_right", "em-arrow_right_hook", "em-arrow_up", "em-arrow_up_down", "em-arrow_up_small", "em-arrow_upper_left", "em-arrow_upper_right", "em-arrows_clockwise", "em-arrows_counterclockwise", "em-art", "em-articulated_lorry", "em-astonished", "em-athletic_shoe", "em-atm", "em-atom_symbol", "em-avocado", "em-b", "em-baby", "em-baby_bottle", "em-baby_chick", "em-baby_symbol", "em-back", "em-bacon", "em-badminton_racquet_and_shuttlecock", "em-baggage_claim", "em-baguette_bread", "em-balloon", "em-ballot_box_with_ballot", "em-ballot_box_with_check", "em-bamboo", "em-banana", "em-bangbang", "em-bank", "em-bar_chart", "em-barber", "em-barely_sunny", "em-baseball", "em-basketball", "em-bat", "em-bath", "em-bathtub", "em-battery", "em-beach_with_umbrella", "em-bear", "em-bearded_person", "em-bed", "em-bee", "em-beer", "em-beers", "em-beetle", "em-beginner", "em-bell", "em-bellhop_bell", "em-bento", "em-bicyclist", "em-bike", "em-bikini", "em-billed_cap", "em-biohazard_sign", "em-bird", "em-birthday", "em-black_circle", "em-black_circle_for_record", "em-black_heart", "em-black_joker", "em-black_large_square", "em-black_left_pointing_double_triangle_with_vertical_bar", "em-black_medium_small_square", "em-black_medium_square", "em-black_nib", "em-black_right_pointing_double_triangle_with_vertical_bar", "em-black_right_pointing_triangle_with_double_vertical_bar", "em-black_small_square", "em-black_square_button", "em-black_square_for_stop", "em-blossom", "em-blowfish", "em-blue_book", "em-blue_car", "em-blue_heart", "em-blush", "em-boar", "em-boat", "em-bomb", "em-book", "em-bookmark", "em-bookmark_tabs", "em-books", "em-boom", "em-boot", "em-bouquet", "em-bow", "em-bow_and_arrow", "em-bowl_with_spoon", "em-bowling", "em-boxing_glove", "em-boy", "em-brain", "em-bread", "em-bride_with_veil", "em-bridge_at_night", "em-briefcase", "em-broccoli", "em-broken_heart", "em-bug", "em-building_construction", "em-bulb", "em-bullettrain_front", "em-bullettrain_side", "em-burrito", "em-bus", "em-busstop", "em-bust_in_silhouette", "em-busts_in_silhouette", "em-butterfly", "em-cactus", "em-cake", "em-calendar", "em-call_me_hand", "em-calling", "em-camel", "em-camera", "em-camera_with_flash", "em-camping", "em-cancer", "em-candle", "em-candy", "em-canned_food", "em-canoe", "em-capital_abcd", "em-capricorn", "em-car", "em-card_file_box", "em-card_index", "em-card_index_dividers", "em-carousel_horse", "em-carrot", "em-cat", "em-cd", "em-chains", "em-champagne", "em-chart", "em-chart_with_downwards_trend", "em-chart_with_upwards_trend", "em-checkered_flag", "em-cheese_wedge", "em-cherries", "em-cherry_blossom", "em-chestnut", "em-chicken", "em-child", "em-children_crossing", "em-chipmunk", "em-chocolate_bar", "em-chopsticks", "em-christmas_tree", "em-church", "em-cinema", "em-circus_tent", "em-city_sunrise", "em-city_sunset", "em-cityscape", "em-cl", "em-clap", "em-clapper", "em-classical_building", "em-clinking_glasses", "em-clipboard", "em-clock", "em-closed_book", "em-closed_lock_with_key", "em-closed_umbrella", "em-cloud", "em-clown_face", "em-clubs", "em-cn", "em-coat", "em-cocktail", "em-coconut", "em-coffee", "em-coffin", "em-cold_sweat", "em-comet", "em-compression", "em-computer", "em-confetti_ball", "em-confounded", "em-confused", "em-congratulations", "em-construction", "em-construction_worker", "em-control_knobs", "em-convenience_store", "em-cookie", "em-cool", "em-cop", "em-copyright", "em-corn", "em-couch_and_lamp", "em-couple", "em-couple_with_heart", "em-couplekiss", "em-cow", "em-crab", "em-credit_card", "em-crescent_moon", "em-cricket", "em-cricket_bat_and_ball", "em-crocodile", "em-croissant", "em-crossed_flags", "em-crossed_swords", "em-crown", "em-cry", "em-crying_cat_face", "em-crystal_ball", "em-cucumber", "em-cup_with_straw", "em-cupid", "em-curling_stone", "em-curly_loop", "em-currency_exchange", "em-curry", "em-custard", "em-customs", "em-cut_of_meat", "em-cyclone", "em-dagger_knife", "em-dancer", "em-dancers", "em-dango", "em-dark_sunglasses", "em-dart", "em-dash", "em-date", "em-de", "em-deciduous_tree", "em-deer", "em-department_store", "em-derelict_house_building", "em-desert", "em-desert_island", "em-desktop_computer", "em-diamond_shape_with_a_dot_inside", "em-diamonds", "em-disappointed", "em-disappointed_relieved", "em-dizzy", "em-dizzy_face", "em-do_not_litter", "em-dog", "em-dollar", "em-dolls", "em-dolphin", "em-door", "em-double_vertical_bar", "em-doughnut", "em-dove_of_peace", "em-dragon", "em-dragon_face", "em-dress", "em-dromedary_camel", "em-drooling_face", "em-droplet", "em-drum_with_drumsticks", "em-duck", "em-dumpling", "em-dvd", "em-eagle", "em-ear", "em-ear_of_rice", "em-earth_africa", "em-earth_americas", "em-earth_asia", "em-egg", "em-eggplant", "em-eight", "em-eight_pointed_black_star", "em-eight_spoked_asterisk", "em-eject", "em-electric_plug", "em-elephant", "em-elf", "em-email", "em-end", "em-envelope_with_arrow", "em-es", "em-euro", "em-european_castle", "em-european_post_office", "em-evergreen_tree", "em-exclamation", "em-expressionless", "em-eye", "em-eyeglasses", "em-eyes", "em-face_palm", "em-face_with_cowboy_hat", "em-face_with_finger_covering_closed_lips", "em-face_with_head_bandage", "em-face_with_monocle", "em-face_with_one_eyebrow_raised", "em-face_with_open_mouth_vomiting", "em-face_with_rolling_eyes", "em-face_with_thermometer", "em-facepunch", "em-factory", "em-fairy", "em-fallen_leaf", "em-family", "em-fast_forward", "em-fax", "em-fearful", "em-feet", "em-female_elf", "em-female_fairy", "em-female_genie", "em-female_mage", "em-female_sign", "em-female_vampire", "em-female_zombie", "em-fencer" ]
        ++ [ "em-ferris_wheel", "em-ferry", "em-field_hockey_stick_and_ball", "em-file_cabinet", "em-file_folder", "em-film_frames", "em-film_projector", "em-fire", "em-fire_engine", "em-fireworks", "em-first_place_medal", "em-first_quarter_moon", "em-first_quarter_moon_with_face", "em-fish", "em-fish_cake", "em-fishing_pole_and_fish", "em-fist", "em-five", "em-flags", "em-flashlight", "em-fleur_de_lis", "em-floppy_disk", "em-flower_playing_cards", "em-flushed", "em-flying_saucer", "em-fog", "em-foggy", "em-football", "em-footprints", "em-fork_and_knife", "em-fortune_cookie", "em-fountain", "em-four", "em-four_leaf_clover", "em-fox_face", "em-fr", "em-frame_with_picture", "em-free", "em-fried_egg", "em-fried_shrimp", "em-fries", "em-frog", "em-frowning", "em-fuelpump", "em-full_moon", "em-full_moon_with_face", "em-funeral_urn", "em-game_die", "em-gb", "em-gear", "em-gem", "em-gemini", "em-genie", "em-ghost", "em-gift", "em-gift_heart", "em-giraffe_face", "em-girl", "em-glass_of_milk", "em-globe_with_meridians", "em-gloves", "em-goal_net", "em-goat", "em-golf", "em-golfer", "em-gorilla", "em-grapes", "em-green_apple", "em-green_book", "em-green_heart", "em-green_salad", "em-grey_exclamation", "em-grey_question", "em-grimacing", "em-grin", "em-grinning", "em-grinning_face_with_one_large_and_one_small_eye", "em-grinning_face_with_star_eyes", "em-guardsman", "em-guitar", "em-gun", "em-haircut", "em-hamburger", "em-hammer", "em-hammer_and_pick", "em-hammer_and_wrench", "em-hamster", "em-hand", "em-hand_with_index_and_middle_fingers_crossed", "em-handbag", "em-handball", "em-handshake", "em-hankey", "em-hash", "em-hatched_chick", "em-hatching_chick", "em-headphones", "em-hear_no_evil", "em-heart", "em-heart_decoration", "em-heart_eyes", "em-heart_eyes_cat", "em-heartbeat", "em-heartpulse", "em-hearts", "em-heavy_check_mark", "em-heavy_division_sign", "em-heavy_dollar_sign", "em-heavy_heart_exclamation_mark_ornament", "em-heavy_minus_sign", "em-heavy_multiplication_x", "em-heavy_plus_sign", "em-hedgehog", "em-helicopter", "em-helmet_with_white_cross", "em-herb", "em-hibiscus", "em-high_brightness", "em-high_heel", "em-hocho", "em-hole", "em-honey_pot", "em-horse", "em-horse_racing", "em-hospital", "em-hot_pepper", "em-hotdog", "em-hotel", "em-hotsprings", "em-hourglass", "em-hourglass_flowing_sand", "em-house", "em-house_buildings", "em-house_with_garden", "em-hugging_face", "em-hushed", "em-i_love_you_hand_sign", "em-ice_cream", "em-ice_hockey_stick_and_puck", "em-ice_skate", "em-icecream", "em-id", "em-ideograph_advantage", "em-imp", "em-inbox_tray", "em-incoming_envelope", "em-information_desk_person", "em-information_source", "em-innocent", "em-interrobang", "em-iphone", "em-it", "em-izakaya_lantern", "em-jack_o_lantern", "em-japan", "em-japanese_castle", "em-japanese_goblin", "em-japanese_ogre", "em-jeans", "em-joy", "em-joy_cat", "em-joystick", "em-jp", "em-juggling", "em-kaaba", "em-key", "em-keyboard", "em-keycap_star", "em-keycap_ten", "em-kimono", "em-kiss", "em-kissing", "em-kissing_cat", "em-kissing_closed_eyes", "em-kissing_heart", "em-kissing_smiling_eyes", "em-kiwifruit", "em-knife_fork_plate", "em-koala", "em-koko", "em-kr", "em-label", "em-large_blue_circle", "em-large_blue_diamond", "em-large_orange_diamond", "em-last_quarter_moon", "em-last_quarter_moon_with_face", "em-latin_cross", "em-laughing", "em-leaves", "em-ledger", "em-left_luggage", "em-left_right_arrow", "em-left_speech_bubble", "em-leftwards_arrow_with_hook", "em-lemon", "em-leo", "em-leopard", "em-level_slider", "em-libra", "em-light_rail", "em-lightning", "em-link", "em-linked_paperclips", "em-lion_face", "em-lips", "em-lipstick", "em-lizard", "em-lock", "em-lock_with_ink_pen", "em-lollipop", "em-loop", "em-loud_sound", "em-loudspeaker", "em-love_hotel", "em-love_letter", "em-low_brightness", "em-lower_left_ballpoint_pen", "em-lower_left_crayon", "em-lower_left_fountain_pen", "em-lower_left_paintbrush", "em-lying_face", "em-m", "em-mag", "em-mag_right", "em-mage", "em-mahjong", "em-mailbox", "em-mailbox_closed", "em-mailbox_with_mail", "em-mailbox_with_no_mail", "em-male_elf", "em-male_fairy", "em-male_genie", "em-male_mage", "em-male_sign", "em-male_vampire", "em-male_zombie", "em-man", "em-man_climbing", "em-man_dancing", "em-man_in_business_suit_levitating", "em-man_in_lotus_position", "em-man_in_steamy_room", "em-man_in_tuxedo", "em-man_with_gua_pi_mao", "em-man_with_turban", "em-mans_shoe", "em-mantelpiece_clock", "em-maple_leaf", "em-martial_arts_uniform", "em-mask", "em-massage", "em-meat_on_bone", "em-medal", "em-mega", "em-melon", "em-memo", "em-menorah_with_nine_branches", "em-mens", "em-mermaid", "em-merman", "em-merperson", "em-metro", "em-microphone", "em-microscope", "em-middle_finger", "em-milky_way", "em-minibus", "em-minidisc", "em-mobile_phone_off", "em-money_mouth_face", "em-money_with_wings", "em-moneybag", "em-monkey", "em-monkey_face", "em-monorail", "em-moon", "em-mortar_board", "em-mosque", "em-mostly_sunny", "em-mother_christmas", "em-motor_boat", "em-motor_scooter", "em-motorway", "em-mount_fuji", "em-mountain", "em-mountain_bicyclist", "em-mountain_cableway", "em-mountain_railway", "em-mouse", "em-movie_camera", "em-moyai", "em-muscle", "em-mushroom", "em-musical_keyboard", "em-musical_note", "em-musical_score", "em-mute", "em-nail_care", "em-name_badge", "em-national_park", "em-nauseated_face", "em-necktie", "em-negative_squared_cross_mark", "em-nerd_face", "em-neutral_face", "em-new", "em-new_moon", "em-new_moon_with_face", "em-newspaper", "em-ng", "em-night_with_stars", "em-nine", "em-no_bell", "em-no_bicycles", "em-no_entry", "em-no_entry_sign", "em-no_good", "em-no_mobile_phones", "em-no_mouth", "em-no_pedestrians", "em-no_smoking", "em-nose", "em-notebook", "em-notebook_with_decorative_cover", "em-notes", "em-nut_and_bolt", "em-o", "em-ocean", "em-octagonal_sign", "em-octopus", "em-oden", "em-office", "em-oil_drum", "em-ok", "em-ok_hand", "em-ok_woman", "em-old_key", "em-older_adult", "em-older_man", "em-older_woman", "em-om_symbol", "em-on", "em-oncoming_automobile", "em-oncoming_bus", "em-oncoming_police_car", "em-oncoming_taxi", "em-one", "em-open_file_folder", "em-open_hands", "em-open_mouth", "em-ophiuchus", "em-orange_book", "em-orange_heart", "em-orthodox_cross", "em-outbox_tray", "em-owl", "em-ox", "em-package", "em-page_facing_up", "em-page_with_curl", "em-pager", "em-palm_tree", "em-palms_up_together", "em-pancakes", "em-panda_face", "em-paperclip", "em-parking", "em-part_alternation_mark", "em-partly_sunny", "em-partly_sunny_rain", "em-passenger_ship", "em-passport_control", "em-peace_symbol", "em-peach", "em-peanuts", "em-pear", "em-penguin", "em-pensive", "em-performing_arts", "em-persevere", "em-person_climbing", "em-person_doing_cartwheel", "em-person_frowning" ]
        ++ [ "em-person_in_lotus_position"
           , "em-person_in_steamy_room"
           , "em-person_with_ball"
           , "em-person_with_blond_hair"
           , "em-person_with_headscarf"
           , "em-person_with_pouting_face"
           , "em-phone"
           , "em-pick"
           , "em-pie"
           , "em-pig"
           , "em-pig_nose"
           , "em-pill"
           , "em-pineapple"
           , "em-pisces"
           , "em-pizza"
           , "em-place_of_worship"
           , "em-point_down"
           , "em-point_left"
           , "em-point_right"
           , "em-point_up"
           , "em-police_car"
           , "em-poodle"
           , "em-popcorn"
           , "em-post_office"
           , "em-postal_horn"
           , "em-postbox"
           , "em-potable_water"
           , "em-potato"
           , "em-pouch"
           , "em-poultry_leg"
           , "em-pound"
           , "em-pouting_cat"
           , "em-pray"
           , "em-prayer_beads"
           , "em-pregnant_woman"
           , "em-pretzel"
           , "em-prince"
           , "em-princess"
           , "em-printer"
           , "em-purple_heart"
           , "em-purse"
           , "em-pushpin"
           , "em-put_litter_in_its_place"
           , "em-question"
           , "em-rabbit"
           , "em-racehorse"
           , "em-racing_car"
           , "em-racing_motorcycle"
           , "em-radio"
           , "em-radio_button"
           , "em-radioactive_sign"
           , "em-rage"
           , "em-railway_car"
           , "em-railway_track"
           , "em-rain_cloud"
           , "em-rainbow"
           , "em-raised_back_of_hand"
           , "em-raised_hand_with_fingers_splayed"
           , "em-raised_hands"
           , "em-raising_hand"
           , "em-ram"
           , "em-ramen"
           , "em-rat"
           , "em-recycle"
           , "em-red_circle"
           , "em-registered"
           , "em-relaxed"
           , "em-relieved"
           , "em-reminder_ribbon"
           , "em-repeat"
           , "em-repeat_one"
           , "em-restroom"
           , "em-revolving_hearts"
           , "em-rewind"
           , "em-rhinoceros"
           , "em-ribbon"
           , "em-rice"
           , "em-rice_ball"
           , "em-rice_cracker"
           , "em-rice_scene"
           , "em-right_anger_bubble"
           , "em-ring"
           , "em-robot_face"
           , "em-rocket"
           , "em-rolled_up_newspaper"
           , "em-roller_coaster"
           , "em-rolling_on_the_floor_laughing"
           , "em-rooster"
           , "em-rose"
           , "em-rosette"
           , "em-rotating_light"
           , "em-round_pushpin"
           , "em-rowboat"
           , "em-ru"
           , "em-rugby_football"
           , "em-runner"
           , "em-running_shirt_with_sash"
           , "em-sa"
           , "em-sagittarius"
           , "em-sake"
           , "em-sandal"
           , "em-sandwich"
           , "em-santa"
           , "em-satellite"
           , "em-satellite_antenna"
           , "em-sauropod"
           , "em-saxophone"
           , "em-scales"
           , "em-scarf"
           , "em-school"
           , "em-school_satchel"
           , "em-scissors"
           , "em-scooter"
           , "em-scorpion"
           , "em-scorpius"
           , "em-scream"
           , "em-scream_cat"
           , "em-scroll"
           , "em-seat"
           , "em-second_place_medal"
           , "em-secret"
           , "em-see_no_evil"
           , "em-seedling"
           , "em-selfie"
           , "em-serious_face_with_symbols_covering_mouth"
           , "em-seven"
           , "em-shallow_pan_of_food"
           , "em-shamrock"
           , "em-shark"
           , "em-shaved_ice"
           , "em-sheep"
           , "em-shell"
           , "em-shield"
           , "em-shinto_shrine"
           , "em-ship"
           , "em-shirt"
           , "em-shocked_face_with_exploding_head"
           , "em-shopping_bags"
           , "em-shopping_trolley"
           , "em-shower"
           , "em-shrimp"
           , "em-shrug"
           , "em-signal_strength"
           , "em-six"
           , "em-six_pointed_star"
           , "em-ski"
           , "em-skier"
           , "em-skull"
           , "em-skull_and_crossbones"
           , "em-sled"
           , "em-sleeping"
           , "em-sleeping_accommodation"
           , "em-sleepy"
           , "em-sleuth_or_spy"
           , "em-slightly_frowning_face"
           , "em-slightly_smiling_face"
           , "em-slot_machine"
           , "em-small_airplane"
           , "em-small_blue_diamond"
           , "em-small_orange_diamond"
           , "em-small_red_triangle"
           , "em-small_red_triangle_down"
           , "em-smile"
           , "em-smile_cat"
           , "em-smiley"
           , "em-smiley_cat"
           , "em-smiling_face_with_smiling_eyes_and_hand_covering_mouth"
           , "em-smiling_imp"
           , "em-smirk"
           , "em-smirk_cat"
           , "em-smoking"
           , "em-snail"
           , "em-snake"
           , "em-sneezing_face"
           , "em-snow_capped_mountain"
           , "em-snow_cloud"
           , "em-snowboarder"
           , "em-snowflake"
           , "em-snowman"
           , "em-snowman_without_snow"
           , "em-sob"
           , "em-soccer"
           , "em-socks"
           , "em-soon"
           , "em-sos"
           , "em-sound"
           , "em-space_invader"
           , "em-spades"
           , "em-spaghetti"
           , "em-sparkle"
           , "em-sparkler"
           , "em-sparkles"
           , "em-sparkling_heart"
           , "em-speak_no_evil"
           , "em-speaker"
           , "em-speaking_head_in_silhouette"
           , "em-speech_balloon"
           , "em-speedboat"
           , "em-spider"
           , "em-spider_web"
           , "em-spiral_calendar_pad"
           , "em-spiral_note_pad"
           , "em-spoon"
           , "em-sports_medal"
           , "em-squid"
           , "em-stadium"
           , "em-staff_of_aesculapius"
           , "em-star"
           , "em-star_and_crescent"
           , "em-star_of_david"
           , "em-stars"
           , "em-station"
           , "em-statue_of_liberty"
           , "em-steam_locomotive"
           , "em-stew"
           , "em-stopwatch"
           , "em-straight_ruler"
           , "em-strawberry"
           , "em-stuck_out_tongue"
           , "em-stuck_out_tongue_closed_eyes"
           , "em-stuck_out_tongue_winking_eye"
           , "em-studio_microphone"
           , "em-stuffed_flatbread"
           , "em-sun_with_face"
           , "em-sunflower"
           , "em-sunglasses"
           , "em-sunny"
           , "em-sunrise"
           , "em-sunrise_over_mountains"
           , "em-surfer"
           , "em-sushi"
           , "em-suspension_railway"
           , "em-sweat"
           , "em-sweat_drops"
           , "em-sweat_smile"
           , "em-sweet_potato"
           , "em-swimmer"
           , "em-symbols"
           , "em-synagogue"
           , "em-syringe"
           , "em-table_tennis_paddle_and_ball"
           , "em-taco"
           , "em-tada"
           , "em-takeout_box"
           , "em-tanabata_tree"
           , "em-tangerine"
           , "em-taurus"
           , "em-taxi"
           , "em-tea"
           , "em-telephone_receiver"
           , "em-telescope"
           , "em-tennis"
           , "em-tent"
           , "em-the_horns"
           , "em-thermometer"
           , "em-thinking_face"
           , "em-third_place_medal"
           , "em-thought_balloon"
           , "em-three"
           , "em-three_button_mouse"
           , "em-thunder_cloud_and_rain"
           , "em-ticket"
           , "em-tiger"
           , "em-timer_clock"
           , "em-tired_face"
           , "em-tm"
           , "em-toilet"
           , "em-tokyo_tower"
           , "em-tomato"
           , "em-tongue"
           , "em-top"
           , "em-tophat"
           , "em-tornado"
           , "em-trackball"
           , "em-tractor"
           , "em-traffic_light"
           , "em-train"
           , "em-tram"
           , "em-triangular_flag_on_post"
           , "em-triangular_ruler"
           , "em-trident"
           , "em-triumph"
           , "em-trolleybus"
           , "em-trophy"
           , "em-tropical_drink"
           , "em-tropical_fish"
           , "em-truck"
           , "em-trumpet"
           , "em-tulip"
           , "em-tumbler_glass"
           , "em-turkey"
           , "em-turtle"
           , "em-tv"
           , "em-twisted_rightwards_arrows"
           , "em-two"
           , "em-two_hearts"
           , "em-two_men_holding_hands"
           , "em-two_women_holding_hands"
           , "em-umbrella"
           , "em-umbrella_on_ground"
           , "em-umbrella_with_rain_drops"
           , "em-unamused"
           , "em-underage"
           , "em-unicorn_face"
           , "em-unlock"
           , "em-up"
           , "em-upside_down_face"
           , "em-us"
           , "em-v"
           , "em-vampire"
           , "em-vertical_traffic_light"
           , "em-vhs"
           , "em-vibration_mode"
           , "em-video_camera"
           , "em-video_game"
           , "em-violin"
           , "em-virgo"
           , "em-volcano"
           , "em-volleyball"
           , "em-vs"
           , "em-walking"
           , "em-waning_crescent_moon"
           , "em-waning_gibbous_moon"
           , "em-warning"
           , "em-wastebasket"
           , "em-watch"
           , "em-water_buffalo"
           , "em-water_polo"
           , "em-watermelon"
           , "em-wave"
           , "em-waving_black_flag"
           , "em-waving_white_flag"
           , "em-wavy_dash"
           , "em-waxing_crescent_moon"
           , "em-wc"
           , "em-weary"
           , "em-wedding"
           , "em-weight_lifter"
           , "em-whale"
           , "em-wheel_of_dharma"
           , "em-wheelchair"
           , "em-white_check_mark"
           , "em-white_circle"
           , "em-white_flower"
           , "em-white_frowning_face"
           , "em-white_large_square"
           , "em-white_medium_small_square"
           , "em-white_medium_square"
           , "em-white_small_square"
           , "em-white_square_button"
           , "em-wilted_flower"
           , "em-wind_blowing_face"
           , "em-wind_chime"
           , "em-wine_glass"
           , "em-wink"
           , "em-wolf"
           , "em-woman"
           , "em-woman_climbing"
           , "em-woman_in_lotus_position"
           , "em-woman_in_steamy_room"
           , "em-womans_clothes"
           , "em-womans_hat"
           , "em-womens"
           , "em-world_map"
           , "em-worried"
           , "em-wrench"
           , "em-wrestlers"
           , "em-writing_hand"
           , "em-x"
           , "em-yellow_heart"
           , "em-yen"
           , "em-yin_yang"
           , "em-yum"
           , "em-zap"
           , "em-zebra_face"
           , "em-zero"
           , "em-zipper_mouth_face"
           , "em-zombie"
           , "em-zzz"
           ]
