#!/usr/bin/env bash
set -e
CODE_PATH="$1"
. $IDF_PATH/export.sh
cd ${CODE_PATH}
cd build

echo "Generating binary"
esptool.py --chip esp32s3 merge_bin --fill-flash-size 16MB -o flash_image.bin @flash_args

echo "Running virtual machine"
timeout 5m /opt/qemu/bin/qemu-system-xtensa -machine esp32s3 -nographic -no-reboot -watchdog-action shutdown -drive file=flash_image.bin,if=mtd,format=raw -m 4 -serial file:output.log  || echo "error"

echo "Generate report"
cat output.log
grep -q -E '[[:digit:]]+ Tests [[:digit:]]+ Failures [[:digit:]]+ Ignored' output.log && ruby /opt/Unity-*/auto/parse_output.rb -xml output.log || exit 1
mv report.xml /github/workspace
