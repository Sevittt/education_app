// "Sud Qoʻllanma — Yangi dizayn (mobil)" Figma fayli uchun bir martalik plagin.
// Figma MCP limiti tugagani uchun qolgan ishni bajaradi:
//  1. "01 · Dizayn tizimi": sarlavha/tamoyillar, ranglar (yorugʻ + qorongʻi),
//     tipografiya va oʻlchamlar doskalari; sahifa tartibi.
//  2. "02 · Ekranlar": 9 ta ekranning qorongʻi nusxalari (ranglar qorongʻi
//     kolleksiyaga bogʻlanadi), reyting avatarlarini tuzatish, qator sarlavhalari.
// Qayta ishga tushirilsa, bajarilgan qismlar takrorlanmaydi.

const TN = ['bg/canvas', 'bg/surface', 'bg/subtle', 'bg/elevated', 'border/default', 'border/strong', 'text/primary', 'text/secondary', 'text/tertiary', 'text/on-brand', 'brand/primary', 'brand/pressed', 'brand/container', 'brand/on-container', 'gold/solid', 'gold/ink', 'gold/container', 'success/solid', 'success/container', 'danger/solid', 'danger/container', 'streak/solid', 'streak/container'];
const HL = { 'hero/bg': 'VariableID:6:70', 'hero/fg': 'VariableID:6:72', 'hero/muted': 'VariableID:6:74', 'hero/track': 'VariableID:6:76' };
const HD = { 'hero/bg': 'VariableID:6:71', 'hero/fg': 'VariableID:6:73', 'hero/muted': 'VariableID:6:75', 'hero/track': 'VariableID:6:77' };
const ALLN = TN.concat(Object.keys(HL));
const LID = n => (TN.includes(n) ? 'VariableID:2:' + (4 + TN.indexOf(n)) : HL[n]);
const DID = n => (TN.includes(n) ? 'VariableID:2:' + (56 + TN.indexOf(n)) : HD[n]);
const TS = { 'Display/L': 'S:c281e98d9c1223a7754824ff31c4ff755cda64b9,', 'Display/M': 'S:b08239eb0a8560e30b03f8e4e82d6d43e9b50ed6,', 'Title/L': 'S:9efa1653410380873cdf219947dfddf108898177,', 'Title/M': 'S:b9b0f2c74ad7336e8d69f7c89996294cb2d05371,', 'Title/S': 'S:76bacc4372b63f578495e7e6947f7feaf2e73ba7,', 'Body/L': 'S:939083e76c14919d0d2b99b85a34703ce0d22766,', 'Body/M': 'S:63478a35e1837fcdfa8b1eb2737a770937f5d296,', 'Body/S': 'S:8b1b2352da27c7d8da39d7f4d185d9635ffd647a,', 'Label/M': 'S:c2dbefcf4c40ea5aff8b7131d4e02996d43e251a,', 'Label/S': 'S:22bf128f3f28e2ada9ee8244da4c13ffb4906b81,', 'Caption': 'S:3944e3cc591adee14112579dc9564bee22efae13,', 'Numeric/L': 'S:73f3aa3d58b99f03576461d66b9d4696a5a56666,', 'Numeric/M': 'S:ecc8e2a362aea610c109b30424263f9d8ccdb2d5,' };
const SCREENS = ['8:70', '9:157', '9:364', '12:396', '12:524', '13:448', '13:544', '14:493', '14:654'];
const DARK_SUFFIX = ' · qorongʻi';

const VL = {};
const VD = {};
let LM, DM;

const bind = v => figma.variables.setBoundVariableForPaint({ type: 'SOLID', color: { r: 0, g: 0, b: 0 } }, 'color', v);
const PL = n => bind(VL[n]);
const PD = n => bind(VD[n]);
const hex = c => '#' + [c.r, c.g, c.b].map(x => Math.round(x * 255).toString(16).padStart(2, '0')).join('').toUpperCase();

function AL(dir, o = {}) {
  const f = figma.createFrame();
  f.layoutMode = dir;
  f.primaryAxisSizingMode = 'AUTO';
  f.counterAxisSizingMode = 'AUTO';
  f.fills = o.fill ? [o.fill] : [];
  if (o.name) f.name = o.name;
  if (o.gap != null) f.itemSpacing = o.gap;
  if (o.p != null) f.paddingTop = f.paddingBottom = f.paddingLeft = f.paddingRight = o.p;
  if (o.r != null) f.cornerRadius = o.r;
  if (o.stroke) { f.strokes = [o.stroke]; f.strokeWeight = 1; f.strokeAlign = 'INSIDE'; }
  if (o.align) f.counterAxisAlignItems = o.align;
  if (o.w) { f.resize(o.w, 10); f.layoutSizingHorizontal = 'FIXED'; f.layoutSizingVertical = 'HUG'; }
  return f;
}

async function T(s, st, fill) {
  const t = figma.createText();
  await t.setTextStyleIdAsync(TS[st]);
  t.characters = s;
  t.fills = [fill];
  t.name = s.slice(0, 30);
  return t;
}

function add(p, c, mode) {
  p.appendChild(c);
  if (mode === 'fill') c.layoutSizingHorizontal = 'FILL';
  if (mode === 'wrap') { c.textAutoResize = 'HEIGHT'; c.layoutSizingHorizontal = 'FILL'; }
  return c;
}

async function buildDesignSystemPage(page1) {
  const hdr = AL('VERTICAL', { name: 'Sarlavha va tamoyillar', gap: 16, p: 40, r: 24, fill: PL('hero/bg'), w: 1400 });
  add(hdr, await T('Sud Qoʻllanma — Dizayn tizimi', 'Display/L', PL('hero/fg')), 'wrap');
  add(hdr, await T('Sud xodimlari uchun oʻquv ilovasi. Rasmiy va ishonchli, lekin zamonaviy: toʻq koʻk brend, kam ishlatiladigan oltin urgʻu, Noto Serif sarlavhalar va Inter matn.', 'Body/L', PL('hero/muted')), 'wrap');
  const pr = AL('HORIZONTAL', { gap: 16, name: 'Tamoyillar' });
  add(hdr, pr, 'fill');
  for (const [t, d] of [
    ['Bitta asosiy harakat', 'Har ekranda bitta «Asosiy» tugma — pastki panelda yoki asosiy kartada.'],
    ['Holat sababi bilan', 'Qulflangan dars nega qulfligini va qachon ochilishini aytadi.'],
    ['Rang — maʼno', 'Oltin — yutuq va sertifikat, yashil — tugallangan, qizil — xato, toʻq sariq — seriya.'],
    ['Bitta brend, ikki rejim', 'Yorugʻda toʻq koʻk, qorongʻida och koʻk. Gradient, shisha effekt va emoji yoʻq.'],
  ]) {
    const c = AL('VERTICAL', { gap: 6, p: 20, r: 16, fill: PL('hero/track') });
    add(pr, c, 'fill');
    add(c, await T(t, 'Title/M', PL('hero/fg')), 'wrap');
    add(c, await T(d, 'Body/M', PL('hero/muted')), 'wrap');
  }

  const cb = AL('VERTICAL', { name: 'Ranglar', gap: 24, p: 32, r: 24, fill: PL('bg/surface'), w: 1400 });
  add(cb, await T('Ranglar', 'Display/M', PL('text/primary')), 'wrap');
  add(cb, await T('Har bir rang — oʻzgaruvchi (token). Nomlar ikki rejimda bir xil: yorugʻ ekranlar «Ranglar · Yorugʻ», qorongʻilari «Ranglar · Qorongʻi» kolleksiyasiga bogʻlangan (Starter rejada kolleksiyada 1 ta rejim).', 'Body/M', PL('text/secondary')), 'wrap');
  const cols = AL('HORIZONTAL', { gap: 24, name: 'Rejimlar' });
  add(cb, cols, 'fill');
  for (const dark of [false, true]) {
    const V = dark ? VD : VL;
    const M = dark ? DM : LM;
    const P = dark ? PD : PL;
    const col = AL('VERTICAL', { gap: 16, p: 24, r: 20, fill: P('bg/canvas'), name: dark ? 'Qorongʻi' : 'Yorugʻ' });
    add(cols, col, 'fill');
    add(col, await T(dark ? 'Qorongʻi rejim' : 'Yorugʻ rejim', 'Title/L', P('text/primary')), 'wrap');
    const grid = AL('HORIZONTAL', { gap: 12, name: 'Tokenlar' });
    add(col, grid, 'fill');
    grid.layoutWrap = 'WRAP';
    grid.counterAxisSpacing = 12;
    for (const n of ALLN) {
      const chip = AL('HORIZONTAL', { gap: 10, p: 8, r: 12, fill: P('bg/surface'), stroke: P('border/default'), align: 'CENTER', w: 298, name: n });
      grid.appendChild(chip);
      const sw = figma.createRectangle();
      sw.name = 'Namuna';
      sw.resize(40, 40);
      sw.cornerRadius = 8;
      sw.fills = [bind(V[n])];
      sw.strokes = [P('border/default')];
      sw.strokeWeight = 1;
      chip.appendChild(sw);
      const tc = AL('VERTICAL', { gap: 0 });
      add(chip, tc, 'fill');
      tc.appendChild(await T(n, 'Label/M', P('text/primary')));
      tc.appendChild(await T(hex(V[n].valuesByMode[M]), 'Body/S', P('text/secondary')));
    }
  }

  const tb = AL('VERTICAL', { name: 'Tipografiya', gap: 20, p: 32, r: 24, fill: PL('bg/surface'), w: 1400 });
  add(tb, await T('Tipografiya', 'Display/M', PL('text/primary')), 'wrap');
  add(tb, await T('Sarlavhalar — Noto Serif (rasmiy ohang), qolgani — Inter. Ikkalasi ham oʻ/gʻ (U+02BB), tutuq (U+02BC) va yangi alifbodagi Ö, Ğ, Ş, Ç harflarini toʻliq qoʻllaydi.', 'Body/M', PL('text/secondary')), 'wrap');
  for (const [st, spec, sample] of [
    ['Display/L', 'Noto Serif SemiBold · 28/34', 'Elektron ish yuritish'],
    ['Display/M', 'Noto Serif SemiBold · 22/28', 'Test topshirildi!'],
    ['Title/L', 'Inter Semi Bold · 18/24', 'Elektron raqamli imzo bilan ishlash'],
    ['Title/M', 'Inter Semi Bold · 16/22', 'Davom ettirish'],
    ['Title/S', 'Inter Semi Bold · 14/20', '2.3 Elektron raqamli imzo bilan ishlash'],
    ['Body/L', 'Inter Regular · 16/24', 'Vakolatli shaxsning elektron raqamli imzosi bilan tasdiqlanganda'],
    ['Body/M', 'Inter Regular · 14/20', 'Videoni oxirigacha koʻrsangiz, dars avtomatik yakunlanadi va +10 XP beriladi.'],
    ['Body/S', 'Inter Regular · 12/16', 'Avval 2.3-darsni tugating'],
    ['Label/M', 'Inter Medium · 14/20', 'Barchasi'],
    ['Label/S', 'Inter Medium · 12/16', '12:40 / 18:05'],
    ['Caption', 'Inter Semi Bold · 11/14 · +2%', 'DAVOM ETTIRISH'],
    ['Numeric/L', 'Inter Bold · 32/36', '1 640'],
    ['Numeric/M', 'Inter Semi Bold · 20/24', '80%'],
  ]) {
    const row = AL('HORIZONTAL', { gap: 24, align: 'CENTER', name: st });
    add(tb, row, 'fill');
    const left = AL('VERTICAL', { gap: 2, w: 260 });
    row.appendChild(left);
    left.appendChild(await T(st, 'Title/S', PL('text/primary')));
    left.appendChild(await T(spec, 'Body/S', PL('text/secondary')));
    add(row, await T(sample, st, PL('text/primary')), 'wrap');
  }
  const na = AL('HORIZONTAL', { gap: 24, align: 'CENTER', p: 16, r: 16, fill: PL('brand/container'), name: 'Yangi alifbo namunasi' });
  add(tb, na, 'fill');
  const nal = AL('VERTICAL', { gap: 2, w: 244 });
  na.appendChild(nal);
  nal.appendChild(await T('Yangi alifbo (OʻRQ-1184)', 'Title/S', PL('brand/on-container')));
  nal.appendChild(await T('Til sozlamasida tanlanadi', 'Body/S', PL('text/secondary')));
  add(na, await T('Töğri javob · Boş sahifa · Çiqiş · Özbekça — Ğalaba, Şaxs, Çempion', 'Body/L', PL('brand/on-container')), 'wrap');

  const zb = AL('VERTICAL', { name: 'Oʻlchamlar', gap: 20, p: 32, r: 24, fill: PL('bg/surface'), w: 1400 });
  add(zb, await T('Oʻlchamlar', 'Display/M', PL('text/primary')), 'wrap');
  add(zb, await T('Oraliqlar 4 ga karrali; ekran chetlari 16, kartalar ichi 16–20, boʻlimlar orasi 20–24. Burchaklar: tugma 12, karta 16, asosiy karta 20.', 'Body/M', PL('text/secondary')), 'wrap');
  const zr = AL('HORIZONTAL', { gap: 48, name: 'Shkalalar' });
  add(zb, zr, 'fill');
  const sp = AL('HORIZONTAL', { gap: 20, align: 'MAX', name: 'Oraliqlar' });
  zr.appendChild(sp);
  for (const s of [4, 8, 12, 16, 20, 24, 32]) {
    const c = AL('VERTICAL', { gap: 6, align: 'CENTER' });
    sp.appendChild(c);
    const r = figma.createRectangle();
    r.resize(s, 32);
    r.fills = [PL('brand/primary')];
    c.appendChild(r);
    c.appendChild(await T('space/' + s, 'Label/S', PL('text/secondary')));
  }
  const rd = AL('HORIZONTAL', { gap: 20, align: 'MAX', name: 'Radiuslar' });
  zr.appendChild(rd);
  for (const [n, v] of [['sm', 8], ['md', 12], ['lg', 16], ['xl', 20], ['full', 32]]) {
    const c = AL('VERTICAL', { gap: 6, align: 'CENTER' });
    rd.appendChild(c);
    const r = figma.createRectangle();
    r.resize(64, 64);
    r.cornerRadius = v;
    r.fills = [PL('brand/container')];
    r.strokes = [PL('brand/primary')];
    r.strokeWeight = 1.5;
    c.appendChild(r);
    c.appendChild(await T('radius/' + n, 'Label/S', PL('text/secondary')));
  }

  let y = 0;
  for (const n of [hdr, cb, tb, zb]) { n.x = 0; n.y = y; y += n.height + 80; }
  const label = async (s, yy) => { const t = await T(s, 'Display/M', PL('text/primary')); t.x = 0; t.y = yy; page1.appendChild(t); };
  await label('Ikonkalar', y);
  y += 56;
  const icons = await figma.getNodeByIdAsync('3:2');
  icons.x = 0; icons.y = y; y += icons.height + 80;
  await label('Komponentlar', y);
  y += 56;
  const k1 = await figma.getNodeByIdAsync('4:2');
  const k2 = await figma.getNodeByIdAsync('5:14');
  k1.x = 0; k1.y = y; k2.x = k1.width + 80; k2.y = y;
}

async function buildDarkRow(page2) {
  const s9 = await figma.getNodeByIdAsync('14:654');
  const pod = s9 && s9.findOne(n => n.name === 'Top 3');
  if (pod) {
    for (const av of pod.findAll(n => n.name === 'Avatar')) av.strokeAlign = 'INSIDE';
    for (const c of pod.children) c.clipsContent = false;
  }

  const created = [];
  if (!page2.children.some(n => n.name.endsWith(DARK_SUFFIX))) {
    const map = {};
    for (const n of ALLN) map[LID(n)] = n;
    const swap = arr => {
      let changed = false;
      const out = arr.map(p => {
        const b = p.boundVariables && p.boundVariables.color;
        if (b && map[b.id]) { changed = true; return figma.variables.setBoundVariableForPaint(p, 'color', VD[map[b.id]]); }
        return p;
      });
      return changed ? out : null;
    };
    const retheme = root => {
      for (const n of [root].concat(root.findAll(() => true))) {
        for (const prop of ['fills', 'strokes']) {
          if (!(prop in n)) continue;
          const arr = n[prop];
          if (!Array.isArray(arr) || !arr.length) continue;
          const out = swap(arr);
          if (out) n[prop] = out;
        }
      }
    };
    for (const id of SCREENS) {
      const s = await figma.getNodeByIdAsync(id);
      const c = s.clone();
      c.x = s.x; c.y = 1700; c.name = s.name + DARK_SUFFIX;
      retheme(c);
      created.push(c);
    }
  }

  if (!page2.children.some(n => n.name === 'Qator sarlavhasi')) {
    for (const [t, sub, yy] of [
      ['Yorugʻ rejim', 'Oqim: Bosh sahifa → Kurslar → Kurs → Dars (video) → Test → Natija → Profil / Reyting', -110],
      ['Qorongʻi rejim', 'Xuddi shu ekranlar — ranglar «Ranglar · Qorongʻi» kolleksiyasiga bogʻlangan', 1590],
    ]) {
      const g = AL('VERTICAL', { gap: 4, name: 'Qator sarlavhasi' });
      g.x = 0; g.y = yy;
      g.appendChild(await T(t, 'Display/L', PL('text/primary')));
      g.appendChild(await T(sub, 'Body/M', PL('text/secondary')));
    }
  }
  return created;
}

async function main() {
  const page1 = await figma.getNodeByIdAsync('0:1');
  const page2 = await figma.getNodeByIdAsync('2:2');
  const lc = await figma.variables.getVariableCollectionByIdAsync('VariableCollectionId:2:3');
  const dc = await figma.variables.getVariableCollectionByIdAsync('VariableCollectionId:2:55');
  if (!page1 || !page2 || !lc || !dc || !(await figma.getNodeByIdAsync('8:70'))) {
    return 'Bu boshqa fayl. "Sud Qoʻllanma — Yangi dizayn (mobil)" faylini oching.';
  }
  LM = lc.modes[0].modeId;
  DM = dc.modes[0].modeId;
  await Promise.all(ALLN.map(async n => {
    VL[n] = await figma.variables.getVariableByIdAsync(LID(n));
    VD[n] = await figma.variables.getVariableByIdAsync(DID(n));
  }));
  await Promise.all([['Inter', 'Regular'], ['Inter', 'Medium'], ['Inter', 'Semi Bold'], ['Inter', 'Bold'], ['Noto Serif', 'SemiBold']]
    .map(([family, style]) => figma.loadFontAsync({ family, style })));

  await figma.setCurrentPageAsync(page1);
  const dsDone = page1.children.some(n => n.name === 'Ranglar');
  if (!dsDone) await buildDesignSystemPage(page1);

  await figma.setCurrentPageAsync(page2);
  const dark = await buildDarkRow(page2);
  if (dark.length) figma.viewport.scrollAndZoomIntoView(dark);

  return `Tayyor: dizayn tizimi ${dsDone ? 'oldin yaratilgan' : 'yaratildi'}, ${dark.length ? dark.length + ' ta qorongʻi ekran yaratildi' : 'qorongʻi ekranlar oldin yaratilgan'}.`;
}

main()
  .then(msg => figma.closePlugin(msg))
  .catch(e => figma.closePlugin('Xato: ' + (e && e.message ? e.message : e)));
