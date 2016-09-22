local m, public, private = aux.module'money'

private.GOLD_TEXT = '|cffffd70ag|r'
private.SILVER_TEXT = '|cffc7c7cfs|r'
private.COPPER_TEXT = '|cffeda55fc|r'

do
	local COPPER_PER_SILVER = 100
	local COPPER_PER_GOLD = 10000

	function public.gsc(money)
		local gold = floor(money / COPPER_PER_GOLD)
		local silver = floor(mod(money, COPPER_PER_GOLD) / COPPER_PER_SILVER)
		local copper = mod(money, COPPER_PER_SILVER)
		return gold, silver, copper
	end

	function public.copper(gold, silver, copper)
		return gold * COPPER_PER_GOLD + silver * COPPER_PER_SILVER + copper
	end
end

function public.format(money, exact, color)
	color = color or FONT_COLOR_CODE_CLOSE

	local TEXT_NONE = '0'

	local GOLD = 'ffd100'
	local SILVER = 'e6e6e6'
	local COPPER = 'c8602c'
	local START = '|cff%s%d'..FONT_COLOR_CODE_CLOSE
	local PART = color..'.|cff%s%02d'..FONT_COLOR_CODE_CLOSE
	local NONE = '|cffa0a0a0'..TEXT_NONE..FONT_COLOR_CODE_CLOSE

	if not exact and money >= 10000 then
		-- Round to nearest silver
		money = floor(money / 100 + 0.5) * 100
	end
	local g, s, c = aux.money.gsc(money)

	local str = ''

	local fmt = START
	if g > 0 then
		str = str..format(fmt, GOLD, g)
		fmt = PART
	end
	if s > 0 or c > 0 then
		str = str..format(fmt, SILVER, s)
		fmt = PART
	end
	if c > 0 then
		str = str..format(fmt, COPPER, c)
	end
	if str == '' then
		str = NONE
	end
	return str
end

--function public.to_string(params) -- TODOSS
--	local gold, silver, copper = m.gsc(params.copper or 0 + )
--	local settings = aux.util.set(unpack(arg))
--end

function public.to_string(money, pad, trim, decimal_points, color, no_color)
	local is_negative = money < 0
	money = abs(money)
	local gold, silver, copper = m.gsc(money)

	-- rounding
	if decimal_points then
		copper = tonumber(format('%.'..decimal_points..'f', copper))
	end

	local gold_text, silver_text, copper_text
	if no_color then
		gold_text, silver_text, copper_text = 'g', 's', 'c'
	else
		gold_text, silver_text, copper_text = m.GOLD_TEXT, m.SILVER_TEXT, m.COPPER_TEXT
	end
	
	local text
	if trim then
		local parts = {}
		if gold > 0 then
			tinsert(parts, m.format_number(gold, false, nil, color)..gold_text)
		end
		if silver > 0 then
			tinsert(parts, m.format_number(silver, pad, nil, color)..silver_text)
		end
		if copper > 0 or gold == 0 and silver == 0 then
			tinsert(parts, m.format_number(copper, pad, decimal_points, color)..copper_text)
		end
		text = aux.util.join(parts, ' ')
	else
		if gold > 0 then
			text = m.format_number(gold, false, nil, color)..gold_text..' '..m.format_number(silver, pad, nil, color)..silver_text..' '..m.format_number(copper, pad, decimal_points, color)..copper_text
		elseif silver > 0 then
			text = m.format_number(silver, false, nil, color)..silver_text..' '..m.format_number(copper, pad, decimal_points, color)..copper_text
		else
			text = m.format_number(copper, false, decimal_points, color)..copper_text
		end
	end
	
	if is_negative then
		if color then
			text = color..'-'..FONT_COLOR_CODE_CLOSE..text
		else
			text = '-'..text
		end
	end

	return text
end

function public.from_string(value)
	for _, number in {tonumber(value)} do
		return number * COPPER_PER_GOLD
	end

	-- remove any colors
	value = gsub(gsub(strlower(value), '|c%x%x%x%x%x%x%x%x', ''), FONT_COLOR_CODE_CLOSE, '')

	-- extract gold/silver/copper values
	local gold = tonumber(({strfind(value, '(%d*%.?%d+)g')})[3])
	local silver = tonumber(({strfind(value, '(%d*%.?%d+)s')})[3])
	local copper = tonumber(({strfind(value, '(%d*%.?%d+)c')})[3])
	if not gold and not silver and not copper then return end

	-- test that there are no extra characters (other than spaces)
	value = gsub(value, '%d*%.?%d+g', '', 1)
	value = gsub(value, '%d*%.?%d+s', '', 1)
	value = gsub(value, '%d*%.?%d+c', '', 1)
	if strfind(value, '%S') then return end
	
	return m.copper(gold or 0, silver or 0, copper or 0)
end

function public.format_number(num, pad, decimal_padding, color)
	local padding = pad and 2 + (decimal_padding and decimal_padding + 1 or 0) or 0
	num = format('%0'..padding..'.0'..(decimal_padding or 0)..'f', num)
	if color then
		return color..num..FONT_COLOR_CODE_CLOSE
	else
		return num
	end
end