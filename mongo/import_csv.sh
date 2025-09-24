#!/bin/bash
set -e

DB=${MONGO_INITDB_DATABASE:-benchmark_db}
CSV_PATH=/tmp/uk_property_prices.csv
COLLECTION=property_prices

# Header manual, já que CSV não tem
HEADER="transaction_id,price,date_of_transfer,postcode,property_type,new_build_flag,tenure,paon,saon,street,locality,town_city,district,county,ppd_category_type,record_status"

echo "=== Importando CSV grande para MongoDB ==="
mongoimport --username $MONGO_INITDB_ROOT_USERNAME \
            --password $MONGO_INITDB_ROOT_PASSWORD \
            --authenticationDatabase admin \
            --db $DB \
            --collection $COLLECTION \
            --type csv \
            --fields "$HEADER" \
            --file "$CSV_PATH"

echo "Importação concluída!"
