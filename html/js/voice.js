const VoiceHud = (() => {
    const elements = {};

    function cacheElements() {
        elements.root =
            document.getElementById("voiceHud");

        elements.mic =
            document.getElementById("voiceMic");

        elements.range =
            document.getElementById("voiceRange");

        elements.radioInfo =
            document.getElementById("radioInfo");

        elements.radioChannel =
            document.getElementById("radioChannel");
    }

    function setVisibility(data) {
        if (!elements.root) return;

        elements.root.classList.toggle(
            "is-hidden",
            data?.visible === false
        );
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

        if (elements.range) {
            elements.range.textContent =
                String(
                    data.rangeLabel ||
                    data.range ||
                    "NORMAL"
                ).toUpperCase();

            elements.range.style.display =
                visibility.range !== false
                    ? ""
                    : "none";
        }

        if (elements.mic) {
            elements.mic.classList.toggle(
                "talking",
                data.talking === true
            );

            elements.mic.style.display =
                visibility.talking !== false
                    ? ""
                    : "none";
        }

        const showRadio =
            visibility.radioChannel !== false &&
            Number(data.radioChannel) > 0;

        if (elements.radioInfo) {
            elements.radioInfo.style.display =
                showRadio ? "" : "none";

            elements.radioInfo.classList.toggle(
                "transmitting",
                data.radioTalking === true
            );
        }

        if (elements.radioChannel) {
            elements.radioChannel.textContent =
                data.radioChannel ?? 0;
        }
    }

    function applySettings(settings) {
        if (
            typeof settings?.voice ===
            "boolean"
        ) {
            setVisibility({
                visible: settings.voice
            });
        }
    }

    function init() {
        cacheElements();

        if (!window.HudApp) return;

        window.HudApp.register(
            "voice",
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