#!/bin/bash
echo "=== RESUMO DOS RESULTADOS ==="
echo ""
echo "PostgreSQL Read-Heavy:"
grep "transactions:" results_teste_estresse/postgres_read_heavy.log | tail -1
grep "queries:" results_teste_estresse/postgres_read_heavy.log | tail -1
echo ""
echo "PostgreSQL Write-Heavy:"
grep "transactions:" results_teste_estresse/postgres_write_heavy.log | tail -1
grep "queries:" results_teste_estresse/postgres_write_heavy.log | tail -1
echo ""
echo "PostgreSQL Balanced:"
grep "transactions:" results_teste_estresse/postgres_balanced.log | tail -1
grep "queries:" results_teste_estresse/postgres_balanced.log | tail -1
echo ""
echo "MongoDB Read-Heavy:"
grep "\[OVERALL\], Throughput" results_teste_estresse/mongo_read_heavy.log
grep "\[READ\], AverageLatency" results_teste_estresse/mongo_read_heavy.log
echo ""
echo "MongoDB Write-Heavy:"
grep "\[OVERALL\], Throughput" results_teste_estresse/mongo_write_heavy.log
grep "\[UPDATE\], AverageLatency" results_teste_estresse/mongo_write_heavy.log
echo ""
echo "MongoDB Balanced:"
grep "\[OVERALL\], Throughput" results_teste_estresse/mongo_balanced.log
grep "\[READ\], AverageLatency" results_teste_estresse/mongo_balanced.log
grep "\[UPDATE\], AverageLatency" results_teste_estresse/mongo_balanced.log
