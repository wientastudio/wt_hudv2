const PlayerInfo = (() => {
    const elements = {};

    function cacheElements() {
        elements.root =
            document.getElementById("playerInfo");

        elements.serverName =
            document.getElementById("serverName");

        elements.characterName =
            document.getElementById("characterName");

        elements.playerId =
            document.getElementById("playerId");

        elements.dutyState =
            document.getElementById("dutyState");

        elements.jobName =
            document.getElementById("jobName");

        elements.jobGrade =
            document.getElementById("jobGrade");

        elements.cashBlock =
            document.getElementById("cashBlock");

        elements.cashValue =
            document.getElementById("cashValue");

        elements.bankBlock =
            document.getElementById("bankBlock");

        elements.bankValue =
            document.getElementById("bankValue");

        elements.cryptoBlock =
            document.getElementById("cryptoBlock");

        elements.cryptoValue =
            document.getElementById("cryptoValue");
    }

    // =====================================================
    // HELPERS
    // =====================================================

    function formatMoney(value) {
        const amount =
            Number(value) || 0;

        return `$${amount.toLocaleString("tr-TR")}`;
    }

    function setText(element, value, fallback = "") {
        if (!element) return;

        element.textContent =
            value ?? fallback;
    }

    function setVisible(element, visible) {
        if (!element) return;

        element.style.display =
            visible ? "" : "none";
    }

    // =====================================================
    // ROOT VISIBILITY
    // =====================================================

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
    // DUTY
    // =====================================================

    function updateDuty(duty) {
        if (!elements.dutyState) return;

        const onDuty =
            duty === true;

        elements.dutyState.textContent =
            onDuty
                ? "ON DUTY"
                : "OFF DUTY";

        elements.dutyState.classList.toggle(
            "off-duty",
            !onDuty
        );
    }

    // =====================================================
    // MONEY
    // =====================================================

    function updateMoney(data, visibility) {
        const cashVisible =
            visibility.cash !== false;

        const bankVisible =
            visibility.bank !== false;

        const cryptoVisible =
            visibility.crypto === true;

        setVisible(
            elements.cashBlock,
            cashVisible
        );

        setVisible(
            elements.bankBlock,
            bankVisible
        );

        setVisible(
            elements.cryptoBlock,
            cryptoVisible
        );

        setText(
            elements.cashValue,
            formatMoney(data.cash)
        );

        setText(
            elements.bankValue,
            formatMoney(data.bank)
        );

        setText(
            elements.cryptoValue,
            Number(data.crypto || 0)
                .toLocaleString("tr-TR")
        );

        const visibleCount = [
            cashVisible,
            bankVisible,
            cryptoVisible
        ].filter(Boolean).length;

        elements.root.classList.remove(
            "money-two-columns",
            "money-one-column",
            "no-money"
        );

        if (visibleCount === 2) {
            elements.root.classList.add(
                "money-two-columns"
            );

            return;
        }

        if (visibleCount === 1) {
            elements.root.classList.add(
                "money-one-column"
            );

            return;
        }

        if (visibleCount === 0) {
            elements.root.classList.add(
                "no-money"
            );
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
        // SERVER

        setText(
            elements.serverName,
            data.serverName || "WIENTA ROLEPLAY"
        );

        setVisible(
            elements.serverName,
            visibility.serverName !== false
        );

        // CHARACTER

        setText(
            elements.characterName,
            data.characterName || ""
        );

        setVisible(
            elements.characterName,
            visibility.characterName !== false
        );

        // PLAYER ID

        setText(
            elements.playerId,
            data.playerId ?? "-"
        );

        const playerIdWrapper =
            elements.playerId?.closest(
                ".player-id"
            );

        setVisible(
            playerIdWrapper,
            visibility.playerId !== false
        );

        // DUTY

        updateDuty(data.duty);

        setVisible(
            elements.dutyState,
            visibility.duty !== false
        );

        // JOB

        setText(
            elements.jobName,
            data.job || ""
        );

        setVisible(
            elements.jobName,
            visibility.job !== false
        );

        // GRADE

        setText(
            elements.jobGrade,
            data.jobGrade || ""
        );

        setVisible(
            elements.jobGrade,
            visibility.jobGrade !== false
        );

        const separator =
            elements.root.querySelector(
                ".job-separator"
            );

        if (separator) {
            separator.style.display =
                visibility.job !== false &&
                visibility.jobGrade !== false &&
                data.job &&
                data.jobGrade
                    ? ""
                    : "none";
        }

        // MONEY

        updateMoney(
            data,
            visibility
        );
    }

    // =====================================================
    // INIT
    // =====================================================

    function init() {
        cacheElements();

        if (!window.HudApp) {
            console.error(
                "[Wienta HUD] HudApp is not ready for PlayerInfo"
            );

            return;
        }

        window.HudApp.register(
            "playerInfo",
            {
                update,
                setVisibility
            }
        );
    }

    document.addEventListener(
        "DOMContentLoaded",
        init
    );

    return {
        update,
        setVisibility
    };
})();