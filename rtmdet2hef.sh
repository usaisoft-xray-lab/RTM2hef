#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
#  USER-EDITABLE VARIABLES  (all paths are relative to this script dir)
# ----------------------------------------------------------------------
ONNX=rtmdet.onnx            # input ONNX (must start with rtmdet/ scopes)
CALIB=calib_set.npy         # calibration set .npy  (64–256 RGB frames)

OPT_SCRIPT=rtm.alls         # optimisation-time script
COMP_SCRIPT=compile.alls    # compile-time    script

HW_ARCH=hailo8              # target device
PARSED=rtmdet.har           # output of parser
QUANT=rtmdet_int8.har       # output of optimiser
HEF_DIR=output              # compiler output dir
# ----------------------------------------------------------------------

echo "=== 1. Parsing ${ONNX} → ${PARSED} (no prompt) ==="
hailo parser onnx "${ONNX}" \
      --har-path "${PARSED}" \
      --start-node input \
      --end-node /Concat_6 /Sigmoid \
      --tensor-shapes input=[1,3,640,640] \
      --hw-arch "${HW_ARCH}" \
      --end-node-names "/bbox_head/Mul" \
                       "/bbox_head/Mul_1" \
                       "/bbox_head/Mul_2" \
                       "/bbox_head/rtm_cls.1/Conv" \
                       "/bbox_head/rtm_cls.2/Conv" \
                       "/bbox_head/rtm_cls.0/Conv"

echo -e "\n=== 2. Optimising → ${QUANT} ==="
hailo optimize "${PARSED}" \
      --output-har "${QUANT}" \
      --calib-set-path "${CALIB}" \
      --model-script "${OPT_SCRIPT}" \
      --hw-arch "${HW_ARCH}"

echo -e "\n=== 3. Compiling → ${HEF_DIR} ==="
hailo compiler "${QUANT}" \
      --output-dir "${HEF_DIR}"\
      --hw-arch "${HW_ARCH}"

echo -e "\n✔ Done — final HEF at ${HEF_DIR}/$(basename "${QUANT}" .har).hef"

