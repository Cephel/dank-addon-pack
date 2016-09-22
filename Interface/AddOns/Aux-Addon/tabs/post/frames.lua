local m, public, private = aux.module'post_tab'

function private.create_frames()
	private.frame = CreateFrame('Frame', nil, aux.frame)
	m.frame:SetAllPoints()
	m.frame:SetScript('OnUpdate', m.on_update)
	m.frame:Hide()

	m.frame.content = CreateFrame('Frame', nil, m.frame)
	m.frame.content:SetPoint('TOP', aux.frame, 'TOP', 0, -8)
	m.frame.content:SetPoint('BOTTOMLEFT', aux.frame.content, 'BOTTOMLEFT', 0, 0)
	m.frame.content:SetPoint('BOTTOMRIGHT', aux.frame.content, 'BOTTOMRIGHT', 0, 0)

	m.frame.inventory = aux.gui.panel(m.frame.content)
	m.frame.inventory:SetWidth(212)
	m.frame.inventory:SetPoint('TOPLEFT', 0, 0)
	m.frame.inventory:SetPoint('BOTTOMLEFT', 0, 0)

	m.frame.parameters = aux.gui.panel(m.frame.content)
	m.frame.parameters:SetHeight(173)
	m.frame.parameters:SetPoint('TOPLEFT', m.frame.inventory, 'TOPRIGHT', 2.5, 0)
	m.frame.parameters:SetPoint('TOPRIGHT', 0, 0)

	m.frame.auctions = aux.gui.panel(m.frame.content)
	m.frame.auctions:SetHeight(228)
	m.frame.auctions:SetPoint('BOTTOMLEFT', m.frame.inventory, 'BOTTOMRIGHT', 2.5, 0)
	m.frame.auctions:SetPoint('BOTTOMRIGHT', 0, 0)

	do
	    local checkbox = aux.gui.checkbox(m.frame.inventory)
	    checkbox:SetPoint('TOPLEFT', 49, -16)
	    checkbox:SetScript('OnClick', function()
	        m.refresh = true
	    end)
	    local label = aux.gui.label(checkbox, aux.gui.config.small_font_size)
	    label:SetPoint('LEFT', checkbox, 'RIGHT', 4, 1)
	    label:SetText('Show hidden items')
	    private.show_hidden_checkbox = checkbox
	end

	aux.gui.horizontal_line(m.frame.inventory, -48)

	private.item_listing = aux.item_listing.create(
	    m.frame.inventory,
	    function()
	        if arg1 == 'LeftButton' then
	            m.set_item(this.item_record)
	        elseif arg1 == 'RightButton' then
	            aux.tab_group:set_tab(1)
	            aux.search_tab.set_filter(strlower(aux.info.item(this.item_record.item_id).name)..'/exact')
	            aux.search_tab.execute(nil, false)
	        end
	    end,
	    function(item_record)
	        return item_record == m.selected_item
	    end
	)

	private.auction_listing = aux.listing.CreateScrollingTable(m.frame.auctions)
	m.auction_listing:SetColInfo({
	    { name='Auctions', width=.12, align='CENTER' },
	    { name='Left', width=.1, align='CENTER' },
	    { name='Qty', width=.08, align='CENTER' },
	    { name='Bid/ea', width=.22, align='RIGHT' },
	    { name='Bid Pct', width=.13, align='CENTER' },
	    { name='Buy/ea', width=.22, align='RIGHT' },
	    { name='Buy Pct', width=.13, align='CENTER' }
	})
	m.auction_listing:EnableSorting(false)
	m.auction_listing:DisableSelection(true)
	m.auction_listing:SetHandler('OnClick', function(table, row_data, column, button)
	    local column_index = aux.util.key(column, column.row.cols)
	    local unit_start_price, unit_buyout_price = m.undercut(row_data.record, m.stack_size_slider:GetValue(), button == 'RightButton')
	    if column_index == 3 then
	        m.stack_size_slider:SetValue(row_data.record.stack_size)
	    elseif column_index == 4 then
	        m.set_unit_start_price(unit_start_price)
	    elseif column_index == 6 then
	        m.set_unit_buyout_price(unit_buyout_price)
	    end
	end)

	do
	    local status_bar = aux.gui.status_bar(m.frame)
	    status_bar:SetWidth(265)
	    status_bar:SetHeight(25)
	    status_bar:SetPoint('TOPLEFT', aux.frame.content, 'BOTTOMLEFT', 0, -6)
	    status_bar:update_status(100, 100)
	    status_bar:set_text('')
	    private.status_bar = status_bar
	end
	do
	    local btn = aux.gui.button(m.frame.parameters, 16)
	    btn:SetPoint('TOPLEFT', m.status_bar, 'TOPRIGHT', 5, 0)
	    btn:SetWidth(80)
	    btn:SetHeight(24)
	    btn:SetText('Post')
	    btn:SetScript('OnClick', m.post_auctions)
	    private.post_button = btn
	end
	do
	    local btn = aux.gui.button(m.frame.parameters, 16)
	    btn:SetPoint('TOPLEFT', m.post_button, 'TOPRIGHT', 5, 0)
	    btn:SetWidth(80)
	    btn:SetHeight(24)
	    btn:SetText('Refresh')
	    btn:SetScript('OnClick', function()
	        aux.scan.abort(m.scan_id)
	        m.refresh_entries()
	        m.refresh = true
	    end)
	    private.refresh_button = btn
	end
	do
	    local item = aux.gui.item(m.frame.parameters)
	    item:SetPoint('TOPLEFT', 6, -6)
	    item.button:SetScript('OnEnter', function()
	        if m.selected_item then
	            aux.info.set_tooltip(m.selected_item.itemstring, this, 'ANCHOR_RIGHT')
	        end
	    end)
	    item.button:SetScript('OnLeave', function()
	        GameTooltip:Hide()
	    end)
	    private.item = item
	end
	do
	    local slider = aux.gui.slider(m.frame.parameters)
	    slider:SetValueStep(1)
	    slider:SetPoint('TOPLEFT', 13, -73)
	    slider:SetWidth(190)
	    slider:SetScript('OnValueChanged', function()
	        m.quantity_update(true)
	    end)
	    slider.editbox:SetScript('OnTextChanged', function()
	        slider:SetValue(this:GetNumber())
	        m.quantity_update(true)
	        if m.selected_item then
	            local settings = m.read_settings()
	            settings.stack_size = this:GetNumber()
	            m.write_settings(settings)
	        end
	    end)
	    slider.editbox:SetScript('OnTabPressed', function()
	        if IsShiftKeyDown() then
	            m.unit_buyout_price:SetFocus()
	        elseif m.stack_count_slider.editbox:IsVisible() then
	            m.stack_count_slider.editbox:SetFocus()
	        else
	            m.unit_start_price:SetFocus()
	        end
	    end)
	    slider.editbox:SetNumeric(true)
	    slider.editbox:SetMaxLetters(3)
	    slider.label:SetText('Stack Size')
	    private.stack_size_slider = slider
	end
	do
	    local slider = aux.gui.slider(m.frame.parameters)
	    slider:SetValueStep(1)
	    slider:SetPoint('TOPLEFT', m.stack_size_slider, 'BOTTOMLEFT', 0, -30)
	    slider:SetWidth(190)
	    slider:SetScript('OnValueChanged', function()
	        m.quantity_update()
	    end)
	    slider.editbox:SetScript('OnTextChanged', function()
	        slider:SetValue(this:GetNumber())
	        m.quantity_update()
	    end)
	    slider.editbox:SetScript('OnTabPressed', function()
	        if IsShiftKeyDown() then
	            m.stack_size_slider.editbox:SetFocus()
	        else
	            m.unit_start_price:SetFocus()
	        end
	    end)
	    slider.editbox:SetNumeric(true)
	    slider.label:SetText('Stack Count')
	    private.stack_count_slider = slider
	end
	do
	    local dropdown = aux.gui.dropdown(m.frame.parameters)
	    dropdown:SetPoint('TOPLEFT', m.stack_count_slider, 'BOTTOMLEFT', 0, -21)
	    dropdown:SetWidth(90)
	    local label = aux.gui.label(dropdown, aux.gui.config.small_font_size)
	    label:SetPoint('BOTTOMLEFT', dropdown, 'TOPLEFT', -2, -1)
	    label:SetText('Duration')
	    UIDropDownMenu_Initialize(dropdown, m.initialize_duration_dropdown)
	    dropdown:SetScript('OnShow', function()
	        UIDropDownMenu_Initialize(this, m.initialize_duration_dropdown)
	    end)
	    local label = aux.gui.label(dropdown, aux.gui.config.medium_font_size)
	    label:SetPoint('LEFT', dropdown, 'RIGHT', 25, 0)
	    private.deposit = label
	    private.duration_dropdown = dropdown
	end
	do
	    local checkbox = aux.gui.checkbox(m.frame.parameters)
	    checkbox:SetPoint('TOPRIGHT', -83, -6)
	    checkbox:SetScript('OnClick', function()
	        local settings = m.read_settings()
	        settings.hidden = this:GetChecked()
	        m.write_settings(settings)
	        m.refresh = true
	    end)
	    local label = aux.gui.label(checkbox, aux.gui.config.small_font_size)
	    label:SetPoint('LEFT', checkbox, 'RIGHT', 4, 1)
	    label:SetText('Hide this item')
	    private.hide_checkbox = checkbox
	end
	do
	    local frame = CreateFrame('Frame', nil, m.frame.parameters)
	    private.start_price_frame = frame
	    aux.gui.set_content_style(frame)
	    frame:SetPoint('TOPRIGHT', -71, -50)
	    frame:SetWidth(180)
	    frame:SetHeight(22)
	    local editbox = aux.gui.editbox(frame)
	    editbox:SetAllPoints()
	    editbox:SetJustifyH('RIGHT')
	    editbox:SetFont(aux.gui.config.font, 17)
	    editbox:SetScript('OnTextChanged', function()
	        this.pretty:SetText(aux.money.to_string(m.get_unit_start_price(), true, nil, 3))
	        m.refresh = true
	    end)
	    editbox:SetScript('OnTabPressed', function()
	        if IsShiftKeyDown() and m.stack_count_slider.editbox:IsVisible() then
	            m.stack_count_slider.editbox:SetFocus()
	        elseif IsShiftKeyDown() then
	            m.stack_size_slider.editbox:SetFocus()
	        else
	            m.unit_buyout_price:SetFocus()
	        end
	    end)
	    editbox:SetScript('OnEditFocusGained', function()
	        this:HighlightText()
	        this.pretty:Hide()
	        this:SetAlpha(1)
	    end)
	    editbox:SetScript('OnEditFocusLost', function()
	        this:SetText(aux.money.to_string(m.get_unit_start_price(), true, nil, 3, nil, true))
	        this.pretty:Show()
	        this:SetAlpha(0)
	    end)
	    editbox:SetAlpha(0)
	    editbox.pretty = aux.gui.label(frame, 17)
	    editbox.pretty:SetPoint('LEFT', 1, 0)
	    editbox.pretty:SetPoint('RIGHT', -2, 0)
	    editbox.pretty:SetJustifyH('RIGHT')
	    do
	        local label = aux.gui.label(frame, aux.gui.config.small_font_size)
	        label:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', -2, 1)
	        label:SetText('Unit Starting Price')
	    end
	    do
	        local label = aux.gui.label(frame, 14)
	        label:SetPoint('LEFT', frame, 'RIGHT', 8, 0)
	        label:SetWidth(50)
	        label:SetJustifyH('CENTER')
	        private.start_price_percentage = label
	    end
	    private.unit_start_price = editbox
	end
	do
	    local frame = CreateFrame('Frame', nil, m.frame.parameters)
	    private.buyout_price_frame = frame
	    aux.gui.set_content_style(frame)
	    frame:SetPoint('TOPRIGHT', m.unit_start_price, 'BOTTOMRIGHT', 0, -19)
	    frame:SetWidth(180)
	    frame:SetHeight(22)
	    local editbox = aux.gui.editbox(frame)
	    editbox:SetAllPoints()
	    editbox:SetJustifyH('RIGHT')
	    editbox:SetFont(aux.gui.config.font, 17)
	    editbox:SetScript('OnTextChanged', function()
	        this.pretty:SetText(aux.money.to_string(m.get_unit_buyout_price(), true, nil, 3))
	        m.refresh = true
	    end)
	    editbox:SetScript('OnTabPressed', function()
	        if IsShiftKeyDown() then
	            m.unit_start_price:SetFocus()
	        else
	            m.stack_size_slider.editbox:SetFocus()
	        end
	    end)
	    editbox:SetScript('OnEnterPressed', function()
	        this:ClearFocus()
	    end)
	    editbox:SetScript('OnEditFocusGained', function()
	        this:HighlightText()
	        this.pretty:Hide()
	        this:SetAlpha(1)
	    end)
	    editbox:SetScript('OnEditFocusLost', function()
	        this:SetText(aux.money.to_string(m.get_unit_buyout_price(), true, nil, 3, nil, true))
	        this.pretty:Show()
	        this:SetAlpha(0)
	    end)
	    editbox:SetAlpha(0)
	    editbox.pretty = aux.gui.label(frame, 17)
	    editbox.pretty:SetPoint('LEFT', 1, 0)
	    editbox.pretty:SetPoint('RIGHT', -2, 0)
	    editbox.pretty:SetJustifyH('RIGHT')
	    do
	        local label = aux.gui.label(frame, aux.gui.config.small_font_size)
	        label:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', -2, 1)
	        label:SetText('Unit Buyout Price')
	    end
	    do
	        local label = aux.gui.label(frame, 14)
	        label:SetPoint('LEFT', frame, 'RIGHT', 8, 0)
	        label:SetWidth(50)
	        label:SetJustifyH('CENTER')
	        private.buyout_price_percentage = label
	    end
	    private.unit_buyout_price = editbox
	end
	do
	    local btn = aux.gui.button(m.frame.parameters, 14)
	    btn:SetPoint('TOPRIGHT', -14, -146)
	    btn:SetWidth(150)
	    btn:SetHeight(20)
	    btn:GetFontString():SetJustifyH('RIGHT')
	    btn:GetFontString():SetPoint('RIGHT', -2, 0)
	    btn:SetScript('OnClick', function()
	        if this.amount then
	            m.set_unit_start_price(this.amount)
	            m.set_unit_buyout_price(this.amount)
	        end
	    end)
	    local label = aux.gui.label(btn, aux.gui.config.small_font_size)
	    label:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT', -2, 1)
	    label:SetText('Historical Value')
	    private.historical_value_button = btn
	end
end