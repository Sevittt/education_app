const fs = require('fs');
const path = require('path');

const keys = {
  en: {
    myCoursesTitle: 'My courses',
    myCoursesEmptyTitle: 'You haven\'t started any courses yet',
    myCoursesEmptySubtitle: 'Start courses to learn new skills and earn XP.',
  },
  uz: {
    myCoursesTitle: 'Mening kurslarim',
    myCoursesEmptyTitle: 'Hali hech qanday kursni boshlamadingiz',
    myCoursesEmptySubtitle: 'Yangi bilimlarni o\'zlashtirish va XP ishlash uchun kurslarni boshlang.',
  },
  ru: {
    myCoursesTitle: 'Мои курсы',
    myCoursesEmptyTitle: 'Вы еще не начали ни одного курса',
    myCoursesEmptySubtitle: 'Начните курсы, чтобы получить новые знания и заработать XP.',
  }
};

const l10nDir = path.join(process.cwd(), 'lib', 'l10n');

for (const lang of Object.keys(keys)) {
  const filePath = path.join(l10nDir, `app_${lang}.arb`);
  if (!fs.existsSync(filePath)) continue;

  const content = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  for (const [key, value] of Object.entries(keys[lang])) {
    content[key] = value;
    content['@' + key] = { description: 'Translation for ' + key };
  }
  
  fs.writeFileSync(filePath, JSON.stringify(content, null, 2) + '\n', 'utf8');
  console.log('Updated ' + filePath);
}
