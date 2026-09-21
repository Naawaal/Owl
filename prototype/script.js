// =========================================================
// OWL GAME COMPANION & LAUNCHER — ENGINE SCRIPT
// =========================================================

// State
let games = [
    { 
        id: 'carrom', 
        title: 'Carrom Pool', 
        icon: '🎯', 
        installed: true, 
        category: 'Board / Precision',
        isCustom: false,
        mods: [
            { id: 'carrom_aim', name: 'Precision Laser Raycast', active: true, desc: 'Calculates 2D specular bounce angles externally' },
            { id: 'carrom_fps', name: '120Hz Fluid Strike', active: true, desc: 'Forces display refresh rate to max panel capability' }
        ]
    },
    { 
        id: 'freefire', 
        title: 'Free Fire MAX', 
        icon: '🔥', 
        installed: true, 
        category: 'Battle Royale',
        isCustom: false,
        mods: [
            { id: 'ff_skins', name: 'Safe Skin Asset Staging', active: true, desc: 'Client-side weapon & bundle mesh swap' },
            { id: 'ff_fps', name: '90FPS GFX Unlocker', active: true, desc: 'Removes local config frame limiter' }
        ]
    },
    { 
        id: 'mlbb', 
        title: 'Mobile Legends', 
        icon: '⚔️', 
        installed: true, 
        category: 'MOBA',
        isCustom: false,
        mods: [
            { id: 'ml_skins', name: 'Hero Skin Mesh Staging', active: true, desc: 'Client-side Unity asset injection' },
            { id: 'ml_timers', name: 'Turtle & Lord Timers HUD', active: true, desc: 'Floating OCR-based objective countdown' }
        ]
    },
    { 
        id: 'pubg', 
        title: 'PUBG Mobile', 
        icon: '🪂', 
        installed: true, 
        category: 'Battle Royale',
        isCustom: false,
        mods: [
            { id: 'pubg_gfx', name: 'Extreme 90FPS Preset', active: true, desc: 'Applies calibrated UserCustom.ini' },
            { id: 'pubg_reticle', name: 'Tactical Reticle HUD', active: false, desc: 'Transparent crosshair screen overlay' }
        ]
    },
    { 
        id: '8ball', 
        title: '8 Ball Pool', 
        icon: '🎱', 
        installed: false, 
        category: 'Sports / Precision',
        isCustom: false,
        mods: [
            { id: '8ball_aim', name: 'Extended Pocket Guideline', active: true, desc: 'Screen analysis pocket predictor' }
        ]
    },
    { 
        id: 'subway', 
        title: 'Subway Surfers', 
        icon: '🏄‍♂️', 
        installed: true, 
        category: 'Arcade Runner',
        isCustom: false,
        mods: [
            { id: 'subway_boost', name: '120Hz Touch Response', active: true, desc: 'Lowers input latency via touch booster' }
        ]
    }
];

// Unadded Device Applications detected on system
const unaddedDeviceApps = [
    { id: 'stumble', title: 'Stumble Guys', icon: '🏃', category: 'Party Royale', pkg: 'com.kitkagames.fallbuddies' },
    { id: 'codm', title: 'Call of Duty: Mobile', icon: '🎖️', category: 'Action FPS', pkg: 'com.activision.callofduty.shooter' },
    { id: 'brawl', title: 'Brawl Stars', icon: '⭐', category: 'MOBA Action', pkg: 'com.supercell.brawlstars' },
    { id: 'roblox', title: 'Roblox', icon: '🧱', category: 'Sandbox', pkg: 'com.roblox.client' },
    { id: 'genshin', title: 'Genshin Impact', icon: '✨', category: 'Open World RPG', pkg: 'com.miHoYo.GenshinImpact' }
];

let currentTab = 'home';
let currentFilter = 'all';
let searchQuery = '';

// Studio Global Settings
let globalSettings = {
    carromGuidelineLength: 2.2,
    bankBouncePredictor: true,
    fps120Lock: true,
    gameDnd: true,
    touchBooster: true
};

// DOM References
const appContent = document.getElementById('app-content');
const navItems = document.querySelectorAll('.nav-item');
const navIndicator = document.getElementById('nav-indicator');
const themeToggle = document.getElementById('theme-toggle');
const htmlEl = document.documentElement;

const detailSheetOverlay = document.getElementById('detail-sheet');
const sheetContent = document.getElementById('sheet-content');

const addGameModal = document.getElementById('add-game-modal');
const openAddGameBtn = document.getElementById('open-add-game-btn');
const closeAddModalBtn = document.getElementById('close-add-modal');
const addGameSearch = document.getElementById('add-game-search');
const deviceAppsList = document.getElementById('device-apps-list');

const gameSimOverlay = document.getElementById('game-sim-overlay');
const simExitBtn = document.getElementById('sim-exit-btn');
const simGameTitle = document.getElementById('sim-game-title');
const simGuidelineCanvas = document.getElementById('sim-guideline-canvas');

// =========================================================
// THEME SWITCHER
// =========================================================
themeToggle.addEventListener('click', () => {
    const current = htmlEl.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    htmlEl.setAttribute('data-theme', next);
});

// =========================================================
// ONBOARDING (Bypassed if completed or tapped)
// =========================================================
const obContainer = document.getElementById('onboarding');
const obNextBtn = document.getElementById('ob-next-btn');
const obTrack = document.getElementById('ob-track');
const obDots = document.querySelectorAll('.dot');
let currentSlide = 0;

if (obNextBtn) {
    obNextBtn.addEventListener('click', () => {
        if (currentSlide < 2) {
            currentSlide++;
            obTrack.style.transform = `translateX(-${currentSlide * 100}%)`;
            obDots.forEach((d, i) => d.classList.toggle('active', i === currentSlide));
            if (currentSlide === 2) obNextBtn.textContent = 'Enter Engine';
        } else {
            obContainer.classList.remove('active');
            setTimeout(() => { obContainer.style.display = 'none'; }, 300);
        }
    });

    obDots.forEach((dot, i) => {
        dot.addEventListener('click', () => {
            currentSlide = i;
            obTrack.style.transform = `translateX(-${currentSlide * 100}%)`;
            obDots.forEach((d, idx) => d.classList.toggle('active', idx === currentSlide));
            if (currentSlide === 2) obNextBtn.textContent = 'Enter Engine';
            else obNextBtn.textContent = 'Continue';
        });
    });
}

// =========================================================
// VIEW GENERATORS
// =========================================================
const views = {
    // -----------------------------------------------------
    // DECK (HOME)
    // -----------------------------------------------------
    home: () => {
        const readyGames = games.filter(g => g.installed);
        return `
            <div class="fade-in">
                <!-- System Status Ticker -->
                <div class="status-strip">
                    <div class="status-strip-left">
                        <i class="fa-solid fa-shield-halved"></i>
                        <div>
                            <h4>Zero-Cheat Native Staging</h4>
                            <p>Bare-metal launch · Memory injection blocked · Ban-safe</p>
                        </div>
                    </div>
                    <span class="telemetry-pill active"><i class="fa-solid fa-circle-check"></i> VERIFIED</span>
                </div>

                <!-- Hero Snap Deck -->
                <div class="deck-section-title">
                    <span>Quick Launch Deck</span>
                    <span class="mono-font" style="font-size:0.68rem; color:var(--text-tertiary)">${readyGames.length} READY</span>
                </div>

                <div class="hero-deck-carousel">
                    ${readyGames.map(g => `
                        <div class="deck-card ${g.id === 'carrom' ? 'highlight' : ''}" onclick="openGameDetail('${g.id}')">
                            <div>
                                <div class="deck-card-top">
                                    <div class="deck-game-icon">${g.icon}</div>
                                    <div class="deck-card-info">
                                        <h3>${g.title}</h3>
                                        <p>${g.category}</p>
                                    </div>
                                </div>
                                <div class="deck-mod-badges">
                                    ${g.mods.map(m => `
                                        <span class="mod-badge ${m.active ? 'active' : ''}">
                                            <i class="fa-solid fa-check"></i> ${m.name.split(' ')[0]}
                                        </span>
                                    `).join('')}
                                </div>
                            </div>
                            <button class="deck-launch-btn" onclick="event.stopPropagation(); launchGameSession('${g.id}')">
                                <i class="fa-solid fa-play"></i> Launch with Mods
                            </button>
                        </div>
                    `).join('')}
                </div>

                <!-- System Telemetry & Quick Profiles -->
                <div class="deck-section-title" style="margin-top: var(--space-lg);">
                    <span>Hardware & Overlay Telemetry</span>
                </div>

                <div class="mod-control-card">
                    <div class="mod-control-row">
                        <div class="mod-info">
                            <h4>Ultra-Refresh Rate Lock (120Hz)</h4>
                            <p>Forces display surface to hardware maximum</p>
                        </div>
                        <label class="switch">
                            <input type="checkbox" ${globalSettings.fps120Lock ? 'checked' : ''} onchange="toggleGlobalSetting('fps120Lock')">
                            <span class="slider"></span>
                        </label>
                    </div>
                </div>

                <div class="mod-control-card">
                    <div class="mod-control-row">
                        <div class="mod-info">
                            <h4>Competitive Focus DND</h4>
                            <p>Suppresses heads-up notifications & calls during match</p>
                        </div>
                        <label class="switch">
                            <input type="checkbox" ${globalSettings.gameDnd ? 'checked' : ''} onchange="toggleGlobalSetting('gameDnd')">
                            <span class="slider"></span>
                        </label>
                    </div>
                </div>
            </div>
        `;
    },

    // -----------------------------------------------------
    // LIBRARY (GAMES & ADD CUSTOM GAME)
    // -----------------------------------------------------
    library: () => {
        let filtered = games;
        if (currentFilter === 'installed') filtered = filtered.filter(g => g.installed);
        if (currentFilter === 'aim') filtered = filtered.filter(g => g.mods.some(m => m.id.includes('aim')));
        if (currentFilter === 'custom') filtered = filtered.filter(g => g.isCustom);

        if (searchQuery.trim() !== '') {
            const q = searchQuery.toLowerCase();
            filtered = filtered.filter(g => g.title.toLowerCase().includes(q) || g.category.toLowerCase().includes(q));
        }

        return `
            <div class="fade-in">
                <!-- Search & Filters -->
                <div class="search-filter-bar">
                    <div class="search-box">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" placeholder="Search games or categories..." value="${searchQuery}" oninput="handleSearch(this.value)">
                    </div>
                    <div class="filter-pills">
                        <button class="filter-pill ${currentFilter === 'all' ? 'active' : ''}" onclick="setFilter('all')">All Games (${games.length})</button>
                        <button class="filter-pill ${currentFilter === 'installed' ? 'active' : ''}" onclick="setFilter('installed')">Installed (${games.filter(g=>g.installed).length})</button>
                        <button class="filter-pill ${currentFilter === 'aim' ? 'active' : ''}" onclick="setFilter('aim')">Aim Assist</button>
                        <button class="filter-pill ${currentFilter === 'custom' ? 'active' : ''}" onclick="setFilter('custom')">User Added (${games.filter(g=>g.isCustom).length})</button>
                    </div>
                </div>

                <!-- Games Grid -->
                <div class="library-grid">
                    <!-- Prominent Add Game Card -->
                    <div class="add-custom-card" onclick="openAddGameModal()">
                        <div class="add-custom-icon"><i class="fa-solid fa-plus"></i></div>
                        <h4>Add Game</h4>
                        <p>Import APK or scan device apps</p>
                    </div>

                    ${filtered.map(g => `
                        <div class="game-grid-card" onclick="openGameDetail('${g.id}')">
                            <div>
                                <div class="game-grid-icon">${g.icon}</div>
                                <h4>${g.title}</h4>
                                <p>${g.category}</p>
                            </div>
                            <div class="card-footer">
                                <span class="mod-pill-count">${g.mods.length} MODS</span>
                                <button class="launch-btn ${g.installed ? 'primary' : ''}" onclick="event.stopPropagation(); launchGameSession('${g.id}')">
                                    ${g.installed ? 'Launch' : 'Get'}
                                </button>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    },

    // -----------------------------------------------------
    // STUDIO (MOD SUITE)
    // -----------------------------------------------------
    plugins: () => {
        return `
            <div class="fade-in">
                <!-- Module 1: Vision & Trajectory -->
                <div class="studio-section">
                    <div class="studio-module-header">
                        <i class="fa-solid fa-crosshairs"></i>
                        <h3>Vision & Trajectory Engine</h3>
                    </div>

                    <div class="mod-control-card">
                        <div class="mod-control-row">
                            <div class="mod-info">
                                <h4>Carrom Laser Raycasting</h4>
                                <p>External screen analysis overlay with bank reflection</p>
                            </div>
                            <label class="switch">
                                <input type="checkbox" checked onchange="toggleGameMod('carrom', 'carrom_aim')">
                                <span class="slider"></span>
                            </label>
                        </div>
                        <div class="mod-slider-container">
                            <div class="slider-header">
                                <span>Guideline Raycast Distance</span>
                                <span class="mono-font" id="guideline-val">${globalSettings.carromGuidelineLength}x</span>
                            </div>
                            <input type="range" class="mod-range" min="1.0" max="4.0" step="0.2" value="${globalSettings.carromGuidelineLength}" oninput="updateGuidelineLength(this.value)">
                        </div>
                    </div>

                    <div class="mod-control-card">
                        <div class="mod-control-row">
                            <div class="mod-info">
                                <h4>Secondary Cushion Bounce Line</h4>
                                <p>Predicts multi-bank wall reflections into pockets</p>
                            </div>
                            <label class="switch">
                                <input type="checkbox" ${globalSettings.bankBouncePredictor ? 'checked' : ''} onchange="toggleGlobalSetting('bankBouncePredictor')">
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Module 2: Asset Staging -->
                <div class="studio-section">
                    <div class="studio-module-header">
                        <i class="fa-solid fa-shirt"></i>
                        <h3>Skin & Texture Staging</h3>
                    </div>

                    <div class="mod-control-card">
                        <div class="mod-control-row">
                            <div class="mod-info">
                                <h4>Client-Side Mesh Replacer</h4>
                                <p>Replaces local game models without memory hooks</p>
                            </div>
                            <label class="switch">
                                <input type="checkbox" checked>
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>

                    <button class="btn-secondary" onclick="simulateAssetImport()">
                        <i class="fa-solid fa-file-arrow-up"></i> Import Custom .pak / .zip Archive
                    </button>
                </div>

                <!-- Module 3: Hardware Tuning -->
                <div class="studio-section">
                    <div class="studio-module-header">
                        <i class="fa-solid fa-microchip"></i>
                        <h3>Hardware & Touch Tuning</h3>
                    </div>

                    <div class="mod-control-card">
                        <div class="mod-control-row">
                            <div class="mod-info">
                                <h4>Touch Sampling Rate Overdrive</h4>
                                <p>Maximizes digitizer polling rate for instant response</p>
                            </div>
                            <label class="switch">
                                <input type="checkbox" ${globalSettings.touchBooster ? 'checked' : ''} onchange="toggleGlobalSetting('touchBooster')">
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
};

// =========================================================
// RENDER & NAVIGATION LOGIC
// =========================================================
function renderCurrentView() {
    appContent.innerHTML = views[currentTab]();
}

function updateNavIndicator(index) {
    navIndicator.style.transform = `translateX(${index * 100}%)`;
}

navItems.forEach((item, index) => {
    item.addEventListener('click', () => {
        const target = item.dataset.target;
        if (target !== currentTab) {
            navItems.forEach(i => i.classList.remove('active'));
            item.classList.add('active');
            updateNavIndicator(index);
            currentTab = target;
            renderCurrentView();
        }
    });
});

// Library Search & Filter handlers
window.handleSearch = function(query) {
    searchQuery = query;
    renderCurrentView();
};

window.setFilter = function(filter) {
    currentFilter = filter;
    renderCurrentView();
};

// =========================================================
// GAME DETAIL MODAL
// =========================================================
window.openGameDetail = function(gameId) {
    const game = games.find(g => g.id === gameId);
    if (!game) return;

    sheetContent.innerHTML = `
        <div style="text-align: center; margin-bottom: var(--space-lg)">
            <div style="width: 72px; height: 72px; background: var(--bg-surface); border: 1px solid var(--border-subtle); border-radius: var(--radius-md); font-size: 2.2rem; display: flex; align-items: center; justify-content: center; margin: 0 auto var(--space-xs); box-shadow: var(--shadow-soft);">
                ${game.icon}
            </div>
            <h2 style="font-size: 1.25rem; font-weight: 800; color: var(--text-primary);">${game.title}</h2>
            <p style="color: var(--text-secondary); font-size: 0.8rem;">${game.category} · ${game.installed ? 'Installed on device' : 'Not installed'}</p>
        </div>

        <button class="btn-primary" style="margin-bottom: var(--space-lg);" onclick="launchGameSession('${game.id}')">
            <i class="fa-solid fa-play"></i> ${game.installed ? 'Launch with Active Mods' : 'Install Game to Launch'}
        </button>

        <div class="deck-section-title">
            <span>Configured Modifications (${game.mods.length})</span>
        </div>

        ${game.mods.map(m => `
            <div class="mod-control-card">
                <div class="mod-control-row">
                    <div class="mod-info">
                        <h4>${m.name}</h4>
                        <p>${m.desc}</p>
                    </div>
                    <label class="switch">
                        <input type="checkbox" ${m.active ? 'checked' : ''} onchange="toggleGameMod('${game.id}', '${m.id}')">
                        <span class="slider"></span>
                    </label>
                </div>
            </div>
        `).join('')}

        <div style="margin-top: var(--space-md); padding: 12px; background: var(--bg-surface); border: 1px solid var(--border-subtle); border-radius: var(--radius-sm); font-size: 0.74rem; color: var(--text-secondary); display: flex; align-items: center; gap: 8px;">
            <i class="fa-solid fa-circle-check text-accent"></i>
            <span>All modifications run via external overlay or client asset cache.</span>
        </div>
    `;

    detailSheetOverlay.classList.add('active');
};

detailSheetOverlay.addEventListener('click', (e) => {
    if (e.target === detailSheetOverlay) {
        detailSheetOverlay.classList.remove('active');
    }
});

// Toggle individual game mod
window.toggleGameMod = function(gameId, modId) {
    const game = games.find(g => g.id === gameId);
    if (game) {
        const mod = game.mods.find(m => m.id === modId);
        if (mod) mod.active = !mod.active;
    }
};

window.toggleGlobalSetting = function(key) {
    globalSettings[key] = !globalSettings[key];
};

window.updateGuidelineLength = function(val) {
    globalSettings.carromGuidelineLength = val;
    const label = document.getElementById('guideline-val');
    if (label) label.textContent = `${val}x`;
};

// =========================================================
// ADD CUSTOM GAME WORKFLOW
// =========================================================
window.openAddGameModal = function() {
    renderDeviceAppsList('');
    addGameModal.classList.add('active');
};

openAddGameBtn.addEventListener('click', () => {
    window.openAddGameModal();
});

closeAddModalBtn.addEventListener('click', () => {
    addGameModal.classList.remove('active');
});

addGameModal.addEventListener('click', (e) => {
    if (e.target === addGameModal) addGameModal.classList.remove('active');
});

addGameSearch.addEventListener('input', (e) => {
    renderDeviceAppsList(e.target.value);
});

function renderDeviceAppsList(filterText) {
    const existingIds = new Set(games.map(g => g.id));
    let available = unaddedDeviceApps.filter(app => !existingIds.has(app.id));

    if (filterText.trim() !== '') {
        const q = filterText.toLowerCase();
        available = available.filter(a => a.title.toLowerCase().includes(q) || a.pkg.toLowerCase().includes(q));
    }

    if (available.length === 0) {
        deviceAppsList.innerHTML = `
            <div style="text-align: center; padding: 24px 0; color: var(--text-tertiary); font-size: 0.85rem;">
                No unadded packages found. All device games are in your library.
            </div>
        `;
        return;
    }

    deviceAppsList.innerHTML = available.map(app => `
        <div class="device-app-item" onclick="addGameToLibrary('${app.id}')">
            <div class="app-item-left">
                <div class="app-item-icon">${app.icon}</div>
                <div class="app-item-meta">
                    <h5>${app.title}</h5>
                    <span>${app.pkg}</span>
                </div>
            </div>
            <button class="action-btn add-btn" style="padding: 6px 12px; font-size: 0.75rem;">
                <i class="fa-solid fa-plus"></i> Add
            </button>
        </div>
    `).join('');
}

window.addGameToLibrary = function(appId) {
    const target = unaddedDeviceApps.find(a => a.id === appId);
    if (!target) return;

    // Add to games collection with universal mod suite
    games.push({
        id: target.id,
        title: target.title,
        icon: target.icon,
        installed: true,
        category: target.category,
        isCustom: true,
        mods: [
            { id: `${target.id}_fps`, name: '120Hz Refresh Unlocker', active: true, desc: 'Locks high-refresh display state' },
            { id: `${target.id}_dnd`, name: 'Game Focus DND', active: true, desc: 'Prevents notification & call interruptions' },
            { id: `${target.id}_pak`, name: 'Custom Asset Patch (.pak)', active: false, desc: 'Local file stage directory active' }
        ]
    });

    addGameModal.classList.remove('active');
    renderCurrentView();

    showToast(`Added "${target.title}" to Library`);
};

// Toast notification helper
function showToast(msg) {
    let toast = document.getElementById('owl-toast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = 'owl-toast';
        toast.style.cssText = 'position:fixed; bottom:80px; left:50%; transform:translateX(-50%); background:rgba(16,20,30,0.95); border:1px solid rgba(59,130,246,0.4); color:#FFFFFF; padding:10px 18px; border-radius:9999px; font-size:0.8rem; font-weight:600; z-index:300; box-shadow:0 8px 24px rgba(0,0,0,0.5); backdrop-filter:blur(8px); display:flex; align-items:center; gap:8px; pointer-events:none; transition:opacity 0.25s ease; opacity:0;';
        document.body.appendChild(toast);
    }
    toast.innerHTML = `<i class="fa-solid fa-circle-check" style="color:var(--accent-primary)"></i> ${msg}`;
    toast.style.opacity = '1';
    setTimeout(() => { toast.style.opacity = '0'; }, 2200);
}

// =========================================================
// IN-GAME COMPANION OVERLAY SIMULATION
// =========================================================
window.launchGameSession = function(gameId) {
    const game = games.find(g => g.id === gameId);
    if (!game) return;

    if (!game.installed) {
        showToast(`Please install ${game.title} first`);
        return;
    }

    // Close detail sheet if open
    detailSheetOverlay.classList.remove('active');

    // Setup Simulation Screen
    simGameTitle.textContent = `${game.title} (Running)`;
    
    // Check if aim assist is active on this game
    const hasAim = game.mods.some(m => m.id.includes('aim') && m.active);
    if (hasAim) {
        simGuidelineCanvas.style.display = 'block';
        document.getElementById('sim-hud-aim-status').textContent = 'RAYCAST 2.2x';
        document.getElementById('sim-hud-aim-status').style.color = 'var(--accent-secondary)';
    } else {
        simGuidelineCanvas.style.display = 'none';
        document.getElementById('sim-hud-aim-status').textContent = 'STANDBY';
        document.getElementById('sim-hud-aim-status').style.color = 'var(--text-tertiary)';
    }

    gameSimOverlay.classList.add('active');
};

simExitBtn.addEventListener('click', () => {
    gameSimOverlay.classList.remove('active');
});

window.simulateAssetImport = function() {
    alert('File Picker opened: Select custom .pak / .zip archive to stage to /Android/data/ directory.');
};

// Initial Setup
renderCurrentView();
updateNavIndicator(0);
