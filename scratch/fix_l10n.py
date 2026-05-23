import json
import os
import re

def fix_capitalization(text):
    if not isinstance(text, str):
        return text
    
    # Preserve placeholders like {name}
    placeholders = re.findall(r'\{[^{}]+\}', text)
    temp_text = re.sub(r'\{[^{}]+\}', '___PLACEHOLDER___', text)
    
    # List of acronyms and proper nouns to preserve
    preserve = {
        'FAQ', 'TSS', 'F.I.Sh.', 'AKT', 'YouTube', 'PDF', 'URL', 'ID', 'E-SUD', 'E-XAT', 
        'ICT', 'Google', 'XP', 'OS', 'GB', 'MB', 'TB', 'KB', 'UI', 'UX', 'API', 'JSON', 
        'XML', 'HTML', 'CSS', 'JS', 'Dart', 'Flutter', 'OK', 'F.I.Sh'
    }
    
    # Handle All Caps (if more than one word and all caps)
    words = temp_text.split()
    if len(words) > 0:
        # If the whole string is uppercase and contains spaces, or is a single word but not in preserve list
        if temp_text.isupper() and len(temp_text) > 2 and temp_text not in preserve:
            # Special case for acronyms that might be ALL CAPS in the original but should stay that way
            # But the user specifically said "FINISH" -> "Finish"
            # So if it's all caps, we convert it to sentence case.
            temp_text = temp_text.capitalize()
    
    # Handle Title Case
    # Regex to find words starting with a capital letter that are not at the beginning of the sentence
    # and not in the preserve list.
    def replace_word(match):
        word = match.group(0)
        # If it's a punctuation or something, keep it
        if not word.strip():
            return word
        
        # Check if it's in preserve list
        # We strip punctuation from the word to check
        clean_word = re.sub(r'[^\w\-.]', '', word)
        if clean_word in preserve or clean_word.upper() in preserve:
            return word
        
        # If it's the first word of the text, keep its first letter case (usually capital)
        # But for other words, convert to lowercase if they are capitalized
        return word.lower()

    # Split by spaces and handle each word after the first one
    words = temp_text.split(' ')
    if len(words) > 1:
        new_words = [words[0]]
        for word in words[1:]:
            # Check if word starts with a capital letter
            if len(word) > 0 and word[0].isupper():
                # Check if it's an acronym
                clean_word = re.sub(r'[^\w\-.]', '', word)
                if clean_word not in preserve and clean_word.upper() not in preserve:
                    new_words.append(word[0].lower() + word[1:])
                else:
                    new_words.append(word)
            else:
                new_words.append(word)
        temp_text = ' '.join(new_words)

    # Restore placeholders
    for p in placeholders:
        temp_text = temp_text.replace('___PLACEHOLDER___', p, 1)
        
    return temp_text

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    changed = False
    for key, value in data.items():
        if not key.startswith('@'):
            new_value = fix_capitalization(value)
            if new_value != value:
                data[key] = new_value
                changed = True
    
    if changed:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Fixed: {file_path}")
    else:
        print(f"No changes: {file_path}")

paths = [
    r'd:\project_BMI\b-v2\education_app\lib\l10n\app_uz.arb',
    r'd:\project_BMI\b-v2\education_app\lib\l10n\app_en.arb',
    r'd:\project_BMI\b-v2\education_app\lib\l10n\app_ru.arb'
]

for p in paths:
    if os.path.exists(p):
        process_file(p)
    else:
        print(f"Not found: {p}")
