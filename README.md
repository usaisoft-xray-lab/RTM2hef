The guide below walks you from ONNX → HEF in three CLI commands using Hailo DFC 3.27 + Python 3.8. It explains every flag, links the official docs/community posts for deeper reading, and highlights the name-mismatch pitfall when you rename the ONNX. Clone the repo, drop your files in one folder, run the commands, and you’ll have a ready-to-run .hef in minutes.

📦 Requirements
Item	Version / Note	Reference
Hailo Dataflow Compiler (DFC)	3.27.0 wheel	
community.hailo.ai
Python	3.8 virtual-env (recommended)	
community.hailo.ai
OS	Native Ubuntu 20.04 / 22.04 (PCIe driver not supported in WSL 2)	
community.hailo.ai
Hailo-8 HW	PCIe / M.2 / USB dev-kit (for runtime tests)	

No board? You can still produce the .hef and inspect it, but you can’t execute it without hardware. 
community.hailo.ai

🔧 Installation (DFC 3.27)
bash
Copy
Edit
# 1 – make an isolated env
python3.8 -m venv ~/hailo_327
source ~/hailo_327/bin/activate

# 2 – install the wheel you downloaded from Hailo Developer Zone
pip install hailo_dataflow_compiler-3.27.0-py3-none-manylinux2014_x86_64.whl
The wheel bundles the correct TensorFlow / ONNX runtimes; no root access needed. 
note.mmmsk.myds.me

🗂️ Folder layout
bash
Copy
Edit
rtmdet_to_hef/
├── rtmdet.onnx          # your model  (⚠️ see “name pitfall” below)
├── calib_set.npy        # calibration frames (NHWC uint8)
├── rtm.alls             # model-script (layer tweaks / QFT off / etc.)
└── (output/)            # compiler will appear here
The ONNX name pitfall
Layer scopes inherit the file name.

If the file is rtmdet.onnx, layers start with rtmdet/….

If you rename to rtmsmall.onnx, scopes become rtmsmall/… – update the paths in rtm.alls or the parser will raise “Invalid scope name”. 
community.hailo.ai

⚙️ Step 1 – Parse ONNX → HAR
bash
Copy
Edit
hailo parser onnx rtmdet.onnx \
      --har-path rtmdet.har \
      --start-node input \
      --end-node /Concat_6 /Sigmoid \
      --tensor-shapes input=[1,3,640,640] \
      --hw-arch hailo8
Flag	Purpose
--har-path	output archive for the parsed graph
--start-node / --end-node	anchor points (accept suggestions if prompted) 
community.hailo.ai
--tensor-shapes	batch, C, H, W that the network expects
--hw-arch	selects Hailo-8 allocator

⚙️ Step 2 – Optimise & Quantise
bash
Copy
Edit
hailo optimize rtmdet.har \
      --output-har rtmdet_int8.har \
      --calib-set-path calib_set.npy \
      --model-script rtm.alls \
      --hw-arch hailo8
Flag	Purpose
--calib-set-path	.npy file with 50-200 representative frames 
community.hailo.ai
--model-script	.alls tweaks (e.g. disable Fine-Tune to avoid GPU-OOM) 
community.hailo.ai
--output-har	INT-8 / mixed-precision graph for the compiler

⚙️ Step 3 – Compile → HEF
bash
Copy
Edit
hailo compiler rtmdet_int8.har \
      --output-dir output \
      --hw-arch hailo8
Flag	Purpose
--output-dir	writes rtmdet.hef + compile_report.html here 
community.hailo.ai
--hw-arch	must match the device (hailo8 / 8L / 15H …)

Open the HTML to inspect FPS, bandwidth, per-layer latency.
