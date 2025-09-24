#!/usr/bin/env sysbench

function event()
    -- Escolhe um ID aleatório
    local id = math.random(1, sysbench.opt.table_size)
    -- JOIN + agregação
    db_query([[
        SELECT a.id, a.c, AVG(b.k) as avg_k
        FROM sbtest]] .. sysbench.tid .. [[ a
        JOIN sbtest_related]] .. sysbench.tid .. [[ b
        ON a.id = b.sbtest_id
        WHERE a.id = ]] .. id .. [[
        GROUP BY a.id, a.c
    ]])
end
