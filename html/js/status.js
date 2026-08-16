const StatusHud = (() => {
    const elements = {};
    const statuses = [
        "health",
        "armor",
        "hunger",
        "thirst",
        "stress",
        "stamina",
        "oxygen"
    ];

    let currentStyle = "minimal";

    // =====================================================
    // CACHE
    // =====================================================

    function cacheElements() {
        elements.root =
            document.getElementById("statusHud");

        statuses.forEach((name) => {
            const capitalized =
                name.charAt(0).toUpperCase() +
                name.slice(1);

            elements[name] = {
                root:
                    document.getElementById(
                        `status${capitalized}`
                    ),

                fill:
                    document.getElementById(
                        `${name}Fill`
                    ),

                value:
                    document.getElementById(
                        `${name}Value`
                    )
            };
        });
    }

    // =====================================================
    // HELPERS
    // =====================================================

    function clamp(value) {
        return Math.max(
            0,
            Math.min(100, Number(value) || 0)
        );
    }

    function setVisibility(data) {
        if (!elements.root) return;

        const visible =
            data?.visible !== false;

        elements.root.classList.toggle(
            "is-hidden",
            !visible
        );
    }

    // =====================================================
    // STYLE
    // =====================================================

    function setStyle(style) {
        if (!elements.root) return;

        const allowed = [
            "minimal",
            "circle",
            "capsule",
            "blocks",
            "compact",
            "glass"
        ];

        if (!allowed.includes(style)) {
            style = "minimal";
        }

        currentStyle = style;

        elements.root.classList.remove(
            "status-minimal",
            "status-circle",
            "status-capsule",
            "status-blocks",
            "status-compact",
            "status-glass"
        );

        elements.root.classList.add(
            `status-${style}`
        );

        refreshProgressModes();
    }

    // =====================================================
    // STATUS STATE
    // =====================================================

    function getState(name, value) {
        if (
            name === "health" ||
            name === "hunger" ||
            name === "thirst" ||
            name === "oxygen" ||
            name === "stamina"
        ) {
            if (value <= 15) {
                return "critical";
            }

            if (value <= 30) {
                return "low";
            }
        }

        if (name === "armor") {
            if (value > 0 && value <= 20) {
                return "low";
            }
        }

        if (name === "stress") {
            if (value >= 85) {
                return "critical";
            }

            if (value >= 65) {
                return "low";
            }
        }

        return null;
    }

    function applyState(element, state) {
        if (!element) return;

        element.classList.remove(
            "low",
            "critical"
        );

        if (state) {
            element.classList.add(state);
        }
    }

    // =====================================================
    // PROGRESS
    // =====================================================

    function updateProgress(name, value) {
        const item = elements[name];

        if (!item) return;

        const percent = clamp(value);

        if (item.fill) {
            if (currentStyle === "compact") {
                item.fill.style.height =
                    `${percent}%`;

                item.fill.style.width =
                    "100%";
            } else {
                item.fill.style.width =
                    `${percent}%`;

                item.fill.style.height =
                    "100%";
            }
        }

        if (item.root) {
            item.root.style.setProperty(
                "--status-progress",
                `${percent}%`
            );
        }

        if (item.value) {
            item.value.textContent =
                Math.round(percent);
        }
    }

    function refreshProgressModes() {
        statuses.forEach((name) => {
            const item = elements[name];

            if (!item?.value) return;

            updateProgress(
                name,
                Number(item.value.textContent) || 0
            );
        });
    }

    // =====================================================
    // ELEMENT VISIBILITY
    // =====================================================

    function setStatusVisible(name, visible) {
        const item = elements[name]?.root;

        if (!item) return;

        const wasHidden =
            item.classList.contains("is-hidden");

        item.classList.toggle(
            "is-hidden",
            !visible
        );

        if (
            visible &&
            wasHidden
        ) {
            item.classList.remove(
                "status-enter"
            );

            void item.offsetWidth;

            item.classList.add(
                "status-enter"
            );
        }
    }

    // =====================================================
    // UPDATE ONE
    // =====================================================

    function updateStatus(name, data) {
        if (!data) return;

        const value =
            clamp(data.value);

        updateProgress(
            name,
            value
        );

        setStatusVisible(
            name,
            data.visible !== false
        );

        applyState(
            elements[name]?.root,
            getState(name, value)
        );
    }

    // =====================================================
    // UPDATE ALL
    // =====================================================

    function update(data) {
        if (!elements.root || !data) {
            return;
        }

        setVisibility({
            visible: true
        });

        statuses.forEach((name) => {
            updateStatus(
                name,
                data[name]
            );
        });
    }

    // =====================================================
    // SETTINGS
    // =====================================================

    function applySettings(settings) {
        if (!settings) return;

        if (settings.statusStyle) {
            setStyle(
                settings.statusStyle
            );
        }

        if (
            typeof settings.status ===
            "boolean"
        ) {
            setVisibility({
                visible: settings.status
            });
        }
    }

    // =====================================================
    // INIT
    // =====================================================

    function init() {
        cacheElements();

        if (!window.HudApp) {
            console.error(
                "[Wienta HUD] HudApp is not ready for StatusHud"
            );

            return;
        }

        window.HudApp.register(
            "status",
            {
                update,
                setVisibility,
                setStyle,
                applySettings
            }
        );
    }

    document.addEventListener(
        "DOMContentLoaded",
        init
    );

    return {
        update,
        setVisibility,
        setStyle,
        applySettings
    };
})();