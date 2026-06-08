# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail lanpaint@1.4.10 --mode remote || (echo "WARN: lanpaint@1.4.10 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail lanpaint --mode remote)
RUN git clone https://github.com/chrisgoringe/cg-use-everywhere /comfyui/custom_nodes/cg-use-everywhere && cd /comfyui/custom_nodes/cg-use-everywhere && (git checkout f72d23a7060db657a2775c4dd1f1a85a3efcf5a8 2>/dev/null || (git fetch origin f72d23a7060db657a2775c4dd1f1a85a3efcf5a8 --depth=1 && git checkout f72d23a7060db657a2775c4dd1f1a85a3efcf5a8) || echo "WARN: commit f72d23a7060db657a2775c4dd1f1a85a3efcf5a8 unreachable in https://github.com/chrisgoringe/cg-use-everywhere, falling back to default branch HEAD")
RUN comfy node install --exit-on-fail rgthree-comfy@1.0.2512112053 || (echo "WARN: rgthree-comfy@1.0.2512112053 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail rgthree-comfy)

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp4mixed.safetensors?download=true' --relative-path models/text_encoders --filename 'qwen_3_8b_fp4mixed.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors' --relative-path models/vae --filename 'flux2-vae.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Aitrepreneur/FLX/resolve/main/flux-2-klein-9b-fp8.safetensors' --relative-path models/diffusion_models --filename 'flux-2-klein-9b-fp8.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/pexels-mimfathi-10919291.jpg' "https://cool-anteater-319.convex.cloud/api/storage/b0bc5adb-84e5-4e35-a539-ee4a59068f47"
RUN wget --progress=dot:giga -O '/comfyui/input/pexels-peterfazekas-1137340.jpg' "https://cool-anteater-319.convex.cloud/api/storage/b88a5b0e-a652-4719-a779-0614c8c21201"
RUN wget --progress=dot:giga -O '/comfyui/input/IMG-20260608-WA0001.jpg' "https://cool-anteater-319.convex.cloud/api/storage/f4c60d7c-26a2-45c0-8165-0b2c8762ab19"
RUN wget --progress=dot:giga -O '/comfyui/input/pexels-alina-zahorulko-48514961-31445409.jpg' "https://cool-anteater-319.convex.cloud/api/storage/22807926-9184-41e0-9917-27d1be14f5a4"
RUN wget --progress=dot:giga -O '/comfyui/input/IMG-20260608-WA0002.jpg' "https://cool-anteater-319.convex.cloud/api/storage/550df3c0-c404-4348-8d8f-54c09c0ea290"
