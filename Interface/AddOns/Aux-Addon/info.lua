local TOOLTIP_LENGTH = 30

local private, public = {}, {}
Aux.info = public

function public.inventory_index(slot)
    local inventory_index_map = {
        INVTYPE_AMMO = {0},
        INVTYPE_HEAD = {1},
        INVTYPE_NECK = {2},
        INVTYPE_SHOULDER = {3},
        INVTYPE_BODY = {4},
        INVTYPE_CHEST = {5},
        INVTYPE_ROBE = {5},
        INVTYPE_WAIST = {6},
        INVTYPE_LEGS = {7},
        INVTYPE_FEET = {8},
        INVTYPE_WRIST = {9},
        INVTYPE_HAND = {10},
        INVTYPE_FINGER = {11, 12},
        INVTYPE_TRINKET = {13, 14},
        INVTYPE_CLOAK = {15},
        INVTYPE_2HWEAPON = {16, 17},
        INVTYPE_WEAPONMAINHAND = {16, 17},
        INVTYPE_WEAPON = {16, 17},
        INVTYPE_WEAPONOFFHAND = {16, 17},
        INVTYPE_HOLDABLE = {16, 17},
        INVTYPE_SHIELD = {16, 17},
        INVTYPE_RANGED = {18},
        INVTYPE_RANGEDRIGHT = {18},
        INVTYPE_TABARD = {19},
    }

    return unpack(inventory_index_map[slot] or {})
end

function public.container_item(bag, slot)
	local hyperlink = GetContainerItemLink(bag, slot)
	
	if not hyperlink then
		return
    end

    local item_id, suffix_id, unique_id, enchant_id = public.parse_hyperlink(hyperlink)
    local item_info = public.item(item_id, suffix_id, unique_id, enchant_id)

    local texture, count, locked, quality, readable, lootable = GetContainerItemInfo(bag, slot) -- quality not working?
    local tooltip = public.tooltip(function(tt) tt:SetBagItem(bag, slot) end)
    local charges = private.item_charges(tooltip)
    local aux_quantity = charges or count

    return {
        item_id = item_id,
        suffix_id = suffix_id,
        unique_id = unique_id,
        enchant_id = enchant_id,

        hyperlink = hyperlink,
        itemstring = item_info.itemstring,
        item_key = item_id..':'..suffix_id,

        name = item_info.name,
        texture = texture,
        level = item_info.level,
        type = item_info.type,
        subtype = item_info.subtype,
        slot = item_info.slot,
        quality = item_info.quality,
        max_stack = item_info.max_stack,
        aux_quantity = aux_quantity,

        count = count,
        locked = locked,
        readable = readable,
        lootable = lootable,

        tooltip = tooltip,
        charges = charges,
    }
end

function public.auction_sell_item()
	local name, texture, count, quality, usable, vendor_price = GetAuctionSellItemInfo()

	if name then

        local unit_vendor_price = vendor_price / count
        local tooltip = public.tooltip(function(tt) tt:SetAuctionSellItem() end)

        local charges = private.item_charges(tooltip)
        local aux_quantity = charges or count

        return {
			name = name,
			texture = texture,
            quality = quality,
            aux_quantity = aux_quantity,
			stack_size = count,
			usable = usable,
            vendor_price = vendor_price,
            unit_vendor_price = unit_vendor_price,
            tooltip = tooltip,
            charges = charges,
		}
	end
end

function public.auction(index, query_type)
    query_type = query_type or 'list'

	local hyperlink = GetAuctionItemLink(query_type, index)
	
	if not hyperlink then
		return
	end

    local item_id, suffix_id, unique_id, enchant_id = public.parse_hyperlink(hyperlink)
    local item_info = public.item(item_id, suffix_id, unique_id, enchant_id)

    local name, texture, count, quality, usable, level, start_price, min_increment, buyout_price, high_bid, high_bidder, owner, sale_status = GetAuctionItemInfo(query_type, index)

	local duration = GetAuctionItemTimeLeft(query_type, index)
    local tooltip = public.tooltip(function(tt) tt:SetAuctionItem(query_type, index) end)
    local charges = private.item_charges(tooltip)
    local aux_quantity = charges or count
    local blizzard_bid = high_bid > 0 and high_bid or start_price
    local bid_price = high_bid > 0 and (high_bid + min_increment) or start_price

    return {
        item_id = item_id,
        suffix_id = suffix_id,
        unique_id = unique_id,
        enchant_id = enchant_id,

        hyperlink = hyperlink,
        itemstring = item_info.itemstring,
        item_key = item_id..':'..suffix_id,
        search_signature = Aux.util.join({item_id, suffix_id, enchant_id, start_price, buyout_price, bid_price, aux_quantity, duration, type(high_bidder) == 'string' and high_bidder or (high_bidder and 1 or 0), aux_ignore_owner and (Aux.is_player(owner) and 0 or 1) or (owner or '?')}, ':'),

        name = name,
        texture = texture,
        level = item_info.level,
        type = item_info.type,
        subtype = item_info.subtype,
        slot = item_info.slot,
        quality = quality,
        max_stack = item_info.max_stack,

        count = count,
        start_price = start_price,
        high_bid = high_bid,
        min_increment = min_increment,
        blizzard_bid = blizzard_bid,
        bid_price = bid_price,
        buyout_price = buyout_price,
        unit_blizzard_bid = blizzard_bid / aux_quantity,
        unit_bid_price = bid_price / aux_quantity,
        unit_buyout_price = buyout_price / aux_quantity,
        high_bidder = high_bidder,
        owner = owner,
        sale_status = sale_status,
        duration = duration,
        usable = usable,
        tooltip = tooltip,
        charges = charges,
        aux_quantity = aux_quantity,
    }
end

function public.set_tooltip(itemstring, owner, anchor)
    GameTooltip:SetOwner(owner, anchor)
    GameTooltip:SetHyperlink(itemstring)
end

function public.set_shopping_tooltip(slot)
    local index1, index2 = public.inventory_index(slot)

    local tooltips = {}
    if index1 then
        local tooltip = public.tooltip(function(tt) tt:SetInventoryItem('player', index1) end)
        if getn(tooltip) > 0 then
            tinsert(tooltips, tooltip)
        end
    end
    if index2 then
        local tooltip = public.tooltip(function(tt) tt:SetInventoryItem('player', index2) end)
        if getn(tooltip) > 0 then
            tinsert(tooltips, tooltip)
        end
    end

    if tooltips[1] then
        tinsert(tooltips[1], 1, { left_text = 'Currently Equipped', left_color = { 0.5, 0.5, 0.5 } })

        ShoppingTooltip1:SetOwner(GameTooltip, 'ANCHOR_BOTTOMRIGHT')
        public.load_tooltip(ShoppingTooltip1, tooltips[1])
        ShoppingTooltip1:Show()
        ShoppingTooltip1:SetPoint('TOPLEFT', GameTooltip, 'TOPRIGHT', 0, -10)
    end

    if tooltips[2] then
        tinsert(tooltips[2], 1, { left_text = 'Currently Equipped', left_color = { 0.5, 0.5, 0.5 } })

        ShoppingTooltip2:SetOwner(ShoppingTooltip1, 'ANCHOR_BOTTOMRIGHT')
        public.load_tooltip(ShoppingTooltip2, tooltips[2])
        ShoppingTooltip2:Show()
        ShoppingTooltip2:SetPoint('TOPLEFT', ShoppingTooltip1, 'TOPRIGHT')
    end
end

function public.tooltip_match(entry, tooltip)
    return Aux.util.any(tooltip, function(line)
        local left_match = line.left_text and strupper(line.left_text) == strupper(entry)
        local right_match = line.right_text and strupper(line.right_text) == strupper(entry)
        return left_match or right_match
    end)
end

function public.tooltip_find(pattern, tooltip)
    local count = 0
    for _, line in ipairs(tooltip) do
        if line.left_text and strfind(line.left_text, pattern) then
            count = count + 1
        end
        if line.right_text and strfind(line.right_text, pattern) then
            count = count + 1
        end
    end

    return count
end

function public.load_tooltip(frame, tooltip)
    for _, line in ipairs(tooltip) do
        if line.right_text then
            frame:AddDoubleLine(line.left_text, line.right_text, line.left_color[1], line.left_color[2], line.left_color[3], line.right_color[1], line.right_color[2], line.right_color[3])
        else
            frame:AddLine(line.left_text, line.left_color[1], line.left_color[2], line.left_color[3], true)
        end
    end
    for i = 1,TOOLTIP_LENGTH do -- TODO why is this needed?
        getglobal(frame:GetName()..'TextLeft'..i):SetJustifyH('LEFT')
        getglobal(frame:GetName()..'TextRight'..i):SetJustifyH('LEFT')
    end
end

function public.display_name(item_id, plain, uncolored)
    local item_info = Aux.info.item(item_id)
    if item_info then
        local name = item_info.name
        if not plain then
            name = '['..name..']'
        end
        if not uncolored then
            name = ({GetItemQualityColor(item_info.quality)})[4]..name..FONT_COLOR_CODE_CLOSE
        end
        return name
    end
end

function public.auctionable(tooltip, quality, lootable)
    local durability, max_durability = public.durability(tooltip)
    return not lootable
            and (not quality or quality < 6)
            and not public.tooltip_match(ITEM_BIND_ON_PICKUP, tooltip)
            and not public.tooltip_match(ITEM_BIND_QUEST, tooltip)
            and not public.tooltip_match(ITEM_SOULBOUND, tooltip)
            and (not public.tooltip_match(ITEM_CONJURED, tooltip) or public.tooltip_find(ITEM_MIN_LEVEL, tooltip) > 1)
            and not (durability and durability < max_durability)
end

function public.tooltip(setter)
	for i = 1, TOOLTIP_LENGTH do
		getglobal('AuxTooltipTextLeft'..i):SetText()
		getglobal('AuxTooltipTextRight'..i):SetText()
	end
	
	AuxTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
    AuxTooltip.money = 0
	setter(AuxTooltip)
	AuxTooltip:Show()

	local tooltip = { money=AuxTooltip.money }
	for i = 1, TOOLTIP_LENGTH do

		local left_text = getglobal('AuxTooltipTextLeft'..i):GetText()
		local left_color = { getglobal('AuxTooltipTextLeft'..i):GetTextColor() }
		
		local right_text = getglobal('AuxTooltipTextRight'..i):GetText()
		local right_color = { getglobal('AuxTooltipTextRight'..i):GetTextColor() }

        if left_text or right_text then
		    tinsert(tooltip, {
                left_text = left_text,
                left_color = left_color,
                right_text = right_text,
                right_color = right_color,
            })
        end
	end
	
	for i = 1, TOOLTIP_LENGTH do
		getglobal('AuxTooltipTextLeft'..i):SetText()
		getglobal('AuxTooltipTextRight'..i):SetText()
	end
	
	return tooltip
end

function private.item_charges(tooltip)
    if public.tooltip_find(ITEM_SPELL_TRIGGER_ONUSE, tooltip) > 1 then -- it's presumably a recipe
        return
    end

	for _, line in ipairs(tooltip) do
        local pattern1 = '^'..gsub(ITEM_SPELL_CHARGES, '%%d', '(%%d+)')..'$'
        local pattern2 = '^'..gsub(ITEM_SPELL_CHARGES_P1, '%%d', '(%%d+)')..'$'

        local _, _, left_charges_string1 = strfind(line.left_text or '', pattern1)
        local _, _, left_charges_string2 = strfind(line.left_text or '', pattern2)

        local _, _, right_charges_string1 = strfind(line.right_text or '', pattern1)
        local _, _, right_charges_string2 = strfind(line.right_text or '', pattern2)

        local charges = tonumber(left_charges_string1) or tonumber(left_charges_string2) or tonumber(right_charges_string1) or tonumber(right_charges_string2)
		if charges then
			return charges
		end
	end
end

function public.durability(tooltip)
    for _, line in ipairs(tooltip) do
        local pattern = '^'..gsub(DURABILITY_TEMPLATE, '%%d', '(%%d+)')..'$'
        local _, _, left_durability_string, left_max_durability_string = strfind(line.left_text or '', pattern)
        local _, _, right_durability_string, right_max_durability_string = strfind(line.right_text or '', pattern)
        local durability = tonumber(left_durability_string) or tonumber(right_durability_string)
        local max_durability = tonumber(left_max_durability_string) or tonumber(right_max_durability_string)
        if durability then
            return durability, max_durability
        end
    end
end

function public.item_key(hyperlink)
    local item_id, suffix_id = public.parse_hyperlink(hyperlink)
    return item_id..':'..suffix_id
end

function public.parse_hyperlink(hyperlink)
    local _, _, item_id, enchant_id, suffix_id, unique_id, name = strfind(hyperlink, '|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h')
    return tonumber(item_id) or 0, tonumber(suffix_id) or 0, tonumber(unique_id) or 0, tonumber(enchant_id) or 0, name
end

function public.itemstring(item_id, suffix_id, unique_id, enchant_id)
    return 'item:'..(item_id or 0)..':'..(enchant_id or 0)..':'..(suffix_id or 0)..':'..(unique_id or 0)
end

function public.item(item_id, suffix_id)
    local itemstring = 'item:'..(item_id or 0)..':0:'..(suffix_id or 0)..':0'
    local name, itemstring, quality, level, class, subclass, max_stack, slot, texture = GetItemInfo(itemstring)
    return name and {
        name = name,
        itemstring = itemstring,
        quality = quality,
        level = level,
        class = class,
        subclass = subclass,
        slot = slot,
        max_stack = max_stack,
        texture = texture,
    } or Aux.cache.item_info(item_id)
end