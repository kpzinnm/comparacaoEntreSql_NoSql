#!/usr/bin/env sysbench

function event()
    -- Escolhe um ID aleatório
    local id = math.random(1, sysbench.opt.table_size)
    -- SELECT simples
    db_query("SELECT c FROM sbtest" .. sysbench.tid .. " WHERE id=" .. id)
end
