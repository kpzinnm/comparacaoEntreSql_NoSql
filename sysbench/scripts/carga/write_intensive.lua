-- ./sysbench/scripts/write_intensive.lua
#!/usr/bin/env sysbench

function event()
    local r = math.random()
    
    if r < 0.1 then
        local id = math.random(1, sysbench.opt.table_size)
        db_query("SELECT c FROM sbtest" .. sysbench.tid .. " WHERE id=" .. id)
    elseif r < 0.4 then
        local id = math.random(1, sysbench.opt.table_size)
        db_query("UPDATE sbtest" .. sysbench.tid .. " SET k=k+1 WHERE id=" .. id)
    else
        local k = math.random(1, sysbench.opt.table_size)
        local c = sysbench.rand.string(50)
        db_query("INSERT INTO sbtest" .. sysbench.tid .. " (k, c, pad) VALUES (" .. k .. ", '" .. c .. "', '1234567890')")
    end
end