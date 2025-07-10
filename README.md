# RTMDet to HEF Conversion using Hailo DFC

This repository provides a simple and well-documented pipeline for converting any RTMDet ONNX model (Small, Medium, Large) into a Hailo Executable Format (`.hef`) file using Hailo's Dataflow Compiler (DFC).

---

## ✅ Requirements

- **Hailo DFC Version:** `3.27.0`
- **Python Version:** `3.8`
- **ONNX Model Name:** Must be renamed to `rtmdet.onnx` (explained below)
- **Calib Data:** In `.npy` format (script provided in repo)

---

## 🔧 Installation

### 1. Install Hailo DFC 3.27.0

Download the Hailo DFC wheel from the official portal:

➡️ [DFC 3.27 Download Link](https://hailo.ai/developer-zone/dataflow-compiler/)

Then install it with:

```bash
pip install hailo_dataflow_compiler-3.27.0-py3-none-manylinux2014_x86_64.whl
```

---

## ⚠️ ONNX Naming Requirement

Your ONNX model **must be named** `rtmdet.onnx`.  
This is because the model scripts (`.alls`) reference layer names that start with `rtmdet`.  
If you use a different model name (e.g., `rtmsmall.onnx`), layer scopes will break unless updated inside the `.alls` file.

---

## 🧪 Calib Dataset (calib_set.npy)

We use a calibration dataset in `.npy` format for INT8 optimization.

- A script will be provided in this repo to generate it.
- Make sure the following three files are in the **same directory**:
  - `rtmdet.onnx`
  - `calib_set.npy`
  - `rtm.alls` (provided)

---

## 🔁 Workflow

### 1. **Parsing the ONNX Model**

```bash
hailo parser onnx rtmdet.onnx --har-path rtmdet.har --start-node input --end-node /Concat_6 /Sigmoid --tensor-shapes input=[1,3,640,640] --hw-arch hailo8 --end-node-names "/bbox_head/Mul" "/bbox_head/Mul_1" "/bbox_head/Mul_2" "/bbox_head/rtm_cls.1/Conv" "/bbox_head/rtm_cls.2/Conv" "/bbox_head/rtm_cls.0/Conv"
```

#### 🔹 Explanation:
- `--har-path`: Output HAR file (Hailo Archive Representation)
- `--start-node` / `--end-node`: Input/output layer names
- `--tensor-shapes`: Input shape
- `--hw-arch`: Target hardware (e.g., hailo8)

---

### 2. **Optimization (Quantization & Post-processing)**

```bash
hailo optimize rtmdet.har   --output-har rtmdet_int8.har   --calib-set-path calib_set.npy   --model-script rtm.alls   --hw-arch hailo8
```

#### 🔹 Explanation:
- `--output-har`: Optimized quantized HAR file
- `--calib-set-path`: Numpy file for calibration
- `--model-script`: Script to define quantization/lat layers
- `--hw-arch`: Hailo target hardware

---

### 3. **Compile to HEF**

```bash
hailo compiler rtmdet_int8.har   --output-dir output   --hw-arch hailo8
```

#### 🔹 Explanation:
- `--output-dir`: Directory where `.hef` will be saved
- `.hef`: Final file to run on Hailo device

---

## ⚠️ NOTE

- If you get layer errors, check if your ONNX model was renamed properly to `rtmdet.onnx`.
- The `.alls` file must match the ONNX layer prefixes (like `rtmdet/`).
- The `.hef` file can **only be tested on a physical Hailo device** (PC testing not supported).

---

## 📁 Files in Repo

- `rtm.alls` → Quantization layer scope script
- `calib_dataset_to_npy.py` → Script to generate `calib_set.npy` from images
- `README.md` → This file

---
