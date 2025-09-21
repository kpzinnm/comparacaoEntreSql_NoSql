-- ./sysbench/scripts/read_intensive.lua
#!/usr/bin/env sysbench

function event()
    local id = math.random(1, sysbench.opt.table_size)
    
    if math.random() < 0.9 then
        db_query("SELECT c FROM sbtest" .. sysbench.tid .. " WHERE id=" .. id)
    else
        db_query("UPDATE sbtest" .. sysbench.tid .. " SET k=k+1 WHERE id=" .. id)
    end
end