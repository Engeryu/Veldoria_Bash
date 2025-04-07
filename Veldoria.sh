#!/bin/bash
# @Author: Engeryu
# @Date:   2018-09-02 13:0:36
# @Last Modified by:   Engeryu
# @Last Modified time: 2025-04-07 10:23:42

clear

echo "Welcome to my game"

# ---- Random Level Name Generator ----
random_level_name() {
    local adjectives=("Mystic" "Dark" "Ancient" "Enchanted" "Cursed" "Golden" "Emerald" "Shadow" "Crimson" "Forgotten")
    local nouns=("Forest" "Keep" "Cavern" "Castle" "Temple" "Fortress" "Ruins" "Barracks" "Sanctuary" "Citadel")
    local rand_adj=${adjectives[$RANDOM % ${#adjectives[@]}]}
    local rand_noun=${nouns[$RANDOM % ${#nouns[@]}]}
    echo "$rand_adj $rand_noun"
}

# ---- Combat Systems ----

fight_system() {
    local choice
    echo "1. Attack   2. Heal"
    read -r choice
    while [[ "$choice" != "1" && "$choice" != "2" ]]; do
        read -r choice
    done

    if [ "$choice" = "1" ]; then
        # Attaque : Réduit les HP de l'ennemi de la force du joueur
        Remaining_hp_enemies=$((Remaining_hp_enemies - Players_Classes_Str))

        # Réduit les HP du joueur en fonction de la force de l'ennemi
        Remaining_hp_players=$((Remaining_hp_players - STR_Enemies))
    elif [ "$choice" = "2" ]; then
        # Soin : Augmente les HP du joueur, mais limite au maximum de ses HP
        Remaining_hp_players=$((Remaining_hp_players + Players_Classes_Hp * 3 / 2))

        if [ "$Remaining_hp_players" -gt "$Players_Classes_Hp" ]; then
            Remaining_hp_players=$Players_Classes_Hp
        fi
    fi
}

fight2_system() {
    local choice
    echo "1. Attack   2. Heal"
    read -r choice
    while [[ "$choice" != "1" && "$choice" != "2" ]]; do
        read -r choice
    done

    if [ "$choice" = "1" ]; then
        # Dans le combat de boss, on met à jour Remaining_hp_boss
        Remaining_hp_boss=$((Remaining_hp_boss - Players_Classes_Str))
        Remaining_hp_players=$((Remaining_hp_players - Str_Bosses))
    elif [ "$choice" = "2" ]; then
        Remaining_hp_players=$((Remaining_hp_players + Players_Classes_Hp * 3 / 2))
        if [ "$Remaining_hp_players" -gt "$Players_Classes_Hp" ]; then
             Remaining_hp_players=$Players_Classes_Hp
        fi
    fi
}

# ---- Level Design ----
# La fonction level_design ignore le premier paramètre et génère à chaque appel un nom aléatoire.
#   $2 = level description  
#   $3 = fight system function name (e.g. fight_system ou fight2_system)
#   $4 = next level function name (or a terminal function)
# ---- Level Design ----
level_design() {
    local level_name="$1"
    local level_description="$2"
    local fight_sys="$3"
    local next_level="$4"

    printf "\n========== %s ==========\n" "$level_name"
    printf "%s\n" "$level_description"
    printf "========== FIGHT ==========\n"

    # Combat contre un BOSS
    if [ "$level_name" = "Fabled Floor of the Fallen" ]; then
        Random_Bosses
        printf "%s              %s\n" "$Player" "$Bosses"
        printf "HP: %s/%s        HP: %s/%s\n" "$Players_Classes_Hp" "$Players_Classes_Hp" "$HP_Bosses" "$HP_Bosses"
        Remaining_hp_players=$Players_Classes_Hp
        Remaining_hp_boss=$HP_Bosses   # Variable dédiée pour le boss

        while [ "$Remaining_hp_players" -gt 0 ] && [ "$Remaining_hp_boss" -gt 0 ]; do
            printf "\n%s              %s\n" "$Player" "$Bosses"
            printf "HP: %s/%s        HP: %s/%s\n" "$Remaining_hp_players" "$Players_Classes_Hp" "$Remaining_hp_boss" "$HP_Bosses"
            $fight_sys  # Appelle fight2_system (qui doit mettre à jour Remaining_hp_boss)
            if [ "$Remaining_hp_boss" -le 0 ]; then
                echo "You won! GG, you have defeated the final boss!"
                break
            fi
            if [ "$Remaining_hp_players" -le 0 ]; then
                echo "You are dead. The world falls into despair..."
                exit 1
            fi
        done
        congrats
        return
    fi

    # Combat contre des ENEMIES
    Random_Enemies
    printf "%s              %s\n" "$Player" "$Enemies"
    printf "HP: %s/%s        HP: %s/%s\n" "$Players_Classes_Hp" "$Players_Classes_Hp" "$HP_Enemies" "$HP_Enemies"
    Remaining_hp_players=$Players_Classes_Hp
    Remaining_hp_enemies=$HP_Enemies

    while [ "$Remaining_hp_players" -gt 0 ] && [ "$Remaining_hp_enemies" -gt 0 ]; do
        printf "\n%s              %s\n" "$Player" "$Enemies"
        printf "HP: %s/%s        HP: %s/%s\n" "$Remaining_hp_players" "$Players_Classes_Hp" "$Remaining_hp_enemies" "$HP_Enemies"
        $fight_sys  # Appelle fight_system
        if [ "$Remaining_hp_enemies" -le 0 ]; then
            echo "You won! GG, now let's get to the next floor!"
            break
        fi
        if [ "$Remaining_hp_players" -le 0 ]; then
            echo "You are dead. It was a pitiful loss..."
            exit 1
        fi
    done

    $next_level
}

# ---- Level Functions ----
level1_design() {
    # La description est statique, le nom sera généré aléatoirement.
    level_design "Caves of Gloomspire" "Within the labyrinthine caves of Gloomspire, treacherous paths await. $Player steels his heart for the challenges ahead." "fight_system" "level2_design"
}

level2_design() {
    level_design "Enchanted forest" "Deep in the enchanted forest, ancient creatures rise. $Player gathers strength to overcome them." "fight_system" "level3_design"
}

level3_design() {
    level_design "Forbidden Marshes" "At the edge of the Forbidden Marshes, malevolent spirits stir in the mist. $Player presses on despite the dread." "fight_system" "level4_design"
}

level4_design() {
    level_design "Tower of Elders" "At the peak of the Tower of Elders, a cursed wind blows. $Player faces mysterious foes." "fight_system" "level5_design"
}

level5_design() {
    level_design "Cursed ruins of Blackmoor" "In the cursed ruins of Blackmoor, forgotten secrets lurk in every shadow. $Player must decipher cryptic omens." "fight_system" "level6_design"
}

level6_design() {
    level_design "Ancient drake's lair" "Beneath the ancient drake's lair, fiery terrors emerge. $Player's resolve is put to the test." "fight_system" "level7_design"
}

level7_design() {
    level_design "Moonlit Peaks" "Over the Moonlit Peaks, ghostly warriors whisper their plight. $Player ventures forward into unknown lands." "fight_system" "level8_design"
}

level8_design() {
    level_design "Ruined city of Ashenvale" "In the ruined city of Ashenvale, darkness spreads. Our Hero $Player begins his quest to banish the evil of the Crimson Citadel." "fight_system" "level9_design"
}

level9_design() {
    level_design "shattered halls of the Crimson Citadel" "Within the shattered halls of the Crimson Citadel, fate awaits. $Player confronts challenges that test his very soul." "fight_system" "level10_design"
}

level10_design() {
    # Boss floor: avant de lancer le combat, on génère aléatoirement le nom du niveau et on force un nom fixe si nécessaire
    Random_Bosses
    level_design "Fabled Floor of the Fallen" "At the apex of destiny, on the fabled Floor of the Fallen, the dreaded boss $Bosses appears!" "fight2_system" "congrats"
}

congrats() {
    echo "You bet!"
    Random_Bosses
    echo "YOU WIN!"
}

# ---- CSV and Stat Functions ----

get_stat() {
    local entity="$1"
    local csv_path="$2"
    local column="$3"
    grep "$entity" "$csv_path" | awk -F "," -v col="$column" '{print $col}'
}

display_stats() {
    local entity="$1"
    shift
    printf "\nStats for %s:\n" "$entity"
    printf "HP: %s\nMP: %s\nSTR: %s\nINT: %s\nDEF: %s\nRES: %s\nSPD: %s\nLUCK: %s\n" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
}

ask_question() {
    local question="$1"
    local function_name="$2"
    local choice
    read -r -p "$question yes or no? " choice
    while [[ "$choice" != "yes" && "$choice" != "no" ]]; do
        read -r -p "$question yes or no? " choice
    done
    if [ "$choice" = "yes" ]; then
        $function_name
    else
        echo "Game over!"
        exit 1
    fi
}

Random_Enemies() {
    Enemies=$(sed '1d' src/Enemies_stat.csv | cut -d "," -f2 | tr "," " " | shuf -n 1)
    HP_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 3)
    MP_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 4)
    STR_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 5)
    INT_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 6)
    DEF_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 7)
    RES_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 8)
    SPD_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 9)
    LUCK_Enemies=$(get_stat "$Enemies" "src/Enemies_stat.csv" 10)
}

Random_Bosses() {
    Bosses=$(sed '1d' src/Bosses_stat.csv | cut -d "," -f2 | tr "," " " | shuf -n 1)
    HP_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 3)
    MP_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 4)
    Str_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 5)
    Int_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 6)
    Def_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 7)
    Res_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 8)
    Spd_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 9)
    Luck_Bosses=$(get_stat "$Bosses" "src/Bosses_stat.csv" 10)
}

Character_choice() {
    echo "This is your Character:"
    Player=$(sed '1d' src/Players_stat.csv | cut -d "," -f2 | tr "," " " | shuf -n 1)
    HP_Players=$(get_stat "$Player" "src/Players_stat.csv" 3)
    MP_Players=$(get_stat "$Player" "src/Players_stat.csv" 4)
    Str_Players=$(get_stat "$Player" "src/Players_stat.csv" 5)
    Int_Players=$(get_stat "$Player" "src/Players_stat.csv" 6)
    Def_Players=$(get_stat "$Player" "src/Players_stat.csv" 7)
    Res_Players=$(get_stat "$Player" "src/Players_stat.csv" 8)
    Spd_Players=$(get_stat "$Player" "src/Players_stat.csv" 9)
    Luck_Players=$(get_stat "$Player" "src/Players_stat.csv" 10)
    display_stats "$Player" "$HP_Players" "$MP_Players" "$Str_Players" "$Int_Players" "$Def_Players" "$Res_Players" "$Spd_Players" "$Luck_Players"
    ask_question "Will you continue" classes_choice
}

classes_choice() {
    Class=$(sed '1d' src/Classes_Stat.csv | cut -d "," -f2 | tr "," " " | shuf -n 1)
    HP_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 3)
    MP_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 4)
    Str_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 5)
    Int_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 6)
    Def_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 7)
    Res_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 8)
    Spd_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 9)
    Luck_Classes=$(get_stat "$Class" "src/Classes_Stat.csv" 10)
    display_stats "$Class" "$HP_Classes" "$MP_Classes" "$Str_Classes" "$Int_Classes" "$Def_Classes" "$Res_Classes" "$Spd_Classes" "$Luck_Classes"
    ask_question "Will you continue" players_classes
}

players_classes() {
    echo "Your Hero $Player is a $Class"
    Players_Classes_Hp=$((HP_Players + HP_Classes))
    Players_Classes_Mp=$((MP_Players + MP_Classes))
    Players_Classes_Str=$((Str_Players + Str_Classes))
    Players_Classes_Int=$((Int_Players + Int_Classes))
    Players_Classes_Def=$((Def_Players + Def_Classes))
    Players_Classes_Res=$((Res_Players + Res_Classes))
    Players_Classes_Spd=$((Spd_Players + Spd_Classes))
    Players_Classes_Luck=$((Luck_Players + Luck_Classes))

    echo "Combined Stats:"
    printf "HP: %s\nMP: %s\nSTR: %s\nINT: %s\nDEF: %s\nRES: %s\nSPD: %s\nLUCK: %s\n" \
           "$Players_Classes_Hp" "$Players_Classes_Mp" "$Players_Classes_Str" "$Players_Classes_Int" \
           "$Players_Classes_Def" "$Players_Classes_Res" "$Players_Classes_Spd" "$Players_Classes_Luck"
    ask_question "Will you continue" level1_design
}

# ---- Start Game ----

ask_question "Will you start my game" Character_choice