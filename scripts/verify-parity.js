/**
 * Verification Script: Swift & JS Game Catalog & Engine Parity Test
 * Ensures 100% synchronization between Swift watchOS app and Web Simulator
 */

const fs = require('fs');
const path = require('path');
const http = require('http');

const SWIFT_PATH = path.join(__dirname, '..', 'WristArcade', 'Core', 'GameProtocol.swift');
const APP_JS_PATH = path.join(__dirname, '..', 'Simulator', 'app.js');
const LOC_PATH = path.join(__dirname, '..', 'WristArcade', 'Core', 'LocalizationManager.swift');
const SCORE_PATH = path.join(__dirname, '..', 'WristArcade', 'Core', 'ScoreManager.swift');
const CONTENT_VIEW_PATH = path.join(__dirname, '..', 'WristArcade', 'Views', 'ContentView.swift');

console.log('===================================================');
console.log('  WristArcade Parity & Integrity Verification');
console.log('===================================================\n');

let passedTests = 0;
let totalTests = 0;

function assert(condition, message) {
  totalTests++;
  if (condition) {
    console.log(`  [PASS] ${message}`);
    passedTests++;
  } else {
    console.error(`  [FAIL] ${message}`);
    process.exitCode = 1;
  }
}

// 1. Check file existence
assert(fs.existsSync(SWIFT_PATH), 'GameProtocol.swift exists');
assert(fs.existsSync(APP_JS_PATH), 'app.js exists');
assert(fs.existsSync(LOC_PATH), 'LocalizationManager.swift exists');
assert(fs.existsSync(SCORE_PATH), 'ScoreManager.swift exists');
assert(fs.existsSync(CONTENT_VIEW_PATH), 'ContentView.swift exists');

const swiftCode = fs.readFileSync(SWIFT_PATH, 'utf8');
const jsCode = fs.readFileSync(APP_JS_PATH, 'utf8');
const locCode = fs.readFileSync(LOC_PATH, 'utf8');
const scoreCode = fs.readFileSync(SCORE_PATH, 'utf8');
const contentViewCode = fs.readFileSync(CONTENT_VIEW_PATH, 'utf8');

// 2. Extract Swift GameItems
// Regex to extract GameItem definitions:
// GameItem(id: "blackjack", ... isFreeByDefault: true, ... categoryKey: "cat_cards", ...)
const swiftGameMatches = [...swiftCode.matchAll(/GameItem\s*\(\s*id:\s*"([^"]+)",[\s\S]*?isFreeByDefault:\s*(true|false)[\s\S]*?categoryKey:\s*"cat_([a-zA-Z]+)"/g)];

const swiftGames = swiftGameMatches.map(m => ({
  id: m[1],
  isFree: m[2] === 'true',
  category: m[3]
}));

console.log(`\nFound ${swiftGames.length} games in GameProtocol.swift.`);
assert(swiftGames.length === 60, `Swift has exactly 60 games (found ${swiftGames.length})`);

const swiftFreeCount = swiftGames.filter(g => g.isFree).length;
const swiftProCount = swiftGames.filter(g => !g.isFree).length;
assert(swiftFreeCount === 17, `Swift has exactly 17 Free games (found ${swiftFreeCount})`);
assert(swiftProCount === 43, `Swift has exactly 43 Pro games (found ${swiftProCount})`);

// 3. Extract JS CATALOG items
// Match CATALOG items in app.js
const jsCatalogMatch = jsCode.match(/const CATALOG = \[([\s\S]*?)\];/);
assert(Boolean(jsCatalogMatch), 'CATALOG array found in app.js');

const jsItemsRaw = jsCatalogMatch ? jsCatalogMatch[1] : '';
const jsGameMatches = [...jsItemsRaw.matchAll(/id:\s*'([^']+)',\s*icon:\s*'([^']+)',[\s\S]*?isFree:\s*(true|false),\s*categoryKey:\s*'cat_([a-zA-Z]+)'/g)];

const jsGames = jsGameMatches.map(m => ({
  id: m[1],
  icon: m[2],
  isFree: m[3] === 'true',
  category: m[4] // cards, crown, reflex, puzzle
}));

console.log(`Found ${jsGames.length} games in app.js CATALOG.`);
assert(jsGames.length === 60, `app.js CATALOG has exactly 60 games (found ${jsGames.length})`);

const jsFreeCount = jsGames.filter(g => g.isFree).length;
const jsProCount = jsGames.filter(g => !g.isFree).length;
assert(jsFreeCount === 17, `app.js has exactly 17 Free games (found ${jsFreeCount})`);
assert(jsProCount === 43, `app.js has exactly 43 Pro games (found ${jsProCount})`);

// 4. Parity checks per game
console.log('\nChecking 1-to-1 game parity between Swift and JavaScript:');
const categoryMap = {
  cards: 'cards',
  crown: 'crown',
  reflex: 'reflex',
  puzzle: 'puzzle'
};

swiftGames.forEach(sg => {
  const jg = jsGames.find(j => j.id === sg.id);
  assert(Boolean(jg), `Game "${sg.id}" exists in app.js`);
  if (jg) {
    assert(jg.isFree === sg.isFree, `Game "${sg.id}" isFree parity (Swift: ${sg.isFree}, JS: ${jg.isFree})`);
    assert(categoryMap[sg.category] === jg.category, `Game "${sg.id}" category parity (Swift: ${sg.category}, JS: ${jg.category})`);
  }
});

// 5. Check game class instantiations in renderGame
console.log('\nChecking engine class mapping in app.js renderGame:');
swiftGames.forEach(sg => {
  const hasCase = jsCode.includes(`case '${sg.id}':`);
  assert(hasCase, `renderGame handles case '${sg.id}'`);
});

// 6. Check Swift LocalizationManager for all 46 game titles (EN & TR)
console.log('\nChecking LocalizationManager.swift coverage:');
const enLocSection = locCode.split('"tr": [')[0];
const trLocSection = locCode.split('"tr": [')[1] || '';
swiftGames.forEach(sg => {
  const enTitleDefined = enLocSection.includes(`"title_${sg.id}":`);
  const trTitleDefined = trLocSection.includes(`"title_${sg.id}":`);
  assert(enTitleDefined, `Localization EN has title_${sg.id}`);
  assert(trTitleDefined, `Localization TR has title_${sg.id}`);
});

// 7. Check ScoreManager.allGameIds
console.log('\nChecking ScoreManager.swift allGameIds:');
swiftGames.forEach(sg => {
  const inScoreList = scoreCode.includes(`"${sg.id}"`);
  assert(inScoreList, `ScoreManager.allGameIds includes "${sg.id}"`);
});

// 8. Check ContentView destinationView mapping
console.log('\nChecking ContentView.swift destinationView mapping:');
swiftGames.forEach(sg => {
  const inContentView = contentViewCode.includes(`case "${sg.id}":`);
  assert(inContentView, `ContentView destinationView handles case "${sg.id}"`);
});

// 9. Check server execution
console.log('\nTesting server.js endpoint:');
const server = require('../server.js');

setTimeout(() => {
  http.get('http://localhost:3000/index.html', (res) => {
    assert(res.statusCode === 200, `HTTP Server responds 200 OK (got ${res.statusCode})`);
    
    let data = '';
    res.on('data', chunk => { data += chunk; });
    res.on('end', () => {
      assert(data.includes('60 Games Diamond Edition'), 'index.html contains 60 Games Diamond Edition');
      
      console.log('\n===================================================');
      console.log(`  Tests Passed: ${passedTests} / ${totalTests}`);
      if (passedTests === totalTests) {
        console.log('  STATUS: ALL PARITY CHECKS PASSED PERFECTLY! 🚀');
      } else {
        console.log('  STATUS: SOME CHECKS FAILED!');
      }
      console.log('===================================================\n');
      process.exit(passedTests === totalTests ? 0 : 1);
    });
  }).on('error', (err) => {
    assert(false, `HTTP request failed: ${err.message}`);
    process.exit(1);
  });
}, 500);
