local private, public = {}, {}
Aux.persistence = public

aux_datasets = {}

function public.on_load()
    Aux.control.as_soon_as(function() private.faction = UnitFactionGroup('player') return private.faction end, Aux.util.pass)
    private.realm = GetCVar('realmName')
end

function private.get_dataset_key()
	return private.realm..'|'..private.faction
end

function public.load_dataset()
    local dataset_key = private.get_dataset_key()
    aux_datasets[dataset_key] = aux_datasets[dataset_key] or {}
    return aux_datasets[dataset_key]
end

function public.read(schema, str)
    if schema == 'string' then
        return str
    elseif schema == 'boolean' then
        return str == '1'
    elseif schema == 'number' then
        return tonumber(str)
    elseif type(schema) == 'table' and schema[1] == 'list' then
        return public.read_list(schema, str)
    elseif type(schema) == 'table' and schema[1] == 'record' then
        return public.read_record(schema, str)
    else
        error('Unknown schema.')
    end
end

function public.write(schema, obj)
    if schema == 'string' then
        return obj or ''
    elseif schema == 'boolean' then
        return obj and '1' or '0'
    elseif schema == 'number' then
        return obj and tostring(obj) or ''
    elseif type(schema) == 'table' and schema[1] == 'list' then
        return public.write_list(schema, obj)
    elseif type(schema) == 'table' and schema[1] == 'record' then
        return public.write_record(schema, obj)
    else
        error('Unknown schema.')
    end
end

function public.read_list(schema, str)
    if str == '' then
        return {}
    end

    local separator = schema[2]
    local element_type = schema[3]
    local parts = Aux.util.split(str, separator)
    return Aux.util.map(parts, function(part)
        return public.read(element_type, part)
    end)
end

function public.write_list(schema, list)
    local separator = schema[2]
    local element_type = schema[3]
    local parts = Aux.util.map(list, function(element)
        return public.write(element_type, element)
    end)
    return Aux.util.join(parts, separator)
end

function public.read_record(schema, str)
    local separator = schema[2]
    local record = {}
    local parts = Aux.util.split(str, separator)
    for i=3,getn(schema) do
        local key, type = next(schema[i])
        record[key] = public.read(type, parts[i - 2])
    end
    return record
end

function public.write_record(schema, record)
    local separator = schema[2]
    local parts = {}
    for i=3,getn(schema) do
        local key, type = next(schema[i])
        tinsert(parts, public.write(type, record[key]))
    end
    return Aux.util.join(parts, separator)
end

function public.serialize(data, separator, compactor)

    local data_string = ''
    local i = 1
    while i <= getn(data) do
        local element, count = data[i], 1
        while compactor and data[i + 1] == element do
            count = count + 1
            i = i + 1
        end
        local part = count > 1 and element..compactor..count or element
        data_string = data_string..(i == 1 and '' or separator)..part
        i = i + 1
    end

    return data_string
end

function public.deserialize(data_string, separator, compactor)
    if not data_string or data_string == '' then
        return {}
    end

    local data = {}
    while true do
        local start_index, _ = strfind(data_string, separator, 1, true)

        local part
        if start_index then
            part = string.sub(data_string, 1, start_index - 1)
            data_string = string.sub(data_string, start_index + 1, strlen(data_string))
        else
            part = string.sub(data_string, 1, strlen(data_string))
        end

        if compactor and strfind(part, compactor, 1, true) then
            local compactor_index, _ = strfind(part, compactor, 1, true)
            for i=1, tonumber(string.sub(part, compactor_index + 1, strlen(part))) do
               tinsert(data, string.sub(part, 1, compactor_index - 1))
            end
        else
            tinsert(data, part)
        end

        if not start_index then
            return data
        end
    end
end