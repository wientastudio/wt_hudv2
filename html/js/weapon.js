const WeaponHud = (() => {
    const elements = {};

    function cacheElements() {
        elements.root =
            document.getElementById("weaponHud");

        elements.name =
            document.getElementById("weaponName");

        elements.loaded =
            document.getElementById(
                "weaponLoadedAmmo"
            );

        elements.reserve =
            document.getElementById(
                "weaponReserveAmmo"
            );

        elements.durability =
            document.getElementById(
                "weaponDurabilityFill"
            );

        elements.ammo =
            elements.root?.querySelector(
                ".weapon-ammo"
            );

        elements.durabilityWrapper =
            elements.root?.querySelector(
                ".weapon-durability"
            );
    }

    function clamp(value) {
        return Math.max(
            0,
            Math.min(
                100,
                Number(value) || 0
            )
        );
    }

    function setVisibility(data) {
        if (!elements.root) return;

        elements.root.classList.toggle(
            "is-hidden",
            data?.visible === false
        );
    }

    function formatWeaponName(data) {
        if (data.label) {
            return data.label;
        }

        return String(
            data.name || ""
        )
            .replace(/^WEAPON_/i, "")
            .replaceAll("_", " ");
    }

    function update(data) {
        if (!elements.root || !data) {
            return;
        }

        const visibility =
            data.visibility || {};

        setVisibility({
            visible: true
        });

        if (elements.name) {
            elements.name.textContent =
                formatWeaponName(data)
                    .toUpperCase();

            elements.name.style.display =
                visibility.weaponName !== false
                    ? ""
                    : "none";
        }

        const melee =
            data.melee === true;

        if (elements.ammo) {
            elements.ammo.style.display =
                !melee &&
                visibility.ammo !== false
                    ? ""
                    : "none";
        }

        if (!melee) {
            if (elements.loaded) {
                elements.loaded.textContent =
                    Math.max(
                        0,
                        Number(
                            data.ammo?.loaded
                        ) || 0
                    );
            }

            if (elements.reserve) {
                elements.reserve.textContent =
                    Math.max(
                        0,
                        Number(
                            data.ammo?.reserve
                        ) || 0
                    );
            }
        }

        const durability =
            clamp(data.durability);

        if (elements.durability) {
            elements.durability.style.width =
                `${durability}%`;
        }

        if (elements.durabilityWrapper) {
            elements.durabilityWrapper.style.display =
                Number.isFinite(
                    Number(data.durability)
                )
                    ? ""
                    : "none";
        }

        elements.root.classList.toggle(
            "weapon-low-durability",
            durability <= 25
        );
    }

    function applySettings(settings) {
        if (
            typeof settings?.weapon ===
            "boolean"
        ) {
            setVisibility({
                visible: settings.weapon
            });
        }
    }

    function init() {
        cacheElements();

        if (!window.HudApp) return;

        window.HudApp.register(
            "weapon",
            {
                update,
                setVisibility,
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
        applySettings
    };
})();