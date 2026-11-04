"""
Local Embedding Generator using Google DeepMind's EmbeddingGemma 2.
Loads raw_chunks.json, computes 768d and 256d MRL embeddings, and saves outputs.
"""
import os, sys, json, time
from pathlib import Path

os.environ['HF_HUB_DISABLE_TELEMETRY'] = '1'
os.environ['HF_HUB_OFFLINE'] = '1'
os.environ['TRANSFORMERS_OFFLINE'] = '1'

import torch
from sentence_transformers import SentenceTransformer

MODEL_PATH = Path(r"D:\dasturlar\STT\models\embeddinggemma-2")
INPUT_FILE = Path(r"d:\dasturlar\b-v22\assets\data\raw_chunks.json")
OUTPUT_FILE = Path(r"d:\dasturlar\b-v22\assets\data\court_knowledge_chunks.json")
FIRESTORE_EXPORT = Path(r"d:\dasturlar\b-v22\assets\data\firestore_rag_chunks.json")

def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    print("Loading raw chunks from:", INPUT_FILE)
    with open(INPUT_FILE, "r", encoding="utf-8") as rf:
        chunks = json.load(rf)
    print(f"Loaded {len(chunks)} chunks.")

    torch.set_num_threads(min(8, os.cpu_count() or 4))
    print(f"Loading EmbeddingGemma 2 from {MODEL_PATH}...")
    start_load = time.perf_counter()
    model = SentenceTransformer(
        str(MODEL_PATH),
        device='cpu',
        local_files_only=True,
        config_kwargs={'vision_config': None, 'audio_config': None},
        model_kwargs={'torch_dtype': torch.float32}
    )
    # Set sequence length to 384 tokens (~1500 chars) for 10x faster CPU encoding
    model.max_seq_length = 384
    print(f"Model loaded in {time.perf_counter() - start_load:.2f} seconds. Max seq length: {model.max_seq_length}")

    # Prepare texts for encoding: title + content truncated to ~1200 chars
    texts = [f"{c['title']}\n{c['content'][:1200]}" for c in chunks]

    print(f"Computing 768-dim embeddings for {len(texts)} chunks in batches...")
    start_enc = time.perf_counter()
    vectors_768 = model.encode(
        texts,
        batch_size=32,
        prompt_name='Document',
        normalize_embeddings=True,
        show_progress_bar=True,
        truncate_dim=768
    )
    enc_time = time.perf_counter() - start_enc
    print(f"Encoded {len(texts)} chunks in {enc_time:.2f} seconds ({len(texts)/enc_time:.1f} chunks/sec).")

    # Also extract normalized 256-dim MRL vectors
    import numpy as np
    vectors_256 = vectors_768[:, :256].copy()
    norms = np.linalg.norm(vectors_256, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    vectors_256 = vectors_256 / norms

    processed_chunks = []
    firestore_docs = []

    for i, c in enumerate(chunks):
        v256_list = [round(float(x), 5) for x in vectors_256[i]]
        v768_list = [round(float(x), 5) for x in vectors_768[i]]

        processed = {
            "id": c["id"],
            "title": c["title"],
            "module": c["module"],
            "category": c["category"],
            "content": c["content"],
            "source_path": c.get("source_path", ""),
            "vector_256": v256_list,
            "vector_768": v768_list,
            "updated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ")
        }
        processed_chunks.append(processed)

        firestore_docs.append({
            "id": c["id"],
            "title": c["title"],
            "text": c["content"],
            "module": c["module"],
            "category": c["category"],
            "embedding": v768_list,
            "updatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ")
        })

    print(f"Saving processed chunks to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, "w", encoding="utf-8") as wf:
        json.dump(processed_chunks, wf, ensure_ascii=False)

    print(f"Saving Firestore export to {FIRESTORE_EXPORT}...")
    with open(FIRESTORE_EXPORT, "w", encoding="utf-8") as wf:
        json.dump(firestore_docs, wf, ensure_ascii=False)

    print("Embedding pipeline completed successfully!")

if __name__ == "__main__":
    main()
