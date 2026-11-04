---
name: RAG
description: Local-First RAG pipeline using Google DeepMind's EmbeddingGemma-2, Drift SQLite database, and Sodiq AI mentor for Uzbekistan court systems.
---

# Local-First AI RAG Pipeline (EmbeddingGemma-2 & Drift)

This skill guides Retrieval-Augmented Generation (RAG) for the Uzbekistan Court Education Platform ("Sud Qo'llanma").

## Model Specification
- **Model Name:** EmbeddingGemma 2 (`google/embeddinggemma-2`)
- **Local Path:** `D:\dasturlar\STT\models\embeddinggemma-2`
- **Python Environment:** `D:\dasturlar\STT\.venv-embedding\Scripts\python.exe`
- **Vector Dimension:** 768 dimensions (Supports Matryoshka Representation Learning down to 256 dimensions for low storage footprint).
- **Execution Mode:** Offline CPU (`HF_HUB_OFFLINE=1`, `TRANSFORMERS_OFFLINE=1`, `torch.float32`).

## Canonical Court Knowledge Repositories
Always source domain context, courses, and chunks from:
1. `c:\Users\Arxiv\Documents\DARS` (5 modules for Supreme Court decree 10-06/26-93855)
2. `c:\Users\Arxiv\Documents\Sud_Qollanmalari` (EDO, JIB E-SUD, M-SUD, ADOLAT, E-IMZO manuals)
3. `c:\Users\Arxiv\Videos\Screen Recordings\EDO-qo'llanma` (Video tutorials)

## Architecture Patterns
1. **Document Chunking:**
   - Header-aware markdown splitter (`## 🔹 MAVZU`, `### 1.1`, etc.).
   - Target chunk size: 300 - 600 words with 50-word overlap.
   - Include metadata: `title`, `module`, `category`, `sourcePath`.

2. **Encoding Prompt Names:**
   - For indexing documents: `prompt_name='Document'`
   - For user queries: `prompt_name='SearchQuery'`

3. **Storage & Retrieval:**
   - **Local Database:** Drift (`AppDatabase`) `rag_chunks` table storing `id`, `title`, `module`, `category`, `content`, and serialized vector floats (`vectorJson`).
   - **Similarity Metric:** Cosine similarity ($A \cdot B / (\|A\| \|B\|)$). Since embeddings are normalized upon encoding, dot product is equivalent to cosine similarity.
   - **Sodiq Context Injection:** Format retrieved chunks with clear source labels and feed as grounding context to Gemini / Sodiq mentor.
