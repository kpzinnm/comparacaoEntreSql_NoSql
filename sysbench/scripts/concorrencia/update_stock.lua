-- Script básico para simular concorrência em PostgreSQL
function thread_init()
    -- Cada thread vai executar selects e updates simples
    db_query("SET SESSION CHARACTERISTICS AS TRANSACTION READ WRITE")
end

function event()
    local t = sysbench.rand.uniform(1, 100)
    if t <= 50 then
        -- 50% SELECT
        db_query("SELECT * FROM pg_tables LIMIT 10")
    else
        -- 50% UPDATE em tabela fictícia
        db_query("UPDATE sbtest1 SET k = k + 1 WHERE id = " .. sysbench.rand.default(1, 10000))
    end
end
