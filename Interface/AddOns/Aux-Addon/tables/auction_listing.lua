local m, public, private = aux.module'auction_listing'

local RT_COUNT = 1
local HEAD_HEIGHT = 27
local HEAD_SPACE = 2

public.colors = {
	BLUE = '|cff2992ff',
	GREEN = '|cff16ff16',
	YELLOW = '|cffffff00',
	ORANGE = '|cffff9218',
	RED = '|cffff0000',
	GRAY = '|cffbbbbbb',
}

local AUCTION_PCT_COLORS = {
    {color=m.colors.BLUE, value=50},
    {color=m.colors.GREEN, value=80},
    {color=m.colors.YELLOW, value=110},
    {color=m.colors.ORANGE, value=135},
    {color=m.colors.RED, value=aux.huge},
}
local TIME_LEFT_STRINGS = {
	m.colors.RED..'30m'..FONT_COLOR_CODE_CLOSE, -- Short
	m.colors.ORANGE..'2h'..FONT_COLOR_CODE_CLOSE, -- Medium
	m.colors.YELLOW..'8h'..FONT_COLOR_CODE_CLOSE, -- Long
	m.colors.BLUE..'24h'..FONT_COLOR_CODE_CLOSE, -- Very Long
}

function private.item_column_init(rt, cell)
    local spacer = CreateFrame('Frame', nil, cell)
    spacer:SetPoint('TOPLEFT', 0, 0)
    spacer:SetHeight(rt.ROW_HEIGHT)
    spacer:SetWidth(1)
    cell.spacer = spacer

    local iconBtn = CreateFrame('Button', nil, cell)
    iconBtn:SetPoint('TOPLEFT', spacer, 'TOPRIGHT')
    iconBtn:SetHeight(rt.ROW_HEIGHT)
    iconBtn:SetWidth(rt.ROW_HEIGHT)
    iconBtn:SetScript('OnEnter', rt.OnIconEnter)
    iconBtn:SetScript('OnLeave', rt.OnIconLeave)
    iconBtn:SetScript('OnClick', rt.OnIconClick)
    iconBtn:SetScript('OnDoubleClick', rt.OnIconDoubleClick)
    local icon = iconBtn:CreateTexture(nil, 'ARTWORK')
    icon:SetPoint('TOPLEFT', 2, -2)
    icon:SetPoint('BOTTOMRIGHT', -2, 2)
    icon:SetTexCoord(.07, .93, .08, .94)

    cell.iconBtn = iconBtn
    cell.icon = icon

    local text = cell:GetFontString()
    text:ClearAllPoints()
    text:SetPoint('TOPLEFT', iconBtn, 'TOPRIGHT', 2, 0)
    text:SetPoint('BOTTOMRIGHT', 0, 0)
end

public.search_config = {
    {
        title = 'Item',
        width = 0.35,
        init = m.item_column_init,
        set = function(cell, record, _, _, _, indented)
            cell.icon:SetTexture(record.texture)
            if indented then
                cell.spacer:SetWidth(10)
                cell.icon:SetAlpha(0.5)
                cell:GetFontString():SetAlpha(0.7)
            else
                cell.spacer:SetWidth(1)
                cell.icon:SetAlpha(1)
                cell:GetFontString():SetAlpha(1)
            end
            cell:SetText(gsub(record.hyperlink, '[%[%]]', ''))
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.name, record_b.name, desc)
        end,
    },
    {
        title = 'Lvl',
        width = 0.035,
        align = 'CENTER',
        set = function(cell, record)
            local display_level = max(record.level, 1)
            display_level = UnitLevel('player') < record.level and m.colors.RED..display_level..FONT_COLOR_CODE_CLOSE or display_level
            cell:SetText(display_level)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.level, record_b.level, desc)
        end,
    },
    {
        title = 'Auctions',
        width = 0.06,
        align = 'CENTER',
        set = function(cell, record, count, own, expandable)
            local numAuctionsText = expandable and aux.gui.inline_color.link..count..FONT_COLOR_CODE_CLOSE or count
            if own > 0 then
                numAuctionsText = numAuctionsText..(' '..m.colors.YELLOW..'('..own..')'..FONT_COLOR_CODE_CLOSE)
            end
            cell:SetText(numAuctionsText)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.EQ
--            if sortKey == 'numAuctions' then
--                if a.children then
--                    aVal = a.totalAuctions
--                    bVal = b.totalAuctions
--                else
--                    aVal = a.numAuctions
--                    bVal = b.numAuctions
--                end
--            end
        end,
    },
    {
        title = 'Stack Size',
        width = 0.055,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(record.aux_quantity)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.aux_quantity, record_b.aux_quantity, desc)
        end,
    },
    {
        title = 'Time Left',
        width = 0.04,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(TIME_LEFT_STRINGS[record.duration or 0] or '---')
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.duration, record_b.duration, desc)
        end,
    },
    {
        title = 'Seller',
        width = 0.13,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(aux.is_player(record.owner) and (m.colors.YELLOW..record.owner..FONT_COLOR_CODE_CLOSE) or (record.owner or '---'))
        end,
        cmp = function(record_a, record_b, desc)
            if not record_a.owner and not record_b.owner then
                return aux.sort.EQ
            elseif not record_a.owner then
                return aux.sort.GT
            elseif not record_b.owner then
                return aux.sort.LT
            else
                return aux.sort.compare(record_a.owner, record_b.owner, desc)
            end
        end,
    },
    {
        title = {'Auction Bid\n(per item)', 'Auction Bid\n(per stack)'},
        width = 0.125,
        align = 'RIGHT',
        isPrice = true,
        set = function(cell, record)
            local color
            if record.high_bidder then
                color = AUCTION_PCT_COLORS[2].color
            elseif record.high_bid ~= 0 then
                color = AUCTION_PCT_COLORS[4].color
            end
            local price
            if record.high_bidder then
                price = aux_price_per_unit and ceil(record.high_bid / record.aux_quantity) or record.high_bid
            else
                price = aux_price_per_unit and ceil(record.unit_bid_price) or record.bid_price
            end
            cell:SetText(aux.money.to_string(price, true, false, nil, color))
        end,
        cmp = function(record_a, record_b, desc)
            local price_a
            if record_a.high_bidder then
                price_a = aux_price_per_unit and record_a.high_bid / record_a.aux_quantity or record_a.high_bid
            else
                price_a = aux_price_per_unit and record_a.unit_bid_price or record_a.bid_price
            end
            local price_b
            if record_b.high_bidder then
                price_b = aux_price_per_unit and record_b.high_bid / record_b.aux_quantity or record_b.high_bid
            else
                price_b = aux_price_per_unit and record_b.unit_bid_price or record_b.bid_price
            end
            return aux.sort.compare(price_a, price_b, desc)
        end,
    },
    {
        title = {'Auction Buyout\n(per item)', 'Auction Buyout\n(per stack)'},
        width = 0.125,
        align = 'RIGHT',
        isPrice = true,
        set = function(cell, record)
            local price = aux_price_per_unit and ceil(record.unit_buyout_price) or record.buyout_price
            cell:SetText(price > 0 and aux.money.to_string(price, true, false) or '---')
        end,
        cmp = function(record_a, record_b, desc)
            local price_a = aux_price_per_unit and record_a.unit_buyout_price or record_a.buyout_price
            local price_b = aux_price_per_unit and record_b.unit_buyout_price or record_b.buyout_price
            price_a = price_a > 0 and price_a or (desc and -aux.huge or aux.huge)
            price_b = price_b > 0 and price_b or (desc and -aux.huge or aux.huge)

            return aux.sort.compare(price_a, price_b, desc)
        end,
    },
    {
        title = '% Hist. Value',
        width = 0.08,
        align = 'CENTER',
        set = function(cell, record)
            local pct, bidPct = m.record_percentage(record)
            cell:SetText((pct or bidPct) and m.percentage_historical(pct or bidPct, not pct) or '---')
        end,
        cmp = function(record_a, record_b, desc)
            local pct_a = m.record_percentage(record_a) or (desc and -aux.huge or aux.huge)
            local pct_b = m.record_percentage(record_b) or (desc and -aux.huge or aux.huge)
            return aux.sort.compare(pct_a, pct_b, desc)
        end,
    },
}

public.auctions_config = {
    {
        title = 'Item',
        width = 0.35,
        init = m.item_column_init,
        set = function(cell, record, _, _, _, indented)
            cell.icon:SetTexture(record.texture)
            if indented then
                cell.spacer:SetWidth(10)
                cell.icon:SetAlpha(0.5)
                cell:GetFontString():SetAlpha(0.7)
            else
                cell.spacer:SetWidth(1)
                cell.icon:SetAlpha(1)
                cell:GetFontString():SetAlpha(1)
            end
            cell:SetText(gsub(record.hyperlink, '[%[%]]', ''))
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.name, record_b.name, desc)
        end,
    },
    {
        title = 'Lvl',
        width = 0.035,
        align = 'CENTER',
        set = function(cell, record)
            local display_level = max(record.level, 1)
            display_level = UnitLevel('player') < record.level and m.colors.RED..display_level..FONT_COLOR_CODE_CLOSE or display_level
            cell:SetText(display_level)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.level, record_b.level, desc)
        end,
    },
    {
        title = 'Auctions',
        width = 0.06,
        align = 'CENTER',
        set = function(cell, record, count, own, expandable)
            local numAuctionsText = expandable and aux.gui.inline_color.link..count..FONT_COLOR_CODE_CLOSE or count
            cell:SetText(numAuctionsText)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.EQ
            --            if sortKey == 'numAuctions' then
            --                if a.children then
            --                    aVal = a.totalAuctions
            --                    bVal = b.totalAuctions
            --                else
            --                    aVal = a.numAuctions
            --                    bVal = b.numAuctions
            --                end
            --            end
        end,
    },
    {
        title = 'Stack Size',
        width = 0.055,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(record.aux_quantity)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.aux_quantity, record_b.aux_quantity, desc)
        end,
    },
    {
        title = 'Time Left',
        width = 0.04,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(TIME_LEFT_STRINGS[record.duration or 0] or '---')
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.duration, record_b.duration, desc)
        end,
    },
    {
        title = {'Auction Bid\n(per item)', 'Auction Bid\n(per stack)'},
        width = 0.125,
        align = 'RIGHT',
        isPrice = true,
        set = function(cell, record)
            local price
            if record.high_bidder then
                price = aux_price_per_unit and ceil(record.high_bid / record.aux_quantity) or record.high_bid
            else
                price = aux_price_per_unit and ceil(record.start_price / record.aux_quantity) or record.start_price
            end
            cell:SetText(aux.money.to_string(price, true, false))
        end,
        cmp = function(record_a, record_b, desc)
            local price_a
            if record_a.high_bidder then
                price_a = aux_price_per_unit and record_a.high_bid / record_a.aux_quantity or record_a.high_bid
            else
                price_a = aux_price_per_unit and record_a.start_price / record_b.aux_quantity or record_a.start_price
            end
            local price_b
            if record_b.high_bidder then
                price_b = aux_price_per_unit and record_b.high_bid / record_b.aux_quantity or record_b.high_bid
            else
                price_b = aux_price_per_unit and record_b.start_price / record_b.aux_quantity or record_b.start_price
            end
            return aux.sort.compare(price_a, price_b, desc)
        end,
    },
    {
        title = {'Auction Buyout\n(per item)', 'Auction Buyout\n(per stack)'},
        width = 0.125,
        align = 'RIGHT',
        isPrice = true,
        set = function(cell, record)
            local price = aux_price_per_unit and ceil(record.unit_buyout_price) or record.buyout_price
            cell:SetText(price > 0 and aux.money.to_string(price, true, false) or '---')
        end,
        cmp = function(record_a, record_b, desc)
            local price_a = aux_price_per_unit and record_a.unit_buyout_price or record_a.buyout_price
            local price_b = aux_price_per_unit and record_b.unit_buyout_price or record_b.buyout_price
            price_a = price_a > 0 and price_a or (desc and -aux.huge or aux.huge)
            price_b = price_b > 0 and price_b or (desc and -aux.huge or aux.huge)

            return aux.sort.compare(price_a, price_b, desc)
        end,
    },
    {
        title = 'High Bidder',
        width = 0.21,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(record.high_bidder or m.colors.RED..'No Bids'..FONT_COLOR_CODE_CLOSE)
        end,
        cmp = function(record_a, record_b, desc)
            if not record_a.high_bidder and not record_b.high_bidder then
                return aux.sort.EQ
            elseif not record_a.high_bidder then
                return aux.sort.GT
            elseif not record_b.high_bidder then
                return aux.sort.LT
            else
                return aux.sort.compare(record_a.high_bidder, record_b.high_bidder, desc)
            end
        end,
    },
}

public.bids_config = {
    {
        title = 'Item',
        width = 0.35,
        init = m.item_column_init,
        set = function(cell, record, _, _, _, indented)
            cell.icon:SetTexture(record.texture)
            if indented then
                cell.spacer:SetWidth(10)
                cell.icon:SetAlpha(0.5)
                cell:GetFontString():SetAlpha(0.7)
            else
                cell.spacer:SetWidth(1)
                cell.icon:SetAlpha(1)
                cell:GetFontString():SetAlpha(1)
            end
            cell:SetText(gsub(record.hyperlink, '[%[%]]', ''))
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.name, record_b.name, desc)
        end,
    },
    {
        title = 'Auctions',
        width = 0.06,
        align = 'CENTER',
        set = function(cell, record, count, own, expandable)
            local numAuctionsText = expandable and aux.gui.inline_color.link..count..FONT_COLOR_CODE_CLOSE or count
            cell:SetText(numAuctionsText)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.EQ
            --            if sortKey == 'numAuctions' then
            --                if a.children then
            --                    aVal = a.totalAuctions
            --                    bVal = b.totalAuctions
            --                else
            --                    aVal = a.numAuctions
            --                    bVal = b.numAuctions
            --                end
            --            end
        end,
    },
    {
        title = 'Stack Size',
        width = 0.055,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(record.aux_quantity)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.aux_quantity, record_b.aux_quantity, desc)
        end,
    },
    {
        title = 'Time Left',
        width = 0.04,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(TIME_LEFT_STRINGS[record.duration or 0] or '---')
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.duration, record_b.duration, desc)
        end,
    },
    {
        title = 'Seller',
        width = 0.13,
        align = 'CENTER',
        set = function(cell, record)
            cell:SetText(aux.is_player(record.owner) and (m.colors.YELLOW..record.owner..FONT_COLOR_CODE_CLOSE) or (record.owner or '---'))
        end,
        cmp = function(record_a, record_b, desc)
            if not record_a.owner and not record_b.owner then
                return aux.sort.EQ
            elseif not record_a.owner then
                return aux.sort.GT
            elseif not record_b.owner then
                return aux.sort.LT
            else
                return aux.sort.compare(record_a.owner, record_b.owner, desc)
            end
        end,
    },
    {
        title = {'Auction Bid\n(per item)', 'Auction Bid\n(per stack)'},
        width = 0.125,
        align = 'RIGHT',
        isPrice = true,
        set = function(cell, record)
            local price
            if record.high_bidder then
                price = aux_price_per_unit and ceil(record.high_bid / record.aux_quantity) or record.high_bid
            else
                price = aux_price_per_unit and ceil(record.unit_bid_price) or record.bid_price
            end
            cell:SetText(aux.money.to_string(price))
        end,
        cmp = function(record_a, record_b, desc)
            local price_a
            if record_a.high_bidder then
                price_a = aux_price_per_unit and record_a.high_bid / record_a.aux_quantity or record_a.high_bid
            else
                price_a = aux_price_per_unit and record_a.unit_bid_price or record_a.bid_price
            end
            local price_b
            if record_b.high_bidder then
                price_b = aux_price_per_unit and record_b.high_bid / record_b.aux_quantity or record_b.high_bid
            else
                price_b = aux_price_per_unit and record_b.unit_bid_price or record_b.bid_price
            end
            return aux.sort.compare(price_a, price_b, desc)
        end,
    },
    {
        title = {'Auction Buyout\n(per item)', 'Auction Buyout\n(per stack)'},
        width = 0.125,
        align = 'RIGHT',
        isPrice = true,
        set = function(cell, record)
            local price = aux_price_per_unit and ceil(record.unit_buyout_price) or record.buyout_price
            cell:SetText(price > 0 and aux.money.to_string(price, true, false) or '---')
        end,
        cmp = function(record_a, record_b, desc)
            local price_a = aux_price_per_unit and record_a.unit_buyout_price or record_a.buyout_price
            local price_b = aux_price_per_unit and record_b.unit_buyout_price or record_b.buyout_price
            price_a = price_a > 0 and price_a or (desc and -aux.huge or aux.huge)
            price_b = price_b > 0 and price_b or (desc and -aux.huge or aux.huge)

            return aux.sort.compare(price_a, price_b, desc)
        end,
    },
    {
        title = 'Status',
        width = 0.115,
        align = 'CENTER',
        set = function(cell, record)
            local status
            if record.high_bidder then
                status = m.colors.YELLOW..'High Bidder'..FONT_COLOR_CODE_CLOSE
            else
                status = m.colors.RED..'Outbid'..FONT_COLOR_CODE_CLOSE
            end
            cell:SetText(status)
        end,
        cmp = function(record_a, record_b, desc)
            return aux.sort.compare(record_a.high_bidder and 1 or 0, record_b.high_bidder and 1 or 0, desc)
        end,
    },
}

function private.record_percentage(record)
    if not record then return end

    local historical_value = aux.history.value(record.item_key) or 0
    if historical_value > 0 then
        if record.unit_buyout_price > 0 then
            return aux.util.round(100 * record.unit_buyout_price / historical_value, 1)
        end
        return nil, aux.util.round(100 * record.unit_bid_price / historical_value, 1)
    end
end

function private.percentage_color(pct)
	for i=1,getn(AUCTION_PCT_COLORS) do
		if pct < AUCTION_PCT_COLORS[i].value then
			return AUCTION_PCT_COLORS[i].color
		end
	end
end

function public.percentage_historical(pct, bid)
    if pct > 10000 then
        pct = '>10000'
    end
    return (bid and m.colors.GRAY or m.percentage_color(pct))..pct..'%'..FONT_COLOR_CODE_CLOSE
end

function public.time_left(code)
    return TIME_LEFT_STRINGS[code]
end

local methods = {

    OnContentSizeChanged = function()
        local width = arg1
        local rt = this:GetParent()
        for _, cell in rt.headCells do
            cell:SetWidth(cell.info.width * width)
        end

        for _, row in rt.rows do
            for i, cell in row.cells do
                cell:SetWidth(rt.headCells[i].info.width * width)
            end
        end
    end,

    OnHeadColumnClick = function()
        local button = arg1
        local rt = this.rt
        if rt.disabled then return end

        if button == 'RightButton' and rt.headCells[this.columnIndex].info.isPrice then
            aux_price_per_unit = not aux_price_per_unit
            for _, cell in rt.headCells do
                if cell.info.isPrice then
                    cell:SetText(cell.info.title[aux_price_per_unit and 1 or 2])
                end
            end
            rt:SetSort()
            return
        end

        local descending = false
        if getn(rt.sorts) > 0 and rt.sorts[1].index == this.columnIndex then
            descending = not rt.sorts[1].descending
        end
        rt:SetSort((descending and -1 or 1) * this.columnIndex)
    end,

    OnIconEnter = function()
        local rt = this:GetParent().row.rt
        local rowData = this:GetParent().row.data
        if rowData and rowData.record then
            aux.info.set_tooltip(rowData.record.itemstring, this, 'ANCHOR_RIGHT')
            aux.info.set_shopping_tooltip(rowData.record.slot)
            rt.isShowingItemTooltip = true
        end
    end,

    OnIconLeave = function()
        GameTooltip:Hide()
        this:GetParent().row.rt.isShowingItemTooltip = nil
    end,

--    OnIconClick = function(self, ...)
--        if IsModifiedClick() then
--            HandleModifiedItemClick(self:GetParent().row.data.record.rawItemLink)
--        else
--            self:GetParent():GetScript("OnClick")(self:GetParent(), ...)
--        end
--    end,
--
--    OnIconDoubleClick = function(self, ...)
--        self:GetParent():GetScript("OnDoubleClick")(self:GetParent(), ...)
--    end,

    OnCellEnter = function()
        local rt = this.rt
        local row = this.row
        if rt.disabled then return end
        if this ~= row.cells[1] or not rt.isShowingItemTooltip then
            if rt.expanded[row.data.expandKey] then
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                GameTooltip:AddLine('Double-click to collapse this item and show only the cheapest auction.', 1, 1, 1, true)
                GameTooltip:Show()
            elseif row.data.expandable then
                GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                GameTooltip:AddLine('Double-click to expand this item and show all the auctions.', 1, 1, 1, true)
                GameTooltip:Show()
            end
        end

        -- show highlight for this row
        this.row.highlight:Show()
    end,

    OnCellLeave = function()
        GameTooltip:Hide()
        -- hide highlight if it's not selected
        if not this.rt.selected or this.rt.selected.search_signature ~= this.row.data.record.search_signature then
            this.row.highlight:Hide()
        end
    end,

    OnCellClick = function()
        local button = arg1
        if this.rt.disabled then return end
        if IsControlKeyDown() then
            DressUpItemLink(this.row.data.record.hyperlink)
        elseif IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
            ChatFrameEditBox:Insert(this.row.data.record.hyperlink)
        elseif not aux.modified() and button == 'RightButton' then -- TODO not when alt (how?)
            aux.tab_group:set_tab(1)
            aux.search_tab.set_filter(strlower(aux.info.item(this.row.data.record.item_id).name)..'/exact')
            aux.search_tab.execute(nil, false)
        else
            local selection = this.rt:GetSelection()
            if not selection or selection.record ~= this.row.data.record then
                this.rt:SetSelectedRecord(this.row.data.record)
            elseif this.rt.handlers.OnCellClick then
                this.rt.handlers.OnCellClick(this, button)
            end
        end
    end,

    OnCellDoubleClick = function()
        local rt = this.rt
        local rowData = this.row.data
        local expand = not rt.expanded[rowData.expandKey]
        if rt.disabled or expand and not rowData.expandable then return end

        rt.expanded[rowData.expandKey] = expand
        rt:UpdateRowInfo()
        rt:UpdateRows()
        -- select this row if it's not indented
        if not rowData.indented then
            rt:SetSelectedRecord(this.row.data.record)
        end
    end,


    -- ============================================================================
    -- Internal Results Table Methods
    -- ============================================================================

    UpdateRowInfo = function(self)
        aux.util.wipe(self.rowInfo)
        self.rowInfo.numDisplayRows = 0
        self.isSorted = nil
        self:SetSelectedRecord(nil, true)

        sort(self.records, function(a, b) return aux.sort.multi_lt({a.search_signature, tostring(a)}, {b.search_signature, tostring(b)}) end)

        local records = self.records
        if getn(records) == 0 then return end

        -- Populate the row info from the database by combining identical auctions and auctions
        -- of the same base item. Also, get the number of rows which will be shown.
        for i=1, getn(records) do
            local record = records[i]
            local prevRecord = records[i-1]
            if prevRecord and record.search_signature == prevRecord.search_signature then
                -- it's an identical auction to the previous row so increment the number of auctions
                self.rowInfo[getn(self.rowInfo)].children[getn(self.rowInfo[getn(self.rowInfo)].children)].numAuctions = self.rowInfo[getn(self.rowInfo)].children[getn(self.rowInfo[getn(self.rowInfo)].children)].numAuctions + 1
            elseif prevRecord and record.item_key == prevRecord.item_key then
                -- it's the same base item as the previous row so insert a new auction
                tinsert(self.rowInfo[getn(self.rowInfo)].children, {numAuctions=1, record=record})
                if self.expanded[self.rowInfo[getn(self.rowInfo)].expandKey] then
                    self.rowInfo.numDisplayRows = self.rowInfo.numDisplayRows + 1
                end
            else
                -- it's a different base item from the previous row
                tinsert(self.rowInfo, {item_key=record.item_key, expandKey=record.item_key, children={{numAuctions=1, record=record}}})
                self.rowInfo.numDisplayRows = self.rowInfo.numDisplayRows + 1
            end
        end

        for _, info in ipairs(self.rowInfo) do
            local totalAuctions, totalPlayerAuctions = 0, 0
            for _, childInfo in info.children do
                totalAuctions = totalAuctions + childInfo.numAuctions
                if aux.is_player(childInfo.record.owner) then
                    totalPlayerAuctions = totalPlayerAuctions + childInfo.numAuctions
                end
            end
            info.totalAuctions = totalAuctions
            info.totalPlayerAuctions = totalPlayerAuctions
        end
    end,

    UpdateRows = function(self)
        -- hide all the rows
        for _, row in self.rows do row:Hide() end

        -- update sorting highlights
        for _, cell in self.headCells do
            local tex = cell:GetNormalTexture()
            tex:SetTexture([[Interface\AddOns\aux-AddOn\WorldStateFinalScore-Highlight]])
            tex:SetTexCoord(0.017, 1, 0.083, 0.909)
            tex:SetAlpha(0.5)
        end

        if getn(self.sorts) > 0 then
            local last_sort = self.sorts[1]
            if last_sort.descending then
                self.headCells[last_sort.index]:GetNormalTexture():SetTexture(0.8, 0.6, 1, 0.8)
            else
                self.headCells[last_sort.index]:GetNormalTexture():SetTexture(0.6, 0.8, 1, 0.8)
            end
        end

        FauxScrollFrame_Update(self.scrollFrame, self.rowInfo.numDisplayRows, getn(self.rows), self.ROW_HEIGHT)

        -- make sure the offset is not too high
        local maxOffset = max(self.rowInfo.numDisplayRows - getn(self.rows), 0)
        if FauxScrollFrame_GetOffset(self.scrollFrame) > maxOffset then
            FauxScrollFrame_SetOffset(self.scrollFrame, maxOffset)
        end

        if not self.isSorted then
            local function sort_helper(a, b)

                local record_a, record_b
                if a.children then
                    record_a = a.children[1].record
                    record_b = b.children[1].record
                else
                    record_a = a.record
                    record_b = b.record
                end

                for _, sort in self.sorts do
                    local ordering = self.config[sort.index].cmp and self.config[sort.index].cmp(record_a, record_b, sort.descending) or aux.sort.EQ

                    if ordering == aux.sort.LT then
                        return true
                    elseif ordering == aux.sort.GT then
                        return false
                    end
                end

                return tostring(a) < tostring(b)
            end

            for _, info in ipairs(self.rowInfo) do
                sort(info.children, sort_helper)
            end
            sort(self.rowInfo, sort_helper)
            self.isSorted = true
        end

        -- update all the rows
        local rowIndex = 1 - FauxScrollFrame_GetOffset(self.scrollFrame)
        for _, info in ipairs(self.rowInfo) do
            if self.expanded[info.expandKey] then
                -- show each of the rows for this base item since it's expanded
                for i, childInfo in info.children do
                    self:SetRowInfo(rowIndex, childInfo.record, childInfo.numAuctions, 0, i > 1, false, info.expandKey, childInfo.numAuctions)
                    rowIndex = rowIndex + 1
                end
            else
                -- just show one row for this base item since it's not expanded
                self:SetRowInfo(rowIndex, info.children[1].record, info.totalAuctions, getn(info.children) > 1 and info.totalPlayerAuctions or 0, false, getn(info.children) > 1, info.expandKey, info.children[1].numAuctions)
                rowIndex = rowIndex + 1
            end
        end
    end,

    SetRowInfo = function(self, rowIndex, record, displayNumAuctions, numPlayerAuctions, indented, expandable, expandKey, numAuctions)
        if rowIndex <= 0 or rowIndex > getn(self.rows) then return end
        local row = self.rows[rowIndex]
        -- show this row
        row:Show()
        if self.selected and record.search_signature == self.selected.search_signature then
            row.highlight:Show()
        else
            row.highlight:Hide()
        end
        row.data = {record=record, expandable=expandable, indented=indented, numAuctions=numAuctions, expandKey=expandKey}

        for i, column_config in self.config do
            column_config.set(row.cells[i], record, displayNumAuctions, numPlayerAuctions, expandable, indented)
        end
    end,

    SetSelectedRecord = function(self, record, silent)
        if self.disabled then return end

        -- make sure the selected record still exists and get the data for the callback
        self.selected = record
        local selectedData = self:GetSelection()
        self.selected = selectedData and self.selected or nil

        -- show / hide highlight accordingly
        for _, row in self.rows do
            if self.selected and row.data and row.data.record.search_signature == self.selected.search_signature then
                row.highlight:Show()
            else
                row.highlight:Hide()
            end
        end

        if not silent and self.handlers.OnSelectionChanged and not self.scrollDisabled then
            self.handlers.OnSelectionChanged(self, selectedData or nil)
        end
    end,



    -- ============================================================================
    -- General Results Table Methods
    -- ============================================================================

    Reset = function(rt)
        aux.util.wipe(rt.expanded)
        rt:UpdateRowInfo()
        rt:UpdateRows()
        rt:SetSelectedRecord()
    end,

    SetDatabase = function(rt, database, filterFunc, filterHash)
        if database and database ~= rt.records then
            rt.records = database
        end

--            rt.dbView:SetFilter(filterFunc, filterHash)
--        elseif filterFunc then
--            rt.dbView:SetFilter(filterFunc, filterHash) -- TODO

        -- get index of selected row
        local prevSelectedIndex
        if rt.selected then
            for index, row in rt.rows do
                if row:IsVisible() and row.data and row.data.record == rt.selected then
                    prevSelectedIndex = index
                end
            end
        end

        rt:UpdateRowInfo()
        rt:UpdateRows()

        if not rt.selected and prevSelectedIndex then
            -- try to select the same row
            local row = rt.rows[prevSelectedIndex]
            if row and row:IsVisible() and row.data and row.data.record then
                rt:SetSelectedRecord(row.data.record)
            end
            if not rt.selected then
                -- select the first row
                row = rt.rows[1]
                if row and row:IsVisible() and row.data and row.data.record then
                    rt:SetSelectedRecord(row.data.record)
                end
            end
        end
    end,

    RemoveAuctionRecord = function(self, record)
        local index = aux.util.key(record, self.records)
        if index then
            tremove(self.records, index)
        end
        self:SetDatabase()
    end,

    RemoveSelectedRecord = function(self, count)
        count = count or 1
        for i=1, count do
            local index = aux.util.key(self.selected, self.records)
            if index then
                tremove(self.records, index)
            end
        end
        self:SetDatabase()
    end,

    InsertAuctionRecord = function(self, record, count)
        count = count or 1
        for i=1, count do
            tinsert(self.records, record)
        end
        self:SetDatabase()
    end,

    ContainsRecord = function(rt, record)
        if aux.util.key(record, rt.records) then
            return true
        end
    end,

    SetSort = function(self, ...)
        for k=1,arg.n do
            for i, sort in self.sorts do
                if sort.index == abs(arg[k]) then
                    tremove(self.sorts, i)
                    break
                end
            end
            tinsert(self.sorts, 1, { index = abs(arg[k]), descending = arg[k] < 0 })
        end

        self.isSorted = nil
        self:UpdateRows()
    end,

    SetScrollDisabled = function(self, disabled)
        self.scrollDisabled = disabled
    end,

    SetHandler = function(self, event, handler)
        self.handlers[event] = handler
    end,

    SetDisabled = function(self, disabled)
        self.disabled = disabled
        if not disabled then
            -- if there's only one item in the result, expand it
            if getn(self.rowInfo) == 1 and self.expanded[self.rowInfo[1].expandKey] == nil then
                self.expanded[self.rowInfo[1].expandKey] = true
                self.rowInfo.numDisplayRows = getn(self.rowInfo[1].children)
            end
            self:UpdateRows()
            -- select the first row
            self:SetSelectedRecord(getn(self.rowInfo) > 0 and self.rowInfo[1].children[1].record)
        end
    end,

    GetSelection = function(self)
        if not self.selected then return end
        local selectedData
        for _, info in ipairs(self.rowInfo) do
            for _, childInfo in info.children do
                if childInfo.record.search_signature == self.selected.search_signature then
                    selectedData = childInfo
                    break
                end
            end
        end
        return selectedData
    end,

    GetTotalAuctions = function(self)
        local numResults = 0
        for _, info in ipairs(self.rowInfo) do
            for _, childInfo in info.children do
                numResults = numResults + childInfo.numAuctions
            end
        end
        return numResults
    end,
}

function public.CreateAuctionResultsTable(parent, config)

    RT_COUNT = RT_COUNT + 1
    local rt = CreateFrame('Frame', nil, parent)
    rt.config = config
    local numRows = 16
    rt.ROW_HEIGHT = (parent:GetHeight() - HEAD_HEIGHT - HEAD_SPACE) / numRows
    rt.scrollDisabled = nil
    rt.expanded = {}
    rt.handlers = {}
    rt.sorts = {}
    rt.records = {}
    rt.rowInfo = {numDisplayRows=0}

    for name, func in methods do
        rt[name] = func
    end

    rt:SetScript('OnShow', function()
        for _, cell in this.headCells do
            if cell.info.isPrice then
                cell:SetText(cell.info.title[aux_price_per_unit and 1 or 2])
            end
        end
    end)

    local contentFrame = CreateFrame('Frame', nil, rt)
    contentFrame:SetPoint('TOPLEFT', 0, 0)
    contentFrame:SetPoint('BOTTOMRIGHT', -15, 0)
--    contentFrame:SetScript('OnSizeChanged', rt.OnContentSizeChanged)
    rt.contentFrame = contentFrame

    -- frame to hold the header columns and the rows
    local scrollFrame = CreateFrame('ScrollFrame', aux.gui.name(), rt, 'FauxScrollFrameTemplate')
    scrollFrame:SetScript('OnVerticalScroll', function()
        if not rt.scrollDisabled then
            FauxScrollFrame_OnVerticalScroll(rt.ROW_HEIGHT, function() rt:UpdateRows() end)
        end
    end)
    scrollFrame:SetAllPoints(contentFrame)
    rt.scrollFrame = scrollFrame
    FauxScrollFrame_Update(rt.scrollFrame, 0, numRows, rt.ROW_HEIGHT)

    local scrollBar = getglobal(scrollFrame:GetName()..'ScrollBar')
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint('BOTTOMRIGHT', rt, -4, 4)
    scrollBar:SetPoint('TOPRIGHT', rt, -4, -HEAD_HEIGHT)
    scrollBar:SetWidth(10)
    local thumbTex = scrollBar:GetThumbTexture()
    thumbTex:SetPoint('CENTER', 0, 0)
    thumbTex:SetTexture(unpack(aux.gui.color.content.backdrop))
    thumbTex:SetHeight(150)
    thumbTex:SetWidth(scrollBar:GetWidth())
    getglobal(scrollBar:GetName()..'ScrollUpButton'):Hide()
    getglobal(scrollBar:GetName()..'ScrollDownButton'):Hide()

    -- create the header cells
    rt.headCells = {}
    for i, column_config in rt.config do
        local cell = CreateFrame('Button', nil, rt.contentFrame)
        cell:SetHeight(HEAD_HEIGHT)
        if i == 1 then
            cell:SetPoint('TOPLEFT', 0, 0)
        else
            cell:SetPoint('TOPLEFT', rt.headCells[i-1], 'TOPRIGHT')
        end
        cell.info = column_config
        cell.rt = rt
        cell.columnIndex = i
        cell:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

        cell:SetScript('OnClick', rt.OnHeadColumnClick)

        local text = cell:CreateFontString()
        text:SetJustifyH('CENTER')
        text:SetJustifyV('CENTER')
        text:SetFont(aux.gui.config.font, 12)
        text:SetTextColor(unpack(aux.gui.color.label.enabled))
        cell:SetFontString(text)
        if not column_config.isPrice then cell:SetText(column_config.title or '') end -- TODO
        text:SetAllPoints()

        local tex = cell:CreateTexture()
        tex:SetAllPoints()
        tex:SetTexture([[Interface\AddOns\aux-AddOn\WorldStateFinalScore-Highlight]])
        tex:SetTexCoord(0.017, 1, 0.083, 0.909)
        tex:SetAlpha(0.5)
        cell:SetNormalTexture(tex)

        local tex = cell:CreateTexture()
        tex:SetAllPoints()
        tex:SetTexture([[Interface\Buttons\UI-Listbox-Highlight]])
        tex:SetTexCoord(0.025, 0.957, 0.087, 0.931)
        tex:SetAlpha(0.2)
        cell:SetHighlightTexture(tex)

        tinsert(rt.headCells, cell)
    end

    -- create the rows
    rt.rows = {}
    for i=1, numRows do
        local row = CreateFrame('Frame', nil, rt.contentFrame)
        row:SetHeight(rt.ROW_HEIGHT)
        if i == 1 then
            row:SetPoint('TOPLEFT', 0, -(HEAD_HEIGHT + HEAD_SPACE))
            row:SetPoint('TOPRIGHT', 0, -(HEAD_HEIGHT + HEAD_SPACE))
        else
            row:SetPoint('TOPLEFT', rt.rows[i-1], 'BOTTOMLEFT')
            row:SetPoint('TOPRIGHT', rt.rows[i-1], 'BOTTOMRIGHT')
        end
        local highlight = row:CreateTexture()
        highlight:SetAllPoints()
        highlight:SetTexture(1, .9, 0, .5)
        highlight:Hide()
        row.highlight = highlight
        row.rt = rt

        row.cells = {}
        for j=1, getn(rt.config) do
            local cell = CreateFrame('Button', nil, row)
            local text = cell:CreateFontString()
            text:SetFont(aux.gui.config.font, min(14, rt.ROW_HEIGHT))
            text:SetJustifyH(rt.config[j].align or 'LEFT')
            text:SetJustifyV('CENTER')
            text:SetPoint('TOPLEFT', 1, -1)
            text:SetPoint('BOTTOMRIGHT', -1, 1)
            cell:SetFontString(text)
            cell:SetHeight(rt.ROW_HEIGHT)
            cell:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
            cell:SetScript('OnEnter', rt.OnCellEnter)
            cell:SetScript('OnLeave', rt.OnCellLeave)
            cell:SetScript('OnClick', rt.OnCellClick)
            cell:SetScript('OnDoubleClick', rt.OnCellDoubleClick)
            cell.rt = rt
            cell.row = row

            if j == 1 then
                cell:SetPoint('TOPLEFT', 0, 0)
            else
                cell:SetPoint('TOPLEFT', row.cells[j-1], 'TOPRIGHT')
            end

            -- slightly different color for every alternating column
            if mod(j,2) == 1 then
                local tex = cell:CreateTexture()
                tex:SetAllPoints()
                tex:SetTexture(0.3, 0.3, 0.3, 0.2)
                cell:SetNormalTexture(tex)
            end

            if rt.config[j].init then
                rt.config[j].init(rt, cell)
            end

            tinsert(row.cells, cell)
        end

        -- slightly different color for every alternating
        if mod(i,2) == 0 then
            local tex = row:CreateTexture()
            tex:SetAllPoints()
            tex:SetTexture(0.3, 0.3, 0.3, 0.3)
        end

        tinsert(rt.rows, row)
    end

    rt:SetAllPoints()
    this = contentFrame -- TODO change, maybe use for resize without scrollbar?
    arg1 = contentFrame:GetWidth()
    rt:OnContentSizeChanged()
    return rt
end