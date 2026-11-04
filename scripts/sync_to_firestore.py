"""
Sync 404 embedded court knowledge chunks to Cloud Firestore 'rag_chunks' collection.
Uses serviceAccountKey.json from sudqollanma_bot.
"""
import json, sys
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, firestore

KEY_PATH = Path(r"d:\dasturlar\sudqollanma_bot\serviceAccountKey.json")
CHUNKS_PATH = Path(r"d:\dasturlar\b-v22\assets\data\firestore_rag_chunks.json")

def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    if not KEY_PATH.exists():
        print(f"Key not found at {KEY_PATH}")
        return

    print("Initializing Firebase Admin with serviceAccountKey...")
    cred = credentials.Certificate(str(KEY_PATH))
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print(f"Loading chunks from {CHUNKS_PATH}...")
    with open(CHUNKS_PATH, "r", encoding="utf-8") as rf:
        chunks = json.load(rf)
    print(f"Loaded {len(chunks)} chunks.")

    print(f"Batch uploading to Firestore 'rag_chunks' collection...")
    batch = db.batch()
    count = 0
    total_committed = 0

    for c in chunks:
        doc_ref = db.collection("rag_chunks").document(c["id"])
        # Store metadata + 768-dim embedding
        batch.set(doc_ref, {
            "title": c["title"],
            "text": c["text"],
            "module": c.get("module", ""),
            "category": c.get("category", ""),
            "embedding": c["embedding"],
            "updatedAt": c.get("updatedAt", "")
        }, merge=True)
        count += 1

        if count >= 50:
            batch.commit()
            total_committed += count
            print(f"Committed {total_committed}/{len(chunks)} chunks...", flush=True)
            batch = db.batch()
            count = 0

    if count > 0:
        batch.commit()
        total_committed += count
        print(f"Committed {total_committed}/{len(chunks)} chunks...", flush=True)

    print("Firestore rag_chunks synchronization completed successfully!")

if __name__ == "__main__":
    main()
