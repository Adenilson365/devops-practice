#!/bin/bash

# Simulador de I/O Wait com duração controlada
# Debian/Linux

STRESS_DIR="/tmp/io-stress"
FILE_SIZE_MB=1024 # 1GB = 1024MB
JOBS=4
DURATION_SECONDS=600 # 600 segundos = 10 minutos

mkdir -p "$STRESS_DIR"

cleanup() {
    echo
    echo "Parando processos filhos..."
    pkill -P $$ 2>/dev/null

    echo "Removendo arquivos temporários..."
    rm -rf "$STRESS_DIR"

    echo "Finalizado."
    exit 0
}

trap cleanup INT TERM

END_TIME=$((SECONDS + DURATION_SECONDS))

while [ "$SECONDS" -lt "$END_TIME" ]; do
    for i in $(seq 1 "$JOBS"); do
        dd if=/dev/zero \
           of="$STRESS_DIR/io-test-$i-$(date +%s%N).dat" \
           bs=1M \
           count="$FILE_SIZE_MB" \
           oflag=direct \
           status=none &
    done

    wait

    # Remove os arquivos da rodada para não encher o disco
    rm -f "$STRESS_DIR"/io-test-*.dat
done

cleanup