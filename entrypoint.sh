#!/usr/bin/env bash
set -e
CODE_PATH="$1"
. $IDF_PATH/export.sh
cd ${CODE_PATH}
cd build

echo "Generating binary"
esptool.py --chip esp32s3 merge_bin --fill-flash-size 16MB -o flash_image.bin @flash_args

echo "Running virtual machine"
QEMU_EXIT=0
timeout 5m /opt/qemu/bin/qemu-system-xtensa -machine esp32s3 -monitor none -nographic -no-reboot -semihosting -drive file=flash_image.bin,if=mtd,format=raw -m 4 -serial file:output.log || QEMU_EXIT=$?

echo "Generate report"
cat output.log

REPORT_EXIT=0
if grep -q -E '[[:digit:]]+ Tests [[:digit:]]+ Failures [[:digit:]]+ Ignored' output.log; then
    ruby /opt/Unity-*/auto/parse_output.rb -xml output.log || REPORT_EXIT=$?
else
    echo "No Unity test summary found in output"
    REPORT_EXIT=1
fi

if [ -f report.xml ]; then
    mv report.xml /github/workspace
fi

if [ $QEMU_EXIT -ne 0 ]; then
    echo "QEMU virtual machine exited with code $QEMU_EXIT"
    exit $QEMU_EXIT
fi

if [ $REPORT_EXIT -ne 0 ]; then
    echo "Failed to generate test report"
    exit $REPORT_EXIT
fi
