local private, public = {}, {}
Aux.listing = public

local ST_COUNT = 0

local ST_ROW_HEIGHT = 15
local ST_ROW_TEXT_SIZE = 13
local ST_HEAD_HEIGHT = 27
local ST_HEAD_SPACE = 4
local DEFAULT_COL_INFO = {{width=1}}


local function GetTableIndex(tbl, value)
    for i, v in pairs(tbl) do
        if value == v then
            return i
        end
    end
end

local function OnColumnClick()
    local button = arg1
    if this.st.sortInfo.enabled and button == 'LeftButton' then
        if this.st.sortInfo.col == this.colNum then
            this.st.sortInfo.ascending = not this.st.sortInfo.ascending
        else
            this.st.sortInfo.col = this.colNum
            this.st.sortInfo.ascending = true
        end
        this.st.updateSort = true
        this.st:RefreshRows()
    end
    if this.st.handlers.OnColumnClick then
        this.st.handlers.OnColumnClick(this, button)
    end
end


local defaultColScripts = {
    OnEnter = function()
        this.row.mouseover = true
        if not this.row.data then return end
        if not this.st.highlightDisabled then
            this.row.highlight:Show()
        end

        local handler = this.st.handlers.OnEnter
        if handler then
            handler(this.st, this.row.data, this)
        end
    end,

    OnLeave = function()
        this.row.mouseover = false
        if not this.row.data then return end
        if this.st.selectionDisabled or not this.st.selected or this.st.selected ~= GetTableIndex(this.st.rowData, this.row.data) then
            this.row.highlight:Hide()
        end

        local handler = this.st.handlers.OnLeave
        if handler then
            handler(this.st, this.row.data, this)
        end
    end,

    OnClick = function()
        if not this.row.data then return end
        this.st:ClearSelection()
        this.st.selected = GetTableIndex(this.st.rowData, this.row.data)
        this.row.highlight:Show()

        local handler = this.st.handlers.OnClick
        if handler then
            handler(this.st, this.row.data, this, arg1)
        end
    end,

    OnDoubleClick = function()
        if not this.row.data then return end
        local handler = this.st.handlers.OnDoubleClick
        if handler then
            handler(this.st, this.row.data, this, arg1)
        end
    end,
}

local methods = {
    RefreshRows = function(st)
        if not st.rowData then return end
        FauxScrollFrame_Update(st.scrollFrame, getn(st.rowData), st.sizes.numRows, ST_ROW_HEIGHT)
        local offset = FauxScrollFrame_GetOffset(st.scrollFrame)
        st.offset = offset

        -- do sorting if enabled
        if st.sortInfo.enabled and st.sortInfo.col and st.updateSort then
            local function SortHelper(rowA, rowB)
                local sortArgA = rowA.cols[st.sortInfo.col].sortArg
                local sortArgB = rowB.cols[st.sortInfo.col].sortArg

                if st.sortInfo.ascending then
                    return sortArgA < sortArgB
                else
                    return sortArgA > sortArgB
                end
            end
            sort(st.rowData, SortHelper)
            st.updateSort = nil
        end

        -- set row data
        for i=1, st.sizes.numRows do
            st.rows[i].data = nil
            if i > getn(st.rowData) then
                st.rows[i]:Hide()
            else
                st.rows[i]:Show()
                local data = st.rowData[i + offset]
                if not data then break end
                st.rows[i].data = data

                if (st.selected == GetTableIndex(st.rowData, data) and not st.selectionDisabled)
                        or (st.highlighted and st.highlighted == GetTableIndex(st.rowData, data))
                        or st.rows[i].mouseover
                then
                    st.rows[i].highlight:Show()
                else
                    st.rows[i].highlight:Hide()
                end

                for colNum, col in ipairs(st.rows[i].cols) do
                    if st.colInfo[colNum] then
                        local colData = data.cols[colNum]
                        if type(colData.value) == 'function' then
                            col:SetText(colData.value(unpack(colData.args)))
                        else
                            col:SetText(colData.value)
                        end
                    end
                end
            end
        end
    end,

    SetData = function(st, rowData)
        st.rowData = rowData
        st.updateSort = true
        st:RefreshRows()
    end,

    SetSelection = function(st, predicate)
        st:ClearSelection()
        for i, rowDatum in st.rowData do
            if predicate(rowDatum) then
                    st.selected = i
                    st:RefreshRows()
                break
            end
        end
    end,

    GetSelection = function(st)
        return st.selected
    end,

    ClearSelection = function(st)
        st.selected = nil
        st:RefreshRows()
    end,

    DisableSelection = function(st, value)
        st.selectionDisabled = value
    end,

    EnableSorting = function(st, value, defaultCol)
        st.sortInfo.enabled = value
        st.sortInfo.col = abs(defaultCol or 1)
        st.sortInfo.ascending = not defaultCol or defaultCol > 0
        st.updateSort = true
        st:RefreshRows()
    end,

    DisableHighlight = function(st, value)
        st.highlightDisabled = value
    end,

    GetNumRows = function(st)
        return st.sizes.numRows
    end,

    SetScrollOffset = function(st, offset)
        local maxOffset = max(getn(st.rowData) - st.sizes.numRows, 0)
        if not offset or offset < 0 or offset > maxOffset then
            return -- invalid offset
        end

        local scrollPercent = offset / maxOffset
        local maxPixelOffset = st.scrollFrame:GetVerticalScrollRange() + ST_ROW_HEIGHT * 2
        local pixelOffset = scrollPercent * maxPixelOffset
        FauxScrollFrame_SetOffset(st.scrollFrame, offset)
        st.scrollFrame:SetVerticalScroll(pixelOffset)
    end,

    SetHighlighted = function(st, row)
        st.highlighted = row
        st:RefreshRows()
    end,

    Redraw = function(st)
        local width = st:GetWidth() - 14
        local height = st:GetHeight()

        if getn(st.colInfo) > 1 or st.colInfo[1].name then
            -- there is a header row
            st.sizes.headHeight = st.sizes.headFontSize and (st.sizes.headFontSize + 4) or ST_HEAD_HEIGHT
        else
            -- no header row
            st.sizes.headHeight = 0
        end
        st.sizes.numRows = max(floor((st:GetParent():GetHeight() - st.sizes.headHeight - ST_HEAD_SPACE) / ST_ROW_HEIGHT), 0)

        -- update the frame
        st.scrollBar:ClearAllPoints()
        st.scrollBar:SetPoint('BOTTOMRIGHT', st, -1, 1)
        st.scrollBar:SetPoint('TOPRIGHT', st, -1, -st.sizes.headHeight - ST_HEAD_SPACE)

        if st.sizes.headHeight > 0 then
            st.headLine:Show()
            st.headLine:ClearAllPoints()
            st.headLine:SetPoint('TOPLEFT', 2, -st.sizes.headHeight)
            st.headLine:SetPoint('TOPRIGHT', -2, -st.sizes.headHeight)
        else
            st.headLine:Hide()
        end

        -- update the first row
        if st.rows and st.rows[1] then
            st.rows[1]:SetPoint('TOPLEFT', 0, -(st.sizes.headHeight + ST_HEAD_SPACE))
            st.rows[1]:SetPoint('TOPRIGHT', 0, -(st.sizes.headHeight + ST_HEAD_SPACE))
        end

        -- add header columns if necessary
        while getn(st.headCols) < getn(st.colInfo) do
            st:AddColumn()
        end

        -- adjust head col widths
        for colNum, col in ipairs(st.headCols) do
            if st.colInfo[colNum] then
                col:Show()
                col:SetWidth(st.colInfo[colNum].width * width)
                col:SetHeight(st.sizes.headHeight)
                col:SetText(st.colInfo[colNum].name or "")
                col.text:SetJustifyH(st.colInfo[colNum].headAlign or 'CENTER')
            else
                col:Hide()
            end
        end

        -- add more rows if necessary
        while getn(st.rows) < st.sizes.numRows do
            st:AddRow()
        end

        -- adjust rows widths
        for rowNum, row in ipairs(st.rows) do
            if rowNum > st.sizes.numRows then
                row.data = nil
                row:Hide()
            else
                row:Show()
                -- add any missing cols
                while getn(row.cols) < getn(st.colInfo) do
                    st:AddRowCol(rowNum)
                end
                for colNum, col in ipairs(row.cols) do
                    if st.headCols[colNum] and st.colInfo[colNum] then
                        col:Show()
                        col:SetWidth(st.colInfo[colNum].width * width)
                        col.text:SetJustifyH(st.colInfo[colNum].align or 'LEFT')
                    else
                        col:Hide()
                    end
                end
            end
        end

        st:RefreshRows()
    end,

    AddColumn = function(st)
        local colNum = getn(st.headCols) + 1
        local col = CreateFrame('Button', st:GetName()..'HeadCol'..colNum, st.contentFrame)
        if colNum == 1 then
            col:SetPoint('TOPLEFT', 0, 0)
        else
            col:SetPoint('TOPLEFT', st.headCols[colNum - 1], 'TOPRIGHT')
        end
        col.st = st
        col.colNum = colNum
        col:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        col:SetScript('OnClick', OnColumnClick)

        local text = col:CreateFontString()
        text:SetJustifyV('CENTER')
        text:SetFont(Aux.gui.config.content_font, 15)
        text:SetTextColor(unpack(Aux.gui.config.text_color.enabled))
        col.text = text
        col:SetFontString(text)
        text:SetAllPoints()

        local tex = col:CreateTexture()
        tex:SetAllPoints()
        tex:SetTexture([[Interface\Buttons\UI-Listbox-Highlight]])
        tex:SetTexCoord(0.025, 0.957, 0.087, 0.931)
        tex:SetAlpha(0.2)
        col:SetHighlightTexture(tex)

        tinsert(st.headCols, col)

        -- add new cells to the rows
        for rowNum, row in ipairs(st.rows) do
            while getn(row.cols) < getn(st.headCols) do
                st:AddRowCol(rowNum)
            end
        end
    end,

    AddRowCol = function(st, rowNum)
        local row = st.rows[rowNum]
        local colNum = getn(row.cols) + 1
        local col = CreateFrame('Button', nil, row)
        local text = col:CreateFontString()
        text:SetFont(Aux.gui.config.content_font, ST_ROW_TEXT_SIZE)
        text:SetJustifyV('CENTER')
        text:SetPoint('TOPLEFT', 1, -1)
        text:SetPoint('BOTTOMRIGHT', -1, 1)
        col.text = text
        col:SetFontString(text)
        col:SetHeight(ST_ROW_HEIGHT)
        col:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        for name, func in pairs(defaultColScripts) do
            col:SetScript(name, func)
        end
        col.st = st
        col.row = row

        if colNum == 1 then
            col:SetPoint('TOPLEFT', 0, 0)
        else
            col:SetPoint('TOPLEFT', row.cols[colNum - 1], 'TOPRIGHT')
        end
        tinsert(row.cols, col)
    end,

    AddRow = function(st)
        local row = CreateFrame('Frame', nil, st.contentFrame)
        row:SetHeight(ST_ROW_HEIGHT)
        local rowNum = getn(st.rows) + 1
        if rowNum == 1 then
            row:SetPoint('TOPLEFT', 0, -(st.sizes.headHeight + ST_HEAD_SPACE))
            row:SetPoint('TOPRIGHT', 0, -(st.sizes.headHeight + ST_HEAD_SPACE))
        else
            row:SetPoint('TOPLEFT', 0, -(st.sizes.headHeight + ST_HEAD_SPACE + (rowNum - 1) * ST_ROW_HEIGHT))
            row:SetPoint('TOPRIGHT', 0, -(st.sizes.headHeight + ST_HEAD_SPACE + (rowNum - 1) * ST_ROW_HEIGHT))
        end
        local highlight = row:CreateTexture()
        highlight:SetAllPoints()
        highlight:SetTexture(1, .9, .9, .1)
        highlight:Hide()
        row.highlight = highlight
        row.st = st

        row.cols = {}
        st.rows[rowNum] = row
        for i=1, getn(st.colInfo) do
            st:AddRowCol(rowNum)
        end
    end,

    SetHandler = function(st, event, handler)
        st.handlers[event] = handler
    end,

    SetHeadFontSize = function(st, size)
        st.sizes.headFontSize = size
        -- update the text size of the head cols
        for _, col in ipairs(st.headCols) do
            if st.sizes.headFontSize then
                col.text:SetFont(Aux.gui.config.content_font, st.sizes.headFontSize)
            else
                col.text:SetFont(Aux.gui.config.content_font, 15)
            end
        end
        st:Redraw()
    end,

    SetColInfo = function(st, colInfo)
        colInfo = colInfo or DEFAULT_COL_INFO
--        TSMAPI:Assert(type(colInfo) == 'table' and type(colInfo[1]) == 'table', "Invalid colInfo argument.")
        st.colInfo = colInfo
        st:Redraw()
    end,
}

function public.CreateScrollingTable(parent)
    -- create the base frame
    ST_COUNT = ST_COUNT + 1
    local st = CreateFrame('Frame', 'TSMScrollingTable'..ST_COUNT, parent)
    st:SetAllPoints()
--    st:SetScript('OnSizeChanged', function() st:Redraw() end)

    local contentFrame = CreateFrame('Frame', nil, st)
    contentFrame:SetPoint('TOPLEFT', 0, 0)
    contentFrame:SetPoint('BOTTOMRIGHT', -15, 0)
    st.contentFrame = contentFrame

    -- frame to hold the header columns and the rows
    local scrollFrame = CreateFrame('ScrollFrame', st:GetName()..'ScrollFrame', st, 'FauxScrollFrameTemplate')
    scrollFrame:SetScript('OnVerticalScroll', function(self, offset)
        FauxScrollFrame_OnVerticalScroll(ST_ROW_HEIGHT, function() st:RefreshRows() end)
    end)
    scrollFrame:SetAllPoints(contentFrame)
    st.scrollFrame = scrollFrame

    -- make the scroll bar consistent with the TSM theme
    local scrollBar = getglobal(scrollFrame:GetName()..'ScrollBar')
    scrollBar:SetWidth(12)
    st.scrollBar = scrollBar
    local thumbTex = scrollBar:GetThumbTexture()
    thumbTex:SetPoint('CENTER', 0, 0)
    thumbTex:SetTexture(unpack(Aux.gui.config.content_color))
    thumbTex:SetHeight(50)
    thumbTex:SetWidth(12)
    getglobal(scrollBar:GetName()..'ScrollUpButton'):Hide()
    getglobal(scrollBar:GetName()..'ScrollDownButton'):Hide()

    -- create head line at default position
    st.headLine = Aux.gui.horizontal_line(st, 0)

    -- add all the methods
    for name, func in pairs(methods) do
        st[name] = func
    end

    -- setup default values
    st.isTSMScrollingTable = true
    st.sizes = {}
    st.headCols = {}
    st.rows = {}
    st.handlers = {}
    st.sortInfo = {enabled=nil}
    st.colInfo = DEFAULT_COL_INFO

    return st
end