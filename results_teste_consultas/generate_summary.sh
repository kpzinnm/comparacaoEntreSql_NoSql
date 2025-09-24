#!/bin/bash
echo "=== RESUMO DOS RESULTADOS ==="
echo ""
echo "PostgreSQL Read Simple:"
grep "transactions:" ./results_teste_consultas/postgres_read_simple.log | tail -1
grep "queries:" ./results_teste_consultas/postgres_read_simple.log | tail -1
echo ""
echo "PostgreSQL Read Range:"
grep "transactions:" ./results_teste_consultas/postgres_read_range.log | tail -1
grep "queries:" ./results_teste_consultas/postgres_read_range.log | tail -1
echo ""
echo "PostgreSQL Read Join + Agg:"
grep "transactions:" ./results_teste_consultas/postgres_read_join_agg.log | tail -1
grep "queries:" ./results_teste_consultas/postgres_read_join_agg.log | tail -1
echo ""
echo "MongoDB Read Simple:"
grep "\[OVERALL\], Throughput" ./results_teste_consultas/mongo_read_simple.log
grep "\[READ\], AverageLatency" ./results_teste_consultas/mongo_read_simple.log
echo ""
echo "MongoDB Read Range:"
grep "\[OVERALL\], Throughput" ./results_teste_consultas/mongo_read_range.log
grep "\[READ\], AverageLatency" ./results_teste_consultas/mongo_read_range.log
echo ""
echo "MongoDB Read Join Agg:"
grep "\[OVERALL\], Throughput" ./results_teste_consultas/mongo_read_join_agg.log
grep "\[READ\], AverageLatency" ./results_teste_consultas/mongo_read_join_agg.log
