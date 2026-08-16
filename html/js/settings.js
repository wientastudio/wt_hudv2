const HudSettings = (() => {
    const elements = {};
    const state = {
        open: false,
        original: {},
        current: {},
        options: {},
        permissions: {}
    };

    // =====================================================
    // CACHE
    // =====================================================

    function cacheElements() {
        elements.overlay =
            document.getElementById("settingsOverlay");

        elements.close =
            document.getElementById("settingsClose");

        elements.cancel =
            document.getElementById("cancelSettings");

        elements.save =
            document.getElementById("saveSettings");

        elements.reset =
            document.getElementById("resetSettings");

        elements.navItems =
            document.querySelectorAll(".settings-nav-item");

        elements.pages =
            document.querySelectorAll(".settings-page");

        elements.hudEnabled =
            document.getElementById("settingHudEnabled");

        elements.scale =
            document.getElementById("settingScale");

        elements.scaleValue =
            document.getElementById("settingScaleValue");

        elements.statusEnabled =
            document.getElementById("settingStatusEnabled");
        
        elements.alwaysShowStatus =
    document.getElementById("settingAlwaysShowStatus");    

        elements.vehicleEnabled =
            document.getElementById("settingVehicleEnabled");

        elements.playerInfo =
            document.getElementById("settingPlayerInfo");

elements.locationEnabled =
    document.getElementById("settingLocationEnabled");

elements.weaponEnabled =
    document.getElementById("settingWeaponEnabled");

        elements.statusStyleGrid =
            document.getElementById("statusStyleGrid");

        elements.vehicleStyleGrid =
            document.getElementById("vehicleStyleGrid");

        elements.minimapModeGrid =
            document.getElementById("minimapModeGrid");
        
        elements.minimapShapeGrid =
            document.getElementById("minimapShapeGrid");    

        elements.accentGrid =
            document.getElementById("accentPresetGrid");

        elements.colorPicker =
            document.getElementById("accentColorPicker");

        elements.colorText =
            document.getElementById("accentColorText");

        elements.layoutOpen =
            document.getElementById("openLayoutEditor");
    }

    // =====================================================
    // HELPERS
    // =====================================================

    function clone(data) {
        return JSON.parse(
            JSON.stringify(data || {})
        );
    }

    function setPage(name) {
        elements.navItems.forEach((item) => {
            item.classList.toggle(
                "active",
                item.dataset.page === name
            );
        });

        elements.pages.forEach((page) => {
            page.classList.toggle(
                "active",
                page.id === `page-${name}`
            );
        });
    }

    function prettyName(value) {
        return String(value || "")
            .replaceAll("-", " ")
            .replaceAll("_", " ")
            .replace(/\b\w/g, (char) =>
                char.toUpperCase()
            );
    }

    function previewStyle(type, value) {
    if (type === "status") {
        window.HudApp
            ?.getModule("status")
            ?.setStyle(value);

        return;
    }

    if (type === "vehicle") {
        window.HudApp
            ?.getModule("vehicle")
            ?.setStyle(value);
    }
}

function restoreSelectedStyle(type) {
    if (type === "status") {
        window.HudApp
            ?.getModule("status")
            ?.setStyle(
                state.current.statusStyle ||
                "minimal"
            );

        return;
    }

    if (type === "vehicle") {
        window.HudApp
            ?.getModule("vehicle")
            ?.setStyle(
                state.current.vehicleStyle ||
                "digital"
            );
    }
}

    function validHex(value) {
        return /^#[0-9A-F]{6}$/i.test(
            String(value || "")
        );
    }

    // =====================================================
    // STYLE GRID
    // =====================================================

    function renderStyleGrid(
        container,
        values,
        selected,
        type
    ) {
        if (!container) return;

        container.innerHTML = "";

        (values || []).forEach((value) => {
            const item =
                document.createElement("button");

            item.type = "button";
            item.className = "style-option";

            if (value === selected) {
                item.classList.add("selected");
            }

            const preview =
                type === "status"
                    ? `
                        <div class="style-option-preview">
                            <span class="style-preview-block active"></span>
                            <span class="style-preview-block"></span>
                            <span class="style-preview-block"></span>
                            <span class="style-preview-block"></span>
                        </div>
                    `
                    : `
                        <div class="style-option-preview">
                            <span class="style-preview-chip"></span>
                            <span class="style-preview-chip"></span>
                            <span class="style-preview-chip"></span>
                        </div>
                    `;

            item.innerHTML = `
                <span class="style-option-name">
                    ${prettyName(value)}
                </span>

                <span class="style-option-desc">
                    ${type === "status"
                        ? "Player status appearance."
                        : "Vehicle speedometer appearance."}
                </span>

                ${preview}
            `;

item.addEventListener(
    "mouseenter",
    () => {
        previewStyle(
            type,
            value
        );
    }
);

item.addEventListener(
    "mouseleave",
    () => {
        restoreSelectedStyle(
            type
        );
    }
);

item.addEventListener(
    "click",
    () => {
        if (type === "status") {
            state.current.statusStyle =
                value;
        } else {
            state.current.vehicleStyle =
                value;
        }

        renderAll();

        previewStyle(
            type,
            value
        );
    }
);

            container.appendChild(item);
        });
    }

    // =====================================================
    // MINIMAP MODES
    // =====================================================

    function renderMinimapModes() {
        if (!elements.minimapModeGrid) {
            return;
        }

        elements.minimapModeGrid.innerHTML = "";

        (
            state.options.minimapModes || []
        ).forEach((mode) => {
            const item =
                document.createElement("button");

            item.type = "button";
            item.className = "choice-option";

            if (
                state.current.minimapMode ===
                mode
            ) {
                item.classList.add("selected");
            }

            item.innerHTML = `
                <span>${prettyName(mode)}</span>
                <span class="choice-indicator"></span>
            `;

item.addEventListener(
    "mouseenter",
    () => {
        window.HudApp?.nui(
            "minimap:preview",
            {
                mode
            }
        );
    }
);

item.addEventListener(
    "mouseleave",
    () => {
        window.HudApp?.nui(
            "minimap:preview",
            {
                mode:
                    state.current.minimapMode ||
                    "vehicle"
            }
        );
    }
);

item.addEventListener(
    "click",
    () => {
        state.current.minimapMode =
            mode;

        renderMinimapModes();

        window.HudApp?.nui(
            "minimap:preview",
            {
                mode
            }
        );
    }
);

            elements.minimapModeGrid
                .appendChild(item);
        });
    }





    // =====================================================
// MINIMAP SHAPES
// =====================================================

function renderMinimapShapes() {
    if (!elements.minimapShapeGrid) {
        return;
    }

    elements.minimapShapeGrid.innerHTML = "";

    (
        state.options.minimapShapes || []
    ).forEach((shape) => {
        const item =
            document.createElement("button");

        item.type = "button";
        item.className = "choice-option";

        if (
            state.current.minimapShape ===
            shape
        ) {
            item.classList.add("selected");
        }

        const name =
            shape === "circle"
                ? "Circle"
                : "Square";

        item.innerHTML = `
            <span>${name}</span>
            <span class="choice-indicator"></span>
        `;

        item.addEventListener(
            "mouseenter",
            () => {
                window.HudApp?.nui(
                    "minimap:shapePreview",
                    {
                        shape
                    }
                );
            }
        );

        item.addEventListener(
            "mouseleave",
            () => {
                window.HudApp?.nui(
                    "minimap:shapePreview",
                    {
                        shape:
                            state.current
                                .minimapShape
                    }
                );
            }
        );

        item.addEventListener(
            "click",
            () => {
                state.current.minimapShape =
                    shape;

                renderMinimapShapes();
                preview();
            }
        );

        elements.minimapShapeGrid
            .appendChild(item);
    });
}

    // =====================================================
    // ACCENT
    // =====================================================

    function renderAccentGrid() {
        if (!elements.accentGrid) {
            return;
        }

        elements.accentGrid.innerHTML = "";

        (
            state.options.colors || []
        ).forEach((color) => {
            const item =
                document.createElement("button");

            item.type = "button";
            item.className = "accent-option";

            if (
                String(state.current.accent)
                    .toUpperCase() ===
                String(color.value)
                    .toUpperCase()
            ) {
                item.classList.add("selected");
            }

            item.innerHTML = `
                <span
                    class="accent-swatch"
                    style="background:${color.value}"
                ></span>

                <span>${color.name}</span>
            `;

            item.addEventListener(
    "mouseenter",
    () => {
        document.documentElement
            .style.setProperty(
                "--accent",
                color.value
            );
    }
);

item.addEventListener(
    "mouseleave",
    () => {
        document.documentElement
            .style.setProperty(
                "--accent",
                state.current.accent ||
                "#7C5CFF"
            );
    }
);

item.addEventListener(
    "click",
    () => {
        state.current.accent =
            color.value;

        renderAll();

        document.documentElement
            .style.setProperty(
                "--accent",
                color.value
            );
    }
);

            elements.accentGrid
                .appendChild(item);
        });
    }

    // =====================================================
    // FORM SYNC
    // =====================================================

    function syncForm() {
        if (elements.hudEnabled) {
            elements.hudEnabled.checked =
                state.current.enabled !== false;
        }

        if (elements.scale) {
            elements.scale.value =
                Number(
                    state.current.scale || 1
                );
        }

        if (elements.scaleValue) {
            elements.scaleValue.textContent =
                `${Math.round(
                    Number(
                        state.current.scale || 1
                    ) * 100
                )}%`;
        }

        if (elements.statusEnabled) {
            elements.statusEnabled.checked =
                state.current.status !== false;
        }

        if (elements.alwaysShowStatus) {
    elements.alwaysShowStatus.checked =
        state.current.alwaysShowStatus === true;
}

        if (elements.vehicleEnabled) {
            elements.vehicleEnabled.checked =
                state.current.vehicle !== false;
        }

        if (elements.playerInfo) {
            elements.playerInfo.checked =
                state.current.playerInfo !==
                false;
        }

if (elements.locationEnabled) {
    elements.locationEnabled.checked =
        state.current.location !== false;
}

if (elements.weaponEnabled) {
    elements.weaponEnabled.checked =
        state.current.weapon !== false;
}

        if (elements.colorPicker) {
            elements.colorPicker.value =
                validHex(state.current.accent)
                    ? state.current.accent
                    : "#7C5CFF";
        }

        if (elements.colorText) {
            elements.colorText.value =
                state.current.accent ||
                "#7C5CFF";
        }
    }

    // =====================================================
    // RENDER ALL
    // =====================================================

    function renderAll() {
        syncForm();

        renderStyleGrid(
            elements.statusStyleGrid,
            state.options.statusStyles,
            state.current.statusStyle,
            "status"
        );

        renderStyleGrid(
            elements.vehicleStyleGrid,
            state.options.vehicleStyles,
            state.current.vehicleStyle,
            "vehicle"
        );

renderMinimapModes();
renderMinimapShapes();
renderAccentGrid();
        
    }

    // =====================================================
    // LIVE PREVIEW
    // =====================================================

    function applyPreviewLocally() {
        const root =
            document.documentElement;

        const hudRoot =
            document.getElementById("hudRoot");

        if (hudRoot) {
            hudRoot.classList.toggle(
                "is-hidden",
                state.current.enabled === false
            );
        }

        if (state.current.accent) {
            root.style.setProperty(
                "--accent",
                state.current.accent
            );
        }

        if (state.current.scale) {
            root.style.setProperty(
                "--hud-scale",
                state.current.scale
            );
        }

        document.body.dataset.minimapMode =
    state.current.minimapMode ||
    "vehicle";

        const visibility = {
            status:
                state.current.status,

            playerInfo:
                state.current.playerInfo,

            vehicle:
                state.current.vehicle,

            location:
                state.current.location,

            voice:
                state.current.voice,

            weapon:
                state.current.weapon
        };

        Object.entries(
            visibility
        ).forEach(([name, enabled]) => {
            document
                .querySelector(
                    `[data-hud-element="${name}"]`
                )
                ?.classList.toggle(
                    "user-hidden",
                    enabled === false
                );
        });

        window.HudApp
            ?.getModule("status")
            ?.setStyle(
                state.current.statusStyle ||
                "minimal"
            );

        window.HudApp
            ?.getModule("vehicle")
            ?.setStyle(
                state.current.vehicleStyle ||
                "digital"
            );
    }

    function preview() {
        applyPreviewLocally();

        window.HudApp?.nui(
            "settings:preview",
            state.current
        );
    }

    // =====================================================
    // OPEN / CLOSE
    // =====================================================

    function open(data) {
        if (!elements.overlay || !data) {
            return;
        }

        state.open = true;

        state.original =
            clone(data.settings);

        state.current =
            clone(data.settings);

        state.options =
            clone(data.options);

        state.permissions =
            clone(data.permissions);

        renderAll();
        applyPreviewLocally();

        setPage("general");

        elements.overlay.classList.remove(
            "hidden"
        );
    }

    function close() {
        state.open = false;

        elements.overlay?.classList.add(
            "hidden"
        );
    }

    // =====================================================
    // APPLY
    // =====================================================

    function apply(data) {
        if (!data) return;

        state.current =
            clone(data);

        applyPreviewLocally();
    }

    function applyInitial(data) {
        if (!data) return;

        if (data.accent) {
            document.documentElement
                .style.setProperty(
                    "--accent",
                    data.accent
                );
        }

        if (data.scale) {
            document.documentElement
                .style.setProperty(
                    "--hud-scale",
                    data.scale
                );
        }

        window.HudApp
            ?.getModule("status")
            ?.setStyle(
                data.statusStyle ||
                "minimal"
            );

        window.HudApp
            ?.getModule("vehicle")
            ?.setStyle(
                data.vehicleStyle ||
                "digital"
            );
    }

    // =====================================================
    // RESET
    // =====================================================

    function reset(data) {
        if (!data) return;

        state.current =
            clone(data);

        state.original =
            clone(data);

        renderAll();
        applyPreviewLocally();
    }

    // =====================================================
    // SAVE / CANCEL
    // =====================================================

async function save() {
    // Toggle değerlerini direkt DOM'dan tekrar oku.
    // state.current herhangi bir sebeple eski kaldıysa
    // yanlış değer kaydedilmesini engeller.
    if (elements.hudEnabled) {
        state.current.enabled =
            elements.hudEnabled.checked;
    }

    if (elements.statusEnabled) {
        state.current.status =
            elements.statusEnabled.checked;
    }

    if (elements.vehicleEnabled) {
        state.current.vehicle =
            elements.vehicleEnabled.checked;
    }

    if (elements.playerInfo) {
        state.current.playerInfo =
            elements.playerInfo.checked;
    }

    if (elements.locationEnabled) {
        state.current.location =
            elements.locationEnabled.checked;
    }

    if (elements.weaponEnabled) {
        state.current.weapon =
            elements.weaponEnabled.checked;
    }

    if (elements.alwaysShowStatus) {
        state.current.alwaysShowStatus =
            elements.alwaysShowStatus.checked;
    }

    const result =
        await window.HudApp?.nui(
            "settings:save",
            state.current
        );

    if (result === false) {
        return;
    }

    state.original =
        clone(state.current);

    await window.HudApp?.nui(
        "settings:close"
    );

    close();
}

    async function cancel() {
        state.current =
            clone(state.original);

        applyPreviewLocally();

        await window.HudApp?.nui(
            "settings:close"
        );

        close();
    }

    async function requestReset() {
        const result =
            await window.HudApp?.nui(
                "settings:reset"
            );

        if (
            result &&
            typeof result === "object"
        ) {
            reset(result);
        }
    }

    // =====================================================
    // EVENTS
    // =====================================================

    function bindToggle(
        element,
        key
    ) {
elements.locationEnabled
    ?.addEventListener(
        "change",
        (event) => {
            state.current.location =
                event.target.checked;

            preview();
        }
    );

elements.weaponEnabled
    ?.addEventListener(
        "change",
        (event) => {
            state.current.weapon =
                event.target.checked;

            preview();
        }
    );
    }

    function bindEvents() {
        elements.navItems.forEach(
            (item) => {
                item.addEventListener(
                    "click",
                    () => {
                        setPage(
                            item.dataset.page
                        );
                    }
                );
            }
        );

        elements.close?.addEventListener(
            "click",
            cancel
        );

        elements.cancel?.addEventListener(
            "click",
            cancel
        );

        elements.save?.addEventListener(
            "click",
            save
        );

        elements.reset?.addEventListener(
            "click",
            requestReset
        );

        bindToggle(
            elements.hudEnabled,
            "enabled"
        );

        bindToggle(
            elements.statusEnabled,
            "status"
        );

        elements.alwaysShowStatus
    ?.addEventListener(
        "change",
        (event) => {
            state.current.alwaysShowStatus =
                event.target.checked;

            preview();
        }
    );

        bindToggle(
            elements.vehicleEnabled,
            "vehicle"
        );

        bindToggle(
            elements.playerInfo,
            "playerInfo"
        );

        bindToggle(
            elements.voiceEnabled,
            "voice"
        );

        elements.scale?.addEventListener(
            "input",
            (event) => {
                state.current.scale =
                    Number(
                        event.target.value
                    );

                if (elements.scaleValue) {
                    elements.scaleValue.textContent =
                        `${Math.round(
                            state.current.scale *
                            100
                        )}%`;
                }

                preview();
            }
        );

        elements.colorPicker
            ?.addEventListener(
                "input",
                (event) => {
                    state.current.accent =
                        event.target.value;

                    if (
                        elements.colorText
                    ) {
                        elements.colorText.value =
                            state.current.accent;
                    }

                    renderAccentGrid();
                    preview();
                }
            );

        elements.colorText
            ?.addEventListener(
                "change",
                (event) => {
                    const value =
                        event.target.value
                            .trim();

                    if (!validHex(value)) {
                        event.target.value =
                            state.current.accent;

                        return;
                    }

                    state.current.accent =
                        value.toUpperCase();

                    if (
                        elements.colorPicker
                    ) {
                        elements.colorPicker.value =
                            state.current.accent;
                    }

                    renderAccentGrid();
                    preview();
                }
            );

elements.layoutOpen
    ?.addEventListener(
        "click",
        async () => {
            const result =
                await window.HudApp?.nui(
                    "layout:open"
                );

            if (
                !result ||
                result.allowed === false
            ) {
                return;
            }

            close();

            window.HudApp
                ?.getModule("layout")
                ?.open(
                    result.positions || {}
                );
        }
    );

        document.addEventListener(
            "keydown",
            (event) => {
                if (
                    event.key !==
                        "Escape" ||
                    !state.open
                ) {
                    return;
                }

                cancel();
            }
        );
    }

    // =====================================================
    // INIT
    // =====================================================

    function init() {
        cacheElements();
        bindEvents();

        if (!window.HudApp) {
            console.error(
                "[Wienta HUD] HudApp is not ready for Settings"
            );

            return;
        }

        window.HudApp.register(
            "settings",
            {
                open,
                close,
                apply,
                preview: apply,
                reset,
                applyInitial
            }
        );
    }

    document.addEventListener(
        "DOMContentLoaded",
        init
    );

    return {
        open,
        close,
        apply,
        reset,
        applyInitial
    };
})();

