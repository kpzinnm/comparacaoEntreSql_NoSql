FROM mongo:7.0.23

# Copiar scripts de inicialização
COPY init /docker-entrypoint-initdb.d/

# Copiar CSV grande para dentro do container
COPY uk_property_prices.csv /tmp/uk_property_prices.csv

# Script para importar CSV sem header
COPY import_csv.sh /docker-entrypoint-initdb.d/import_csv.sh
RUN chmod +x /docker-entrypoint-initdb.d/import_csv.sh

