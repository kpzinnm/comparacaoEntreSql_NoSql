#!/usr/bin/env sysbench

function event()
    -- Define intervalo aleatório
    local start_id = math.random(1, sysbench.opt.table_size - 100)
    local end_id = start_id + 100
    -- SELECT por intervalo
    db_query("SELECT id, c, k FROM sbtest" .. sysbench.tid .. " WHERE id BETWEEN " .. start_id .. " AND " .. end_id)
end
