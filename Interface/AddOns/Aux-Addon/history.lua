local private, public = {}, {}
Aux.history = public

local history_schema = {'record', '#', {next_push='number'}, {daily_min_buyout='number'}, {daily_max_price='number'}, {data_points={'list', ';', {'record', '@', {market_value='number'}, {time='number'}}}}}
private.value_cache = {}

function private.next_push()
	local date = date('*t')
	date.hour, date.min, date.sec = 24, 0, 0
	return time(date)
end

function private.new_record()
	return { next_push = private.next_push(), data_points = {} }
end

function private.load_data()
	local dataset = Aux.persistence.load_dataset()
	dataset.history = dataset.history or {}
	return dataset.history
end

function private.read_record(item_key)
	local data = private.load_data()

	local record
	if data[item_key] then
		record = Aux.persistence.read(history_schema, data[item_key])
	else
		record = private.new_record()
	end

	if record.next_push <= time() then
		private.push_record(record)
		private.write_record(item_key, record)
	end

	return record
end

function private.write_record(item_key, record)
	private.value_cache[item_key] = nil
	local data = private.load_data()
	data[item_key] = Aux.persistence.write(history_schema, record)
end

function public.process_auction(auction_record)
	local item_record = private.read_record(auction_record.item_key)

	local unit_bid_price = ceil(auction_record.bid_price / auction_record.aux_quantity)
	local unit_buyout_price = ceil(auction_record.buyout_price / auction_record.aux_quantity)

	if auction_record.buyout_price > 0 then
		item_record.daily_min_buyout = item_record.daily_min_buyout and min(item_record.daily_min_buyout, unit_buyout_price) or unit_buyout_price
	end

	item_record.daily_max_price = max(item_record.daily_max_price or 0, unit_buyout_price, unit_bid_price)

	private.write_record(auction_record.item_key, item_record)
end

function public.price_data(item_key)
	local item_record = private.read_record(item_key)
	return item_record.daily_min_buyout, item_record.daily_max_price, item_record.data_points
end

function public.value(item_key)
	if not private.value_cache[item_key] or private.value_cache[item_key].next_push <= time() then
		local item_record = private.read_record(item_key)

		local value
		if getn(item_record.data_points) > 0 then
			local weighted_values = {}
			local total_weight = 0
			for _, data_point in item_record.data_points do
				local weight = 0.99^Aux.round((item_record.data_points[1].time - data_point.time) / (60*60*24))
				total_weight = total_weight + weight
				tinsert(weighted_values, {value = data_point.market_value, weight = weight})
			end
			for _, weighted_value in weighted_values do
				weighted_value.weight = weighted_value.weight / total_weight
			end

			value = private.weighted_median(weighted_values)
		else
			value = private.market_value(item_record)
		end

		private.value_cache[item_key] = {value=value, next_push=item_record.next_push}
	end

	return private.value_cache[item_key].value
end

function public.market_value(item_key)
	local item_record = private.read_record(item_key)
	return private.market_value(item_record)
end

function private.market_value(item_record)
	return item_record.daily_min_buyout and min(ceil(item_record.daily_min_buyout * 1.15), item_record.daily_max_price)
end

function private.weighted_median(list)
	local sorted_list = {}
	for _, e in list do
		tinsert(sorted_list, e)
	end
	sort(sorted_list, function(a,b) return a.value < b.value end)

	local weight = 0
	for _, element in sorted_list do
		weight = weight + element.weight
		if weight >= 0.5 then
			return element.value
		end
	end
end

function private.push_record(item_record)

	local market_value = private.market_value(item_record)
	if market_value then
		tinsert(item_record.data_points, 1, { market_value = market_value, time = item_record.next_push })
		while getn(item_record.data_points) > 11 do
			tremove(item_record.data_points)
		end
	end

	item_record.daily_min_buyout = nil
	item_record.daily_max_price = nil
	item_record.next_push = private.next_push()
end