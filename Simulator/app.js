// WristArcade Apple Watch Interactive Web Simulator (Ultimate 20 Games Mega Edition)
// Full parity with watchOS Swift / SwiftUI / StoreKit 2 logic

class AudioHapticsSimulator {
  constructor() {
    this.ctx = null;
    this.enabled = true;
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) this.ctx = new AudioCtx();
    }
  }

  playTick(freq = 600) {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(120, this.ctx.currentTime + 0.04);
    gain.gain.setValueAtTime(0.2, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.04);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(this.ctx.currentTime + 0.04);
  }

  playTone(freq, duration = 0.1, type = 'sine') {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(freq, this.ctx.currentTime);
    gain.gain.setValueAtTime(0.25, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(this.ctx.currentTime + duration);
  }

  playScore() { this.playTone(880, 0.12); }
  playBounce() { this.playTone(320, 0.06, 'triangle'); }
  playVictory() {
    this.playTone(523.25, 0.1);
    setTimeout(() => this.playTone(659.25, 0.1), 100);
    setTimeout(() => this.playTone(783.99, 0.1), 200);
    setTimeout(() => this.playTone(1046.50, 0.25), 300);
  }
  playGameOver() {
    this.playTone(300, 0.15, 'sawtooth');
    setTimeout(() => this.playTone(180, 0.3, 'sawtooth'), 150);
  }
  playLaser() {
    this.playTone(860, 0.07, 'sawtooth');
  }
  playChord(step = 0) {
    const freqs = [330, 392, 493, 587, 659, 784, 880, 987, 1046, 1175];
    const f = freqs[step % freqs.length];
    this.playTone(f, 0.12, 'sine');
  }
  playDiceRoll() {
    this.playTone(180, 0.04, 'triangle');
    setTimeout(() => this.playTone(220, 0.04, 'triangle'), 50);
    setTimeout(() => this.playTone(280, 0.05, 'triangle'), 100);
  }
  playCoin() {
    this.playTone(987.77, 0.08, 'sine');
    setTimeout(() => this.playTone(1318.51, 0.15, 'sine'), 70);
  }
  playSplash() {
    this.playTone(220, 0.12, 'triangle');
    setTimeout(() => this.playTone(340, 0.1, 'sine'), 60);
  }
  playTurbo() {
    this.playTone(140, 0.25, 'sawtooth');
    setTimeout(() => this.playTone(240, 0.3, 'sawtooth'), 100);
  }
  playArrowThud() {
    this.playTone(280, 0.06, 'triangle');
    setTimeout(() => this.playTone(110, 0.12, 'sawtooth'), 40);
  }
  playCardDeal() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(360, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(750, this.ctx.currentTime + 0.04);
    gain.gain.setValueAtTime(0.28, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.05);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(this.ctx.currentTime + 0.05);
  }
}

const audio = new AudioHapticsSimulator();

// Confetti Particle Explosion Engine
class ConfettiEngine {
  constructor(canvasId = 'confettiCanvas') {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas ? this.canvas.getContext('2d') : null;
    this.particles = [];
    this.animId = null;
  }

  trigger(count = 50) {
    if (!this.canvas) this.canvas = document.getElementById('confettiCanvas');
    if (!this.canvas) return;
    this.ctx = this.canvas.getContext('2d');
    if (!this.ctx) return;

    this.canvas.width = this.canvas.parentElement.clientWidth || 210;
    this.canvas.height = this.canvas.parentElement.clientHeight || 260;

    const colors = ['#f59e0b', '#ef4444', '#10b981', '#3b82f6', '#8b5cf6', '#ec4899', '#facc15'];
    this.particles = [];

    for (let i = 0; i < count; i++) {
      this.particles.push({
        x: this.canvas.width * 0.5 + (Math.random() * 40 - 20),
        y: this.canvas.height * 0.35,
        vx: (Math.random() - 0.5) * 8,
        vy: -Math.random() * 6 - 2,
        size: Math.random() * 5 + 3,
        color: colors[Math.floor(Math.random() * colors.length)],
        rotation: Math.random() * 360,
        vr: (Math.random() - 0.5) * 14,
        life: 1.0,
        decay: 0.012 + Math.random() * 0.012
      });
    }

    if (this.animId) cancelAnimationFrame(this.animId);
    this.render();
  }

  render() {
    if (!this.ctx) return;
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.22; // gravity
      p.rotation += p.vr;
      p.life -= p.decay;

      if (p.life <= 0) {
        this.particles.splice(i, 1);
        continue;
      }

      this.ctx.save();
      this.ctx.translate(p.x, p.y);
      this.ctx.rotate((p.rotation * Math.PI) / 180);
      this.ctx.globalAlpha = p.life;
      this.ctx.fillStyle = p.color;
      this.ctx.fillRect(-p.size / 2, -p.size / 3, p.size, p.size * 0.6);
      this.ctx.restore();
    }

    if (this.particles.length > 0) {
      this.animId = requestAnimationFrame(() => this.render());
    } else {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    }
  }
}

const confetti = new ConfettiEngine();

// State Storage
const Storage = {
  getHighScore(gameId) {
    return parseInt(localStorage.getItem(`high_score_${gameId}`) || '0', 10);
  },
  getStreak() {
    return parseInt(localStorage.getItem('wristarcade_streak') || '0', 10);
  },
  getTodayDateStr() {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  },
  getYesterdayDateStr() {
    const d = new Date();
    d.setDate(d.getDate() - 1);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  },
  isChallengeCompleted() {
    return localStorage.getItem('wristarcade_challenge_completed_day') === this.getTodayDateStr();
  },
  getDailyChallenge() {
    const now = new Date();
    const startOfYear = new Date(now.getFullYear(), 0, 0);
    const diff = now - startOfYear;
    const oneDay = 1000 * 60 * 60 * 24;
    const dayOfYear = Math.floor(diff / oneDay);
    const seed = dayOfYear + now.getFullYear() * 365;

    const tasks = [
      { gameId: 'blackjack', target: 3, title: { en: 'Blackjack Master', tr: 'Blackjack Ustası' }, desc: { en: 'Win 3 hands of Classic 21', tr: "Classic 21'de 3 el kazan" } },
      { gameId: 'speednumbers', target: 4000, title: { en: 'Lightning Schulte', tr: 'Şimşek Sıralama' }, desc: { en: 'Clear 1-9 in under 4.0 seconds', tr: '1-9 sayılarını 4.0 saniye altında bitir' } },
      { gameId: 'deepreel', target: 40, title: { en: 'Deep Sea Trophy', tr: 'Derin Deniz Trofesi' }, desc: { en: 'Catch a fish over 40kg', tr: '40kg üzerinde trofe balık yakala' } },
      { gameId: 'highwayracer', target: 120, title: { en: 'Highway Drift', tr: 'Otoyol Kaçışı' }, desc: { en: 'Drive 120m without crashing', tr: 'Kaza yapmadan 120m yol kat et' } },
      { gameId: 'towerstack', target: 10, title: { en: 'Skyline Architect', tr: 'Gökdelen Mimarı' }, desc: { en: 'Stack 10 continuous neon floors', tr: 'Üst üste 10 kat neon blok çık' } },
      { gameId: 'luckyroulette', target: 50, title: { en: 'Roulette Rush', tr: 'Rulet Şansı' }, desc: { en: 'Win $50 or more in Lucky Roulette', tr: "Lucky Roulette'te $50 veya üzeri kazan" } },
      { gameId: 'bullseyearchery', target: 35, title: { en: 'Robin Hood', tr: 'Hedef Avcısı' }, desc: { en: 'Score 35+ points across 5 arrows', tr: '5 okta 35 ve üzeri puan topla' } },
      { gameId: 'paddle', target: 25, title: { en: 'Paddle Rally', tr: 'Duvar Tenisi Ustası' }, desc: { en: 'Rally ball 25 times in Crown Paddle', tr: "Crown Paddle'da topu 25 kez sektir" } },
      { gameId: 'snake', target: 15, title: { en: 'Crown Nibbler', tr: 'Kral Yılan' }, desc: { en: 'Eat 15 food dots in Crown Snake', tr: "Crown Snake'te 15 yem topla" } },
      { gameId: 'mathblitz', target: 10, title: { en: 'Mental Math Prodigy', tr: 'Zihin Matı Dahisi' }, desc: { en: 'Answer 10 equations correctly', tr: "Hızlı Matematik'te 10 işlemi doğru bil" } },
      { gameId: 'memorymatrix', target: 4, title: { en: 'Chimp Memory Elite', tr: 'Maymun Hafızası' }, desc: { en: 'Reach level 4 in Memory Matrix', tr: 'Hafıza Matrisinde Seviye 4e ulaş' } },
      { gameId: 'merge2048', target: 512, title: { en: 'Tile Fusion', tr: 'Blok Birleştirici' }, desc: { en: 'Merge tiles to create 512 or higher', tr: "2048'de 512 taşı veya daha büyüğünü yap" } }
    ];

    const item = tasks[seed % tasks.length];
    return {
      ...item,
      isCompleted: this.isChallengeCompleted()
    };
  },
  completeChallenge() {
    if (this.isChallengeCompleted()) return false;
    const today = this.getTodayDateStr();
    const lastDay = localStorage.getItem('wristarcade_challenge_completed_day');
    let streak = this.getStreak();

    if (lastDay === this.getYesterdayDateStr()) {
      streak += 1;
    } else if (lastDay !== today) {
      streak = 1;
    }

    localStorage.setItem('wristarcade_streak', streak);
    localStorage.setItem('wristarcade_challenge_completed_day', today);
    this.addXP(250, 'Daily Quest Complete');
    audio.playVictory();
    confetti.trigger(60);
    return true;
  },

  // XP & Level Progression
  getXP() {
    return parseInt(localStorage.getItem('wristarcade_total_xp') || '0', 10);
  },
  xpRequired(level) {
    if (level <= 1) return 0;
    return 60 * level * (level - 1);
  },
  getLevel(xp = this.getXP()) {
    for (let lvl = 50; lvl >= 1; lvl--) {
      if (xp >= this.xpRequired(lvl)) return lvl;
    }
    return 1;
  },
  getRanks() {
    return [
      { minLevel: 1, title: { en: 'Novice Wrist', tr: 'Acemi Oyuncu' }, badge: '🎮' },
      { minLevel: 5, title: { en: 'Crown Cadet', tr: 'Kurma Çırağı' }, badge: '⚙️' },
      { minLevel: 10, title: { en: 'Arcade Veteran', tr: 'Salon Koşucusu' }, badge: '🕹️' },
      { minLevel: 20, title: { en: 'High Roller', tr: 'Usta Kumarbaz' }, badge: '🃏' },
      { minLevel: 30, title: { en: 'Reflex Ninja', tr: 'Şimşek Refleks' }, badge: '⚡' },
      { minLevel: 40, title: { en: 'Grandmaster', tr: 'Büyük Usta' }, badge: '👑' },
      { minLevel: 50, title: { en: 'Arcade Legend', tr: 'Bilek Efsanesi' }, badge: '🌟' }
    ];
  },
  getRank(level = this.getLevel()) {
    const ranks = this.getRanks();
    let current = ranks[0];
    for (const r of ranks) {
      if (level >= r.minLevel) current = r;
    }
    return current;
  },
  getProgressToNextLevel(xp = this.getXP()) {
    const lvl = this.getLevel(xp);
    if (lvl >= 50) return 1.0;
    const base = this.xpRequired(lvl);
    const next = this.xpRequired(lvl + 1);
    const diff = next - base;
    if (diff <= 0) return 1.0;
    return Math.min(Math.max((xp - base) / diff, 0), 1.0);
  },
  addXP(amount, reason = '') {
    if (amount <= 0) return false;
    const oldXP = this.getXP();
    const oldLevel = this.getLevel(oldXP);
    const newXP = oldXP + amount;
    localStorage.setItem('wristarcade_total_xp', newXP);
    const newLevel = this.getLevel(newXP);

    if (newLevel > oldLevel) {
      if (window.wristArcade) {
        window.wristArcade.showLevelUpToast(newLevel, this.getRank(newLevel));
      }
      return true;
    }
    return false;
  },

  // 7-Day Activity Tracking
  recordActivityToday() {
    const today = this.getTodayDateStr();
    const key = `daily_activity_${today}`;
    const count = parseInt(localStorage.getItem(key) || '0', 10) + 1;
    localStorage.setItem(key, count);
  },
  getActivity7Days() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const results = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const str = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
      const count = parseInt(localStorage.getItem(`daily_activity_${str}`) || '0', 10);
      const label = days[d.getDay()];
      results.push({ date: str, label, count });
    }
    return results;
  },

  // Themes
  getTheme() {
    return localStorage.getItem('wristarcade_soft_theme') || 'classic';
  },
  setTheme(theme) {
    localStorage.setItem('wristarcade_soft_theme', theme);
    document.body.className = `theme-${theme}`;
  },

  recordScore(gameId, score) {
    const current = this.getHighScore(gameId);
    this.recordActivityToday();
    this.addXP(20, `Played ${gameId}`);
    
    // Evaluate Daily Challenge
    const challenge = this.getDailyChallenge();
    if (!challenge.isCompleted && challenge.gameId === gameId) {
      if (gameId === 'speednumbers' || gameId === 'reflextap') {
        if (score > 0 && score <= challenge.target) {
          this.completeChallenge();
        }
      } else {
        if (score >= challenge.target) {
          this.completeChallenge();
        }
      }
    }

    if (gameId === 'reflextap' || gameId === 'cardpairs' || gameId === 'speednumbers' || gameId === 'numberslide') {
      if (current === 0 || score < current) {
        localStorage.setItem(`high_score_${gameId}`, score);
        this.addXP(100, 'New High Score');
        confetti.trigger(30);
        return true;
      }
      return false;
    }
    if (score > current) {
      localStorage.setItem(`high_score_${gameId}`, score);
      this.addXP(100, 'New High Score');
      confetti.trigger(30);
      return true;
    }
    return false;
  },
  isPro() {
    return localStorage.getItem('wristarcade_is_pro') === 'true';
  },
  setPro(val) {
    localStorage.setItem('wristarcade_is_pro', val ? 'true' : 'false');
  },
  getLang() {
    return localStorage.getItem('wristarcade_lang') || (navigator.language.startsWith('tr') ? 'tr' : 'en');
  },
  setLang(lang) {
    localStorage.setItem('wristarcade_lang', lang);
  },
  getTrophies() {
    try {
      return JSON.parse(localStorage.getItem('wristarcade_trophies') || '[]');
    } catch (e) {
      return [];
    }
  },
  unlockTrophy(id) {
    const trophies = this.getTrophies();
    if (!trophies.includes(id)) {
      trophies.push(id);
      localStorage.setItem('wristarcade_trophies', JSON.stringify(trophies));
      this.addXP(150, 'Achievement Unlocked');
      audio.playVictory();
      return true;
    }
    return false;
  },
  getDailyFreeProGameId() {
    const proIds = [
      'videopoker', 'microsolitaire', 'cardwar', 'cardpairs', 'highlow', 'luckydice', 'luckyroulette', 'baccarat', 'triplepoker',
      'safecracker', 'crownrunner', 'spaceevade', 'brickcrusher', 'galaxydefender', 'deepreel', 'crownmaze', 'subdive', 'lunarlander',
      'reflextap', 'whackmole', 'colormemory', 'mathblitz', 'quickdraw',
      'numberslide', 'wordguess', 'blockfall', 'mines', 'tictactoe', 'memorymatrix', 'bullseyearchery', 'pipeconnect', 'lasermirror',
      'klondikesolitaire', 'chess', 'checkers', 'slidingblocks', 'minisudoku', 'ninemensmorris', 'seabattle', 'reversi',
      'bombdefusal', 'target24', 'tabletennis', 'duel21'
    ];
    const now = new Date();
    const start = new Date(now.getFullYear(), 0, 0);
    const diff = now - start;
    const dayOfYear = Math.floor(diff / (1000 * 60 * 60 * 24));
    return proIds[dayOfYear % proIds.length];
  },
  isGameUnlocked(game) {
    if (!game.isPro) return true;
    if (this.isPro()) return true;
    if (game.id === this.getDailyFreeProGameId()) return true;
    return false;
  },
  resetAll() {
    const games = [
      'blackjack', 'videopoker', 'microsolitaire', 'cardwar', 'cardpairs', 'highlow', 'luckydice', 'luckyroulette', 'baccarat', 'triplepoker',
      'paddle', 'snake', 'safecracker', 'crownrunner', 'spaceevade', 'brickcrusher', 'galaxydefender', 'deepreel', 'crownmaze', 'subdive',
      'speednumbers', 'wingflap', 'reflextap', 'whackmole', 'colormemory', 'mathblitz', 'towerstack', 'highwayracer', 'neonbeat', 'quickdraw',
      'merge2048', 'numberslide', 'wordguess', 'blockfall', 'mines', 'tictactoe', 'memorymatrix', 'bullseyearchery', 'pipeconnect', 'lasermirror',
      'pisti', 'klondikesolitaire', 'mazemuncher', 'chess', 'checkers', 'slidingblocks',
      'airhockey', 'hangman', 'minisudoku', 'lunarlander', 'ninemensmorris',
      'seabattle', 'reversi', 'word5', 'darts',
      'microcircuit', 'bombdefusal', 'target24', 'tabletennis', 'duel21'
    ];
    games.forEach(g => localStorage.removeItem(`high_score_${g}`));
    localStorage.removeItem('wristarcade_total_xp');
  }
};

// Multi-Language Localization Engine (English & Turkish)
const I18N = {
  en: {
    app_title: "WristArcade",
    unlock_banner_title: "UNLOCK ALL 60 GAMES",
    unlock_banner_subtitle: "Poker • Dice • Crown • Chess • No Ads",
    filter_all: "All",
    cat_cards: "Card Games",
    cat_crown: "Crown Arcades",
    cat_reflex: "Speed & Reflex",
    cat_puzzle: "Puzzle & Strategy",
    search_placeholder: "Search 60 games...",
    trophies: "Trophies & Badges",
    best: "Best",
    score: "Score",
    moves: "Moves",
    time: "Time",
    how_to_play: "How to Play",
    objective: "Objective",
    controls: "Controls",
    pro_tips: "Pro Tips",
    got_it: "Got it!",
    settings: "Settings",
    language: "Language",
    preferences: "Preferences",
    haptics: "Haptic Feedback",
    sound: "Sound Effects",
    data_stats: "Data & Stats",
    reset_scores: "Reset High Scores",
    pro_activated: "PRO ACTIVATED",
    restore_purchases: "Restore Purchases",
    paywall_title: "WRIST ARCADE PRO",
    paywall_desc: "Unlock all 60 arcade & card games forever with a single purchase.",
    paywall_feat1: "43 Pro Games Unlocked (Battleship, Reversi, Bomb Defusal, etc.)",
    paywall_feat2: "Digital Crown & Haptic Dial Feedback",
    paywall_feat3: "Offline Play, Zero Ads, Lifetime Access",
    paywall_buy: "$2.99 • UNLOCK ALL 60",
    back: "‹ Back",
    start: "START",
    tap_to_play: "TAP TO PLAY",
    game_over: "GAME OVER",
    you_win: "YOU WIN!",
    next: "Next",
    streak: "Streak",
    daily_free_tag: "FREE TODAY"
  },
  tr: {
    app_title: "WristArcade",
    unlock_banner_title: "TÜM 60 OYUNUN KİLİDİNİ AÇ",
    unlock_banner_subtitle: "Poker • Zarlar • Crown • Satranç • Reklamsız",
    filter_all: "Tümü",
    cat_cards: "Kart Oyunları",
    cat_crown: "Crown Klasikleri",
    cat_reflex: "Hız & Refleks",
    cat_puzzle: "Zeka & Strateji",
    search_placeholder: "60 oyunda ara...",
    trophies: "Kupalar & Rozetler",
    best: "Rekor",
    score: "Skor",
    moves: "Hamle",
    time: "Süre",
    how_to_play: "Nasıl Oynanır?",
    objective: "Amaç",
    controls: "Kontroller",
    pro_tips: "Püf Noktası",
    got_it: "Anladım!",
    settings: "Ayarlar",
    language: "Dil (Language)",
    preferences: "Tercihler",
    haptics: "Titreşim (Haptic)",
    sound: "Ses Efektleri",
    data_stats: "Veriler & İstatistikler",
    reset_scores: "Rekorları Sıfırla",
    pro_activated: "PRO AKTİF",
    restore_purchases: "Satın Alımları Geri Yükle",
    paywall_title: "WRIST ARCADE PRO",
    paywall_desc: "Tek bir satın alımla 60 oyunluk devasa koleksiyonun kilidini açın.",
    paywall_feat1: "43 Pro Oyun Açık (Amiral Battı, Reversi, Bomba İmha vb.)",
    paywall_feat2: "Digital Crown & Haptik Kasa Hissi",
    paywall_feat3: "Çevrimdışı Oynanış, Sıfır Reklam, Ömür Boyu",
    paywall_buy: "$2.99 • TÜM 60'I AÇ",
    back: "‹ Geri",
    start: "BAŞLAT",
    tap_to_play: "DOKUN VE BAŞLA",
    game_over: "OYUN BİTTİ",
    you_win: "KAZANDIN!",
    next: "Sıradaki",
    streak: "Seri",
    daily_free_tag: "BUGÜN ÜCRETSİZ"
  }
};

// 40-Game Catalog with Info Content
const CATALOG = [
  // Cards (6)
  {
    id: 'blackjack', icon: '♣️', color: 'var(--accent-teal)', isFree: true, categoryKey: 'cat_cards',
    title: { en: 'Classic 21', tr: 'Classic 21' },
    subtitle: { en: 'Arcade Blackjack', tr: 'Arcade Blackjack' },
    obj: { en: 'Beat the dealer by getting closer to 21 without busting. Aces count as 1 or 11.', tr: "21'i geçmeden krupiyeden daha yüksek bir el yapın. Aslar 1 veya 11 sayılır." },
    ctrl: { en: 'Tap HIT to draw card, STAND to lock in your score.', tr: 'Kart çekmek için HIT, elinizi sabitlemek için STAND dokunun.' },
    tips: { en: 'Dealers must draw to 16 and stand on 17.', tr: 'Krupiye 17 veya üzerinde durmak zorundadır.' }
  },
  {
    id: 'videopoker', icon: '♦️', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Video Poker', tr: 'Video Poker' },
    subtitle: { en: 'Jacks or Better', tr: 'Jacks or Better' },
    obj: { en: 'Form winning 5-card poker hands. Jacks or Better qualifies for payout!', tr: '5 kartla en iyi eli oluşturun. Vale çifti (Jacks) ve üstü puan kazandırır!' },
    ctrl: { en: 'Tap cards to toggle HOLD, then tap DRAW to replace unheld cards.', tr: 'Kartlara dokunarak TUT (HOLD) yapın, DRAW ile kalanları yenileyin.' },
    tips: { en: 'Always hold four cards to an open-ended straight or flush!', tr: 'Dörtlü açık kent veya renk serilerini asla bozmayın!' }
  },
  {
    id: 'microsolitaire', icon: '♠️', color: 'var(--accent-cyan)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Micro Solitaire', tr: 'Micro Solitaire' },
    subtitle: { en: 'Golf Card Clear', tr: 'Golf Kart Temizleme' },
    obj: { en: 'Clear tableau by tapping cards that are ±1 rank from current waste pile.', tr: 'Açık kartın 1 üstü veya 1 altı (±1) olan kartlara dokunarak masayı temizleyin.' },
    ctrl: { en: 'Tap eligible face-up cards or tap stock pile for a new card.', tr: 'Uygun masa kartına dokunun veya desteden yeni kart açın.' },
    tips: { en: 'Kings wrap to Aces in Golf Solitaire to keep streaks alive!', tr: 'Papazlar ve Aslar birbirine bağlanarak seri devam ettirebilir.' }
  },
  {
    id: 'cardwar', icon: '🛡️', color: 'var(--accent-orange)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Card War', tr: 'Kart Savaşı' },
    subtitle: { en: 'High Card Battle', tr: 'Yüksek Kart Savaşı' },
    obj: { en: 'Draw highest card against dealer! Ties trigger WAR with double points.', tr: 'Krupiyeye karşı en yüksek kartı çekin! Beraberlikte Savaş ve çift puan başlar.' },
    ctrl: { en: 'Tap BATTLE to draw cards against the dealer.', tr: 'Kart çekmek için SAVAŞ butonuna dokunun.' },
    tips: { en: 'Aces are highest (14). Build long streaks for combo points.', tr: 'As en yüksek karttır (14). Seri galibiyetlerle puanı katlayın.' }
  },
  {
    id: 'cardpairs', icon: '🃏', color: 'var(--accent-indigo)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Card Pairs', tr: 'Kart Eşleştirme' },
    subtitle: { en: 'Memory Match', tr: 'Hafıza Kartları' },
    obj: { en: 'Flip and match all 6 card pairs in the 3x4 grid in fewest moves.', tr: '3x4 ızgaradaki 6 kart çiftini en az hamlede bularak açın.' },
    ctrl: { en: 'Tap cards to flip them over two at a time.', tr: 'Kartlara ikişer ikişer dokunarak çevirin.' },
    tips: { en: 'Remember positions of seen cards to solve matches swiftly.', tr: 'Gördüğünüz kartların yerini zihninizde tutun.' }
  },
  {
    id: 'highlow', icon: '♥️', color: 'var(--accent-red)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'High-Low', tr: 'High-Low' },
    subtitle: { en: 'Card Guess Streak', tr: 'Kart Tahmin Serisi' },
    obj: { en: 'Guess if the next drawn card will be Higher or Lower.', tr: 'Bir sonraki kartın mevcut karttan Yüksek mi Düşük mü olacağını bilin.' },
    ctrl: { en: 'Tap HIGHER or LOWER buttons.', tr: 'YÜKSEK veya DÜŞÜK butonlarına dokunun.' },
    tips: { en: 'Cards range 2 to Ace. On a 2 or 3, HIGHER is nearly certain!', tr: 'Kartlar 2 ile As arasındadır. 2 veya 3 çıktığında YÜKSEK kesin gibidir!' }
  },
  {
    id: 'luckydice', icon: '🎲', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Lucky Dice', tr: 'Şanslı Zarlar' },
    subtitle: { en: 'Dice Combos & Duel', tr: 'Zar Kombinasyonları' },
    obj: { en: 'Roll 3 dice, tap dice to HOLD, roll again to score poker triples, straights, or sums!', tr: '3 zar atın, istediklerinizi HOLD yapın, 3lü zar veya kent gibi kombinasyonlar yapın!' },
    ctrl: { en: 'Tap ROLL to shake. Tap dice to toggle HOLD. 2 rolls per round.', tr: 'ROLL ile zar atın. Kilitlemek için zara dokunun.' },
    tips: { en: 'Triples award +100 bonus points! Hold pairs to hunt for the jackpot.', tr: 'Aynı 3 zar +100 bonus verir! Çiftleri tutup üçlüye oynayın.' }
  },
  {
    id: 'luckyroulette', icon: '🎡', color: 'var(--accent-red)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Lucky Roulette', tr: 'Şanslı Rulet' },
    subtitle: { en: 'Spin & Bet Table', tr: 'Çark Çevir & Bahis Yap' },
    obj: { en: 'Place chips on Red, Black, Even, Odd or single numbers. Spin the wheel and win big!', tr: 'Kırmızı, Siyah, Çift, Tek veya sayılara bahis koyun. Çarkı çevirip kazanın!' },
    ctrl: { en: 'Tap bet chip buttons, then tap SPIN. Watch the ball land on the winning slot.', tr: 'Bahis türünü seçin, ÇEVİR butonuna dokunun ve topun düşüşünü izleyin.' },
    tips: { en: 'Red and Black pay 1:1, while a direct single number hit pays a massive 35:1!', tr: 'Kırmızı/Siyah 1:1 verirken, doğrudan tek sayı tahmini tam 35 kat kazandırır!' }
  },
  {
    id: 'baccarat', icon: '🎴', color: 'var(--accent-teal)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Baccarat Mini', tr: 'Baccarat Mini' },
    subtitle: { en: 'Punto Banco Casino', tr: 'Punto Banco Kumarhane' },
    obj: { en: 'Bet on Player, Banker or Tie. Hand closest to 9 wins according to classic casino rules.', tr: 'Oyuncu, Kasa veya Beraberliğe bahis yapın. 9a en yakın el kazanır.' },
    ctrl: { en: 'Select bet target, pick chip size, and tap DEAL to receive cards.', tr: 'Bahis hedefinizi seçin ve KART DAĞIT butonuna dokunun.' },
    tips: { en: 'Banker bet has the best mathematical odds! Ties pay 8 to 1.', tr: 'Kasa bahsi en yüksek kazanma şansına sahiptir! Beraberlik 8 kat verir.' }
  },
  {
    id: 'triplepoker', icon: '🃏', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Three Card Poker', tr: '3 Kart Poker' },
    subtitle: { en: 'Fast-Paced Showdown', tr: 'Hızlı Kart Düellosu' },
    obj: { en: 'Play 3 cards vs Dealer! Form pairs, straights, flushes, or 3-of-a-kind.', tr: 'Dağıtıcıya karşı 3 kartlı poker oynayın! Per veya kent yaparak kazanın.' },
    ctrl: { en: 'Place ANTE, review cards, then tap PLAY or FOLD.', tr: 'ANTE koyun, kartlarınızı inceleyip OYNA veya PAS seçin.' },
    tips: { en: 'Play any hand containing Queen-6-4 or higher; fold anything below.', tr: 'Kız-6-4 veya daha iyi ellerde mutlaka oynayın!' }
  },

  // Crown Arcades (10)
  {
    id: 'paddle', icon: '🏓', color: 'var(--accent-cyan)', isFree: true, categoryKey: 'cat_crown',
    title: { en: 'Crown Paddle', tr: 'Crown Paddle' },
    subtitle: { en: 'Retro Wall Bounce', tr: 'Duvar Tenisi' },
    obj: { en: 'Bounce ball against wall and paddle as speed accelerates.', tr: 'Hızlanan topu raket ve duvarlardan sektirerek puan toplayın.' },
    ctrl: { en: 'Rotate Digital Crown (or mouse wheel) to move paddle horizontally.', tr: 'Raketi sağa/sola kaydırmak için Digital Crown tekerini çevirin.' },
    tips: { en: 'Corner paddle hits deflect ball at sharp angles.', tr: 'Köşe vuruşları sert açılar yaratır, merkeze odaklanın.' }
  },
  {
    id: 'snake', icon: '🐍', color: 'var(--accent-green)', isFree: true, categoryKey: 'cat_crown',
    title: { en: 'Crown Snake', tr: 'Crown Snake' },
    subtitle: { en: 'Classic Nibbler', tr: 'Klasik Yılan' },
    obj: { en: 'Eat dots to grow without crashing into walls or your tail.', tr: 'Duvarlara ve kuyruğunuza çarpmadan yemleri yiyip uzayın.' },
    ctrl: { en: 'Turn Crown or swipe screen to steer snake.', tr: 'Dönüş için Crown tekerini çevirin veya ekranda kaydırın.' },
    tips: { en: 'Hug outer walls to preserve open space in center.', tr: 'Merkezi boş bırakmak için duvar kenarlarından dönün.' }
  },
  {
    id: 'safecracker', icon: '🔐', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Safe Cracker', tr: 'Kasa Hırsızı' },
    subtitle: { en: 'Crown Haptic Dial', tr: 'Crown Haptik Kilit' },
    obj: { en: 'Crack 3-digit safe combination using dial audio/haptic clicks.', tr: 'Tık seslerini ve titreşimleri dinleyerek 3 haneli kasa şifresini çözün.' },
    ctrl: { en: 'Rotate Digital Crown slowly until click intensifies.', tr: 'Tık sesleri hızlanana kadar Digital Crown tekerini yavaşça çevirin.' },
    tips: { en: 'Click rate accelerates within ±3 digits of target.', tr: 'Hedef rakama 3 hane kala tık sesleri sıklaşır.' }
  },
  {
    id: 'crownrunner', icon: '🏃', color: 'var(--accent-orange)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Crown Runner', tr: 'Crown Runner' },
    subtitle: { en: 'Infinite Hop', tr: 'Sonsuz Zıplama' },
    obj: { en: 'Run endlessly, jump over spikes, and collect coins.', tr: 'Sonsuz koşuda tuzakların üzerinden zıplayarak altın toplayın.' },
    ctrl: { en: 'Flick Crown upward or tap screen to jump.', tr: 'Zıplamak için Crown tekerini yukarı çevirin veya ekrana dokunun.' },
    tips: { en: 'Jump at the last second to avoid landing on double traps.', tr: 'Çift engellerin üzerine düşmemek için en son anda zıplayın.' }
  },
  {
    id: 'spaceevade', icon: '🚀', color: 'var(--accent-mint)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Space Evade', tr: 'Uzay Kaçışı' },
    subtitle: { en: 'Star Dodger', tr: 'Yıldız Toplayıcı' },
    obj: { en: 'Pilot ship through asteroid storm and collect yellow stars.', tr: 'Asteroitlerden kaçarak altın enerji yıldızlarını toplayın.' },
    ctrl: { en: 'Rotate Digital Crown to steer ship left and right.', tr: 'Uzay gemisini yönlendirmek için Digital Crown çevirin.' },
    tips: { en: 'Gentle micro-turns prevent slamming into sudden meteors.', tr: 'Küçük ve yumuşak dönüşlerle ani beliren meteorlardan kaçının.' }
  },
  {
    id: 'brickcrusher', icon: '🧱', color: 'var(--accent-pink)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Brick Crusher', tr: 'Tuğla Kırma' },
    subtitle: { en: 'Smash Blocks', tr: 'Renkli Tuğlalar' },
    obj: { en: 'Smash all colored bricks with the bouncing ball.', tr: 'Seken topla yukarıdaki tüm renkli tuğlaları patlatın.' },
    ctrl: { en: 'Rotate Crown to position paddle underneath ball.', tr: 'Raketi topun altına getirmek için Crown tekerini çevirin.' },
    tips: { en: 'Punch a hole through to let ball bounce on top ceiling!', tr: 'Tuğlaların üstüne delik açarak topun tavanda sekmesini sağlayın!' }
  },
  {
    id: 'galaxydefender', icon: '🚀', color: 'var(--accent-mint)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Galaxy Defender', tr: 'Galaksi Savunması' },
    subtitle: { en: 'Crown Plasma Defense', tr: 'Crown Uzay Tareti' },
    obj: { en: 'Defend Earth from invading alien fleets! Steer laser turret with Crown and tap to fire.', tr: 'Dünyayı uzaylı istilasından koruyun! Crown ile taretinizi sürüp ateş edin.' },
    ctrl: { en: 'Rotate Digital Crown to steer horizontally. Tap screen anywhere to shoot.', tr: 'Tareti kaydırmak için Crown çevirin. Ateş etmek için ekrana dokunun.' },
    tips: { en: 'Shoot the red bonus UFO mothership for an instant 200 points!', tr: 'Kırmızı UFO ana gemisini vurmak anında 200 ekstra puan verir!' }
  },
  {
    id: 'deepreel', icon: '🎣', color: 'var(--accent-blue)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Deep Sea Reel', tr: 'Derin Olta' },
    subtitle: { en: 'Crown Trophy Fishing', tr: 'Crown Trofe Balıkçılık' },
    obj: { en: 'Cast line, detect fish bite haptic, and rotate Crown to reel in heavy prize fish.', tr: 'Oltayı atın, vuruşu hissedin ve Crown ile trofe balıkları kıyıya çekin.' },
    ctrl: { en: 'Tap CAST to drop line. When BITE flashes, rotate Crown smoothly within the green tension zone.', tr: 'OLTA AT dokunun. VURUŞ uyarısında Crown çevirin ve gerilimi yeşil alanda tutun.' },
    tips: { en: 'Reeling too fast snaps the line, while reeling too slow lets the fish break free!', tr: 'Çok hızlı çekmek misinayı koparır, yavaş çekmek balığı kaçırır! Dengeli sarın.' }
  },
  {
    id: 'crownmaze', icon: '🌀', color: 'var(--accent-cyan)', isFree: true, categoryKey: 'cat_crown',
    title: { en: 'Crown Maze', tr: 'Crown Labirenti' },
    subtitle: { en: 'Concentric Labyrinth', tr: 'İç İçe Halka Labirenti' },
    obj: { en: 'Rotate Crown to spin concentric rings and guide the marble into the center goal.', tr: 'Crown ile dairesel halkaları çevirin ve bilyeyi merkez hedefine düşürün.' },
    ctrl: { en: 'Rotate Crown to align gate slots. Marble drops automatically into inner rings.', tr: 'Boşlukları hizalamak için Crown tekerini çevirin.' },
    tips: { en: 'Inner rings spin with greater sensitivity. Turn gently!', tr: 'İç halkalar daha hassastır. Sakin ve yavaş çevirin!' }
  },
  {
    id: 'subdive', icon: '🌊', color: 'var(--accent-blue)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Submarine Dive', tr: 'Denizaltı Dalışı' },
    subtitle: { en: 'Deep Trench Explorer', tr: 'Derin Deniz Kaşifi' },
    obj: { en: 'Pilot submarine through abyssal trenches! Adjust depth with Crown to dodge mines and grab oxygen.', tr: 'Denizaltıyla mayınlardan kaçın ve oksijen baloncuklarını toplayın.' },
    ctrl: { en: 'Rotate Crown to raise or lower submarine depth.', tr: 'Derinliği artırıp azaltmak için Crown tekerini çevirin.' },
    tips: { en: 'Oxygen depletes continuously. Prioritize oxygen bubbles over distance!', tr: 'Oksijen hızla biter. Mayınlardan kaçarken baloncukları kaçırmayın!' }
  },

  // Speed & Reflex (10)
  {
    id: 'speednumbers', icon: '🔢', color: 'var(--accent-cyan)', isFree: true, categoryKey: 'cat_reflex',
    title: { en: 'Speed Tap 1-9', tr: 'Hızlı 1-9' },
    subtitle: { en: 'Schulte Number Rush', tr: 'Karma Tablo Sıralama' },
    obj: { en: 'Tap numbers 1 to 9 in strict ascending order as fast as possible!', tr: 'Karma tablodaki 1-9 sayılarına sırayla en hızlı şekilde dokunun!' },
    ctrl: { en: 'Tap 1, then 2, 3... up to 9. Wrong taps add time penalty.', tr: '1, 2, 3... 9 sırasıyla dokunun. Yanlış dokunuş ceza süresi ekler.' },
    tips: { en: 'Scan for 2 and 3 with peripheral vision while tapping 1!', tr: "1'e basarken göz ucuyla 2 ve 3'ün yerini tarayın!" }
  },
  {
    id: 'wingflap', icon: '🕊️', color: 'var(--accent-green)', isFree: true, categoryKey: 'cat_reflex',
    title: { en: 'Wing Flap', tr: 'Kanat Çırpma' },
    subtitle: { en: 'Tap to Fly', tr: 'Dokunarak Uç' },
    obj: { en: 'Flap wings to stay aloft and fly through glowing neon pipes.', tr: 'Kanat çırparak neon sütunların arasından güvenle geçin.' },
    ctrl: { en: 'Tap screen anywhere to give your bird upward lift.', tr: 'Kuşu yukarı uçurmak için ekranda herhangi bir yere dokunun.' },
    tips: { en: 'Steady rhythmic taps are better than rapid panicked tapping.', tr: 'Panik basışlar yerine sakin ve ritmik dokunuşlar yapın.' }
  },
  {
    id: 'reflextap', icon: '⚡', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_reflex',
    title: { en: 'Reflex Tap', tr: 'Refleks Testi' },
    subtitle: { en: 'Reaction Test', tr: 'Milisaniye Hız Ölçer' },
    obj: { en: 'Wait during RED state, then tap instantly when screen flashes GREEN.', tr: 'Kırmızıda bekleyin, ekran YEŞİL yandığı milisaniyede dokunun.' },
    ctrl: { en: 'Tap screen the exact moment it turns GREEN.', tr: 'Ekran yeşile döndüğü an tek dokunuş yapın.' },
    tips: { en: 'Tapping early during RED gives a false-start penalty!', tr: 'Kırmızıda erken basarsanız hatalı çıkış cezası alırsınız.' }
  },
  {
    id: 'whackmole', icon: '🎯', color: 'var(--accent-red)', isFree: false, categoryKey: 'cat_reflex',
    title: { en: 'Whack-A-Dot', tr: 'Hedef Dokunmaca' },
    subtitle: { en: 'Pop-up Reflex', tr: 'Anlık Hedef Refleksi' },
    obj: { en: 'Tap red targets in 3x3 grid before they disappear.', tr: '3x3 ızgarada yanan kırmızı hedeflere kaybolmadan önce vurun.' },
    ctrl: { en: 'Tap directly on the illuminated red dot.', tr: 'Yanan kırmızı daireye doğrudan dokunun.' },
    tips: { en: 'Hover your finger closely over center of the screen.', tr: 'Parmağınızı ekranın hemen üstünde hazır tutun.' }
  },
  {
    id: 'colormemory', icon: '✨', color: 'var(--accent-purple)', isFree: false, categoryKey: 'cat_reflex',
    title: { en: 'Color Sequence', tr: 'Renk Sırası' },
    subtitle: { en: 'Simon Reflex', tr: 'Simon Hafıza Ritmi' },
    obj: { en: 'Memorize and repeat the flashing color quadrants in exact sequence.', tr: 'Yanıp sönen renk kadranlarının sırasını aklınızda tutup tekrarlayın.' },
    ctrl: { en: 'Tap Green, Red, Yellow, or Blue quadrants in order.', tr: 'Yeşil, Kırmızı, Sarı ve Mavi kadranlara sırayla dokunun.' },
    tips: { en: 'Number colors in your head (1-4) to remember longer strings.', tr: 'Renkleri zihninizde numaralandırarak uzun serileri kolayca hatırlayın.' }
  },
  {
    id: 'mathblitz', icon: '➕', color: 'var(--accent-blue)', isFree: false, categoryKey: 'cat_reflex',
    title: { en: 'Math Blitz', tr: 'Hızlı Matematik' },
    subtitle: { en: 'Mental Math', tr: '3 Saniyede Zihin Matı' },
    obj: { en: 'Judge if the equation is TRUE or FALSE before 3 seconds expires.', tr: '3 saniye dolmadan işlemin DOĞRU mu YANLIŞ mı olduğunu bilin.' },
    ctrl: { en: 'Tap TRUE (Checkmark) or FALSE (X) buttons.', tr: 'DOĞRU (Tik) veya YANLIŞ (X) butonlarına dokunun.' },
    tips: { en: 'Checking the ones digit often catches false equations instantly.', tr: 'Sonucun birler basamağına bakmak yanlışları anında ele verir.' }
  },
  {
    id: 'towerstack', icon: '🏗️', color: 'var(--accent-cyan)', isFree: true, categoryKey: 'cat_reflex',
    title: { en: 'Tower Stacker', tr: 'Denge Kulesi' },
    subtitle: { en: 'Neon Block Heights', tr: 'Neon Kat Çıkma' },
    obj: { en: 'Stack sliding neon block slabs as high as possible. Overhangs get sliced off!', tr: 'Kayan neon blokları tam üst üste koyarak kat çıkın. Taşan kısımlar kesilir!' },
    ctrl: { en: 'Tap screen to drop slab onto tower. Align perfectly for combo pitch.', tr: 'Bloğu sabitlemek için ekrana dokunun. Mükemmel hizalamada ses perdesi yükselir.' },
    tips: { en: 'Three consecutive perfect drops will expand your platform width!', tr: 'Üst üste 3 mükemmel yerleştirme platformunuzu yeniden genişletir!' }
  },
  {
    id: 'highwayracer', icon: '🏎️', color: 'var(--accent-yellow)', isFree: true, categoryKey: 'cat_reflex',
    title: { en: 'Highway Racer', tr: 'Otoyol Yarışçısı' },
    subtitle: { en: 'Neon Traffic Weave', tr: 'Neon Trafik Kaçışı' },
    obj: { en: 'High-speed 3-lane neon highway traffic dodger! Weave past cars and collect nitro boosts.', tr: '3 şeritli neon otoyolda araçların arasından sıyrılın ve nitroları toplayın.' },
    ctrl: { en: 'Rotate Crown or tap Left/Right sides to change lanes. Tap NITRO for invincibility boost.', tr: 'Şerit değiştirmek için Crown çevirin veya Sol/Sağ dokunun. Turbo için Nitroyu açın.' },
    tips: { en: 'Near-miss passing gives drift score bonuses. Watch for blinking brake lights!', tr: 'Araçların dibinden teğet geçmek bonus puan verir. Fren lambalarına dikkat edin!' }
  },
  {
    id: 'neonbeat', icon: '🎵', color: 'var(--accent-cyan)', isFree: true, categoryKey: 'cat_reflex',
    title: { en: 'Neon Beat', tr: 'Neon Ritim' },
    subtitle: { en: 'Highway Rhythm Tap', tr: 'Otoyol Ritim Dokunuşu' },
    obj: { en: 'Rhythm beat drop! Tap Left or Right lane when falling neon bars hit the target line in perfect sync.', tr: 'Müzikal neon ritim dokunuşu! Kayan notalar hedef çizgisine ulaştığı anda Sol veya Sağ butona basın.' },
    ctrl: { en: 'Tap LEFT or RIGHT button as musical notes cross the lower hit line.', tr: 'Notalar alt çizgiyi kestiği milisaniyede SOL veya SAĞ butonuna dokunun.' },
    tips: { en: 'Maintain uninterrupted streaks to trigger the 2x, 3x, and 4x combo multipliers!', tr: 'Seriyi bozmadan devam ederek 2x, 3x ve 4x kombo puan çarpanlarını aktif tutun!' }
  },
  {
    id: 'quickdraw', icon: '🤠', color: 'var(--accent-orange)', isFree: false, categoryKey: 'cat_reflex',
    title: { en: 'Quick Draw Duel', tr: 'Hızlı Çekim Düello' },
    subtitle: { en: 'Western Outlaw Reflex', tr: 'Vahşi Batı Kovboy Refleksi' },
    obj: { en: 'High noon western duel! Stare down the outlaw, wait for the DRAW! cue, and tap screen in under 350ms.', tr: 'Vahşi batı kovboy düellosu! Hayduta odaklanın, ÇEK! uyarısı geldiğinde 350ms altında dokunun.' },
    ctrl: { en: 'Wait through the tense heartbeat cue, tap immediately when DRAW! flashes on screen.', tr: 'Kalp atışı geriliminde bekleyin, ekranda ÇEK! belirdiği an ekrana vurun.' },
    tips: { en: 'Tapping before the cue results in a false-start penalty! Stay calm and twitch-ready.', tr: 'Uyarıdan önce basarsanız erken ateş cezası alırsınız! Sakin olun ve ani refleksi bekleyin.' }
  },

  // Puzzle & Strategy (8)
  {
    id: 'merge2048', icon: '🔢', color: 'var(--accent-orange)', isFree: true, categoryKey: 'cat_puzzle',
    title: { en: 'Number Merge', tr: 'Sayı Birleştir' },
    subtitle: { en: '2048 Tile Puzzle', tr: '2048 Blok Bulmacası' },
    obj: { en: 'Slide numbered tiles to merge identical pairs and reach 2048!', tr: 'Aynı sayıları birleştirerek 2048 taşına ulaşın!' },
    ctrl: { en: 'Swipe Up, Down, Left, or Right on screen.', tr: 'Ekranda Yukarı, Aşağı, Sola veya Sağa kaydırın.' },
    tips: { en: 'Keep your highest tile in a single corner at all times.', tr: 'En büyük sayınızı her zaman köşelerden birinde sabitleyin.' }
  },
  {
    id: 'numberslide', icon: '🧩', color: 'var(--accent-mint)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Number Slide', tr: 'Rakam Kaydırma' },
    subtitle: { en: '3x3 8-Puzzle', tr: '3x3 8-Puzzle' },
    obj: { en: 'Slide tiles (1 to 8) into the blank slot to arrange them in order.', tr: 'Boşluğu kullanarak 1-8 arası sayıları sıraya dizin.' },
    ctrl: { en: 'Tap any tile adjacent to empty space to slide it.', tr: 'Boşluğun yanındaki komşu taşa dokunarak kaydırın.' },
    tips: { en: 'Solve row by row! Complete row 1 (1, 2, 3) first.', tr: 'Satır satır çözün! Önce ilk satırı (1, 2, 3) sabitleyin.' }
  },
  {
    id: 'wordguess', icon: '🔤', color: 'var(--accent-green)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Word Guess', tr: 'Kelime Tahmini' },
    subtitle: { en: '4-Letter Deduction', tr: '4 Harfli Gizem' },
    obj: { en: 'Deduce hidden 4-letter word within 5 tries using color clues.', tr: '5 denemede renkli ipuçlarıyla 4 harfli gizli kelimeyi bulun.' },
    ctrl: { en: 'Tap keyboard letters, ENTER to submit, DEL to erase.', tr: 'Harflere dokunarak yazın, ENTER ile gönderin, DEL ile silin.' },
    tips: { en: 'Green = right spot; Yellow = in word; Gray = not in word.', tr: 'Yeşil = doğru yer; Sarı = kelimede var; Gri = kelimede yok.' }
  },
  {
    id: 'blockfall', icon: '🧱', color: 'var(--accent-pink)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Color Blocks', tr: 'Renk Blokları' },
    subtitle: { en: 'Falling 3-Match', tr: "Düşen 3'lü Eşleştirme" },
    obj: { en: 'Match 3 or more blocks of the same color horizontally or vertically.', tr: "Aynı renkteki 3 veya daha fazla taşı eşleştirip patlatın." },
    ctrl: { en: 'Rotate Crown to move, tap to cycle colors, swipe down to drop.', tr: 'Crown ile sağa/sola gidin, dokunarak renkleri çevirin, kaydırıp düşürün.' },
    tips: { en: 'Clear lower blocks to create chain reaction cascades.', tr: 'Altları temizleyerek zincirleme kombolar başlatın.' }
  },
  {
    id: 'mines', icon: '🚩', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Mine Grid', tr: 'Mayın Tarlası' },
    subtitle: { en: 'Tactical Sweeper', tr: 'Taktik Mayın Arama' },
    obj: { en: 'Clear all safe squares without triggering hidden mines.', tr: 'Gizli mayınlara basmadan tüm güvenli kareleri açın.' },
    ctrl: { en: 'Tap in DIG mode to clear, switch to FLAG mode to mark danger.', tr: 'KAZ modunda açın, BAYRAK modunda mayınları işaretleyin.' },
    tips: { en: 'Numbers indicate how many mines touch that specific cell.', tr: 'Sayılar o kareye temas eden mayın sayısını gösterir.' }
  },
  {
    id: 'tictactoe', icon: '❌', color: 'var(--accent-teal)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Tic-Tac-Toe', tr: 'Tic-Tac-Toe' },
    subtitle: { en: 'Smart AI & 2-Player', tr: 'Akıllı YZ & 2 Kişilik' },
    obj: { en: 'Place 3 marks in a line to defeat smart AI or pass-and-play friend.', tr: '3 taşınızı düz veya çapraz dizerek yapay zekayı yenin.' },
    ctrl: { en: 'Tap any empty grid square to place your mark.', tr: 'Sembolünüzü koymak için boş kareye dokunun.' },
    tips: { en: 'Claim the center square first for maximum tactical advantage.', tr: 'İlk hamlede merkez kareyi almak büyük avantaj sağlar.' }
  },
  {
    id: 'memorymatrix', icon: '🧠', color: 'var(--accent-indigo)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Memory Matrix', tr: 'Hafıza Matrisi' },
    subtitle: { en: 'Chimp Memory Test', tr: 'Maymun Testi' },
    obj: { en: 'Famous Chimp Test! Memorize numbered tiles before they hide, then tap them in order (1, 2, 3..).', tr: 'Meşhur Maymun Testi! Sayılar kapanmadan ezberleyin, sonra sırayla (1, 2, 3..) açın.' },
    ctrl: { en: 'Memorize tiles during countdown, then tap tiles in strict sequence.', tr: 'Geri sayımda sayıları ezberleyin, ardından sırayla dokunun.' },
    tips: { en: 'Mentally group numbers into geometric shapes to recall up to 8 tiles.', tr: 'Sayıları geometrik şekiller halinde gruplayarak zihninizde tutun.' }
  },
  {
    id: 'bullseyearchery', icon: '🎯', color: 'var(--accent-orange)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Bullseye Archery', tr: 'Hedef Okçuluk' },
    subtitle: { en: 'Wind Physics Target', tr: 'Rüzgar Fiziği Hedefi' },
    obj: { en: 'Master crosswinds and draw tension to shoot precision arrows into the 10-point bullseye!', tr: 'Rüzgar hızını ve yay gerginliğini hesaplayıp okları 10 puanlık merkeze vurun!' },
    ctrl: { en: 'Drag and hold on target to draw bow, adjust for wind drift, release to loose arrow.', tr: 'Yayı germek için basılı tutun, rüzgara göre nişan alın, oku fırlatmak için bırakın.' },
    tips: { en: 'Strong crosswinds push arrows sideways. Aim in the opposite direction of the wind arrow!', tr: 'Rüzgar oku yana savurur. Rüzgar okunun gösterdiği yönün tersine nişan alın!' }
  },
  {
    id: 'pipeconnect', icon: '🔧', color: 'var(--accent-cyan)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Pipe Connect', tr: 'Boru Bağlama' },
    subtitle: { en: 'Flow Rotation Grid', tr: 'Su Akış Izgarası' },
    obj: { en: 'Connect the water flow! Tap pipe tiles on the 3x3 grid to rotate them and create a continuous pipeline.', tr: 'Su akışını bağlayın! 3x3 ızgaradaki boru parçalarına dokunarak döndürün ve kesintisiz hat kurun.' },
    ctrl: { en: 'Tap any pipe tile to rotate it 90 degrees clockwise.', tr: 'Herhangi bir boru parçasına dokunarak saat yönünde 90 derece döndürün.' },
    tips: { en: 'Start connecting backwards from the exit drain to narrow down valid paths!', tr: 'Çıkış vanasından geriye doğru döşemeye başlayarak doğru yolu daha kolay bulun!' }
  },
  {
    id: 'lasermirror', icon: '⚡', color: 'var(--accent-pink)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Laser Mirror', tr: 'Lazer Aynası' },
    subtitle: { en: 'Optic Prism Maze', tr: 'Optik Prizma Labirenti' },
    obj: { en: 'Laser optics puzzle! Tap angled prism mirrors to redirect the red laser beam into the power crystal.', tr: 'Lazer optik bulmacası! Aynalara dokunarak kırmızı lazer ışınını güç kristaline saptırın.' },
    ctrl: { en: 'Tap angled mirrors to toggle their angle 90 degrees.', tr: 'Açılı aynalara dokunarak 90 derece yönlerini değiştirin.' },
    tips: { en: 'Diagonal mirrors deflect light perpendicular to their surface. Trace the beam step by step!', tr: 'Aynalar ışığı tam 90 derece büker. Lazer kaynağını adım adım takip edin!' }
  },
  {
    id: 'pisti', icon: '♠️', color: 'var(--accent-red)', isFree: true, categoryKey: 'cat_cards',
    title: { en: 'Pisti Card Match', tr: 'Pişti' },
    subtitle: { en: 'Classic Turkish Deck', tr: 'Geleneksel Türk Kartı' },
    obj: { en: 'Classic Turkish Pisti! Match the middle card rank or play a Jack to sweep the pile. Score a Pisti (+10) on a single card!', tr: 'Geleneksel Türk Pişti oyunu! Yerdeki kartın aynısını veya Vale atarak yerdeki desteyi toplayın. Tek karta pişti yapın (+10)!' },
    ctrl: { en: 'Tap any card in your hand to play it into the center pile.', tr: 'Elinizdeki kartlara dokunarak ortaya kart atın.' },
    tips: { en: 'Jacks always capture everything on the board. Save your matching cards for isolated table cards!', tr: 'Valeler yerdeki tüm kartları süpürür. Yerde tek kart kaldığında aynı kartı atarak pişti yapın!' }
  },
  {
    id: 'klondikesolitaire', icon: '♦️', color: 'var(--accent-cyan)', isFree: false, categoryKey: 'cat_cards',
    title: { en: 'Klondike Solitaire', tr: 'Klasik Soliter' },
    subtitle: { en: '7-Column Classic', tr: '7 Sütunlu Klondike' },
    obj: { en: 'Classic Klondike Solitaire! Build 4 foundation suits from Ace to King. Sequence tableau columns in alternating colors descending.', tr: 'Klasik Klondike Soliter! As\'tan Papaz\'a 4 ana deste serisini tamamlayın. Masadaki sütunları zıt renklerde azalan dizin.' },
    ctrl: { en: 'Tap waste/tableau cards to auto-move to foundations or valid tableau columns.', tr: 'Kartlara dokunarak uygun yuvaya veya kütüğe otomatik taşıyın.' },
    tips: { en: 'Expose hidden tableau cards as quickly as possible. Empty column spaces can only take Kings!', tr: 'Kapalı kartları mümkün olduğunca hızlı açın. Boş sütunlara yalnızca Papazlar (K) konulabilir!' }
  },
  {
    id: 'mazemuncher', icon: '🟡', color: 'var(--accent-yellow)', isFree: true, categoryKey: 'cat_crown',
    title: { en: 'Maze Muncher', tr: 'Labirent Yemcisi' },
    subtitle: { en: 'Neon Dot Chomp', tr: 'Neon Yem Toplama' },
    obj: { en: 'Neon Maze Chomp! Eat all dots in the labyrinth while dodging colorful ghosts. Grab power gems to turn the hunt on them!', tr: 'Neon Labirent Yemcisi! Renkli hayaletlerden kaçarak labirentteki tüm yemleri yiyin. Güç mücevherini alıp hayaletleri kovalayın!' },
    ctrl: { en: 'Rotate Digital Crown to steer or swipe across the screen in 4 directions.', tr: 'Digital Crown\'ı çevirerek veya ekranda 4 yöne kaydırarak yön verin.' },
    tips: { en: 'Power gems make ghosts vulnerable for a short period. Turn around and chomp them for massive bonus points!', tr: 'Güç mücevherini aldığınızda hayaletler kaçmaya başlar. Onları yiyerek devasa bonus puanlar kazanın!' }
  },
  {
    id: 'chess', icon: '♟️', color: 'var(--accent-orange)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Mini Chess', tr: 'Satranç' },
    subtitle: { en: 'Tactical Board AI', tr: 'Taktik Zeka Hamleleri' },
    obj: { en: 'Watch Tactical Chess! Outsmart the AI chess engine by capturing the opposing King with tactical maneuvers.', tr: 'Akıllı Saat Satrancı! Taktiksel hamlelerle rakip Şah\'ı mat etmek için satranç yapay zekasına karşı hamle yapın.' },
    ctrl: { en: 'Tap your piece to reveal highlighted valid legal moves, then tap destination square to move.', tr: 'Taşınıza dokunun, yeşil hedef kareler açılınca gideceğiniz kareye dokunarak hamle yapın.' },
    tips: { en: 'Control center squares early and guard your King with castling. Watch out for Knight forks!', tr: 'Merkez kareleri erken kontrol edin ve Şahınızı erken güvenceye alın. At çatallarına dikkat edin!' }
  },
  {
    id: 'checkers', icon: '🔴', color: 'var(--accent-teal)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Classic Checkers', tr: 'Klasik Dama' },
    subtitle: { en: 'Jump & Crown Board', tr: 'Çapraz Taş Yeme' },
    obj: { en: 'Classic Checkers / Draughts! Jump diagonally over opposing checkers to capture them and crown your pieces as Kings.', tr: 'Klasik Dama! Rakip taşların üzerinden çapraz atlayarak taşları toplayın ve en arkaya ulaşıp Dama olun.' },
    ctrl: { en: 'Tap a checker piece, then tap an available diagonal target square to advance or jump.', tr: 'Taşınıza dokunun, beliren hedef kareye dokunarak ilerleyin veya rakip taşı yiyin.' },
    tips: { en: 'Reach the farthest back row to crown a King! Kings can move and jump both forwards and backwards.', tr: 'En arka sıraya ulaşan taş Dama olur! Damalar hem ileri hem geri çapraz hareket edebilir ve yiyebilir.' }
  },
  {
    id: 'slidingblocks', icon: '🧱', color: 'var(--accent-purple)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Sliding Blocks', tr: 'Kayıcı Bloklar' },
    subtitle: { en: 'Block Escape Puzzle', tr: 'Blok Kaçış Bulmacası' },
    obj: { en: 'Slide Block Escape! Slide horizontal and vertical wooden blocks to clear a path and guide the golden key block to the exit gate.', tr: 'Kayıcı Blok Kaçışı! Yatay ve dikey blokları kaydırarak yolu açın ve altın anahtar bloğu çıkış kapısından geçirin.' },
    ctrl: { en: 'Tap and drag blocks along their allowed axis (horizontal blocks move left/right, vertical move up/down).', tr: 'Bloklara dokunup sürükleyin (yatay bloklar sağ/sol, dikey bloklar yukarı/aşağı kayar).' },
    tips: { en: 'Work backwards from the exit slot. Clear obstacles blocking the key block\'s direct lane first!', tr: 'Çıkış kapısından geriye doğru düşünün. Anahtar bloğun önündeki dikey engelleri kenara çekin!' }
  },
  {
    id: 'airhockey', icon: '🏒', color: 'var(--accent-cyan)', isFree: true, categoryKey: 'cat_crown',
    title: { en: 'Neon Air Hockey', tr: 'Hava Hokeyi' },
    subtitle: { en: 'Puck & Mallet Duel', tr: 'Neon Disk Düellosu' },
    obj: { en: 'Neon Air Hockey! Slide your paddle with Digital Crown or touch to deflect the speeding puck into the opponent\'s goal.', tr: 'Neon Hava Hokeyi! Digital Crown veya dokunarak raketinizi kaydırın ve hızlı diski rakip kaleye sokun.' },
    ctrl: { en: 'Rotate Crown or drag finger to slide paddle left/right. First to 5 points wins!', tr: 'Crown çevirerek veya parmağınızı sürükleyerek raketi kaydırın. 5 puana ilk ulaşan kazanır!' },
    tips: { en: 'Bank pucks off side walls at sharp angles to slip past the defending bot!', tr: 'Diski yan duvarlara açılı çarptırarak botun savunmasını hazırlıksız yakalayın!' }
  },
  {
    id: 'hangman', icon: '🔤', color: 'var(--accent-green)', isFree: true, categoryKey: 'cat_puzzle',
    title: { en: 'Classic Hangman', tr: 'Adam Asmaca' },
    subtitle: { en: 'Word Deduction', tr: 'Kelime Tahmini' },
    obj: { en: 'Classic Hangman! Guess the hidden word letter by letter before completing 6 mistaken strokes on the neon gallows.', tr: 'Klasik Adam Asmaca! 6 hata hakkınızı tüketmeden gizli kelimeyi harf harf tahmin edin.' },
    ctrl: { en: 'Tap alphabet keyboard buttons to guess letters.', tr: 'Harfleri seçmek için ekrandaki klavye tuşlarına dokunun.' },
    tips: { en: 'Start by guessing common vowels (A, E, I, O) to uncover the word framework quickly!', tr: 'Kelimenin iskeletini hızlıca ortaya çıkarmak için önce sesli harflerle başlayın!' }
  },
  {
    id: 'minisudoku', icon: '🔢', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Mini Sudoku', tr: 'Mini Sudoku' },
    subtitle: { en: '4x4 Number Grid', tr: '4x4 Sayı Bulmacası' },
    obj: { en: 'Mini Sudoku 4x4! Fill the grid so numbers 1 to 4 appear exactly once in each row, column, and 2x2 box.', tr: 'Mini Sudoku 4x4! 1\'den 4\'e kadar sayıları her satır, sütun ve 2x2 kutuda tek birer kez yerleştirin.' },
    ctrl: { en: 'Tap an empty cell, then tap numbers 1 to 4 on the keypad below.', tr: 'Boş hücreye dokunun, ardından aşağıdaki tuş takımından 1-4 arası sayıyı seçin.' },
    tips: { en: 'Look for rows or 2x2 boxes that only have one missing number first!', tr: 'Önce sadece tek bir boşluğu kalan satır veya 2x2 blokları tamamlayın!' }
  },
  {
    id: 'lunarlander', icon: '🚀', color: 'var(--accent-orange)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Lunar Lander', tr: 'Ay Modülü' },
    subtitle: { en: 'Moon Descent Physics', tr: 'Ay İniş Fiziği' },
    obj: { en: 'Lunar Lander! Pilot lunar module through gravity and touch down smoothly on the landing pad before fuel runs out.', tr: 'Ay Modülü İnişi! Yerçekimine karşı itki vererek yakıtınız bitmeden iniş platformuna yumuşak iniş yapın.' },
    ctrl: { en: 'Tap or rotate Crown upwards for thruster burst. Crown downwards/steer left or right.', tr: 'İtki vermek için ekrana dokunun veya Crown çevirin. Yana yönlenmek için sola/sağa kaydırın.' },
    tips: { en: 'Keep descent speed under 1.6 m/s just before touchdown to avoid hard crashes!', tr: 'Sert çarpmamak için yere tam temas anında iniş hızınızı 1.6 m/s altında tutun!' }
  },
  {
    id: 'ninemensmorris', icon: '🏛️', color: 'var(--accent-cyan)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: "Nine Men's Morris", tr: '9 Taş (Dokuz Taş)' },
    subtitle: { en: 'Ancient Tactical Mill', tr: 'Antik Değirmen Oyunu' },
    obj: { en: 'Form 3-in-a-row mills to capture enemy stones and reduce opponent to 2 pieces.', tr: "3'lü değirmen kurarak rakip taşları toplayın ve rakibi 2 taşa düşürün." },
    ctrl: { en: 'Phase 1: Tap empty point to place. Phase 2: Tap your stone then adjacent point to slide. When mill forms, tap enemy stone to capture.', tr: '1. Aşama: Boş noktaya dokunup koyun. 2. Aşama: Taşınızı seçip komşu noktaya kaydırın. Değirmen olunca rakip taşı seçin.' },
    tips: { en: 'Control midpoints on the middle square for maximum mobility and double-mill traps!', tr: 'Orta karenin kenar orta noktalarını tutarak çift değirmen kapanları kurun!' }
  },
  {
    id: 'seabattle', icon: '🚢', color: 'var(--accent-blue)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Sea Battle', tr: 'Amiral Battı' },
    subtitle: { en: 'Battleship Sonar Radar', tr: 'Taktik Radar & Torpido' },
    obj: { en: 'Fire sonar torpedos on a 5x5 grid to locate and sink 3 hidden enemy naval vessels.', tr: '5x5 radar ızgarasında torpido fırlatarak gizlenmiş 3 düşman savaş gemisini batırın.' },
    ctrl: { en: 'Tap unrevealed grid coordinate to launch torpedo. Red = hit, Blue = miss.', tr: 'Ateş etmek için haritada bir kareye dokunun. Kırmızı = isabet, Mavi = su.' },
    tips: { en: 'Once you score a hit, target adjacent cells immediately!', tr: 'İsabet aldıktan sonra hemen komşu kareleri tarayın!' }
  },
  {
    id: 'reversi', icon: '⚪', color: 'var(--accent-green)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Reversi', tr: 'Reversi' },
    subtitle: { en: 'Classic Othello Flip', tr: 'Taş Çevirme Stratejisi' },
    obj: { en: 'Trap opponent discs between yours to flip them to your color. Most discs on board wins!', tr: 'Rakibin taşlarını iki taşınız arasına kıstırarak kendi renginize çevirin. En çok taşı olan kazanır!' },
    ctrl: { en: 'Tap any valid highlighted green circle to place your disc and flip opponent line.', tr: 'Geçerli hamle noktalarını gösteren yeşil halkalara dokunarak taşınızı koyun.' },
    tips: { en: 'Corners can never be flipped! Prioritize securing corner nodes.', tr: 'Köşe kareler asla geri çevrilemez! Köşeleri ele geçirmek oyunu kazandırır.' }
  },
  {
    id: 'word5', icon: '🔤', color: 'var(--accent-yellow)', isFree: true, categoryKey: 'cat_puzzle',
    title: { en: 'Word Master', tr: 'Kelime Ustası' },
    subtitle: { en: '5-Letter Word Hunt', tr: '5 Harfli Gizli Kelime' },
    obj: { en: 'Guess the hidden 5-letter word in 6 tries with dynamic color letter hints.', tr: 'Gizli 5 harfli kelimeyi 6 denemede yeşil/sarı/gri renk ipuçlarıyla çözün.' },
    ctrl: { en: 'Tap alphabet keys to type. Green = correct spot, Yellow = in word, Gray = absent.', tr: 'Harf klavyesine dokunarak kelimeyi yazın. Yeşil = doğru yer, Sarı = var, Gri = yok.' },
    tips: { en: 'Start with vowel-rich opener words like ARISE or AUDIO!', tr: 'Sesli harfi bol başlangıç kelimeleriyle başlayın!' }
  },
  {
    id: 'darts', icon: '🎯', color: 'var(--accent-red)', isFree: true, categoryKey: 'cat_crown',
    title: { en: 'Precision Darts', tr: 'Dart' },
    subtitle: { en: 'Target Dial Throw', tr: 'Hedef Tahtası & Crown' },
    obj: { en: 'Aim with Digital Crown and gauge throw power to hit Triple 20s and Bullseyes.', tr: 'Digital Crown ile nişan açısını ayarlayın ve güç barını tutturup hedefi vurun.' },
    ctrl: { en: 'Rotate Crown to align angle. Hold and release THROW button as power bar peaks.', tr: 'Crown çevirerek nişan alın. Güç barı dolunca FIRLAT butonuna basın.' },
    tips: { en: 'Triple 20 is worth 60 points — more than the 50-point Bullseye!', tr: 'Üçlü 20 bölgesi (60 puan) hedefin merkezinden (50 puan) daha değerlidir!' }
  },
  {
    id: 'microcircuit', icon: '🏎️', color: 'var(--accent-orange)', isFree: true, categoryKey: 'cat_reflex',
    title: { en: 'Micro Circuit', tr: 'Mikro Pist' },
    subtitle: { en: 'Drift & Crown Racer', tr: 'Drift & Crown Yarışı' },
    obj: { en: 'Drift through neon curves and beat the lap record using Crown steering or Wrist Tilt.', tr: 'Crown tekeri veya bileğinizi eğerek virajları dönün ve en iyi tur rekorunu kırın.' },
    ctrl: { en: 'Rotate Crown or tilt your device/drag mouse to steer. Hold GAS to accelerate!', tr: 'Crown ile veya fareyi sürükleyerek direksiyonu çevirin. Hızlanmak için GAZA basın!' },
    tips: { en: 'Start turning slightly before the apex to execute a high-speed drift!', tr: 'Viraja girmeden hafifçe direksiyon kırarak drift çizgisine oturun!' }
  },
  {
    id: 'bombdefusal', icon: '💣', color: 'var(--accent-red)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: 'Bomb Defusal', tr: 'Bomba İmha' },
    subtitle: { en: 'Logic Wire Cutter', tr: 'Kablo Kesme Mantığı' },
    obj: { en: 'Cut the correct colored wire under intense countdown based on tactical logic rules.', tr: 'Geri sayan saatte dedüksiyon kurallarına uyarak doğru renkli kabloyu kesin.' },
    ctrl: { en: 'Read serial rules and click the specific wire to cut it. Wrong cut explodes!', tr: 'Seri numarası kuralını okuyun ve kesmek istediğiniz kabloya tıklayın!' },
    tips: { en: 'If the last serial digit is odd and there is a red wire, wire 2 is safe!', tr: 'Seri sonu tekse ve kırmızı kablo varsa 2. kabloyu kesin!' }
  },
  {
    id: 'target24', icon: '🧮', color: 'var(--accent-purple)', isFree: false, categoryKey: 'cat_puzzle',
    title: { en: '24 Solver', tr: 'Hedef 24' },
    subtitle: { en: '4-Number Target Math', tr: '4 Rakamla 24 Bulmacası' },
    obj: { en: 'Combine 4 given numbers with arithmetic (+, -, ×, ÷) to reach exactly 24.', tr: 'Verilen 4 rakamı ve dört işlemi kullanarak tam olarak 24 sayısına ulaşın.' },
    ctrl: { en: 'Click numbers and operators sequentially to build mathematical expressions.', tr: 'Sırasıyla rakam ve işlem butonlarına tıklayarak denklemi oluşturun.' },
    tips: { en: 'Look for factor pairs of 24 like 3×8, 4×6, or 2×12!', tr: '24\'ün çarpanlarını (3×8, 4×6, 2×12) elde etmeye çalışın!' }
  },
  {
    id: 'tabletennis', icon: '🏓', color: 'var(--accent-teal)', isFree: false, categoryKey: 'cat_crown',
    title: { en: 'Air Tennis', tr: 'Masa Tenisi' },
    subtitle: { en: 'Retro Court Spin', tr: 'Retro Falso & Fiziği' },
    obj: { en: 'High-speed retro table tennis against an adaptive AI with topspin and side angles.', tr: 'Hızlı retro kortta yapay zekaya karşı falsolu kesme vuruşlarla sayı kazanın.' },
    ctrl: { en: 'Rotate Digital Crown (or mouse wheel) to position your paddle along the baseline.', tr: 'Raketinizi hareket ettirmek için Digital Crown veya fare tekerini kullanın.' },
    tips: { en: 'Hit the ball on paddle edges to apply steep slice angles that trick the bot!', tr: 'Topu raketin köşeleriyle karşılayarak botun yetişemeyeceği falso açıları verin!' }
  },
  {
    id: 'duel21', icon: '🃏', color: 'var(--accent-yellow)', isFree: false, categoryKey: 'cat_cards',
    title: { en: '21 Duel', tr: '21 Düellosu' },
    subtitle: { en: '2-Player Pass & Play', tr: '2 Kişilik Blackjack' },
    obj: { en: 'Pass-and-play heads-up Blackjack between 2 players on a single Apple Watch.', tr: 'Tek saat üzerinde arkadaşınızla sırayla kapıştığınız 2 kişilik Blackjack.' },
    ctrl: { en: 'Player 1 takes turn (Hit/Stand), passes watch to Player 2. Highest hand <= 21 wins!', tr: '1. Oyuncu kart çeker veya kalır, saati 2. Oyuncuya devreder. 21\'e en yakın olan kazanır!' },
    tips: { en: 'Stand on 17+ if your opponent already finished with a lower total!', tr: 'Rakibiniz düşük puanla kaldıysa 16-17 gibi ellerde risk almayıp durun!' }
  }
];

class WristArcadeApp {
  constructor() {
    this.root = document.getElementById('appRoot');
    this.currentView = 'menu';
    this.activeGameInstance = null;
    this.lang = Storage.getLang();
    this.selectedCategory = 'all';
    this.searchQuery = '';

    this.initClock();
    this.initControls();
    this.updateLangPill();
    this.render();
  }

  t(key) {
    const dict = I18N[this.lang] || I18N['en'];
    return dict[key] || key;
  }

  toggleLang() {
    this.lang = (this.lang === 'tr') ? 'en' : 'tr';
    Storage.setLang(this.lang);
    this.updateLangPill();
    audio.playTick();
    this.render();
  }

  updateLangPill() {
    const pill = document.getElementById('langPill');
    if (pill) pill.textContent = this.lang.toUpperCase();
    const btn = document.getElementById('toggleLangBtn');
    if (btn) btn.textContent = this.lang === 'tr' ? '🌐 Dil: Türkçe (Switch to EN)' : '🌐 Language: English (Türkçe Yap)';
  }

  initClock() {
    const clockEl = document.getElementById('watchTime');
    const update = () => {
      const now = new Date();
      const h = String(now.getHours()).padStart(2, '0');
      const m = String(now.getMinutes()).padStart(2, '0');
      clockEl.textContent = `${h}:${m}`;
    };
    update();
    setInterval(update, 1000);
  }

  initControls() {
    const crown = document.getElementById('digitalCrown');
    const actionBtn = document.getElementById('actionBtn');
    const sideBtn = document.getElementById('sideBtn');
    const langPill = document.getElementById('langPill');
    const toggleLangBtn = document.getElementById('toggleLangBtn');

    if (langPill) {
      langPill.addEventListener('click', () => this.toggleLang());
    }
    if (toggleLangBtn) {
      toggleLangBtn.addEventListener('click', () => this.toggleLang());
    }

    actionBtn.addEventListener('click', () => {
      audio.playTick();
      this.navigate('menu');
    });

    sideBtn.addEventListener('click', () => {
      audio.playTick();
      this.navigate('settings');
    });

    // Theme Selector Buttons
    document.querySelectorAll('.theme-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.theme-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        const theme = btn.dataset.theme;
        const container = document.getElementById('watchCaseContainer');
        if (container) {
          container.className = 'watch-case-container ' + (theme === 'midnight-ocean' ? 'theme-midnight-ocean' : (theme === 'starlight-trail' ? 'theme-starlight-trail' : ''));
        }
        audio.playTick();
      });
    });

    // Software Display Theme Buttons
    const savedTheme = Storage.getTheme();
    Storage.setTheme(savedTheme);
    document.querySelectorAll('[data-soft-theme]').forEach(btn => {
      if (btn.dataset.softTheme === savedTheme) btn.classList.add('active');
      else btn.classList.remove('active');
      btn.addEventListener('click', () => {
        document.querySelectorAll('[data-soft-theme]').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        Storage.setTheme(btn.dataset.softTheme);
        audio.playTick();
      });
    });

    // Sound toggle
    const sndBtn = document.getElementById('toggleSoundBtn');
    if (sndBtn) {
      sndBtn.addEventListener('click', () => {
        audio.enabled = !audio.enabled;
        sndBtn.textContent = audio.enabled ? '🔊 Sound: ON' : '🔇 Sound: OFF';
        audio.playTick();
      });
    }

    // Trophy modal triggers
    const trophyBtn = document.getElementById('trophyBtn');
    if (trophyBtn) trophyBtn.addEventListener('click', () => { audio.playTick(); this.openTrophies(); });
    const openTrophiesActionBtn = document.getElementById('openTrophiesActionBtn');
    if (openTrophiesActionBtn) openTrophiesActionBtn.addEventListener('click', () => { audio.playTick(); this.openTrophies(); });

    // Stats & XP modal trigger
    const openStatsActionBtn = document.getElementById('openStatsActionBtn');
    if (openStatsActionBtn) openStatsActionBtn.addEventListener('click', () => { audio.playTick(); this.openStatsModal(); });

    // 2-Player Duel trigger
    const openDuelActionBtn = document.getElementById('openDuelActionBtn');
    if (openDuelActionBtn) openDuelActionBtn.addEventListener('click', () => { audio.playTick(); this.openDuelView(); });

    // Gauntlet trigger
    const openGauntletBtn = document.getElementById('openGauntletBtn');
    if (openGauntletBtn) openGauntletBtn.addEventListener('click', () => { audio.playTick(); this.openGauntletView(); });

    // Mockup modal trigger
    const openMockupBtn = document.getElementById('openMockupBtn');
    if (openMockupBtn) openMockupBtn.addEventListener('click', () => { audio.playTick(); this.openMockup(); });

    window.addEventListener('wheel', (e) => {
      if (this.activeGameInstance && this.activeGameInstance.onCrown) {
        e.preventDefault();
        const delta = e.deltaY > 0 ? 1 : -1;
        this.activeGameInstance.onCrown(delta);
        audio.playTick();
        this.animateCrown(delta);
      }
    }, { passive: false });

    let isDraggingCrown = false;
    let startY = 0;
    crown.addEventListener('mousedown', (e) => {
      isDraggingCrown = true;
      startY = e.clientY;
    });
    window.addEventListener('mousemove', (e) => {
      if (!isDraggingCrown) return;
      const diff = e.clientY - startY;
      if (Math.abs(diff) > 8) {
        const delta = diff > 0 ? 1 : -1;
        if (this.activeGameInstance && this.activeGameInstance.onCrown) {
          this.activeGameInstance.onCrown(delta);
          audio.playTick();
        }
        this.animateCrown(delta);
        startY = e.clientY;
      }
    });
    window.addEventListener('mouseup', () => { isDraggingCrown = false; });

    window.addEventListener('keydown', (e) => {
      if (this.activeGameInstance && this.activeGameInstance.onCrown) {
        if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
          this.activeGameInstance.onCrown(-1);
          audio.playTick();
          this.animateCrown(-1);
        } else if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
          this.activeGameInstance.onCrown(1);
          audio.playTick();
          this.animateCrown(1);
        }
      }
    });
  }

  animateCrown(dir) {
    const crown = document.getElementById('digitalCrown');
    crown.style.transform = `translateY(${dir * 2}px)`;
    setTimeout(() => { crown.style.transform = 'translateY(0)'; }, 60);
  }

  navigate(viewId, param = null) {
    if (this.activeGameInstance && this.activeGameInstance.destroy) {
      this.activeGameInstance.destroy();
      this.activeGameInstance = null;
    }
    this.currentView = viewId;
    this.render(param);
  }

  render(param) {
    const isPro = Storage.isPro();
    document.getElementById('proStatusIndicator').style.display = isPro ? 'inline-block' : 'none';

    if (this.currentView === 'menu') {
      this.renderMenu();
    } else if (this.currentView === 'paywall') {
      this.renderPaywall();
    } else if (this.currentView === 'settings') {
      this.renderSettings();
    } else if (this.currentView === 'game') {
      this.renderGame(param);
    }
  }

  openHowToPlay(gameId) {
    const g = CATALOG.find(item => item.id === gameId);
    if (!g) return;

    const modal = document.createElement('div');
    modal.className = 'info-modal';
    const lang = this.lang;
    const title = g.title[lang] || g.title['en'];
    const cat = this.t(g.categoryKey);
    const obj = g.obj[lang] || g.obj['en'];
    const ctrl = g.ctrl[lang] || g.ctrl['en'];
    const tips = g.tips[lang] || g.tips['en'];

    modal.innerHTML = `
      <div class="info-header">
        <div class="info-header-left">
          <span style="font-size:16px;">${g.icon}</span>
          <div>
            <h3>${title}</h3>
            <span>${cat}</span>
          </div>
        </div>
        <button class="info-close-btn" id="btnCloseInfo">✕</button>
      </div>
      <div class="info-section">
        <div class="info-section-title obj">🎯 ${this.t('objective')}</div>
        <p>${obj}</p>
      </div>
      <div class="info-section">
        <div class="info-section-title ctrl">🕹️ ${this.t('controls')}</div>
        <p>${ctrl}</p>
      </div>
      <div class="info-section">
        <div class="info-section-title tips">💡 ${this.t('pro_tips')}</div>
        <p>${tips}</p>
      </div>
      <button class="info-ok-btn" id="btnOkInfo">${this.t('got_it')}</button>
    `;

    this.root.appendChild(modal);

    const close = () => {
      audio.playTick();
      modal.remove();
    };
    modal.querySelector('#btnCloseInfo').addEventListener('click', close);
    modal.querySelector('#btnOkInfo').addEventListener('click', close);
  }

  openTrophies() {
    const trophies = [
      { id: 'first_game', icon: '🎯', name: this.lang === 'tr' ? 'İlk Adım' : 'First Step', desc: this.lang === 'tr' ? 'İlk mini oyununu oyna' : 'Play any mini-game' },
      { id: 'luckydice', icon: '🎲', name: this.lang === 'tr' ? 'Zar Ustası' : 'Dice Master', desc: this.lang === 'tr' ? 'Lucky Dice oyununda üçlü yakala' : 'Roll triples in Lucky Dice' },
      { id: 'galaxydefender', icon: '🚀', name: this.lang === 'tr' ? 'Galaksi Savunucusu' : 'Galaxy Guardian', desc: this.lang === 'tr' ? 'Galaxy Defender 2. Dalgaya ulaş' : 'Reach Wave 2 in Galaxy Defender' },
      { id: 'towerstack', icon: '🏗️', name: this.lang === 'tr' ? 'Gökdelen Mimarı' : 'Tower Architect', desc: this.lang === 'tr' ? 'Denge Kulesinde 10 kata ulaş' : 'Reach floor 10 in Tower Stacker' },
      { id: 'memorymatrix', icon: '🧠', name: this.lang === 'tr' ? 'Maymun Zekası' : 'Chimp Genius', desc: this.lang === 'tr' ? 'Hafıza Matrisinde 3. Seviyeyi geç' : 'Clear Level 3 in Memory Matrix' },
      { id: 'pro_unlocked', icon: '👑', name: this.lang === 'tr' ? 'VIP Arcade' : 'VIP Arcade', desc: this.lang === 'tr' ? 'Tüm 40 oyunun kilidini aç' : 'Unlock all 40 games' }
    ];

    const unlocked = Storage.getTrophies();
    if (Storage.isPro()) unlocked.push('pro_unlocked');

    const modal = document.createElement('div');
    modal.className = 'sheet-modal';
    let listHtml = '';
    trophies.forEach(t => {
      const isUnlocked = unlocked.includes(t.id);
      listHtml += `
        <div class="trophy-item ${isUnlocked ? 'unlocked' : ''}">
          <span class="trophy-badge">${isUnlocked ? t.icon : '🔒'}</span>
          <div class="trophy-text">
            <div class="trophy-name">${t.name} ${isUnlocked ? '✅' : ''}</div>
            <div class="trophy-desc">${t.desc}</div>
          </div>
        </div>
      `;
    });

    modal.innerHTML = `
      <button class="sheet-close" id="btnCloseTrophies">✕</button>
      <div style="padding:4px 6px;">
        <h3 style="font-size:12px; font-weight:900; color:var(--accent-yellow); margin-bottom:4px;">🏆 ${this.t('trophies')}</h3>
        <div class="trophies-list">${listHtml}</div>
      </div>
    `;
    this.root.appendChild(modal);
    modal.querySelector('#btnCloseTrophies').addEventListener('click', () => {
      audio.playTick();
      modal.remove();
    });
  }

  openMockup() {
    const modal = document.createElement('div');
    modal.className = 'mockup-modal';
    const isTr = this.lang === 'tr';

    modal.innerHTML = `
      <div class="mockup-canvas-wrapper theme-sunset" id="mockupCanvas">
        <div class="mockup-header-text">
          <span class="mockup-tagline-pill">⌚ APPLE WATCH ULTRA</span>
          <h2 class="mockup-main-title">${isTr ? '50 Mega Retro Oyun<br>Bileğinizde!' : '50 Mega Watch Games<br>On Your Wrist!'}</h2>
        </div>

        <div style="transform: scale(0.85); transform-origin: center; margin: -10px 0;">
          <div style="background: #18181b; border: 4px solid #71717a; border-radius: 36px; padding: 12px; width: 170px; height: 215px; box-shadow: 0 15px 35px rgba(0,0,0,0.8); display: flex; flex-direction: column; align-items: center; justify-content: center; position: relative;">
            <div style="font-size: 38px; margin-bottom: 6px;">⌚</div>
            <div style="font-size: 13px; font-weight: 900; color: #facc15;">WristArcade</div>
            <div style="font-size: 9px; font-weight: 700; color: #fff; margin-top: 2px;">50 Games Golden Edition</div>
            <div style="display: flex; gap: 4px; margin-top: 10px; font-size: 16px;">
              <span>🏒</span><span>♟️</span><span>🚀</span><span>♠️</span><span>🎲</span>
            </div>
            <div style="margin-top: 12px; background: rgba(255,255,255,0.1); border-radius: 12px; padding: 3px 8px; font-size: 8px; color: #38bdf8; font-weight: 800;">
              100% ROYALTY FREE
            </div>
          </div>
        </div>

        <div class="mockup-footer-badge">
          <span>👑 StoreKit 2 Ready</span>
          <span>•</span>
          <span>⚡ Zero Battery Drain</span>
        </div>
      </div>

      <div class="mockup-controls-bar" style="flex-wrap:wrap; justify-content:center; gap:6px;">
        <button class="mockup-btn secondary" id="btnThemeIndigo">Indigo</button>
        <button class="mockup-btn secondary" id="btnThemeSunset">Sunset</button>
        <button class="mockup-btn secondary" id="btnThemeCyber">Cyber</button>
        <button class="mockup-btn secondary" id="btnThemeMidnight">Midnight</button>
        <button class="mockup-btn secondary" id="btnExportScreenshot" style="background:#0284c7; color:#fff; font-weight:800;">💾 ${isTr ? 'App Store Ekran Görüntüsü (PNG)' : 'Download App Store (PNG)'}</button>
        <button class="mockup-btn primary" id="btnCloseMockup">✕ ${isTr ? 'Kapat' : 'Close'}</button>
      </div>
    `;

    document.body.appendChild(modal);

    const canvas = modal.querySelector('#mockupCanvas');
    modal.querySelector('#btnThemeIndigo').addEventListener('click', () => { canvas.className = 'mockup-canvas-wrapper'; });
    modal.querySelector('#btnThemeSunset').addEventListener('click', () => { canvas.className = 'mockup-canvas-wrapper theme-sunset'; });
    modal.querySelector('#btnThemeCyber').addEventListener('click', () => { canvas.className = 'mockup-canvas-wrapper theme-cyber'; });
    modal.querySelector('#btnThemeMidnight').addEventListener('click', () => { canvas.className = 'mockup-canvas-wrapper theme-midnight'; });
    
    modal.querySelector('#btnExportScreenshot').addEventListener('click', () => {
      audio.playScore();
      const expCanvas = document.createElement('canvas');
      expCanvas.width = 410;
      expCanvas.height = 502;
      const ctx = expCanvas.getContext('2d');

      // Background gradient
      const grad = ctx.createLinearGradient(0, 0, 410, 502);
      grad.addColorStop(0, '#0f172a');
      grad.addColorStop(0.5, '#1e1b4b');
      grad.addColorStop(1, '#09090b');
      ctx.fillStyle = grad;
      ctx.fillRect(0, 0, 410, 502);

      // Top Tagline Pill
      ctx.fillStyle = 'rgba(245, 158, 11, 0.2)';
      ctx.strokeStyle = '#f59e0b';
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.roundRect(410 / 2 - 110, 24, 220, 28, 14);
      ctx.fill();
      ctx.stroke();

      ctx.fillStyle = '#f59e0b';
      ctx.font = 'bold 12px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('⌚ APPLE WATCH ULTRA', 410 / 2, 42);

      // Title
      ctx.fillStyle = '#ffffff';
      ctx.font = '900 24px sans-serif';
      ctx.fillText(isTr ? '50 MEGA RETRO OYUN' : '50 MEGA WATCH GAMES', 410 / 2, 85);
      ctx.font = 'bold 14px sans-serif';
      ctx.fillStyle = '#38bdf8';
      ctx.fillText(isTr ? 'Bileğinizdeki En Büyük Konsol!' : 'Ultimate Arcade On Your Wrist!', 410 / 2, 108);

      // Watch Case Mockup
      const watchW = 180;
      const watchH = 225;
      const watchX = (410 - watchW) / 2;
      const watchY = 135;

      ctx.fillStyle = '#18181b';
      ctx.strokeStyle = '#71717a';
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.roundRect(watchX, watchY, watchW, watchH, 36);
      ctx.fill();
      ctx.stroke();

      // Screen inside watch
      ctx.fillStyle = '#09090b';
      ctx.beginPath();
      ctx.roundRect(watchX + 10, watchY + 10, watchW - 20, watchH - 20, 26);
      ctx.fill();

      // Watch content
      ctx.fillStyle = '#facc15';
      ctx.font = '900 18px sans-serif';
      ctx.fillText('WristArcade', 410 / 2, watchY + 60);

      ctx.fillStyle = '#ffffff';
      ctx.font = 'bold 11px sans-serif';
      ctx.fillText('50 Games Golden Edition', 410 / 2, watchY + 82);

      ctx.font = '22px sans-serif';
      ctx.fillText('🏒  ♟️  🚀  ♠️  🎲', 410 / 2, watchY + 120);

      ctx.fillStyle = '#06b6d4';
      ctx.font = '900 11px sans-serif';
      ctx.fillText('100% ROYALTY FREE', 410 / 2, watchY + 155);

      // Footer badge
      ctx.fillStyle = '#a1a1aa';
      ctx.font = 'bold 11px sans-serif';
      ctx.fillText('👑 StoreKit 2 Ready  •  ⚡ Zero Battery Drain', 410 / 2, 502 - 25);

      const link = document.createElement('a');
      link.download = 'WristArcade_AppStore_410x502.png';
      link.href = expCanvas.toDataURL('image/png');
      link.click();
    });

    modal.querySelector('#btnCloseMockup').addEventListener('click', () => {
      audio.playTick();
      modal.remove();
    });
  }

  openStatsModal() {
    const xp = Storage.getXP();
    const lvl = Storage.getLevel(xp);
    const rank = Storage.getRank(lvl);
    const progress = Storage.getProgressToNextLevel(xp);
    const streak = Storage.getStreak();
    const activity = Storage.getActivity7Days();
    const maxCount = Math.max(1, ...activity.map(a => a.count));

    let chartColsHtml = '';
    activity.forEach((item, idx) => {
      const heightPct = Math.max(8, Math.round((item.count / maxCount) * 100));
      const isToday = idx === activity.length - 1;
      chartColsHtml += `
        <div class="chart-col">
          <div class="chart-bar-bg" title="${item.date}: ${item.count} games">
            <div class="chart-bar-fill" style="height: ${heightPct}%; ${isToday ? 'background:var(--accent-cyan);' : ''}"></div>
          </div>
          <span class="chart-day-label" style="${isToday ? 'color:#fff;font-weight:900;' : ''}">${item.label}</span>
        </div>
      `;
    });

    const modal = document.createElement('div');
    modal.className = 'sheet-modal';
    const isTr = this.lang === 'tr';

    modal.innerHTML = `
      <button class="sheet-close" id="btnCloseStats">✕</button>
      <div style="padding:4px 6px;">
        <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">
          <span style="font-size:26px;">${rank.badge}</span>
          <div>
            <div style="font-size:13px; font-weight:900; color:#fff;">Lv.${lvl} • ${rank.title[this.lang] || rank.title['en']}</div>
            <div style="font-size:10px; font-weight:700; color:#facc15;">${xp} XP</div>
          </div>
        </div>

        <div style="margin-bottom:10px;">
          <div class="xp-bar-track" style="height:6px;">
            <div class="xp-bar-fill" style="width:${Math.round(progress * 100)}%;"></div>
          </div>
          <div style="display:flex; justify-content:space-between; font-size:8px; color:#94a3b8; margin-top:3px;">
            <span>${isTr ? 'Sonraki Seviye' : 'Next Level'}</span>
            <span>${Math.round(progress * 100)}%</span>
          </div>
        </div>

        <div style="font-size:9px; font-weight:800; color:#94a3b8; text-transform:uppercase; margin-bottom:4px;">
          📊 ${isTr ? 'Son 7 Gün Oynanış' : '7-Day Activity'}
        </div>
        <div class="stats-chart-wrapper">
          ${chartColsHtml}
        </div>

        <div style="margin-top:12px; background:rgba(255,255,255,0.06); border-radius:8px; padding:8px; display:flex; justify-content:space-between;">
          <span style="font-size:10px; color:#94a3b8;">${isTr ? 'Günlük Seri' : 'Daily Streak'}:</span>
          <span style="font-size:10px; font-weight:800; color:#f97316;">${streak} ${isTr ? 'Gün' : 'Days'} 🔥</span>
        </div>
      </div>
    `;

    this.root.appendChild(modal);
    modal.querySelector('#btnCloseStats').addEventListener('click', () => {
      audio.playTick();
      modal.remove();
    });
  }

  showLevelUpToast(level, rank) {
    audio.playVictory();
    confetti.trigger(75);

    const toast = document.createElement('div');
    toast.className = 'level-up-toast';
    const isTr = this.lang === 'tr';

    toast.innerHTML = `
      <div class="level-up-badge">${rank.badge}</div>
      <div class="level-up-congrats">🎉 ${isTr ? 'TEBRİKLER! SEVİYE ATLADIN' : 'LEVEL UP!'}</div>
      <div class="level-up-number">${isTr ? 'SEVİYE' : 'LEVEL'} ${level}</div>
      <div class="level-up-rank-title">${rank.title[this.lang] || rank.title['en']}</div>
      <button class="level-up-dismiss-btn" id="btnDismissLevelUp">${isTr ? 'DEVAM ET' : 'CONTINUE'}</button>
    `;

    document.getElementById('watchScreen').appendChild(toast);
    toast.querySelector('#btnDismissLevelUp').addEventListener('click', () => {
      audio.playTick();
      toast.remove();
      this.render();
    });
  }

  openDuelView() {
    audio.playTick();
    let p1Score = 0;
    let p2Score = 0;
    let state = 'ready'; // 'ready' | 'waiting' | 'tapNow' | 'roundOver'
    let timer = null;
    const isTr = this.lang === 'tr';

    const renderDuel = () => {
      this.root.innerHTML = `
        <div class="duel-arena">
          <!-- Top Player (P1 - Inverted 180 degrees) -->
          <div class="duel-player-zone duel-zone-p1 ${state === 'tapNow' ? 'duel-zone-tap-now' : ''}" id="p1TapZone">
            <span class="duel-player-name">${isTr ? 'OYUNCU 1 (P1)' : 'PLAYER 1 (P1)'}</span>
            <span class="duel-score-big">${p1Score} / 3</span>
            ${state === 'tapNow' ? `<span class="duel-tap-prompt">⚡ ${isTr ? 'BAS!' : 'TAP!'}</span>` : ''}
          </div>

          <!-- Mid Control Bar -->
          <div class="duel-mid-bar">
            <button class="duel-btn-sm" id="btnExitDuel">✕</button>
            <span class="duel-status-text" id="duelStatus">
              ${p1Score >= 3 ? (isTr ? '👑 P1 KAZANDI!' : '👑 P1 WINS!') : (p2Score >= 3 ? (isTr ? '👑 P2 KAZANDI!' : '👑 P2 WINS!') : (state === 'waiting' ? (isTr ? 'BEKLE...' : 'WAIT...') : (state === 'tapNow' ? (isTr ? 'ŞİMDİ! ⚡' : 'NOW! ⚡') : (state === 'ready' ? (isTr ? 'BAŞLA' : 'START') : (isTr ? 'SONRAKİ EL' : 'NEXT ROUND')))))}
            </span>
            ${(p1Score < 3 && p2Score < 3 && (state === 'ready' || state === 'roundOver')) ? `<button class="duel-btn-sm" id="btnStartDuelRound">▶</button>` : ''}
          </div>

          <!-- Bottom Player (P2 - Normal orientation) -->
          <div class="duel-player-zone duel-zone-p2 ${state === 'tapNow' ? 'duel-zone-tap-now' : ''}" id="p2TapZone">
            ${state === 'tapNow' ? `<span class="duel-tap-prompt">⚡ ${isTr ? 'BAS!' : 'TAP!'}</span>` : ''}
            <span class="duel-score-big">${p2Score} / 3</span>
            <span class="duel-player-name">${isTr ? 'OYUNCU 2 (P2)' : 'PLAYER 2 (P2)'}</span>
          </div>
        </div>
      `;

      // Event handlers
      this.root.querySelector('#btnExitDuel').addEventListener('click', () => {
        if (timer) clearTimeout(timer);
        audio.playTick();
        this.navigate('menu');
      });

      const startBtn = this.root.querySelector('#btnStartDuelRound');
      if (startBtn) {
        startBtn.addEventListener('click', () => {
          startRound();
        });
      }

      this.root.querySelector('#p1TapZone').addEventListener('click', () => handleTap(1));
      this.root.querySelector('#p2TapZone').addEventListener('click', () => handleTap(2));
    };

    const startRound = () => {
      state = 'waiting';
      audio.playTick();
      renderDuel();

      const delay = 1500 + Math.random() * 2000;
      timer = setTimeout(() => {
        state = 'tapNow';
        audio.playScore();
        renderDuel();
      }, delay);
    };

    const handleTap = (player) => {
      if (state === 'waiting') {
        // False start! Opponent gets point
        clearTimeout(timer);
        state = 'roundOver';
        if (player === 1) p2Score++;
        else p1Score++;
        audio.playGameOver();
        checkDuelOver();
        renderDuel();
        return;
      }
      if (state === 'tapNow') {
        clearTimeout(timer);
        state = 'roundOver';
        if (player === 1) p1Score++;
        else p2Score++;
        audio.playVictory();
        checkDuelOver();
        renderDuel();
      }
    };

    const checkDuelOver = () => {
      if (p1Score >= 3 || p2Score >= 3) {
        confetti.trigger(50);
        Storage.addXP(50, 'Wrist Duel Win');
      }
    };

    renderDuel();
  }

  openGauntletView() {
    audio.playTick();
    const isTr = this.lang === 'tr';
    let lives = 3;
    let score = 0;
    let roundIndex = 0;
    let step = 'intro'; // 'intro' | 'roundIntro' | 'miniGame' | 'victory' | 'defeat'
    let roundTimer = 7.0;
    let intervalId = null;
    let timeoutId = null;

    // Mini-game states
    let mathA = 3, mathB = 4, mathAns = 7, mathOptions = [7, 8, 6];
    let reflexColor = '#ef4444', reflexReady = false;
    let targetDots = 3, dotsHit = 0, dotPos = { x: 80, y: 70 };
    let dialAngle = 0, targetAngle = 90;
    let tapsCount = 0, requiredTaps = 12;

    const roundTitles = [
      { enTitle: "SPEED MATH", enPrompt: "Solve instantly!", trTitle: "HIZLI MATEMATİK", trPrompt: "Hemen çöz!" },
      { enTitle: "REFLEX FLASH", enPrompt: "Tap on GREEN!", trTitle: "REFLEKS IŞIK", trPrompt: "YEŞİLDE dokun!" },
      { enTitle: "WHACK TARGETS", enPrompt: "Hit all red dots!", trTitle: "HEDEFLERİ VUR", trPrompt: "Tüm kırmızı noktalara bas!" },
      { enTitle: "LOCK ALIGN", enPrompt: "Turn dial to match!", trTitle: "KİLİT AYARLA", trPrompt: "Kadranı hedefe çevir!" },
      { enTitle: "TURBO TAP", enPrompt: "12 Rapid Taps!", trTitle: "SERİ DOKUNUŞ", trPrompt: "Hızlıca 12 kere bas!" }
    ];

    const cleanup = () => {
      if (intervalId) clearInterval(intervalId);
      if (timeoutId) clearTimeout(timeoutId);
      intervalId = null;
      timeoutId = null;
    };

    const startGauntlet = () => {
      lives = 3;
      roundIndex = 0;
      score = 0;
      loadRound(0);
    };

    const loadRound = (idx) => {
      cleanup();
      roundIndex = idx;
      roundTimer = 7.0;
      step = 'roundIntro';
      renderGauntlet();

      // Setup microgame
      if (idx === 0) {
        mathA = Math.floor(Math.random() * 5) + 2;
        mathB = Math.floor(Math.random() * 5) + 2;
        mathAns = mathA + mathB;
        const pool = [mathAns, mathAns + 1, mathAns - 1].sort(() => Math.random() - 0.5);
        mathOptions = pool;
      } else if (idx === 1) {
        reflexColor = '#ef4444';
        reflexReady = false;
        timeoutId = setTimeout(() => {
          if (step === 'miniGame' && roundIndex === 1) {
            reflexColor = '#22c55e';
            reflexReady = true;
            audio.playMove();
            renderGauntlet();
          }
        }, 1500 + Math.random() * 1500);
      } else if (idx === 2) {
        dotsHit = 0;
        dotPos = { x: 40 + Math.floor(Math.random() * 80), y: 30 + Math.floor(Math.random() * 55) };
      } else if (idx === 3) {
        dialAngle = 0;
        const targetList = [90, 180, 270];
        targetAngle = targetList[Math.floor(Math.random() * targetList.length)];
      } else {
        tapsCount = 0;
      }

      timeoutId = setTimeout(() => {
        step = 'miniGame';
        startTimer();
        renderGauntlet();
      }, 1200);
    };

    const startTimer = () => {
      cleanup();
      intervalId = setInterval(() => {
        if (step !== 'miniGame') return;
        roundTimer -= 0.1;
        if (roundTimer <= 0) {
          failRound();
        } else {
          updateTimerBar();
        }
      }, 100);
    };

    const updateTimerBar = () => {
      const fillEl = this.root.querySelector('#gauntletTimerFill');
      if (fillEl) {
        const pct = Math.max(0, Math.min(100, (roundTimer / 7.0) * 100));
        fillEl.style.width = pct + '%';
        fillEl.style.background = roundTimer > 2.5 ? '#22c55e' : '#ef4444';
      }
    };

    const passRound = () => {
      cleanup();
      audio.playVictory();
      score += 50;
      if (roundIndex >= 4) {
        step = 'victory';
        confetti.trigger(70);
        Storage.recordScore('gauntlet', score + 250);
        Storage.addXP(250, 'Arcade Gauntlet Cleared');
        renderGauntlet();
      } else {
        loadRound(roundIndex + 1);
      }
    };

    const failRound = () => {
      cleanup();
      audio.playBuzzer();
      lives -= 1;
      if (lives <= 0) {
        step = 'defeat';
        renderGauntlet();
      } else {
        loadRound(roundIndex);
      }
    };

    const renderGauntlet = () => {
      // Hearts
      let heartsHtml = '';
      for (let i = 0; i < 3; i++) {
        heartsHtml += `<span style="font-size:11px;">${i < lives ? '❤️' : '🖤'}</span>`;
      }

      let contentHtml = '';

      if (step === 'intro') {
        contentHtml = `
          <div class="gauntlet-center-box">
            <div style="font-size:28px; margin-bottom:4px; animation: pulse 1.5s infinite;">⚡</div>
            <div style="font-size:13px; font-weight:900; color:#fbbf24; text-transform:uppercase;">ARCADE GAUNTLET</div>
            <div style="font-size:9px; color:#cbd5e1; margin:6px 0 14px 0; line-height:1.3; text-align:center;">
              ${isTr ? '5 Hızlı Mikro Oyun<br>3 Can ile Hayatta Kal!' : '5 Rapid Micro-Games<br>Survive with 3 Lives!'}
            </div>
            <button class="gauntlet-btn-primary" id="btnGauntletStart">
              ${isTr ? 'MARATONU BAŞLAT' : 'START MARATHON'}
            </button>
          </div>
        `;
      } else if (step === 'roundIntro') {
        const info = roundTitles[roundIndex] || roundTitles[0];
        const title = isTr ? info.trTitle : info.enTitle;
        const prompt = isTr ? info.trPrompt : info.enPrompt;
        contentHtml = `
          <div class="gauntlet-center-box">
            <div style="font-size:10px; font-weight:900; color:#38bdf8; letter-spacing:0.05em; text-transform:uppercase;">
              ${isTr ? 'AŞAMA' : 'STAGE'} ${roundIndex + 1} / 5
            </div>
            <div style="font-size:15px; font-weight:900; color:#ffffff; margin:6px 0 2px 0;">${title}</div>
            <div style="font-size:11px; font-weight:700; color:#facc15;">${prompt}</div>
          </div>
        `;
      } else if (step === 'miniGame') {
        if (roundIndex === 0) {
          // Fast Math
          contentHtml = `
            <div class="gauntlet-center-box">
              <div style="font-size:18px; font-weight:900; font-family:monospace; color:#fff; margin-bottom:12px;">
                ${mathA} + ${mathB} = ?
              </div>
              <div style="display:flex; gap:8px;">
                ${mathOptions.map(opt => `
                  <button class="gauntlet-choice-btn" data-ans="${opt}">${opt}</button>
                `).join('')}
              </div>
            </div>
          `;
        } else if (roundIndex === 1) {
          // Reflex Flash
          contentHtml = `
            <div class="gauntlet-center-box">
              <button class="gauntlet-reflex-pad" id="btnReflexPad" style="background:${reflexColor};">
                <span style="font-size:13px; font-weight:900; color:#000;">
                  ${reflexReady ? (isTr ? 'ŞİMDİ DOKUN!' : 'TAP NOW!') : (isTr ? 'BEKLE...' : 'WAIT...')}
                </span>
              </button>
            </div>
          `;
        } else if (roundIndex === 2) {
          // Whack targets
          contentHtml = `
            <div style="position:relative; width:100%; height:110px; overflow:hidden;">
              <div style="text-align:center; font-size:9px; font-weight:700; color:#94a3b8; margin-top:2px;">
                ${isTr ? `${targetDots - dotsHit} hedef kaldı!` : `Hit ${targetDots - dotsHit} more!`}
              </div>
              <button class="gauntlet-dot-target" id="btnDotTarget" style="left:${dotPos.x}px; top:${dotPos.y}px;"></button>
            </div>
          `;
        } else if (roundIndex === 3) {
          // Dial align
          contentHtml = `
            <div class="gauntlet-center-box">
              <div style="font-size:9px; font-weight:700; color:#94a3b8; margin-bottom:6px;">
                ${isTr ? 'Kadranı hedefe çevir!' : 'Rotate dial to match target!'}
              </div>
              <div style="position:relative; width:64px; height:64px; border-radius:50%; border:3px solid rgba(255,255,255,0.2); margin-bottom:8px; display:flex; align-items:center; justify-content:center;">
                <div style="position:absolute; width:4px; height:24px; background:#22c55e; border-radius:2px; transform:translateY(-14px) rotate(${targetAngle}deg); transform-origin:50% 26px;"></div>
                <div style="position:absolute; width:4px; height:24px; background:#38bdf8; border-radius:2px; transform:translateY(-14px) rotate(${dialAngle}deg); transform-origin:50% 26px;"></div>
              </div>
              <button class="gauntlet-btn-primary" id="btnTurnDial" style="padding:4px 12px; font-size:10px; background:#0284c7; color:#fff;">
                ${isTr ? 'KADRANI ÇEVİR' : 'TURN DIAL'}
              </button>
            </div>
          `;
        } else {
          // Turbo Tap
          contentHtml = `
            <div class="gauntlet-center-box">
              <div style="font-size:9px; font-weight:900; color:#f97316; text-transform:uppercase;">
                ${isTr ? 'HIZLICA DOKUN!' : 'TAP AS FAST AS YOU CAN!'}
              </div>
              <div style="font-size:16px; font-weight:900; font-family:monospace; color:#fff; margin:4px 0 8px 0;">
                ${tapsCount} / ${requiredTaps}
              </div>
              <button class="gauntlet-turbo-btn" id="btnTurboTap">TAP</button>
            </div>
          `;
        }
      } else if (step === 'victory') {
        contentHtml = `
          <div class="gauntlet-center-box">
            <div style="font-size:26px; margin-bottom:2px;">👑</div>
            <div style="font-size:12px; font-weight:900; color:#fbbf24; text-transform:uppercase;">
              ${isTr ? 'GAUNTLET TAMAMLANDI!' : 'GAUNTLET CLEARED!'}
            </div>
            <div style="font-size:11px; font-weight:800; color:#22c55e; margin:6px 0 12px 0;">+250 XP BONUS</div>
            <button class="gauntlet-btn-primary" id="btnGauntletDone" style="background:#22c55e; color:#000;">
              ${isTr ? 'ÖDÜLÜ AL' : 'CLAIM REWARD'}
            </button>
          </div>
        `;
      } else if (step === 'defeat') {
        contentHtml = `
          <div class="gauntlet-center-box">
            <div style="font-size:26px; margin-bottom:2px;">💀</div>
            <div style="font-size:12px; font-weight:900; color:#ef4444; text-transform:uppercase;">
              ${isTr ? 'ELENDİNİZ' : 'GAUNTLET FAILED'}
            </div>
            <div style="font-size:9px; color:#94a3b8; margin:4px 0 12px 0;">
              ${isTr ? `Aşama ${roundIndex + 1} seni eledi` : `Stage ${roundIndex + 1} eliminated you`}
            </div>
            <button class="gauntlet-btn-primary" id="btnGauntletRetry" style="background:#f97316; color:#000;">
              ${isTr ? 'TEKRAR DENE' : 'TRY AGAIN'}
            </button>
          </div>
        `;
      }

      this.root.innerHTML = `
        <div class="gauntlet-arena">
          <!-- Top HUD -->
          <div class="gauntlet-hud">
            <button class="gauntlet-exit-btn" id="btnExitGauntlet">✕</button>
            <span class="gauntlet-hud-title">⚡ GAUNTLET</span>
            <div class="gauntlet-lives-box">${heartsHtml}</div>
          </div>

          <!-- Timer Bar Track -->
          <div class="gauntlet-timer-track" style="visibility:${step === 'miniGame' ? 'visible' : 'hidden'};">
            <div class="gauntlet-timer-fill" id="gauntletTimerFill" style="width:${Math.max(0, Math.min(100, (roundTimer / 7.0) * 100))}%;"></div>
          </div>

          <!-- Content Zone -->
          <div class="gauntlet-content">
            ${contentHtml}
          </div>
        </div>
      `;

      // Event hookups
      const btnExit = this.root.querySelector('#btnExitGauntlet');
      if (btnExit) {
        btnExit.addEventListener('click', () => {
          cleanup();
          audio.playTick();
          this.navigate('menu');
        });
      }

      const btnStart = this.root.querySelector('#btnGauntletStart');
      if (btnStart) {
        btnStart.addEventListener('click', () => {
          audio.playTick();
          startGauntlet();
        });
      }

      const btnDone = this.root.querySelector('#btnGauntletDone');
      if (btnDone) {
        btnDone.addEventListener('click', () => {
          cleanup();
          audio.playTick();
          this.navigate('menu');
        });
      }

      const btnRetry = this.root.querySelector('#btnGauntletRetry');
      if (btnRetry) {
        btnRetry.addEventListener('click', () => {
          audio.playTick();
          startGauntlet();
        });
      }

      // Microgame interactive buttons
      if (step === 'miniGame') {
        if (roundIndex === 0) {
          this.root.querySelectorAll('.gauntlet-choice-btn').forEach(btn => {
            btn.addEventListener('click', () => {
              const val = Number(btn.dataset.ans);
              if (val === mathAns) passRound();
              else failRound();
            });
          });
        } else if (roundIndex === 1) {
          const btnReflex = this.root.querySelector('#btnReflexPad');
          if (btnReflex) {
            btnReflex.addEventListener('click', () => {
              if (reflexReady) passRound();
              else failRound();
            });
          }
        } else if (roundIndex === 2) {
          const btnDot = this.root.querySelector('#btnDotTarget');
          if (btnDot) {
            btnDot.addEventListener('click', () => {
              dotsHit++;
              audio.playTick();
              if (dotsHit >= targetDots) {
                passRound();
              } else {
                dotPos = { x: 30 + Math.floor(Math.random() * 100), y: 25 + Math.floor(Math.random() * 60) };
                renderGauntlet();
              }
            });
          }
        } else if (roundIndex === 3) {
          const btnDial = this.root.querySelector('#btnTurnDial');
          if (btnDial) {
            btnDial.addEventListener('click', () => {
              dialAngle = (dialAngle + 30) % 360;
              audio.playTick();
              if (Math.abs(dialAngle - targetAngle) < 15) {
                passRound();
              } else {
                renderGauntlet();
              }
            });
          }
        } else if (roundIndex === 4) {
          const btnTurbo = this.root.querySelector('#btnTurboTap');
          if (btnTurbo) {
            btnTurbo.addEventListener('click', () => {
              tapsCount++;
              audio.playTick();
              if (tapsCount >= requiredTaps) {
                passRound();
              } else {
                renderGauntlet();
              }
            });
          }
        }
      }
    };

    renderGauntlet();
  }

  renderMenu() {
    const isPro = Storage.isPro();
    const challenge = Storage.getDailyChallenge();
    const streak = Storage.getStreak();
    const isCompleted = challenge.isCompleted;
    const challengeTitle = challenge.title[this.lang] || challenge.title['en'];
    const challengeDesc = challenge.desc[this.lang] || challenge.desc['en'];

    const xp = Storage.getXP();
    const level = Storage.getLevel(xp);
    const rank = Storage.getRank(level);
    const progress = Storage.getProgressToNextLevel(xp);

    const xpRankHtml = `
      <div class="xp-rank-strip" id="btnOpenStatsStrip" title="${this.lang === 'tr' ? 'Seviye & İstatistik Detayları' : 'Level & Stats Details'}">
        <span class="xp-rank-badge">${rank.badge}</span>
        <div class="xp-rank-info">
          <div class="xp-rank-top">
            <span class="xp-rank-level">Lv.${level} • ${rank.title[this.lang] || rank.title['en']}</span>
            <span class="xp-rank-points">${xp} XP</span>
          </div>
          <div class="xp-bar-track">
            <div class="xp-bar-fill" style="width: ${Math.round(progress * 100)}%;"></div>
          </div>
        </div>
      </div>
    `;

    const gauntletBannerHtml = `
      <div class="wrist-duel-banner gauntlet-banner-theme" id="btnGauntletBanner" title="${this.lang === 'tr' ? 'Arcade Gauntlet: 5 Aşamalı Blitz Modu' : 'Arcade Gauntlet: 5-Stage Blitz Mode'}">
        <span class="duel-icon">⚡</span>
        <div class="duel-banner-body">
          <div class="duel-banner-title" style="color:#fbbf24;">${this.lang === 'tr' ? 'ARCADE GAUNTLET' : 'ARCADE GAUNTLET'}</div>
          <div class="duel-banner-subtitle">${this.lang === 'tr' ? '5 hızlı mikro raund, 3 can! Hayatta kal!' : '5 micro-blitz rounds, 3 lives! Survive!'}</div>
        </div>
      </div>
    `;

    const wristDuelHtml = `
      <div class="wrist-duel-banner" id="btnWristDuelBanner" title="${this.lang === 'tr' ? 'Bilek Düellosu: 2 Kişilik Mod' : 'Wrist Duel: 2-Player Mode'}">
        <span class="duel-icon">⚔️</span>
        <div class="duel-banner-body">
          <div class="duel-banner-title">${this.lang === 'tr' ? 'BİLEK DÜELLOSU (2P)' : 'WRIST DUEL (2-PLAYER)'}</div>
          <div class="duel-banner-subtitle">${this.lang === 'tr' ? 'Aynı saatte karşılıklı 2 kişi oyna!' : 'Play 2-player split screen on 1 watch!'}</div>
        </div>
      </div>
    `;

    const dailyQuestHtml = `
      <div class="daily-quest-card ${isCompleted ? 'completed' : ''}" id="dailyQuestBanner" data-game="${challenge.gameId}">
        <span class="daily-quest-icon">${isCompleted ? '✅' : '🔥'}</span>
        <div class="daily-quest-body">
          <div class="daily-quest-header">
            <span class="daily-quest-title">${challengeTitle}</span>
            ${streak > 0 ? `<span class="daily-quest-streak">${streak}d 🔥</span>` : ''}
          </div>
          <span class="daily-quest-desc">${isCompleted ? (this.lang === 'tr' ? 'GÖREV TAMAMLANDI!' : 'QUEST COMPLETE!') : challengeDesc}</span>
        </div>
      </div>
    `;

    let proBannerHtml = '';
    if (!isPro) {
      proBannerHtml = `
        <div class="pro-banner" id="bannerPro">
          <div class="pro-banner-left">
            <span class="pro-crown-icon">👑</span>
            <div class="pro-banner-text">
              <h4>${this.t('unlock_banner_title')}</h4>
              <p>${this.t('unlock_banner_subtitle')}</p>
            </div>
          </div>
          <span class="pro-price-tag">$2.99</span>
        </div>
      `;
    }

    // Category Filter Pills
    const filterPills = [
      { key: 'all', icon: '🔲', name: this.t('filter_all') },
      { key: 'cat_cards', icon: '🎴', name: this.t('cat_cards') },
      { key: 'cat_crown', icon: '⌚', name: this.t('cat_crown') },
      { key: 'cat_reflex', icon: '⚡', name: this.t('cat_reflex') },
      { key: 'cat_puzzle', icon: '🧩', name: this.t('cat_puzzle') }
    ];
    let filterBarHtml = '<div class="category-filter-bar">';
    filterPills.forEach(p => {
      const activeClass = this.selectedCategory === p.key ? 'active' : '';
      filterBarHtml += `<button class="cat-pill ${activeClass}" data-filter="${p.key}">${p.icon} ${p.name}</button>`;
    });
    filterBarHtml += '</div>';

    let searchBarHtml = `
      <div class="game-search-box">
        <input type="text" class="game-search-input" id="gameSearchInput" placeholder="${this.t('search_placeholder')}" value="${this.searchQuery || ''}">
      </div>
    `;

    const allCategories = [
      { key: 'cat_cards', name: this.t('cat_cards') },
      { key: 'cat_crown', name: this.t('cat_crown') },
      { key: 'cat_reflex', name: this.t('cat_reflex') },
      { key: 'cat_puzzle', name: this.t('cat_puzzle') }
    ];

    let categoriesToRender = allCategories;
    if (this.selectedCategory !== 'all') {
      categoriesToRender = allCategories.filter(c => c.key === this.selectedCategory);
    }

    let gamesHtml = '';
    let totalShown = 0;

    categoriesToRender.forEach(cat => {
      let catGames = CATALOG.filter(g => g.categoryKey === cat.key);
      if (this.searchQuery) {
        const q = this.searchQuery.toLowerCase();
        catGames = catGames.filter(g => {
          const tEn = (g.title.en || '').toLowerCase();
          const tTr = (g.title.tr || '').toLowerCase();
          return tEn.includes(q) || tTr.includes(q);
        });
      }

      if (catGames.length > 0) {
        gamesHtml += `<div class="game-category-header">${cat.name} (${catGames.length})</div>`;
        catGames.forEach(game => {
          totalShown++;
          const isDailyFree = !game.isFree && game.id === Storage.getDailyFreeProGameId();
          const isLocked = !Storage.isGameUnlocked(game);
          const best = Storage.getHighScore(game.id);
          let bestDisplay = best;
          if (game.id === 'reflextap' && best > 0) bestDisplay = `${best}ms`;
          if (game.id === 'speednumbers' && best > 0) bestDisplay = `${(best / 1000).toFixed(2)}s`;
          if (game.id === 'numberslide' && best > 0) bestDisplay = `${best} ${this.t('moves')}`;
          if (game.id === 'towerstack' && best > 0) bestDisplay = `${best} kat`;

          const title = game.title[this.lang] || game.title['en'];
          const subtitle = game.subtitle[this.lang] || game.subtitle['en'];

          gamesHtml += `
            <div class="game-card" data-game="${game.id}">
              <div class="game-icon-box" style="background: ${game.color}22; color: ${game.color}">
                ${game.icon}
              </div>
              <div class="game-info">
                <div class="game-info-top">
                  <span class="game-title">${title}</span>
                  ${isDailyFree ? `<span class="badge-daily-free">🌟 ${this.t('daily_free_tag')}</span>` : (isLocked ? '<span class="lock-icon">🔒</span>' : '')}
                </div>
                <div class="game-subtitle">${subtitle}</div>
                ${best > 0 && !isLocked ? `<div class="game-best">👑 ${this.t('best')}: ${bestDisplay}</div>` : ''}
              </div>
              <button class="game-card-info-btn" data-infoid="${game.id}" title="${this.t('how_to_play')}">❓</button>
              <span class="game-arrow">${isLocked ? '🔒' : '›'}</span>
            </div>
          `;
        });
      }
    });

    if (totalShown === 0) {
      gamesHtml = `<div style="text-align:center; padding:20px; font-size:11px; color:#94a3b8;">${this.lang === 'tr' ? 'Sonuç bulunamadı' : 'No games found'}</div>`;
    }

    this.root.innerHTML = `
      <div class="app-header">
        <div class="app-title-group">
          <span class="logo">🎮</span>
          <span class="app-title">${this.t('app_title')}</span>
        </div>
        <button class="icon-btn" id="btnOpenSettings" title="${this.t('settings')}">⚙️</button>
      </div>
      ${xpRankHtml}
      ${dailyQuestHtml}
      ${gauntletBannerHtml}
      ${wristDuelHtml}
      ${proBannerHtml}
      ${filterBarHtml}
      ${searchBarHtml}
      <div class="games-list">
        ${gamesHtml}
      </div>
    `;

    // Hook XP Stats Strip
    const statsStrip = this.root.querySelector('#btnOpenStatsStrip');
    if (statsStrip) {
      statsStrip.addEventListener('click', () => {
        audio.playTick();
        this.openStatsModal();
      });
    }

    // Hook Arcade Gauntlet Banner
    const gauntletBanner = this.root.querySelector('#btnGauntletBanner');
    if (gauntletBanner) {
      gauntletBanner.addEventListener('click', () => {
        audio.playTick();
        this.openGauntletView();
      });
    }

    // Hook 2P Wrist Duel Banner
    const duelBanner = this.root.querySelector('#btnWristDuelBanner');
    if (duelBanner) {
      duelBanner.addEventListener('click', () => {
        audio.playTick();
        this.openDuelView();
      });
    }

    // Hook Daily Quest Banner
    const dailyQuestEl = this.root.querySelector('#dailyQuestBanner');
    if (dailyQuestEl) {
      dailyQuestEl.addEventListener('click', () => {
        const gameId = dailyQuestEl.dataset.game;
        const game = CATALOG.find(g => g.id === gameId);
        if (game) {
          if (!game.isFree && !Storage.isPro()) {
            audio.playTick();
            this.navigate('paywall');
          } else {
            audio.playTick();
            this.navigate('game', game);
          }
        }
      });
    }

    // Hook filter pills
    this.root.querySelectorAll('.cat-pill').forEach(pill => {
      pill.addEventListener('click', () => {
        audio.playTick();
        this.selectedCategory = pill.dataset.filter;
        this.renderMenu();
      });
    });

    // Hook search input
    const searchInput = this.root.querySelector('#gameSearchInput');
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this.searchQuery = e.target.value.trim();
        this.renderMenu();
        const reInput = this.root.querySelector('#gameSearchInput');
        if (reInput) {
          reInput.focus();
          reInput.setSelectionRange(this.searchQuery.length, this.searchQuery.length);
        }
      });
    }

    if (!isPro && document.getElementById('bannerPro')) {
      document.getElementById('bannerPro').addEventListener('click', () => {
        audio.playTick();
        this.navigate('paywall');
      });
    }

    document.getElementById('btnOpenSettings').addEventListener('click', () => {
      audio.playTick();
      this.navigate('settings');
    });

    this.root.querySelectorAll('.game-card-info-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        audio.playTick();
        this.openHowToPlay(btn.dataset.infoid);
      });
    });

    this.root.querySelectorAll('.game-card').forEach(card => {
      card.addEventListener('click', () => {
        const gameId = card.dataset.game;
        const game = CATALOG.find(g => g.id === gameId);
        if (!Storage.isGameUnlocked(game)) {
          audio.playTick();
          this.navigate('paywall');
        } else {
          Storage.unlockTrophy('first_game');
          audio.playTick();
          this.navigate('game', game);
        }
      });
    });
  }

  renderPaywall() {
    this.root.innerHTML = `
      <div class="sheet-modal">
        <button class="sheet-close" id="btnCloseSheet">✕</button>
        <div class="paywall-content">
          <div class="paywall-crown-big">👑</div>
          <div class="paywall-title">${this.t('paywall_title')}</div>
          <p class="paywall-desc">${this.t('paywall_desc')}</p>
          <ul class="paywall-features">
            <li>🎴 ${this.t('paywall_feat1')}</li>
            <li>⌚ ${this.t('paywall_feat2')}</li>
            <li>✨ ${this.t('paywall_feat3')}</li>
          </ul>
          <button class="paywall-buy-btn" id="btnPaywallBuy">${this.t('paywall_buy')}</button>
          <button class="paywall-restore-btn" id="btnPaywallRestore">${this.t('restore_purchases')}</button>
        </div>
      </div>
    `;

    document.getElementById('btnCloseSheet').addEventListener('click', () => {
      audio.playTick();
      this.navigate('menu');
    });
    document.getElementById('btnPaywallBuy').addEventListener('click', () => {
      Storage.setPro(true);
      audio.playVictory();
      this.navigate('menu');
    });
    document.getElementById('btnPaywallRestore').addEventListener('click', () => {
      Storage.setPro(true);
      audio.playVictory();
      this.navigate('menu');
    });
  }

  renderSettings() {
    this.root.innerHTML = `
      <div class="sheet-modal">
        <button class="sheet-close" id="btnCloseSheet">✕</button>
        <div class="settings-section">
          <h4>${this.t('preferences')}</h4>
          <div class="settings-row">
            <span>🌐 ${this.t('language')}</span>
            <button class="btn-secondary" id="btnToggleLangInline" style="padding:2px 8px; font-size:10px;">${this.lang.toUpperCase()}</button>
          </div>
          <div class="settings-row">
            <span>📳 ${this.t('haptics')}</span>
            <label class="toggle-switch">
              <input type="checkbox" id="toggleHaptics" checked>
              <span class="toggle-slider"></span>
            </label>
          </div>
          <div class="settings-row">
            <span>🔊 ${this.t('sound')}</span>
            <label class="toggle-switch">
              <input type="checkbox" id="toggleAudio" ${audio.enabled ? 'checked' : ''}>
              <span class="toggle-slider"></span>
            </label>
          </div>
        </div>

        <div class="settings-section">
          <h4>${this.t('data_stats')}</h4>
          <button class="btn-secondary" id="btnResetScores" style="width:100%; color:#ef4444; border-color:rgba(239,68,68,0.3)">${this.t('reset_scores')}</button>
        </div>
      </div>
    `;

    document.getElementById('btnCloseSheet').addEventListener('click', () => {
      audio.playTick();
      this.navigate('menu');
    });
    document.getElementById('btnToggleLangInline').addEventListener('click', () => {
      this.toggleLang();
      this.renderSettings();
    });
    document.getElementById('toggleAudio').addEventListener('change', (e) => {
      audio.enabled = e.target.checked;
    });
    document.getElementById('btnResetScores').addEventListener('click', () => {
      Storage.resetAll();
      audio.playTick();
      alert(this.lang === 'tr' ? 'Rekorlar sıfırlandı.' : 'High scores reset.');
    });
  }

  renderGame(game) {
    const isReflex = game.id === 'reflextap';
    const isSpeed = game.id === 'speednumbers';
    const best = Storage.getHighScore(game.id);
    let bestDisplay = best;
    if (isReflex && best > 0) bestDisplay = `${best}ms`;
    if (isSpeed && best > 0) bestDisplay = `${(best / 1000).toFixed(2)}s`;

    this.root.innerHTML = `
      <div class="game-container" id="gameBox">
        <div class="game-hud">
          <button class="icon-btn" id="btnBackToMenu" style="font-size:11px;">${this.t('back')}</button>
          <span class="hud-score" id="gameCurrentScore">0</span>
          <span class="hud-high" id="gameHighScore">👑 ${bestDisplay}</span>
          <button class="icon-btn" id="btnGameInfo" style="font-size:13px; color:var(--accent-yellow);" title="${this.t('how_to_play')}">❓</button>
        </div>
        <div class="game-canvas-container" id="gameArea"></div>
      </div>
    `;

    document.getElementById('btnBackToMenu').addEventListener('click', () => {
      audio.playTick();
      this.navigate('menu');
    });

    document.getElementById('btnGameInfo').addEventListener('click', () => {
      audio.playTick();
      this.openHowToPlay(game.id);
    });

    const area = document.getElementById('gameArea');
    switch (game.id) {
      // Cards (10)
      case 'blackjack': this.activeGameInstance = new BlackjackGame(area, this); break;
      case 'videopoker': this.activeGameInstance = new VideoPokerGame(area, this); break;
      case 'microsolitaire': this.activeGameInstance = new MicroSolitaireGame(area, this); break;
      case 'cardwar': this.activeGameInstance = new CardWarGame(area, this); break;
      case 'cardpairs': this.activeGameInstance = new CardPairsGame(area, this); break;
      case 'highlow': this.activeGameInstance = new HighLowGame(area, this); break;
      case 'luckydice': this.activeGameInstance = new LuckyDiceGame(area, this); break;
      case 'luckyroulette': this.activeGameInstance = new LuckyRouletteGame(area, this); break;
      case 'baccarat': this.activeGameInstance = new BaccaratGame(area, this); break;
      case 'triplepoker': this.activeGameInstance = new TriplePokerGame(area, this); break;
      
      // Crown Arcades (10)
      case 'paddle': this.activeGameInstance = new PaddleGame(area, this); break;
      case 'snake': this.activeGameInstance = new SnakeGame(area, this); break;
      case 'safecracker': this.activeGameInstance = new SafeCrackerGame(area, this); break;
      case 'crownrunner': this.activeGameInstance = new CrownRunnerGame(area, this); break;
      case 'spaceevade': this.activeGameInstance = new SpaceEvadeGame(area, this); break;
      case 'brickcrusher': this.activeGameInstance = new BrickCrusherGame(area, this); break;
      case 'galaxydefender': this.activeGameInstance = new GalaxyDefenderGame(area, this); break;
      case 'deepreel': this.activeGameInstance = new DeepSeaReelGame(area, this); break;
      case 'crownmaze': this.activeGameInstance = new CrownMazeGame(area, this); break;
      case 'subdive': this.activeGameInstance = new SubDiveGame(area, this); break;
      
      // Speed & Reflex (10)
      case 'speednumbers': this.activeGameInstance = new SpeedNumbersGame(area, this); break;
      case 'wingflap': this.activeGameInstance = new WingFlapGame(area, this); break;
      case 'reflextap': this.activeGameInstance = new ReflexTapGame(area, this); break;
      case 'whackmole': this.activeGameInstance = new WhackDotGame(area, this); break;
      case 'colormemory': this.activeGameInstance = new ColorMemoryGame(area, this); break;
      case 'mathblitz': this.activeGameInstance = new MathBlitzGame(area, this); break;
      case 'towerstack': this.activeGameInstance = new TowerStackGame(area, this); break;
      case 'highwayracer': this.activeGameInstance = new HighwayRacerGame(area, this); break;
      case 'neonbeat': this.activeGameInstance = new NeonBeatGame(area, this); break;
      case 'quickdraw': this.activeGameInstance = new QuickdrawGame(area, this); break;
      
      // Puzzle & Strategy (10)
      case 'merge2048': this.activeGameInstance = new Merge2048Game(area, this); break;
      case 'numberslide': this.activeGameInstance = new NumberSlideGame(area, this); break;
      case 'wordguess': this.activeGameInstance = new WordGuessGame(area, this); break;
      case 'blockfall': this.activeGameInstance = new ColorBlocksGame(area, this); break;
      case 'mines': this.activeGameInstance = new MinesGame(area, this); break;
      case 'tictactoe': this.activeGameInstance = new TicTacToeGame(area, this); break;
      case 'memorymatrix': this.activeGameInstance = new MemoryMatrixGame(area, this); break;
      case 'bullseyearchery': this.activeGameInstance = new BullseyeArcheryGame(area, this); break;
      case 'pipeconnect': this.activeGameInstance = new PipeConnectGame(area, this); break;
      case 'lasermirror': this.activeGameInstance = new LaserMirrorGame(area, this); break;
      
      // New Expansion Games (10)
      case 'pisti': this.activeGameInstance = new PistiGame(area, this); break;
      case 'klondikesolitaire': this.activeGameInstance = new KlondikeGame(area, this); break;
      case 'mazemuncher': this.activeGameInstance = new MazeMuncherGame(area, this); break;
      case 'chess': this.activeGameInstance = new ChessGame(area, this); break;
      case 'checkers': this.activeGameInstance = new CheckersGame(area, this); break;
      case 'slidingblocks': this.activeGameInstance = new SlidingBlocksGame(area, this); break;
      case 'airhockey': this.activeGameInstance = new AirHockeyGame(area, this); break;
      case 'hangman': this.activeGameInstance = new HangmanGame(area, this); break;
      case 'minisudoku': this.activeGameInstance = new MiniSudokuGame(area, this); break;
      case 'lunarlander': this.activeGameInstance = new LunarLanderGame(area, this); break;
      case 'ninemensmorris': this.activeGameInstance = new NineMenMorrisGame(area, this); break;
      case 'seabattle': this.activeGameInstance = new SeaBattleGame(area, this); break;
      case 'reversi': this.activeGameInstance = new ReversiGame(area, this); break;
      case 'word5': this.activeGameInstance = new WordMasterGame(area, this); break;
      case 'darts': this.activeGameInstance = new PrecisionDartsGame(area, this); break;
      case 'microcircuit': this.activeGameInstance = new MicroCircuitGame(area, this); break;
      case 'bombdefusal': this.activeGameInstance = new BombDefusalGame(area, this); break;
      case 'target24': this.activeGameInstance = new Target24Game(area, this); break;
      case 'tabletennis': this.activeGameInstance = new TableTennisGame(area, this); break;
      case 'duel21': this.activeGameInstance = new Duel21Game(area, this); break;
    }
  }
}

class MicroSolitaireGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">♠️</div>
        <h3>MICRO SOLITAIRE</h3>
        <p>Tap cards ±1 rank from waste card to clear board</p>
        <button class="play-btn" id="startSolitaireBtn" style="background:var(--accent-cyan)">START</button>
      </div>
    `;
    this.container.querySelector('#startSolitaireBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    const ranks = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
    const suits = ['♠', '♥', '♦', '♣'];
    let fullDeck = [];
    suits.forEach(s => {
      ranks.forEach((r, val) => {
        fullDeck.push({ rank: r, suit: s, val: val + 1, isRed: (s === '♥' || s === '♦'), removed: false });
      });
    });
    fullDeck.sort(() => Math.random() - 0.5);

    this.tableau = fullDeck.slice(0, 9);
    this.waste = fullDeck[9];
    this.stock = fullDeck.slice(10);
    this.cleared = 0;
    this.render();
  }

  render() {
    let tHtml = this.tableau.map((c, i) => {
      if (c.removed) {
        return `<div class="playing-card" style="opacity:0.1; border:1px dashed #fff; background:none;"></div>`;
      }
      return `
        <div class="playing-card ${c.isRed ? 'red' : 'black'}" data-idx="${i}">
          <span class="card-rank">${c.rank}</span>
          <span class="card-suit">${c.suit}</span>
        </div>
      `;
    }).join('');

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; gap:8px;">
        <div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:6px;">
          ${tHtml}
        </div>
        <div style="display:flex; gap:16px; align-items:center; margin-top:4px;">
          <div class="playing-card card-back" id="stockPile" style="cursor:pointer;">
            ${this.stock.length}
          </div>
          <span style="font-size:11px; color:var(--text-muted)">➔</span>
          <div class="playing-card ${this.waste.isRed ? 'red' : 'black'}" style="transform:scale(1.15)">
            <span class="card-rank">${this.waste.rank}</span>
            <span class="card-suit">${this.waste.suit}</span>
          </div>
        </div>
      </div>
    `;

    this.container.querySelectorAll('.playing-card[data-idx]').forEach(el => {
      el.addEventListener('click', () => {
        const idx = parseInt(el.dataset.idx, 10);
        this.cardClick(idx);
      });
    });

    const stockEl = this.container.querySelector('#stockPile');
    if (stockEl) {
      stockEl.addEventListener('click', () => this.drawStock());
    }
  }

  cardClick(idx) {
    const card = this.tableau[idx];
    if (card.removed) return;
    const diff = Math.abs(card.val - this.waste.val);
    const isMatch = (diff === 1) || (card.val === 1 && this.waste.val === 13) || (card.val === 13 && this.waste.val === 1);

    if (isMatch) {
      card.removed = true;
      this.waste = card;
      this.cleared++;
      document.getElementById('gameCurrentScore').textContent = this.cleared;
      audio.playScore();

      if (this.cleared === 9) {
        audio.playVictory();
        Storage.recordScore('microsolitaire', 9);
        this.container.innerHTML = `
          <div class="game-screen-center">
            <h3 style="color:var(--accent-green)">BOARD CLEARED!</h3>
            <p>Score: 9/9</p>
            <button class="play-btn" id="retrySolitaireBtn">PLAY AGAIN</button>
          </div>
        `;
        this.container.querySelector('#retrySolitaireBtn').addEventListener('click', () => this.startGame());
        return;
      }
      this.render();
    } else {
      audio.playTick(200);
    }
  }

  drawStock() {
    if (this.stock.length === 0) return;
    this.waste = this.stock.pop();
    audio.playTick();
    this.render();
  }

  destroy() {}
}

// -------------------------------------------------------------
// GAME: SAFE CRACKER (CROWN HAPTIC DIAL)
// -------------------------------------------------------------
class SafeCrackerGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.dial = 0;
    this.safes = 0;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🔐</div>
        <h3>SAFE CRACKER</h3>
        <p>Turn Digital Crown to feel dial clicks and crack the 3 locks</p>
        <button class="play-btn" id="startCrackBtn" style="background:var(--accent-yellow); color:#000">CRACK</button>
      </div>
    `;
    this.container.querySelector('#startCrackBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.targets = [
      Math.floor(Math.random() * 25) + 10,
      Math.floor(Math.random() * 25) + 40,
      Math.floor(Math.random() * 25) + 70
    ];
    this.targetIdx = 0;
    this.timeLeft = 30;
    this.dial = 0;
    this.running = true;
    this.render();

    this.timer = setInterval(() => {
      this.timeLeft--;
      const timeEl = this.container.querySelector('#safeTime');
      if (timeEl) timeEl.textContent = `${this.timeLeft}s`;
      if (this.timeLeft <= 0) {
        clearInterval(this.timer);
        this.running = false;
        audio.playGameOver();
        this.container.innerHTML = `
          <div class="game-screen-center">
            <h3 style="color:var(--accent-red)">TIME UP!</h3>
            <p>Vaults opened: ${this.safes}</p>
            <button class="play-btn" id="retryCrackBtn" style="background:var(--accent-yellow); color:#000">RETRY</button>
          </div>
        `;
        this.container.querySelector('#retryCrackBtn').addEventListener('click', () => this.startGame());
      }
    }, 1000);
  }

  onCrown(delta) {
    if (!this.running) return;
    this.dial = (this.dial + delta * 2 + 100) % 100;
    this.checkDial();
    this.renderDialOnly();
  }

  checkDial() {
    if (this.targetIdx >= 3) return;
    const target = this.targets[this.targetIdx];
    const diff = Math.abs(this.dial - target);

    if (diff <= 1) {
      this.targetIdx++;
      audio.playScore();
      if (this.targetIdx === 3) {
        clearInterval(this.timer);
        this.safes++;
        Storage.recordScore('safecracker', this.safes);
        audio.playVictory();
        this.container.innerHTML = `
          <div class="game-screen-center">
            <h3 style="color:var(--accent-yellow)">VAULT CRACKED!</h3>
            <p>Total Safes: ${this.safes}</p>
            <button class="play-btn" id="nextVaultBtn" style="background:var(--accent-yellow); color:#000">NEXT VAULT</button>
          </div>
        `;
        this.container.querySelector('#nextVaultBtn').addEventListener('click', () => this.startGame());
      }
    } else if (diff <= 4) {
      audio.playTick(800); // high tick near combination
    }
  }

  render() {
    let locksHtml = [0,1,2].map(i => `<span style="color:${i < this.targetIdx ? 'var(--accent-green)' : '#666'}">${i < this.targetIdx ? '🔓' : '🔒'}</span>`).join('');
    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; gap:8px;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:700;">
          <span id="safeTime" style="color:var(--accent-yellow)">${this.timeLeft}s</span>
          <div>${locksHtml}</div>
        </div>
        <div class="safe-dial-box" id="safeDialBox">
          <div class="safe-indicator-pin"></div>
          <div class="safe-number-display" id="safeNumDisplay">${Math.floor(this.dial)}</div>
        </div>
        <span style="font-size:8px; color:var(--text-muted)">Turn Crown to feel combination</span>
      </div>
    `;
  }

  renderDialOnly() {
    const numEl = this.container.querySelector('#safeNumDisplay');
    if (numEl) numEl.textContent = Math.floor(this.dial);
  }

  destroy() {
    clearInterval(this.timer);
  }
}

// -------------------------------------------------------------
// GAME: CROWN RUNNER
// -------------------------------------------------------------
class CrownRunnerGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.canvas = document.createElement('canvas');
    this.canvas.width = 240;
    this.canvas.height = 240;
    this.canvas.id = 'runnerCanvas';
    this.ctx = this.canvas.getContext('2d');
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🏃</div>
        <h3>CROWN RUNNER</h3>
        <p>Turn Crown or tap screen to jump over obstacles</p>
        <button class="play-btn" id="startRunnerBtn" style="background:var(--accent-orange)">RUN</button>
      </div>
    `;
    this.container.querySelector('#startRunnerBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.container.innerHTML = '';
    this.container.appendChild(this.canvas);
    this.score = 0;
    this.obstacles = [];
    this.playerY = 0;
    this.playerVy = 0;
    this.isGrounded = true;
    this.tick = 0;
    this.running = true;

    this.canvas.addEventListener('click', () => this.jump());
    this.loop();
  }

  onCrown() {
    this.jump();
  }

  jump() {
    if (!this.running || !this.isGrounded) return;
    this.playerVy = 8.0;
    this.isGrounded = false;
    audio.playTick();
  }

  loop() {
    if (!this.running) return;
    this.update();
    this.draw();
    this.animId = requestAnimationFrame(() => this.loop());
  }

  update() {
    this.score++;
    this.tick++;
    document.getElementById('gameCurrentScore').textContent = `${this.score}m`;

    this.playerY += this.playerVy;
    this.playerVy -= 0.55;
    if (this.playerY <= 0) {
      this.playerY = 0;
      this.playerVy = 0;
      this.isGrounded = true;
    }

    if (this.tick % 45 === 0) {
      this.obstacles.push({ x: this.canvas.width + 20, w: 12, h: Math.random() * 10 + 16 });
    }

    const groundY = this.canvas.height - 30;
    const playerBox = { x: 30, y: groundY - 18 - this.playerY, w: 14, h: 18 };

    let nextObs = [];
    for (let obs of this.obstacles) {
      obs.x -= 3.2;
      const obsBox = { x: obs.x, y: groundY - obs.h, w: obs.w, h: obs.h };

      // Collision
      if (playerBox.x < obsBox.x + obsBox.w && playerBox.x + playerBox.w > obsBox.x &&
          playerBox.y < obsBox.y + obsBox.h && playerBox.y + playerBox.h > obsBox.y) {
        this.gameOver();
        return;
      }

      if (obs.x > -20) nextObs.push(obs);
    }
    this.obstacles = nextObs;
  }

  draw() {
    this.ctx.fillStyle = '#000000';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    const groundY = this.canvas.height - 30;
    this.ctx.strokeStyle = '#f97316';
    this.ctx.lineWidth = 2;
    this.ctx.beginPath();
    this.ctx.moveTo(0, groundY);
    this.ctx.lineTo(this.canvas.width, groundY);
    this.ctx.stroke();

    // Obstacles
    this.ctx.fillStyle = '#ef4444';
    for (let obs of this.obstacles) {
      this.ctx.fillRect(obs.x, groundY - obs.h, obs.w, obs.h);
    }

    // Runner
    this.ctx.fillStyle = '#f97316';
    this.ctx.fillRect(30, groundY - 18 - this.playerY, 14, 18);
  }

  gameOver() {
    this.running = false;
    audio.playGameOver();
    Storage.recordScore('crownrunner', this.score);
    this.container.innerHTML = `
      <div class="game-screen-center">
        <h3 style="color:var(--accent-red)">COLLISION!</h3>
        <p>Distance: ${this.score}m</p>
        <button class="play-btn" id="retryRunnerBtn" style="background:var(--accent-orange)">RUN AGAIN</button>
      </div>
    `;
    this.container.querySelector('#retryRunnerBtn').addEventListener('click', () => this.startGame());
  }

  destroy() {
    this.running = false;
    cancelAnimationFrame(this.animId);
  }
}

// -------------------------------------------------------------
// GAME: WING FLAP
// -------------------------------------------------------------
class WingFlapGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.canvas = document.createElement('canvas');
    this.canvas.width = 240;
    this.canvas.height = 240;
    this.canvas.id = 'flapCanvas';
    this.ctx = this.canvas.getContext('2d');
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🕊️</div>
        <h3>WING FLAP</h3>
        <p>Tap screen to flap wings and glide through pillars</p>
        <button class="play-btn" id="startFlapBtn" style="background:var(--accent-green)">FLY</button>
      </div>
    `;
    this.container.querySelector('#startFlapBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.container.innerHTML = '';
    this.container.appendChild(this.canvas);
    this.score = 0;
    this.birdY = this.canvas.height / 2;
    this.birdVy = 0;
    this.pipes = [];
    this.tick = 0;
    this.running = true;

    this.canvas.addEventListener('click', () => this.flap());
    this.loop();
  }

  onCrown() { this.flap(); }

  flap() {
    if (!this.running) return;
    this.birdVy = -5.0;
    audio.playTick(500);
  }

  loop() {
    if (!this.running) return;
    this.update();
    this.draw();
    this.animId = requestAnimationFrame(() => this.loop());
  }

  update() {
    this.birdY += this.birdVy;
    this.birdVy += 0.35;
    this.tick++;

    if (this.birdY < 8 || this.birdY > this.canvas.height - 8) {
      this.gameOver();
      return;
    }

    if (this.tick % 50 === 0) {
      this.pipes.push({ x: this.canvas.width + 20, gapY: Math.random() * 120 + 60, passed: false });
    }

    const gap = 58;
    const pipeW = 18;
    let nextPipes = [];

    for (let p of this.pipes) {
      p.x -= 2.2;

      // Check collision
      if (40 > p.x - 7 && 40 < p.x + pipeW + 7) {
        if (this.birdY < p.gapY - gap / 2 || this.birdY > p.gapY + gap / 2) {
          this.gameOver();
          return;
        }
      }

      if (!p.passed && p.x < 40) {
        p.passed = true;
        this.score++;
        document.getElementById('gameCurrentScore').textContent = this.score;
        audio.playScore();
      }

      if (p.x > -30) nextPipes.push(p);
    }
    this.pipes = nextPipes;
  }

  draw() {
    this.ctx.fillStyle = '#000000';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

    const gap = 58;
    const pipeW = 18;
    this.ctx.fillStyle = '#10b981';

    for (let p of this.pipes) {
      // Top
      this.ctx.fillRect(p.x, 0, pipeW, p.gapY - gap / 2);
      // Bottom
      this.ctx.fillRect(p.x, p.gapY + gap / 2, pipeW, this.canvas.height - (p.gapY + gap / 2));
    }

    // Bird
    this.ctx.fillStyle = '#eab308';
    this.ctx.beginPath();
    this.ctx.arc(40, this.birdY, 7, 0, Math.PI * 2);
    this.ctx.fill();
  }

  gameOver() {
    this.running = false;
    audio.playGameOver();
    Storage.recordScore('wingflap', this.score);
    this.container.innerHTML = `
      <div class="game-screen-center">
        <h3 style="color:var(--accent-red)">GAME OVER</h3>
        <p>Score: ${this.score}</p>
        <button class="play-btn" id="retryFlapBtn" style="background:var(--accent-green)">FLAP AGAIN</button>
      </div>
    `;
    this.container.querySelector('#retryFlapBtn').addEventListener('click', () => this.startGame());
  }

  destroy() {
    this.running = false;
    cancelAnimationFrame(this.animId);
  }
}

// -------------------------------------------------------------
// GAME: WHACK-A-DOT
// -------------------------------------------------------------
class WhackDotGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🎯</div>
        <h3>WHACK-A-DOT</h3>
        <p>Tap glowing red dots as fast as you can</p>
        <button class="play-btn" id="startWhackBtn" style="background:var(--accent-red)">START</button>
      </div>
    `;
    this.container.querySelector('#startWhackBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.score = 0;
    this.timeLeft = 25;
    this.activeHole = Math.floor(Math.random() * 9);
    this.render();

    this.timer = setInterval(() => {
      this.timeLeft--;
      const tEl = this.container.querySelector('#whackTime');
      if (tEl) tEl.textContent = `⏳ ${this.timeLeft}s`;
      if (this.timeLeft <= 0) {
        clearInterval(this.timer);
        clearInterval(this.holeInterval);
        audio.playGameOver();
        Storage.recordScore('whackmole', this.score);
        this.container.innerHTML = `
          <div class="game-screen-center">
            <h3 style="color:var(--accent-red)">TIME UP!</h3>
            <p>Score: ${this.score}</p>
            <button class="play-btn" id="retryWhackBtn" style="background:var(--accent-red)">AGAIN</button>
          </div>
        `;
        this.container.querySelector('#retryWhackBtn').addEventListener('click', () => this.startGame());
      }
    }, 1000);

    this.holeInterval = setInterval(() => {
      this.activeHole = Math.floor(Math.random() * 9);
      this.renderGridOnly();
    }, 750);
  }

  render() {
    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; gap:6px;">
        <div style="display:flex; justify-content:space-between; font-size:10px; font-weight:700;">
          <span style="color:var(--accent-red)">SCORE: <strong id="whackScore">${this.score}</strong></span>
          <span id="whackTime">⏳ ${this.timeLeft}s</span>
        </div>
        <div class="whack-grid" id="whackGridBox"></div>
      </div>
    `;
    this.renderGridOnly();
  }

  renderGridOnly() {
    const box = this.container.querySelector('#whackGridBox');
    if (!box) return;
    let holesHtml = [0,1,2,3,4,5,6,7,8].map(i => {
      return `<div class="whack-hole" data-idx="${i}">
        ${i === this.activeHole ? '<div class="whack-target"></div>' : ''}
      </div>`;
    }).join('');
    box.innerHTML = holesHtml;

    box.querySelectorAll('.whack-hole').forEach(el => {
      el.addEventListener('click', () => {
        const idx = parseInt(el.dataset.idx, 10);
        if (idx === this.activeHole) {
          this.score++;
          this.activeHole = null;
          audio.playScore();
          const sEl = this.container.querySelector('#whackScore');
          if (sEl) sEl.textContent = this.score;
          document.getElementById('gameCurrentScore').textContent = this.score;
          this.renderGridOnly();
        }
      });
    });
  }

  destroy() {
    clearInterval(this.timer);
    clearInterval(this.holeInterval);
  }
}

// -------------------------------------------------------------
// GAME: MATH BLITZ
// -------------------------------------------------------------
class MathBlitzGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">➕</div>
        <h3>MATH BLITZ</h3>
        <p>Is the equation True or False? 3s per round!</p>
        <button class="play-btn" id="startMathBtn" style="background:var(--accent-blue)">START</button>
      </div>
    `;
    this.container.querySelector('#startMathBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.score = 0;
    this.nextRound();
  }

  nextRound() {
    clearInterval(this.roundTimer);
    this.timeLeftMs = 3000;
    const a = Math.floor(Math.random() * 11) + 2;
    const b = Math.floor(Math.random() * 11) + 2;
    const isAdd = Math.random() < 0.5;
    const realAns = isAdd ? (a + b) : (a * b);
    this.isCorrect = Math.random() < 0.5;
    const shownAns = this.isCorrect ? realAns : (realAns + [-2, -1, 1, 2][Math.floor(Math.random() * 4)]);

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; gap:8px;">
        <div class="math-timer-bar"><div class="math-timer-fill" id="mathTimerFill" style="width:100%"></div></div>
        <div style="font-size:22px; font-weight:900; font-family:'JetBrains Mono'">${a} ${isAdd ? '+' : '×'} ${b} = ${shownAns}</div>
        <div style="display:flex; gap:8px; width:100%; margin-top:8px;">
          <button class="play-btn" id="btnTrue" style="flex:1; background:var(--accent-green); color:#000">✓ TRUE</button>
          <button class="play-btn" id="btnFalse" style="flex:1; background:var(--accent-red); color:#fff">✗ FALSE</button>
        </div>
      </div>
    `;

    this.container.querySelector('#btnTrue').addEventListener('click', () => this.answer(true));
    this.container.querySelector('#btnFalse').addEventListener('click', () => this.answer(false));

    this.roundTimer = setInterval(() => {
      this.timeLeftMs -= 50;
      const fill = this.container.querySelector('#mathTimerFill');
      if (fill) fill.style.width = `${(this.timeLeftMs / 3000) * 100}%`;
      if (this.timeLeftMs <= 0) {
        this.gameOver();
      }
    }, 50);
  }

  answer(guess) {
    if (guess === this.isCorrect) {
      this.score++;
      document.getElementById('gameCurrentScore').textContent = this.score;
      audio.playScore();
      this.nextRound();
    } else {
      this.gameOver();
    }
  }

  gameOver() {
    clearInterval(this.roundTimer);
    audio.playGameOver();
    Storage.recordScore('mathblitz', this.score);
    this.container.innerHTML = `
      <div class="game-screen-center">
        <h3 style="color:var(--accent-red)">WRONG!</h3>
        <p>Streak: ${this.score}</p>
        <button class="play-btn" id="retryMathBtn" style="background:var(--accent-blue)">RETRY</button>
      </div>
    `;
    this.container.querySelector('#retryMathBtn').addEventListener('click', () => this.startGame());
  }

  destroy() {
    clearInterval(this.roundTimer);
  }
}

// -------------------------------------------------------------
// GAME: WORD GUESS (4-LETTER WORDLE)
// -------------------------------------------------------------
class WordGuessGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.words = ['STAR', 'GAME', 'TIME', 'PLAY', 'GOLD', 'FIRE', 'WIND', 'MOON', 'LION', 'BEAR', 'COOL'];
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🔤</div>
        <h3>WORD GUESS</h3>
        <p>Guess the hidden 4-letter word in 4 tries</p>
        <button class="play-btn" id="startWordBtn" style="background:var(--accent-green)">START</button>
      </div>
    `;
    this.container.querySelector('#startWordBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.secret = this.words[Math.floor(Math.random() * this.words.length)];
    this.rows = [];
    this.currentGuess = '';
    this.render();
  }

  render() {
    let rowsHtml = '';
    for (let r = 0; r < 4; r++) {
      let tilesHtml = '';
      for (let c = 0; c < 4; c++) {
        let char = '';
        let cls = 'word-guess-tile';
        if (r < this.rows.length) {
          char = this.rows[r].guess[c];
          cls += ' ' + this.rows[r].states[c];
        } else if (r === this.rows.length && c < this.currentGuess.length) {
          char = this.currentGuess[c];
        }
        tilesHtml += `<div class="${cls}">${char}</div>`;
      }
      rowsHtml += `<div class="word-guess-row">${tilesHtml}</div>`;
    }

    const kbRows = ['ABCDEFGHIJ', 'KLMNOPQRST', 'UVWXYZ'];
    let kbHtml = kbRows.map((rowStr, ri) => {
      let keys = Array.from(rowStr).map(k => `<button class="kb-key" data-k="${k}">${k}</button>`).join('');
      if (ri === 2) {
        keys += `<button class="kb-key" id="kbDel" style="background:#ef4444">⌫</button>`;
        keys += `<button class="kb-key" id="kbGo" style="background:#10b981; color:#000">GO</button>`;
      }
      return `<div class="mini-kb-row">${keys}</div>`;
    }).join('');

    this.container.innerHTML = `
      <div class="word-guess-grid">${rowsHtml}</div>
      <div class="mini-kb">${kbHtml}</div>
    `;

    this.container.querySelectorAll('.kb-key[data-k]').forEach(b => {
      b.addEventListener('click', () => {
        if (this.currentGuess.length < 4) {
          this.currentGuess += b.dataset.k;
          audio.playTick();
          this.render();
        }
      });
    });

    const delBtn = this.container.querySelector('#kbDel');
    if (delBtn) delBtn.addEventListener('click', () => {
      this.currentGuess = this.currentGuess.slice(0, -1);
      audio.playTick();
      this.render();
    });

    const goBtn = this.container.querySelector('#kbGo');
    if (goBtn) goBtn.addEventListener('click', () => this.submitGuess());
  }

  submitGuess() {
    if (this.currentGuess.length !== 4) return;
    let states = [];
    for (let i = 0; i < 4; i++) {
      if (this.currentGuess[i] === this.secret[i]) states.push('correct');
      else if (this.secret.includes(this.currentGuess[i])) states.push('wrong-spot');
      else states.push('not-in-word');
    }

    this.rows.push({ guess: this.currentGuess, states });

    if (this.currentGuess === this.secret) {
      audio.playVictory();
      Storage.recordScore('wordguess', 1);
      this.container.innerHTML = `
        <div class="game-screen-center">
          <h3 style="color:var(--accent-green)">WORD CRACKED!</h3>
          <p>Word: ${this.secret}</p>
          <button class="play-btn" id="retryWordBtn" style="background:var(--accent-green)">AGAIN</button>
        </div>
      `;
      this.container.querySelector('#retryWordBtn').addEventListener('click', () => this.startGame());
      return;
    }

    if (this.rows.length >= 4) {
      audio.playGameOver();
      this.container.innerHTML = `
        <div class="game-screen-center">
          <h3 style="color:var(--accent-red)">OUT OF GUESSES</h3>
          <p>Word was: ${this.secret}</p>
          <button class="play-btn" id="retryWordBtn" style="background:var(--accent-green)">AGAIN</button>
        </div>
      `;
      this.container.querySelector('#retryWordBtn').addEventListener('click', () => this.startGame());
      return;
    }

    this.currentGuess = '';
    audio.playBounce();
    this.render();
  }

  destroy() {}
}

// -------------------------------------------------------------
// GAME: COLOR BLOCKS (FALLING MATCH-3)
// -------------------------------------------------------------
class ColorBlocksGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🧱</div>
        <h3>COLOR BLOCKS</h3>
        <p>Turn Crown to move falling block. Match 3 colors!</p>
        <button class="play-btn" id="startCBBtn" style="background:var(--accent-pink)">START</button>
      </div>
    `;
    this.container.querySelector('#startCBBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.cols = 5;
    this.rows = 8;
    this.grid = Array(this.rows).fill(0).map(() => Array(this.cols).fill(null));
    this.score = 0;
    this.activeCol = 2;
    this.activeRow = 0;
    this.colors = ['#ef4444', '#10b981', '#3b82f6', '#eab308'];
    this.activeColor = this.colors[Math.floor(Math.random() * 4)];
    this.running = true;

    this.container.addEventListener('click', () => this.dropStep());
    this.render();

    this.timer = setInterval(() => {
      if (this.running) this.dropStep();
    }, 450);
  }

  onCrown(delta) {
    if (!this.running) return;
    this.activeCol = Math.max(0, Math.min(this.cols - 1, this.activeCol + delta));
    this.render();
  }

  dropStep() {
    if (this.activeRow + 1 < this.rows && this.grid[this.activeRow + 1][this.activeCol] === null) {
      this.activeRow++;
    } else {
      this.grid[this.activeRow][this.activeCol] = this.activeColor;
      audio.playBounce();
      this.checkMatches();

      this.activeRow = 0;
      this.activeColor = this.colors[Math.floor(Math.random() * 4)];

      if (this.grid[0][this.activeCol] !== null) {
        this.running = false;
        clearInterval(this.timer);
        audio.playGameOver();
        Storage.recordScore('blockfall', this.score);
        this.container.innerHTML = `
          <div class="game-screen-center">
            <h3 style="color:var(--accent-red)">GRID FULL!</h3>
            <p>Score: ${this.score}</p>
            <button class="play-btn" id="retryCBBtn" style="background:var(--accent-pink)">PLAY AGAIN</button>
          </div>
        `;
        this.container.querySelector('#retryCBBtn').addEventListener('click', () => this.startGame());
        return;
      }
    }
    this.render();
  }

  checkMatches() {
    let toClear = [];
    for (let r = 0; r < this.rows; r++) {
      for (let c = 0; c < this.cols - 2; c++) {
        let col = this.grid[r][c];
        if (col && this.grid[r][c+1] === col && this.grid[r][c+2] === col) {
          toClear.push([r, c], [r, c+1], [r, c+2]);
        }
      }
    }
    for (let c = 0; c < this.cols; c++) {
      for (let r = 0; r < this.rows - 2; r++) {
        let col = this.grid[r][c];
        if (col && this.grid[r+1][c] === col && this.grid[r+2][c] === col) {
          toClear.push([r, c], [r+1, c], [r+2, c]);
        }
      }
    }

    if (toClear.length > 0) {
      toClear.forEach(([r, c]) => { this.grid[r][c] = null; });
      this.score += toClear.length * 10;
      document.getElementById('gameCurrentScore').textContent = this.score;
      audio.playScore();
    }
  }

  render() {
    let cellsHtml = '';
    for (let r = 0; r < this.rows; r++) {
      for (let c = 0; c < this.cols; c++) {
        let isFalling = (r === this.activeRow && c === this.activeCol);
        let bg = isFalling ? this.activeColor : (this.grid[r][c] || 'rgba(255,255,255,0.06)');
        cellsHtml += `<div class="bf-cell" style="background:${bg}"></div>`;
      }
    }
    this.container.innerHTML = `<div class="blockfall-grid">${cellsHtml}</div>`;
  }

  destroy() {
    clearInterval(this.timer);
  }
}

// -------------------------------------------------------------
// EXISTING GAMES (PADDLE, SNAKE, 2048, BRICK, COLOR MEMORY, MINES, TIC-TAC-TOE, BLACKJACK, PAIRS, HIGH-LOW, SPACE, REFLEX)
// -------------------------------------------------------------
class BlackjackGame {
  constructor(container, app) {
    this.container = container; this.app = app; this.winStreak = 0;
    this.credits = 100; this.betAmount = 10; this.activeBet = 10; this.isDoubleActive = false;
    this.showStartScreen();
  }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">♣️</div>
        <h3 style="margin-bottom:2px">CLASSIC 21</h3>
        <div style="font-size:11px; color:#eab308; font-weight:bold; margin-bottom:4px">🪙 Bank: 100 Credits</div>
        <p style="font-size:9px; color:#94a3b8; margin-bottom:8px">2X Double Down • Dealer 17+ • 3:2 BJ</p>
        <button class="play-btn" id="start21Btn" style="background:var(--accent-teal); font-weight:bold">DEAL (10 🪙)</button>
      </div>`;
    this.container.querySelector('#start21Btn').addEventListener('click', () => {
      audio.playTick(); this.startRound();
    });
  }
  buildDeck() {
    const ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
    const suits = ['♠', '♥', '♦', '♣'];
    this.deck = [];
    for (let s of suits) {
      for (let r of ranks) {
        let v = (r === 'A') ? 11 : (['J','Q','K'].includes(r) ? 10 : parseInt(r, 10));
        this.deck.push({ rank: r, suit: s, value: v, isRed: (s === '♥' || s === '♦') });
      }
    }
    this.deck.sort(() => Math.random() - 0.5);
  }
  drawCard() { if (!this.deck || this.deck.length === 0) this.buildDeck(); return this.deck.pop(); }
  handTotal(hand) {
    let total = hand.reduce((sum, c) => sum + c.value, 0);
    let aces = hand.filter(c => c.rank === 'A').length;
    while (total > 21 && aces > 0) { total -= 10; aces--; }
    return total;
  }
  startRound() {
    if (this.credits <= 0) { this.credits = 100; this.betAmount = 10; }
    this.activeBet = Math.min(this.betAmount, this.credits);
    this.credits -= this.activeBet;
    this.isDoubleActive = false;
    this.buildDeck();
    audio.playCardDeal();
    this.playerHand = [this.drawCard(), this.drawCard()];
    this.dealerHand = [this.drawCard(), this.drawCard()];
    this.isPlayerTurn = true; this.outcome = null;
    
    if (this.handTotal(this.playerHand) === 21) {
      this.evaluateNatural21();
      return;
    }
    this.render();
  }
  evaluateNatural21() {
    this.isPlayerTurn = false;
    const d = this.handTotal(this.dealerHand);
    if (d === 21) {
      this.credits += this.activeBet;
      this.outcome = 'PUSH (BOTH 21)'; this.outcomeColor = 'var(--accent-yellow)';
      audio.playBounce();
    } else {
      const payout = Math.floor(this.activeBet * 2.5);
      this.credits += payout;
      this.outcome = `BLACKJACK! +${payout} 🪙`; this.outcomeColor = 'var(--accent-green)';
      this.winStreak++; audio.playVictory();
      Storage.recordScore('blackjack', this.credits);
    }
    document.getElementById('gameCurrentScore').textContent = this.credits;
    this.render();
  }
  render() {
    const dTotal = this.isPlayerTurn ? '?' : this.handTotal(this.dealerHand);
    const pTotal = this.handTotal(this.playerHand);
    let dCardsHtml = this.dealerHand.map((c, i) => (i === 1 && this.isPlayerTurn) ? `<div class="playing-card card-back">🔒</div>` : `<div class="playing-card ${c.isRed ? 'red' : 'black'}"><span class="card-rank">${c.rank}</span><span class="card-suit">${c.suit}</span></div>`).join('');
    let pCardsHtml = this.playerHand.map(c => `<div class="playing-card ${c.isRed ? 'red' : 'black'}"><span class="card-rank">${c.rank}</span><span class="card-suit">${c.suit}</span></div>`).join('');
    
    let actionSectionHtml = '';
    if (this.outcome) {
      if (this.credits <= 0) {
        actionSectionHtml = `
          <div style="text-align:center; margin-top:3px;">
            <div style="font-size:11px; font-weight:800; color:var(--accent-red); margin-bottom:2px">${this.outcome}</div>
            <button class="play-btn" id="btnReload21" style="background:#eab308; color:#000; font-weight:bold">RELOAD 100 🪙</button>
          </div>`;
      } else {
        actionSectionHtml = `
          <div style="text-align:center; margin-top:3px;">
            <div style="font-size:11px; font-weight:800; color:${this.outcomeColor}; margin-bottom:2px">${this.outcome}</div>
            <button class="play-btn" id="btnNext21" style="background:var(--accent-teal); font-weight:bold">NEXT (BET ${Math.min(this.betAmount, this.credits)} 🪙)</button>
          </div>`;
      }
    } else if (this.isPlayerTurn) {
      const canDouble = (this.playerHand.length === 2 && this.credits >= this.activeBet && !this.isDoubleActive);
      if (canDouble) {
        actionSectionHtml = `
          <div style="display:flex; gap:4px; width:100%; margin-top:3px;">
            <button class="play-btn" id="btnHit" style="flex:1; background:var(--accent-teal); font-size:10px; padding:4px 0">HIT</button>
            <button class="play-btn" id="btnStand" style="flex:1; background:rgba(255,255,255,0.2); color:#fff; font-size:10px; padding:4px 0">STAND</button>
            <button class="play-btn" id="btnDouble" style="flex:1.2; background:#f97316; color:#000; font-weight:bold; font-size:10px; padding:4px 0">2X DBL</button>
          </div>`;
      } else {
        actionSectionHtml = `
          <div style="display:flex; gap:6px; width:100%; margin-top:3px;">
            <button class="play-btn" id="btnHit" style="flex:1; background:var(--accent-teal); font-size:10px">HIT</button>
            <button class="play-btn" id="btnStand" style="flex:1; background:rgba(255,255,255,0.2); color:#fff; font-size:10px">STAND</button>
          </div>`;
      }
    }
    
    this.container.innerHTML = `
      <div class="blackjack-table" style="display:flex; flex-direction:column; justify-content:space-between; height:100%; padding:2px 0;">
        <div style="display:flex; justify-content:space-between; align-items:center; font-size:9px; font-family:monospace; padding:0 4px;">
          <span style="color:#eab308; font-weight:bold">🪙 ${this.credits}</span>
          <span style="color:${this.isDoubleActive ? '#f97316' : 'var(--accent-teal)'}; font-weight:bold">BET: ${this.activeBet}</span>
          <span style="color:#94a3b8">${this.isDoubleActive ? '🔥 2X' : 'POT: ' + (this.activeBet * 2) + '🪙'}</span>
        </div>
        
        <div class="hand-section" style="margin:1px 0">
          <div class="hand-header" style="font-size:8px"><span>DEALER</span><span>${dTotal}</span></div>
          <div class="cards-row">${dCardsHtml}</div>
        </div>
        
        <hr style="border:0; border-top:1px solid rgba(255,255,255,0.12); margin:2px 0">
        
        <div class="hand-section" style="margin:1px 0">
          <div class="hand-header" style="font-size:8px"><span>YOU</span><span style="color:var(--accent-teal)">${pTotal}</span></div>
          <div class="cards-row">${pCardsHtml}</div>
        </div>
        
        ${actionSectionHtml}
      </div>`;
      
    const hitBtn = this.container.querySelector('#btnHit'); if (hitBtn) hitBtn.addEventListener('click', () => this.hit());
    const standBtn = this.container.querySelector('#btnStand'); if (standBtn) standBtn.addEventListener('click', () => this.stand());
    const dblBtn = this.container.querySelector('#btnDouble'); if (dblBtn) dblBtn.addEventListener('click', () => this.doubleDown());
    const nextBtn = this.container.querySelector('#btnNext21'); if (nextBtn) nextBtn.addEventListener('click', () => this.startRound());
    const reloadBtn = this.container.querySelector('#btnReload21'); if (reloadBtn) reloadBtn.addEventListener('click', () => {
      this.credits = 100; this.betAmount = 10; this.startRound();
    });
  }
  hit() {
    this.playerHand.push(this.drawCard()); audio.playCardDeal();
    const total = this.handTotal(this.playerHand);
    if (total > 21) {
      this.isPlayerTurn = false; this.outcome = `BUST! -${this.activeBet} 🪙`; this.outcomeColor = 'var(--accent-red)'; this.winStreak = 0;
      document.getElementById('gameCurrentScore').textContent = this.credits; audio.playGameOver();
    } else if (total === 21) { this.stand(); return; }
    this.render();
  }
  doubleDown() {
    if (this.credits < this.activeBet || this.playerHand.length !== 2) return;
    this.credits -= this.activeBet;
    this.activeBet *= 2;
    this.isDoubleActive = true;
    this.playerHand.push(this.drawCard());
    audio.playCardDeal();
    const total = this.handTotal(this.playerHand);
    if (total > 21) {
      this.isPlayerTurn = false; this.outcome = `BUST! -${this.activeBet} 🪙`; this.outcomeColor = 'var(--accent-red)'; this.winStreak = 0;
      document.getElementById('gameCurrentScore').textContent = this.credits; audio.playGameOver();
      this.render();
    } else {
      this.stand();
    }
  }
  stand() {
    this.isPlayerTurn = false;
    while (this.handTotal(this.dealerHand) < 17) {
      this.dealerHand.push(this.drawCard());
      audio.playCardDeal();
    }
    const p = this.handTotal(this.playerHand); const d = this.handTotal(this.dealerHand);
    if (d > 21) {
      const winAmount = this.activeBet * 2;
      this.credits += winAmount;
      this.outcome = `DEALER BUSTS! +${winAmount} 🪙`; this.outcomeColor = 'var(--accent-green)'; this.winStreak++;
      Storage.recordScore('blackjack', this.credits); audio.playVictory();
    } else if (p > d) {
      const winAmount = this.activeBet * 2;
      this.credits += winAmount;
      this.outcome = `YOU WIN! +${winAmount} 🪙`; this.outcomeColor = 'var(--accent-green)'; this.winStreak++;
      Storage.recordScore('blackjack', this.credits); audio.playVictory();
    } else if (p < d) {
      this.outcome = `DEALER WINS -${this.activeBet} 🪙`; this.outcomeColor = 'var(--accent-red)'; this.winStreak = 0; audio.playGameOver();
    } else {
      this.credits += this.activeBet;
      this.outcome = 'PUSH (TIE) 🪙 RETURNED'; this.outcomeColor = 'var(--accent-yellow)'; audio.playBounce();
    }
    document.getElementById('gameCurrentScore').textContent = this.credits; this.render();
  }
  destroy() {}
}

class CardPairsGame {
  constructor(container, app) {
    this.container = container; this.app = app; this.symbols = ['♠', '♥', '♦', '♣', '⭐', '⚡'];
    this.colors = ['#ffffff', '#ef4444', '#f97316', '#06b6d4', '#eab308', '#a855f7']; this.showStartScreen();
  }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🃏</div><h3>CARD PAIRS</h3>
        <p>Flip and match all 6 card pairs</p>
        <button class="play-btn" id="startPairsBtn" style="background:var(--accent-indigo)">START</button>
      </div>`;
    this.container.querySelector('#startPairsBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.moves = 0; this.cards = [];
    for (let i = 0; i < 6; i++) {
      this.cards.push({ id: i * 2, sym: this.symbols[i], color: this.colors[i], faceUp: false, matched: false });
      this.cards.push({ id: i * 2 + 1, sym: this.symbols[i], color: this.colors[i], faceUp: false, matched: false });
    }
    this.cards.sort(() => Math.random() - 0.5); this.selected = []; this.busy = false; this.render();
  }
  render() {
    let gridHtml = this.cards.map((c, i) => {
      let cls = 'memory-card-box'; let content = '?';
      if (c.matched) { cls += ' matched'; content = `<span style="color:${c.color}">${c.sym}</span>`; }
      else if (c.faceUp) { cls += ' face-up'; content = `<span style="color:${c.color}">${c.sym}</span>`; }
      return `<div class="${cls}" data-idx="${i}">${content}</div>`;
    }).join('');
    this.container.innerHTML = `<div class="card-pairs-grid">${gridHtml}</div>`;
    this.container.querySelectorAll('.memory-card-box').forEach(el => {
      el.addEventListener('click', () => { const idx = parseInt(el.dataset.idx, 10); this.cardClick(idx); });
    });
  }
  cardClick(idx) {
    if (this.busy) return; const card = this.cards[idx]; if (card.matched || card.faceUp) return;
    card.faceUp = true; this.selected.push(idx); audio.playTick(); this.render();
    if (this.selected.length === 2) {
      this.moves++; document.getElementById('gameCurrentScore').textContent = this.moves;
      const [i1, i2] = this.selected;
      if (this.cards[i1].sym === this.cards[i2].sym) {
        this.cards[i1].matched = true; this.cards[i2].matched = true; this.selected = []; audio.playScore();
        if (this.cards.every(c => c.matched)) {
          audio.playVictory(); Storage.recordScore('cardpairs', this.moves);
          setTimeout(() => {
            this.container.innerHTML = `
              <div class="game-screen-center">
                <h3 style="color:var(--accent-green)">ALL PAIRS FOUND!</h3><p>Completed in ${this.moves} moves</p>
                <button class="play-btn" id="retryPairsBtn" style="background:var(--accent-indigo)">PLAY AGAIN</button>
              </div>`;
            this.container.querySelector('#retryPairsBtn').addEventListener('click', () => this.startGame());
          }, 400);
        }
      } else {
        this.busy = true;
        setTimeout(() => { this.cards[i1].faceUp = false; this.cards[i2].faceUp = false; this.selected = []; this.busy = false; this.render(); }, 600);
      }
    }
  }
  destroy() {}
}

class HighLowGame {
  constructor(container, app) { this.container = container; this.app = app; this.streak = 0; this.showStartScreen(); }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">♥️</div><h3>HIGH-LOW</h3>
        <p>Guess if the next card will be Higher or Lower</p>
        <button class="play-btn" id="startHLBtn" style="background:var(--accent-red)">START</button>
      </div>`;
    this.container.querySelector('#startHLBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  randomCard() {
    const ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']; const suits = ['♠', '♥', '♦', '♣'];
    const r = ranks[Math.floor(Math.random() * ranks.length)]; const s = suits[Math.floor(Math.random() * suits.length)];
    const valMap = { 'J': 11, 'Q': 12, 'K': 13, 'A': 14 }; const val = valMap[r] || parseInt(r, 10);
    return { rank: r, suit: s, value: val, isRed: (s === '♥' || s === '♦') };
  }
  startGame() { this.streak = 0; this.currentCard = this.randomCard(); this.render(); }
  render() {
    const c = this.currentCard;
    this.container.innerHTML = `
      <div class="high-low-display">
        <div class="big-card ${c.isRed ? 'red' : 'black'}"><span class="big-rank">${c.rank}</span><span class="big-suit">${c.suit}</span></div>
        <div style="display:flex; gap:8px; width:100%;">
          <button class="play-btn" id="btnHigher" style="flex:1; background:var(--accent-green); color:#000">▲ HIGHER</button>
          <button class="play-btn" id="btnLower" style="flex:1; background:var(--accent-red); color:#fff">▼ LOWER</button>
        </div>
      </div>`;
    this.container.querySelector('#btnHigher').addEventListener('click', () => this.guess(true));
    this.container.querySelector('#btnLower').addEventListener('click', () => this.guess(false));
  }
  guess(isHigher) {
    let next = this.randomCard(); while (next.value === this.currentCard.value) next = this.randomCard();
    const correct = isHigher ? (next.value > this.currentCard.value) : (next.value < this.currentCard.value);
    this.currentCard = next;
    if (correct) {
      this.streak++; document.getElementById('gameCurrentScore').textContent = this.streak; audio.playScore(); this.render();
    } else {
      audio.playGameOver(); Storage.recordScore('highlow', this.streak);
      this.container.innerHTML = `
        <div class="game-screen-center">
          <h3 style="color:var(--accent-red)">WRONG GUESS!</h3><p>Streak: ${this.streak}</p>
          <button class="play-btn" id="retryHLBtn" style="background:var(--accent-red)">RETRY</button>
        </div>`;
      this.container.querySelector('#retryHLBtn').addEventListener('click', () => this.startGame());
    }
  }
  destroy() {}
}

class SpaceEvadeGame {
  constructor(container, app) {
    this.container = container; this.app = app; this.canvas = document.createElement('canvas');
    this.canvas.width = 240; this.canvas.height = 240; this.canvas.id = 'spaceCanvas'; this.ctx = this.canvas.getContext('2d'); this.showStartScreen();
  }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🚀</div><h3>SPACE EVADE</h3>
        <p>Turn Digital Crown to pilot ship & dodge meteors</p>
        <button class="play-btn" id="startSpaceBtn" style="background:var(--accent-mint); color:#000">LAUNCH</button>
      </div>`;
    this.container.querySelector('#startSpaceBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.container.innerHTML = ''; this.container.appendChild(this.canvas);
    this.score = 0; this.shipX = this.canvas.width / 2; this.hazards = []; this.tickCount = 0; this.running = true; this.loop();
  }
  onCrown(delta) { if (!this.running) return; this.shipX = Math.max(14, Math.min(this.canvas.width - 14, this.shipX + delta * 8)); }
  loop() { if (!this.running) return; this.update(); this.draw(); this.animId = requestAnimationFrame(() => this.loop()); }
  update() {
    this.tickCount++;
    if (this.tickCount % 16 === 0) {
      const isStar = Math.random() < 0.25;
      this.hazards.push({ x: Math.random() * (this.canvas.width - 24) + 12, y: -10, r: isStar ? 5 : 6, speed: Math.random() * 1.5 + 2.0, isStar });
    }
    const shipY = this.canvas.height - 18; let nextH = [];
    for (let h of this.hazards) {
      h.y += h.speed; const dist = Math.hypot(h.x - this.shipX, h.y - shipY);
      if (dist < h.r + 10) {
        if (h.isStar) { this.score += 5; document.getElementById('gameCurrentScore').textContent = this.score; audio.playScore(); continue; }
        else { this.gameOver(); return; }
      }
      if (h.y < this.canvas.height + 10) nextH.push(h);
      else if (!h.isStar) { this.score++; document.getElementById('gameCurrentScore').textContent = this.score; }
    }
    this.hazards = nextH;
  }
  draw() {
    this.ctx.fillStyle = '#000000'; this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    for (let h of this.hazards) {
      this.ctx.fillStyle = h.isStar ? '#eab308' : '#ef4444';
      this.ctx.beginPath(); this.ctx.arc(h.x, h.y, h.r, 0, Math.PI * 2); this.ctx.fill();
    }
    this.ctx.fillStyle = '#2dd4bf'; this.ctx.beginPath();
    this.ctx.moveTo(this.shipX, this.canvas.height - 26); this.ctx.lineTo(this.shipX - 10, this.canvas.height - 10);
    this.ctx.lineTo(this.shipX + 10, this.canvas.height - 10); this.ctx.closePath(); this.ctx.fill();
  }
  gameOver() {
    this.running = false; audio.playGameOver(); Storage.recordScore('spaceevade', this.score);
    this.container.innerHTML = `
      <div class="game-screen-center">
        <h3 style="color:var(--accent-red)">SHIP DESTROYED!</h3><p>Score: ${this.score}</p>
        <button class="play-btn" id="retrySpaceBtn" style="background:var(--accent-mint); color:#000">RETRY</button>
      </div>`;
    this.container.querySelector('#retrySpaceBtn').addEventListener('click', () => this.startGame());
  }
  destroy() { this.running = false; cancelAnimationFrame(this.animId); }
}

class ReflexTapGame {
  constructor(container, app) { this.container = container; this.app = app; this.showStartScreen(); }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">⚡</div><h3>REFLEX TAP</h3>
        <p>Tap as fast as possible when screen flashes GREEN</p>
        <button class="play-btn" id="startReflexBtn" style="background:var(--accent-yellow); color:#000">START</button>
      </div>`;
    this.container.querySelector('#startReflexBtn').addEventListener('click', () => this.prepareWait());
  }
  prepareWait() {
    this.state = 'waiting'; audio.playTick();
    this.container.innerHTML = `<div class="reflex-container waiting"><h3 style="font-size:16px;">WAIT FOR GREEN...</h3><p style="font-size:10px;">Don't tap yet!</p></div>`;
    const el = this.container.querySelector('.reflex-container');
    el.addEventListener('click', () => {
      if (this.state === 'waiting') {
        clearTimeout(this.waitTimer); this.state = 'early'; audio.playGameOver();
        this.container.innerHTML = `
          <div class="reflex-container early">
            <h3>TOO EARLY!</h3><p>Wait for green before tapping.</p>
            <button class="play-btn" id="retryEarlyBtn" style="background:#fff; color:#000; margin-top:8px">TRY AGAIN</button>
          </div>`;
        this.container.querySelector('#retryEarlyBtn').addEventListener('click', (e) => { e.stopPropagation(); this.prepareWait(); });
      } else if (this.state === 'ready') {
        const ms = Date.now() - this.startTime; this.state = 'result'; audio.playVictory();
        Storage.recordScore('reflextap', ms); document.getElementById('gameCurrentScore').textContent = `${ms}ms`;
        let rank = '🐢 AVERAGE'; if (ms < 200) rank = '⚡ GODLIKE!'; else if (ms < 260) rank = '🚀 LIGHTNING!'; else if (ms < 330) rank = '👍 GREAT!';
        this.container.innerHTML = `
          <div class="game-screen-center">
            <h2 style="font-size:24px; font-family:'JetBrains Mono'">${ms} ms</h2>
            <div style="font-size:12px; font-weight:800; color:var(--accent-yellow)">${rank}</div>
            <button class="play-btn" id="retryReflexBtn" style="background:var(--accent-yellow); color:#000; margin-top:8px">TRY AGAIN</button>
          </div>`;
        this.container.querySelector('#retryReflexBtn').addEventListener('click', () => this.prepareWait());
      }
    });
    this.waitTimer = setTimeout(() => {
      this.state = 'ready'; this.startTime = Date.now(); audio.playTick();
      el.className = 'reflex-container ready'; el.innerHTML = `<h2 style="font-size:24px; font-weight:900;">TAP NOW!</h2>`;
    }, Math.random() * 2000 + 1500);
  }
  destroy() { clearTimeout(this.waitTimer); }
}

class PaddleGame {
  constructor(container, app) {
    this.container = container; this.app = app; this.canvas = document.createElement('canvas');
    this.canvas.width = 240; this.canvas.height = 240; this.canvas.id = 'paddleCanvas'; this.ctx = this.canvas.getContext('2d');
    this.paddleW = 46; this.paddleH = 8; this.paddleX = 97; this.ballX = 120; this.ballY = 80; this.ballVx = 2.4; this.ballVy = 2.8; this.ballR = 5;
    this.showStartScreen();
  }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🏓</div><h3>CROWN PADDLE</h3>
        <p>Turn Digital Crown to steer paddle</p>
        <button class="play-btn" id="startPaddleBtn">START</button>
      </div>`;
    this.container.querySelector('#startPaddleBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.container.innerHTML = ''; this.container.appendChild(this.canvas);
    this.score = 0; this.paddleX = 97; this.ballX = 120; this.ballY = 80; this.ballVx = 2.4; this.ballVy = 2.8; this.running = true; this.loop();
  }
  onCrown(delta) { if (!this.running) return; this.paddleX = Math.max(4, Math.min(this.canvas.width - this.paddleW - 4, this.paddleX + delta * 9)); }
  loop() { if (!this.running) return; this.update(); this.draw(); this.animId = requestAnimationFrame(() => this.loop()); }
  update() {
    this.ballX += this.ballVx; this.ballY += this.ballVy;
    if (this.ballX - this.ballR <= 4) { this.ballX = this.ballR + 4; this.ballVx = Math.abs(this.ballVx); audio.playBounce(); }
    else if (this.ballX + this.ballR >= this.canvas.width - 4) { this.ballX = this.canvas.width - 4 - this.ballR; this.ballVx = -Math.abs(this.ballVx); audio.playBounce(); }
    if (this.ballY - this.ballR <= 4) { this.ballY = this.ballR + 4; this.ballVy = Math.abs(this.ballVy); audio.playBounce(); }
    const paddleY = this.canvas.height - 16;
    if (this.ballY + this.ballR >= paddleY && this.ballY - this.ballR <= paddleY + this.paddleH) {
      if (this.ballX >= this.paddleX && this.ballX <= this.paddleX + this.paddleW) {
        this.ballY = paddleY - this.ballR; this.ballVy = -Math.abs(this.ballVy) * 1.02;
        this.ballVx = ((this.ballX - (this.paddleX + this.paddleW / 2)) / (this.paddleW / 2)) * 3.5;
        this.score++; document.getElementById('gameCurrentScore').textContent = this.score; audio.playScore();
      }
    }
    if (this.ballY - this.ballR > this.canvas.height) this.gameOver();
  }
  draw() {
    this.ctx.fillStyle = '#000'; this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.strokeStyle = 'rgba(6, 182, 212, 0.3)'; this.ctx.lineWidth = 2; this.ctx.strokeRect(2, 2, this.canvas.width - 4, this.canvas.height - 4);
    this.ctx.fillStyle = '#06b6d4'; this.ctx.fillRect(this.paddleX, this.canvas.height - 16, this.paddleW, this.paddleH);
    this.ctx.fillStyle = '#fff'; this.ctx.beginPath(); this.ctx.arc(this.ballX, this.ballY, this.ballR, 0, Math.PI * 2); this.ctx.fill();
  }
  gameOver() {
    this.running = false; audio.playGameOver(); Storage.recordScore('paddle', this.score);
    this.container.innerHTML = `
      <div class="game-screen-center">
        <h3 style="color:var(--accent-red)">GAME OVER</h3><p>Score: ${this.score}</p>
        <button class="play-btn" id="retryPaddleBtn">RETRY</button>
      </div>`;
    this.container.querySelector('#retryPaddleBtn').addEventListener('click', () => this.startGame());
  }
  destroy() { this.running = false; cancelAnimationFrame(this.animId); }
}

class SnakeGame {
  constructor(container, app) {
    this.container = container; this.app = app; this.cols = 14; this.rows = 14; this.cellSize = 16;
    this.canvas = document.createElement('canvas'); this.canvas.width = 224; this.canvas.height = 224; this.ctx = this.canvas.getContext('2d'); this.showStartScreen();
  }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🐍</div><h3>CROWN SNAKE</h3>
        <p>Rotate Crown or swipe to steer</p>
        <button class="play-btn" id="startSnakeBtn" style="background:var(--accent-green)">START</button>
      </div>`;
    this.container.querySelector('#startSnakeBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.container.innerHTML = ''; this.container.appendChild(this.canvas);
    this.snake = [{x: 7, y: 7}, {x: 7, y: 8}, {x: 7, y: 9}]; this.dir = 'up'; this.nextDir = 'up'; this.food = {x: 4, y: 4}; this.score = 0; this.running = true;
    this.timer = setInterval(() => this.tick(), 160);
  }
  onCrown(delta) {
    const dirs = ['up', 'right', 'down', 'left']; let idx = dirs.indexOf(this.dir);
    this.nextDir = dirs[delta > 0 ? (idx + 1) % 4 : (idx + 3) % 4];
  }
  tick() {
    this.dir = this.nextDir; const head = Object.assign({}, this.snake[0]);
    if (this.dir === 'up') head.y--; else if (this.dir === 'down') head.y++; else if (this.dir === 'left') head.x--; else if (this.dir === 'right') head.x++;
    if (head.x < 0 || head.x >= this.cols || head.y < 0 || head.y >= this.rows || this.snake.some(s => s.x === head.x && s.y === head.y)) {
      this.gameOver(); return;
    }
    this.snake.unshift(head);
    if (head.x === this.food.x && head.y === this.food.y) {
      this.score++; document.getElementById('gameCurrentScore').textContent = this.score; audio.playScore();
      this.food = { x: Math.floor(Math.random() * this.cols), y: Math.floor(Math.random() * this.rows) };
    } else this.snake.pop();
    this.draw();
  }
  draw() {
    this.ctx.fillStyle = '#000'; this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.fillStyle = '#ef4444'; this.ctx.beginPath(); this.ctx.arc(this.food.x * 16 + 8, this.food.y * 16 + 8, 6, 0, Math.PI * 2); this.ctx.fill();
    this.snake.forEach((seg, i) => {
      this.ctx.fillStyle = i === 0 ? '#10b981' : 'rgba(16, 185, 129, 0.7)';
      this.ctx.fillRect(seg.x * 16 + 1, seg.y * 16 + 1, 14, 14);
    });
  }
  gameOver() {
    this.running = false; clearInterval(this.timer); audio.playGameOver(); Storage.recordScore('snake', this.score);
    this.container.innerHTML = `
      <div class="game-screen-center">
        <h3 style="color:var(--accent-red)">GAME OVER</h3><p>Apples: ${this.score}</p>
        <button class="play-btn" id="retrySnakeBtn" style="background:var(--accent-green)">RETRY</button>
      </div>`;
    this.container.querySelector('#retrySnakeBtn').addEventListener('click', () => this.startGame());
  }
  destroy() { clearInterval(this.timer); }
}

class Merge2048Game {
  constructor(container, app) { this.container = container; this.app = app; this.showStartScreen(); }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🔢</div><h3>NUMBER MERGE</h3>
        <p>Swipe or use arrow keys to combine tiles</p>
        <button class="play-btn" id="start2048Btn" style="background:var(--accent-orange)">START</button>
      </div>`;
    this.container.querySelector('#start2048Btn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.board = Array(4).fill(0).map(() => Array(4).fill(0)); this.score = 0;
    this.spawn(); this.spawn(); this.render();
    this.keyHandler = (e) => {
      if (['ArrowLeft','ArrowRight','ArrowUp','ArrowDown'].includes(e.key)) { e.preventDefault(); this.move(e.key.replace('Arrow','').toLowerCase()); }
    };
    window.addEventListener('keydown', this.keyHandler);
  }
  spawn() {
    let empty = []; for (let r = 0; r < 4; r++) for (let c = 0; c < 4; c++) if (this.board[r][c] === 0) empty.push({r, c});
    if (empty.length > 0) { const s = empty[Math.floor(Math.random() * empty.length)]; this.board[s.r][s.c] = Math.random() < 0.9 ? 2 : 4; }
  }
  slide(row) {
    let nonZero = row.filter(v => v !== 0); let res = []; let pts = 0;
    for (let i = 0; i < nonZero.length; i++) {
      if (i + 1 < nonZero.length && nonZero[i] === nonZero[i + 1]) { res.push(nonZero[i] * 2); pts += nonZero[i] * 2; i++; }
      else res.push(nonZero[i]);
    }
    while (res.length < 4) res.push(0);
    return { res, pts, moved: JSON.stringify(res) !== JSON.stringify(row) };
  }
  move(dir) {
    let moved = false; let pts = 0;
    for (let i = 0; i < 4; i++) {
      let line = (dir === 'left' || dir === 'right') ? this.board[i].slice() : [this.board[0][i], this.board[1][i], this.board[2][i], this.board[3][i]];
      if (dir === 'right' || dir === 'down') line.reverse();
      let out = this.slide(line); if (out.moved) moved = true; pts += out.pts;
      if (dir === 'right' || dir === 'down') out.res.reverse();
      for (let j = 0; j < 4; j++) { if (dir === 'left' || dir === 'right') this.board[i][j] = out.res[j]; else this.board[j][i] = out.res[j]; }
    }
    if (moved) {
      this.score += pts; document.getElementById('gameCurrentScore').textContent = this.score; audio.playBounce(); this.spawn(); this.render();
      if (this.isOver()) { audio.playGameOver(); Storage.recordScore('merge2048', this.score); }
    }
  }
  isOver() {
    for (let r = 0; r < 4; r++) for (let c = 0; c < 4; c++) {
      if (this.board[r][c] === 0 || (c + 1 < 4 && this.board[r][c] === this.board[r][c + 1]) || (r + 1 < 4 && this.board[r][c] === this.board[r + 1][c])) return false;
    }
    return true;
  }
  render() {
    const tileColors = { 2: '#334155', 4: '#475569', 8: '#f97316', 16: '#ea580c', 32: '#ef4444', 64: '#dc2626', 128: '#eab308', 256: '#ca8a04', 512: '#06b6d4', 1024: '#2563eb', 2048: '#a855f7' };
    let cellsHtml = ''; for (let r = 0; r < 4; r++) for (let c = 0; c < 4; c++) {
      const v = this.board[r][c]; cellsHtml += `<div class="tile-2048" style="background:${v > 0 ? (tileColors[v] || '#ec4899') : 'rgba(255,255,255,0.06)'}">${v > 0 ? v : ''}</div>`;
    }
    this.container.innerHTML = `<div class="grid-2048">${cellsHtml}</div>`;
  }
  destroy() { if (this.keyHandler) window.removeEventListener('keydown', this.keyHandler); }
}

class BrickCrusherGame {
  constructor(container, app) {
    this.container = container; this.app = app; this.canvas = document.createElement('canvas');
    this.canvas.width = 240; this.canvas.height = 240; this.canvas.id = 'brickCanvas'; this.ctx = this.canvas.getContext('2d'); this.showStartScreen();
  }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🧱</div><h3>BRICK CRUSHER</h3>
        <p>Turn Digital Crown to smash all bricks</p>
        <button class="play-btn" id="startBrickBtn" style="background:var(--accent-pink)">START</button>
      </div>`;
    this.container.querySelector('#startBrickBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.container.innerHTML = ''; this.container.appendChild(this.canvas);
    this.score = 0; this.paddleW = 42; this.paddleH = 7; this.paddleX = 99; this.ballX = 120; this.ballY = 130; this.ballVx = 2.2; this.ballVy = -2.4; this.ballR = 4.5;
    this.bricks = []; const colors = ['#ef4444', '#f97316', '#06b6d4', '#10b981'];
    for (let r = 0; r < 4; r++) for (let c = 0; c < 6; c++) this.bricks.push({ x: 4 + c * 39, y: 20 + r * 14, w: 35, h: 10, color: colors[r], alive: true });
    this.running = true; this.loop();
  }
  onCrown(delta) { if (!this.running) return; this.paddleX = Math.max(4, Math.min(this.canvas.width - this.paddleW - 4, this.paddleX + delta * 9)); }
  loop() { if (!this.running) return; this.update(); this.draw(); this.animId = requestAnimationFrame(() => this.loop()); }
  update() {
    this.ballX += this.ballVx; this.ballY += this.ballVy;
    if (this.ballX - this.ballR <= 4) { this.ballX = this.ballR + 4; this.ballVx = Math.abs(this.ballVx); audio.playBounce(); }
    else if (this.ballX + this.ballR >= this.canvas.width - 4) { this.ballX = this.canvas.width - 4 - this.ballR; this.ballVx = -Math.abs(this.ballVx); audio.playBounce(); }
    if (this.ballY - this.ballR <= 4) { this.ballY = this.ballR + 4; this.ballVy = Math.abs(this.ballVy); audio.playBounce(); }
    const paddleY = this.canvas.height - 16;
    if (this.ballY + this.ballR >= paddleY && this.ballY - this.ballR <= paddleY + this.paddleH) {
      if (this.ballX >= this.paddleX && this.ballX <= this.paddleX + this.paddleW) {
        this.ballY = paddleY - this.ballR; this.ballVy = -Math.abs(this.ballVy);
        this.ballVx = ((this.ballX - (this.paddleX + this.paddleW / 2)) / (this.paddleW / 2)) * 3.4; audio.playBounce();
      }
    }
    for (let b of this.bricks) {
      if (b.alive && this.ballX >= b.x && this.ballX <= b.x + b.w && this.ballY >= b.y && this.ballY <= b.y + b.h) {
        b.alive = false; this.ballVy = -this.ballVy; this.score += 10; document.getElementById('gameCurrentScore').textContent = this.score; audio.playScore(); break;
      }
    }
    if (this.bricks.every(b => !b.alive)) {
      this.running = false; audio.playVictory(); Storage.recordScore('brickcrusher', this.score);
      this.container.innerHTML = `<div class="game-screen-center"><h3 style="color:var(--accent-green)">CLEARED!</h3><button class="play-btn" id="retryBrickBtn" style="background:var(--accent-pink)">PLAY AGAIN</button></div>`;
      this.container.querySelector('#retryBrickBtn').addEventListener('click', () => this.startGame()); return;
    }
    if (this.ballY - this.ballR > this.canvas.height) {
      this.running = false; audio.playGameOver(); Storage.recordScore('brickcrusher', this.score);
      this.container.innerHTML = `<div class="game-screen-center"><h3 style="color:var(--accent-red)">GAME OVER</h3><button class="play-btn" id="retryBrickBtn" style="background:var(--accent-pink)">RETRY</button></div>`;
      this.container.querySelector('#retryBrickBtn').addEventListener('click', () => this.startGame());
    }
  }
  draw() {
    this.ctx.fillStyle = '#000'; this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    for (let b of this.bricks) if (b.alive) { this.ctx.fillStyle = b.color; this.ctx.fillRect(b.x, b.y, b.w, b.h); }
    this.ctx.fillStyle = '#ec4899'; this.ctx.fillRect(this.paddleX, this.canvas.height - 16, this.paddleW, this.paddleH);
    this.ctx.fillStyle = '#fff'; this.ctx.beginPath(); this.ctx.arc(this.ballX, this.ballY, this.ballR, 0, Math.PI * 2); this.ctx.fill();
  }
  destroy() { this.running = false; cancelAnimationFrame(this.animId); }
}

class ColorMemoryGame {
  constructor(container, app) { this.container = container; this.app = app; this.colors = ['green', 'red', 'yellow', 'blue']; this.showStartScreen(); }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">✨</div><h3>COLOR SEQUENCE</h3>
        <p>Remember and repeat the light pattern</p>
        <button class="play-btn" id="startMemoryBtn" style="background:var(--accent-purple)">START</button>
      </div>`;
    this.container.querySelector('#startMemoryBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.sequence = []; this.round = 0;
    this.container.innerHTML = `<div class="color-memory-grid"><div class="color-pad pad-green" data-color="green"></div><div class="color-pad pad-red" data-color="red"></div><div class="color-pad pad-yellow" data-color="yellow"></div><div class="color-pad pad-blue" data-color="blue"></div></div>`;
    this.container.querySelectorAll('.color-pad').forEach(p => p.addEventListener('click', () => this.handleTap(p.dataset.color)));
    this.nextRound();
  }
  nextRound() {
    this.round++; document.getElementById('gameCurrentScore').textContent = this.round;
    this.sequence.push(this.colors[Math.floor(Math.random() * 4)]); this.userStep = 0; this.playSeq();
  }
  async playSeq() {
    this.blocked = true; await new Promise(r => setTimeout(r, 600));
    for (let c of this.sequence) {
      const pad = this.container.querySelector(`[data-color="${c}"]`);
      if (pad) { pad.classList.add('active'); audio.playTone({ green:300, red:400, yellow:500, blue:600 }[c] || 440, 0.25); }
      await new Promise(r => setTimeout(r, 350)); if (pad) pad.classList.remove('active');
      await new Promise(r => setTimeout(r, 150));
    }
    this.blocked = false;
  }
  handleTap(color) {
    if (this.blocked) return;
    const pad = this.container.querySelector(`[data-color="${color}"]`);
    if (pad) { pad.classList.add('active'); setTimeout(() => pad.classList.remove('active'), 200); }
    if (color === this.sequence[this.userStep]) {
      this.userStep++;
      if (this.userStep === this.sequence.length) { audio.playScore(); setTimeout(() => this.nextRound(), 600); }
    } else {
      audio.playGameOver(); Storage.recordScore('colormemory', this.round - 1);
      this.container.innerHTML = `<div class="game-screen-center"><h3 style="color:var(--accent-red)">WRONG!</h3><button class="play-btn" id="retryMemoryBtn" style="background:var(--accent-purple)">RETRY</button></div>`;
      this.container.querySelector('#retryMemoryBtn').addEventListener('click', () => this.startGame());
    }
  }
  destroy() {}
}

class MinesGame {
  constructor(container, app) { this.container = container; this.app = app; this.rows = 6; this.cols = 6; this.totalMines = 5; this.showStartScreen(); }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🚩</div><h3>MINE GRID</h3>
        <p>Uncover safe tiles without hitting mines</p>
        <button class="play-btn" id="startMinesBtn" style="background:var(--accent-yellow); color:#000">START</button>
      </div>`;
    this.container.querySelector('#startMinesBtn').addEventListener('click', () => { audio.playTick(); this.startGame(); });
  }
  startGame() {
    this.grid = []; this.firstTap = true; this.isFlagMode = false;
    for (let r = 0; r < 6; r++) for (let c = 0; c < 6; c++) this.grid.push({ r, c, isMine: false, revealed: false, flagged: false, neighbors: 0 });
    this.render();
  }
  render() {
    let cellsHtml = this.grid.map((cell, idx) => {
      let content = cell.revealed ? (cell.isMine ? '💣' : (cell.neighbors > 0 ? cell.neighbors : '')) : (cell.flagged ? '🚩' : '');
      return `<div class="mine-cell ${cell.revealed ? (cell.isMine ? 'mine' : 'revealed') : ''}" data-idx="${idx}">${content}</div>`;
    }).join('');
    this.container.innerHTML = `
      <div class="mines-header">
        <button class="mine-mode-btn ${this.isFlagMode ? 'flag' : ''}" id="btnToggleMode">${this.isFlagMode ? 'FLAG 🚩' : 'DIG ⛏️'}</button>
        <span style="font-size:10px; color:var(--accent-yellow)">💣 5</span>
      </div>
      <div class="mines-grid">${cellsHtml}</div>`;
    this.container.querySelector('#btnToggleMode').addEventListener('click', () => { this.isFlagMode = !this.isFlagMode; audio.playTick(); this.render(); });
    this.container.querySelectorAll('.mine-cell').forEach(el => el.addEventListener('click', () => this.handleTap(parseInt(el.dataset.idx, 10))));
  }
  handleTap(idx) {
    const cell = this.grid[idx]; if (cell.revealed) return;
    if (this.isFlagMode) { cell.flagged = !cell.flagged; audio.playTick(); this.render(); return; }
    if (cell.flagged) return;
    if (this.firstTap) {
      this.firstTap = false;
      let indices = this.grid.map((_, i) => i).filter(i => i !== idx).sort(() => Math.random() - 0.5);
      for (let i = 0; i < 5; i++) this.grid[indices[i]].isMine = true;
      for (let i = 0; i < 36; i++) {
        const { r, c } = this.grid[i]; let count = 0;
        for (let dr = -1; dr <= 1; dr++) for (let dc = -1; dc <= 1; dc++) {
          if (dr === 0 && dc === 0) continue; const nr = r + dr, nc = c + dc;
          if (nr >= 0 && nr < 6 && nc >= 0 && nc < 6 && this.grid[nr * 6 + nc].isMine) count++;
        }
        this.grid[i].neighbors = count;
      }
    }
    if (cell.isMine) {
      audio.playGameOver(); this.grid.forEach(c => { if (c.isMine) c.revealed = true; }); this.render();
      setTimeout(() => { alert('BOOM!'); this.startGame(); }, 400); return;
    }
    this.reveal(idx); audio.playBounce(); this.render();
    if (this.grid.filter(c => !c.isMine && !c.revealed).length === 0) {
      audio.playVictory(); Storage.recordScore('mines', 1); alert('CLEARED!'); this.startGame();
    }
  }
  reveal(idx) {
    const c = this.grid[idx]; if (c.revealed || c.flagged) return; c.revealed = true;
    if (c.neighbors === 0 && !c.isMine) {
      for (let dr = -1; dr <= 1; dr++) for (let dc = -1; dc <= 1; dc++) {
        const nr = c.r + dr, nc = c.c + dc;
        if (nr >= 0 && nr < 6 && nc >= 0 && nc < 6) this.reveal(nr * 6 + nc);
      }
    }
  }
  destroy() {}
}

class TicTacToeGame {
  constructor(container, app) { this.container = container; this.app = app; this.showStartScreen(); }
  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">❌</div><h3>TIC-TAC-TOE</h3>
        <button class="play-btn" id="mAi" style="background:var(--accent-teal); width:130px; margin-bottom:6px">VS AI</button>
        <button class="play-btn" id="mPvp" style="background:rgba(255,255,255,0.15); color:#fff; width:130px">PASS & PLAY</button>
      </div>`;
    this.container.querySelector('#mAi').addEventListener('click', () => { this.isAi = true; audio.playTick(); this.start(); });
    this.container.querySelector('#mPvp').addEventListener('click', () => { this.isAi = false; audio.playTick(); this.start(); });
  }
  start() { this.board = Array(9).fill(null); this.curr = 'X'; this.winner = null; this.render(); }
  render() {
    let cellsHtml = this.board.map((v, i) => `<div class="ttt-cell ${v ? v.toLowerCase() : ''}" data-idx="${i}">${v || ''}</div>`).join('');
    this.container.innerHTML = `
      <div style="font-size:10px; font-weight:700; text-align:center; margin-bottom:6px;">${this.winner ? `${this.winner} WINS!` : `TURN: ${this.curr}`}</div>
      <div class="ttt-grid">${cellsHtml}</div>
      ${this.winner ? `<button class="play-btn" id="tAgain" style="margin-top:8px; width:100px; align-self:center">AGAIN</button>` : ''}`;
    this.container.querySelectorAll('.ttt-cell').forEach(el => el.addEventListener('click', () => this.move(parseInt(el.dataset.idx, 10))));
    const btn = this.container.querySelector('#tAgain'); if (btn) btn.addEventListener('click', () => this.start());
  }
  move(idx) {
    if (this.board[idx] || this.winner) return; this.board[idx] = this.curr; audio.playTick();
    if (this.check(this.curr)) { this.winner = this.curr; audio.playVictory(); this.render(); return; }
    if (!this.board.includes(null)) { this.winner = 'DRAW'; audio.playBounce(); this.render(); return; }
    this.curr = this.curr === 'X' ? 'O' : 'X'; this.render();
    if (this.isAi && this.curr === 'O') setTimeout(() => this.aiMove(), 300);
  }
  aiMove() {
    let empty = this.board.map((v, i) => v === null ? i : null).filter(v => v !== null);
    if (empty.length > 0) { this.board[empty[Math.floor(Math.random() * empty.length)]] = 'O'; }
    if (this.check('O')) { this.winner = 'O'; audio.playGameOver(); }
    else this.curr = 'X'; this.render();
  }
  check(p) {
    const lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    return lines.some(([a,b,c]) => this.board[a] === p && this.board[b] === p && this.board[c] === p);
  }
  destroy() {}
}

// -------------------------------------------------------------
// GAME: VIDEO POKER (JACKS OR BETTER)
// -------------------------------------------------------------
class VideoPokerGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.score = 0;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">♦️</div>
        <h3>VIDEO POKER</h3>
        <p>Jacks or Better • 5-Card Draw</p>
        <button class="play-btn" id="startPokerBtn" style="background:var(--accent-yellow); color:#000">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startPokerBtn').addEventListener('click', () => {
      audio.playTick();
      this.dealNewHand();
    });
  }

  dealNewHand() {
    const ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
    const suits = ['♠', '♥', '♦', '♣'];
    let deck = [];
    suits.forEach(s => {
      ranks.forEach((r, idx) => {
        deck.push({ rank: r, suit: s, val: idx + 2, isRed: (s === '♥' || s === '♦'), held: false });
      });
    });
    deck.sort(() => Math.random() - 0.5);

    this.hand = deck.slice(0, 5);
    this.deck = deck.slice(5);
    this.isDrawPhase = false;
    this.resultText = '';
    this.renderHand();
  }

  renderHand() {
    let cardsHtml = this.hand.map((c, i) => `
      <div class="poker-card-box ${c.isRed ? 'red' : 'black'} ${c.held ? 'held' : ''}" data-idx="${i}">
        <span class="poker-hold-badge" style="visibility:${c.held ? 'visible' : 'hidden'}">${this.app.lang === 'tr' ? 'TUT' : 'HELD'}</span>
        <span class="poker-card-val">${c.rank}</span>
        <span class="poker-card-suit">${c.suit}</span>
      </div>
    `).join('');

    this.container.innerHTML = `
      <div class="game-screen-center" style="gap:4px; padding:4px;">
        <div style="font-size:10px; font-weight:800; color:var(--accent-yellow); min-height:16px;">
          ${this.resultText || (this.app.lang === 'tr' ? 'Tutmak için karta dokun' : 'Tap card to hold')}
        </div>
        <div class="poker-hand-row">${cardsHtml}</div>
        <button class="play-btn" id="btnPokerAction" style="background:${this.isDrawPhase ? 'var(--accent-cyan)' : 'var(--accent-yellow)'}; color:#000; font-size:10px; padding:5px 14px; margin-top:2px;">
          ${this.isDrawPhase ? (this.app.lang === 'tr' ? 'YENİ EL (DEAL)' : 'NEW DEAL') : (this.app.lang === 'tr' ? 'KART DEĞİŞTİR (DRAW)' : 'DRAW CARDS')}
        </button>
      </div>
    `;

    this.container.querySelectorAll('.poker-card-box').forEach(el => {
      el.addEventListener('click', () => {
        if (!this.isDrawPhase) {
          const idx = parseInt(el.dataset.idx, 10);
          this.hand[idx].held = !this.hand[idx].held;
          audio.playTick();
          this.renderHand();
        }
      });
    });

    this.container.querySelector('#btnPokerAction').addEventListener('click', () => {
      audio.playTick();
      if (this.isDrawPhase) {
        this.dealNewHand();
      } else {
        this.drawCards();
      }
    });
  }

  drawCards() {
    this.hand.forEach((card, i) => {
      if (!card.held && this.deck.length > 0) {
        this.hand[i] = this.deck.pop();
      }
    });
    this.isDrawPhase = true;
    this.evaluate();
    this.renderHand();
  }

  evaluate() {
    const vals = this.hand.map(c => c.val).sort((a, b) => a - b);
    const suits = this.hand.map(c => c.suit);
    const isFlush = new Set(suits).size === 1;

    let isStraight = false;
    if (new Set(vals).size === 5) {
      if (vals[4] - vals[0] === 4) isStraight = true;
      else if (JSON.stringify(vals) === JSON.stringify([2, 3, 4, 5, 14])) isStraight = true;
    }

    const counts = {};
    vals.forEach(v => counts[v] = (counts[v] || 0) + 1);
    const freq = Object.values(counts).sort((a, b) => b - a);

    let pts = 0;
    let name = '';

    if (isFlush && isStraight && vals.includes(14) && vals.includes(13)) {
      name = 'ROYAL FLUSH! 👑'; pts = 800;
    } else if (isFlush && isStraight) {
      name = 'STRAIGHT FLUSH!'; pts = 250;
    } else if (freq[0] === 4) {
      name = '4 OF A KIND!'; pts = 100;
    } else if (freq[0] === 3 && freq[1] === 2) {
      name = 'FULL HOUSE!'; pts = 40;
    } else if (isFlush) {
      name = 'FLUSH!'; pts = 30;
    } else if (isStraight) {
      name = 'STRAIGHT!'; pts = 20;
    } else if (freq[0] === 3) {
      name = '3 OF A KIND!'; pts = 15;
    } else if (freq[0] === 2 && freq[1] === 2) {
      name = 'TWO PAIR!'; pts = 10;
    } else if (freq[0] === 2) {
      const pairVal = Object.keys(counts).find(k => counts[k] === 2);
      if (parseInt(pairVal, 10) >= 11) {
        name = this.app.lang === 'tr' ? 'VALE ÇİFTİ+ (JACKS+)' : 'JACKS OR BETTER!';
        pts = 5;
      } else {
        name = this.app.lang === 'tr' ? 'DÜŞÜK ÇİFT' : 'LOW PAIR';
      }
    } else {
      name = this.app.lang === 'tr' ? 'KAZANÇ YOK' : 'NO WIN';
    }

    this.resultText = name;
    if (pts > 0) {
      this.score += pts;
      document.getElementById('gameCurrentScore').textContent = this.score;
      Storage.recordScore('videopoker', this.score);
      audio.playVictory();
    } else {
      audio.playBounce();
    }
  }

  destroy() {}
}

// -------------------------------------------------------------
// GAME: CARD WAR (HIGH CARD BATTLE)
// -------------------------------------------------------------
class CardWarGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.score = 0;
    this.streak = 0;
    this.isWar = false;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🛡️</div>
        <h3>CARD WAR</h3>
        <p>Highest Card Wins • War on Ties!</p>
        <button class="play-btn" id="startWarBtn" style="background:var(--accent-orange); color:#000">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startWarBtn').addEventListener('click', () => {
      audio.playTick();
      this.renderArena();
    });
  }

  getRandomCard() {
    const ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
    const suits = ['♠', '♥', '♦', '♣'];
    const s = suits[Math.floor(Math.random() * suits.length)];
    const idx = Math.floor(Math.random() * ranks.length);
    return { rank: ranks[idx], suit: s, val: idx + 2, isRed: (s === '♥' || s === '♦') };
  }

  renderArena(pCard = null, dCard = null, msg = '') {
    const pCardHtml = pCard ? `
      <div class="war-card-view ${pCard.isRed ? 'red' : 'black'}">
        <span style="font-size:16px; font-weight:900;">${pCard.rank}</span>
        <span style="font-size:18px;">${pCard.suit}</span>
      </div>
    ` : `<div class="war-card-view empty"></div>`;

    const dCardHtml = dCard ? `
      <div class="war-card-view ${dCard.isRed ? 'red' : 'black'}">
        <span style="font-size:16px; font-weight:900;">${dCard.rank}</span>
        <span style="font-size:18px;">${dCard.suit}</span>
      </div>
    ` : `<div class="war-card-view empty"></div>`;

    this.container.innerHTML = `
      <div class="game-screen-center" style="padding:4px; gap:4px;">
        <div style="font-size:10px; font-weight:800; color:var(--accent-orange); min-height:16px;">
          ${msg || (this.app.lang === 'tr' ? `Seri: ${this.streak} 🔥` : `Streak: ${this.streak} 🔥`)}
        </div>
        <div class="war-arena">
          <div class="war-slot">
            <span>${this.app.lang === 'tr' ? 'KRUPİYE' : 'DEALER'}</span>
            ${dCardHtml}
          </div>
          <div class="war-vs">VS</div>
          <div class="war-slot">
            <span style="color:var(--accent-orange)">${this.app.lang === 'tr' ? 'SEN' : 'YOU'}</span>
            ${pCardHtml}
          </div>
        </div>
        <button class="play-btn" id="btnWarDraw" style="background:${this.isWar ? 'var(--accent-yellow)' : 'var(--accent-orange)'}; color:#000; font-size:11px; padding:6px 20px;">
          ${this.isWar ? (this.app.lang === 'tr' ? '⚔️ SAVAŞ! (WAR)' : '⚔️ WAR STRIKE!') : (this.app.lang === 'tr' ? 'KART ÇEK (BATTLE)' : 'DRAW CARD')}
        </button>
      </div>
    `;

    this.container.querySelector('#btnWarDraw').addEventListener('click', () => {
      this.playRound();
    });
  }

  playRound() {
    const p = this.getRandomCard();
    const d = this.getRandomCard();
    let msg = '';

    if (p.val > d.val) {
      const gain = this.isWar ? 30 : 10;
      this.score += gain;
      this.streak++;
      this.isWar = false;
      document.getElementById('gameCurrentScore').textContent = this.score;
      Storage.recordScore('cardwar', this.score);
      audio.playVictory();
      msg = this.app.lang === 'tr' ? `KAZANDIN! (+${gain})` : `YOU WIN! (+${gain})`;
    } else if (d.val > p.val) {
      this.streak = 0;
      this.isWar = false;
      audio.playGameOver();
      msg = this.app.lang === 'tr' ? 'KAYBETTİN' : 'DEALER WON';
    } else {
      this.isWar = true;
      audio.playScore();
      msg = this.app.lang === 'tr' ? '⚔️ BERABERE! SAVAŞ BAŞLADI!' : '⚔️ TIE! WAR BEGINS!';
    }

    this.renderArena(p, d, msg);
  }

  destroy() {}
}

// -------------------------------------------------------------
// GAME: SPEED TAP 1-9 (SCHULTE NUMBER RUSH)
// -------------------------------------------------------------
class SpeedNumbersGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🔢</div>
        <h3>SPEED TAP 1-9</h3>
        <p>${this.app.lang === 'tr' ? "1'den 9'a sırayla en hızlı şekilde dokun!" : 'Tap numbers 1 to 9 in ascending order as fast as possible!'}</p>
        <button class="play-btn" id="startSpeedBtn" style="background:var(--accent-cyan); color:#000">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startSpeedBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    let nums = [1, 2, 3, 4, 5, 6, 7, 8, 9].sort(() => Math.random() - 0.5);
    this.tiles = nums.map(n => ({ val: n, tapped: false }));
    this.target = 1;
    this.startTime = null;
    this.timerInterval = null;
    this.penalty = 0;
    this.renderGrid();
  }

  renderGrid() {
    let tilesHtml = this.tiles.map((t, idx) => `
      <div class="speed-tile ${t.tapped ? 'tapped' : ''}" data-idx="${idx}">
        ${t.tapped ? '✓' : t.val}
      </div>
    `).join('');

    this.container.innerHTML = `
      <div class="game-screen-center" style="padding:4px; gap:4px;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:800;">
          <span style="color:var(--accent-cyan)">${this.app.t('next')}: ${this.target <= 9 ? this.target : '✓'}</span>
          <span id="speedTimerDisplay" style="font-family:'JetBrains Mono'; color:#fff;">0.00s</span>
        </div>
        <div class="speed-numbers-grid">${tilesHtml}</div>
      </div>
    `;

    this.container.querySelectorAll('.speed-tile').forEach(el => {
      el.addEventListener('click', () => {
        const idx = parseInt(el.dataset.idx, 10);
        this.handleTileClick(idx, el);
      });
    });
  }

  handleTileClick(idx, el) {
    if (this.tiles[idx].tapped) return;

    if (!this.startTime) {
      this.startTime = Date.now();
      this.timerInterval = setInterval(() => {
        const elapsed = (Date.now() - this.startTime + this.penalty) / 1000;
        const disp = document.getElementById('speedTimerDisplay');
        if (disp) disp.textContent = `${elapsed.toFixed(2)}s`;
      }, 50);
    }

    if (this.tiles[idx].val === this.target) {
      this.tiles[idx].tapped = true;
      el.classList.add('tapped');
      el.textContent = '✓';
      audio.playTick();

      if (this.target === 9) {
        clearInterval(this.timerInterval);
        const finalSec = (Date.now() - this.startTime + this.penalty) / 1000;
        const ms = Math.round(finalSec * 1000);
        audio.playVictory();
        Storage.recordScore('speednumbers', ms);
        document.getElementById('gameCurrentScore').textContent = `${finalSec.toFixed(2)}s`;

        this.container.innerHTML = `
          <div class="game-screen-center">
            <h3 style="color:var(--accent-green)">${this.app.t('you_win')}</h3>
            <p style="font-size:13px; font-weight:900; font-family:'JetBrains Mono'; color:#fff;">${finalSec.toFixed(2)}s</p>
            <button class="play-btn" id="retrySpeedBtn" style="background:var(--accent-cyan); color:#000">${this.app.lang === 'tr' ? 'TEKRAR OYNA' : 'PLAY AGAIN'}</button>
          </div>
        `;
        this.container.querySelector('#retrySpeedBtn').addEventListener('click', () => this.startGame());
      } else {
        this.target++;
        const disp = this.container.querySelector('span[style*="var(--accent-cyan)"]');
        if (disp) disp.textContent = `${this.app.t('next')}: ${this.target}`;
      }
    } else {
      // Wrong tile!
      this.penalty += 500; // 0.5s penalty
      el.classList.add('error');
      audio.playGameOver();
      setTimeout(() => el.classList.remove('error'), 250);
    }
  }

  destroy() {
    if (this.timerInterval) clearInterval(this.timerInterval);
  }
}

// -------------------------------------------------------------
// GAME: NUMBER SLIDE (3x3 8-PUZZLE)
// -------------------------------------------------------------
class NumberSlideGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🧩</div>
        <h3>NUMBER SLIDE</h3>
        <p>${this.app.lang === 'tr' ? "1'den 8'e kadar sayıları sırayla dizin" : 'Slide tiles 1 to 8 into sequential order'}</p>
        <button class="play-btn" id="startSlideBtn" style="background:var(--accent-mint); color:#000">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startSlideBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    let board = [1, 2, 3, 4, 5, 6, 7, 8, 0];
    let blank = 8;
    // Solvable shuffle
    for (let i = 0; i < 35; i++) {
      const neighbors = this.getNeighbors(blank);
      const next = neighbors[Math.floor(Math.random() * neighbors.length)];
      [board[blank], board[next]] = [board[next], board[blank]];
      blank = next;
    }
    this.board = board;
    this.moves = 0;
    this.render();
  }

  getNeighbors(idx) {
    const res = [];
    const r = Math.floor(idx / 3);
    const c = idx % 3;
    if (r > 0) res.push(idx - 3);
    if (r < 2) res.push(idx + 3);
    if (c > 0) res.push(idx - 1);
    if (c < 2) res.push(idx + 1);
    return res;
  }

  render() {
    let tilesHtml = this.board.map((val, idx) => `
      <div class="slide-tile ${val === 0 ? 'empty' : ''}" data-idx="${idx}">
        ${val > 0 ? val : ''}
      </div>
    `).join('');

    this.container.innerHTML = `
      <div class="game-screen-center" style="padding:4px; gap:4px;">
        <div style="font-size:10px; font-weight:800; color:var(--accent-mint);">
          ${this.app.t('moves')}: ${this.moves}
        </div>
        <div class="number-slide-grid">${tilesHtml}</div>
      </div>
    `;

    this.container.querySelectorAll('.slide-tile').forEach(el => {
      el.addEventListener('click', () => {
        const idx = parseInt(el.dataset.idx, 10);
        this.handleTileClick(idx);
      });
    });
  }

  handleTileClick(idx) {
    const blank = this.board.indexOf(0);
    const neighbors = this.getNeighbors(blank);

    if (neighbors.includes(idx)) {
      [this.board[blank], this.board[idx]] = [this.board[idx], this.board[blank]];
      this.moves++;
      document.getElementById('gameCurrentScore').textContent = this.moves;
      audio.playTick();
      this.render();

      if (JSON.stringify(this.board) === JSON.stringify([1, 2, 3, 4, 5, 6, 7, 8, 0])) {
        audio.playVictory();
        Storage.recordScore('numberslide', this.moves);
        this.container.innerHTML = `
          <div class="game-screen-center">
            <h3 style="color:var(--accent-green)">${this.app.t('you_win')}</h3>
            <p>${this.app.lang === 'tr' ? `${this.moves} hamlede çözüldü!` : `Solved in ${this.moves} moves!`}</p>
            <button class="play-btn" id="retrySlideBtn" style="background:var(--accent-mint); color:#000">${this.app.lang === 'tr' ? 'TEKRAR OYNA' : 'PLAY AGAIN'}</button>
          </div>
        `;
        this.container.querySelector('#retrySlideBtn').addEventListener('click', () => this.startGame());
      }
    } else {
      audio.playBounce();
    }
  }

  destroy() {}
}

/* ==========================================================
   GAME 25: LUCKY DICE (ZAR DÜELLOSU)
========================================================== */
class LuckyDiceGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🎲</div>
        <h3>LUCKY DICE</h3>
        <p>${this.app.lang === 'tr' ? '3 zar atın, istediklerinizi tutun ve kombinasyon yapın!' : 'Roll 3 dice, hold numbers, and match poker combos!'}</p>
        <button class="play-btn" id="startDiceBtn" style="background:var(--accent-yellow); color:#000">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startDiceBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.dice = [
      { val: 1, held: false },
      { val: 2, held: false },
      { val: 3, held: false }
    ];
    this.rollsLeft = 2;
    this.totalScore = 0;
    this.lastCombo = '';
    this.render();
  }

  render() {
    const diceHtml = this.dice.map((d, idx) => `
      <div class="die-box ${d.held ? 'held' : ''}" data-idx="${idx}">
        <span class="die-number">${d.val}</span>
        ${d.held ? `<span class="die-held-label">${this.app.lang === 'tr' ? 'KİLİTLİ' : 'HELD'}</span>` : ''}
      </div>
    `).join('');

    this.container.innerHTML = `
      <div class="dice-arena">
        <div style="font-size:10px; font-weight:800; color:var(--accent-yellow);">
          ${this.app.lang === 'tr' ? `Atış: ${this.rollsLeft}/2` : `Rolls: ${this.rollsLeft}/2`} • ${this.app.t('score')}: ${this.totalScore}
        </div>
        <div class="dice-row">${diceHtml}</div>
        <div style="font-size:9px; font-weight:700; color:var(--accent-green); height:14px;">
          ${this.lastCombo}
        </div>
        <button class="play-btn" id="rollDiceBtn" style="background:var(--accent-yellow); color:#000; font-size:10px; padding:6px 14px;">
          ${this.rollsLeft > 0 ? (this.app.lang === 'tr' ? 'ZAR AT' : 'ROLL DICE') : (this.app.lang === 'tr' ? 'YENİ EL' : 'NEW ROUND')}
        </button>
      </div>
    `;

    this.container.querySelectorAll('.die-box').forEach(el => {
      el.addEventListener('click', () => {
        if (this.rollsLeft === 2) return;
        const idx = parseInt(el.dataset.idx, 10);
        this.dice[idx].held = !this.dice[idx].held;
        audio.playTick();
        this.render();
      });
    });

    this.container.querySelector('#rollDiceBtn').addEventListener('click', () => {
      this.handleRoll();
    });
  }

  handleRoll() {
    if (this.rollsLeft === 0) {
      this.dice.forEach(d => d.held = false);
      this.rollsLeft = 2;
      this.lastCombo = '';
      this.render();
      return;
    }

    audio.playDiceRoll();
    for (let i = 0; i < 3; i++) {
      if (!this.dice[i].held) {
        this.dice[i].val = Math.floor(Math.random() * 6) + 1;
      }
    }
    this.rollsLeft--;

    if (this.rollsLeft === 0) {
      this.evaluateHand();
    }
    this.render();
  }

  evaluateHand() {
    const vals = this.dice.map(d => d.val).sort((a, b) => a - b);
    let pts = 0;
    let text = '';

    if (vals[0] === vals[1] && vals[1] === vals[2]) {
      pts = vals[0] * 10 + 100;
      text = this.app.lang === 'tr' ? `ÜÇLÜ ZAR! +${pts}` : `TRIPLES JACKPOT! +${pts}`;
      audio.playVictory();
      Storage.unlockTrophy('luckydice');
    } else if (vals[0] + 1 === vals[1] && vals[1] + 1 === vals[2]) {
      pts = 60;
      text = this.app.lang === 'tr' ? 'DÜZ KENT! +60' : 'STRAIGHT RUN! +60';
      audio.playVictory();
    } else if (vals[0] === vals[1] || vals[1] === vals[2]) {
      const pair = (vals[0] === vals[1]) ? vals[0] : vals[1];
      pts = pair * 4 + 20;
      text = this.app.lang === 'tr' ? `ÇİFT ZAR! +${pts}` : `LUCKY PAIR! +${pts}`;
      audio.playScore();
    } else {
      pts = vals.reduce((a, b) => a + b, 0);
      text = this.app.lang === 'tr' ? `TOPLAM: +${pts}` : `HIGH SUM: +${pts}`;
      audio.playTick();
    }

    this.totalScore += pts;
    this.lastCombo = text;
    document.getElementById('gameCurrentScore').textContent = this.totalScore;
    Storage.recordScore('luckydice', this.totalScore);
  }

  destroy() {}
}

/* ==========================================================
   GAME 26: GALAXY DEFENDER (CROWN RETRO SPACE DEFENSE)
========================================================== */
class GalaxyDefenderGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.animId = null;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🚀</div>
        <h3>GALAXY DEFENDER</h3>
        <p>${this.app.lang === 'tr' ? 'Crown ile tareti sürün, ekrana basıp lazerle uzaylıları vurun!' : 'Steer with Crown, tap to shoot lasers at invaders!'}</p>
        <button class="play-btn" id="startGalaxyBtn" style="background:var(--accent-mint); color:#000">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startGalaxyBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.container.innerHTML = `<canvas class="galaxy-canvas" id="galaxyCv" width="220" height="250"></canvas>`;
    this.canvas = this.container.querySelector('#galaxyCv');
    this.ctx = this.canvas.getContext('2d');

    this.cannonX = 110;
    this.score = 0;
    this.wave = 1;
    this.isGameOver = false;
    this.lasers = [];
    this.aliens = [];
    this.ufo = { x: -30, y: 22, active: false };

    this.spawnWave();

    this.canvas.addEventListener('click', () => this.fireLaser());

    this.lastTime = performance.now();
    const loop = (now) => {
      const dt = (now - this.lastTime) / 1000;
      this.lastTime = now;
      this.update(dt);
      this.draw();
      if (!this.isGameOver) {
        this.animId = requestAnimationFrame(loop);
      }
    };
    this.animId = requestAnimationFrame(loop);
  }

  onCrown(delta) {
    this.cannonX = Math.max(16, Math.min(204, this.cannonX + delta * 12));
  }

  spawnWave() {
    this.aliens = [];
    for (let r = 0; r < 3; r++) {
      for (let c = 0; c < 5; c++) {
        this.aliens.push({
          x: 28 + c * 38,
          y: 40 + r * 22,
          alive: true,
          color: r === 0 ? '#ec4899' : (r === 1 ? '#06b6d4' : '#2dd4bf')
        });
      }
    }
  }

  fireLaser() {
    if (this.isGameOver) {
      this.startGame();
      return;
    }
    audio.playLaser();
    this.lasers.push({ x: this.cannonX, y: 225 });
  }

  update(dt) {
    // Move Lasers
    for (let i = this.lasers.length - 1; i >= 0; i--) {
      this.lasers[i].y -= 260 * dt;
      if (this.lasers[i].y < 0) {
        this.lasers.splice(i, 1);
        continue;
      }
      // Collide with UFO
      if (this.ufo.active && Math.abs(this.lasers[i].x - this.ufo.x) < 16 && Math.abs(this.lasers[i].y - this.ufo.y) < 10) {
        this.ufo.active = false;
        this.lasers.splice(i, 1);
        this.score += 200;
        audio.playScore();
        document.getElementById('gameCurrentScore').textContent = this.score;
        continue;
      }
      // Collide with Aliens
      for (let a of this.aliens) {
        if (a.alive && Math.abs(this.lasers[i].x - a.x) < 14 && Math.abs(this.lasers[i].y - a.y) < 10) {
          a.alive = false;
          this.lasers.splice(i, 1);
          this.score += 25;
          audio.playBounce();
          document.getElementById('gameCurrentScore').textContent = this.score;
          break;
        }
      }
    }

    // Move UFO
    if (this.ufo.active) {
      this.ufo.x += 80 * dt;
      if (this.ufo.x > 250) this.ufo.active = false;
    } else if (Math.random() < 0.005) {
      this.ufo.active = true;
      this.ufo.x = -20;
    }

    // Alien descend
    const aliveAliens = this.aliens.filter(a => a.alive);
    if (aliveAliens.length === 0) {
      this.wave++;
      this.score += 150;
      audio.playVictory();
      Storage.unlockTrophy('galaxydefender');
      this.spawnWave();
      return;
    }

    if (Math.random() < 0.02) {
      for (let a of aliveAliens) {
        a.y += 2 + this.wave * 0.5;
        if (a.y >= 215) {
          this.gameOver();
          return;
        }
      }
    }
  }

  draw() {
    const ctx = this.ctx;
    ctx.fillStyle = '#000';
    ctx.fillRect(0, 0, 220, 250);

    // Stars
    ctx.fillStyle = '#ffffff33';
    ctx.fillRect(30, 20, 1, 1);
    ctx.fillRect(180, 50, 1, 1);
    ctx.fillRect(90, 140, 1, 1);
    ctx.fillRect(150, 200, 1, 1);

    // UFO
    if (this.ufo.active) {
      ctx.font = '16px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('🛸', this.ufo.x, this.ufo.y);
    }

    // Aliens
    ctx.font = '14px sans-serif';
    ctx.textAlign = 'center';
    for (let a of this.aliens) {
      if (a.alive) {
        ctx.fillText('👾', a.x, a.y);
      }
    }

    // Lasers
    ctx.fillStyle = '#facc15';
    for (let l of this.lasers) {
      ctx.fillRect(l.x - 1.5, l.y, 3, 8);
    }

    // Cannon
    ctx.fillStyle = '#2dd4bf';
    ctx.fillRect(this.cannonX - 10, 235, 20, 8);
    ctx.fillRect(this.cannonX - 2, 227, 4, 8);

    if (this.isGameOver) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.8)';
      ctx.fillRect(0, 0, 220, 250);
      ctx.fillStyle = '#ef4444';
      ctx.font = '900 14px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(this.app.lang === 'tr' ? 'ÜS DÜŞTÜ!' : 'BASE DESTROYED', 110, 110);
      ctx.fillStyle = '#fff';
      ctx.font = '700 11px sans-serif';
      ctx.fillText(`${this.score} PTS`, 110, 130);
      ctx.fillStyle = '#2dd4bf';
      ctx.fillText(this.app.lang === 'tr' ? 'TEKRAR İÇİN DOKUN' : 'TAP TO RETRY', 110, 155);
    }
  }

  gameOver() {
    this.isGameOver = true;
    audio.playGameOver();
    Storage.recordScore('galaxydefender', this.score);
  }

  destroy() {
    if (this.animId) cancelAnimationFrame(this.animId);
  }
}

/* ==========================================================
   GAME 27: TOWER STACKER (DENGE KULESİ)
========================================================== */
class TowerStackGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.animId = null;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🏗️</div>
        <h3>TOWER STACKER</h3>
        <p>${this.app.lang === 'tr' ? 'Kayan neon blokları tam üst üste koyarak gökdelen inşa edin!' : 'Stack sliding slabs to build the ultimate skyscraper!'}</p>
        <button class="play-btn" id="startStackBtn" style="background:var(--accent-cyan); color:#000">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startStackBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.container.innerHTML = `<canvas class="stacker-canvas" id="stackCv" width="220" height="250"></canvas>`;
    this.canvas = this.container.querySelector('#stackCv');
    this.ctx = this.canvas.getContext('2d');

    this.colors = ['#06b6d4', '#10b981', '#f59e0b', '#ec4899', '#8b5cf6', '#3b82f6', '#14b8a6'];
    this.tower = [{ x: 110, w: 100, color: '#06b6d4' }];
    this.movingX = 40;
    this.movingW = 100;
    this.dx = 130;
    this.score = 0;
    this.combo = 0;
    this.isGameOver = false;

    this.canvas.addEventListener('click', () => this.placeBlock());

    this.lastTime = performance.now();
    const loop = (now) => {
      const dt = (now - this.lastTime) / 1000;
      this.lastTime = now;
      this.update(dt);
      this.draw();
      if (!this.isGameOver) {
        this.animId = requestAnimationFrame(loop);
      }
    };
    this.animId = requestAnimationFrame(loop);
  }

  placeBlock() {
    if (this.isGameOver) {
      this.startGame();
      return;
    }

    const prev = this.tower[this.tower.length - 1];
    const diff = this.movingX - prev.x;

    if (Math.abs(diff) <= 4) {
      // Perfect align!
      this.combo++;
      audio.playChord(this.combo);
      if (this.combo >= 3) {
        this.movingW = Math.min(110, this.movingW + 10);
      }
      this.tower.push({
        x: prev.x,
        w: this.movingW,
        color: this.colors[this.score % this.colors.length]
      });
    } else if (Math.abs(diff) < this.movingW) {
      // Sliced
      this.combo = 0;
      audio.playTick();
      const newW = this.movingW - Math.abs(diff);
      const newX = prev.x + (diff / 2);
      this.movingW = newW;
      this.tower.push({
        x: newX,
        w: newW,
        color: this.colors[this.score % this.colors.length]
      });
    } else {
      // Total miss
      this.isGameOver = true;
      audio.playGameOver();
      Storage.recordScore('towerstack', this.score);
      return;
    }

    this.score++;
    document.getElementById('gameCurrentScore').textContent = this.score;
    if (this.score >= 10) {
      Storage.unlockTrophy('towerstack');
    }
    Storage.recordScore('towerstack', this.score);

    // Speed up
    const spd = 130 + this.score * 8;
    this.dx = (this.dx > 0 ? 1 : -1) * Math.min(spd, 320);
    this.movingX = this.dx > 0 ? 30 : 190;
  }

  update(dt) {
    this.movingX += this.dx * dt;
    if (this.movingX > 185) {
      this.dx = -Math.abs(this.dx);
    } else if (this.movingX < 35) {
      this.dx = Math.abs(this.dx);
    }
  }

  draw() {
    const ctx = this.ctx;
    ctx.fillStyle = '#050608';
    ctx.fillRect(0, 0, 220, 250);

    const blockH = 14;
    const baseFloorY = 220;

    // Draw top 10 visible tower blocks
    const startIdx = Math.max(0, this.tower.length - 10);
    for (let i = startIdx; i < this.tower.length; i++) {
      const b = this.tower[i];
      const y = baseFloorY - (i - startIdx) * blockH;
      ctx.fillStyle = b.color;
      ctx.shadowColor = b.color;
      ctx.shadowBlur = 6;
      ctx.fillRect(b.x - b.w / 2, y, b.w, blockH - 2);
    }
    ctx.shadowBlur = 0;

    // Draw active moving block
    if (!this.isGameOver) {
      const activeY = baseFloorY - (this.tower.length - startIdx) * blockH;
      const col = this.colors[this.score % this.colors.length];
      ctx.fillStyle = col;
      ctx.shadowColor = col;
      ctx.shadowBlur = 8;
      ctx.fillRect(this.movingX - this.movingW / 2, activeY, this.movingW, blockH - 2);
      ctx.shadowBlur = 0;
    } else {
      ctx.fillStyle = 'rgba(0,0,0,0.82)';
      ctx.fillRect(0, 0, 220, 250);
      ctx.fillStyle = '#ec4899';
      ctx.font = '900 14px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(this.app.lang === 'tr' ? 'KULE YIKILDI!' : 'TOWER TOPPLED', 110, 110);
      ctx.fillStyle = '#fff';
      ctx.font = '700 12px sans-serif';
      ctx.fillText(this.app.lang === 'tr' ? `${this.score} KAT` : `${this.score} FLOORS`, 110, 130);
      ctx.fillStyle = '#06b6d4';
      ctx.fillText(this.app.lang === 'tr' ? 'TEKRAR DENE' : 'TAP TO RETRY', 110, 155);
    }
  }

  destroy() {
    if (this.animId) cancelAnimationFrame(this.animId);
  }
}

/* ==========================================================
   GAME 28: MEMORY MATRIX (CHIMP TEST)
========================================================== */
class MemoryMatrixGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.timeout = null;
    this.showStartScreen();
  }

  showStartScreen() {
    this.container.innerHTML = `
      <div class="game-screen-center">
        <div class="game-large-icon">🧠</div>
        <h3>MEMORY MATRIX</h3>
        <p>${this.app.lang === 'tr' ? 'Sayılar kapanmadan ezberleyin, sonra 1-2-3... sırasıyla dokunun!' : 'Memorize numbers before they hide, then tap them in order!'}</p>
        <button class="play-btn" id="startMatrixBtn" style="background:var(--accent-indigo); color:#fff">${this.app.t('start')}</button>
      </div>
    `;
    this.container.querySelector('#startMatrixBtn').addEventListener('click', () => {
      audio.playTick();
      this.startGame();
    });
  }

  startGame() {
    this.level = 1;
    this.score = 0;
    this.startLevel();
  }

  startLevel() {
    if (this.timeout) clearTimeout(this.timeout);
    this.isShowing = true;
    this.nextTarget = 1;
    this.isGameOver = false;

    const count = Math.min(3 + this.level, 8);
    const slots = [0, 1, 2, 3, 4, 5, 6, 7, 8].sort(() => 0.5 - Math.random());
    this.grid = Array(9).fill(null);

    for (let i = 0; i < count; i++) {
      this.grid[slots[i]] = { num: i + 1, cleared: false };
    }

    this.render();

    const hideDelay = Math.max(1600 - this.level * 100, 800);
    this.timeout = setTimeout(() => {
      this.isShowing = false;
      this.render();
    }, hideDelay);
  }

  render() {
    let cellsHtml = this.grid.map((cell, idx) => {
      if (!cell) {
        return `<div class="matrix-tile empty"></div>`;
      }
      if (cell.cleared) {
        return `<div class="matrix-tile cleared">${cell.num}</div>`;
      }
      if (this.isShowing) {
        return `<div class="matrix-tile active-number">${cell.num}</div>`;
      }
      return `<div class="matrix-tile masked" data-idx="${idx}"></div>`;
    }).join('');

    this.container.innerHTML = `
      <div class="matrix-container">
        <div style="display:flex; justify-content:space-between; font-size:9px; font-weight:800; color:var(--accent-indigo); padding:2px 4px;">
          <span>${this.app.lang === 'tr' ? `Seviye: ${this.level}` : `Level: ${this.level}`}</span>
          <span>${this.app.t('score')}: ${this.score}</span>
        </div>
        <div style="text-align:center; font-size:8px; font-weight:700; color:${this.isShowing ? 'var(--accent-cyan)' : 'var(--accent-yellow)'}">
          ${this.isShowing ? (this.app.lang === 'tr' ? 'Sayıları Ezberle!' : 'Memorize Numbers!') : (this.app.lang === 'tr' ? `Sıradaki: ${this.nextTarget}` : `Next Target: ${this.nextTarget}`)}
        </div>
        <div class="matrix-grid">${cellsHtml}</div>
      </div>
    `;

    if (!this.isShowing) {
      this.container.querySelectorAll('.matrix-tile.masked').forEach(el => {
        el.addEventListener('click', () => {
          const idx = parseInt(el.dataset.idx, 10);
          this.handleTileTap(idx);
        });
      });
    }
  }

  handleTileTap(idx) {
    const cell = this.grid[idx];
    if (!cell || cell.cleared || this.isShowing || this.isGameOver) return;

    if (cell.num === this.nextTarget) {
      cell.cleared = true;
      audio.playTick();
      const count = Math.min(3 + this.level, 8);

      if (this.nextTarget === count) {
        // Level Complete!
        audio.playVictory();
        this.score += this.level * 50;
        document.getElementById('gameCurrentScore').textContent = this.score;
        Storage.recordScore('memorymatrix', this.score);
        if (this.level >= 3) {
          Storage.unlockTrophy('memorymatrix');
        }
        this.level++;
        this.startLevel();
      } else {
        this.nextTarget++;
        this.render();
      }
    } else {
      // Wrong sequence
      this.isGameOver = true;
      audio.playGameOver();
      Storage.recordScore('memorymatrix', this.score);
      this.container.innerHTML = `
        <div class="game-screen-center">
          <h3 style="color:var(--accent-red)">${this.app.lang === 'tr' ? 'HATALI DOKUNUŞ!' : 'WRONG NUMBER!'}</h3>
          <p>${this.app.lang === 'tr' ? `${this.score} Puan • Seviye ${this.level}` : `${this.score} Points • Level ${this.level}`}</p>
          <button class="play-btn" id="retryMatrixBtn" style="background:var(--accent-indigo); color:#fff">${this.app.lang === 'tr' ? 'TEKRAR DENE' : 'TRY AGAIN'}</button>
        </div>
      `;
      this.container.querySelector('#retryMatrixBtn').addEventListener('click', () => {
        this.startGame();
      });
    }
  }

  destroy() {
    if (this.timeout) clearTimeout(this.timeout);
  }
}

// ==========================================
// 1. LUCKY ROULETTE GAME
// ==========================================
class LuckyRouletteGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.chips = 100;
    this.currentBet = 10;
    this.selectedBetType = 'red';
    this.wheelAngle = 0;
    this.isSpinning = false;
    this.winningNumber = null;
    this.resultMessage = '';
    this.redNumbers = new Set([1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]);
    this.render();
  }

  onCrown(delta) {
    if (!this.isSpinning) {
      this.wheelAngle += delta * 25;
      const wheel = this.container.querySelector('#rouletteWheel');
      if (wheel) wheel.style.transform = `rotate(${this.wheelAngle}deg)`;
    }
  }

  render() {
    const isTr = this.app.lang === 'tr';
    let numBadge = '🎡';
    let numClass = '';
    let subBadge = isTr ? 'ÇARK' : 'WHEEL';

    if (this.winningNumber !== null) {
      numBadge = this.winningNumber;
      if (this.winningNumber === 0) {
        numClass = 'green';
        subBadge = 'ZERO';
      } else if (this.redNumbers.has(this.winningNumber)) {
        numClass = 'red';
        subBadge = 'RED';
      } else {
        numClass = 'black';
        subBadge = 'BLK';
      }
    }

    this.container.innerHTML = `
      <div class="roulette-container">
        <div style="display:flex; justify-content:space-between; font-size:9px; font-weight:800; padding:0 4px;">
          <span style="color:var(--accent-yellow)">${isTr ? 'KASA' : 'BANK'}: $${this.chips}</span>
          <span style="color:var(--accent-cyan)">${isTr ? 'BAHİS' : 'BET'}: $${this.currentBet}</span>
        </div>

        <div class="roulette-wheel-box" id="rouletteWheel" style="transform: rotate(${this.wheelAngle}deg)">
          <div class="roulette-inner-hub">
            <span class="roulette-number-badge ${numClass}">${numBadge}</span>
            <span class="roulette-sub-badge">${subBadge}</span>
          </div>
        </div>

        <div style="text-align:center; min-height:14px; font-size:9px; font-weight:800; color:${this.resultMessage.includes('+') ? '#10b981' : '#f59e0b'}">
          ${this.resultMessage}
        </div>

        <div class="roulette-bets-row">
          <button class="roulette-bet-btn bet-red ${this.selectedBetType === 'red' ? 'active' : ''}" data-bet="red">RED (2x)</button>
          <button class="roulette-bet-btn bet-black ${this.selectedBetType === 'black' ? 'active' : ''}" data-bet="black">BLK (2x)</button>
          <button class="roulette-bet-btn bet-even ${this.selectedBetType === 'even' ? 'active' : ''}" data-bet="even">EVEN (2x)</button>
          <button class="roulette-bet-btn bet-odd ${this.selectedBetType === 'odd' ? 'active' : ''}" data-bet="odd">ODD (2x)</button>
        </div>

        <button class="play-btn" id="btnSpinWheel" style="background:var(--accent-red); color:#fff; min-height:26px;" ${this.isSpinning || this.chips < 10 ? 'disabled' : ''}>
          ${this.isSpinning ? (isTr ? 'DÖNÜYOR...' : 'SPINNING...') : (isTr ? 'ÇARK ÇEVİR ($10)' : 'SPIN WHEEL ($10)')}
        </button>

        ${this.chips < 10 && !this.isSpinning ? `
          <button class="play-btn" id="btnReloadChips" style="background:var(--accent-yellow); color:#000; font-size:9px; min-height:20px; margin-top:2px;">
            ${isTr ? 'KASAYI DOLDUR ($100)' : 'RELOAD BANK ($100)'}
          </button>
        ` : ''}
      </div>
    `;

    this.bindEvents();
  }

  bindEvents() {
    this.container.querySelectorAll('.roulette-bet-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        if (this.isSpinning) return;
        audio.playTick();
        this.selectedBetType = btn.dataset.bet;
        this.render();
      });
    });

    const spinBtn = this.container.querySelector('#btnSpinWheel');
    if (spinBtn) {
      spinBtn.addEventListener('click', () => this.spin());
    }

    const reloadBtn = this.container.querySelector('#btnReloadChips');
    if (reloadBtn) {
      reloadBtn.addEventListener('click', () => {
        audio.playVictory();
        this.chips = 100;
        this.resultMessage = this.app.lang === 'tr' ? '+$100 Eklendi!' : '+$100 Reloaded!';
        this.render();
      });
    }
  }

  spin() {
    if (this.isSpinning || this.chips < this.currentBet) return;
    this.chips -= this.currentBet;
    this.isSpinning = true;
    this.resultMessage = '';
    audio.playDiceRoll();

    const extraRounds = 4 + Math.floor(Math.random() * 4);
    const targetDeg = this.wheelAngle + extraRounds * 360 + Math.floor(Math.random() * 360);
    this.wheelAngle = targetDeg;

    const wheel = this.container.querySelector('#rouletteWheel');
    if (wheel) {
      wheel.style.transform = `rotate(${this.wheelAngle}deg)`;
    }

    const spinBtn = this.container.querySelector('#btnSpinWheel');
    if (spinBtn) {
      spinBtn.disabled = true;
      spinBtn.textContent = this.app.lang === 'tr' ? 'DÖNÜYOR...' : 'SPINNING...';
    }

    setTimeout(() => {
      this.isSpinning = false;
      const landed = Math.floor(Math.random() * 37); // 0 to 36
      this.winningNumber = landed;

      let won = false;
      let payout = 0;

      if (this.selectedBetType === 'red' && this.redNumbers.has(landed)) {
        won = true; payout = this.currentBet * 2;
      } else if (this.selectedBetType === 'black' && landed !== 0 && !this.redNumbers.has(landed)) {
        won = true; payout = this.currentBet * 2;
      } else if (this.selectedBetType === 'even' && landed !== 0 && landed % 2 === 0) {
        won = true; payout = this.currentBet * 2;
      } else if (this.selectedBetType === 'odd' && landed % 2 === 1) {
        won = true; payout = this.currentBet * 2;
      }

      if (won) {
        this.chips += payout;
        audio.playVictory();
        this.resultMessage = this.app.lang === 'tr' ? `KAZANDIN! +$${payout}` : `YOU WON! +$${payout}`;
        Storage.recordScore('luckyroulette', this.chips);
      } else {
        audio.playGameOver();
        this.resultMessage = this.app.lang === 'tr' ? 'KAYBETTİN (-$10)' : 'LOST (-$10)';
      }

      const scoreDisplay = document.getElementById('gameCurrentScore');
      if (scoreDisplay) scoreDisplay.textContent = `$${this.chips}`;

      this.render();
    }, 2200);
  }

  destroy() {}
}

// ==========================================
// 2. DEEP SEA REEL GAME
// ==========================================
class DeepSeaReelGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.state = 'idle'; // idle, waitingBite, hooked, caught, snapped, escaped
    this.distance = 40.0;
    this.tension = 50.0;
    this.fishName = '';
    this.fishWeight = 0;
    this.score = 0;
    this.statusMsg = '';
    this.timer = null;
    this.biteTimeout = null;
    this.render();
  }

  onCrown(delta) {
    if (this.state === 'hooked') {
      this.reelStep(Math.abs(delta) * 1.5);
    }
  }

  reelStep(multiplier = 1.0) {
    if (this.state !== 'hooked') return;
    audio.playTick();
    this.distance = Math.max(0, this.distance - 2.0 * multiplier);
    this.tension = Math.min(100, this.tension + 5.5 * multiplier);

    if (this.distance <= 0) {
      this.catchFish();
    } else {
      this.updateVisuals();
    }
  }

  render() {
    const isTr = this.app.lang === 'tr';
    let contentHtml = '';

    if (this.state === 'idle') {
      contentHtml = `
        <div style="font-size:28px;">🎣</div>
        <div style="font-size:9px; color:rgba(255,255,255,0.8);">${isTr ? 'Oltayı denize fırlatın' : 'Cast line to fish'}</div>
      `;
    } else if (this.state === 'waitingBite') {
      contentHtml = `
        <div style="font-size:20px; animation:spin 1s linear infinite;">🌊</div>
        <div style="font-size:9px; font-weight:800; color:var(--accent-cyan);">${isTr ? 'Balık bekleniyor...' : 'Waiting for bite...'}</div>
      `;
    } else if (this.state === 'hooked') {
      const tensionPercent = Math.min(100, Math.max(0, this.tension));
      let barColor = '#f59e0b';
      if (tensionPercent < 25) barColor = '#3b82f6';
      else if (tensionPercent > 80) barColor = '#ef4444';
      else if (tensionPercent >= 40 && tensionPercent <= 75) barColor = '#10b981';

      contentHtml = `
        <div style="font-size:9px; font-weight:900; color:var(--accent-yellow);">⚠️ ${isTr ? 'VURDU! CROWN ÇEVİR' : 'HOOKED! REEL CROWN'}</div>
        <div class="fishing-depth-label">${Math.ceil(this.distance)}m ${isTr ? 'Kaldı' : 'Left'}</div>
        <div class="fishing-tension-wrapper">
          <div class="fishing-sweet-zone"></div>
          <div class="fishing-tension-bar" style="width:${tensionPercent}%; background-color:${barColor}"></div>
        </div>
      `;
    } else if (this.state === 'caught') {
      contentHtml = `
        <div style="font-size:24px;">🏆</div>
        <div style="font-size:10px; font-weight:900; color:#10b981;">${this.fishName} (${this.fishWeight.toFixed(1)} kg)</div>
      `;
    } else {
      contentHtml = `
        <div style="font-size:22px;">❌</div>
        <div style="font-size:9px; font-weight:800; color:var(--accent-red);">${this.statusMsg}</div>
      `;
    }

    this.container.innerHTML = `
      <div class="fishing-container">
        <div class="fishing-ocean-card" id="oceanCard">
          ${contentHtml}
        </div>

        ${this.state === 'hooked' ? `
          <button class="play-btn" id="btnTapReel" style="background:var(--accent-cyan); color:#000; min-height:28px;">
            ${isTr ? 'DOKUN / CROWN ÇEVİR' : 'TAP / REEL CROWN'}
          </button>
        ` : `
          <button class="play-btn" id="btnCastLine" style="background:var(--accent-blue); color:#fff; min-height:28px;">
            ${isTr ? 'OLTA FIRLAT' : 'CAST LINE'}
          </button>
        `}
      </div>
    `;

    const castBtn = this.container.querySelector('#btnCastLine');
    if (castBtn) {
      castBtn.addEventListener('click', () => this.cast());
    }

    const reelBtn = this.container.querySelector('#btnTapReel');
    if (reelBtn) {
      reelBtn.addEventListener('click', () => this.reelStep(1.2));
    }
  }

  updateVisuals() {
    if (this.state !== 'hooked') return;
    const isTr = this.app.lang === 'tr';
    const depthLabel = this.container.querySelector('.fishing-depth-label');
    if (depthLabel) depthLabel.textContent = `${Math.ceil(this.distance)}m ${isTr ? 'Kaldı' : 'Left'}`;

    const tensionBar = this.container.querySelector('.fishing-tension-bar');
    if (tensionBar) {
      const tensionPercent = Math.min(100, Math.max(0, this.tension));
      tensionBar.style.width = `${tensionPercent}%`;
      let barColor = '#f59e0b';
      if (tensionPercent < 25) barColor = '#3b82f6';
      else if (tensionPercent > 80) barColor = '#ef4444';
      else if (tensionPercent >= 40 && tensionPercent <= 75) barColor = '#10b981';
      tensionBar.style.backgroundColor = barColor;
    }
  }

  cast() {
    audio.playTick();
    this.state = 'waitingBite';
    this.render();

    const delay = 1500 + Math.random() * 2000;
    this.biteTimeout = setTimeout(() => {
      audio.playScore();
      this.state = 'hooked';
      this.distance = 35 + Math.floor(Math.random() * 30);
      this.tension = 50.0;

      const species = [
        ['Bluefin Tuna', 42.0],
        ['Striped Marlin', 68.0],
        ['King Salmon', 14.5],
        ['Swordfish', 55.0],
        ['Tiger Shark', 92.0]
      ];
      const pick = species[Math.floor(Math.random() * species.length)];
      this.fishName = pick[0];
      this.fishWeight = pick[1] + (Math.random() * 8 - 4);

      this.render();
      this.startLoop();
    }, delay);
  }

  startLoop() {
    if (this.timer) clearInterval(this.timer);
    this.timer = setInterval(() => {
      if (this.state !== 'hooked') return;

      this.tension -= 2.2; // natural decay
      if (Math.random() > 0.55) {
        this.tension += 3.0 + Math.random() * 4.0; // fish tug
      }

      if (this.tension >= 98) {
        this.state = 'snapped';
        audio.playGameOver();
        this.statusMsg = this.app.lang === 'tr' ? 'Misina koptu! (Aşırı Gerilim)' : 'Line snapped! (High Tension)';
        clearInterval(this.timer);
        this.render();
      } else if (this.tension <= 5) {
        this.state = 'escaped';
        audio.playGameOver();
        this.statusMsg = this.app.lang === 'tr' ? 'Balık kaçtı! (Gevşek Misina)' : 'Fish escaped! (Line Slack)';
        clearInterval(this.timer);
        this.render();
      } else {
        this.updateVisuals();
      }
    }, 120);
  }

  catchFish() {
    clearInterval(this.timer);
    this.state = 'caught';
    audio.playVictory();
    const gained = Math.round(this.fishWeight * 10);
    this.score += gained;
    document.getElementById('gameCurrentScore').textContent = this.score;
    Storage.recordScore('deepreel', this.score);
    this.render();
  }

  destroy() {
    if (this.timer) clearInterval(this.timer);
    if (this.biteTimeout) clearTimeout(this.biteTimeout);
  }
}

// ==========================================
// 3. HIGHWAY RACER GAME
// ==========================================
class HighwayRacerGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.playerLane = 1; // 0: Left, 1: Center, 2: Right
    this.traffic = [];
    this.distance = 0;
    this.nitroUnits = 0;
    this.isNitro = false;
    this.isGameOver = false;
    this.isPlaying = false;
    this.loopTimer = null;
    this.nitroTimeout = null;
    this.render();
  }

  onCrown(delta) {
    if (!this.isPlaying || this.isGameOver) return;
    if (delta > 0 && this.playerLane < 2) {
      this.shift(1);
    } else if (delta < 0 && this.playerLane > 0) {
      this.shift(-1);
    }
  }

  shift(dir) {
    audio.playTick();
    this.playerLane = Math.max(0, Math.min(2, this.playerLane + dir));
    this.updatePlayerCar();
  }

  render() {
    const isTr = this.app.lang === 'tr';
    this.container.innerHTML = `
      <div class="racer-container">
        <div style="display:flex; justify-content:space-between; align-items:center; font-size:9px; font-weight:800; padding:0 4px;">
          <span style="color:#ffffff">${this.distance}m</span>
          ${this.nitroUnits > 0 ? `
            <button id="btnTriggerNitro" style="background:${this.isNitro ? 'var(--accent-cyan)' : 'var(--accent-yellow)'}; color:#000; font-size:8px; font-weight:900; border-radius:4px; padding:2px 6px; border:none; cursor:pointer;">
              ⚡ NITRO x${this.nitroUnits}
            </button>
          ` : ''}
        </div>

        <div class="racer-road ${this.isNitro ? 'nitro-boost' : ''}" id="racerRoad">
          <div class="racer-lane-divider div-1"></div>
          <div class="racer-lane-divider div-2"></div>
          <div id="trafficLayer"></div>
          <div class="racer-car player ${this.isNitro ? 'nitro' : ''}" id="playerCar" style="left:50%">
            <div style="width:4px; height:4px; border-radius:50%; background:#fff;"></div>
            <div style="width:14px; height:6px; background:rgba(0,0,0,0.6); border-radius:2px;"></div>
            <div style="width:4px; height:4px; border-radius:50%; background:#ef4444;"></div>
          </div>

          ${this.isGameOver ? `
            <div style="position:absolute; inset:0; background:rgba(0,0,0,0.85); display:flex; flex-direction:column; align-items:center; justify-content:center; gap:4px; z-index:10;">
              <div style="font-size:11px; font-weight:900; color:var(--accent-red);">${isTr ? 'KAZA YAPTIN!' : 'CRASHED!'}</div>
              <div style="font-size:9px; font-weight:800; color:#fff;">${this.distance}m</div>
              <button class="play-btn" id="btnRestartRacer" style="background:var(--accent-yellow); color:#000; font-size:9px; min-height:22px; padding:2px 10px;">
                ${isTr ? 'TEKRAR OYNA' : 'PLAY AGAIN'}
              </button>
            </div>
          ` : (!this.isPlaying ? `
            <div style="position:absolute; inset:0; background:rgba(0,0,0,0.7); display:flex; flex-direction:column; align-items:center; justify-content:center; gap:6px; z-index:10;">
              <button class="play-btn" id="btnStartRacer" style="background:var(--accent-yellow); color:#000; font-size:11px; min-height:28px; padding:4px 16px;">
                ${isTr ? 'YARIŞA BAŞLA' : 'START DRIVE'}
              </button>
            </div>
          ` : '')}
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:4px;">
          <button class="play-btn" id="btnLaneLeft" style="background:rgba(255,255,255,0.1); color:#fff; min-height:22px; font-size:9px;">
            ◀ ${isTr ? 'SOL' : 'LEFT'}
          </button>
          <button class="play-btn" id="btnLaneRight" style="background:rgba(255,255,255,0.1); color:#fff; min-height:22px; font-size:9px;">
            ${isTr ? 'SAĞ' : 'RIGHT'} ▶
          </button>
        </div>
      </div>
    `;

    this.bindControls();
    this.updatePlayerCar();
  }

  bindControls() {
    const startBtn = this.container.querySelector('#btnStartRacer');
    if (startBtn) startBtn.addEventListener('click', () => this.startGame());

    const restartBtn = this.container.querySelector('#btnRestartRacer');
    if (restartBtn) restartBtn.addEventListener('click', () => this.startGame());

    const leftBtn = this.container.querySelector('#btnLaneLeft');
    if (leftBtn) leftBtn.addEventListener('click', () => {
      if (this.playerLane > 0) this.shift(-1);
    });

    const rightBtn = this.container.querySelector('#btnLaneRight');
    if (rightBtn) rightBtn.addEventListener('click', () => {
      if (this.playerLane < 2) this.shift(1);
    });

    const nitroBtn = this.container.querySelector('#btnTriggerNitro');
    if (nitroBtn) nitroBtn.addEventListener('click', () => this.activateNitro());
  }

  updatePlayerCar() {
    const car = this.container.querySelector('#playerCar');
    if (!car) return;
    const lanePercents = [16.66, 50.0, 83.33];
    car.style.left = `${lanePercents[this.playerLane]}%`;
  }

  startGame() {
    audio.playTick();
    this.isPlaying = true;
    this.isGameOver = false;
    this.distance = 0;
    this.nitroUnits = 0;
    this.isNitro = false;
    this.traffic = [];
    this.playerLane = 1;
    this.render();

    if (this.loopTimer) clearInterval(this.loopTimer);
    this.loopTimer = setInterval(() => this.gameLoop(), 50);
  }

  activateNitro() {
    if (this.nitroUnits <= 0 || this.isNitro) return;
    audio.playVictory();
    this.nitroUnits--;
    this.isNitro = true;
    this.render();

    if (this.nitroTimeout) clearTimeout(this.nitroTimeout);
    this.nitroTimeout = setTimeout(() => {
      this.isNitro = false;
      this.render();
    }, 3000);
  }

  gameLoop() {
    if (!this.isPlaying || this.isGameOver) return;

    this.distance += this.isNitro ? 3 : 1;
    document.getElementById('gameCurrentScore').textContent = this.distance;

    // Spawn new obstacles or nitro
    if (Math.random() < 0.08) {
      const lane = Math.floor(Math.random() * 3);
      const isNitroItem = Math.random() < 0.15;
      this.traffic.push({
        id: Math.random(),
        lane,
        y: -30,
        isNitro: isNitroItem
      });
    }

    const roadHeight = 110;
    const speed = this.isNitro ? 8.5 : 4.5;
    const lanePercents = [16.66, 50.0, 83.33];

    // Move traffic
    this.traffic.forEach(item => { item.y += speed; });

    // Check collisions
    for (let i = this.traffic.length - 1; i >= 0; i--) {
      const item = this.traffic[i];
      if (item.y >= roadHeight - 40 && item.y <= roadHeight - 5 && item.lane === this.playerLane) {
        if (item.isNitro) {
          audio.playTick();
          this.nitroUnits = Math.min(3, this.nitroUnits + 1);
          this.traffic.splice(i, 1);
          this.render();
          return;
        } else if (!this.isNitro) {
          // Crash!
          audio.playGameOver();
          this.isGameOver = true;
          clearInterval(this.loopTimer);
          Storage.recordScore('highwayracer', this.distance);
          this.render();
          return;
        }
      } else if (item.y > roadHeight + 20) {
        this.traffic.splice(i, 1);
      }
    }

    // Render traffic layer
    const layer = this.container.querySelector('#trafficLayer');
    if (layer) {
      let layerHtml = '';
      this.traffic.forEach(t => {
        if (t.isNitro) {
          layerHtml += `<div class="racer-nitro-item" style="left:${lanePercents[t.lane]}%; top:${t.y}px;">⚡</div>`;
        } else {
          layerHtml += `
            <div class="racer-car traffic" style="left:${lanePercents[t.lane]}%; top:${t.y}px;">
              <div style="width:4px; height:4px; border-radius:50%; background:#facc15;"></div>
              <div style="width:14px; height:6px; background:rgba(0,0,0,0.6); border-radius:2px;"></div>
              <div style="width:4px; height:4px; border-radius:50%; background:#ef4444;"></div>
            </div>
          `;
        }
      });
      layer.innerHTML = layerHtml;
    }
  }

  destroy() {
    if (this.loopTimer) clearInterval(this.loopTimer);
    if (this.nitroTimeout) clearTimeout(this.nitroTimeout);
  }
}

// ==========================================
// 4. BULLSEYE ARCHERY GAME
// ==========================================
class BullseyeArcheryGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.arrowsLeft = 5;
    this.score = 0;
    this.windX = (Math.random() * 4 - 2).toFixed(1);
    this.lastHit = null;
    this.lastScore = 0;
    this.isDrawing = false;
    this.isGameOver = false;
    this.render();
  }

  render() {
    const isTr = this.app.lang === 'tr';
    this.container.innerHTML = `
      <div class="archery-container">
        <div style="display:flex; justify-content:space-between; align-items:center; font-size:9px; font-weight:800; padding:0 4px;">
          <span style="color:#ffffff">${isTr ? 'OK' : 'ARROWS'}: ${this.arrowsLeft}/5</span>
          <span style="color:var(--accent-cyan)">💨 ${Math.abs(this.windX)}m/s ${parseFloat(this.windX) >= 0 ? '▶' : '◀'}</span>
        </div>

        <div class="archery-target-board" id="targetBoard">
          <div class="archery-ring-black">
            <div class="archery-ring-blue">
              <div class="archery-ring-red">
                <div class="archery-ring-gold"></div>
              </div>
            </div>
          </div>
          ${this.lastHit ? `
            <div class="archery-hit-dot" style="left:${this.lastHit.x}px; top:${this.lastHit.y}px;"></div>
          ` : ''}
          <div class="archery-crosshair" id="crosshair" style="display:none;">🎯</div>
        </div>

        <div style="text-align:center; min-height:14px; font-size:9px; font-weight:900; color:${this.lastScore >= 8 ? '#facc15' : '#ffffff'}">
          ${this.lastScore > 0 ? (this.lastScore === 10 ? (isTr ? 'TAM İSABET! (BULLSEYE 10P)' : 'PERFECT BULLSEYE! (10 PTS)') : `+${this.lastScore} ${isTr ? 'PUAN' : 'PTS'}`) : (isTr ? 'Hedefe basılı tut ve oku fırlat' : 'Hold target & release arrow')}
        </div>

        ${this.isGameOver ? `
          <button class="play-btn" id="btnRestartArchery" style="background:var(--accent-orange); color:#fff; min-height:26px;">
            ${isTr ? 'YENİ TUR' : 'NEW ROUND'}
          </button>
        ` : ''}
      </div>
    `;

    this.bindTargetEvents();
  }

  bindTargetEvents() {
    const board = this.container.querySelector('#targetBoard');
    if (!board) return;

    const crosshair = board.querySelector('#crosshair');

    const onDown = (e) => {
      if (this.arrowsLeft <= 0 || this.isGameOver) return;
      this.isDrawing = true;
      audio.playTick();
      const rect = board.getBoundingClientRect();
      const clientX = e.clientX || (e.touches && e.touches[0].clientX);
      const clientY = e.clientY || (e.touches && e.touches[0].clientY);
      const x = clientX - rect.left;
      const y = clientY - rect.top;
      if (crosshair) {
        crosshair.style.display = 'block';
        crosshair.style.left = `${x}px`;
        crosshair.style.top = `${y}px`;
      }
    };

    const onMove = (e) => {
      if (!this.isDrawing) return;
      const rect = board.getBoundingClientRect();
      const clientX = e.clientX || (e.touches && e.touches[0].clientX);
      const clientY = e.clientY || (e.touches && e.touches[0].clientY);
      const x = clientX - rect.left;
      const y = clientY - rect.top;
      if (crosshair) {
        crosshair.style.left = `${x}px`;
        crosshair.style.top = `${y}px`;
      }
    };

    const onUp = (e) => {
      if (!this.isDrawing) return;
      this.isDrawing = false;
      if (crosshair) crosshair.style.display = 'none';

      const rect = board.getBoundingClientRect();
      const clientX = e.clientX || (e.changedTouches && e.changedTouches[0].clientX);
      const clientY = e.clientY || (e.changedTouches && e.changedTouches[0].clientY);
      let aimX = (clientX - rect.left) || 53;
      let aimY = (clientY - rect.top) || 53;

      // Apply wind physics
      const windOffset = parseFloat(this.windX) * 9.0;
      const finalX = Math.max(4, Math.min(102, aimX + windOffset));
      const finalY = Math.max(4, Math.min(102, aimY));

      this.shoot(finalX, finalY);
    };

    board.addEventListener('mousedown', onDown);
    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseup', onUp);

    board.addEventListener('touchstart', onDown, { passive: true });
    window.addEventListener('touchmove', onMove, { passive: true });
    window.addEventListener('touchend', onUp);

    const restartBtn = this.container.querySelector('#btnRestartArchery');
    if (restartBtn) {
      restartBtn.addEventListener('click', () => {
        this.arrowsLeft = 5;
        this.score = 0;
        this.lastHit = null;
        this.lastScore = 0;
        this.isGameOver = false;
        this.windX = (Math.random() * 4 - 2).toFixed(1);
        document.getElementById('gameCurrentScore').textContent = '0';
        this.render();
      });
    }
  }

  shoot(x, y) {
    this.arrowsLeft--;
    this.lastHit = { x, y };

    const centerX = 53;
    const centerY = 53;
    const dist = Math.sqrt((x - centerX) ** 2 + (y - centerY) ** 2);

    let pts = 0;
    if (dist <= 8) pts = 10;
    else if (dist <= 17) pts = 8;
    else if (dist <= 27) pts = 6;
    else if (dist <= 38) pts = 4;
    else if (dist <= 50) pts = 2;

    this.lastScore = pts;
    this.score += pts;
    document.getElementById('gameCurrentScore').textContent = this.score;

    if (pts >= 8) {
      audio.playVictory();
    } else if (pts > 0) {
      audio.playScore();
    } else {
      audio.playGameOver();
    }

    // Shift wind for next arrow
    this.windX = (Math.random() * 5 - 2.5).toFixed(1);

    if (this.arrowsLeft <= 0) {
      this.isGameOver = true;
      Storage.recordScore('bullseyearchery', this.score);
    }

    this.render();
  }

  destroy() {}
}

class BaccaratGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.bankroll = 100;
    this.betAmount = 10;
    this.betTarget = 'player'; // 'player', 'banker', 'tie'
    this.playerHand = [];
    this.bankerHand = [];
    this.statusText = '';
    this.state = 'betting'; // 'betting', 'dealing', 'result'
    this.render();
  }

  cardVal(card) {
    if (['10', 'J', 'Q', 'K'].includes(card.rank)) return 0;
    if (card.rank === 'A') return 1;
    return parseInt(card.rank, 10);
  }

  handTotal(hand) {
    const sum = hand.reduce((acc, c) => acc + this.cardVal(c), 0);
    return sum % 10;
  }

  drawCard() {
    const ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
    const suits = ['♠', '♥', '♦', '♣'];
    const rank = ranks[Math.floor(Math.random() * ranks.length)];
    const suit = suits[Math.floor(Math.random() * suits.length)];
    return { rank, suit, isRed: (suit === '♥' || suit === '♦') };
  }

  deal() {
    if (this.bankroll < this.betAmount) {
      this.bankroll = 50;
    }
    this.bankroll -= this.betAmount;
    this.state = 'dealing';
    audio.playTick();

    this.playerHand = [this.drawCard(), this.drawCard()];
    this.bankerHand = [this.drawCard(), this.drawCard()];

    let pTotal = this.handTotal(this.playerHand);
    let bTotal = this.handTotal(this.bankerHand);

    // Natural 8 or 9
    if (pTotal >= 8 || bTotal >= 8) {
      this.finishHand(pTotal, bTotal);
      return;
    }

    // Player draws if <= 5
    let playerDrew = false;
    let p3Val = -1;
    if (pTotal <= 5) {
      const c3 = this.drawCard();
      this.playerHand.push(c3);
      playerDrew = true;
      p3Val = this.cardVal(c3);
      pTotal = this.handTotal(this.playerHand);
    }

    // Banker drawing rules
    if (!playerDrew) {
      if (bTotal <= 5) {
        this.bankerHand.push(this.drawCard());
        bTotal = this.handTotal(this.bankerHand);
      }
    } else {
      let bDraw = false;
      if (bTotal <= 2) bDraw = true;
      else if (bTotal === 3 && p3Val !== 8) bDraw = true;
      else if (bTotal === 4 && [2, 3, 4, 5, 6, 7].includes(p3Val)) bDraw = true;
      else if (bTotal === 5 && [4, 5, 6, 7].includes(p3Val)) bDraw = true;
      else if (bTotal === 6 && [6, 7].includes(p3Val)) bDraw = true;

      if (bDraw) {
        this.bankerHand.push(this.drawCard());
        bTotal = this.handTotal(this.bankerHand);
      }
    }

    this.finishHand(pTotal, bTotal);
  }

  finishHand(pTotal, bTotal) {
    this.state = 'result';
    let winner = 'tie';
    if (pTotal > bTotal) winner = 'player';
    else if (bTotal > pTotal) winner = 'banker';

    const isTr = this.app.lang === 'tr';
    let won = false;
    let payout = 0;

    if (winner === this.betTarget) {
      won = true;
      if (this.betTarget === 'player') payout = this.betAmount * 2;
      else if (this.betTarget === 'banker') payout = Math.floor(this.betAmount * 1.95);
      else if (this.betTarget === 'tie') payout = this.betAmount * 9;
      this.bankroll += payout;
      this.statusText = isTr ? `KAZANDIN! (+${payout})` : `YOU WON! (+${payout})`;
      audio.playVictory();
    } else if (winner === 'tie' && this.betTarget !== 'tie') {
      this.bankroll += this.betAmount;
      this.statusText = isTr ? 'BERABERE (İade)' : 'PUSH (Refund)';
      audio.playScore();
    } else {
      this.statusText = isTr ? `KAYBETTİN! (-${this.betAmount})` : `HOUSE WON! (-${this.betAmount})`;
      audio.playGameOver();
    }

    Storage.recordScore('baccarat', this.bankroll);
    const scoreEl = document.getElementById('gameCurrentScore');
    if (scoreEl) scoreEl.textContent = this.bankroll;
    this.render();
  }

  render() {
    const isTr = this.app.lang === 'tr';
    const pTotal = this.playerHand.length ? this.handTotal(this.playerHand) : 0;
    const bTotal = this.bankerHand.length ? this.handTotal(this.bankerHand) : 0;

    const renderCards = (cards) => cards.map(c => `
      <div class="playing-card ${c.isRed ? 'red' : 'black'}" style="width:28px; height:40px; font-size:11px; padding:2px;">
        <span class="card-rank">${c.rank}</span>
        <span class="card-suit" style="font-size:12px;">${c.suit}</span>
      </div>
    `).join('');

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; justify-content:space-between; height:100%; width:100%; padding:4px; box-sizing:border-box;">
        <!-- Top: Banker -->
        <div style="display:flex; flex-direction:column; align-items:center; width:100%;">
          <div style="font-size:10px; font-weight:700; color:var(--accent-red); margin-bottom:2px;">
            🏦 ${isTr ? 'KASA' : 'BANKER'} (${bTotal})
          </div>
          <div style="display:flex; gap:4px; min-height:42px; align-items:center;">
            ${this.bankerHand.length ? renderCards(this.bankerHand) : '<div style="font-size:10px; color:rgba(255,255,255,0.4);">[ -- ]</div>'}
          </div>
        </div>

        <!-- Middle: Status & Player -->
        <div style="display:flex; flex-direction:column; align-items:center; width:100%;">
          ${this.statusText ? `<div style="font-size:10px; font-weight:800; color:var(--accent-yellow); margin:2px 0;">${this.statusText}</div>` : ''}
          <div style="display:flex; gap:4px; min-height:42px; align-items:center;">
            ${this.playerHand.length ? renderCards(this.playerHand) : '<div style="font-size:10px; color:rgba(255,255,255,0.4);">[ -- ]</div>'}
          </div>
          <div style="font-size:10px; font-weight:700; color:var(--accent-cyan); margin-top:2px;">
            👤 ${isTr ? 'OYUNCU' : 'PLAYER'} (${pTotal})
          </div>
        </div>

        <!-- Bottom: Controls -->
        <div style="width:100%; display:flex; flex-direction:column; gap:4px;">
          <!-- Target selector -->
          <div style="display:flex; justify-content:center; gap:4px;">
            <button class="arcade-btn-mini ${this.betTarget === 'player' ? 'active' : ''}" id="btnBetP" style="font-size:9px; padding:3px 6px;">P (1:1)</button>
            <button class="arcade-btn-mini ${this.betTarget === 'tie' ? 'active' : ''}" id="btnBetT" style="font-size:9px; padding:3px 6px;">T (8:1)</button>
            <button class="arcade-btn-mini ${this.betTarget === 'banker' ? 'active' : ''}" id="btnBetB" style="font-size:9px; padding:3px 6px;">B (0.95:1)</button>
          </div>
          <!-- Action row -->
          <div style="display:flex; justify-content:space-between; align-items:center; width:100%;">
            <span style="font-size:10px; font-weight:800; color:var(--accent-green);">💰 ${this.bankroll}</span>
            <button class="arcade-btn-mini" id="btnDealBaccarat" style="font-size:10px; padding:4px 12px; font-weight:800; background:var(--accent-yellow); color:#000;">
              ${isTr ? 'DAĞIT (10)' : 'DEAL (10)'}
            </button>
          </div>
        </div>
      </div>
    `;

    document.getElementById('btnBetP')?.addEventListener('click', () => { this.betTarget = 'player'; audio.playTick(); this.render(); });
    document.getElementById('btnBetT')?.addEventListener('click', () => { this.betTarget = 'tie'; audio.playTick(); this.render(); });
    document.getElementById('btnBetB')?.addEventListener('click', () => { this.betTarget = 'banker'; audio.playTick(); this.render(); });
    document.getElementById('btnDealBaccarat')?.addEventListener('click', () => { this.deal(); });
  }

  destroy() {}
}

class TriplePokerGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.bankroll = 100;
    this.ante = 10;
    this.playerHand = [];
    this.dealerHand = [];
    this.state = 'ready'; // 'ready', 'playerTurn', 'showdown'
    this.statusMsg = '';
    this.render();
  }

  drawHand(count) {
    const ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    const suits = ['♠', '♥', '♦', '♣'];
    let deck = [];
    suits.forEach(s => {
      ranks.forEach((r, idx) => deck.push({ rank: r, suit: s, val: idx + 2, isRed: s === '♥' || s === '♦' }));
    });
    deck.sort(() => Math.random() - 0.5);
    return deck.slice(0, count);
  }

  evalHand(hand) {
    const vals = hand.map(c => c.val).sort((a, b) => b - a);
    const suits = hand.map(c => c.suit);
    const isFlush = suits[0] === suits[1] && suits[1] === suits[2];
    
    let isStraight = false;
    if (vals[0] - vals[1] === 1 && vals[1] - vals[2] === 1) isStraight = true;
    else if (vals[0] === 14 && vals[1] === 3 && vals[2] === 2) isStraight = true;

    const counts = {};
    vals.forEach(v => counts[v] = (counts[v] || 0) + 1);
    const countVals = Object.values(counts);
    const isThree = countVals.includes(3);
    const isPair = countVals.includes(2);

    if (isStraight && isFlush) return { rank: 6, desc: 'Straight Flush', score: 600 + vals[0] };
    if (isThree) return { rank: 5, desc: '3 of a Kind', score: 500 + vals[0] };
    if (isStraight) return { rank: 4, desc: 'Straight', score: 400 + vals[0] };
    if (isFlush) return { rank: 3, desc: 'Flush', score: 300 + vals[0] };
    if (isPair) {
      const pairVal = parseInt(Object.keys(counts).find(k => counts[k] === 2));
      return { rank: 2, desc: 'Pair', score: 200 + pairVal };
    }
    return { rank: 1, desc: 'High Card', score: 100 + vals[0] };
  }

  startRound() {
    if (this.bankroll < this.ante) this.bankroll = 50;
    this.bankroll -= this.ante;
    audio.playTick();

    const full = this.drawHand(6);
    this.playerHand = full.slice(0, 3);
    this.dealerHand = full.slice(3, 6);
    this.state = 'playerTurn';
    this.statusMsg = '';
    this.render();
  }

  playBet() {
    this.bankroll -= this.ante;
    this.state = 'showdown';

    const pEval = this.evalHand(this.playerHand);
    const dEval = this.evalHand(this.dealerHand);
    const isTr = this.app.lang === 'tr';

    const dQualifies = dEval.rank > 1 || (dEval.rank === 1 && this.dealerHand.some(c => c.val >= 12));

    if (!dQualifies) {
      this.bankroll += this.ante * 2 + this.ante;
      this.statusMsg = isTr ? 'KASA AÇILMADI! (+10)' : 'DEALER NO QUALIFY (+10)';
      audio.playScore();
    } else if (pEval.score > dEval.score) {
      this.bankroll += this.ante * 4;
      this.statusMsg = isTr ? `KAZANDIN! ${pEval.desc} (+20)` : `WIN! ${pEval.desc} (+20)`;
      audio.playVictory();
    } else if (pEval.score < dEval.score) {
      this.statusMsg = isTr ? `KASA KAZANDI (${dEval.desc})` : `DEALER WINS (${dEval.desc})`;
      audio.playGameOver();
    } else {
      this.bankroll += this.ante * 2;
      this.statusMsg = isTr ? 'BERABERE' : 'PUSH';
      audio.playScore();
    }

    Storage.recordScore('triplepoker', this.bankroll);
    const scoreEl = document.getElementById('gameCurrentScore');
    if (scoreEl) scoreEl.textContent = this.bankroll;
    this.render();
  }

  fold() {
    this.state = 'showdown';
    const isTr = this.app.lang === 'tr';
    this.statusMsg = isTr ? 'PAS GEÇTİN (-10)' : 'FOLDED (-10)';
    audio.playGameOver();
    this.render();
  }

  render() {
    const isTr = this.app.lang === 'tr';
    const renderCards = (cards, hidden = false) => cards.map(c => hidden ? `
      <div class="playing-card card-back" style="width:28px; height:40px; font-size:11px;">🂠</div>
    ` : `
      <div class="playing-card ${c.isRed ? 'red' : 'black'}" style="width:28px; height:40px; font-size:11px; padding:2px;">
        <span class="card-rank">${c.rank}</span>
        <span class="card-suit" style="font-size:12px;">${c.suit}</span>
      </div>
    `).join('');

    const pEval = this.playerHand.length ? this.evalHand(this.playerHand) : null;

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; justify-content:space-between; height:100%; width:100%; padding:4px; box-sizing:border-box;">
        <!-- Dealer -->
        <div style="display:flex; flex-direction:column; align-items:center;">
          <div style="font-size:10px; font-weight:700; color:var(--accent-red); margin-bottom:2px;">
            🤠 ${isTr ? 'KASA' : 'DEALER'} (Q+)
          </div>
          <div style="display:flex; gap:4px; min-height:42px; align-items:center;">
            ${this.dealerHand.length ? renderCards(this.dealerHand, this.state === 'playerTurn') : '<div style="font-size:10px; color:rgba(255,255,255,0.4);">[ ? ? ? ]</div>'}
          </div>
        </div>

        <!-- Status & Player -->
        <div style="display:flex; flex-direction:column; align-items:center;">
          ${this.statusMsg ? `<div style="font-size:10px; font-weight:800; color:var(--accent-yellow); margin:2px 0;">${this.statusMsg}</div>` : ''}
          <div style="display:flex; gap:4px; min-height:42px; align-items:center;">
            ${this.playerHand.length ? renderCards(this.playerHand) : '<div style="font-size:10px; color:rgba(255,255,255,0.4);">[ 🂠 🂠 🂠 ]</div>'}
          </div>
          <div style="font-size:10px; font-weight:700; color:var(--accent-cyan); margin-top:2px;">
            👤 ${isTr ? 'ELİNİZ' : 'YOUR HAND'}: ${pEval ? pEval.desc : '--'}
          </div>
        </div>

        <!-- Actions -->
        <div style="width:100%; display:flex; justify-content:space-between; align-items:center;">
          <span style="font-size:10px; font-weight:800; color:var(--accent-green);">💰 ${this.bankroll}</span>
          ${this.state === 'playerTurn' ? `
            <div style="display:flex; gap:4px;">
              <button class="arcade-btn-mini" id="btnFold" style="font-size:10px; padding:4px 8px; background:var(--accent-red); color:#fff;">${isTr ? 'PAS' : 'FOLD'}</button>
              <button class="arcade-btn-mini" id="btnPlay" style="font-size:10px; padding:4px 8px; background:var(--accent-green); color:#000; font-weight:800;">${isTr ? 'OYNAMAK' : 'PLAY'}</button>
            </div>
          ` : `
            <button class="arcade-btn-mini" id="btnDealPoker" style="font-size:10px; padding:4px 12px; background:var(--accent-yellow); color:#000; font-weight:800;">
              ${isTr ? 'DAĞIT (10)' : 'ANTE (10)'}
            </button>
          `}
        </div>
      </div>
    `;

    document.getElementById('btnDealPoker')?.addEventListener('click', () => this.startRound());
    document.getElementById('btnFold')?.addEventListener('click', () => this.fold());
    document.getElementById('btnPlay')?.addEventListener('click', () => this.playBet());
  }

  destroy() {}
}

class CrownMazeGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.score = 0;
    this.currentLevel = 1;
    this.marbleRing = 3; // 3 (outer), 2 (middle), 1 (inner), 0 (center win)
    this.marbleAngle = 0;
    this.ringRotations = [0, 0, 0, 0];
    this.ringSlots = [0, 0.8, 2.2, 4.0];
    this.isDropping = false;
    this.setupCanvas();
  }

  setupCanvas() {
    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; width:100%; height:100%;">
        <canvas id="crownMazeCanvas" width="180" height="180" style="background:#000; border-radius:50%; box-shadow:0 0 10px rgba(0,255,255,0.2);"></canvas>
      </div>
    `;
    this.canvas = document.getElementById('crownMazeCanvas');
    this.ctx = this.canvas.getContext('2d');
    this.newLevel();
    this.draw();
  }

  newLevel() {
    this.marbleRing = 3;
    this.marbleAngle = Math.random() * Math.PI * 2;
    this.ringRotations = [0, Math.random() * Math.PI, Math.random() * Math.PI, Math.random() * Math.PI];
    this.ringSlots = [0, Math.random() * Math.PI * 2, Math.random() * Math.PI * 2, Math.random() * Math.PI * 2];
    this.isDropping = false;
  }

  onCrown(delta) {
    if (this.marbleRing === 0 || this.isDropping) return;
    audio.playTick();
    const speed = 0.15;
    this.ringRotations[this.marbleRing] += delta * speed;
    this.checkAlignment();
    this.draw();
  }

  checkAlignment() {
    if (this.marbleRing === 0 || this.isDropping) return;
    const ring = this.marbleRing;
    const effectiveSlot = (this.ringSlots[ring] + this.ringRotations[ring]) % (Math.PI * 2);
    let diff = Math.abs(effectiveSlot - (this.marbleAngle % (Math.PI * 2)));
    if (diff > Math.PI) diff = Math.PI * 2 - diff;

    if (diff < 0.32) {
      this.isDropping = true;
      audio.playScore();
      setTimeout(() => {
        this.marbleRing--;
        this.isDropping = false;
        if (this.marbleRing === 0) {
          this.score += 100;
          this.currentLevel++;
          audio.playVictory();
          Storage.recordScore('crownmaze', this.score);
          const scoreEl = document.getElementById('gameCurrentScore');
          if (scoreEl) scoreEl.textContent = this.score;
          setTimeout(() => { this.newLevel(); this.draw(); }, 600);
        }
        this.draw();
      }, 200);
    }
  }

  draw() {
    const ctx = this.ctx;
    const cx = 90;
    const cy = 90;
    ctx.clearRect(0, 0, 180, 180);

    const radii = [0, 26, 50, 74];
    const colors = ['#ffe600', '#00e5ff', '#a855f7', '#3b82f6'];

    ctx.beginPath();
    ctx.arc(cx, cy, 12, 0, Math.PI * 2);
    ctx.fillStyle = '#ffcc00';
    ctx.shadowBlur = 10;
    ctx.shadowColor = '#ffcc00';
    ctx.fill();
    ctx.shadowBlur = 0;

    for (let r = 1; r <= 3; r++) {
      const radius = radii[r];
      const rot = this.ringRotations[r];
      const slot = (this.ringSlots[r] + rot) % (Math.PI * 2);
      const slotWidth = 0.45;

      ctx.beginPath();
      ctx.arc(cx, cy, radius, slot + slotWidth / 2, slot + Math.PI * 2 - slotWidth / 2);
      ctx.lineWidth = 4;
      ctx.strokeStyle = (r === this.marbleRing) ? '#00ffff' : colors[r];
      ctx.stroke();
    }

    if (this.marbleRing > 0) {
      const mRadius = radii[this.marbleRing];
      const mx = cx + Math.cos(this.marbleAngle) * mRadius;
      const my = cy + Math.sin(this.marbleAngle) * mRadius;

      ctx.beginPath();
      ctx.arc(mx, my, 5, 0, Math.PI * 2);
      ctx.fillStyle = this.isDropping ? '#ffffff' : '#ff0055';
      ctx.shadowBlur = 8;
      ctx.shadowColor = '#ff0055';
      ctx.fill();
      ctx.shadowBlur = 0;
    } else {
      ctx.beginPath();
      ctx.arc(cx, cy, 6, 0, Math.PI * 2);
      ctx.fillStyle = '#ffffff';
      ctx.fill();
    }
  }

  destroy() {}
}

class SubDiveGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.distance = 0;
    this.depth = 90;
    this.oxygen = 100;
    this.mines = [];
    this.bubbles = [];
    this.gameOver = false;
    this.animId = null;
    this.lastTime = 0;
    this.setup();
  }

  setup() {
    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%; position:relative;">
        <canvas id="subDiveCanvas" width="180" height="180" style="background:#00132b; border-radius:50%;"></canvas>
      </div>
    `;
    this.canvas = document.getElementById('subDiveCanvas');
    this.ctx = this.canvas.getContext('2d');
    this.canvas.addEventListener('click', () => {
      if (this.gameOver) {
        this.distance = 0;
        this.depth = 90;
        this.oxygen = 100;
        this.mines = [];
        this.bubbles = [];
        this.gameOver = false;
        this.start();
      }
    });
    this.start();
  }

  onCrown(delta) {
    if (this.gameOver) return;
    this.depth = Math.max(25, Math.min(155, this.depth + delta * 6));
  }

  start() {
    this.lastTime = performance.now();
    this.loop = (t) => {
      const dt = (t - this.lastTime) / 1000;
      this.lastTime = t;
      this.update(dt);
      this.render();
      if (!this.gameOver) {
        this.animId = requestAnimationFrame(this.loop);
      }
    };
    this.animId = requestAnimationFrame(this.loop);
  }

  update(dt) {
    this.distance += Math.round(dt * 30);
    this.oxygen -= dt * 4;

    const scoreEl = document.getElementById('gameCurrentScore');
    if (scoreEl) scoreEl.textContent = this.distance;

    if (this.oxygen <= 0) {
      this.endGame();
      return;
    }

    if (Math.random() < 0.035) {
      this.mines.push({ x: 190, y: 25 + Math.random() * 130, r: 6 });
    }
    if (Math.random() < 0.03) {
      this.bubbles.push({ x: 190, y: 25 + Math.random() * 130, r: 5 });
    }

    const subX = 35;
    const subY = this.depth;

    for (let i = this.mines.length - 1; i >= 0; i--) {
      const m = this.mines[i];
      m.x -= 70 * dt;
      const dist = Math.hypot(m.x - subX, m.y - subY);
      if (dist < 12) {
        this.endGame();
        return;
      }
      if (m.x < -10) this.mines.splice(i, 1);
    }

    for (let i = this.bubbles.length - 1; i >= 0; i--) {
      const b = this.bubbles[i];
      b.x -= 60 * dt;
      const dist = Math.hypot(b.x - subX, b.y - subY);
      if (dist < 12) {
        this.oxygen = Math.min(100, this.oxygen + 25);
        audio.playScore();
        this.bubbles.splice(i, 1);
        continue;
      }
      if (b.x < -10) this.bubbles.splice(i, 1);
    }
  }

  endGame() {
    this.gameOver = true;
    audio.playGameOver();
    Storage.recordScore('subdive', this.distance);
    this.render();
  }

  render() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 180, 180);

    const grad = ctx.createLinearGradient(0, 0, 0, 180);
    grad.addColorStop(0, '#001a3d');
    grad.addColorStop(1, '#000814');
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, 180, 180);

    ctx.fillStyle = '#0f2942';
    ctx.fillRect(0, 0, 180, 18);
    ctx.fillRect(0, 162, 180, 18);

    this.mines.forEach(m => {
      ctx.beginPath();
      ctx.arc(m.x, m.y, m.r, 0, Math.PI * 2);
      ctx.fillStyle = '#ef4444';
      ctx.shadowBlur = 6;
      ctx.shadowColor = '#ef4444';
      ctx.fill();
      ctx.shadowBlur = 0;
    });

    this.bubbles.forEach(b => {
      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
      ctx.fillStyle = '#38bdf8';
      ctx.shadowBlur = 8;
      ctx.shadowColor = '#38bdf8';
      ctx.fill();
      ctx.shadowBlur = 0;
    });

    ctx.save();
    ctx.translate(35, this.depth);
    ctx.fillStyle = '#eab308';
    ctx.beginPath();
    ctx.ellipse(0, 0, 12, 7, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = '#ca8a04';
    ctx.fillRect(-2, -10, 4, 5);
    ctx.fillRect(0, -10, 5, 2);
    ctx.fillStyle = '#cbd5e1';
    ctx.fillRect(-14, -4, 2, 8);
    ctx.restore();

    ctx.fillStyle = 'rgba(255,255,255,0.2)';
    ctx.fillRect(30, 168, 120, 6);
    ctx.fillStyle = this.oxygen > 30 ? '#00f0ff' : '#ef4444';
    ctx.fillRect(30, 168, (this.oxygen / 100) * 120, 6);

    if (this.gameOver) {
      ctx.fillStyle = 'rgba(0,0,0,0.7)';
      ctx.fillRect(0, 0, 180, 180);
      ctx.fillStyle = '#ff3366';
      ctx.font = 'bold 16px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(this.app.lang === 'tr' ? 'DERİNLİKTE BATTI' : 'HULL BREACH', 90, 80);
      ctx.fillStyle = '#fff';
      ctx.font = '12px sans-serif';
      ctx.fillText(`${this.distance}m`, 90, 105);
      ctx.fillStyle = '#38bdf8';
      ctx.font = '10px sans-serif';
      ctx.fillText(this.app.lang === 'tr' ? 'Tekrar için tıkla' : 'Tap to retry', 90, 130);
    }
  }

  destroy() {
    if (this.animId) cancelAnimationFrame(this.animId);
  }
}

class NeonBeatGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.score = 0;
    this.combo = 0;
    this.notes = [];
    this.animId = null;
    this.lastTime = 0;
    this.hitText = '';
    this.hitColor = '';
    this.setup();
  }

  setup() {
    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%; box-sizing:border-box;">
        <canvas id="neonBeatCanvas" width="180" height="135" style="background:#050510; border-radius:12px 12px 0 0;"></canvas>
        <div style="display:flex; width:180px; height:45px; gap:4px; margin-top:2px;">
          <button class="arcade-btn-mini" id="btnBeatL" style="flex:1; background:#06b6d4; color:#000; font-weight:800; font-size:12px; border-radius:0 0 0 12px;">LEFT</button>
          <button class="arcade-btn-mini" id="btnBeatR" style="flex:1; background:#ec4899; color:#000; font-weight:800; font-size:12px; border-radius:0 0 12px 0;">RIGHT</button>
        </div>
      </div>
    `;
    this.canvas = document.getElementById('neonBeatCanvas');
    this.ctx = this.canvas.getContext('2d');

    document.getElementById('btnBeatL')?.addEventListener('click', () => this.hit(0));
    document.getElementById('btnBeatR')?.addEventListener('click', () => this.hit(1));

    this.onKeyDown = (e) => {
      if (e.key === 'ArrowLeft' || e.key === 'a') this.hit(0);
      else if (e.key === 'ArrowRight' || e.key === 'd') this.hit(1);
    };
    window.addEventListener('keydown', this.onKeyDown);

    this.start();
  }

  start() {
    this.lastTime = performance.now();
    this.loop = (t) => {
      const dt = (t - this.lastTime) / 1000;
      this.lastTime = t;
      this.update(dt);
      this.render();
      this.animId = requestAnimationFrame(this.loop);
    };
    this.animId = requestAnimationFrame(this.loop);
  }

  update(dt) {
    if (Math.random() < 0.04) {
      this.notes.push({ lane: Math.random() < 0.5 ? 0 : 1, y: 0 });
    }

    const hitY = 110;
    const speed = 95;

    for (let i = this.notes.length - 1; i >= 0; i--) {
      const n = this.notes[i];
      n.y += speed * dt;
      if (n.y > hitY + 20) {
        this.combo = 0;
        this.hitText = 'MISS';
        this.hitColor = '#ef4444';
        this.notes.splice(i, 1);
      }
    }
  }

  hit(lane) {
    const hitY = 110;
    let hitIndex = -1;
    let minDist = 999;

    for (let i = 0; i < this.notes.length; i++) {
      const n = this.notes[i];
      if (n.lane === lane) {
        const dist = Math.abs(n.y - hitY);
        if (dist < 28 && dist < minDist) {
          minDist = dist;
          hitIndex = i;
        }
      }
    }

    if (hitIndex !== -1) {
      this.notes.splice(hitIndex, 1);
      this.combo++;
      const multiplier = Math.min(4, 1 + Math.floor(this.combo / 5));
      if (minDist <= 12) {
        this.score += 100 * multiplier;
        this.hitText = `PERFECT! x${multiplier}`;
        this.hitColor = '#22c55e';
        audio.playVictory();
      } else {
        this.score += 50 * multiplier;
        this.hitText = `GOOD x${multiplier}`;
        this.hitColor = '#06b6d4';
        audio.playScore();
      }
    } else {
      this.combo = 0;
      this.hitText = 'MISS';
      this.hitColor = '#ef4444';
      audio.playTick();
    }

    Storage.recordScore('neonbeat', this.score);
    const scoreEl = document.getElementById('gameCurrentScore');
    if (scoreEl) scoreEl.textContent = this.score;
  }

  render() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 180, 135);

    ctx.strokeStyle = 'rgba(255,255,255,0.1)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(90, 0); ctx.lineTo(90, 135);
    ctx.stroke();

    ctx.strokeStyle = 'rgba(255,255,255,0.4)';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(10, 110); ctx.lineTo(170, 110);
    ctx.stroke();

    ctx.strokeStyle = '#06b6d4';
    ctx.strokeRect(30, 102, 30, 16);
    ctx.strokeStyle = '#ec4899';
    ctx.strokeRect(120, 102, 30, 16);

    this.notes.forEach(n => {
      const x = n.lane === 0 ? 45 : 135;
      ctx.fillStyle = n.lane === 0 ? '#06b6d4' : '#ec4899';
      ctx.shadowBlur = 8;
      ctx.shadowColor = ctx.fillStyle;
      ctx.fillRect(x - 14, n.y - 4, 28, 8);
      ctx.shadowBlur = 0;
    });

    if (this.hitText) {
      ctx.font = 'bold 12px sans-serif';
      ctx.fillStyle = this.hitColor;
      ctx.textAlign = 'center';
      ctx.fillText(this.hitText, 90, 50);
    }
  }

  destroy() {
    if (this.animId) cancelAnimationFrame(this.animId);
    window.removeEventListener('keydown', this.onKeyDown);
  }
}

class QuickdrawGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.round = 1;
    this.state = 'idle'; // 'idle', 'wait', 'draw', 'result'
    this.drawTime = 0;
    this.reactionTime = 0;
    this.outlawTime = 420;
    this.statusText = '';
    this.timer = null;
    this.render();
  }

  startDuel() {
    this.state = 'wait';
    this.statusText = this.app.lang === 'tr' ? 'BEKLE... ÇEKME!' : 'STEADY... WAIT!';
    audio.playTick();
    this.render();

    const delay = 1500 + Math.random() * 2500;
    this.timer = setTimeout(() => {
      this.state = 'draw';
      this.drawTime = performance.now();
      this.statusText = '🔥 DRAW! 🔥';
      audio.playScore();
      this.render();
    }, delay);
  }

  tapAction() {
    if (this.state === 'idle' || this.state === 'result') {
      this.startDuel();
    } else if (this.state === 'wait') {
      clearTimeout(this.timer);
      this.state = 'result';
      this.statusText = this.app.lang === 'tr' ? 'ERKEN ATEŞ! FAUL!' : 'FALSE START! FOUL!';
      audio.playGameOver();
      this.render();
    } else if (this.state === 'draw') {
      this.reactionTime = Math.round(performance.now() - this.drawTime);
      this.state = 'result';

      const isTr = this.app.lang === 'tr';
      if (this.reactionTime < this.outlawTime) {
        this.statusText = isTr ? `VURDUN! ${this.reactionTime}ms (Kovboy: ${this.outlawTime}ms)` : `VICTORY! ${this.reactionTime}ms (Outlaw: ${this.outlawTime}ms)`;
        audio.playVictory();
        this.outlawTime = Math.max(190, this.outlawTime - 45);
        this.round++;
        Storage.recordScore('quickdraw', this.reactionTime);
      } else {
        this.statusText = isTr ? `HAYDUT VURDU! ${this.reactionTime}ms` : `OUTLAW DREW FIRST! ${this.reactionTime}ms`;
        audio.playGameOver();
      }

      const scoreEl = document.getElementById('gameCurrentScore');
      if (scoreEl) scoreEl.textContent = `${this.reactionTime}ms`;
      this.render();
    }
  }

  render() {
    const isTr = this.app.lang === 'tr';
    let bg = '#1c1917';
    if (this.state === 'draw') bg = '#b91c1c';

    this.container.innerHTML = `
      <div id="quickdrawScreen" style="display:flex; flex-direction:column; align-items:center; justify-content:space-between; width:100%; height:100%; padding:8px; box-sizing:border-box; background:${bg}; cursor:pointer;">
        <div style="font-size:10px; font-weight:800; color:var(--accent-orange);">
          🤠 ${isTr ? 'BATI DÜELLOSU' : 'WESTERN DUEL'} • R${this.round}
        </div>

        <div style="display:flex; flex-direction:column; align-items:center; justify-content:center;">
          <div style="font-size:42px; margin-bottom:4px;">
            ${this.state === 'draw' ? '💥' : (this.state === 'wait' ? '👁️' : '🤠')}
          </div>
          <div style="font-size:14px; font-weight:900; color:#fff; text-align:center;">
            ${this.statusText || (isTr ? 'DOKUN VE BAŞLA' : 'TAP TO DUEL')}
          </div>
        </div>

        <div style="font-size:10px; color:rgba(255,255,255,0.6);">
          ${this.state === 'wait' ? (isTr ? 'Ateş etme...' : 'Hold your holster...') : (isTr ? 'Ekrana dokun' : 'Tap screen')}
        </div>
      </div>
    `;

    document.getElementById('quickdrawScreen')?.addEventListener('click', () => this.tapAction());
  }

  destroy() {
    if (this.timer) clearTimeout(this.timer);
  }
}

class PipeConnectGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.score = 0;
    this.moves = 0;
    this.grid = [];
    this.solved = false;
    this.newPuzzle();
  }

  newPuzzle() {
    this.grid = [
      { type: 'L', rot: Math.floor(Math.random() * 4) }, { type: 'I', rot: Math.floor(Math.random() * 4) }, { type: 'L', rot: Math.floor(Math.random() * 4) },
      { type: 'I', rot: Math.floor(Math.random() * 4) }, { type: 'T', rot: Math.floor(Math.random() * 4) }, { type: 'I', rot: Math.floor(Math.random() * 4) },
      { type: 'L', rot: Math.floor(Math.random() * 4) }, { type: 'I', rot: Math.floor(Math.random() * 4) }, { type: 'L', rot: Math.floor(Math.random() * 4) }
    ];
    this.solved = false;
    this.checkFlow();
    this.render();
  }

  getOpenings(type, rot) {
    let base = [];
    if (type === 'I') base = [0, 2];
    else if (type === 'L') base = [0, 1];
    else if (type === 'T') base = [0, 1, 3];
    return base.map(dir => (dir + rot) % 4);
  }

  checkFlow() {
    const visited = new Set();
    const queue = [{ r: 0, c: 0 }];
    visited.add('0,0');

    const opp = [2, 3, 0, 1];
    const dr = [-1, 0, 1, 0];
    const dc = [0, 1, 0, -1];

    let reachesEnd = false;
    while (queue.length > 0) {
      const { r, c } = queue.shift();
      if (r === 2 && c === 2) reachesEnd = true;

      const idx = r * 3 + c;
      const tile = this.grid[idx];
      const open = this.getOpenings(tile.type, tile.rot);

      for (let dir of open) {
        const nr = r + dr[dir];
        const nc = c + dc[dir];
        if (nr >= 0 && nr < 3 && nc >= 0 && nc < 3) {
          const nKey = `${nr},${nc}`;
          if (!visited.has(nKey)) {
            const nTile = this.grid[nr * 3 + nc];
            const nOpen = this.getOpenings(nTile.type, nTile.rot);
            if (nOpen.includes(opp[dir])) {
              visited.add(nKey);
              queue.push({ r: nr, c: nc });
            }
          }
        }
      }
    }

    if (reachesEnd && !this.solved) {
      this.solved = true;
      this.score += 100;
      audio.playVictory();
      Storage.recordScore('pipeconnect', this.score);
      const scoreEl = document.getElementById('gameCurrentScore');
      if (scoreEl) scoreEl.textContent = this.score;
      setTimeout(() => this.newPuzzle(), 1200);
    }
  }

  rotateTile(index) {
    if (this.solved) return;
    this.grid[index].rot = (this.grid[index].rot + 1) % 4;
    this.moves++;
    audio.playTick();
    this.checkFlow();
    this.render();
  }

  render() {
    const isTr = this.app.lang === 'tr';
    const tileChars = { 'I': '┃', 'L': '┗', 'T': '┣' };

    const gridHtml = this.grid.map((t, idx) => `
      <div class="pipe-tile" data-idx="${idx}" style="width:48px; height:48px; background:#1e293b; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:24px; color:${this.solved ? '#00f0ff' : '#94a3b8'}; cursor:pointer; transform:rotate(${t.rot * 90}deg); transition:transform 0.15s ease, color 0.3s ease; box-shadow:inset 0 0 5px rgba(0,0,0,0.5);">
        ${tileChars[t.type]}
      </div>
    `).join('');

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; justify-content:space-between; width:100%; height:100%; padding:4px; box-sizing:border-box;">
        <div style="font-size:10px; font-weight:800; color:var(--accent-cyan);">
          🔧 ${isTr ? 'SU AKIŞINI BAĞLA' : 'CONNECT PIPELINE'}
        </div>
        <div style="display:grid; grid-template-columns:repeat(3, 48px); gap:6px;">
          ${gridHtml}
        </div>
        <div style="font-size:10px; color:rgba(255,255,255,0.6);">
          ${this.solved ? (isTr ? '🎉 AKIŞ BAĞLANDI!' : '🎉 FLOW CONNECTED!') : (isTr ? 'Parçaları döndür' : 'Tap pipe to rotate')}
        </div>
      </div>
    `;

    this.container.querySelectorAll('.pipe-tile').forEach(el => {
      el.addEventListener('click', () => {
        const idx = parseInt(el.dataset.idx, 10);
        this.rotateTile(idx);
      });
    });
  }

  destroy() {}
}

class LaserMirrorGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.score = 0;
    this.level = 1;
    this.solved = false;
    this.mirrors = [];
    this.emitter = { r: 0, c: 0, dir: 1 };
    this.target = { r: 3, c: 3 };
    this.laserPath = [];
    this.setupCanvas();
  }

  setupCanvas() {
    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; width:100%; height:100%;">
        <canvas id="laserCanvas" width="180" height="180" style="background:#090914; border-radius:12px;"></canvas>
      </div>
    `;
    this.canvas = document.getElementById('laserCanvas');
    this.ctx = this.canvas.getContext('2d');

    this.canvas.addEventListener('click', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      const c = Math.floor(x / 45);
      const r = Math.floor(y / 45);

      const m = this.mirrors.find(item => item.r === r && item.c === c);
      if (m && !this.solved) {
        m.type = 1 - m.type;
        audio.playTick();
        this.traceLaser();
        this.draw();
      }
    });

    this.newLevel();
  }

  newLevel() {
    this.solved = false;
    this.mirrors = [
      { r: 0, c: 2, type: 0 },
      { r: 2, c: 2, type: 1 },
      { r: 2, c: 3, type: 0 }
    ];
    this.target = { r: 3, c: 3 };
    this.traceLaser();
    this.draw();
  }

  traceLaser() {
    this.laserPath = [{ r: this.emitter.r, c: this.emitter.c }];
    let currR = this.emitter.r;
    let currC = this.emitter.c;
    let dir = this.emitter.dir;

    const dr = [-1, 0, 1, 0];
    const dc = [0, 1, 0, -1];

    for (let step = 0; step < 16; step++) {
      currR += dr[dir];
      currC += dc[dir];
      if (currR < 0 || currR >= 4 || currC < 0 || currC >= 4) break;

      this.laserPath.push({ r: currR, c: currC });

      if (currR === this.target.r && currC === this.target.c) {
        if (!this.solved) {
          this.solved = true;
          this.score += 100;
          audio.playVictory();
          Storage.recordScore('lasermirror', this.score);
          const scoreEl = document.getElementById('gameCurrentScore');
          if (scoreEl) scoreEl.textContent = this.score;
          setTimeout(() => { this.level++; this.newLevel(); }, 1200);
        }
        break;
      }

      const m = this.mirrors.find(item => item.r === currR && item.c === currC);
      if (m) {
        if (m.type === 0) {
          if (dir === 1) dir = 0;
          else if (dir === 2) dir = 3;
          else if (dir === 3) dir = 2;
          else if (dir === 0) dir = 1;
        } else {
          if (dir === 1) dir = 2;
          else if (dir === 0) dir = 3;
          else if (dir === 3) dir = 0;
          else if (dir === 2) dir = 1;
        }
      }
    }
  }

  draw() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 180, 180);

    ctx.strokeStyle = 'rgba(255,255,255,0.08)';
    ctx.lineWidth = 1;
    for (let i = 1; i < 4; i++) {
      ctx.beginPath(); ctx.moveTo(i * 45, 0); ctx.lineTo(i * 45, 180); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(0, i * 45); ctx.lineTo(180, i * 45); ctx.stroke();
    }

    const tx = this.target.c * 45 + 22.5;
    const ty = this.target.r * 45 + 22.5;
    ctx.fillStyle = this.solved ? '#22c55e' : '#ec4899';
    ctx.shadowBlur = this.solved ? 15 : 6;
    ctx.shadowColor = ctx.fillStyle;
    ctx.beginPath();
    ctx.arc(tx, ty, 8, 0, Math.PI * 2);
    ctx.fill();
    ctx.shadowBlur = 0;

    ctx.fillStyle = '#ef4444';
    ctx.fillRect(8, 14, 16, 16);

    this.mirrors.forEach(m => {
      const mx = m.c * 45 + 22.5;
      const my = m.r * 45 + 22.5;
      ctx.strokeStyle = '#38bdf8';
      ctx.lineWidth = 4;
      ctx.beginPath();
      if (m.type === 0) {
        ctx.moveTo(mx - 14, my + 14);
        ctx.lineTo(mx + 14, my - 14);
      } else {
        ctx.moveTo(mx - 14, my - 14);
        ctx.lineTo(mx + 14, my + 14);
      }
      ctx.stroke();
    });

    if (this.laserPath.length > 1) {
      ctx.strokeStyle = '#ef4444';
      ctx.lineWidth = 3;
      ctx.shadowBlur = 8;
      ctx.shadowColor = '#ef4444';
      ctx.beginPath();
      ctx.moveTo(this.laserPath[0].c * 45 + 22.5, this.laserPath[0].r * 45 + 22.5);
      for (let i = 1; i < this.laserPath.length; i++) {
        ctx.lineTo(this.laserPath[i].c * 45 + 22.5, this.laserPath[i].r * 45 + 22.5);
      }
      ctx.stroke();
      ctx.shadowBlur = 0;
    }
  }

  destroy() {}
}

// ==========================================
// 1. PISTI CARD GAME (TURKISH CLASSIC)
// ==========================================
class PistiGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.initGame();
  }

  initGame() {
    const suits = ['♠', '♥', '♦', '♣'];
    this.deck = [];
    for (let s of suits) {
      for (let r = 1; r <= 13; r++) {
        this.deck.push({ s, r, isRed: s === '♥' || s === '♦' });
      }
    }
    // Shuffle
    for (let i = this.deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [this.deck[i], this.deck[j]] = [this.deck[j], this.deck[i]];
    }

    this.tablePile = this.deck.splice(0, 4);
    this.playerHand = [];
    this.aiHand = [];
    this.playerScore = 0;
    this.aiScore = 0;
    this.playerPisti = 0;
    this.aiPisti = 0;
    this.isPlayerTurn = true;
    this.isGameOver = false;
    this.msg = this.app.lang === 'tr' ? 'Kartını seç ve ortaya at!' : 'Tap a card to play it!';

    this.dealHands();
    this.render();
  }

  dealHands() {
    if (this.deck.length >= 8) {
      this.playerHand = this.deck.splice(0, 4);
      this.aiHand = this.deck.splice(0, 4);
    } else {
      this.endGame();
    }
  }

  rankStr(r) {
    if (r === 1) return 'A';
    if (r === 11) return 'J';
    if (r === 12) return 'Q';
    if (r === 13) return 'K';
    return String(r);
  }

  playPlayerCard(idx) {
    if (!this.isPlayerTurn || this.isGameOver) return;
    const card = this.playerHand.splice(idx, 1)[0];
    audio.playTick();
    this.evaluatePlay(card, true);

    if (this.playerHand.length === 0 && this.aiHand.length === 0) {
      if (this.deck.length > 0) this.dealHands();
      else { this.endGame(); this.render(); return; }
    }

    this.isPlayerTurn = false;
    this.render();

    setTimeout(() => {
      this.playAITurn();
    }, 500);
  }

  playAITurn() {
    if (this.aiHand.length === 0 || this.isGameOver) return;
    const top = this.tablePile.length > 0 ? this.tablePile[this.tablePile.length - 1] : null;
    let chosenIdx = 0;

    if (top) {
      const matchIdx = this.aiHand.findIndex(c => c.r === top.r);
      const jackIdx = this.aiHand.findIndex(c => c.r === 11);
      if (matchIdx !== -1) chosenIdx = matchIdx;
      else if (this.tablePile.length >= 3 && jackIdx !== -1) chosenIdx = jackIdx;
      else {
        const nonJacks = this.aiHand.map((c, i) => ({ c, i })).filter(x => x.c.r !== 11);
        if (nonJacks.length > 0) chosenIdx = nonJacks[Math.floor(Math.random() * nonJacks.length)].i;
      }
    }

    const card = this.aiHand.splice(chosenIdx, 1)[0];
    this.evaluatePlay(card, false);

    if (this.playerHand.length === 0 && this.aiHand.length === 0) {
      if (this.deck.length > 0) this.dealHands();
      else { this.endGame(); this.render(); return; }
    }

    this.isPlayerTurn = true;
    this.render();
  }

  evaluatePlay(card, isPlayer) {
    const top = this.tablePile.length > 0 ? this.tablePile[this.tablePile.length - 1] : null;
    if (top && (card.r === top.r || card.r === 11)) {
      // Capture
      if (this.tablePile.length === 1 && card.r === top.r) {
        const pts = card.r === 11 ? 20 : 10;
        if (isPlayer) {
          this.playerScore += pts;
          this.playerPisti++;
          this.msg = this.app.lang === 'tr' ? `💥 PİŞTİ! (+${pts} Puan)` : `💥 PISTI! (+${pts} pts)`;
          audio.playVictory();
        } else {
          this.aiScore += pts;
          this.aiPisti++;
          this.msg = this.app.lang === 'tr' ? `🤖 Rakip Pişti! (+${pts})` : `🤖 Opponent Pisti! (+${pts})`;
          audio.playGameOver();
        }
      } else {
        const pts = this.tablePile.length + 1;
        if (isPlayer) {
          this.playerScore += pts;
          this.msg = this.app.lang === 'tr' ? `👏 ${pts} kart topladın!` : `👏 Captured ${pts} cards!`;
          audio.playCoin();
        } else {
          this.aiScore += pts;
          this.msg = this.app.lang === 'tr' ? `🤖 Rakip ${pts} kart topladı.` : `🤖 Bot captured ${pts} cards.`;
        }
      }
      this.tablePile = [];
    } else {
      this.tablePile.push(card);
    }
  }

  endGame() {
    this.isGameOver = true;
    if (this.playerScore > this.aiScore) {
      this.msg = this.app.lang === 'tr' ? `🏆 KAZANDIN! (${this.playerScore} - ${this.aiScore})` : `🏆 YOU WON! (${this.playerScore} - ${this.aiScore})`;
      audio.playVictory();
    } else {
      this.msg = this.app.lang === 'tr' ? `OYUN BİTTİ (${this.playerScore} - ${this.aiScore})` : `GAME OVER (${this.playerScore} - ${this.aiScore})`;
      audio.playGameOver();
    }
    Storage.recordScore('pisti', this.playerScore);
  }

  render() {
    const isTr = this.app.lang === 'tr';
    const topCard = this.tablePile.length > 0 ? this.tablePile[this.tablePile.length - 1] : null;

    let pileHtml = `<div style="color:#71717a; font-size:10px; font-weight:700;">${isTr ? 'Yer Boş' : 'Pile Empty'}</div>`;
    if (topCard) {
      pileHtml = `
        <div style="width:34px; height:48px; background:#fff; border-radius:5px; color:${topCard.isRed ? '#ef4444' : '#000'}; font-weight:900; display:flex; flex-direction:column; align-items:center; justify-content:center; box-shadow:0 4px 10px rgba(0,0,0,0.5);">
          <div style="font-size:13px;">${this.rankStr(topCard.r)}</div>
          <div style="font-size:11px;">${topCard.s}</div>
        </div>
        <div style="font-size:9px; color:#a1a1aa; margin-top:2px;">${this.tablePile.length} ${isTr ? 'kart' : 'cards'}</div>
      `;
    }

    let handHtml = '';
    this.playerHand.forEach((c, idx) => {
      handHtml += `
        <button class="pisti-card-btn" data-idx="${idx}" style="width:30px; height:42px; background:#fff; border:1px solid #38bdf8; border-radius:4px; color:${c.isRed ? '#ef4444' : '#000'}; font-weight:900; display:flex; flex-direction:column; align-items:center; justify-content:center; cursor:pointer; box-shadow:0 2px 6px rgba(0,0,0,0.4);">
          <div style="font-size:12px;">${this.rankStr(c.r)}</div>
          <div style="font-size:10px;">${c.s}</div>
        </button>
      `;
    });

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%; padding:4px 6px; box-sizing:border-box;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:11px; font-weight:900; margin-bottom:2px;">
          <span style="color:#38bdf8;">${isTr ? 'SEN' : 'YOU'}: ${this.playerScore}p ${this.playerPisti > 0 ? '🔥' + this.playerPisti : ''}</span>
          <span style="color:#ef4444;">BOT: ${this.aiScore}p ${this.aiPisti > 0 ? '🔥' + this.aiPisti : ''}</span>
        </div>
        <div style="font-size:9px; font-weight:700; color:#facc15; min-height:14px; text-align:center;">${this.msg}</div>

        <div style="width:100%; height:75px; background:rgba(34,197,94,0.15); border:1px dashed rgba(34,197,94,0.4); border-radius:8px; display:flex; flex-direction:column; align-items:center; justify-content:center; margin:4px 0;">
          ${pileHtml}
        </div>

        <div style="display:flex; gap:5px; margin-top:2px;">
          ${handHtml}
        </div>

        ${this.isGameOver ? `
          <button id="pistiRestartBtn" style="margin-top:5px; background:#facc15; color:#000; font-weight:900; font-size:10px; border:none; padding:4px 12px; border-radius:12px; cursor:pointer;">
            ${isTr ? 'YENİDEN OYNA' : 'PLAY AGAIN'}
          </button>
        ` : ''}
      </div>
    `;

    this.container.querySelectorAll('.pisti-card-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const idx = parseInt(e.currentTarget.dataset.idx, 10);
        this.playPlayerCard(idx);
      });
    });

    const restartBtn = this.container.querySelector('#pistiRestartBtn');
    if (restartBtn) {
      restartBtn.addEventListener('click', () => {
        this.initGame();
      });
    }
  }

  destroy() {}
}

// ==========================================
// 2. KLONDIKE SOLITAIRE GAME
// ==========================================
class KlondikeGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.initGame();
  }

  initGame() {
    const suits = ['♠', '♥', '♦', '♣'];
    const deck = [];
    for (let s of suits) {
      for (let r = 1; r <= 13; r++) {
        deck.push({ s, r, isRed: s === '♥' || s === '♦', isUp: false });
      }
    }
    for (let i = deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [deck[i], deck[j]] = [deck[j], deck[i]];
    }

    this.columns = [[], [], [], [], [], [], []];
    for (let i = 0; i < 7; i++) {
      for (let j = 0; j <= i; j++) {
        const c = deck.shift();
        if (j === i) c.isUp = true;
        this.columns[i].push(c);
      }
    }

    this.stock = deck;
    this.waste = [];
    this.foundations = [[], [], [], []];
    this.score = 0;
    this.moves = 0;
    this.isWon = false;
    this.render();
  }

  drawStock() {
    audio.playTick();
    this.moves++;
    if (this.stock.length === 0) {
      this.stock = this.waste.reverse().map(c => ({ ...c, isUp: false }));
      this.waste = [];
    } else {
      const c = this.stock.pop();
      c.isUp = true;
      this.waste.push(c);
    }
    this.render();
  }

  moveWasteCard() {
    if (this.waste.length === 0) return;
    const card = this.waste[this.waste.length - 1];

    // Try foundations
    for (let f of this.foundations) {
      if ((f.length === 0 && card.r === 1) || (f.length > 0 && f[f.length - 1].s === card.s && f[f.length - 1].r === card.r - 1)) {
        f.push(this.waste.pop());
        this.score += 15;
        this.moves++;
        audio.playVictory();
        this.checkWin();
        this.render();
        return;
      }
    }

    // Try columns
    for (let col of this.columns) {
      if (col.length > 0) {
        const top = col[col.length - 1];
        if (top.isUp && top.isRed !== card.isRed && top.r === card.r + 1) {
          col.push(this.waste.pop());
          this.score += 5;
          this.moves++;
          audio.playCoin();
          this.render();
          return;
        }
      } else if (card.r === 13) {
        col.push(this.waste.pop());
        this.score += 5;
        this.moves++;
        audio.playCoin();
        this.render();
        return;
      }
    }
    audio.playGameOver();
  }

  moveColCard(colIdx) {
    const col = this.columns[colIdx];
    if (col.length === 0) return;
    const card = col[col.length - 1];
    if (!card.isUp) return;

    // Try foundations
    for (let f of this.foundations) {
      if ((f.length === 0 && card.r === 1) || (f.length > 0 && f[f.length - 1].s === card.s && f[f.length - 1].r === card.r - 1)) {
        f.push(col.pop());
        if (col.length > 0) col[col.length - 1].isUp = true;
        this.score += 15;
        this.moves++;
        audio.playVictory();
        this.checkWin();
        this.render();
        return;
      }
    }

    // Try other columns
    for (let i = 0; i < 7; i++) {
      if (i === colIdx) continue;
      const other = this.columns[i];
      if (other.length > 0) {
        const top = other[other.length - 1];
        if (top.isUp && top.isRed !== card.isRed && top.r === card.r + 1) {
          other.push(col.pop());
          if (col.length > 0) col[col.length - 1].isUp = true;
          this.score += 5;
          this.moves++;
          audio.playCoin();
          this.render();
          return;
        }
      } else if (card.r === 13 && col.length > 1) {
        other.push(col.pop());
        if (col.length > 0) col[col.length - 1].isUp = true;
        this.score += 5;
        this.moves++;
        audio.playCoin();
        this.render();
        return;
      }
    }
    audio.playGameOver();
  }

  checkWin() {
    const totalF = this.foundations.reduce((acc, f) => acc + f.length, 0);
    if (totalF === 52) {
      this.isWon = true;
      this.score += 200;
      audio.playVictory();
      Storage.recordScore('klondikesolitaire', this.score);
    }
  }

  rankStr(r) {
    if (r === 1) return 'A';
    if (r === 11) return 'J';
    if (r === 12) return 'Q';
    if (r === 13) return 'K';
    return String(r);
  }

  render() {
    const isTr = this.app.lang === 'tr';
    const topWaste = this.waste.length > 0 ? this.waste[this.waste.length - 1] : null;

    let fHtml = '';
    this.foundations.forEach((f, idx) => {
      const top = f.length > 0 ? f[f.length - 1] : null;
      fHtml += `
        <div style="width:20px; height:26px; border:1px solid #facc15; border-radius:3px; background:#18181b; display:flex; flex-direction:column; align-items:center; justify-content:center; color:${top ? (top.isRed ? '#ef4444' : '#fff') : '#71717a'}; font-size:8px; font-weight:900;">
          ${top ? `<div>${this.rankStr(top.r)}</div><div>${top.s}</div>` : ['♠', '♥', '♦', '♣'][idx]}
        </div>
      `;
    });

    let colsHtml = '';
    this.columns.forEach((col, cIdx) => {
      let cardsInCol = '';
      col.forEach((c, rIdx) => {
        if (c.isUp) {
          cardsInCol += `
            <div class="klondike-card" data-col="${cIdx}" style="width:18px; height:24px; background:#fff; border:1px solid #38bdf8; border-radius:3px; color:${c.isRed ? '#ef4444' : '#000'}; font-weight:900; font-size:7px; display:flex; flex-direction:column; align-items:center; justify-content:center; margin-top:-14px; cursor:pointer;">
              <div>${this.rankStr(c.r)}</div>
              <div>${c.s}</div>
            </div>
          `;
        } else {
          cardsInCol += `
            <div style="width:18px; height:24px; background:#2563eb; border:1px solid #60a5fa; border-radius:3px; margin-top:-14px;"></div>
          `;
        }
      });
      colsHtml += `
        <div style="display:flex; flex-direction:column; align-items:center; min-height:80px; padding-top:14px;">
          ${cardsInCol || `<div class="klondike-empty-col" data-col="${cIdx}" style="width:18px; height:24px; border:1px dashed #52525b; border-radius:3px; display:flex; align-items:center; justify-content:center; font-size:7px; color:#71717a;">K</div>`}
        </div>
      `;
    });

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; width:100%; height:100%; padding:2px 4px; box-sizing:border-box;">
        <div style="display:flex; justify-content:space-between; font-size:10px; font-weight:800; margin-bottom:2px;">
          <span style="color:#22c55e;">${isTr ? 'Puan' : 'Score'}: ${this.score}</span>
          <span style="color:#a1a1aa;">${isTr ? 'Hamle' : 'Moves'}: ${this.moves}</span>
        </div>

        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
          <div style="display:flex; gap:3px;">
            <button id="solStockBtn" style="width:20px; height:26px; background:#2563eb; border:1px solid #60a5fa; border-radius:3px; color:#fff; font-size:10px; cursor:pointer;">
              ${this.stock.length > 0 ? '🂠' : '↺'}
            </button>
            <div id="solWasteBtn" style="width:20px; height:26px; border:1px solid #38bdf8; border-radius:3px; background:${topWaste ? '#fff' : '#18181b'}; color:${topWaste ? (topWaste.isRed ? '#ef4444' : '#000') : '#71717a'}; font-weight:900; font-size:8px; display:flex; flex-direction:column; align-items:center; justify-content:center; cursor:pointer;">
              ${topWaste ? `<div>${this.rankStr(topWaste.r)}</div><div>${topWaste.s}</div>` : ''}
            </div>
          </div>
          <div style="display:flex; gap:2px;">
            ${fHtml}
          </div>
        </div>

        <div style="display:flex; justify-content:space-between; width:100%;">
          ${colsHtml}
        </div>

        ${this.isWon ? `
          <div style="text-align:center; margin-top:4px;">
            <div style="color:#facc15; font-weight:900; font-size:11px;">🎉 ${isTr ? 'KAZANDIN!' : 'YOU WON!'}</div>
            <button id="solRestartBtn" style="margin-top:2px; background:#22c55e; color:#000; font-weight:900; font-size:9px; border:none; padding:3px 8px; border-radius:8px; cursor:pointer;">${isTr ? 'YENİDEN' : 'RESTART'}</button>
          </div>
        ` : ''}
      </div>
    `;

    const stockBtn = this.container.querySelector('#solStockBtn');
    if (stockBtn) stockBtn.addEventListener('click', () => this.drawStock());

    const wasteBtn = this.container.querySelector('#solWasteBtn');
    if (wasteBtn) wasteBtn.addEventListener('click', () => this.moveWasteCard());

    this.container.querySelectorAll('.klondike-card').forEach(cardEl => {
      cardEl.addEventListener('click', (e) => {
        const cIdx = parseInt(e.currentTarget.dataset.col, 10);
        this.moveColCard(cIdx);
      });
    });

    const restartBtn = this.container.querySelector('#solRestartBtn');
    if (restartBtn) restartBtn.addEventListener('click', () => this.initGame());
  }

  destroy() {}
}

// ==========================================
// 3. MAZE MUNCHER (PAC-MAN RETRO CHOMP)
// ==========================================
class MazeMuncherGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.initGame();
  }

  initGame() {
    this.initialGrid = [
      [1,1,1,1,1,1,1,1,1],
      [1,2,0,0,1,0,0,2,1],
      [1,0,1,0,1,0,1,0,1],
      [1,0,0,0,0,0,0,0,1],
      [1,1,0,1,3,1,0,1,1],
      [1,0,0,0,0,0,0,0,1],
      [1,0,1,0,1,0,1,0,1],
      [1,2,0,0,1,0,0,2,1],
      [1,1,1,1,1,1,1,1,1]
    ];
    this.grid = JSON.parse(JSON.stringify(this.initialGrid));
    this.playerR = 5;
    this.playerC = 4;
    this.dir = { r: 0, c: 1 };
    this.ghost1 = { r: 3, c: 3 };
    this.ghost2 = { r: 3, c: 5 };
    this.score = 0;
    this.lives = 3;
    this.powerTimer = 0;
    this.isGameOver = false;
    this.isWon = false;

    if (this.timer) clearInterval(this.timer);
    this.timer = setInterval(() => this.tick(), 350);
    this.render();
  }

  tick() {
    if (this.isGameOver || this.isWon) return;
    if (this.powerTimer > 0) this.powerTimer--;

    const nr = this.playerR + this.dir.r;
    const nc = this.playerC + this.dir.c;
    if (this.canMove(nr, nc)) {
      this.playerR = nr;
      this.playerC = nc;
      if (this.grid[nr][nc] === 0) {
        this.grid[nr][nc] = 3;
        this.score += 10;
        audio.playTick(750);
      } else if (this.grid[nr][nc] === 2) {
        this.grid[nr][nc] = 3;
        this.score += 50;
        this.powerTimer = 12;
        audio.playCoin();
      }
    }

    this.moveGhost(this.ghost1);
    this.moveGhost(this.ghost2);
    this.checkCollisions();

    let dots = 0;
    for (let row of this.grid) {
      for (let cell of row) {
        if (cell === 0 || cell === 2) dots++;
      }
    }
    if (dots === 0) {
      this.isWon = true;
      this.score += 200;
      audio.playVictory();
      clearInterval(this.timer);
      Storage.recordScore('mazemuncher', this.score);
    }

    this.render();
  }

  canMove(r, c) {
    if (r < 0 || r >= 9 || c < 0 || c >= 9) return false;
    return this.grid[r][c] !== 1;
  }

  moveGhost(g) {
    const dirs = [{r:-1,c:0}, {r:1,c:0}, {r:0,c:-1}, {r:0,c:1}];
    const valid = dirs.filter(d => this.canMove(g.r + d.r, g.c + d.c)).map(d => ({ r: g.r + d.r, c: g.c + d.c }));
    if (valid.length > 0) {
      if (this.powerTimer > 0) {
        valid.sort((a, b) => (Math.abs(b.r - this.playerR) + Math.abs(b.c - this.playerC)) - (Math.abs(a.r - this.playerR) + Math.abs(a.c - this.playerC)));
      } else {
        valid.sort((a, b) => (Math.abs(a.r - this.playerR) + Math.abs(a.c - this.playerC)) - (Math.abs(b.r - this.playerR) + Math.abs(b.c - this.playerC)));
      }
      g.r = valid[0].r;
      g.c = valid[0].c;
    }
  }

  checkCollisions() {
    const c1 = (this.playerR === this.ghost1.r && this.playerC === this.ghost1.c);
    const c2 = (this.playerR === this.ghost2.r && this.playerC === this.ghost2.c);
    if (c1 || c2) {
      if (this.powerTimer > 0) {
        this.score += 100;
        audio.playVictory();
        if (c1) { this.ghost1.r = 1; this.ghost1.c = 1; }
        if (c2) { this.ghost2.r = 1; this.ghost2.c = 7; }
      } else {
        this.lives--;
        audio.playGameOver();
        this.playerR = 5;
        this.playerC = 4;
        if (this.lives <= 0) {
          this.isGameOver = true;
          clearInterval(this.timer);
          Storage.recordScore('mazemuncher', this.score);
        }
      }
    }
  }

  changeDir(dr, dc) {
    this.dir = { r: dr, c: dc };
    audio.playTick();
  }

  onCrown(delta) {
    if (delta > 0) this.changeDir(0, 1);
    else this.changeDir(0, -1);
  }

  render() {
    let gridHtml = '';
    for (let r = 0; r < 9; r++) {
      let rowHtml = '';
      for (let c = 0; c < 9; c++) {
        const isP = (r === this.playerR && c === this.playerC);
        const isG1 = (r === this.ghost1.r && c === this.ghost1.c);
        const isG2 = (r === this.ghost2.r && c === this.ghost2.c);
        const val = this.grid[r][c];

        let content = '';
        let bg = '#000';
        if (val === 1) {
          bg = '#1e3a8a';
        } else if (val === 0) {
          content = '<div style="width:3px; height:3px; background:#facc15; border-radius:50%;"></div>';
        } else if (val === 2) {
          content = '<div style="width:6px; height:6px; background:#f97316; border-radius:50%; box-shadow:0 0 6px #f97316;"></div>';
        }

        if (isP) content = '<span style="font-size:10px;">🟡</span>';
        else if (isG1 || isG2) content = `<span style="font-size:10px;">${this.powerTimer > 0 ? '🔵' : (isG1 ? '🔴' : '🟣')}</span>`;

        rowHtml += `<div style="width:16px; height:16px; background:${bg}; display:flex; align-items:center; justify-content:center;">${content}</div>`;
      }
      gridHtml += `<div style="display:flex;">${rowHtml}</div>`;
    }

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%; padding:2px; box-sizing:border-box;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:800; padding:0 4px;">
          <span>${'🟡'.repeat(Math.max(0, this.lives))}</span>
          <span style="color:#facc15;">${this.score} pts ${this.powerTimer > 0 ? '⚡' + this.powerTimer : ''}</span>
        </div>

        <div style="border:1px solid #3b82f6; border-radius:4px; overflow:hidden; margin:2px 0;">
          ${gridHtml}
        </div>

        <div style="display:flex; gap:6px; align-items:center;">
          <button id="mmLeft" style="width:26px; height:18px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:9px; cursor:pointer;">◀</button>
          <div style="display:flex; flex-direction:column; gap:2px;">
            <button id="mmUp" style="width:26px; height:15px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:8px; cursor:pointer;">▲</button>
            <button id="mmDown" style="width:26px; height:15px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:8px; cursor:pointer;">▼</button>
          </div>
          <button id="mmRight" style="width:26px; height:18px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:9px; cursor:pointer;">▶</button>
        </div>

        ${this.isGameOver || this.isWon ? `
          <button id="mmRestartBtn" style="margin-top:3px; background:#facc15; color:#000; font-weight:900; font-size:9px; border:none; padding:3px 8px; border-radius:8px; cursor:pointer;">
            ${this.app.lang === 'tr' ? 'TEKRAR OYNA' : 'PLAY AGAIN'}
          </button>
        ` : ''}
      </div>
    `;

    this.container.querySelector('#mmLeft').addEventListener('click', () => this.changeDir(0, -1));
    this.container.querySelector('#mmRight').addEventListener('click', () => this.changeDir(0, 1));
    this.container.querySelector('#mmUp').addEventListener('click', () => this.changeDir(-1, 0));
    this.container.querySelector('#mmDown').addEventListener('click', () => this.changeDir(1, 0));

    const restartBtn = this.container.querySelector('#mmRestartBtn');
    if (restartBtn) restartBtn.addEventListener('click', () => this.initGame());
  }

  destroy() {
    if (this.timer) clearInterval(this.timer);
  }
}

// ==========================================
// 4. MINI CHESS GAME (5x5 TACTICAL AI)
// ==========================================
class ChessGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.initGame();
  }

  initGame() {
    this.board = [
      [{t:'R',w:false}, {t:'N',w:false}, {t:'B',w:false}, {t:'Q',w:false}, {t:'K',w:false}],
      [{t:'P',w:false}, {t:'P',w:false}, {t:'P',w:false}, {t:'P',w:false}, {t:'P',w:false}],
      [null, null, null, null, null],
      [{t:'P',w:true}, {t:'P',w:true}, {t:'P',w:true}, {t:'P',w:true}, {t:'P',w:true}],
      [{t:'R',w:true}, {t:'N',w:true}, {t:'B',w:true}, {t:'Q',w:true}, {t:'K',w:true}]
    ];
    this.selected = null;
    this.validMoves = [];
    this.isWhiteTurn = true;
    this.isGameOver = false;
    this.score = 0;
    this.msg = this.app.lang === 'tr' ? 'Sıra sende (Beyaz)!' : 'Your turn (White)!';
    this.render();
  }

  symbol(p) {
    const s = { K: '♔', Q: '♕', R: '♖', B: '♗', N: '♘', P: '♙' };
    return s[p.t] || '?';
  }

  value(t) {
    const v = { P: 10, N: 30, B: 30, R: 50, Q: 90, K: 900 };
    return v[t] || 0;
  }

  getMoves(r, c, isWhite) {
    const p = this.board[r][c];
    if (!p || p.w !== isWhite) return [];
    const moves = [];

    const add = (nr, nc) => {
      if (nr < 0 || nr >= 5 || nc < 0 || nc >= 5) return false;
      const target = this.board[nr][nc];
      if (target) {
        if (target.w !== isWhite) moves.push({ r: nr, c: nc });
        return false;
      }
      moves.push({ r: nr, c: nc });
      return true;
    };

    if (p.t === 'P') {
      const step = isWhite ? -1 : 1;
      const fr = r + step;
      if (fr >= 0 && fr < 5 && !this.board[fr][c]) moves.push({ r: fr, c });
      for (let dc of [-1, 1]) {
        const fc = c + dc;
        if (fr >= 0 && fr < 5 && fc >= 0 && fc < 5) {
          const t = this.board[fr][fc];
          if (t && t.w !== isWhite) moves.push({ r: fr, c: fc });
        }
      }
    } else if (p.t === 'N') {
      for (let o of [[-2,-1],[-2,1],[-1,-2],[-1,2],[1,-2],[1,2],[2,-1],[2,1]]) add(r + o[0], c + o[1]);
    } else if (p.t === 'B') {
      for (let d of [[-1,-1],[-1,1],[1,-1],[1,1]]) {
        let s = 1; while (add(r + d[0]*s, c + d[1]*s)) s++;
      }
    } else if (p.t === 'R') {
      for (let d of [[-1,0],[1,0],[0,-1],[0,1]]) {
        let s = 1; while (add(r + d[0]*s, c + d[1]*s)) s++;
      }
    } else if (p.t === 'Q') {
      for (let d of [[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]]) {
        let s = 1; while (add(r + d[0]*s, c + d[1]*s)) s++;
      }
    } else if (p.t === 'K') {
      for (let d of [[-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]]) add(r + d[0], c + d[1]);
    }
    return moves;
  }

  onSquareClick(r, c) {
    if (!this.isWhiteTurn || this.isGameOver) return;

    if (this.selected && this.selected.r === r && this.selected.c === c) {
      this.selected = null;
      this.validMoves = [];
      this.render();
      return;
    }

    const moveTarget = this.validMoves.find(m => m.r === r && m.c === c);
    if (this.selected && moveTarget) {
      this.executeMove(this.selected, { r, c }, true);
      this.selected = null;
      this.validMoves = [];
      if (!this.isGameOver) {
        this.isWhiteTurn = false;
        this.msg = this.app.lang === 'tr' ? 'Bot düşünüyor...' : 'Bot thinking...';
        this.render();
        setTimeout(() => this.botTurn(), 500);
      } else {
        this.render();
      }
      return;
    }

    const p = this.board[r][c];
    if (p && p.w) {
      this.selected = { r, c };
      this.validMoves = this.getMoves(r, c, true);
      audio.playTick();
      this.render();
    }
  }

  executeMove(from, to, isWhite) {
    const moving = this.board[from.r][from.c];
    const captured = this.board[to.r][to.c];
    this.board[to.r][to.c] = moving;
    this.board[from.r][from.c] = null;

    if (moving.t === 'P' && ((isWhite && to.r === 0) || (!isWhite && to.r === 4))) {
      moving.t = 'Q';
    }

    if (captured) {
      if (isWhite) this.score += this.value(captured.t);
      if (captured.t === 'K') {
        this.isGameOver = true;
        if (isWhite) {
          this.score += 500;
          this.msg = this.app.lang === 'tr' ? '🏆 ŞAH MAT! KAZANDIN!' : '🏆 CHECKMATE! YOU WON!';
          audio.playVictory();
        } else {
          this.msg = this.app.lang === 'tr' ? 'ŞAH MAT! Bot kazandı.' : 'CHECKMATE! Bot won.';
          audio.playGameOver();
        }
        Storage.recordScore('chess', this.score);
        return;
      }
      audio.playCoin();
    } else {
      audio.playTick();
    }
  }

  botTurn() {
    if (this.isGameOver) return;
    const allMoves = [];
    for (let r = 0; r < 5; r++) {
      for (let c = 0; c < 5; c++) {
        if (this.board[r][c] && !this.board[r][c].w) {
          const moves = this.getMoves(r, c, false);
          for (let m of moves) {
            const cap = this.board[m.r][m.c];
            allMoves.push({ from: { r, c }, to: m, val: cap ? this.value(cap.t) : 0 });
          }
        }
      }
    }

    if (allMoves.length === 0) {
      this.isGameOver = true;
      this.msg = '🏆 PAT!';
      this.render();
      return;
    }

    allMoves.sort((a, b) => b.val - a.val);
    const chosen = allMoves[0];
    this.executeMove(chosen.from, chosen.to, false);

    if (!this.isGameOver) {
      this.isWhiteTurn = true;
      this.msg = this.app.lang === 'tr' ? 'Sıra sende (Beyaz)!' : 'Your turn (White)!';
    }
    this.render();
  }

  render() {
    let boardHtml = '';
    for (let r = 0; r < 5; r++) {
      let rowHtml = '';
      for (let c = 0; c < 5; c++) {
        const isLight = (r + c) % 2 === 0;
        const isSel = this.selected && this.selected.r === r && this.selected.c === c;
        const isTarget = this.validMoves.some(m => m.r === r && m.c === c);
        const p = this.board[r][c];

        let bg = isLight ? '#f4f4f5' : '#78350f';
        if (isSel) bg = '#0284c7';
        else if (isTarget) bg = '#15803d';

        rowHtml += `
          <button class="chess-sq" data-r="${r}" data-c="${c}" style="width:30px; height:30px; background:${bg}; border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; padding:0;">
            ${p ? `<span style="font-size:18px; color:${p.w ? '#fff' : '#000'}; text-shadow:0 0 2px ${p.w ? '#000' : '#fff'};">${this.symbol(p)}</span>` : (isTarget ? '<div style="width:6px; height:6px; background:#22c55e; border-radius:50%;"></div>' : '')}
          </button>
        `;
      }
      boardHtml += `<div style="display:flex;">${rowHtml}</div>`;
    }

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%; padding:2px; box-sizing:border-box;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:800; padding:0 4px;">
          <span style="color:#facc15;">${this.msg}</span>
          <span style="color:#22c55e;">${this.score} pts</span>
        </div>

        <div style="border:2px solid #52525b; border-radius:4px; overflow:hidden; margin:4px 0;">
          ${boardHtml}
        </div>

        ${this.isGameOver ? `
          <button id="chessRestartBtn" style="background:#facc15; color:#000; font-weight:900; font-size:9px; border:none; padding:3px 10px; border-radius:8px; cursor:pointer;">
            ${this.app.lang === 'tr' ? 'YENİ OYUN' : 'NEW GAME'}
          </button>
        ` : ''}
      </div>
    `;

    this.container.querySelectorAll('.chess-sq').forEach(el => {
      el.addEventListener('click', (e) => {
        const r = parseInt(e.currentTarget.dataset.r, 10);
        const c = parseInt(e.currentTarget.dataset.c, 10);
        this.onSquareClick(r, c);
      });
    });

    const restartBtn = this.container.querySelector('#chessRestartBtn');
    if (restartBtn) restartBtn.addEventListener('click', () => this.initGame());
  }

  destroy() {}
}

// ==========================================
// 5. CLASSIC CHECKERS (DAMA)
// ==========================================
class CheckersGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.initGame();
  }

  initGame() {
    this.board = Array(6).fill(null).map(() => Array(6).fill(null));
    for (let r = 0; r <= 1; r++) {
      for (let c = 0; c < 6; c++) {
        if ((r + c) % 2 !== 0) this.board[r][c] = { isPlayer: false, isKing: false };
      }
    }
    for (let r = 4; r <= 5; r++) {
      for (let c = 0; c < 6; c++) {
        if ((r + c) % 2 !== 0) this.board[r][c] = { isPlayer: true, isKing: false };
      }
    }

    this.selected = null;
    this.validMoves = [];
    this.isPlayerTurn = true;
    this.isGameOver = false;
    this.score = 0;
    this.captured = 0;
    this.msg = this.app.lang === 'tr' ? 'Taşını seç ve çapraz ilerle!' : 'Select checker to move!';
    this.render();
  }

  getMoves(r, c, isPlayer) {
    const p = this.board[r][c];
    if (!p || p.isPlayer !== isPlayer) return [];
    const moves = [];
    const rowDirs = p.isKing ? [-1, 1] : [isPlayer ? -1 : 1];
    const colDirs = [-1, 1];

    for (let dr of rowDirs) {
      for (let dc of colDirs) {
        const nr = r + dr;
        const nc = c + dc;
        if (nr >= 0 && nr < 6 && nc >= 0 && nc < 6 && !this.board[nr][nc]) {
          moves.push({ r: nr, c: nc, jr: null, jc: null });
        }
        const jr = r + 2 * dr;
        const jc = c + 2 * dc;
        if (jr >= 0 && jr < 6 && jc >= 0 && jc < 6 && !this.board[jr][jc]) {
          const mid = this.board[nr][nc];
          if (mid && mid.isPlayer !== isPlayer) {
            moves.push({ r: jr, c: jc, jr: nr, jc: nc });
          }
        }
      }
    }
    return moves;
  }

  onSquareClick(r, c) {
    if (!this.isPlayerTurn || this.isGameOver) return;

    if (this.selected && this.selected.r === r && this.selected.c === c) {
      this.selected = null;
      this.validMoves = [];
      this.render();
      return;
    }

    const moveTarget = this.validMoves.find(m => m.r === r && m.c === c);
    if (this.selected && moveTarget) {
      this.executeMove(this.selected, moveTarget, true);
      this.selected = null;
      this.validMoves = [];
      if (!this.isGameOver) {
        this.isPlayerTurn = false;
        this.msg = this.app.lang === 'tr' ? 'Bot düşünüyor...' : 'Bot thinking...';
        this.render();
        setTimeout(() => this.botTurn(), 500);
      } else {
        this.render();
      }
      return;
    }

    const p = this.board[r][c];
    if (p && p.isPlayer) {
      this.selected = { r, c };
      this.validMoves = this.getMoves(r, c, true);
      audio.playTick();
      this.render();
    }
  }

  executeMove(from, move, isPlayer) {
    const p = this.board[from.r][from.c];
    this.board[from.r][from.c] = null;

    if (isPlayer && move.r === 0) p.isKing = true;
    else if (!isPlayer && move.r === 5) p.isKing = true;

    this.board[move.r][move.c] = p;

    if (move.jr !== null) {
      this.board[move.jr][move.jc] = null;
      if (isPlayer) {
        this.captured++;
        this.score += 50;
        audio.playCoin();
      } else {
        audio.playGameOver();
      }
    } else {
      audio.playTick();
    }

    this.checkGameOver();
  }

  botTurn() {
    if (this.isGameOver) return;
    const jumps = [];
    const regular = [];

    for (let r = 0; r < 6; r++) {
      for (let c = 0; c < 6; c++) {
        if (this.board[r][c] && !this.board[r][c].isPlayer) {
          const moves = this.getMoves(r, c, false);
          for (let m of moves) {
            if (m.jr !== null) jumps.push({ from: { r, c }, move: m });
            else regular.push({ from: { r, c }, move: m });
          }
        }
      }
    }

    const pool = jumps.length > 0 ? jumps : regular;
    if (pool.length === 0) {
      this.isGameOver = true;
      this.score += 200;
      this.msg = this.app.lang === 'tr' ? '🏆 KAZANDIN! Bot hamlesiz kaldı.' : '🏆 YOU WON! Bot has no moves.';
      audio.playVictory();
      Storage.recordScore('checkers', this.score);
      this.render();
      return;
    }

    const chosen = pool[Math.floor(Math.random() * pool.length)];
    this.executeMove(chosen.from, chosen.move, false);

    if (!this.isGameOver) {
      this.isPlayerTurn = true;
      this.msg = this.app.lang === 'tr' ? 'Sıra sende (Kırmızı)!' : 'Your turn (Red)!';
    }
    this.render();
  }

  checkGameOver() {
    let pCount = 0;
    let bCount = 0;
    for (let r = 0; r < 6; r++) {
      for (let c = 0; c < 6; c++) {
        if (this.board[r][c]) {
          if (this.board[r][c].isPlayer) pCount++;
          else bCount++;
        }
      }
    }

    if (bCount === 0) {
      this.isGameOver = true;
      this.score += 300;
      this.msg = this.app.lang === 'tr' ? '🏆 DAMA ŞAMPİYONU!' : '🏆 CHECKERS CHAMPION!';
      audio.playVictory();
      Storage.recordScore('checkers', this.score);
    } else if (pCount === 0) {
      this.isGameOver = true;
      this.msg = this.app.lang === 'tr' ? 'OYUN BİTTİ! Bot kazandı.' : 'GAME OVER! Bot won.';
      audio.playGameOver();
    }
  }

  render() {
    let boardHtml = '';
    for (let r = 0; r < 6; r++) {
      let rowHtml = '';
      for (let c = 0; c < 6; c++) {
        const isDark = (r + c) % 2 !== 0;
        const isSel = this.selected && this.selected.r === r && this.selected.c === c;
        const isTarget = this.validMoves.some(m => m.r === r && m.c === c);
        const p = this.board[r][c];

        let bg = isDark ? '#18181b' : '#52525b';
        if (isSel) bg = '#eab308';
        else if (isTarget) bg = '#15803d';

        rowHtml += `
          <button class="checkers-sq" data-r="${r}" data-c="${c}" style="width:25px; height:25px; background:${bg}; border:none; display:flex; align-items:center; justify-content:center; cursor:pointer; padding:0;">
            ${p ? `<div style="width:18px; height:18px; border-radius:50%; background:${p.isPlayer ? '#ef4444' : '#a1a1aa'}; border:1px solid #fff; display:flex; align-items:center; justify-content:center; font-size:8px;">${p.isKing ? '👑' : ''}</div>` : (isTarget ? '<div style="width:6px; height:6px; background:#22c55e; border-radius:50%;"></div>' : '')}
          </button>
        `;
      }
      boardHtml += `<div style="display:flex;">${rowHtml}</div>`;
    }

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%; padding:2px; box-sizing:border-box;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:800; padding:0 4px;">
          <span style="color:#facc15;">${this.msg}</span>
          <span style="color:#ef4444;">${this.captured} ${this.app.lang === 'tr' ? 'yendi' : 'pts'}</span>
        </div>

        <div style="border:2px solid #3f3f46; border-radius:4px; overflow:hidden; margin:4px 0;">
          ${boardHtml}
        </div>

        ${this.isGameOver ? `
          <button id="checkersRestartBtn" style="background:#facc15; color:#000; font-weight:900; font-size:9px; border:none; padding:3px 10px; border-radius:8px; cursor:pointer;">
            ${this.app.lang === 'tr' ? 'YENİ OYUN' : 'NEW GAME'}
          </button>
        ` : ''}
      </div>
    `;

    this.container.querySelectorAll('.checkers-sq').forEach(el => {
      el.addEventListener('click', (e) => {
        const r = parseInt(e.currentTarget.dataset.r, 10);
        const c = parseInt(e.currentTarget.dataset.c, 10);
        this.onSquareClick(r, c);
      });
    });

    const restartBtn = this.container.querySelector('#checkersRestartBtn');
    if (restartBtn) restartBtn.addEventListener('click', () => this.initGame());
  }

  destroy() {}
}

// ==========================================
// 6. SLIDING BLOCKS ESCAPE PUZZLE
// ==========================================
class SlidingBlocksGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.level = 1;
    this.loadLevel(1);
  }

  loadLevel(lvl) {
    this.level = lvl;
    this.moves = 0;
    this.isWon = false;
    this.selectedId = null;

    if (lvl === 1) {
      this.blocks = [
        { id: 1, r: 2, c: 1, len: 2, horiz: true, target: true },
        { id: 2, r: 1, c: 3, len: 3, horiz: false, target: false },
        { id: 3, r: 4, c: 1, len: 2, horiz: true, target: false },
        { id: 4, r: 0, c: 0, len: 2, horiz: false, target: false },
        { id: 5, r: 0, c: 2, len: 2, horiz: true, target: false }
      ];
    } else if (lvl === 2) {
      this.blocks = [
        { id: 1, r: 2, c: 0, len: 2, horiz: true, target: true },
        { id: 2, r: 0, c: 2, len: 3, horiz: false, target: false },
        { id: 3, r: 1, c: 3, len: 2, horiz: true, target: false },
        { id: 4, r: 2, c: 4, len: 2, horiz: false, target: false },
        { id: 5, r: 3, c: 1, len: 2, horiz: false, target: false },
        { id: 6, r: 4, c: 2, len: 2, horiz: true, target: false }
      ];
    } else {
      this.blocks = [
        { id: 1, r: 2, c: 1, len: 2, horiz: true, target: true },
        { id: 2, r: 1, c: 3, len: 3, horiz: false, target: false },
        { id: 3, r: 0, c: 4, len: 2, horiz: false, target: false },
        { id: 4, r: 4, c: 3, len: 2, horiz: true, target: false },
        { id: 5, r: 3, c: 0, len: 2, horiz: false, target: false },
        { id: 6, r: 5, c: 1, len: 3, horiz: true, target: false }
      ];
    }
    audio.playTick();
    this.render();
  }

  slide(b, delta) {
    const nr = b.horiz ? b.r : b.r + delta;
    const nc = b.horiz ? b.c + delta : b.c;

    if (b.horiz) {
      if (nc < 0 || nc + b.len > 6) return;
    } else {
      if (nr < 0 || nr + b.len > 6) return;
    }

    for (let other of this.blocks) {
      if (other.id === b.id) continue;
      for (let s = 0; s < b.len; s++) {
        const cr = b.horiz ? nr : nr + s;
        const cc = b.horiz ? nc + s : nc;
        for (let os = 0; os < other.len; os++) {
          const or = other.horiz ? other.r : other.r + os;
          const oc = other.horiz ? other.c + os : other.c;
          if (cr === or && cc === oc) {
            audio.playGameOver();
            return;
          }
        }
      }
    }

    b.r = nr;
    b.c = nc;
    this.moves++;
    audio.playTick();

    if (b.target && b.r === 2 && b.c === 4) {
      this.isWon = true;
      audio.playVictory();
      Storage.recordScore('slidingblocks', this.moves);
    }
    this.render();
  }

  render() {
    const isTr = this.app.lang === 'tr';
    const cell = 24;

    let blocksHtml = '';
    this.blocks.forEach(b => {
      const isSel = this.selectedId === b.id;
      const w = b.horiz ? b.len * cell - 2 : cell - 2;
      const h = b.horiz ? cell - 2 : b.len * cell - 2;
      const x = b.c * cell + 1;
      const y = b.r * cell + 1;
      const bg = b.target ? '#ef4444' : (b.horiz ? '#06b6d4' : '#f97316');

      blocksHtml += `
        <div class="sb-block" data-id="${b.id}" style="position:absolute; left:${x}px; top:${y}px; width:${w}px; height:${h}px; background:${bg}; border-radius:3px; border:${isSel ? '2px solid #fff' : '1px solid rgba(0,0,0,0.4)'}; display:flex; align-items:center; justify-content:center; cursor:pointer; box-sizing:border-box;">
          ${b.target ? '🗝️' : ''}
        </div>
      `;
    });

    const selectedBlock = this.blocks.find(b => b.id === this.selectedId);

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%; padding:2px; box-sizing:border-box;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:800; padding:0 4px;">
          <span style="color:#facc15;">${isTr ? 'Bölüm' : 'Level'} ${this.level}</span>
          <span style="color:#a1a1aa;">${isTr ? 'Hamle' : 'Moves'}: ${this.moves}</span>
          <button id="sbResetLevel" style="background:transparent; border:none; color:#38bdf8; font-size:11px; cursor:pointer;">↺</button>
        </div>

        <div style="position:relative; width:${cell*6}px; height:${cell*6}px; background:rgba(120,53,15,0.3); border:1px solid #78350f; border-radius:4px; margin:4px 0;">
          <!-- Exit gate -->
          <div style="position:absolute; right:-4px; top:${cell*2}px; width:4px; height:${cell}px; background:#22c55e; border-radius:0 2px 2px 0;"></div>
          ${blocksHtml}
        </div>

        ${selectedBlock ? `
          <div style="display:flex; gap:10px;">
            ${selectedBlock.horiz ? `
              <button id="sbLeft" style="width:40px; height:20px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:9px; cursor:pointer;">◀ SOL</button>
              <button id="sbRight" style="width:40px; height:20px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:9px; cursor:pointer;">SAĞ ▶</button>
            ` : `
              <button id="sbUp" style="width:44px; height:20px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:9px; cursor:pointer;">▲ YUKARI</button>
              <button id="sbDown" style="width:44px; height:20px; background:#27272a; border:1px solid #52525b; border-radius:4px; color:#fff; font-size:9px; cursor:pointer;">▼ AŞAĞI</button>
            `}
          </div>
        ` : `
          <div style="font-size:8px; color:#71717a; height:20px; display:flex; align-items:center;">${isTr ? 'Bloğa dokunup yön tuşlarıyla kaydır' : 'Tap block to slide with arrows'}</div>
        `}

        ${this.isWon ? `
          <button id="sbNextBtn" style="margin-top:2px; background:#22c55e; color:#000; font-weight:900; font-size:9px; border:none; padding:3px 10px; border-radius:8px; cursor:pointer;">
            ${isTr ? 'SONRAKİ BÖLÜM ➔' : 'NEXT LEVEL ➔'}
          </button>
        ` : ''}
      </div>
    `;

    this.container.querySelectorAll('.sb-block').forEach(el => {
      el.addEventListener('click', (e) => {
        const id = parseInt(e.currentTarget.dataset.id, 10);
        this.selectedId = id;
        audio.playTick();
        this.render();
      });
    });

    const resetBtn = this.container.querySelector('#sbResetLevel');
    if (resetBtn) resetBtn.addEventListener('click', () => this.loadLevel(this.level));

    const leftBtn = this.container.querySelector('#sbLeft');
    if (leftBtn) leftBtn.addEventListener('click', () => this.slide(selectedBlock, -1));
    const rightBtn = this.container.querySelector('#sbRight');
    if (rightBtn) rightBtn.addEventListener('click', () => this.slide(selectedBlock, 1));
    const upBtn = this.container.querySelector('#sbUp');
    if (upBtn) upBtn.addEventListener('click', () => this.slide(selectedBlock, -1));
    const downBtn = this.container.querySelector('#sbDown');
    if (downBtn) downBtn.addEventListener('click', () => this.slide(selectedBlock, 1));

    const nextBtn = this.container.querySelector('#sbNextBtn');
    if (nextBtn) nextBtn.addEventListener('click', () => this.loadLevel((this.level % 3) + 1));
  }

  destroy() {}
}

// ============================================================
// 🌟 50 GAMES GOLDEN MILESTONE EXPANSION CLASSES
// ============================================================

// 1. NEON AIR HOCKEY
class AirHockeyGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.playerScore = 0;
    this.botScore = 0;
    this.targetScore = 5;
    this.playerX = 80;
    this.botX = 80;
    this.puckX = 80;
    this.puckY = 110;
    this.puckVx = 2.0;
    this.puckVy = 2.5;
    this.gameOver = false;
    this.animId = null;

    this.init();
  }

  init() {
    this.container.innerHTML = `
      <div style="position:relative; width:100%; height:100%; background:#09090b; overflow:hidden; user-select:none;">
        <canvas id="ahCanvas" width="180" height="230" style="width:100%; height:100%; display:block;"></canvas>
        <div id="ahOverlay" style="display:none; position:absolute; inset:0; background:rgba(0,0,0,0.85); flex-direction:column; align-items:center; justify-content:center; gap:8px;">
          <div id="ahTitle" style="font-weight:900; font-size:16px;"></div>
          <div id="ahScoreFinal" style="font-family:monospace; font-size:20px; font-weight:900; color:#fff;"></div>
          <button id="ahReplayBtn" style="background:#06b6d4; color:#000; font-weight:900; font-size:11px; border:none; padding:5px 14px; border-radius:6px; cursor:pointer;">REPLAY</button>
        </div>
      </div>
    `;

    this.canvas = this.container.querySelector('#ahCanvas');
    this.ctx = this.canvas.getContext('2d');

    // Controls: mouse/touch and Crown wheel
    const onMove = (clientX) => {
      if (this.gameOver) return;
      const rect = this.canvas.getBoundingClientRect();
      const relX = ((clientX - rect.left) / rect.width) * 180;
      this.playerX = Math.max(20, Math.min(160, relX));
    };

    this.canvas.addEventListener('mousemove', (e) => onMove(e.clientX));
    this.canvas.addEventListener('touchmove', (e) => {
      if (e.touches.length > 0) onMove(e.touches[0].clientX);
    }, { passive: true });

    this.wheelHandler = (e) => {
      e.preventDefault();
      if (this.gameOver) return;
      this.playerX = Math.max(20, Math.min(160, this.playerX + (e.deltaY > 0 ? 12 : -12)));
      audio.playTick();
    };
    window.addEventListener('wheel', this.wheelHandler, { passive: false });

    this.container.querySelector('#ahReplayBtn').addEventListener('click', () => {
      this.resetGame();
    });

    this.loop();
  }

  loop() {
    this.update();
    this.draw();
    if (!this.gameOver) {
      this.animId = requestAnimationFrame(() => this.loop());
    }
  }

  update() {
    // Puck position
    this.puckX += this.puckVx;
    this.puckY += this.puckVy;

    // Wall bounce (Left/Right)
    if (this.puckX <= 10) {
      this.puckX = 10;
      this.puckVx = -this.puckVx;
      audio.playWallBounce();
    } else if (this.puckX >= 170) {
      this.puckX = 170;
      this.puckVx = -this.puckVx;
      audio.playWallBounce();
    }

    // Bot AI tracking puck
    if (this.botX < this.puckX - 4) {
      this.botX += Math.min(2.8, this.puckX - this.botX);
    } else if (this.botX > this.puckX + 4) {
      this.botX -= Math.min(2.8, this.botX - this.puckX);
    }
    this.botX = Math.max(20, Math.min(160, this.botX));

    // Player Paddle Collision (Bottom)
    const distP = Math.hypot(this.puckX - this.playerX, this.puckY - 205);
    if (distP < 22 && this.puckVy > 0) {
      this.puckVy = -Math.abs(this.puckVy) * 1.04;
      this.puckVx = (this.puckX - this.playerX) * 0.35;
      audio.playPaddle();
    }

    // Bot Paddle Collision (Top)
    const distB = Math.hypot(this.puckX - this.botX, this.puckY - 25);
    if (distB < 22 && this.puckVy < 0) {
      this.puckVy = Math.abs(this.puckVy) * 1.04;
      this.puckVx = (this.puckX - this.botX) * 0.35;
      audio.playPaddle();
    }

    // Clamp speed
    this.puckVx = Math.max(-6, Math.min(6, this.puckVx));
    this.puckVy = Math.max(-7, Math.min(7, this.puckVy));

    // Goals (Goal width: 60px centered at 90 -> 60 to 120)
    if (this.puckY <= 8) {
      if (this.puckX >= 55 && this.puckX <= 125) {
        this.playerScore++;
        audio.playScore();
        if (this.playerScore >= this.targetScore) {
          this.endGame(true);
        } else {
          this.resetPuck(false);
        }
      } else {
        this.puckY = 8;
        this.puckVy = -this.puckVy;
      }
    } else if (this.puckY >= 222) {
      if (this.puckX >= 55 && this.puckX <= 125) {
        this.botScore++;
        audio.playLose();
        if (this.botScore >= this.targetScore) {
          this.endGame(false);
        } else {
          this.resetPuck(true);
        }
      } else {
        this.puckY = 222;
        this.puckVy = -this.puckVy;
      }
    }
  }

  resetPuck(toPlayer) {
    this.puckX = 90;
    this.puckY = 115;
    this.puckVx = (Math.random() - 0.5) * 2;
    this.puckVy = toPlayer ? 2.5 : -2.5;
  }

  endGame(won) {
    this.gameOver = true;
    const overlay = this.container.querySelector('#ahOverlay');
    const title = this.container.querySelector('#ahTitle');
    const scoreFinal = this.container.querySelector('#ahScoreFinal');
    overlay.style.display = 'flex';
    title.innerText = won ? 'VICTORY! 🏆' : 'DEFEAT!';
    title.style.color = won ? '#22c55e' : '#ef4444';
    scoreFinal.innerText = `${this.playerScore} - ${this.botScore}`;
    if (won) {
      audio.playVictory();
      confetti.trigger(40);
      Storage.recordScore('airhockey', this.playerScore * 100);
    }
  }

  resetGame() {
    this.playerScore = 0;
    this.botScore = 0;
    this.gameOver = false;
    this.container.querySelector('#ahOverlay').style.display = 'none';
    this.resetPuck(false);
    this.loop();
  }

  draw() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 180, 230);

    // Rink lines
    ctx.strokeStyle = 'rgba(6, 182, 212, 0.4)';
    ctx.lineWidth = 2;
    ctx.strokeRect(6, 6, 168, 218);

    // Center divider & circle
    ctx.beginPath();
    ctx.moveTo(6, 115);
    ctx.lineTo(174, 115);
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(90, 115, 24, 0, Math.PI * 2);
    ctx.stroke();

    // Goals
    ctx.fillStyle = 'rgba(239, 68, 68, 0.5)';
    ctx.fillRect(55, 4, 70, 4);
    ctx.fillStyle = 'rgba(34, 197, 94, 0.5)';
    ctx.fillRect(55, 222, 70, 4);

    // Bot Paddle
    ctx.fillStyle = '#ef4444';
    ctx.beginPath();
    ctx.arc(this.botX, 25, 14, 0, Math.PI * 2);
    ctx.fill();

    // Player Paddle
    ctx.fillStyle = '#06b6d4';
    ctx.beginPath();
    ctx.arc(this.playerX, 205, 14, 0, Math.PI * 2);
    ctx.fill();

    // Puck
    ctx.fillStyle = '#facc15';
    ctx.shadowColor = '#facc15';
    ctx.shadowBlur = 8;
    ctx.beginPath();
    ctx.arc(this.puckX, this.puckY, 8, 0, Math.PI * 2);
    ctx.fill();
    ctx.shadowBlur = 0;

    // Score in corner
    ctx.fillStyle = '#ef4444';
    ctx.font = 'bold 12px monospace';
    ctx.fillText(this.botScore, 14, 22);

    ctx.fillStyle = '#06b6d4';
    ctx.fillText(this.playerScore, 14, 216);
  }

  destroy() {
    this.gameOver = true;
    if (this.animId) cancelAnimationFrame(this.animId);
    if (this.wheelHandler) window.removeEventListener('wheel', this.wheelHandler);
  }
}

// 2. CLASSIC HANGMAN
class HangmanGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.enWords = ['WATCH', 'APPLE', 'ARCADE', 'CROWN', 'PULSE', 'LASER', 'CYBER', 'NEON', 'ROBOT', 'QUEST', 'POWER', 'GHOST'];
    this.trWords = ['SAAT', 'ELMA', 'OYUN', 'TEKER', 'NABIZ', 'LAZER', 'SİBER', 'NEON', 'ROBOT', 'GÖREV', 'GÜÇ', 'HAYALET'];
    this.targetWord = '';
    this.guessed = new Set();
    this.mistakes = 0;
    this.maxMistakes = 6;
    this.isWon = false;
    this.isGameOver = false;

    this.startNewGame();
  }

  startNewGame() {
    const isTr = this.app.lang === 'tr';
    const bank = isTr ? this.trWords : this.enWords;
    this.targetWord = bank[Math.floor(Math.random() * bank.length)];
    this.guessed.clear();
    this.mistakes = 0;
    this.isWon = false;
    this.isGameOver = false;

    this.render();
  }

  guess(letter) {
    if (this.guessed.has(letter) || this.isGameOver) return;
    this.guessed.add(letter);

    if (this.targetWord.includes(letter)) {
      audio.playScore();
      const allFound = [...this.targetWord].every(c => this.guessed.has(c));
      if (allFound) {
        this.isWon = true;
        this.isGameOver = true;
        audio.playVictory();
        confetti.trigger(35);
        Storage.recordScore('hangman', 100);
      }
    } else {
      this.mistakes++;
      audio.playTone(160, 0.1, 'sawtooth');
      if (this.mistakes >= this.maxMistakes) {
        this.isGameOver = true;
        audio.playLose();
      }
    }

    this.render();
  }

  render() {
    const isTr = this.app.lang === 'tr';
    const lettersRow1 = 'ABCDEFG';
    const lettersRow2 = 'HIJKLMN';
    const lettersRow3 = 'OPQRSTU';
    const lettersRow4 = 'VWXYZ';

    // Word slots
    let slotsHtml = '';
    for (const char of this.targetWord) {
      const shown = this.guessed.has(char) || this.isGameOver;
      slotsHtml += `
        <div style="display:flex; flex-direction:column; align-items:center; gap:2px;">
          <span style="font-family:monospace; font-size:14px; font-weight:900; color:${this.guessed.has(char) ? '#22c55e' : (this.isGameOver ? '#ef4444' : '#fff')}; min-width:14px; text-align:center;">
            ${shown ? char : '&nbsp;'}
          </span>
          <div style="width:14px; height:2px; background:rgba(255,255,255,0.4);"></div>
        </div>
      `;
    }

    const renderKeyboardRow = (row) => {
      let h = '';
      for (const char of row) {
        const used = this.guessed.has(char);
        const inWord = this.targetWord.includes(char);
        let bg = 'rgba(255,255,255,0.12)';
        let col = '#fff';
        if (used) {
          bg = inWord ? 'rgba(34,197,94,0.3)' : 'rgba(239,68,68,0.2)';
          col = inWord ? '#22c55e' : '#71717a';
        }
        h += `
          <button class="hm-key" data-char="${char}" ${used || this.isGameOver ? 'disabled' : ''} style="width:19px; height:20px; background:${bg}; color:${col}; font-size:10px; font-weight:700; border:none; border-radius:3px; cursor:${used ? 'default' : 'pointer'};">
            ${char}
          </button>
        `;
      }
      return `<div style="display:flex; justify-content:center; gap:3px;">${h}</div>`;
    };

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; padding:4px; gap:4px; user-select:none;">
        <!-- Header & Mistakes tracker -->
        <div style="display:flex; justify-content:space-between; width:100%; padding:0 4px; font-size:9px; font-weight:800; color:#71717a;">
          <span>HANGMAN</span>
          <div style="display:flex; gap:3px; align-items:center;">
            ${Array.from({ length: this.maxMistakes }, (_, i) => `
              <div style="width:6px; height:6px; border-radius:50%; background:${i < this.mistakes ? '#ef4444' : 'rgba(34,197,94,0.7)'};"></div>
            `).join('')}
          </div>
        </div>

        <!-- Neon Gallows SVG -->
        <div style="width:100%; height:55px; background:rgba(0,0,0,0.4); border:1px solid rgba(255,255,255,0.1); border-radius:6px; display:flex; justify-content:center; align-items:center;">
          <svg width="120" height="50" style="overflow:visible;">
            <!-- Base pole -->
            <line x1="20" y1="45" x2="50" y2="45" stroke="#71717a" stroke-width="2" />
            <line x1="35" y1="45" x2="35" y2="8" stroke="#71717a" stroke-width="2" />
            <line x1="35" y1="8" x2="80" y2="8" stroke="#71717a" stroke-width="2" />
            <line x1="80" y1="8" x2="80" y2="16" stroke="#71717a" stroke-width="2" />

            <!-- 1. Head -->
            ${this.mistakes >= 1 ? '<circle cx="80" cy="22" r="6" stroke="#f97316" stroke-width="2" fill="none" />' : ''}
            <!-- 2. Body -->
            ${this.mistakes >= 2 ? '<line x1="80" y1="28" x2="80" y2="38" stroke="#06b6d4" stroke-width="2" />' : ''}
            <!-- 3. Left Arm -->
            ${this.mistakes >= 3 ? '<line x1="80" y1="30" x2="72" y2="34" stroke="#06b6d4" stroke-width="2" />' : ''}
            <!-- 4. Right Arm -->
            ${this.mistakes >= 4 ? '<line x1="80" y1="30" x2="88" y2="34" stroke="#06b6d4" stroke-width="2" />' : ''}
            <!-- 5. Left Leg -->
            ${this.mistakes >= 5 ? '<line x1="80" y1="38" x2="74" y2="46" stroke="#ec4899" stroke-width="2" />' : ''}
            <!-- 6. Right Leg -->
            ${this.mistakes >= 6 ? '<line x1="80" y1="38" x2="86" y2="46" stroke="#ec4899" stroke-width="2" />' : ''}
          </svg>
        </div>

        <!-- Word Blanks -->
        <div style="display:flex; justify-content:center; gap:5px; margin:3px 0;">
          ${slotsHtml}
        </div>

        <!-- Status / Next button or Keyboard -->
        ${this.isGameOver ? `
          <div style="display:flex; flex-direction:column; align-items:center; gap:4px; margin-top:4px;">
            <span style="font-weight:900; font-size:12px; color:${this.isWon ? '#22c55e' : '#ef4444'};">
              ${this.isWon ? 'SOLVED! +100' : 'GAME OVER'}
            </span>
            <button id="hmNextBtn" style="background:#22c55e; color:#000; font-weight:900; font-size:10px; border:none; padding:4px 12px; border-radius:6px; cursor:pointer;">
              ${isTr ? 'YENİ KELİME' : 'NEXT WORD'}
            </button>
          </div>
        ` : `
          <div style="display:flex; flex-direction:column; gap:2px;">
            ${renderKeyboardRow(lettersRow1)}
            ${renderKeyboardRow(lettersRow2)}
            ${renderKeyboardRow(lettersRow3)}
            ${renderKeyboardRow(lettersRow4)}
          </div>
        `}
      </div>
    `;

    this.container.querySelectorAll('.hm-key').forEach(btn => {
      btn.addEventListener('click', (e) => {
        this.guess(e.currentTarget.dataset.char);
      });
    });

    const nextBtn = this.container.querySelector('#hmNextBtn');
    if (nextBtn) nextBtn.addEventListener('click', () => this.startNewGame());
  }

  destroy() {}
}

// 3. MINI SUDOKU (4x4)
class MiniSudokuGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.presets = [
      {
        solution: [[1, 2, 3, 4], [3, 4, 1, 2], [2, 1, 4, 3], [4, 3, 2, 1]],
        clues: [[1, 0, 3, 0], [0, 4, 0, 2], [2, 0, 4, 0], [0, 3, 0, 1]]
      },
      {
        solution: [[2, 4, 1, 3], [1, 3, 4, 2], [4, 2, 3, 1], [3, 1, 2, 4]],
        clues: [[2, 0, 0, 3], [0, 3, 4, 0], [0, 2, 3, 0], [3, 0, 0, 4]]
      },
      {
        solution: [[4, 1, 2, 3], [2, 3, 4, 1], [1, 4, 3, 2], [3, 2, 1, 4]],
        clues: [[4, 0, 2, 0], [0, 3, 0, 1], [1, 0, 3, 0], [0, 2, 0, 4]]
      }
    ];

    this.grid = [];
    this.selectedIdx = null;
    this.timerSeconds = 0;
    this.timerInterval = null;
    this.isSolved = false;

    this.setupNewPuzzle();
  }

  setupNewPuzzle() {
    const p = this.presets[Math.floor(Math.random() * this.presets.length)];
    this.grid = [];
    for (let r = 0; r < 4; r++) {
      for (let c = 0; c < 4; c++) {
        const val = p.clues[r][c];
        this.grid.push({
          row: r,
          col: c,
          value: val,
          isInitial: val !== 0,
          isError: false
        });
      }
    }
    this.selectedIdx = null;
    this.timerSeconds = 0;
    this.isSolved = false;

    if (this.timerInterval) clearInterval(this.timerInterval);
    this.timerInterval = setInterval(() => {
      if (!this.isSolved) {
        this.timerSeconds++;
        const timerEl = this.container.querySelector('#sudokuTimer');
        if (timerEl) timerEl.innerText = `⏱️ ${this.timerSeconds}s`;
      }
    }, 1000);

    this.render();
  }

  enterDigit(num) {
    if (this.selectedIdx === null) return;
    const cell = this.grid[this.selectedIdx];
    if (cell.isInitial || this.isSolved) return;

    cell.value = num;
    audio.playTick();
    this.checkBoard();
    this.render();
  }

  clearDigit() {
    if (this.selectedIdx === null) return;
    const cell = this.grid[this.selectedIdx];
    if (cell.isInitial || this.isSolved) return;

    cell.value = 0;
    cell.isError = false;
    audio.playTick();
    this.checkBoard();
    this.render();
  }

  checkBoard() {
    for (const c of this.grid) c.isError = false;
    let hasConflict = false;

    // Check rows
    for (let r = 0; r < 4; r++) {
      const seen = {};
      for (let c = 0; c < 4; c++) {
        const idx = r * 4 + c;
        const v = this.grid[idx].value;
        if (v > 0) {
          if (seen[v] !== undefined) {
            this.grid[idx].isError = true;
            this.grid[seen[v]].isError = true;
            hasConflict = true;
          } else {
            seen[v] = idx;
          }
        }
      }
    }

    // Check columns
    for (let c = 0; c < 4; c++) {
      const seen = {};
      for (let r = 0; r < 4; r++) {
        const idx = r * 4 + c;
        const v = this.grid[idx].value;
        if (v > 0) {
          if (seen[v] !== undefined) {
            this.grid[idx].isError = true;
            this.grid[seen[v]].isError = true;
            hasConflict = true;
          } else {
            seen[v] = idx;
          }
        }
      }
    }

    // Check 2x2 blocks
    const blocks = [[0, 0], [0, 2], [2, 0], [2, 2]];
    for (const [br, bc] of blocks) {
      const seen = {};
      for (let r = 0; r < 2; r++) {
        for (let c = 0; c < 2; c++) {
          const idx = (br + r) * 4 + (bc + c);
          const v = this.grid[idx].value;
          if (v > 0) {
            if (seen[v] !== undefined) {
              this.grid[idx].isError = true;
              this.grid[seen[v]].isError = true;
              hasConflict = true;
            } else {
              seen[v] = idx;
            }
          }
        }
      }
    }

    const allFilled = this.grid.every(c => c.value > 0);
    if (allFilled && !hasConflict) {
      this.isSolved = true;
      audio.playVictory();
      confetti.trigger(40);
      const score = Math.max(50, 1000 - this.timerSeconds * 5);
      Storage.recordScore('minisudoku', score);
    }
  }

  render() {
    const isTr = this.app.lang === 'tr';

    let gridHtml = '';
    for (let r = 0; r < 4; r++) {
      let rowHtml = '';
      for (let c = 0; c < 4; c++) {
        const idx = r * 4 + c;
        const cell = this.grid[idx];
        const isSelected = this.selectedIdx === idx;

        let bg = 'rgba(255,255,255,0.06)';
        let border = '1px solid rgba(255,255,255,0.2)';
        let color = cell.isInitial ? '#fff' : '#facc15';

        if (cell.isInitial) bg = 'rgba(255,255,255,0.12)';
        if (isSelected) {
          bg = 'rgba(59, 130, 246, 0.4)';
          border = '2px solid #06b6d4';
        }
        if (cell.isError) {
          bg = 'rgba(239, 68, 68, 0.4)';
          color = '#ef4444';
        }

        rowHtml += `
          <button class="sudoku-cell" data-idx="${idx}" ${cell.isInitial || this.isSolved ? 'disabled' : ''} style="width:34px; height:34px; background:${bg}; border:${border}; border-radius:4px; font-size:16px; font-weight:${cell.isInitial ? '900' : '700'}; color:${color}; cursor:${cell.isInitial ? 'default' : 'pointer'}; display:flex; align-items:center; justify-content:center;">
            ${cell.value > 0 ? cell.value : ''}
          </button>
        `;
      }
      gridHtml += `<div style="display:flex; gap:3px;">${rowHtml}</div>`;
      if (r === 1) {
        gridHtml += `<div style="width:100%; height:1px; background:rgba(255,255,255,0.3); margin:1px 0;"></div>`;
      }
    }

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; padding:4px; gap:4px; user-select:none;">
        <!-- Header -->
        <div style="display:flex; justify-content:space-between; width:100%; padding:0 6px; font-size:9px; font-weight:800; color:#71717a;">
          <span>MINI SUDOKU</span>
          <span id="sudokuTimer" style="color:#06b6d4; font-family:monospace;">⏱️ ${this.timerSeconds}s</span>
        </div>

        <!-- 4x4 Grid Container -->
        <div style="display:flex; flex-direction:column; gap:3px; background:rgba(0,0,0,0.5); padding:6px; border-radius:8px; border:1px solid rgba(255,255,255,0.1);">
          ${gridHtml}
        </div>

        <!-- Numpad or Solved -->
        ${this.isSolved ? `
          <div style="display:flex; flex-direction:column; align-items:center; gap:4px; margin-top:2px;">
            <span style="font-weight:900; font-size:12px; color:#22c55e;">SOLVED! 🏆</span>
            <button id="sudokuNewBtn" style="background:#22c55e; color:#000; font-weight:900; font-size:10px; border:none; padding:4px 12px; border-radius:6px; cursor:pointer;">
              ${isTr ? 'YENİ BULMACA' : 'NEW PUZZLE'}
            </button>
          </div>
        ` : `
          <div style="display:flex; gap:6px; margin-top:3px;">
            ${[1, 2, 3, 4].map(n => `
              <button class="sudoku-num" data-num="${n}" style="width:28px; height:26px; background:rgba(6,182,212,0.25); color:#06b6d4; border:1px solid #06b6d4; border-radius:5px; font-weight:900; font-size:13px; cursor:pointer;">
                ${n}
              </button>
            `).join('')}
            <button id="sudokuClear" style="width:28px; height:26px; background:rgba(239,68,68,0.25); color:#ef4444; border:1px solid #ef4444; border-radius:5px; font-weight:900; font-size:11px; cursor:pointer;">
              ✕
            </button>
          </div>
        `}
      </div>
    `;

    this.container.querySelectorAll('.sudoku-cell').forEach(el => {
      el.addEventListener('click', (e) => {
        this.selectedIdx = parseInt(e.currentTarget.dataset.idx, 10);
        audio.playTick();
        this.render();
      });
    });

    this.container.querySelectorAll('.sudoku-num').forEach(el => {
      el.addEventListener('click', (e) => {
        this.enterDigit(parseInt(e.currentTarget.dataset.num, 10));
      });
    });

    const clearBtn = this.container.querySelector('#sudokuClear');
    if (clearBtn) clearBtn.addEventListener('click', () => this.clearDigit());

    const newBtn = this.container.querySelector('#sudokuNewBtn');
    if (newBtn) newBtn.addEventListener('click', () => this.setupNewPuzzle());
  }

  destroy() {
    if (this.timerInterval) clearInterval(this.timerInterval);
  }
}

// 4. RETRO LUNAR LANDER
class LunarLanderGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.shipX = 80;
    this.shipY = 25;
    this.vx = 0.4;
    this.vy = 0.0;
    this.fuel = 100.0;
    this.isThrusting = false;
    this.gameOver = false;
    this.hasLanded = false;
    this.statusText = 'DESCENDING';
    this.score = 0;
    this.animId = null;

    this.padX = 55;
    this.padWidth = 50;
    this.groundY = 185;
    this.gravity = 0.07;
    this.thrustPower = 0.22;
    this.maxSafeSpeed = 1.6;

    this.init();
  }

  init() {
    this.container.innerHTML = `
      <div style="position:relative; width:100%; height:100%; background:#000; overflow:hidden; user-select:none;">
        <canvas id="llCanvas" width="180" height="230" style="width:100%; height:100%; display:block;"></canvas>
        <div id="llOverlay" style="display:none; position:absolute; inset:0; background:rgba(0,0,0,0.85); flex-direction:column; align-items:center; justify-content:center; gap:8px;">
          <div id="llStatus" style="font-weight:900; font-size:15px;"></div>
          <div id="llScoreFinal" style="font-family:monospace; font-size:16px; font-weight:900; color:#facc15;"></div>
          <button id="llRetryBtn" style="background:#22c55e; color:#000; font-weight:900; font-size:11px; border:none; padding:5px 14px; border-radius:6px; cursor:pointer;">RETRY</button>
        </div>
      </div>
    `;

    this.canvas = this.container.querySelector('#llCanvas');
    this.ctx = this.canvas.getContext('2d');

    const pressThrust = () => {
      if (this.fuel > 0 && !this.gameOver) {
        this.isThrusting = true;
        this.vy -= this.thrustPower;
        this.fuel = Math.max(0, this.fuel - 0.75);
        audio.playTick();
      }
    };

    const releaseThrust = () => {
      this.isThrusting = false;
    };

    this.canvas.addEventListener('mousedown', pressThrust);
    window.addEventListener('mouseup', releaseThrust);
    this.canvas.addEventListener('touchstart', (e) => { e.preventDefault(); pressThrust(); }, { passive: false });
    window.addEventListener('touchend', releaseThrust);

    this.wheelHandler = (e) => {
      e.preventDefault();
      if (this.gameOver) return;
      if (e.deltaY < 0) {
        pressThrust();
      } else {
        this.shipX = Math.max(10, Math.min(170, this.shipX + 4));
      }
    };
    window.addEventListener('wheel', this.wheelHandler, { passive: false });

    this.container.querySelector('#llRetryBtn').addEventListener('click', () => {
      this.resetMission();
    });

    this.loop();
  }

  loop() {
    this.update();
    this.draw();
    if (!this.gameOver) {
      this.animId = requestAnimationFrame(() => this.loop());
    }
  }

  update() {
    this.vy += this.gravity;
    this.shipX += this.vx;
    this.shipY += this.vy;

    // Bounds bounce
    if (this.shipX <= 8) {
      this.shipX = 8;
      this.vx = -this.vx * 0.5;
    } else if (this.shipX >= 172) {
      this.shipX = 172;
      this.vx = -this.vx * 0.5;
    }

    // Ground Touchdown
    if (this.shipY >= this.groundY - 6) {
      this.shipY = this.groundY - 6;
      this.gameOver = true;
      this.isThrusting = false;

      const onPad = this.shipX >= this.padX && this.shipX <= (this.padX + this.padWidth);
      const safeSpeed = Math.abs(this.vy) <= this.maxSafeSpeed;

      const overlay = this.container.querySelector('#llOverlay');
      const status = this.container.querySelector('#llStatus');
      const scoreEl = this.container.querySelector('#llScoreFinal');
      overlay.style.display = 'flex';

      if (onPad && safeSpeed) {
        this.hasLanded = true;
        this.score = 500 + Math.floor(this.fuel * 10);
        status.innerText = 'TOUCHDOWN! 🚀';
        status.style.color = '#22c55e';
        scoreEl.innerText = `SCORE: ${this.score}`;
        audio.playVictory();
        confetti.trigger(40);
        Storage.recordScore('lunarlander', this.score);
      } else {
        this.hasLanded = false;
        status.innerText = !onPad ? 'OFF TARGET CRASH!' : 'HARD CRASH!';
        status.style.color = '#ef4444';
        scoreEl.innerText = '';
        audio.playLose();
      }
    }
  }

  draw() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 180, 230);

    // Stars
    ctx.fillStyle = 'rgba(255,255,255,0.7)';
    const stars = [[20, 15], [75, 40], [130, 20], [45, 90], [110, 120], [145, 80], [165, 35]];
    for (const [sx, sy] of stars) {
      ctx.fillRect(sx, sy, 2, 2);
    }

    // Terrain & Pad
    ctx.fillStyle = '#27272a';
    ctx.beginPath();
    ctx.moveTo(0, this.groundY);
    ctx.lineTo(this.padX, this.groundY);
    ctx.lineTo(this.padX + this.padWidth, this.groundY);
    ctx.lineTo(180, this.groundY);
    ctx.lineTo(180, 230);
    ctx.lineTo(0, 230);
    ctx.closePath();
    ctx.fill();

    // Neon Green Landing Pad
    ctx.strokeStyle = '#22c55e';
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.moveTo(this.padX, this.groundY);
    ctx.lineTo(this.padX + this.padWidth, this.groundY);
    ctx.stroke();

    // Lander
    ctx.save();
    ctx.translate(this.shipX, this.shipY);

    // Flame
    if (this.isThrusting && this.fuel > 0) {
      ctx.fillStyle = '#f97316';
      ctx.beginPath();
      ctx.moveTo(-3, 6);
      ctx.lineTo(3, 6);
      ctx.lineTo(0, 15);
      ctx.closePath();
      ctx.fill();
    }

    // Body
    ctx.fillStyle = '#facc15';
    ctx.beginPath();
    ctx.arc(0, 0, 6, 0, Math.PI * 2);
    ctx.fill();

    // Legs
    ctx.strokeStyle = '#fff';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(-4, 3);
    ctx.lineTo(-7, 7);
    ctx.moveTo(4, 3);
    ctx.lineTo(7, 7);
    ctx.stroke();

    ctx.restore();

    // HUD: Fuel & Vertical Speed
    ctx.font = 'bold 9px monospace';
    ctx.fillStyle = this.fuel > 20 ? '#06b6d4' : '#ef4444';
    ctx.fillText(`FUEL: ${Math.floor(this.fuel)}%`, 8, 14);

    ctx.fillStyle = Math.abs(this.vy) <= this.maxSafeSpeed ? '#22c55e' : '#ef4444';
    ctx.fillText(`V-SPD: ${this.vy.toFixed(1)}`, 115, 14);
  }

  resetMission() {
    this.shipX = 40 + Math.random() * 100;
    this.shipY = 25;
    this.vx = (Math.random() - 0.5) * 0.6;
    this.vy = 0.0;
    this.fuel = 100.0;
    this.isThrusting = false;
    this.gameOver = false;
    this.hasLanded = false;
    this.container.querySelector('#llOverlay').style.display = 'none';
    this.loop();
  }

  destroy() {
    this.gameOver = true;
    if (this.animId) cancelAnimationFrame(this.animId);
    if (this.wheelHandler) window.removeEventListener('wheel', this.wheelHandler);
  }
}

class NineMenMorrisGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    
    // 24 Points (0..23)
    // 0: empty, 1: player, 2: bot
    this.board = new Array(24).fill(0);
    this.playerUnplaced = 9;
    this.botUnplaced = 9;
    this.phase = 'placing'; // 'placing', 'moving', 'removing', 'gameOver'
    this.isPlayerTurn = true;
    this.selectedIndex = null;
    this.score = 0;
    this.statusText = this.isTr ? 'Taşını boş noktaya koy (9 kaldı)' : 'Place stone on empty point (9 left)';

    this.nodeCoords = [
      // Outer (0..7)
      { x: 14, y: 14 }, { x: 85, y: 14 }, { x: 156, y: 14 },
      { x: 156, y: 85 }, { x: 156, y: 156 }, { x: 85, y: 156 },
      { x: 14, y: 156 }, { x: 14, y: 85 },
      // Middle (8..15)
      { x: 38, y: 38 }, { x: 85, y: 38 }, { x: 132, y: 38 },
      { x: 132, y: 85 }, { x: 132, y: 132 }, { x: 85, y: 132 },
      { x: 38, y: 132 }, { x: 38, y: 85 },
      // Inner (16..23)
      { x: 62, y: 62 }, { x: 85, y: 62 }, { x: 108, y: 62 },
      { x: 108, y: 85 }, { x: 108, y: 108 }, { x: 85, y: 108 },
      { x: 62, y: 108 }, { x: 62, y: 85 }
    ];

    this.adjacencies = [
      [1, 7], [0, 2, 9], [1, 3], [2, 4, 11], [3, 5], [4, 6, 13], [5, 7], [6, 0, 15],
      [9, 15], [8, 10, 1, 17], [9, 11], [10, 12, 3, 19], [11, 13], [12, 14, 5, 21], [13, 15], [14, 8, 7, 23],
      [17, 23], [16, 18, 9], [17, 19], [18, 20, 11], [19, 21], [20, 22, 13], [21, 23], [22, 16, 15]
    ];

    this.mills = [
      [0, 1, 2], [2, 3, 4], [4, 5, 6], [6, 7, 0],
      [8, 9, 10], [10, 11, 12], [12, 13, 14], [14, 15, 8],
      [16, 17, 18], [18, 19, 20], [20, 21, 22], [22, 23, 16],
      [1, 9, 17], [3, 11, 19], [5, 13, 21], [7, 15, 23]
    ];

    this.render();
  }

  render() {
    const pCount = this.board.filter(b => b === 1).length;
    const bCount = this.board.filter(b => b === 2).length;

    let svgLines = `
      <rect x="14" y="14" width="142" height="142" fill="none" stroke="rgba(255,255,255,0.35)" stroke-width="1.5" />
      <rect x="38" y="38" width="94" height="94" fill="none" stroke="rgba(255,255,255,0.35)" stroke-width="1.5" />
      <rect x="62" y="62" width="46" height="46" fill="none" stroke="rgba(255,255,255,0.35)" stroke-width="1.5" />
      <line x1="85" y1="14" x2="85" y2="62" stroke="rgba(255,255,255,0.35)" stroke-width="1.5" />
      <line x1="156" y1="85" x2="108" y2="85" stroke="rgba(255,255,255,0.35)" stroke-width="1.5" />
      <line x1="85" y1="156" x2="85" y2="108" stroke="rgba(255,255,255,0.35)" stroke-width="1.5" />
      <line x1="14" y1="85" x2="62" y2="85" stroke="rgba(255,255,255,0.35)" stroke-width="1.5" />
    `;

    let nodesHtml = '';
    this.nodeCoords.forEach((pt, idx) => {
      const val = this.board[idx];
      const isSelected = this.selectedIndex === idx;
      const isRemovable = this.phase === 'removing' && this.isPlayerTurn && this.isRemovableStone(idx);
      const isValidTarget = this.selectedIndex !== null && this.isValidMove(this.selectedIndex, idx);

      let stroke = 'transparent';
      let strokeWidth = '0';
      if (isSelected) {
        stroke = '#fbbf24';
        strokeWidth = '2';
      } else if (isRemovable) {
        stroke = '#ef4444';
        strokeWidth = '2';
      } else if (isValidTarget) {
        stroke = '#22c55e';
        strokeWidth = '2';
      }

      let fill = 'rgba(255,255,255,0.3)';
      let r = 4;
      if (val === 1) {
        fill = '#38bdf8';
        r = 6.5;
      } else if (val === 2) {
        fill = '#f97316';
        r = 6.5;
      }

      nodesHtml += `
        <g class="morris-node" data-idx="${idx}" style="cursor:pointer;">
          <circle cx="${pt.x}" cy="${pt.y}" r="11" fill="transparent" stroke="${stroke}" stroke-width="${strokeWidth}" />
          <circle cx="${pt.x}" cy="${pt.y}" r="${r}" fill="${fill}" />
        </g>
      `;
    });

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; height:100%; width:100%; background:#000; padding:4px 6px; box-sizing:border-box; align-items:center;">
        <!-- Header HUD -->
        <div style="width:100%; display:flex; justify-content:space-between; align-items:center; margin-bottom:2px;">
          <span style="font-size:8px; font-weight:800; color:${this.isPlayerTurn ? '#38bdf8' : '#f97316'}; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:110px;">
            ${this.statusText}
          </span>
          <div style="display:flex; gap:4px; font-size:8px; font-weight:900;">
            <span style="color:#38bdf8;">P:${pCount}</span>
            <span style="color:#f97316;">B:${bCount}</span>
          </div>
        </div>

        <!-- Board SVG -->
        <div style="position:relative; width:170px; height:170px;">
          <svg viewBox="0 0 170 170" style="width:170px; height:170px; display:block;">
            ${svgLines}
            ${nodesHtml}
          </svg>
        </div>

        ${this.phase === 'gameOver' ? `
          <div style="margin-top:2px;">
            <button id="btnMorrisRestart" style="font-size:9px; font-weight:900; background:#f59e0b; color:#000; border:none; border-radius:6px; padding:3px 10px; cursor:pointer;">
              ${this.isTr ? 'YENİDEN BAŞLA' : 'PLAY AGAIN'}
            </button>
          </div>
        ` : ''}
      </div>
    `;

    // Event hooks
    this.container.querySelectorAll('.morris-node').forEach(node => {
      node.addEventListener('click', () => {
        const idx = Number(node.dataset.idx);
        this.handleNodeClick(idx);
      });
    });

    const restartBtn = this.container.querySelector('#btnMorrisRestart');
    if (restartBtn) {
      restartBtn.addEventListener('click', () => {
        audio.playTick();
        this.reset();
      });
    }
  }

  handleNodeClick(idx) {
    if (!this.isPlayerTurn) return;

    if (this.phase === 'placing') {
      if (this.board[idx] === 0) {
        audio.playMove();
        this.board[idx] = 1;
        this.playerUnplaced--;

        if (this.checkMillFormed(idx, 1)) {
          audio.playVictory();
          this.phase = 'removing';
          this.statusText = this.isTr ? 'Değirmen! Rakip taşı kaldır.' : 'Mill! Remove enemy stone.';
          this.render();
        } else {
          this.checkPlacingDoneAndSwitchTurn();
        }
      }
    } else if (this.phase === 'moving') {
      if (this.board[idx] === 1) {
        audio.playTick();
        this.selectedIndex = idx;
        this.statusText = this.isTr ? 'Hedef noktayı seç' : 'Select target spot';
        this.render();
      } else if (this.selectedIndex !== null && this.board[idx] === 0 && this.isValidMove(this.selectedIndex, idx)) {
        audio.playMove();
        this.board[this.selectedIndex] = 0;
        this.board[idx] = 1;
        this.selectedIndex = null;

        if (this.checkMillFormed(idx, 1)) {
          audio.playVictory();
          this.phase = 'removing';
          this.statusText = this.isTr ? 'Değirmen! Rakip taşı kaldır.' : 'Mill! Remove enemy stone.';
          this.render();
        } else {
          this.endPlayerTurn();
        }
      }
    } else if (this.phase === 'removing') {
      if (this.isRemovableStone(idx)) {
        audio.playCapture();
        this.board[idx] = 0;
        this.score += 10;

        const bCount = this.board.filter(b => b === 2).length;
        if (bCount < 3 && this.botUnplaced === 0) {
          this.playerWonGame();
        } else {
          if (this.playerUnplaced > 0 || this.botUnplaced > 0) {
            this.phase = 'placing';
          } else {
            this.phase = 'moving';
          }
          this.endPlayerTurn();
        }
      }
    }
  }

  checkPlacingDoneAndSwitchTurn() {
    if (this.playerUnplaced === 0 && this.botUnplaced === 0) {
      this.phase = 'moving';
    }
    this.endPlayerTurn();
  }

  endPlayerTurn() {
    this.isPlayerTurn = false;
    this.statusText = this.isTr ? 'Bot düşünüyor...' : 'Bot is thinking...';
    this.render();

    setTimeout(() => {
      this.executeBotTurn();
    }, 550);
  }

  executeBotTurn() {
    if (this.phase === 'gameOver') return;

    if (this.botUnplaced > 0) {
      const bestSpot = this.botFindBestPlaceSpot();
      this.board[bestSpot] = 2;
      this.botUnplaced--;
      audio.playMove();

      if (this.checkMillFormed(bestSpot, 2)) {
        audio.playBuzzer();
        this.botRemovePlayerStone();
      }

      if (this.playerUnplaced === 0 && this.botUnplaced === 0) {
        this.phase = 'moving';
      }
      this.endBotTurn();
    } else {
      const bestMove = this.botFindBestMove();
      if (bestMove) {
        this.board[bestMove.from] = 0;
        this.board[bestMove.to] = 2;
        audio.playMove();

        if (this.checkMillFormed(bestMove.to, 2)) {
          audio.playBuzzer();
          this.botRemovePlayerStone();
        }

        const pCount = this.board.filter(b => b === 1).length;
        if (pCount < 3 && this.playerUnplaced === 0) {
          this.botWonGame();
          return;
        }
        this.endBotTurn();
      } else {
        // Bot has no moves -> player wins
        this.playerWonGame();
      }
    }
  }

  endBotTurn() {
    const pCount = this.board.filter(b => b === 1).length;
    if (pCount < 3 && this.playerUnplaced === 0) {
      this.botWonGame();
      return;
    }

    this.isPlayerTurn = true;
    if (this.phase === 'placing') {
      this.statusText = this.isTr ? `Taşını koy (${this.playerUnplaced} kaldı)` : `Place stone (${this.playerUnplaced} left)`;
    } else {
      const isFlying = pCount === 3;
      this.statusText = isFlying ? (this.isTr ? 'Uçuş modu! İstediğin yere taşı' : 'Flying mode! Move anywhere') : (this.isTr ? 'Taşını seç ve hareket et' : 'Select stone and move');
    }
    this.render();
  }

  botFindBestPlaceSpot() {
    // 1. Can bot make mill?
    for (let i = 0; i < 24; i++) {
      if (this.board[i] === 0) {
        this.board[i] = 2;
        const mill = this.checkMillFormed(i, 2);
        this.board[i] = 0;
        if (mill) return i;
      }
    }
    // 2. Can player make mill? Block it!
    for (let i = 0; i < 24; i++) {
      if (this.board[i] === 0) {
        this.board[i] = 1;
        const mill = this.checkMillFormed(i, 1);
        this.board[i] = 0;
        if (mill) return i;
      }
    }
    // 3. Priorities
    const priorities = [9, 11, 13, 15, 1, 3, 5, 7, 17, 19, 21, 23, 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22];
    for (const p of priorities) {
      if (this.board[p] === 0) return p;
    }
    const empties = [];
    for (let i = 0; i < 24; i++) if (this.board[i] === 0) empties.push(i);
    return empties[Math.floor(Math.random() * empties.length)] || 0;
  }

  botFindBestMove() {
    const bCount = this.board.filter(b => b === 2).length;
    const isFlying = bCount === 3;
    const allMoves = [];

    for (let from = 0; from < 24; from++) {
      if (this.board[from] === 2) {
        let possibleTos = [];
        if (isFlying) {
          for (let i = 0; i < 24; i++) if (this.board[i] === 0) possibleTos.push(i);
        } else {
          possibleTos = this.adjacencies[from].filter(t => this.board[t] === 0);
        }

        for (const to of possibleTos) {
          this.board[from] = 0;
          this.board[to] = 2;
          const formsMill = this.checkMillFormed(to, 2);
          this.board[from] = 2;
          this.board[to] = 0;
          allMoves.push({ from, to, formsMill });
        }
      }
    }

    if (allMoves.length === 0) return null;
    const millMove = allMoves.find(m => m.formsMill);
    if (millMove) return millMove;
    return allMoves[Math.floor(Math.random() * allMoves.length)];
  }

  botRemovePlayerStone() {
    const candidates = [];
    for (let i = 0; i < 24; i++) if (this.board[i] === 1) candidates.push(i);
    const notInMill = candidates.filter(c => !this.checkIsInMill(c, 1));
    const list = notInMill.length > 0 ? notInMill : candidates;
    const target = list[Math.floor(Math.random() * list.length)];
    if (target !== undefined) {
      this.board[target] = 0;
    }
  }

  checkMillFormed(idx, player) {
    for (const mill of this.mills) {
      if (mill.includes(idx)) {
        if (mill.every(pos => this.board[pos] === player)) {
          return true;
        }
      }
    }
    return false;
  }

  checkIsInMill(idx, player) {
    return this.checkMillFormed(idx, player);
  }

  isValidMove(from, to) {
    if (this.board[to] !== 0) return false;
    const pCount = this.board.filter(b => b === 1).length;
    const isFlying = pCount === 3;
    if (isFlying) return true;
    return this.adjacencies[from].includes(to);
  }

  isRemovableStone(idx) {
    if (this.board[idx] !== 2) return false;
    const inMill = this.checkIsInMill(idx, 2);
    if (!inMill) return true;
    const allBot = [];
    for (let i = 0; i < 24; i++) if (this.board[i] === 2) allBot.push(i);
    return allBot.every(pos => this.checkIsInMill(pos, 2));
  }

  playerWonGame() {
    this.phase = 'gameOver';
    this.statusText = this.isTr ? '👑 ZAFER! 9 TAŞ KAZANDIN' : '👑 VICTORY! 9 STONES CLEARED';
    audio.playVictory();
    confetti.trigger(60);
    Storage.recordScore('ninemensmorris', 100);
    Storage.addXP(100, '9 Taş Zaferi');
    this.render();
  }

  botWonGame() {
    this.phase = 'gameOver';
    this.statusText = this.isTr ? '💀 OYUN BİTTİ! BOT KAZANDI' : '💀 GAME OVER! BOT WON';
    audio.playBuzzer();
    this.render();
  }

  reset() {
    this.board = new Array(24).fill(0);
    this.playerUnplaced = 9;
    this.botUnplaced = 9;
    this.phase = 'placing';
    this.isPlayerTurn = true;
    this.selectedIndex = null;
    this.score = 0;
    this.statusText = this.isTr ? 'Taşını boş noktaya koy (9 kaldı)' : 'Place stone on empty point (9 left)';
    this.render();
  }

  destroy() {
    this.board = null;
  }
}

// ===================================================
// 52. SEA BATTLE (AMİRAL BATTI - 5x5 RADAR TORPEDO)
// ===================================================
class SeaBattleGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.reset();
  }

  reset() {
    this.grid = new Array(25).fill(0); // 0: unrevealed, 1: miss, 2: hit
    this.torpedosUsed = 0;
    this.maxTorpedos = 18;
    this.gameOver = false;
    this.won = false;
    this.shipCells = new Set();
    this.spawnFleet();
    this.statusText = this.isTr ? 'Radar karesine dokunarak torpido at!' : 'Tap radar grid to launch torpedo!';
    this.render();
  }

  spawnFleet() {
    const occupied = new Set();
    // 3-cell Cruiser
    const cruiserHoriz = Math.random() < 0.5;
    if (cruiserHoriz) {
      const r = Math.floor(Math.random() * 5);
      const c = Math.floor(Math.random() * 3);
      for (let i = 0; i < 3; i++) occupied.add(r * 5 + (c + i));
    } else {
      const r = Math.floor(Math.random() * 3);
      const c = Math.floor(Math.random() * 5);
      for (let i = 0; i < 3; i++) occupied.add((r + i) * 5 + c);
    }
    // 2-cell Submarine
    let subPlaced = false;
    let attempts = 0;
    while (!subPlaced && attempts < 50) {
      attempts++;
      const isHoriz = Math.random() < 0.5;
      const candidate = new Set();
      if (isHoriz) {
        const r = Math.floor(Math.random() * 5);
        const c = Math.floor(Math.random() * 4);
        candidate.add(r * 5 + c);
        candidate.add(r * 5 + c + 1);
      } else {
        const r = Math.floor(Math.random() * 4);
        const c = Math.floor(Math.random() * 5);
        candidate.add(r * 5 + c);
        candidate.add((r + 1) * 5 + c);
      }
      let collision = false;
      candidate.forEach(cell => { if (occupied.has(cell)) collision = true; });
      if (!collision) {
        candidate.forEach(cell => occupied.add(cell));
        subPlaced = true;
      }
    }
    // 1-cell Patrol
    let patrolPlaced = false;
    while (!patrolPlaced) {
      const cell = Math.floor(Math.random() * 25);
      if (!occupied.has(cell)) {
        occupied.add(cell);
        patrolPlaced = true;
      }
    }
    this.shipCells = occupied;
  }

  fireTorpedo(idx) {
    if (this.grid[idx] !== 0 || this.gameOver) return;
    this.torpedosUsed++;

    if (this.shipCells.has(idx)) {
      this.grid[idx] = 2; // hit
      audio.playScore();
      this.statusText = this.isTr ? '💥 DİREKT İSABET!' : '💥 DIRECT HIT!';
      
      let hits = 0;
      this.shipCells.forEach(cell => { if (this.grid[cell] === 2) hits++; });
      if (hits === this.shipCells.size) {
        this.gameOver = true;
        this.won = true;
        audio.playVictory();
        confetti.trigger(50);
        const score = Math.max(100, 1000 - (this.torpedosUsed * 40));
        Storage.recordScore('seabattle', score);
        Storage.addXP(150, 'Amiral Battı Zaferi');
        this.statusText = this.isTr ? `🏆 TÜM FİLO BATTI! (${this.torpedosUsed} atış)` : `🏆 FLEET SUNK! (${this.torpedosUsed} shots)`;
      }
    } else {
      this.grid[idx] = 1; // miss
      audio.playTick();
      this.statusText = this.isTr ? '💧 Karavana! Su sıçraması.' : '💧 Splash... Water miss.';
      if (this.torpedosUsed >= this.maxTorpedos) {
        this.gameOver = true;
        this.won = false;
        audio.playGameOver();
        this.statusText = this.isTr ? '💀 CEPHANE BİTTİ! Filo kaçtı.' : '💀 OUT OF AMMO! Fleet escaped.';
      }
    }
    this.render();
  }

  render() {
    let hits = 0;
    this.shipCells.forEach(c => { if (this.grid[c] === 2) hits++; });

    let cellsHtml = '';
    for (let i = 0; i < 25; i++) {
      const state = this.grid[i];
      let cls = 'seabattle-cell';
      let content = '';
      if (state === 1) { cls += ' miss'; content = '💧'; }
      else if (state === 2) { cls += ' hit'; content = '🔥'; }
      cellsHtml += `<div class="${cls}" data-idx="${i}">${content}</div>`;
    }

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; gap:6px; padding:4px;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:800; padding:0 8px;">
          <span style="color:${this.torpedosUsed > 14 ? '#f97316' : '#06b6d4'};">🚀 ${this.torpedosUsed}/${this.maxTorpedos}</span>
          <span style="color:#22c55e;">🚢 ${hits}/${this.shipCells.size}</span>
        </div>
        <div class="seabattle-grid" id="seaGrid">${cellsHtml}</div>
        <div style="font-size:9.5px; font-weight:700; color:#cbd5e1; text-align:center;">${this.statusText}</div>
        ${this.gameOver ? `
          <button class="play-btn" id="btnSeaReset" style="background:#06b6d4; color:#000; font-size:11px; padding:4px 16px;">
            ${this.isTr ? 'Tekrar Oyna' : 'Play Again'}
          </button>
        ` : ''}
      </div>
    `;

    this.container.querySelectorAll('.seabattle-cell').forEach(cell => {
      cell.addEventListener('click', () => {
        const idx = parseInt(cell.dataset.idx, 10);
        this.fireTorpedo(idx);
      });
    });

    const resetBtn = this.container.querySelector('#btnSeaReset');
    if (resetBtn) resetBtn.addEventListener('click', () => this.reset());
  }

  destroy() {
    this.grid = null;
  }
}

// ===================================================
// 53. REVERSI / OTHELLO (6x6 TACTICAL FLIP)
// ===================================================
class ReversiGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.dirs = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ];
    this.reset();
  }

  reset() {
    this.board = new Array(36).fill(0); // 0: empty, 1: Black (P1), 2: White (Bot)
    this.board[2 * 6 + 2] = 2;
    this.board[2 * 6 + 3] = 1;
    this.board[3 * 6 + 2] = 1;
    this.board[3 * 6 + 3] = 2;
    this.isPlayerTurn = true;
    this.gameOver = false;
    this.statusText = this.isTr ? 'Sıra Sende (Siyah Taş)' : 'Your Turn (Black)';
    this.render();
  }

  getFlippable(player, idx) {
    if (this.board[idx] !== 0) return [];
    const r = Math.floor(idx / 6);
    const c = idx % 6;
    const opponent = player === 1 ? 2 : 1;
    const flippable = [];

    for (const [dr, dc] of this.dirs) {
      let cr = r + dr;
      let cc = c + dc;
      const line = [];
      while (cr >= 0 && cr < 6 && cc >= 0 && cc < 6) {
        const cell = cr * 6 + cc;
        if (this.board[cell] === opponent) {
          line.push(cell);
        } else if (this.board[cell] === player) {
          flippable.push(...line);
          break;
        } else {
          break;
        }
        cr += dr;
        cc += dc;
      }
    }
    return flippable;
  }

  handlePlayerMove(idx) {
    if (!this.isPlayerTurn || this.gameOver) return;
    const flips = this.getFlippable(1, idx);
    if (flips.length === 0) return;

    this.board[idx] = 1;
    flips.forEach(f => { this.board[f] = 1; });
    audio.playTick();

    this.isPlayerTurn = false;
    this.statusText = this.isTr ? 'Yapay Zeka düşünüyor...' : 'AI thinking...';
    this.render();
    this.checkNextTurn(2);
  }

  aiMove() {
    setTimeout(() => {
      if (this.gameOver) return;
      const validMoves = [];
      const corners = new Set([0, 5, 30, 35]);

      for (let i = 0; i < 36; i++) {
        const flips = this.getFlippable(2, i);
        if (flips.length > 0) {
          let weight = flips.length;
          if (corners.has(i)) weight += 25;
          validMoves.push({ idx: i, flips, weight });
        }
      }

      if (validMoves.length > 0) {
        validMoves.sort((a, b) => b.weight - a.weight);
        const best = validMoves[0];
        this.board[best.idx] = 2;
        best.flips.forEach(f => { this.board[f] = 2; });
        audio.playTick();
      }

      this.isPlayerTurn = true;
      this.statusText = this.isTr ? 'Sıra Sende' : 'Your Turn';
      this.render();
      this.checkNextTurn(1);
    }, 550);
  }

  checkNextTurn(next) {
    const pMoves = [];
    const bMoves = [];
    for (let i = 0; i < 36; i++) {
      if (this.getFlippable(1, i).length > 0) pMoves.push(i);
      if (this.getFlippable(2, i).length > 0) bMoves.push(i);
    }

    if (pMoves.length === 0 && bMoves.length === 0) {
      this.gameOver = true;
      const p = this.board.filter(c => c === 1).length;
      const b = this.board.filter(c => c === 2).length;
      if (p > b) {
        audio.playVictory();
        confetti.trigger(50);
        Storage.recordScore('reversi', p);
        Storage.addXP(150, 'Reversi Zaferi');
        this.statusText = this.isTr ? `🏆 KAZANDIN! (${p} - ${b})` : `🏆 YOU WIN! (${p} - ${b})`;
      } else if (p < b) {
        audio.playGameOver();
        this.statusText = this.isTr ? `💀 BOT KAZANDI (${b} - ${p})` : `💀 BOT WON (${b} - ${p})`;
      } else {
        this.statusText = this.isTr ? `🤝 BERABERE! (${p} - ${b})` : `🤝 DRAW! (${p} - ${b})`;
      }
      this.render();
      return;
    }

    if (next === 2) {
      if (bMoves.length === 0) {
        this.isPlayerTurn = true;
        this.statusText = this.isTr ? 'Bot pas geçti! Sıra sende.' : 'Bot passed! Your turn.';
        this.render();
      } else {
        this.aiMove();
      }
    } else {
      if (pMoves.length === 0) {
        this.isPlayerTurn = false;
        this.statusText = this.isTr ? 'Hamlen yok! Pas.' : 'No moves! Pass to AI.';
        this.render();
        this.aiMove();
      }
    }
  }

  render() {
    const p = this.board.filter(c => c === 1).length;
    const b = this.board.filter(c => c === 2).length;

    let cellsHtml = '';
    for (let i = 0; i < 36; i++) {
      const state = this.board[i];
      const canMove = this.isPlayerTurn && !this.gameOver && this.getFlippable(1, i).length > 0;
      let discHtml = '';
      if (state === 1) discHtml = '<div class="reversi-disc black"></div>';
      else if (state === 2) discHtml = '<div class="reversi-disc white"></div>';
      else if (canMove) discHtml = '<div class="reversi-hint"></div>';

      cellsHtml += `<div class="reversi-cell" data-idx="${i}">${discHtml}</div>`;
    }

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; gap:4px; padding:2px;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:11px; font-weight:900; padding:0 10px;">
          <span style="color:#06b6d4;">⚫ P1: ${p}</span>
          <span style="color:#cbd5e1; font-size:9.5px;">${this.statusText}</span>
          <span style="color:#fff;">⚪ AI: ${b}</span>
        </div>
        <div class="reversi-board">${cellsHtml}</div>
        ${this.gameOver ? `
          <button class="play-btn" id="btnReversiReset" style="background:#10b981; color:#000; font-size:10px; padding:3px 12px; margin-top:2px;">
            ${this.isTr ? 'Yeni Maç' : 'New Match'}
          </button>
        ` : ''}
      </div>
    `;

    this.container.querySelectorAll('.reversi-cell').forEach(cell => {
      cell.addEventListener('click', () => {
        const idx = parseInt(cell.dataset.idx, 10);
        this.handlePlayerMove(idx);
      });
    });

    const resetBtn = this.container.querySelector('#btnReversiReset');
    if (resetBtn) resetBtn.addEventListener('click', () => this.reset());
  }

  destroy() {
    this.board = null;
  }
}

// ===================================================
// 54. 5-LETTER WORD MASTER (KELİME USTASI)
// ===================================================
class WordMasterGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.wordsEn = ['WATCH', 'APPLE', 'CROWN', 'PULSE', 'TIMER', 'SMART', 'HEART', 'GAMES', 'PIXEL', 'POWER', 'RETRO', 'SHINE', 'TRACK', 'SPACE', 'FOCUS'];
    this.wordsTr = ['SAATİ', 'ELMAY', 'KORON', 'NABIZ', 'SAYAC', 'AKILL', 'KALBİ', 'OYUNU', 'PİKSL', 'GUCUK', 'RETRO', 'ISIKT', 'KAYIT', 'UZAYI', 'ODAKL'];
    this.reset();
  }

  reset() {
    this.guesses = [];
    this.currentGuess = '';
    this.gameOver = false;
    this.won = false;
    const pool = this.isTr ? this.wordsTr : this.wordsEn;
    this.targetWord = pool[Math.floor(Math.random() * pool.length)];
    this.statusText = this.isTr ? '5 harfli kelimeyi tahmin et' : 'Guess the 5-letter word';
    this.render();
  }

  handleKey(k) {
    if (this.gameOver) return;
    audio.playTick();

    if (k === '⌫') {
      this.currentGuess = this.currentGuess.slice(0, -1);
    } else if (k === '↵') {
      if (this.currentGuess.length === 5) {
        this.guesses.push(this.currentGuess);
        if (this.currentGuess === this.targetWord) {
          this.gameOver = true;
          this.won = true;
          audio.playVictory();
          confetti.trigger(50);
          const score = (7 - this.guesses.length) * 200;
          Storage.recordScore('word5', score);
          Storage.addXP(150, 'Kelime Ustası Çözümü');
          this.statusText = `🏆 ${this.targetWord} (${this.guesses.length}/6)`;
        } else if (this.guesses.length >= 6) {
          this.gameOver = true;
          audio.playGameOver();
          this.statusText = `💀 ${this.targetWord}`;
        } else {
          this.currentGuess = '';
          this.statusText = `${this.isTr ? 'Deneme' : 'Try'} ${this.guesses.length + 1} / 6`;
        }
      } else {
        this.statusText = this.isTr ? '5 harf giriniz!' : 'Must be 5 letters!';
      }
    } else {
      if (this.currentGuess.length < 5) {
        this.currentGuess += k;
      }
    }
    this.render();
  }

  render() {
    // 6 rows of 5 tiles
    let rowsHtml = '';
    for (let r = 0; r < 6; r++) {
      let tilesHtml = '';
      const guess = this.guesses[r];
      const isCurrentRow = r === this.guesses.length;

      for (let c = 0; c < 5; c++) {
        let letter = '';
        let cls = 'word5-tile';
        if (guess) {
          letter = guess[c] || '';
          if (letter === this.targetWord[c]) cls += ' correct';
          else if (this.targetWord.includes(letter)) cls += ' present';
          else cls += ' absent';
        } else if (isCurrentRow) {
          letter = this.currentGuess[c] || '';
        }
        tilesHtml += `<div class="${cls}">${letter}</div>`;
      }
      rowsHtml += `<div class="word5-row">${tilesHtml}</div>`;
    }

    // Keyboard
    const kbRows = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['↵', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫']
    ];

    let kbHtml = '';
    kbRows.forEach(row => {
      let rowBtns = '';
      row.forEach(key => {
        const isWide = key === '↵' || key === '⌫';
        rowBtns += `<button class="word5-key ${isWide ? 'wide' : ''}" data-k="${key}">${key}</button>`;
      });
      kbHtml += `<div class="word5-key-row">${rowBtns}</div>`;
    });

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; gap:2px; padding:2px;">
        <div class="word5-board">${rowsHtml}</div>
        <div style="font-size:9.5px; font-weight:800; color:${this.won ? '#22c55e' : (this.gameOver ? '#ef4444' : '#cbd5e1')}; margin-bottom:2px;">
          ${this.statusText}
        </div>
        ${!this.gameOver ? `
          <div class="word5-keyboard">${kbHtml}</div>
        ` : `
          <button class="play-btn" id="btnWordReset" style="background:#eab308; color:#000; font-size:11px; padding:4px 14px; margin-top:4px;">
            ${this.isTr ? 'Sonraki Kelime' : 'Next Word'}
          </button>
        `}
      </div>
    `;

    this.container.querySelectorAll('.word5-key').forEach(btn => {
      btn.addEventListener('click', () => {
        this.handleKey(btn.dataset.k);
      });
    });

    const resetBtn = this.container.querySelector('#btnWordReset');
    if (resetBtn) resetBtn.addEventListener('click', () => this.reset());
  }

  destroy() {
    this.guesses = null;
  }
}

// ===================================================
// 55. PRECISION DARTS (HASSAS DART)
// ===================================================
class PrecisionDartsGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.reset();
  }

  reset() {
    this.aimAngle = 0; // -180..180
    this.power = 50;
    this.powerIncreasing = true;
    this.dartsLeft = 3;
    this.roundScore = 0;
    this.gameOver = false;
    this.thrownHits = [];
    this.statusText = this.isTr ? 'Crown ile nişan al & Fırlat!' : 'Aim with Crown & Throw!';
    
    if (this.timer) clearInterval(this.timer);
    this.timer = setInterval(() => {
      if (this.gameOver) return;
      if (this.powerIncreasing) {
        this.power += 4;
        if (this.power >= 98) this.powerIncreasing = false;
      } else {
        this.power -= 4;
        if (this.power <= 12) this.powerIncreasing = true;
      }
      const bar = this.container.querySelector('#dartPowerFill');
      if (bar) bar.style.width = `${this.power}%`;
    }, 35);

    this.render();
  }

  onCrown(delta) {
    this.aimAngle += delta * 6;
    if (this.aimAngle > 180) this.aimAngle -= 360;
    if (this.aimAngle < -180) this.aimAngle += 360;
    const pointer = this.container.querySelector('#dartAimLine');
    if (pointer) {
      const rad = this.aimAngle * Math.PI / 180.0;
      pointer.setAttribute('x2', 45 + Math.cos(rad) * 44);
      pointer.setAttribute('y2', 45 + Math.sin(rad) * 44);
    }
  }

  throwDart() {
    if (this.dartsLeft <= 0 || this.gameOver) return;
    this.dartsLeft--;
    audio.playLaser();

    const rad = this.aimAngle * Math.PI / 180.0;
    const dist = 45.0 * (this.power / 100.0);
    const hitX = 45.0 + Math.cos(rad) * dist + (Math.random() * 6 - 3);
    const hitY = 45.0 + Math.sin(rad) * dist + (Math.random() * 6 - 3);
    this.thrownHits.push({ x: hitX, y: hitY });

    const dx = hitX - 45.0;
    const dy = hitY - 45.0;
    const r = Math.sqrt(dx * dx + dy * dy);

    let pts = 0;
    if (r <= 5.0) {
      pts = 50;
      this.statusText = '🎯 BULLSEYE! (+50)';
      audio.playVictory();
    } else if (r <= 11.0) {
      pts = 25;
      this.statusText = 'Outer Bull (+25)';
      audio.playScore();
    } else if (r >= 23.0 && r <= 27.0) {
      pts = 60;
      this.statusText = '🔥 TRIPLE RING! (+60)';
      audio.playScore();
    } else if (r >= 38.0 && r <= 42.0) {
      pts = 40;
      this.statusText = 'Double Ring (+40)';
      audio.playScore();
    } else if (r < 45.0) {
      pts = 20;
      this.statusText = 'Single Hit (+20)';
      audio.playTick();
    } else {
      pts = 0;
      this.statusText = 'Missed board! (0)';
      audio.playGameOver();
    }

    this.roundScore += pts;

    if (this.dartsLeft <= 0) {
      this.gameOver = true;
      clearInterval(this.timer);
      Storage.recordScore('darts', this.roundScore);
      Storage.addXP(this.roundScore, 'Dart Turu');
      confetti.trigger(30);
      this.statusText = `🏁 ${this.isTr ? 'Toplam' : 'Total'}: ${this.roundScore} pts!`;
    }
    this.render();
  }

  render() {
    const rad = this.aimAngle * Math.PI / 180.0;
    const ax2 = 45 + Math.cos(rad) * 44;
    const ay2 = 45 + Math.sin(rad) * 44;

    let hitsSvg = '';
    this.thrownHits.forEach(h => {
      hitsSvg += `<circle cx="${h.x}" cy="${h.y}" r="2.5" fill="#facc15" stroke="#000" stroke-width="0.5"/>`;
    });

    let dartIcons = '';
    for (let i = 0; i < this.dartsLeft; i++) dartIcons += '🎯 ';

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; gap:4px; padding:2px;">
        <div style="display:flex; justify-content:space-between; width:100%; font-size:10px; font-weight:800; padding:0 8px;">
          <span style="color:#ef4444;">${dartIcons}</span>
          <span style="color:#facc15;">Score: ${this.roundScore}</span>
        </div>

        <svg class="darts-board-svg" width="90" height="90" viewBox="0 0 90 90">
          <circle cx="45" cy="45" r="45" fill="#000" stroke="#475569" stroke-width="1.5"/>
          <circle cx="45" cy="45" r="41" fill="none" stroke="#22c55e" stroke-width="4"/>
          <circle cx="45" cy="45" r="37" fill="#1e293b"/>
          <circle cx="45" cy="45" r="25" fill="none" stroke="#ef4444" stroke-width="4"/>
          <circle cx="45" cy="45" r="21" fill="#0f172a"/>
          <circle cx="45" cy="45" r="11" fill="#22c55e"/>
          <circle cx="45" cy="45" r="5" fill="#ef4444"/>
          <line id="dartAimLine" x1="45" y1="45" x2="${ax2}" y2="${ay2}" stroke="#06b6d4" stroke-width="1.5" stroke-dasharray="3,2"/>
          ${hitsSvg}
        </svg>

        <div class="darts-power-bar">
          <div class="darts-power-fill" id="dartPowerFill" style="width:${this.power}%;"></div>
        </div>

        <div style="font-size:9.5px; font-weight:800; color:#38bdf8; margin-top:2px;">${this.statusText}</div>

        ${!this.gameOver ? `
          <button class="play-btn" id="btnThrowDart" style="background:#ef4444; color:#fff; font-size:11px; font-weight:900; padding:4px 20px; border-radius:12px;">
            ${this.isTr ? 'FIRLAT' : 'THROW'}
          </button>
        ` : `
          <button class="play-btn" id="btnDartsReset" style="background:#22c55e; color:#000; font-size:11px; padding:4px 16px;">
            ${this.isTr ? 'Tekrar Oyna' : 'Play Again'}
          </button>
        `}
      </div>
    `;

    const throwBtn = this.container.querySelector('#btnThrowDart');
    if (throwBtn) throwBtn.addEventListener('click', () => this.throwDart());

    const resetBtn = this.container.querySelector('#btnDartsReset');
    if (resetBtn) resetBtn.addEventListener('click', () => this.reset());
  }

  destroy() {
    if (this.timer) clearInterval(this.timer);
    this.thrownHits = null;
  }
}

// ===================================================
// 60 GAMES: 1. MICRO CIRCUIT (CROWN & MOTION TILT RACER)
// ===================================================
class MicroCircuitGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.carX = 95;
    this.carY = 135;
    this.carAngle = 0;
    this.speed = 0;
    this.isGas = false;
    this.currentLap = 1;
    this.lapTime = 0;
    this.bestLap = Storage.getScore('microcircuit') ? Storage.getScore('microcircuit') / 100 : 0;
    this.checkpoints = new Set();
    this.isGameOver = false;
    this.useTilt = true;
    this.virtualTilt = 0; // -1 to 1

    this.render();
    this.bindEvents();
    this.startLoop();
  }

  render() {
    this.container.innerHTML = `
      <div class="circuit-container">
        <div style="display:flex; justify-content:space-between; width:100%; padding:2px 8px; font-family:'JetBrains Mono',monospace; font-size:10px;">
          <span style="color:#f97316; font-weight:800;">LAP <span id="lblLap">${this.currentLap}</span>/3</span>
          <span style="color:#fff;" id="lblLapTime">0.00s</span>
          <span style="color:#22c55e;">BEST: <span id="lblBest">${this.bestLap > 0 ? this.bestLap.toFixed(2) + 's' : '--.--'}</span></span>
        </div>
        <canvas id="circuitCanvas" width="190" height="135" class="circuit-canvas"></canvas>
        <div class="circuit-controls">
          <div class="tilt-indicator-pill" id="btnToggleTilt" title="Toggle Gyro Tilt / Crown">
            ${this.useTilt ? '🌀' : '👑'}
          </div>
          <button class="circuit-gas-btn" id="btnGas">
            ${this.isTr ? 'GAZ' : 'GAS'}
          </button>
        </div>
      </div>
    `;
    this.canvas = this.container.querySelector('#circuitCanvas');
    this.ctx = this.canvas ? this.canvas.getContext('2d') : null;
  }

  bindEvents() {
    const gasBtn = this.container.querySelector('#btnGas');
    if (gasBtn) {
      const startGas = (e) => { e.preventDefault(); this.isGas = true; audio.playTick(440); };
      const stopGas = (e) => { e.preventDefault(); this.isGas = false; };
      gasBtn.addEventListener('mousedown', startGas);
      gasBtn.addEventListener('mouseup', stopGas);
      gasBtn.addEventListener('mouseleave', stopGas);
      gasBtn.addEventListener('touchstart', startGas, { passive: false });
      gasBtn.addEventListener('touchend', stopGas);
    }

    const tiltBtn = this.container.querySelector('#btnToggleTilt');
    if (tiltBtn) {
      tiltBtn.addEventListener('click', () => {
        this.useTilt = !this.useTilt;
        tiltBtn.textContent = this.useTilt ? '🌀' : '👑';
        audio.playTick(600);
      });
    }

    // Virtual Tilt via Mouse/Touch dragging over canvas
    if (this.canvas) {
      let isDragging = false;
      const onMove = (e) => {
        if (!this.useTilt) return;
        const rect = this.canvas.getBoundingClientRect();
        const clientX = e.touches ? e.touches[0].clientX : e.clientX;
        const norm = (clientX - (rect.left + rect.width / 2)) / (rect.width / 2);
        this.virtualTilt = Math.max(-1, Math.min(1, norm));
      };
      this.canvas.addEventListener('mousemove', onMove);
      this.canvas.addEventListener('touchmove', onMove, { passive: true });
    }

    // Device orientation support for mobile
    this.onDeviceTilt = (e) => {
      if (this.useTilt && e.gamma !== null) {
        this.virtualTilt = Math.max(-1, Math.min(1, e.gamma / 30));
      }
    };
    window.addEventListener('deviceorientation', this.onDeviceTilt);
  }

  onCrown(delta) {
    this.carAngle += delta * 0.12;
    audio.playTick(500);
  }

  startLoop() {
    this.timer = setInterval(() => this.tick(), 30);
  }

  tick() {
    if (this.isGameOver) return;

    // Steering from virtual tilt
    if (this.useTilt && Math.abs(this.virtualTilt) > 0.05) {
      this.carAngle += this.virtualTilt * 0.08;
    }

    // Gas & Friction
    if (this.isGas) {
      this.speed = Math.min(3.6, this.speed + 0.14);
    } else {
      this.speed = Math.max(0, this.speed - 0.05);
    }

    this.carX += Math.cos(this.carAngle) * this.speed;
    this.carY += Math.sin(this.carAngle) * this.speed;

    const cx = 95, cy = 68;
    const ox = 78, oy = 52;
    const ix = 38, iy = 24;

    const dx = this.carX - cx;
    const dy = this.carY - cy;
    const outDist = (dx * dx) / (ox * ox) + (dy * dy) / (oy * oy);
    const inDist = (dx * dx) / (ix * ix) + (dy * dy) / (iy * iy);

    // Off track grass friction
    if (outDist > 1.05 || inDist < 0.95) {
      this.speed = Math.max(0.6, this.speed * 0.75);
    }

    if (this.speed > 0.1) {
      this.lapTime += 0.03;
      const timeLbl = this.container.querySelector('#lblLapTime');
      if (timeLbl) timeLbl.textContent = this.lapTime.toFixed(2) + 's';
    }

    // Checkpoints around oval
    if (this.carX > cx + 25 && this.carY < cy) this.checkpoints.add(1);
    if (this.carX < cx - 25 && this.carY < cy) this.checkpoints.add(2);
    if (this.carX < cx - 25 && this.carY > cy) this.checkpoints.add(3);

    // Lap finish line detection
    if (this.checkpoints.size >= 3 && Math.abs(this.carX - cx) < 14 && this.carY > cy + 15) {
      this.checkpoints.clear();
      audio.playScore();

      if (this.bestLap === 0 || this.lapTime < this.bestLap) {
        this.bestLap = this.lapTime;
        Storage.setScore('microcircuit', Math.round(this.bestLap * 100));
        const bestLbl = this.container.querySelector('#lblBest');
        if (bestLbl) bestLbl.textContent = this.bestLap.toFixed(2) + 's';
      }

      if (this.currentLap >= 3) {
        this.isGameOver = true;
        audio.playVictory();
        Storage.addXP(150);
        confetti.trigger(40);
        this.container.querySelector('#lblLap').textContent = 'DONE';
      } else {
        this.currentLap += 1;
        this.lapTime = 0;
        this.container.querySelector('#lblLap').textContent = this.currentLap;
      }
    }

    this.draw();
  }

  draw() {
    if (!this.ctx) return;
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 190, 135);

    const cx = 95, cy = 68;
    const ox = 78, oy = 52;
    const ix = 38, iy = 24;

    // Outer Track
    ctx.beginPath();
    ctx.ellipse(cx, cy, ox, oy, 0, 0, Math.PI * 2);
    ctx.fillStyle = '#1e293b';
    ctx.fill();
    ctx.lineWidth = 3;
    ctx.strokeStyle = '#f97316';
    ctx.stroke();

    // Infield Grass
    ctx.beginPath();
    ctx.ellipse(cx, cy, ix, iy, 0, 0, Math.PI * 2);
    ctx.fillStyle = '#064e3b';
    ctx.fill();
    ctx.lineWidth = 2;
    ctx.strokeStyle = '#475569';
    ctx.stroke();

    // Finish line
    ctx.beginPath();
    ctx.moveTo(cx, cy + iy);
    ctx.lineTo(cx, cy + oy);
    ctx.strokeStyle = '#facc15';
    ctx.setLineDash([3, 3]);
    ctx.lineWidth = 3;
    ctx.stroke();
    ctx.setLineDash([]);

    // Draw Car
    ctx.save();
    ctx.translate(this.carX, this.carY);
    ctx.rotate(this.carAngle);
    ctx.fillStyle = '#f97316';
    ctx.shadowColor = '#f97316';
    ctx.shadowBlur = 6;
    ctx.fillRect(-7, -4, 14, 8);
    ctx.fillStyle = '#38bdf8';
    ctx.shadowBlur = 0;
    ctx.fillRect(1, -3, 3, 6);
    ctx.restore();
  }

  destroy() {
    if (this.timer) clearInterval(this.timer);
    window.removeEventListener('deviceorientation', this.onDeviceTilt);
  }
}

// ===================================================
// 60 GAMES: 2. BOMB DEFUSAL (LOGIC WIRE CUTTER)
// ===================================================
class BombDefusalGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.score = 0;
    this.startNewBomb();
  }

  startNewBomb() {
    if (this.timer) clearInterval(this.timer);
    this.timeLeft = 45.0;
    this.isGameOver = false;

    const letters = ['WX', 'RK', 'TR', 'BL', 'CZ', 'NP'];
    const prefix = letters[Math.floor(Math.random() * letters.length)];
    const digits = Math.floor(1000 + Math.random() * 9000);
    this.serial = `${prefix}-${digits}`;

    const colors = [
      { name: 'Red', hex: '#ef4444' },
      { name: 'Blue', hex: '#3b82f6' },
      { name: 'Yellow', hex: '#facc15' },
      { name: 'Green', hex: '#22c55e' }
    ];

    this.wires = [];
    for (let i = 0; i < 4; i++) {
      const c = colors[Math.floor(Math.random() * colors.length)];
      this.wires.push({ id: i, name: c.name, hex: c.hex, isCut: false });
    }

    const lastDigit = digits % 10;
    const hasRed = this.wires.some(w => w.name === 'Red');
    const blueCount = this.wires.filter(w => w.name === 'Blue').count || 0;

    if (lastDigit % 2 !== 0 && hasRed) {
      this.ruleHint = this.isTr ? 'Seri tek & Kırmızı var -> 2. Kabloyu kes' : 'Serial odd & has RED -> Cut Wire 2';
      this.correctIndex = 1;
    } else if (blueCount > 1) {
      this.ruleHint = this.isTr ? 'Birden fazla Mavi var -> Son kabloyu kes' : 'Multiple BLUE wires -> Cut Wire 4';
      this.correctIndex = 3;
    } else if (this.wires[0].name === 'Green') {
      this.ruleHint = this.isTr ? 'Yeşil ile başlıyor -> 1. Kabloyu kes' : 'Starts with GREEN -> Cut Wire 1';
      this.correctIndex = 0;
    } else {
      this.ruleHint = this.isTr ? 'Standart protokol -> 3. Kabloyu kes' : 'Standard protocol -> Cut Wire 3';
      this.correctIndex = 2;
    }

    this.render();
    this.startTimer();
  }

  render() {
    this.container.innerHTML = `
      <div class="bomb-container">
        <div class="bomb-header-row">
          <div style="font-family:'JetBrains Mono',monospace; font-size:10px;">
            <span style="color:#64748b;">SERIAL</span><br>
            <strong style="color:#facc15;">${this.serial}</strong>
          </div>
          <div class="bomb-timer-led" id="bombTimer">${this.timeLeft.toFixed(1)}</div>
        </div>

        <div style="font-size:9px; text-align:center; padding:3px; background:rgba(255,255,255,0.08); border-radius:5px; color:#cbd5e1;">
          ${this.ruleHint}
        </div>

        <div class="bomb-wire-box">
          ${this.wires.map((w, i) => `
            <div class="bomb-wire-line ${w.isCut ? 'cut' : ''}" data-wire-id="${i}">
              <span style="width:7px; height:7px; border-radius:50%; background:#64748b;"></span>
              <div style="flex:1; height:6px; margin:0 8px; background:${w.hex}; border-radius:3px; box-shadow:0 0 6px ${w.hex};"></div>
              <span style="width:7px; height:7px; border-radius:50%; background:#64748b;"></span>
            </div>
          `).join('')}
        </div>
      </div>
    `;

    this.container.querySelectorAll('.bomb-wire-line').forEach(el => {
      el.addEventListener('click', () => {
        const id = Number(el.getAttribute('data-wire-id'));
        this.cutWire(id);
      });
    });
  }

  startTimer() {
    this.timer = setInterval(() => {
      if (this.timeLeft > 0.1) {
        this.timeLeft -= 0.1;
        const led = this.container.querySelector('#bombTimer');
        if (led) {
          led.textContent = this.timeLeft.toFixed(1);
          if (this.timeLeft <= 10) led.classList.add('critical');
        }
        if (Math.round(this.timeLeft * 10) % 10 === 0 && this.timeLeft <= 5) {
          audio.playTick(800);
        }
      } else {
        this.detonate();
      }
    }, 100);
  }

  cutWire(id) {
    if (this.isGameOver) return;
    this.wires[id].isCut = true;

    if (id === this.correctIndex) {
      clearInterval(this.timer);
      this.isGameOver = true;
      this.score += 1;
      Storage.setScore('bombdefusal', this.score);
      Storage.addXP(150);
      audio.playVictory();
      confetti.trigger(40);

      this.container.innerHTML = `
        <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; text-align:center; gap:8px;">
          <div style="font-size:24px;">✅</div>
          <h3 style="color:#22c55e; font-size:14px; margin:0;">${this.isTr ? 'BOMBA İMHA EDİLDİ!' : 'BOMB DEFUSED!'}</h3>
          <p style="font-size:11px; color:#facc15; margin:0;">+150 XP • Level: ${this.score}</p>
          <button class="play-btn" id="btnNextBomb" style="background:#22c55e; color:#000; font-size:11px; padding:4px 14px;">
            ${this.isTr ? 'Sonraki Bomba' : 'Next Bomb'}
          </button>
        </div>
      `;
      this.container.querySelector('#btnNextBomb').addEventListener('click', () => this.startNewBomb());
    } else {
      this.detonate();
    }
  }

  detonate() {
    clearInterval(this.timer);
    this.isGameOver = true;
    audio.playGameOver();

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; text-align:center; gap:8px;">
        <div style="font-size:28px;">💥</div>
        <h3 style="color:#ef4444; font-size:15px; margin:0;">${this.isTr ? 'PATLADI!' : 'DETONATED!'}</h3>
        <p style="font-size:10px; color:#cbd5e1; margin:0;">${this.isTr ? 'Yanlış kablo kesildi!' : 'Wrong wire cut!'}</p>
        <button class="play-btn" id="btnRetryBomb" style="background:#ef4444; color:#fff; font-size:11px; padding:4px 14px;">
          ${this.isTr ? 'Tekrar Dene' : 'Try Again'}
        </button>
      </div>
    `;
    this.container.querySelector('#btnRetryBomb').addEventListener('click', () => this.startNewBomb());
  }

  destroy() {
    if (this.timer) clearInterval(this.timer);
  }
}

// ===================================================
// 60 GAMES: 3. 24 SOLVER (4-NUMBER TARGET MATH)
// ===================================================
class Target24Game {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.score = 0;
    this.presets = [
      [3, 8, 4, 6], [1, 3, 4, 6], [2, 3, 4, 5],
      [2, 2, 7, 7], [1, 5, 5, 5], [4, 4, 4, 6],
      [2, 4, 6, 8], [3, 3, 8, 8]
    ];
    this.nextPuzzle();
  }

  nextPuzzle() {
    this.expression = [];
    this.numbers = [...this.presets[Math.floor(Math.random() * this.presets.length)]].sort(() => Math.random() - 0.5);
    this.used = [false, false, false, false];
    this.isSolved = false;
    this.render();
  }

  render() {
    this.container.innerHTML = `
      <div class="target24-container">
        <div style="display:flex; justify-content:space-between; font-family:'JetBrains Mono',monospace; font-size:11px;">
          <strong style="color:#facc15;">GOAL: 24</strong>
          <span style="color:#38bdf8;">SOLVED: ${this.score}</span>
        </div>

        <div class="target24-expr-bar" id="exprBar">
          ${this.expression.length > 0 ? this.expression.join(' ') : (this.isTr ? 'Rakam & işlem seç' : 'Tap numbers & ops')}
        </div>

        <div class="target24-tiles-row">
          ${this.numbers.map((n, i) => `
            <button class="target24-tile ${this.used[i] ? 'used' : ''}" data-idx="${i}" ${this.used[i] ? 'disabled' : ''}>${n}</button>
          `).join('')}
        </div>

        <div class="target24-tiles-row">
          ${['+', '-', '×', '÷'].map(op => `
            <button class="target24-op-btn" data-op="${op}">${op}</button>
          `).join('')}
        </div>

        <div style="display:flex; gap:6px; margin-top:2px;">
          <button class="play-btn" id="btnClear24" style="background:#ef4444; width:34px; padding:0;">✕</button>
          <button class="play-btn" id="btnCheck24" style="flex:1; background:#22c55e; color:#000; font-size:11px; font-weight:800;">
            ${this.isTr ? 'KONTROL ET = 24' : 'CHECK = 24'}
          </button>
        </div>
      </div>
    `;

    this.container.querySelectorAll('.target24-tile').forEach(el => {
      el.addEventListener('click', () => {
        const idx = Number(el.getAttribute('data-idx'));
        if (!this.used[idx]) {
          this.used[idx] = true;
          this.expression.push(this.numbers[idx]);
          audio.playTick(500);
          this.render();
        }
      });
    });

    this.container.querySelectorAll('.target24-op-btn').forEach(el => {
      el.addEventListener('click', () => {
        const op = el.getAttribute('data-op');
        if (this.expression.length > 0) {
          const last = this.expression[this.expression.length - 1];
          if (!['+', '-', '×', '÷'].includes(last)) {
            this.expression.push(op);
            audio.playTick(600);
            this.render();
          }
        }
      });
    });

    const clearBtn = this.container.querySelector('#btnClear24');
    if (clearBtn) {
      clearBtn.addEventListener('click', () => {
        this.expression = [];
        this.used = [false, false, false, false];
        audio.playTick(400);
        this.render();
      });
    }

    const checkBtn = this.container.querySelector('#btnCheck24');
    if (checkBtn) {
      checkBtn.addEventListener('click', () => this.evaluate());
    }
  }

  evaluate() {
    if (this.expression.length < 3) return;

    let val = 0;
    let op = '+';

    for (const token of this.expression) {
      if (['+', '-', '×', '÷'].includes(token)) {
        op = token;
      } else {
        const n = Number(token);
        if (op === '+') val += n;
        else if (op === '-') val -= n;
        else if (op === '×') val *= n;
        else if (op === '÷' && n !== 0) val /= n;
      }
    }

    if (Math.abs(val - 24) < 0.001 && this.used.every(Boolean)) {
      this.score += 1;
      Storage.setScore('target24', this.score);
      Storage.addXP(150);
      audio.playVictory();
      confetti.trigger(40);

      this.container.innerHTML = `
        <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; text-align:center; gap:8px;">
          <div style="font-size:24px;">🎉</div>
          <h3 style="color:#facc15; font-size:14px; margin:0;">${this.isTr ? '24 BULDUN!' : '24 SOLVED!'}</h3>
          <p style="font-size:11px; color:#22c55e; margin:0;">+150 XP • Total: ${this.score}</p>
          <button class="play-btn" id="btnNext24" style="background:#facc15; color:#000; font-size:11px; padding:4px 14px;">
            ${this.isTr ? 'Sonraki Soru' : 'Next Puzzle'}
          </button>
        </div>
      `;
      this.container.querySelector('#btnNext24').addEventListener('click', () => this.nextPuzzle());
    } else {
      audio.playGameOver();
      const exprBar = this.container.querySelector('#exprBar');
      if (exprBar) {
        exprBar.style.color = '#ef4444';
        setTimeout(() => { if (exprBar) exprBar.style.color = '#facc15'; }, 600);
      }
    }
  }

  destroy() {}
}

// ===================================================
// 60 GAMES: 4. AIR TENNIS (TABLE TENNIS)
// ===================================================
class TableTennisGame {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.playerPaddleX = 95;
    this.botPaddleX = 95;
    this.ballX = 95;
    this.ballY = 85;
    this.ballVX = 1.6;
    this.ballVY = 2.4;
    this.playerScore = 0;
    this.botScore = 0;
    this.isGameOver = false;

    this.render();
    this.startLoop();
  }

  render() {
    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; width:100%; height:100%;">
        <div style="display:flex; justify-content:space-between; width:100%; padding:2px 8px; font-family:'JetBrains Mono',monospace; font-size:10px;">
          <span style="color:#38bdf8; font-weight:800;">YOU <span id="lblPScore">${this.playerScore}</span></span>
          <span style="color:#ef4444; font-weight:800;">BOT <span id="lblBScore">${this.botScore}</span></span>
        </div>
        <canvas id="tennisCanvas" width="190" height="170" class="tennis-court-canvas"></canvas>
      </div>
    `;
    this.canvas = this.container.querySelector('#tennisCanvas');
    this.ctx = this.canvas ? this.canvas.getContext('2d') : null;

    if (this.canvas) {
      this.canvas.addEventListener('mousemove', (e) => {
        const rect = this.canvas.getBoundingClientRect();
        this.playerPaddleX = Math.max(22, Math.min(168, e.clientX - rect.left));
      });
      this.canvas.addEventListener('touchmove', (e) => {
        const rect = this.canvas.getBoundingClientRect();
        this.playerPaddleX = Math.max(22, Math.min(168, e.touches[0].clientX - rect.left));
      }, { passive: true });
    }
  }

  onCrown(delta) {
    this.playerPaddleX = Math.max(22, Math.min(168, this.playerPaddleX + delta * 2.2));
    audio.playTick(500);
  }

  startLoop() {
    this.timer = setInterval(() => this.tick(), 25);
  }

  tick() {
    if (this.isGameOver) return;

    this.ballX += this.ballVX;
    this.ballY += this.ballVY;

    // Left/Right Walls
    if (this.ballX < 8 || this.ballX > 182) {
      this.ballVX = -this.ballVX;
      audio.playTick(400);
    }

    // Bot AI tracking
    const botSpeed = 2.2;
    if (this.botPaddleX < this.ballX - 4) this.botPaddleX = Math.min(168, this.botPaddleX + botSpeed);
    else if (this.botPaddleX > this.ballX + 4) this.botPaddleX = Math.max(22, this.botPaddleX - botSpeed);

    // Bot Paddle Hit
    if (this.ballY <= 24 && this.ballY >= 16) {
      if (Math.abs(this.ballX - this.botPaddleX) <= 22) {
        this.ballVY = Math.abs(this.ballVY) * 1.03;
        const offset = (this.ballX - this.botPaddleX) / 18;
        this.ballVX = offset * 2.8;
        audio.playTick(550);
      }
    }

    // Player Paddle Hit
    if (this.ballY >= 148 && this.ballY <= 156) {
      if (Math.abs(this.ballX - this.playerPaddleX) <= 22) {
        this.ballVY = -Math.abs(this.ballVY) * 1.03;
        const offset = (this.ballX - this.playerPaddleX) / 18;
        this.ballVX = offset * 3.2;
        audio.playScore();
      }
    }

    // Points
    if (this.ballY < 4) {
      this.playerScore += 1;
      audio.playScore();
      this.container.querySelector('#lblPScore').textContent = this.playerScore;
      this.checkEnd();
      this.serve(false);
    } else if (this.ballY > 166) {
      this.botScore += 1;
      audio.playGameOver();
      this.container.querySelector('#lblBScore').textContent = this.botScore;
      this.checkEnd();
      this.serve(true);
    }

    this.draw();
  }

  serve(toPlayer) {
    this.ballX = 95;
    this.ballY = 85;
    this.ballVX = (Math.random() - 0.5) * 3;
    this.ballVY = toPlayer ? 2.4 : -2.4;
  }

  checkEnd() {
    if (this.playerScore >= 5 || this.botScore >= 5) {
      this.isGameOver = true;
      const isWin = this.playerScore >= 5;
      if (isWin) {
        audio.playVictory();
        Storage.setScore('tabletennis', this.playerScore);
        Storage.addXP(150);
        confetti.trigger(40);
      }
      this.container.innerHTML = `
        <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; text-align:center; gap:8px;">
          <div style="font-size:24px;">${isWin ? '🏆' : '💀'}</div>
          <h3 style="color:${isWin ? '#facc15' : '#ef4444'}; font-size:15px; margin:0;">${isWin ? (this.isTr ? 'KAZANDIN!' : 'VICTORY!') : (this.isTr ? 'KAYBETTİN' : 'DEFEATED')}</h3>
          <p style="font-size:12px; color:#fff; font-family:'JetBrains Mono'; margin:0;">${this.playerScore} - ${this.botScore}</p>
          <button class="play-btn" id="btnRestartTennis" style="background:#38bdf8; color:#000; font-size:11px; padding:4px 14px;">
            ${this.isTr ? 'Tekrar Oyna' : 'Play Again'}
          </button>
        </div>
      `;
      this.container.querySelector('#btnRestartTennis').addEventListener('click', () => {
        this.playerScore = 0;
        this.botScore = 0;
        this.isGameOver = false;
        this.render();
        this.serve(true);
      });
    }
  }

  draw() {
    if (!this.ctx) return;
    const ctx = this.ctx;
    ctx.clearRect(0, 0, 190, 170);

    // Court Net
    ctx.beginPath();
    ctx.moveTo(8, 85);
    ctx.lineTo(182, 85);
    ctx.strokeStyle = 'rgba(255,255,255,0.7)';
    ctx.setLineDash([4, 4]);
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.setLineDash([]);

    // Bot Paddle
    ctx.fillStyle = '#ef4444';
    ctx.fillRect(this.botPaddleX - 18, 18, 36, 6);

    // Player Paddle
    ctx.fillStyle = '#38bdf8';
    ctx.shadowColor = '#38bdf8';
    ctx.shadowBlur = 6;
    ctx.fillRect(this.playerPaddleX - 18, 150, 36, 6);
    ctx.shadowBlur = 0;

    // Tennis Ball
    ctx.beginPath();
    ctx.arc(this.ballX, this.ballY, 4, 0, Math.PI * 2);
    ctx.fillStyle = '#facc15';
    ctx.fill();
  }

  destroy() {
    if (this.timer) clearInterval(this.timer);
  }
}

// ===================================================
// 60 GAMES: 5. 21 DUEL (2-PLAYER PASS & PLAY BLACKJACK)
// ===================================================
class Duel21Game {
  constructor(container, app) {
    this.container = container;
    this.app = app;
    this.isTr = app.lang === 'tr';
    this.startMatch();
  }

  startMatch() {
    const ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
    const suits = [{ s: '♠', r: false }, { s: '♣', r: false }, { s: '♥', r: true }, { s: '♦', r: true }];
    this.deck = [];
    for (const r of ranks) {
      for (const s of suits) {
        let val = parseInt(r);
        if (['J', 'Q', 'K'].includes(r)) val = 10;
        if (r === 'A') val = 11;
        this.deck.push({ rank: r, suit: s.s, isRed: s.r, val });
      }
    }
    this.deck.sort(() => Math.random() - 0.5);

    this.p1Cards = [this.deck.pop(), this.deck.pop()];
    this.p2Cards = [this.deck.pop(), this.deck.pop()];
    this.currentTurn = 1; // 1: P1, 2: Pass modal, 3: P2, 4: Showdown
    this.render();
  }

  calcScore(cards) {
    let sum = cards.reduce((acc, c) => acc + c.val, 0);
    let aces = cards.filter(c => c.rank === 'A').length;
    while (sum > 21 && aces > 0) {
      sum -= 10;
      aces -= 1;
    }
    return sum;
  }

  render() {
    if (this.currentTurn === 1) {
      this.renderPlayer(1, this.p1Cards);
    } else if (this.currentTurn === 2) {
      this.renderPass();
    } else if (this.currentTurn === 3) {
      this.renderPlayer(2, this.p2Cards);
    } else {
      this.renderShowdown();
    }
  }

  renderPlayer(num, cards) {
    const score = this.calcScore(cards);
    this.container.innerHTML = `
      <div class="duel21-container">
        <div style="display:flex; justify-content:space-between; font-family:'JetBrains Mono',monospace; font-size:11px;">
          <strong style="color:${num === 1 ? '#38bdf8' : '#f97316'};">${this.isTr ? `${num}. OYUNCU` : `PLAYER ${num}`}</strong>
          <span style="color:${score > 21 ? '#ef4444' : '#fff'};">TOTAL: ${score}</span>
        </div>

        <div style="display:flex; gap:6px; overflow-x:auto; padding:10px 0; justify-content:center;">
          ${cards.map(c => `
            <div style="width:30px; height:44px; background:#fff; border-radius:5px; display:flex; flex-direction:column; align-items:center; justify-content:center; color:${c.isRed ? '#dc2626' : '#000'}; font-weight:900;">
              <span style="font-size:12px; line-height:1;">${c.rank}</span>
              <span style="font-size:10px;">${c.suit}</span>
            </div>
          `).join('')}
        </div>

        ${score > 21 ? `
          <div style="color:#ef4444; font-weight:800; text-align:center; font-size:11px;">BUST! (> 21)</div>
          <button class="play-btn" id="btnStand" style="background:#facc15; color:#000; font-size:11px; margin-top:6px;">
            ${this.isTr ? 'Devam Et' : 'Continue'}
          </button>
        ` : `
          <div style="display:flex; gap:8px;">
            <button class="play-btn" id="btnHit" style="flex:1; background:#22c55e; color:#000; font-size:11px; font-weight:800;">HIT</button>
            <button class="play-btn" id="btnStand" style="flex:1; background:#ef4444; color:#fff; font-size:11px; font-weight:800;">STAND</button>
          </div>
        `}
      </div>
    `;

    const hitBtn = this.container.querySelector('#btnHit');
    if (hitBtn) {
      hitBtn.addEventListener('click', () => {
        cards.push(this.deck.pop());
        audio.playTick(600);
        this.render();
      });
    }

    const standBtn = this.container.querySelector('#btnStand');
    if (standBtn) {
      standBtn.addEventListener('click', () => {
        audio.playTick(500);
        if (this.currentTurn === 1) {
          this.currentTurn = 2;
        } else if (this.currentTurn === 3) {
          this.currentTurn = 4;
        }
        this.render();
      });
    }
  }

  renderPass() {
    this.container.innerHTML = `
      <div class="pass-watch-modal">
        <div style="font-size:28px;">⌚🔄</div>
        <h3 style="font-size:13px; color:#facc15; margin:0;">${this.isTr ? 'SAATİ UZAT' : 'PASS WATCH'}</h3>
        <p style="font-size:10px; color:#cbd5e1; margin:0;">${this.isTr ? 'Saati 2. Oyuncuya verin' : 'Hand watch to Player 2'}</p>
        <button class="play-btn" id="btnStartP2" style="background:#f97316; color:#000; font-size:11px; padding:4px 14px;">
          ${this.isTr ? '2. OYUNCU BAŞLA' : 'PLAYER 2 START'}
        </button>
      </div>
    `;
    this.container.querySelector('#btnStartP2').addEventListener('click', () => {
      this.currentTurn = 3;
      audio.playTick(600);
      this.render();
    });
  }

  renderShowdown() {
    const s1 = this.calcScore(this.p1Cards);
    const s2 = this.calcScore(this.p2Cards);
    const v1 = s1 <= 21;
    const v2 = s2 <= 21;

    let msg = '';
    let col = '#facc15';

    if (!v1 && !v2) { msg = this.isTr ? 'ÇİFTE BUST (BERABERE)' : 'DOUBLE BUST (TIE)'; col = '#64748b'; }
    else if (v1 && !v2) { msg = this.isTr ? '👑 1. OYUNCU KAZANDI!' : '👑 PLAYER 1 WINS!'; col = '#38bdf8'; }
    else if (!v1 && v2) { msg = this.isTr ? '👑 2. OYUNCU KAZANDI!' : '👑 PLAYER 2 WINS!'; col = '#f97316'; }
    else if (s1 > s2) { msg = this.isTr ? '👑 1. OYUNCU KAZANDI!' : '👑 PLAYER 1 WINS!'; col = '#38bdf8'; }
    else if (s2 > s1) { msg = this.isTr ? '👑 2. OYUNCU KAZANDI!' : '👑 PLAYER 2 WINS!'; col = '#f97316'; }
    else { msg = this.isTr ? '🤝 BERABERE!' : '🤝 PUSH (TIE)!'; col = '#facc15'; }

    audio.playVictory();
    confetti.trigger(40);
    Storage.addXP(150);
    Storage.setScore('duel21', Math.max(s1, s2));

    this.container.innerHTML = `
      <div style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100%; text-align:center; gap:8px;">
        <h3 style="color:${col}; font-size:13px; margin:0;">${msg}</h3>
        <div style="display:flex; gap:16px; font-family:'JetBrains Mono'; font-size:12px;">
          <span style="color:#38bdf8;">P1: ${s1}</span>
          <span style="color:#f97316;">P2: ${s2}</span>
        </div>
        <button class="play-btn" id="btnRestartDuel" style="background:#facc15; color:#000; font-size:11px; padding:4px 14px;">
          ${this.isTr ? 'Tekrar Oyna' : 'Play Again'}
        </button>
      </div>
    `;
    this.container.querySelector('#btnRestartDuel').addEventListener('click', () => this.startMatch());
  }

  destroy() {}
}

// Boot application
window.addEventListener('DOMContentLoaded', () => {
  window.wristArcade = new WristArcadeApp();
});



