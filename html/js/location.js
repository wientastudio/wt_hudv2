const LocationHud = (() => {
    const elements = {};

    // =====================================================
    // CACHE
    // =====================================================

    function cacheElements() {
        elements.root =
            document.getElementById("locationHud");

        elements.direction =
            document.getElementById("compassDirection");

        elements.heading =
            document.getElementById("compassHeading");

        elements.street =
            document.getElementById("streetName");

        elements.crossingWrapper =
            document.getElementById("crossingWrapper");

        elements.crossing =
            document.getElementById("crossingName");

        elements.postalWrapper =
            document.getElementById("postalWrapper");

        elements.postal =
            document.getElementById("postalValue");
    }

    // =====================================================
    // HELPERS
    // =====================================================

    function setText(element, value, fallback = "") {
        if (!element) return;

        element.textContent =
            value ?? fallback;
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
    // COMPASS
    // =====================================================

    function updateCompass(data, visibility) {
        const compass =
            data?.compass || {};

        setText(
            elements.direction,
            compass.direction || "N"
        );

        setText(
            elements.heading,
            `${Math.round(
                Number(compass.heading) || 0
            )}°`
        );

        elements.root.classList.toggle(
            "no-compass",
            visibility.compass === false
        );

        elements.root.classList.toggle(
            "no-heading",
            visibility.heading === false
        );
    }

    // =====================================================
    // STREET
    // =====================================================

    function updateStreet(data, visibility) {
        const street =
            String(data.street || "").trim();

        const crossing =
            String(data.crossing || "").trim();

        setText(
            elements.street,
            street
        );

        setText(
            elements.crossing,
            crossing
        );

        const showStreet =
            visibility.street !== false &&
            street.length > 0;

        const showCrossing =
            visibility.crossing !== false &&
            crossing.length > 0 &&
            crossing !== street;

        elements.root.classList.toggle(
            "no-street",
            !showStreet
        );

        elements.root.classList.toggle(
            "no-crossing",
            !showCrossing
        );

        if (elements.crossingWrapper) {
            elements.crossingWrapper.style.display =
                showCrossing ? "" : "none";
        }
    }

    // =====================================================
    // POSTAL
    // =====================================================

    function updatePostal(data, visibility) {
        const postal =
            data.postal;

        const showPostal =
            visibility.postal === true &&
            postal !== null &&
            postal !== undefined &&
            String(postal).trim() !== "";

        if (showPostal) {
            setText(
                elements.postal,
                postal
            );
        }

        elements.root.classList.toggle(
            "no-postal",
            !showPostal
        );

        if (elements.postalWrapper) {
            elements.postalWrapper.style.display =
                showPostal ? "" : "none";
        }
    }

    // =====================================================
    // UPDATE
    // =====================================================

    function update(data) {
        if (!elements.root || !data) {
            return;
        }

        const visibility =
            data.visibility || {};

        setVisibility({
            visible: true
        });

        updateCompass(
            data,
            visibility
        );

        updateStreet(
            data,
            visibility
        );

        updatePostal(
            data,
            visibility
        );
    }

    // =====================================================
    // SETTINGS
    // =====================================================

    function applySettings(settings) {
        if (!settings) return;

        if (
            typeof settings.location ===
            "boolean"
        ) {
            setVisibility({
                visible: settings.location
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
                "[Wienta HUD] HudApp is not ready for LocationHud"
            );

            return;
        }

        window.HudApp.register(
            "location",
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