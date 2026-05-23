const admin = require('firebase-admin');

// Initialize with the project ID
admin.initializeApp({
  projectId: 'educationapp-4780a'
});

const db = admin.firestore();

const categories = [
  { id: 'beginner', nameUz: 'Boshlang\'ich', nameEn: 'Beginner' },
  { id: 'intermediate', nameUz: 'O\'rta', nameEn: 'Intermediate' },
  { id: 'advanced', nameUz: 'Yuqori', nameEn: 'Advanced' },
  { id: 'practical', nameUz: 'Amaliy', nameEn: 'Practical' },
  { id: 'theoretical', nameUz: 'Nazariy', nameEn: 'Theoretical' }
];

async function initCategories() {
  console.log('Starting category initialization...');
  const batch = db.batch();
  
  for (const cat of categories) {
    const docRef = db.collection('categories').doc(cat.id);
    batch.set(docRef, {
      name_uz: cat.nameUz,
      name_en: cat.nameEn,
      created_at: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log(`Prepared category: ${cat.id}`);
  }
  
  await batch.commit();
  console.log('All categories initialized successfully.');
}

initCategories().catch(err => {
  console.error('Error initializing categories:', err);
  process.exit(1);
});
