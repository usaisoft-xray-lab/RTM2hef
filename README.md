# RTMDet → Hailo-8 Conversion Guide  
*Hailo Dataflow Compiler (DFC) **v 3.27** · Python **3.8***

Convert an **RTMDet** ONNX model into a deployable **`.hef`** in **three commands**:  
`parse → optimize → compile`.  
If you rename the ONNX file you **must** also update layer scopes in `rtm.alls` (see **Name-pitfall**).

---

## ✋ Requirements

| Item | Version / Note |
|------|----------------|
| **Hailo Dataflow Compiler (DFC)** | **3.27.0** |
| **Python** | 3.8 virtual-env |
| **OS** | Ubuntu 20.04 / 22.04 (native) — WSL 2 hides PCIe devices |
| **Hailo-8 hardware** | PCIe / M.2 / USB dev-kit (needed only for runtime tests) |

---

## 🔧 Install DFC 3.27

```bash
# create isolated environment
python3.8 -m venv ~/hailo_327
source ~/hailo_327/bin/activate

# install wheel downloaded from Hailo Developer Zone
pip install hailo_dataflow_compiler-3.27.0-py3-none-manylinux2014_x86_64.whl
