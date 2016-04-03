local private, public = {}, {}
Aux.disenchant = public

function public.source(item_id)

    local info = {
        [10940] = {'DUST', '1-20'},
        [11083] = {'DUST', '21-30'},
        [11137] = {'DUST', '31-40'},
        [11176] = {'DUST', '41-50'},
        [16204] = {'DUST', '51-60'},

        [10938] = {'ESSENCE', '1-10'},
        [10939] = {'ESSENCE', '11-15'},
        [10998] = {'ESSENCE', '16-20'},
        [11082] = {'ESSENCE', '21-25'},
        [11134] = {'ESSENCE', '26-30'},
        [11135] = {'ESSENCE', '31-35'},
        [11174] = {'ESSENCE', '36-40'},
        [11175] = {'ESSENCE', '41-45'},
        [16202] = {'ESSENCE', '46-50'},
        [16203] = {'ESSENCE', '51-60'},

        [10978] = {'SHARD', '1-20'},
        [11084] = {'SHARD', '21-25'},
        [11138] = {'SHARD', '26-30'},
        [11139] = {'SHARD', '31-35'},
        [11177] = {'SHARD', '36-40'},
        [11178] = {'SHARD', '41-45'},
        [14343] = {'SHARD', '46-50'},
        [14344] = {'SHARD', '51-60'},

        [20725] = {'CRYSTAL', '51+'},
    }

    return unpack(info[item_id] or {})
end

local armor = {
    INVTYPE_HEAD = true,
    INVTYPE_NECK = true,
    INVTYPE_SHOULDER = true,
    INVTYPE_BODY = true,
    INVTYPE_CHEST = true,
    INVTYPE_ROBE = true,
    INVTYPE_WAIST = true,
    INVTYPE_LEGS = true,
    INVTYPE_FEET = true,
    INVTYPE_WRIST = true,
    INVTYPE_HAND = true,
    INVTYPE_FINGER = true,
    INVTYPE_TRINKET = true,
    INVTYPE_CLOAK = true,
    INVTYPE_HOLDABLE = true,
}

local weapon = {
    INVTYPE_2HWEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPON = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_SHIELD = true,
    INVTYPE_RANGED = true,
    INVTYPE_RANGEDRIGHT = true,
}

local UNCOMMON, RARE, EPIC = 2, 3, 4

function public.value(slot, quality, level)
    local expectation
    for _, event in public.distribution(slot, quality, level) do
        local value = Aux.history.value(event.item_id..':'..0)
        if not value then
            return
        else
            expectation = (expectation or 0) + event.probability * event.quantity * value
        end
    end
    return expectation
end

function public.distribution(slot, quality, level)
    if not (armor[slot] or weapon[slot]) or level == 0 then
        return {}
    end

    local function p(probability_armor, probability_weapon)
        if armor[slot] then
            return probability_armor
        elseif weapon[slot] then
            return probability_weapon
        end
    end

    if quality == UNCOMMON then
        if level <= 10 then
            return {
                {item_id=10940, quantity=1.5, probability=0.8},
                {item_id=10938, quantity=1.5, probability=0.2},
            }
        elseif level <= 15 then
            return {
                {item_id=10940, quantity=2.5, probability=p(0.75, 0.2)},
                {item_id=10939, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=10978, quantity=1, probability=0.05},
            }
        elseif level <= 20 then
            return {
                {item_id=10940, quantity=5, probability=p(0.75, 0.15)},
                {item_id=10998, quantity=1.5, probability=p(0.15, 0.75)},
                {item_id=10978, quantity=1, probability=0.10},
            }
        elseif level <= 25 then
            return {
                {item_id=11083, quantity=1.5, probability=p(0.75, 0.2)},
                {item_id=11082, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=11084, quantity=1, probability=0.05},
            }
        elseif level <= 30 then
            return {
                {item_id=11083, quantity=3.5, probability=p(0.75, 0.2)},
                {item_id=11134, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=11138, quantity=1, probability=0.05},
            }
        elseif level <= 35 then
            return {
                {item_id=11137, quantity=1.5, probability=p(0.75, 0.2)},
                {item_id=11135, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=11139, quantity=1, probability=0.05},
            }
        elseif level <= 40 then
            return {
                {item_id=11137, quantity=3.5, probability=p(0.75, 0.2)},
                {item_id=11174, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=11177, quantity=1, probability=0.05},
            }
        elseif level <= 45 then
            return {
                {item_id=11176, quantity=1.5, probability=p(0.75, 0.2)},
                {item_id=11175, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=11178, quantity=1, probability=0.05},
            }
        elseif level <= 50 then
            return {
                {item_id=11176, quantity=3.5, probability=p(0.75, 0.22)},
                {item_id=16202, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=14343, quantity=1, probability=p(0.05, 0.03)},
            }
        elseif level <= 55 then
            return {
                {item_id=16204, quantity=1.5, probability=p(0.75, 0.22)},
                {item_id=16203, quantity=1.5, probability=p(0.2, 0.75)},
                {item_id=14344, quantity=1, probability=p(0.05, 0.03)},
            }
        elseif level <= 60 then
            return {
                {item_id=16204, quantity=3.5, probability=p(0.75, 0.22)},
                {item_id=16203, quantity=2.5, probability=p(0.2, 0.75)},
                {item_id=14344, quantity=1, probability=p(0.05, 0.03)},
            }
        end
    elseif quality == RARE then
        if level <= 20 then
            return {{item_id=10978, quantity=1, probability=1}}
        elseif level <= 25 then
            return {{item_id=11084, quantity=1, probability=1}}
        elseif level <= 30 then
            return {{item_id=11138, quantity=1, probability=1}}
        elseif level <= 35 then
            return {{item_id=11139, quantity=1, probability=1}}
        elseif level <= 40 then
            return {{item_id=11177, quantity=1, probability=1}}
        elseif level <= 45 then
            return {{item_id=11178, quantity=1, probability=1}}
        elseif level <= 50 then
            return {{item_id=14343, quantity=1, probability=1}}
        elseif level <= 55 then
            return {{item_id=14344, quantity=1, probability=0.995}, {item_id=20725, quantity=1, probability=0.005}}
        elseif level <= 60 then
            return {{item_id=14344, quantity=1, probability=0.995}, {item_id=20725, quantity=1, probability=0.005}}
        end
    elseif quality == EPIC then
        if level <= 40 then
            return {{item_id=11177, quantity=3, probability=1}}
        elseif level <= 45 then
            return {{item_id=11178, quantity=3, probability=1}}
        elseif level <= 50 then
            return {{item_id=14343, quantity=3, probability=1}}
        elseif level <= 55 then
            return {{item_id=20725, quantity=1, probability=1}}
        elseif level <= 60 then
            return {{item_id=20725, quantity=1.5, probability=1}}
        end
    end
    return {}
end