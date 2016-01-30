local private, public = {}, {}
Aux.stack = public

local controller = (function()
	local controller
	return function()
		controller = controller or Aux.control.controller()
		return controller
	end
end)()

local state

function private.item_slots(item_key)
	local slots = Aux.util.inventory_iterator()
	return function()
        local slot
		repeat
			slot = slots()
		until slot == nil or private.item_key(slot) == item_key
		return slot
	end
end

function private.find_empty_slot()
	for slot in Aux.util.inventory_iterator() do
		if not GetContainerItemInfo(slot.bag, slot.bag_slot) then
			return slot
		end
	end
end

function private.find_charges_item_slot(item_key, charges)
	for slot in private.item_slots(item_key) do
		if private.item_charges(slot) == charges then
			return slot
		end
	end
end

function private.move_item(from_slot, to_slot, amount, k)
	local size_before = private.stack_size(to_slot)
		
	amount = min(private.max_stack(from_slot) - private.stack_size(to_slot), amount)
	
	ClearCursor()
	SplitContainerItem(from_slot.bag, from_slot.bag_slot, amount)
	PickupContainerItem(to_slot.bag, to_slot.bag_slot)
	
	return controller().wait(function() return private.stack_size(to_slot) == size_before + amount end, k)
end

function private.item_key(slot)
	local container_item_info = Aux.info.container_item(slot.bag, slot.bag_slot)
	return container_item_info and container_item_info.item_key
end

function private.stack_size(slot)
    local container_item_info = Aux.info.container_item(slot.bag, slot.bag_slot)
    return container_item_info and container_item_info.count or 0
end

function private.item_charges(slot)
    local container_item_info = Aux.info.container_item(slot.bag, slot.bag_slot)
	return container_item_info and container_item_info.charges
end

function private.process()

	if private.stack_size(state.target_slot) > state.target_size then
		local empty_slot = private.find_empty_slot()
		
		if empty_slot then
			return private.move_item(
				state.target_slot,
				empty_slot,
				private.stack_size(state.target_slot) - state.target_size,
				function()
					return private.process()
			end)
		else
			local next_slot = state.other_slots()
			if next_slot then
				return private.move_item(
					state.target_slot,
					next_slot,
					private.stack_size(state.target_slot) - state.target_size,
					function()
						return private.process()
				end)
			end
		end
	elseif private.stack_size(state.target_slot) < state.target_size then
		local next_slot = state.other_slots()
		if next_slot then
			return private.move_item(
				next_slot,
				state.target_slot,
				state.target_size - private.stack_size(state.target_slot),
				function()
					return private.process()
			end)
		end
	end
		
	return private.stop()
end

function private.max_stack(slot)
    local container_item_info = Aux.info.container_item(slot.bag, slot.bag_slot)
    return container_item_info and container_item_info.max_stack
end

function public.stop(k)
	Aux.control.on_next_update(function()
		private.stop()
		
		if k then
			return k()
		end
	end)
end

function private.stop()
	controller().reset()
	if state then
		local slot
		if state.target_slot and (private.stack_size(state.target_slot) == state.target_size or private.item_charges(state.target_slot) == state.target_size) then
			slot = state.target_slot
		end
		local callback = state.callback
		
		state = nil
		
		if callback then
			callback(slot)
		end
	end
end

function public.start(item_key, size, callback)
	Aux.control.on_next_update(function()
		private.stop()
		
		local slots = private.item_slots(item_key)
		local target_slot = slots()
		
		state = {
			target_size = size,
			target_slot = target_slot,
			other_slots = slots,
			callback = callback,
		}
		
		if not target_slot then
			return private.stop()
		elseif private.item_charges(target_slot) then
			state.target_slot = private.find_charges_item_slot(item_key, size)
			return private.stop()
		else
			return private.process()
		end
	end)
end