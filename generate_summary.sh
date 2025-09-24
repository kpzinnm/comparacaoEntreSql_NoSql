#!/bin/bash

print_mongo_benchmark1() {
    local logfile="$1"

    awk '
        /\[OVERALL\]/ {flag=1}
        flag {
            print
            if ($1 == "[CLEANUP],") {flag_cleanup=1}
        }
        flag_cleanup && /^$/ {exit}
    ' "$logfile"
}

print_mongo_benchmark2() {
    local logfile="$1"

    awk '
        /\[OVERALL\]/ {flag=1}
        flag {
            print
            if ($1 == "[SCAN],") {flag_scan=1}
        }
        flag_scan && /^$/ {exit}
    ' "$logfile"
}

echo "=== RESUMO DOS RESULTADOS ==="

echo -e "\n==================== CENÁRIO READ SIMPLE ====================\n"
echo -e "--PostgreSQL:\n"
awk '
    /=== CENÁRIO READ SIMPLE ===/ {flag_scenario=1}
    flag_scenario && /SQL statistics:/ {flag_print=1}
    flag_print {
        print
        if ($1=="sum:") {flag_print=0; flag_scenario=0}
    }
' "./results/sysbench_all.log"

echo -e "\n\n--MongoDB:\n"
print_mongo_benchmark1 "./results/mongo_read_simple.log"

echo -e "\n==================== CENÁRIO READ RANGE ====================\n"
echo -e "--PostgreSQL:\n"
awk '
    /=== CENÁRIO READ RANGE ===/ {flag_scenario=1}
    flag_scenario && /SQL statistics:/ {flag_print=1}
    flag_print {
        print
        if ($1=="sum:") {flag_print=0; flag_scenario=0}
    }
' "./results/sysbench_all.log"

echo -e "\n\n--MongoDB:\n"
print_mongo_benchmark2 "./results/mongo_read_range.log"

echo -e "\n==================== CENÁRIO READ JOIN + AGG ====================\n"
echo -e "--PostgreSQL:\n"
awk '
    /=== CENÁRIO READ JOIN \+ AGG ===/ {flag_scenario=1}
    flag_scenario && /SQL statistics:/ {flag_print=1}
    flag_print {
        print
        if ($1=="sum:") {flag_print=0; flag_scenario=0}
    }
' "./results/sysbench_all.log"

echo -e "\n\n--MongoDB:\n"
print_mongo_benchmark1 "./results/mongo_read_join_agg.log"
