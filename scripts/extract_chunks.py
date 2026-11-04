"""
Extract and chunk all court knowledge documents:
1. c:\\Users\\Arxiv\\Documents\\DARS (Markdown files for the 5 court modules)
2. c:\\Users\\Arxiv\\Documents\\Sud_Qollanmalari (65 official PDFs)
3. c:\\Users\\Arxiv\\Videos\\Screen Recordings\\EDO-qo'llanma (Video metadata)
"""
import os, re, json, glob, fitz
from pathlib import Path

DARS_DIR = Path(r"c:\Users\Arxiv\Documents\DARS")
QOLLANMALAR_DIR = Path(r"c:\Users\Arxiv\Documents\Sud_Qollanmalari")
VIDEOS_DIR = Path(r"c:\Users\Arxiv\Videos\Screen Recordings\EDO-qo'llanma")
OUTPUT_FILE = Path(r"d:\dasturlar\b-v22\assets\data\raw_chunks.json")

chunks = []

def clean_text(text: str) -> str:
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip()

def chunk_markdown(content: str, file_path: str, module_name: str, category: str):
    # Split on markdown headers (# , ## , ### )
    sections = re.split(r'\n(?=#{1,3} )', content)
    for idx, sec in enumerate(sections):
        sec = clean_text(sec)
        if not sec or len(sec) < 50:
            continue
        
        # Extract title from the first header line
        first_line = sec.split('\n')[0].strip()
        title = re.sub(r'^#{1,3}\s*', '', first_line).strip()
        title = re.sub(r'[*_`]', '', title).strip()
        if not title:
            title = f"{module_name} - Bo'lim {idx + 1}"

        # If section is very long (> 2500 chars), subdivide by paragraphs
        if len(sec) > 2500:
            paras = sec.split('\n\n')
            sub_chunk = []
            sub_len = 0
            sub_idx = 1
            for p in paras:
                sub_chunk.append(p)
                sub_len += len(p)
                if sub_len >= 1200:
                    body = clean_text('\n\n'.join(sub_chunk))
                    chunk_id = f"dars_{Path(file_path).stem}_{idx}_{sub_idx}"
                    chunks.append({
                        "id": chunk_id,
                        "title": f"{title} (qism {sub_idx})",
                        "module": module_name,
                        "category": category,
                        "content": body,
                        "source_path": str(file_path)
                    })
                    sub_chunk = []
                    sub_len = 0
                    sub_idx += 1
            if sub_chunk:
                body = clean_text('\n\n'.join(sub_chunk))
                chunk_id = f"dars_{Path(file_path).stem}_{idx}_{sub_idx}"
                chunks.append({
                    "id": chunk_id,
                    "title": f"{title} (qism {sub_idx})" if sub_idx > 1 else title,
                    "module": module_name,
                    "category": category,
                    "content": body,
                    "source_path": str(file_path)
                })
        else:
            chunk_id = f"dars_{Path(file_path).stem}_{idx}"
            chunks.append({
                "id": chunk_id,
                "title": title,
                "module": module_name,
                "category": category,
                "content": sec,
                "source_path": str(file_path)
            })

def process_dars():
    print("Processing DARS markdowns...")
    for root, dirs, files in os.walk(DARS_DIR):
        # Skip temporary and archive folders
        if "99. Xizmat fayllari va arxiv" in root or "output" in root:
            continue
        for f in files:
            if f.endswith(".md"):
                fp = os.path.join(root, f)
                rel = os.path.relpath(fp, DARS_DIR)
                
                # Determine module name
                mod = "Umumiy"
                if "1. Windows" in rel: mod = "1-modul: Windows va Ofis"
                elif "2. ERI" in rel: mod = "2-modul: ERI va Brauzer"
                elif "3. Axborot" in rel: mod = "3-modul: Axborot xavfsizligi"
                elif "4. Oliy sud" in rel: mod = "4-modul: Oliy sud axborot tizimlari va EDO"
                elif "5. VKA" in rel or "5_modul" in rel: mod = "5-modul: VKA va audio-video"

                try:
                    with open(fp, "r", encoding="utf-8") as rf:
                        content = rf.read()
                    chunk_markdown(content, fp, mod, "dars")
                except Exception as e:
                    print(f"Error reading {fp}: {e}")

def process_sud_qollanmalari():
    print("Processing Sud_Qollanmalari PDFs...")
    for root, dirs, files in os.walk(QOLLANMALAR_DIR):
        for f in files:
            if f.endswith(".pdf"):
                fp = os.path.join(root, f)
                rel = os.path.relpath(fp, QOLLANMALAR_DIR)
                
                cat = "sud_qollanma"
                if "1. EDO" in rel: cat = "edo"
                elif "2. JIB" in rel: cat = "jib_esud"
                elif "3. M-SUD" in rel: cat = "m_sud"
                elif "4. ADOLAT" in rel: cat = "adolat"
                elif "5. E-IMZO" in rel: cat = "e_imzo"
                elif "6. Maqolalar" in rel: cat = "maqola"

                try:
                    doc = fitz.open(fp)
                    full_text = []
                    for page_num in range(len(doc)):
                        p_txt = doc[page_num].get_text()
                        if p_txt.strip():
                            full_text.append(p_txt)
                    
                    text = clean_text('\n\n'.join(full_text))
                    if not text or len(text) < 40:
                        continue
                    
                    stem = Path(f).stem
                    clean_title = re.sub(r'^\d+[\._\s]*', '', stem).replace('_', ' ').strip()
                    
                    # Split into chunks of ~1200 chars
                    paras = text.split('\n\n')
                    sub_chunk = []
                    sub_len = 0
                    part = 1
                    for p in paras:
                        sub_chunk.append(p)
                        sub_len += len(p)
                        if sub_len >= 1200:
                            body = clean_text('\n\n'.join(sub_chunk))
                            c_id = f"pdf_{cat}_{re.sub(r'[^a-zA-Z0-9]', '', stem[:20])}_{part}"
                            chunks.append({
                                "id": c_id,
                                "title": f"{clean_title} (qism {part})" if part > 1 else clean_title,
                                "module": f"Sud Qo'llanma: {cat.upper()}",
                                "category": cat,
                                "content": body,
                                "source_path": str(fp)
                            })
                            sub_chunk = []
                            sub_len = 0
                            part += 1
                    if sub_chunk:
                        body = clean_text('\n\n'.join(sub_chunk))
                        c_id = f"pdf_{cat}_{re.sub(r'[^a-zA-Z0-9]', '', stem[:20])}_{part}"
                        chunks.append({
                            "id": c_id,
                            "title": f"{clean_title} (qism {part})" if part > 1 else clean_title,
                            "module": f"Sud Qo'llanma: {cat.upper()}",
                            "category": cat,
                            "content": body,
                            "source_path": str(fp)
                        })
                except Exception as e:
                    print(f"Error processing PDF {fp}: {e}")

def process_videos():
    print("Processing EDO videos...")
    if not os.path.exists(VIDEOS_DIR):
        return
    for f in os.listdir(VIDEOS_DIR):
        if f.endswith(".mp4"):
            fp = os.path.join(VIDEOS_DIR, f)
            title = Path(f).stem.replace('-', ' ').replace('_', ' ')
            size_mb = round(os.path.getsize(fp) / (1024 * 1024), 1)
            chunks.append({
                "id": f"video_edo_{re.sub(r'[^a-zA-Z0-9]', '', Path(f).stem)}",
                "title": f"Video dars: {title}",
                "module": "4-modul: Oliy sud axborot tizimlari va EDO",
                "category": "video_tutorial",
                "content": f"Elektron Hujjat Aylanmasi (EDO) bo'yicha amaliy video qo'llanma: {title}. Fayl hajmi: {size_mb} MB. Mavzu: sud tizimida EDO dan foydalanish, ERI bilan kirish va imzolash tartibi.",
                "source_path": str(fp)
            })

def main():
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    process_dars()
    process_sud_qollanmalari()
    process_videos()
    print(f"Total extracted chunks: {len(chunks)}")
    with open(OUTPUT_FILE, "w", encoding="utf-8") as wf:
        json.dump(chunks, wf, ensure_ascii=False, indent=2)
    print(f"Saved raw chunks to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
