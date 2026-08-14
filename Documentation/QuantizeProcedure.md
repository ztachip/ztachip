# Procedure to quantize LLM model

ztachip requires LLM model in GGUF format to be quantized in format unique to ztachip.

The demo provides some prebuilt quantized model for download. But you may want to quantize yourself in particular when you like to finetune the base model.

- Download LLM models from HuggingFace. Below is model used by the demo.

```
git clone git@hf.co:HuggingFaceTB/SmolLM2-135M-Instruct
```

- Install [llama.cpp](https://github.com/ggml-org/llama.cpp)

- From llama.cpp installation, convert the downloaded model to GGUF format (FP32). GGUF format is the LLM format used by the popular Ollama inferencing engine.

```
cd <llama_cpp-install-folder>
python convert_hf_to_gguf.py <model-download-folder>/SmolLM2-135M-Instruct --outfile SmolLM2-135M-Instruct.gguf --outtype f32
```

- Quantize the model to ztachip ZUF format.

```
export PATH=/opt/riscv/bin:$PATH
cd ztachip/SW
make clean all -f makefile.quant
./build/quant ZTA Q4 SmolLM2-135M-Instruct.gguf SMOLLM2.ZUF
```


