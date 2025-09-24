#!/bin/bash
set -e

MONGO_CONTAINER=${MONGO_CONTAINER:-mongo-db}
DB_NAME=${DB_NAME:-benchmark_db}
RESULTS_DIR=${RESULTS_DIR:-results_teste_carga}
mkdir -p $RESULTS_DIR

echo "=== Executando consultas MongoDB ==="

# SELECT simples com LIMIT 1000
docker exec -i $MONGO_CONTAINER mongosh $DB_NAME --quiet --eval 'db.property_prices.find().limit(1000).toArray()' > $RESULTS_DIR/select_limit_1000.json

# SELECT com filtro price > 500000
docker exec -i $MONGO_CONTAINER mongosh $DB_NAME --quiet --eval 'db.property_prices.find({price: {$gt: 500000}}).limit(1000).toArray()' > $RESULTS_DIR/select_filter.json

# Agregação AVG por town_city
docker exec -i $MONGO_CONTAINER mongosh $DB_NAME --quiet --eval 'db.property_prices.aggregate([{$group: {_id: "$town_city", avgPrice: {$avg: "$price"}}}]).toArray()' > $RESULTS_DIR/avg_by_town.json

# Contagem por town_city
docker exec -i $MONGO_CONTAINER mongosh $DB_NAME --quiet --eval 'db.property_prices.aggregate([{$group: {_id: "$town_city", count: {$sum: 1}}}]).toArray()' > $RESULTS_DIR/count_by_town.json

# UPDATE 100 registros (exemplo arbitrário)
docker exec -i $MONGO_CONTAINER mongosh $DB_NAME --quiet --eval 'let docs = db.property_prices.find().limit(100).toArray(); docs.forEach(d => db.property_prices.updateOne({_id: d._id}, {$set: {price: d.price + 1}}));'

# DELETE 100 registros
docker exec -i $MONGO_CONTAINER mongosh $DB_NAME --quiet --eval 'let docs = db.property_prices.find().limit(100).toArray(); docs.forEach(d => db.property_prices.deleteOne({_id: d._id}));'

# JOIN (aggregate com $lookup)
docker exec -i $MONGO_CONTAINER mongosh $DB_NAME --quiet --eval '
db.property_prices.aggregate([
    {
        $lookup: {
            from: "town_info",
            localField: "town_city",
            foreignField: "town_city",
            as: "town_info"
        }
    },
    {
        $unwind: "$town_info"
    },
    {
        $group: {
            _id: "$town_city",
            avgPrice: {$avg: "$price"},
            population: {$first: "$town_info.population"}
        }
    }
]).toArray()
' > $RESULTS_DIR/join_avg.json
