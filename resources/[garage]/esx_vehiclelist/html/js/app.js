/* ============================================
   VEHICLE MANAGER - NUI Application
   ============================================ */

(function () {
    'use strict';

    // ---- State ----
    let vehicles = [];
    let selectedVehicle = null;
    let activeFilter = 'all';

    // ---- DOM References ----
    const app = document.getElementById('vehicle-app');
    const vehicleListEl = document.getElementById('vehicle-list');
    const vehicleCountEl = document.getElementById('vehicle-count');
    const searchInput = document.getElementById('search-input');
    const closeBtn = document.getElementById('close-btn');
    const tabs = document.querySelectorAll('.tab');

    // Preview
    const noVehicleMsg = document.getElementById('no-vehicle-msg');
    const vehiclePreview = document.getElementById('vehicle-preview');
    const previewImage = document.getElementById('preview-image');
    const previewName = document.getElementById('preview-name');
    const previewPlate = document.getElementById('preview-plate');
    const actionButtons = document.getElementById('action-buttons');

    // Details
    const detailsContainer = document.getElementById('details-container');
    const noDetails = document.getElementById('no-details');

    // Stats
    const statSpeed = document.getElementById('stat-speed');
    const statAcceleration = document.getElementById('stat-acceleration');
    const statTraction = document.getElementById('stat-traction');
    const statBraking = document.getElementById('stat-braking');

    // Durability
    const ringEngineFill = document.getElementById('ring-engine-fill');
    const ringBodyFill = document.getElementById('ring-body-fill');
    const ringFuelFill = document.getElementById('ring-fuel-fill');
    const ringOilFill = document.getElementById('ring-oil-fill');
    const valEngine = document.getElementById('val-engine');
    const valBody = document.getElementById('val-body');
    const valFuel = document.getElementById('val-fuel');
    const valOil = document.getElementById('val-oil');

    // Cosmetics
    const colorPrimary = document.getElementById('color-primary');
    const colorSecondary = document.getElementById('color-secondary');
    const modsList = document.getElementById('mods-list');

    // Buttons
    const btnSpawn = document.getElementById('btn-spawn');
    const btnRepair = document.getElementById('btn-repair');
    const btnTransfer = document.getElementById('btn-transfer');

    // ---- NUI Message Listener ----
    window.addEventListener('message', function (event) {
        const data = event.data;

        switch (data.action) {
            case 'open':
                openMenu(data.vehicles || []);
                break;
            case 'close':
                closeMenu();
                break;
            case 'updateVehicle':
                updateVehicleData(data.vehicle);
                break;
        }
    });

    // ---- Keyboard Listener ----
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeMenu();
        }
    });

    // ---- Open / Close ----
    function openMenu(vehicleData) {
        vehicles = vehicleData;
        selectedVehicle = null;
        activeFilter = 'all';
        searchInput.value = '';

        // Reset tabs
        tabs.forEach(t => t.classList.remove('active'));
        document.querySelector('[data-tab="all"]').classList.add('active');

        renderVehicleList();
        resetPreview();
        resetDetails();

        app.classList.remove('hidden');
    }

    function closeMenu() {
        app.classList.add('hidden');
        fetch('https://esx_vehiclelist/closeUI', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }

    // ---- Vehicle List Rendering ----
    function getFilteredVehicles() {
        let filtered = vehicles;

        // Filter by status tab
        if (activeFilter !== 'all') {
            filtered = filtered.filter(v => {
                if (activeFilter === 'garage') return v.status === 'garage';
                if (activeFilter === 'out') return v.status === 'out';
                if (activeFilter === 'impound') return v.status === 'impound';
                return true;
            });
        }

        // Filter by search
        const query = searchInput.value.toLowerCase().trim();
        if (query) {
            filtered = filtered.filter(v =>
                v.name.toLowerCase().includes(query) ||
                v.brand.toLowerCase().includes(query) ||
                v.plate.toLowerCase().includes(query)
            );
        }

        return filtered;
    }

    function renderVehicleList() {
        const filtered = getFilteredVehicles();
        vehicleCountEl.textContent = filtered.length;
        vehicleListEl.innerHTML = '';

        if (filtered.length === 0) {
            vehicleListEl.innerHTML = `
                <div style="text-align:center; padding:40px 10px; color:var(--text-muted);">
                    <div style="font-size:32px; margin-bottom:8px;">&#128683;</div>
                    <p>No vehicles found</p>
                </div>
            `;
            return;
        }

        filtered.forEach(function (vehicle, index) {
            const card = document.createElement('div');
            card.className = 'vehicle-card' + (selectedVehicle && selectedVehicle.plate === vehicle.plate ? ' active' : '');
            card.style.animationDelay = (index * 0.03) + 's';

            const statusClass = vehicle.status || 'garage';
            const statusLabel = statusClass === 'garage' ? 'GARAGE' : statusClass === 'out' ? 'OUT' : 'IMPOUND';

            card.innerHTML = `
                <div class="vehicle-card-icon">&#128663;</div>
                <div class="vehicle-card-info">
                    <div class="vehicle-card-name">${escapeHtml(vehicle.name)}</div>
                    <div class="vehicle-card-brand">${escapeHtml(vehicle.brand)}</div>
                    <span class="vehicle-card-plate">${escapeHtml(vehicle.plate)}</span>
                </div>
                <div class="vehicle-card-status">
                    <span class="status-badge ${statusClass}">${statusLabel}</span>
                </div>
            `;

            card.addEventListener('click', function () {
                selectVehicle(vehicle);
            });

            vehicleListEl.appendChild(card);
        });
    }

    // ---- Vehicle Selection ----
    function selectVehicle(vehicle) {
        selectedVehicle = vehicle;

        // Update list active state
        document.querySelectorAll('.vehicle-card').forEach(c => c.classList.remove('active'));
        event.currentTarget && event.currentTarget.classList.add('active');

        // Update preview
        showPreview(vehicle);

        // Update details
        showDetails(vehicle);

        // Show action buttons
        actionButtons.classList.remove('hidden');

        // Re-render list to update active state
        renderVehicleList();

        // Notify Lua
        fetch('https://esx_vehiclelist/selectVehicle', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ plate: vehicle.plate, model: vehicle.model })
        });
    }

    // ---- Preview Panel ----
    function showPreview(vehicle) {
        noVehicleMsg.classList.add('hidden');
        vehiclePreview.classList.remove('hidden');

        previewName.textContent = vehicle.name;
        previewPlate.textContent = vehicle.plate;

        // Use vehicle image or placeholder
        if (vehicle.image) {
            previewImage.src = vehicle.image;
            previewImage.style.display = 'block';
        } else {
            // Show a large car emoji as placeholder
            previewImage.style.display = 'none';
            const wrapper = document.querySelector('.preview-image-wrapper');
            let placeholder = wrapper.querySelector('.preview-placeholder');
            if (!placeholder) {
                placeholder = document.createElement('div');
                placeholder.className = 'preview-placeholder';
                placeholder.innerHTML = '&#128663;';
                wrapper.appendChild(placeholder);
            }
            placeholder.style.display = 'flex';
        }
    }

    function resetPreview() {
        noVehicleMsg.classList.remove('hidden');
        vehiclePreview.classList.add('hidden');
        actionButtons.classList.add('hidden');

        const placeholder = document.querySelector('.preview-placeholder');
        if (placeholder) placeholder.style.display = 'none';
    }

    // ---- Details Panel ----
    function showDetails(vehicle) {
        noDetails.classList.add('hidden');
        detailsContainer.classList.remove('hidden');

        // Performance stats (0-100)
        const stats = vehicle.stats || {};
        animateBar(statSpeed, stats.speed || 0);
        animateBar(statAcceleration, stats.acceleration || 0);
        animateBar(statTraction, stats.traction || 0);
        animateBar(statBraking, stats.braking || 0);

        // Durability rings
        const durability = vehicle.durability || {};
        animateRing(ringEngineFill, valEngine, durability.engine || 0);
        animateRing(ringBodyFill, valBody, durability.body || 0);
        animateRing(ringFuelFill, valFuel, durability.fuel || 0);
        animateRing(ringOilFill, valOil, durability.oil || 0);

        // Cosmetics - Colors
        const cosmetics = vehicle.cosmetics || {};
        colorPrimary.style.backgroundColor = cosmetics.primaryColor || '#333333';
        colorSecondary.style.backgroundColor = cosmetics.secondaryColor || '#333333';

        // Mods
        renderMods(cosmetics.mods || []);
    }

    function resetDetails() {
        noDetails.classList.remove('hidden');
        detailsContainer.classList.add('hidden');
    }

    function animateBar(barEl, value) {
        const clamped = Math.min(100, Math.max(0, value));
        setTimeout(function () {
            barEl.style.width = clamped + '%';
        }, 50);
        const valSpan = barEl.querySelector('.stat-value');
        if (valSpan) valSpan.textContent = Math.round(clamped) + '%';
    }

    function animateRing(ringEl, valEl, value) {
        const clamped = Math.min(100, Math.max(0, value));
        setTimeout(function () {
            ringEl.style.strokeDasharray = clamped + ', 100';
        }, 50);
        valEl.textContent = Math.round(clamped) + '%';
    }

    function renderMods(mods) {
        modsList.innerHTML = '';

        if (mods.length === 0) {
            modsList.innerHTML = '<div class="mod-item"><span class="mod-name">No modifications</span></div>';
            return;
        }

        mods.forEach(function (mod) {
            const item = document.createElement('div');
            item.className = 'mod-item';

            let valueClass = '';
            let displayValue = mod.value;

            if (typeof mod.value === 'boolean') {
                valueClass = mod.value ? 'yes' : 'no';
                displayValue = mod.value ? 'Yes' : 'No';
            } else if (typeof mod.value === 'string') {
                displayValue = mod.value;
            }

            item.innerHTML = `
                <span class="mod-name">${escapeHtml(mod.name)}</span>
                <span class="mod-value ${valueClass}">${escapeHtml(String(displayValue))}</span>
            `;
            modsList.appendChild(item);
        });
    }

    // ---- Update single vehicle data (live updates) ----
    function updateVehicleData(updatedVehicle) {
        const index = vehicles.findIndex(v => v.plate === updatedVehicle.plate);
        if (index !== -1) {
            vehicles[index] = Object.assign(vehicles[index], updatedVehicle);
            if (selectedVehicle && selectedVehicle.plate === updatedVehicle.plate) {
                selectedVehicle = vehicles[index];
                showDetails(selectedVehicle);
            }
        }
        renderVehicleList();
    }

    // ---- Tab Filtering ----
    tabs.forEach(function (tab) {
        tab.addEventListener('click', function () {
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            activeFilter = tab.dataset.tab;
            renderVehicleList();
        });
    });

    // ---- Search ----
    searchInput.addEventListener('input', function () {
        renderVehicleList();
    });

    // ---- Close Button ----
    closeBtn.addEventListener('click', function () {
        closeMenu();
    });

    // ---- Action Buttons ----
    btnSpawn.addEventListener('click', function () {
        if (!selectedVehicle) return;
        fetch('https://esx_vehiclelist/spawnVehicle', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ plate: selectedVehicle.plate, model: selectedVehicle.model })
        });
    });

    btnRepair.addEventListener('click', function () {
        if (!selectedVehicle) return;
        fetch('https://esx_vehiclelist/repairVehicle', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ plate: selectedVehicle.plate })
        });
    });

    btnTransfer.addEventListener('click', function () {
        if (!selectedVehicle) return;
        fetch('https://esx_vehiclelist/transferVehicle', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ plate: selectedVehicle.plate })
        });
    });

    // ---- Utilities ----
    function escapeHtml(str) {
        const div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    // ---- Demo Mode (for testing in browser) ----
    // Uncomment below to test in a standalone browser
    /*
    openMenu([
        {
            name: 'Zentorno', brand: 'Pegassi', plate: 'ABC 123', model: 'zentorno',
            status: 'garage', image: null,
            stats: { speed: 88, acceleration: 82, traction: 70, braking: 55 },
            durability: { engine: 92, body: 78, fuel: 65, oil: 88 },
            cosmetics: {
                primaryColor: '#e74c3c', secondaryColor: '#2c3e50',
                mods: [
                    { name: 'Engine', value: 'Level 4' },
                    { name: 'Turbo', value: true },
                    { name: 'Xenon', value: true },
                    { name: 'Suspension', value: 'Level 3' },
                    { name: 'Armor', value: 'Level 2' }
                ]
            }
        },
        {
            name: 'Elegy RH8', brand: 'Annis', plate: 'XYZ 789', model: 'elegy2',
            status: 'out', image: null,
            stats: { speed: 75, acceleration: 70, traction: 80, braking: 65 },
            durability: { engine: 45, body: 30, fuel: 20, oil: 60 },
            cosmetics: {
                primaryColor: '#3498db', secondaryColor: '#1abc9c',
                mods: [
                    { name: 'Engine', value: 'Level 2' },
                    { name: 'Turbo', value: false },
                    { name: 'Xenon', value: true },
                    { name: 'Brakes', value: 'Level 3' }
                ]
            }
        },
        {
            name: 'Sultan RS', brand: 'Karin', plate: 'IMP 456', model: 'sultanrs',
            status: 'impound', image: null,
            stats: { speed: 72, acceleration: 68, traction: 75, braking: 60 },
            durability: { engine: 10, body: 15, fuel: 5, oil: 25 },
            cosmetics: {
                primaryColor: '#f39c12', secondaryColor: '#ecf0f1',
                mods: [
                    { name: 'Engine', value: 'Level 1' },
                    { name: 'Turbo', value: true },
                    { name: 'Xenon', value: false }
                ]
            }
        }
    ]);
    */
})();
