-- custom_benchmark.lua

-- Executado a cada transação
function event()
    local t = sysbench.rand.uniform(1, 7)

    if t == 1 then
        -- SELECT simples com LIMIT 1000
        db_query("SELECT * FROM property_prices LIMIT 1000")

    elseif t == 2 then
        -- SELECT com filtro (price > 500000)
        db_query("SELECT * FROM property_prices WHERE price > 500000 LIMIT 100")

    elseif t == 3 then
        -- Agregação AVG por cidade
        db_query("SELECT town_city, AVG(price) FROM property_prices GROUP BY town_city LIMIT 50")

    elseif t == 4 then
        -- Contagem por cidade
        db_query("SELECT town_city, COUNT(*) FROM property_prices GROUP BY town_city LIMIT 50")

    elseif t == 5 then
        -- UPDATE de 100 registros
        db_query("UPDATE property_prices SET price = price * 1.1 WHERE transaction_id IN (SELECT transaction_id FROM property_prices LIMIT 100)")

    elseif t == 6 then
        -- DELETE de 100 registros
        db_query("DELETE FROM property_prices WHERE transaction_id IN (SELECT transaction_id FROM property_prices LIMIT 100)")

    elseif t == 7 then
        -- JOIN: média de preços por cidade + população
        db_query([[
            SELECT p.town_city, AVG(p.price), t.population
            FROM property_prices p
            JOIN town_info t ON p.town_city = t.town_city
            GROUP BY p.town_city, t.population
            LIMIT 50
        ]])
    end
end
