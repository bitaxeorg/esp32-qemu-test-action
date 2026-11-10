#!/usr/bin/env bash
set -e
CODE_PATH="$1"
MEMORY_MB="${2:-4}"
OCTAL_PSRAM="${3:-false}"
. $IDF_PATH/export.sh
cd ${CODE_PATH}
cd build

echo "Generating binary"
esptool.py --chip esp32s3 merge_bin --fill-flash-size 16MB -o flash_image.bin @flash_args

QEMU_ARGS=(-machine esp32s3 -nographic -no-reboot -watchdog-action shutdown
           -drive file=flash_image.bin,if=mtd,format=raw -m "${MEMORY_MB}"
           -serial file:output.log)
if [ "${OCTAL_PSRAM}" = "true" ]; then
    QEMU_ARGS+=(-global driver=ssi_psram,property=is_octal,value=true)
fi

echo "Running virtual machine (${MEMORY_MB} MB PSRAM, octal=${OCTAL_PSRAM})"
timeout 5m /opt/qemu/bin/qemu-system-xtensa "${QEMU_ARGS[@]}" || echo "error"

echo "Generate report"
cat output.log
grep -q -E '[[:digit:]]+ Tests [[:digit:]]+ Failures [[:digit:]]+ Ignored' output.log && ruby /opt/Unity-*/auto/parse_output.rb -xml output.log || exit 1
mv report.xml /github/workspace
