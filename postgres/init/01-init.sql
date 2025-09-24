-- Criação da tabela principal
CREATE TABLE IF NOT EXISTS property_prices (
    transaction_id UUID PRIMARY KEY,
    price BIGINT NOT NULL,
    date_of_transfer TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    postcode TEXT,
    property_type CHAR(1),
    new_build_flag CHAR(1),
    tenure CHAR(1),
    paon TEXT,
    saon TEXT,
    street TEXT,
    locality TEXT,
    town_city TEXT,
    district TEXT,
    county TEXT,
    ppd_category_type CHAR(1),
    record_status CHAR(1)
);

-- Criação da tabela auxiliar
CREATE TABLE IF NOT EXISTS town_info (
    town_city TEXT PRIMARY KEY,
    region TEXT NOT NULL,
    population INT
);

-- Importar CSV para property_prices
COPY property_prices(transaction_id, price, date_of_transfer, postcode, property_type, new_build_flag,
    tenure, paon, saon, street, locality, town_city, district, county, ppd_category_type, record_status)
FROM '/docker-entrypoint-initdb.d/uk_property_prices.csv'
DELIMITER ','
CSV;

-- Inserir dados hardcoded na tabela town_info
INSERT INTO town_info (town_city, region, population) VALUES
('London', 'England', 9000000),
('Manchester', 'England', 550000),
('Birmingham', 'England', 1150000),
('Liverpool', 'England', 500000),
('Leeds', 'England', 800000),
('Sheffield', 'England', 600000),
('Bristol', 'England', 470000),
('Edinburgh', 'Scotland', 500000),
('Glasgow', 'Scotland', 635000),
('Cardiff', 'Wales', 370000),
('Swansea', 'Wales', 245000),
('Belfast', 'Northern Ireland', 340000),
('Newcastle', 'England', 300000),
('Nottingham', 'England', 330000),
('Leicester', 'England', 355000),
('Coventry', 'England', 375000),
('Kingston upon Hull', 'England', 260000),
('Bradford', 'England', 360000),
('Stoke-on-Trent', 'England', 255000),
('Wolverhampton', 'England', 260000)
ON CONFLICT (town_city) DO NOTHING;
