#!/bin/bash

# Simulador de I/O Wait com duração controlada
# A ideia é usar o comando dd para escrever na partição e vizualizar 
# monitoramento de I/O Wait com o comandos de troubleshooting
# Debian/Linux


STRESS_DIR=$1
DD_BS=$2 # 1GB = 1024MB
DD_COUNT=$3 # Número de blocos
JOBS=$4
DURATION_SECONDS=$5 # 600 segundos = 10 minutos

 if [ ! -f "$STRESS_DIR/io-read-test/io-test-0.dat" ]; then
    mkdir -p "$STRESS_DIR/io-read-test"
    dd if=/dev/zero of="$STRESS_DIR/io-read-test/io-test-0.dat" bs="$DD_BS" count="$DD_COUNT" oflag=direct conv=fdatasync status=none
 fi

cleanup() {
    echo
    echo "Parando processos filhos..."
    pkill -P $$ 2>/dev/null

    echo "Removendo arquivos temporários..."
    rm -rf "$STRESS_DIR/io-read-test/*"

    echo "Finalizado."
    exit 0
}

trap cleanup INT TERM

END_TIME=$((SECONDS + DURATION_SECONDS))

while [ "$SECONDS" -lt "$END_TIME" ]; do
    for i in $(seq 1 "$JOBS"); do
        dd if="$STRESS_DIR/io-read-test/io-test-0.dat" \
           of=/dev/null \
           bs="$DD_BS" \
           count="$DD_COUNT" \
           iflag=direct \
           status=none &
    done

    wait

done

cleanup