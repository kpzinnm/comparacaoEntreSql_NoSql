BEGIN;
UPDATE estoque SET quantidade = quantidade - 1 WHERE id = 1;
COMMIT;
