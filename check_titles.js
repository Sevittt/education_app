const admin = require('firebase-admin');

// Agar firebase-admin initialize qilinmagan bo'lsa:
const serviceAccount = require('./.firebase/serviceAccountKey.json'); // yoki qayerda bo'lsa
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function getTitles() {
  const coursesSnapshot = await db.collection('courses').get();
  coursesSnapshot.forEach(doc => {
    const data = doc.data();
    console.log(`Course: ${data.title}`);
    const modules = data.modules || [];
    modules.forEach(m => {
        console.log(`  Module: ${m.title}`);
        const lessons = m.lessons || [];
        lessons.forEach(l => {
            console.log(`    Lesson: ${l.title}`);
        });
    });
  });
}

getTitles().catch(console.error);
