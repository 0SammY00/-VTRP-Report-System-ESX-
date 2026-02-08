let currentReports = [];
let activeTab = 'active';

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === 'openReport') {
        document.getElementById('player-container').classList.remove('hidden');
    } else if (data.action === 'openAdmin') {
        currentReports = data.reports;
        renderReports();
        document.getElementById('admin-container').classList.remove('hidden');
    } else if (data.action === 'close') {
        closeUI();
    } else if (data.action === 'notifyAdmin') {
        showAdminNotification(data.text);
    } else if (data.action === 'updateReports') {
        currentReports = data.reports;
        if (!document.getElementById('admin-container').classList.contains('hidden')) {
            renderReports();
        }
    }
});

function closeUI() {
    document.getElementById('player-container').classList.add('hidden');
    document.getElementById('admin-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
}

function submitReport() {
    let category = document.getElementById('report-category').value;
    let text = document.getElementById('report-text').value;

    if (text.length < 5) return; // Jednoduchá validácia

    fetch(`https://${GetParentResourceName()}/submitReport`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ category: category, text: text })
    });
    
    document.getElementById('report-text').value = ''; // Vymazať
    closeUI();
}

function switchTab(tab) {
    activeTab = tab;
    document.getElementById('tab-active').classList.remove('active-tab');
    document.getElementById('tab-resolved').classList.remove('active-tab');
    document.getElementById(`tab-${tab}`).classList.add('active-tab');
    renderReports();
}

function renderReports() {
    let container = document.getElementById('reports-list');
    container.innerHTML = '';

    // Filtrovať reporty podľa tabu
    let filtered = currentReports.filter(r => (activeTab === 'active' ? !r.resolved : r.resolved));

    if (filtered.length === 0) {
        container.innerHTML = '<p style="text-align:center; color:#555;">Žiadne reporty...</p>';
        return;
    }

    // Zoradiť: Najnovšie hore
    filtered.sort((a, b) => b.id - a.id);

    filtered.forEach(r => {
        let card = document.createElement('div');
        card.className = 'report-card';
        // Zmeniť farbu okraja ak je vyriešený
        if(r.resolved) card.style.borderLeftColor = '#00b894';

        let actions = '';
        if (!r.resolved) {
            actions = `
                <button class="action-btn btn-goto" onclick="adminAction('goto', ${r.targetSource})"><i class="fas fa-plane"></i> Goto</button>
                <button class="action-btn btn-bring" onclick="adminAction('bring', ${r.targetSource})"><i class="fas fa-magnet"></i> Bring</button>
                <button class="action-btn btn-resolve" onclick="adminAction('resolve', ${r.id})"><i class="fas fa-check"></i> Vyriešiť</button>
            `;
        } else {
            actions = '<span style="color:#00b894; font-size:12px;">✅ Vyriešené</span>';
        }

        card.innerHTML = `
            <div class="card-header">
                <span class="card-id">REPORT #${r.id} | ${r.category.toUpperCase()}</span>
                <span class="card-author">${r.name} (ID: ${r.targetSource})</span>
            </div>
            <div class="card-body">
                ${r.text}
            </div>
            <div class="card-actions">
                ${actions}
            </div>
        `;
        container.appendChild(card);
    });
}

function adminAction(type, data) {
    fetch(`https://${GetParentResourceName()}/adminAction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: type, data: data })
    });
}

function showAdminNotification(text) {
    let notif = document.getElementById('admin-notification');
    document.getElementById('notif-text').innerText = text;
    notif.classList.remove('hidden');
    setTimeout(() => {
        notif.classList.add('hidden');
    }, 5000);
}

// Zatvorenie cez ESC
document.onkeyup = function(data) {
    if (data.which == 27) {
        closeUI();
    }
};