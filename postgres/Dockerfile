FROM postgres:17

# Copiar script de inicialização para o diretório do entrypoint
COPY init/01-init.sql /docker-entrypoint-initdb.d/

# Copiar CSV para o entrypoint para que o init.sql consiga importar
COPY uk_property_prices.csv /docker-entrypoint-initdb.d/
