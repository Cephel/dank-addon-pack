local m, public, private = aux.module'scan_util'

function public.find(auction_record, status_bar, on_abort, on_failure, on_success)

    local function test(index)
        local auction_info = aux.info.auction(index, auction_record.query_type)
        return auction_info and auction_info.search_signature == auction_record.search_signature
    end

    local queries = {}
    tinsert(queries, {})

    if auction_record.blizzard_query then

        local blizzard_query1 = aux.util.copy(auction_record.blizzard_query)
        blizzard_query1.first_page = auction_record.page
        blizzard_query1.last_page = auction_record.page
        tinsert(queries, {
            blizzard_query = blizzard_query1,
        })

        if auction_record.page > 0 then
            local blizzard_query2 = aux.util.copy(auction_record.blizzard_query)
            blizzard_query2.first_page = auction_record.page - 1
            blizzard_query2.last_page = auction_record.page - 1
            tinsert(queries, {
                blizzard_query = blizzard_query1,
            })
        end

        local item_query = m.item_query(auction_record.item_id, 1, 1)
        if not aux.util.eq(auction_record.blizzard_query, item_query.blizzard_query) then
            tinsert(queries, item_query)
        end
    end


    local found
    return aux.scan.start{
        type = auction_record.query_type,
        queries = queries,
        on_scan_start = function()
            status_bar:update_status(0, 0)
            status_bar:set_text('Searching auction...')
        end,
        on_start_query = function(query_index)
            status_bar:update_status((query_index - 1) / getn(queries) * 100, 0)
        end,
        on_auction = function(auction_record, ctrl)
            if test(auction_record.index) then
                found = true
                ctrl.suspend()
                status_bar:update_status(100, 100)
                status_bar:set_text('Auction found')
                return on_success(auction_record.index)
            end
        end,
        on_abort = function()
            if not found then
                status_bar:update_status(100, 100)
                status_bar:set_text('Auction not found')
                return on_abort()
            end
        end,
        on_complete = function()
            status_bar:update_status(100, 100)
            status_bar:set_text('Auction not found')
            return on_failure()
        end,
    }
end

function public.item_query(item_id, first_page, last_page)

    local item_info = aux.info.item(item_id)

    if item_info then
        local query = aux.filter.query(item_info.name..'/exact')
        query.blizzard_query.first_page = first_page
        query.blizzard_query.last_page = last_page
        return {
            validator = query.validator,
            blizzard_query = query.blizzard_query,
        }
    end
end