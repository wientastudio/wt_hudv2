const VehicleHud = (() => {
    const elements = {};
    let currentStyle = "digital";

    // =====================================================
    // CACHE
    // =====================================================

    function cacheElements() {
        elements.root =
            document.getElementById("vehicleHud");

        elements.speed =
            document.getElementById("vehicleSpeed");

        elements.speedUnit =
            document.getElementById("vehicleSpeedUnit");

        elements.gear =
            document.getElementById("vehicleGear");

        elements.rpmValue =
            document.getElementById("rpmValue");

        elements.rpmFill =
            document.getElementById("rpmFill");

        elements.fuelValue =
            document.getElementById("fuelValue");

        elements.fuelFill =
            document.getElementById("fuelFill");

        elements.engineValue =
            document.getElementById("engineValue");

        elements.engineFill =
            document.getElementById("engineFill");

        elements.seatbelt =
            document.getElementById("seatbeltIcon");

            if (elements.seatbelt) {
    elements.seatbelt.innerHTML = `
        <svg
            viewBox="0 0 24 24"
            width="13"
            height="13"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
        >
            <circle cx="8" cy="5" r="2"></circle>

            <path d="M8 7v6"></path>
            <path d="M5 21l3-8"></path>
            <path d="M8 13l5 8"></path>

            <path d="M12 8l6 9"></path>
            <path d="M15 13l3-2"></path>
        </svg>
    `;
}

        elements.lights =
            document.getElementById("lightsIcon");

        elements.cruise =
            document.getElementById("cruiseIcon");

        elements.engine =
            document.getElementById("engineIcon");
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
        data?.visible === true;

    elements.root.classList.toggle(
        "is-hidden",
        !visible
    );
}

    function setActive(element, state) {
        if (!element) return;

        element.classList.toggle(
            "active",
            state === true
        );
    }

    // =====================================================
    // STYLE
    // =====================================================

    function setStyle(style) {
        if (!elements.root) return;

        const allowed = [
            "digital",
            "sport",
            "minimal",
            "arc",
            "compact"
        ];

        if (!allowed.includes(style)) {
            style = "digital";
        }

        currentStyle = style;

        elements.root.classList.remove(
            "vehicle-digital",
            "vehicle-sport",
            "vehicle-minimal",
            "vehicle-arc",
            "vehicle-compact"
        );

        elements.root.classList.add(
            `vehicle-${style}`
        );
    }

    // =====================================================
    // SPEED
    // =====================================================

    function updateSpeed(speed, unit) {
        if (!elements.speed) return;

        const value =
            Math.max(
                0,
                Math.round(Number(speed) || 0)
            );

        elements.speed.textContent =
            String(value).padStart(3, "0");

        if (elements.speedUnit) {
            elements.speedUnit.textContent =
                String(unit || "kmh").toUpperCase();
        }
    }

    // =====================================================
    // RPM
    // =====================================================

    function updateRpm(rpm) {
        const value = clamp(rpm);

        if (elements.rpmValue) {
            elements.rpmValue.textContent =
                Math.round(value);
        }

        if (elements.rpmFill) {
            elements.rpmFill.style.width =
                `${value}%`;

            elements.rpmFill.classList.remove(
                "high",
                "redline"
            );

            if (value >= 90) {
                elements.rpmFill.classList.add(
                    "redline"
                );
            } else if (value >= 75) {
                elements.rpmFill.classList.add(
                    "high"
                );
            }
        }

        if (elements.root) {
            const maxAngle = 280;
            const angle =
                (value / 100) * maxAngle;

            elements.root.style.setProperty(
                "--vehicle-rpm-angle",
                `${angle}deg`
            );
        }
    }

    // =====================================================
    // GEAR
    // =====================================================

    function updateGear(gear) {
        if (!elements.gear) return;

        elements.gear.textContent =
            String(gear ?? "N");
    }

    // =====================================================
    // FUEL
    // =====================================================

    function updateFuel(fuel) {
        const value = clamp(fuel);

        if (elements.fuelValue) {
            elements.fuelValue.textContent =
                Math.round(value);
        }

        if (elements.fuelFill) {
            elements.fuelFill.style.width =
                `${value}%`;
        }

        const fuelRow =
            elements.fuelFill?.closest(
                ".vehicle-meta-item"
            );

        if (!fuelRow) return;

        fuelRow.classList.remove(
            "warning",
            "danger"
        );

        if (value <= 10) {
            fuelRow.classList.add("danger");
        } else if (value <= 25) {
            fuelRow.classList.add("warning");
        }
    }

    // =====================================================
    // ENGINE
    // =====================================================

    function updateEngine(health, running) {
        const value = clamp(health);

        if (elements.engineValue) {
            elements.engineValue.textContent =
                Math.round(value);
        }

        if (elements.engineFill) {
            elements.engineFill.style.width =
                `${value}%`;
        }

        const engineRow =
            elements.engineFill?.closest(
                ".vehicle-meta-item"
            );

        if (engineRow) {
            engineRow.classList.remove(
                "warning",
                "danger"
            );

            if (value <= 25) {
                engineRow.classList.add(
                    "danger"
                );
            } else if (value <= 50) {
                engineRow.classList.add(
                    "warning"
                );
            }
        }

        elements.root?.classList.toggle(
            "engine-off",
            running === false
        );

        if (elements.engine) {
            elements.engine.classList.toggle(
                "active",
                running === true
            );

            elements.engine.classList.toggle(
                "danger",
                running === false
            );
        }
    }

    // =====================================================
    // ICON STATES
    // =====================================================

    function updateIcons(data) {
        setActive(
            elements.seatbelt,
            data.seatbelt
        );

        setActive(
            elements.lights,
            data.lights
        );

        setActive(
            elements.cruise,
            data.cruise
        );

        if (elements.lights) {
            elements.lights.classList.toggle(
                "warning",
                data.highBeam === true
            );
        }
    }

    // =====================================================
    // PARKING / HANDBRAKE
    // =====================================================

    function updateParking(data) {
        const parked =
            data.handbrake === true ||
            String(data.gear) === "P";

        elements.root?.classList.toggle(
            "parked",
            parked
        );
    }

    // =====================================================
    // UPDATE
    // =====================================================

    function update(data) {
        if (!elements.root || !data) {
            return;
        }

        updateSpeed(
            data.speed,
            data.speedUnit
        );

        updateRpm(
            data.rpm
        );

        updateGear(
            data.gear
        );

        updateFuel(
            data.fuel
        );

        updateEngine(
            data.engine,
            data.engineRunning
        );

        updateIcons(
            data
        );

        updateParking(
            data
        );
    }

    // =====================================================
    // SETTINGS
    // =====================================================

function applySettings(settings) {
    if (!settings) return;

    if (settings.vehicleStyle) {
        setStyle(
            settings.vehicleStyle
        );
    }
}
    // =====================================================
    // INIT
    // =====================================================

    function init() {
        cacheElements();

        if (!window.HudApp) {
            console.error(
                "[Wienta HUD] HudApp is not ready for VehicleHud"
            );

            return;
        }

        window.HudApp.register(
            "vehicle",
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