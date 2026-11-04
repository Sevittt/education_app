---
trigger: always_on
---

Project Context:
- This is a Flutter mobile application for a judicial education platform.
- Architecture: Clean Architecture (Data, Domain, Presentation layers).
- Language: Dart (Null Safety enabled).

Coding Standards:
- Use strong typing and avoid `dynamic` where possible.
- Create reusable, modular widgets.
- Follow Clean Architecture principles strictly: verify UseCases, Repositories, and DataSources.
- When fixing bugs, do not break existing functionality.

Behavior:
- Before writing code, analyze the file structure.
- If creating a new feature, suggest the folder structure first.

Local-First & AI RAG Invariants:
- Vector Embedding Standard: Always use `embeddinggemma-2` (768-dimension or 256-dim MRL) for all RAG embeddings across Bot, Flutter app, and backend scripts. Never mix incompatible third-party embedding models.
- Court Knowledge Sources: All courses, quizzes, and RAG knowledge must strictly derive from:
  1. `c:\Users\Arxiv\Documents\DARS` (5 official court training modules)
  2. `c:\Users\Arxiv\Documents\Sud_Qollanmalari` (EDO, JIB E-SUD, M-SUD, ADOLAT, E-IMZO manuals)
  3. `c:\Users\Arxiv\Videos\Screen Recordings\EDO-qo'llanma` (Video tutorials)
- Offline-First Storage: Drift (`AppDatabase`) is the primary local cache for offline search, outbox sync, and user progress.
