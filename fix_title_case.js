const admin = require('firebase-admin');

// Agar FIREBASE_EMULATOR_HOST o'rnatilmagan bo'lsa local environmentdan ishlaydi
admin.initializeApp({
  projectId: 'educationapp-4780a'
});

const db = admin.firestore();

// So'zlarni tekshirish uchun maxsus qoida
function toSentenceCase(str) {
  if (!str) return str;
  // Acronyms va proper noun lar katta harfda qolishi kerak (E-SUD, E-XAT kabi)
  const acronyms = ["FAQ", "TSS", "E-SUD", "E-XAT", "IT", "BMI", "UI", "UX", "API", "OS", "PC"];
  
  const words = str.trim().split(/\s+/);
  if (words.length === 0) return str;

  const newWords = words.map((word, index) => {
    // Toza harflarni ajratib olamiz (tinish belgilarsiz tekshirish uchun)
    const cleanWord = word.replace(/[.,!?()[\]{}"':;]/g, '');
    
    // Agar u acronym bo'lsa
    if (acronyms.includes(cleanWord.toUpperCase())) {
      // E-SUD kabi qoldirish, lekin tinish belgilarini joyiga qaytarish kerak
      // Bu yerda faqat to'liq upper case qilib qo'yish ham bo'ladi, chunki abbreviatura:
      return word.toUpperCase();
    }
    
    // Aks holda 1-so'z Kapital, qolganlar lower
    if (index === 0) {
      return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
    }
    
    return word.toLowerCase();
  });
  
  return newWords.join(' ');
}

async function run() {
  console.log("Checking courses in Firestore...");
  const coursesSnapshot = await db.collection('courses').get();
  
  let batch = db.batch();
  let count = 0;
  let updatedCourses = 0;

  for (const doc of coursesSnapshot.docs) {
    const data = doc.data();
    let updated = false;
    
    const newTitle = toSentenceCase(data.title);
    if (newTitle !== data.title) {
        console.log(`[Course] Fix: "${data.title}" -> "${newTitle}"`);
        data.title = newTitle;
        updated = true;
    }

    if (data.modules && Array.isArray(data.modules)) {
        for (let m = 0; m < data.modules.length; m++) {
            const moduleTitle = toSentenceCase(data.modules[m].title);
            if (moduleTitle !== data.modules[m].title) {
                console.log(`  [Module] Fix: "${data.modules[m].title}" -> "${moduleTitle}"`);
                data.modules[m].title = moduleTitle;
                updated = true;
            }
            
            if (data.modules[m].lessons && Array.isArray(data.modules[m].lessons)) {
                for (let l = 0; l < data.modules[m].lessons.length; l++) {
                    const lessonTitle = toSentenceCase(data.modules[m].lessons[l].title);
                    if (lessonTitle !== data.modules[m].lessons[l].title) {
                        console.log(`    [Lesson] Fix: "${data.modules[m].lessons[l].title}" -> "${lessonTitle}"`);
                        data.modules[m].lessons[l].title = lessonTitle;
                        updated = true;
                    }
                }
            }
        }
    }

    if (updated) {
        batch.update(doc.ref, { 
            title: data.title,
            modules: data.modules 
        });
        count++;
        updatedCourses++;
        
        if (count >= 400) {
            await batch.commit();
            batch = db.batch();
            count = 0;
        }
    }
  }

  if (count > 0) {
      await batch.commit();
  }

  console.log(`\nYakunlandi. Jami ${updatedCourses} ta kurs va uning ichidagi darsliklar 'Sentence case' formatiga tushirildi.`);
}

run().catch(console.error);
