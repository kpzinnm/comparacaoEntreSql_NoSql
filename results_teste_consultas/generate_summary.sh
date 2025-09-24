#!/bin/bash
echo "=== RESUMO DOS RESULTADOS ==="
echo ""
echo "PostgreSQL Read Simple:"
grep "transactions:" ./postgres_read_simple.log | tail -1
grep "queries:" ./postgres_read_simple.log | tail -1
echo ""
echo "PostgreSQL Read Range:"
grep "transactions:" ./postgres_read_range.log | tail -1
grep "queries:" ./postgres_read_range.log | tail -1
echo ""
echo "PostgreSQL Read Join + Agg:"
grep "transactions:" ./postgres_read_join_agg.log | tail -1
grep "queries:" ./postgres_read_join_agg.log | tail -1
echo ""
echo "MongoDB Read Simple:"
grep "\[OVERALL\], Throughput" ./mongo_read_simple.log
grep "\[READ\], AverageLatency" ./mongo_read_simple.log
echo ""
echo "MongoDB Read Range:"
grep "\[OVERALL\], Throughput" ./mongo_read_range.log
grep "\[READ\], AverageLatency" ./mongo_read_range.log
echo ""
echo "MongoDB Read Join Agg:"
grep "\[OVERALL\], Throughput" ./mongo_read_join_agg.log
grep "\[READ\], AverageLatency" ./mongo_read_join_agg.log
grep "\[UPDATE\], AverageLatency" ./mongo_read_join_agg.log
