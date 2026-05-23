# SUD QO‘LLANMA ECOSYSTEM: Digital Mentor Skills & Rules

## 🎨 UI/UX Styling Rules

### 1. Text Capitalization (Strict)
- **Rule**: All UI strings, especially multi-word phrases, must follow **Sentence case**.
- **Format**: The first word must start with a Capital letter, and all subsequent words must be in lowercase (unless they are proper nouns or acronyms like FAQ, TSS, E-SUD, E-XAT).
- **Prohibited**: NEVER use all-caps for multi-word strings (e.g., "TEZKOR BONUS") and avoid Title Case where every word is capitalized (e.g., "Tezkor Bonus").
- **Examples**:
  - ✅ "Tezkor bonus"
  - ❌ "TEZKOR BONUS"
  - ❌ "Tezkor Bonus"
  - ✅ "Umumiy ko'rinish"
  - ❌ "UMUMIY KO'RINISH"
  - ✅ "Tizim ma'lumotlari"
  - ❌ "TIZIM MA'LUMOTLARI"

### 2. TabBar Contrast
- When using a `TabBar` inside a primary-colored `AppBar`, always ensure high contrast:
  - `labelColor: Colors.white`
  - `unselectedLabelColor: Colors.white70`
  - `indicatorColor: Colors.white`

## 🛠 Tech Stack & Architecture
- **Framework**: Flutter (Feature-First Clean Architecture)
- **State Management**: Provider
- **Database**: Cloud Firestore
- **AI**: Gemini 2.5 Flash (via Firebase AI Logic)

## ✍️ Writing Style
- **Case**: Always use **Sentence case** for UI strings (e.g., "Hisob ma'lumotlari").
- **Consistency**: The first word is Capitalized, subsequent words are lowercase (except proper nouns/acronyms).
- **No Title Case**: Avoid "Hisob Ma'lumotlari" or "Hisobni Tahrirlash".
- **No All Caps**: Avoid "HISOB MA'LUMOTLARI".

## 🔒 Security
- Always verify Telegram `user_id` in bot handlers.
- Use `FieldValue.increment()` for atomic updates in Firestore.

