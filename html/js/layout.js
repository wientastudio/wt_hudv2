const LayoutEditor = (() => {
    const elements = {};

    const state = {
        active: false,
        original: {},
        current: {},
        dragging: null,
        offsetX: 0,
        offsetY: 0
    };

    const movable = [
        "status",
        "playerInfo",
        "vehicle",
        "location",
        "weapon"
    ];

    // =====================================================
    // CACHE
    // =====================================================

    function cacheElements() {
        elements.editor =
            document.getElementById("layoutEditor");

        elements.save =
            document.getElementById("layoutSave");

        elements.cancel =
            document.getElementById("layoutCancel");

        elements.reset =
            document.getElementById("layoutReset");

        elements.hud = {};

        movable.forEach((name) => {
            elements.hud[name] =
                document.querySelector(
                    `[data-hud-element="${name}"]`
                );
        });
    }

    // =====================================================
    // HELPERS
    // =====================================================

    function clone(data) {
        return JSON.parse(
            JSON.stringify(data || {})
        );
    }

    function clamp(value, min, max) {
        return Math.max(
            min,
            Math.min(max, value)
        );
    }

    function normalizePosition(x, y) {
        return {
            x:
                x /
                window.innerWidth,

            y:
                y /
                window.innerHeight
        };
    }

    function denormalizePosition(
        position
    ) {
        return {
            x:
                Number(position?.x || 0) *
                window.innerWidth,

            y:
                Number(position?.y || 0) *
                window.innerHeight
        };
    }

    // =====================================================
    // APPLY POSITION
    // =====================================================

    function applyPosition(
        name,
        position
    ) {
        const element =
            elements.hud[name];

        if (
            !element ||
            !position
        ) {
            return;
        }

        const pixel =
            denormalizePosition(
                position
            );

        element.style.left =
            `${pixel.x}px`;

        element.style.top =
            `${pixel.y}px`;

        element.style.right =
            "auto";

        element.style.bottom =
            "auto";
    }

    function applyPositions(
        positions
    ) {
        if (!positions) {
            return;
        }

        movable.forEach((name) => {
            if (!positions[name]) {
                return;
            }

            applyPosition(
                name,
                positions[name]
            );
        });
    }

    // =====================================================
    // CLEAR CUSTOM POSITIONS
    // =====================================================

    function clearPositions() {
        movable.forEach((name) => {
            const element =
                elements.hud[name];

            if (!element) {
                return;
            }

            element.style.left = "";
            element.style.top = "";
            element.style.right = "";
            element.style.bottom = "";
        });
    }

    // =====================================================
    // DRAG START
    // =====================================================

    function startDrag(
        event,
        name
    ) {
        if (!state.active) {
            return;
        }

        const element =
            elements.hud[name];

        if (!element) {
            return;
        }

        const left =
            element.offsetLeft;

        const top =
            element.offsetTop;

        element.style.left =
            `${left}px`;

        element.style.top =
            `${top}px`;

        element.style.right =
            "auto";

        element.style.bottom =
            "auto";

        state.dragging =
            name;

        state.offsetX =
            event.clientX -
            left;

        state.offsetY =
            event.clientY -
            top;

        element.classList.add(
            "dragging"
        );

        event.preventDefault();
    }

    // =====================================================
    // DRAG MOVE
    // =====================================================

    function drag(event) {
        if (
            !state.active ||
            !state.dragging
        ) {
            return;
        }

        const name =
            state.dragging;

        const element =
            elements.hud[name];

        if (!element) {
            return;
        }

        const rect =
            element.getBoundingClientRect();

        const width =
            element.offsetWidth;

        const height =
            element.offsetHeight;

        const scaleExtraX =
            Math.max(
                0,
                (
                    rect.width -
                    width
                ) / 2
            );

        const scaleExtraY =
            Math.max(
                0,
                (
                    rect.height -
                    height
                ) / 2
            );

        const x =
            clamp(
                event.clientX -
                state.offsetX,

                8 + scaleExtraX,

                window.innerWidth -
                    width -
                    8 -
                    scaleExtraX
            );

        const y =
            clamp(
                event.clientY -
                state.offsetY,

                8 + scaleExtraY,

                window.innerHeight -
                    height -
                    8 -
                    scaleExtraY
            );

        element.style.left =
            `${x}px`;

        element.style.top =
            `${y}px`;

        element.style.right =
            "auto";

        element.style.bottom =
            "auto";

        state.current[name] =
            normalizePosition(
                x,
                y
            );
    }

    // =====================================================
    // DRAG END
    // =====================================================

    function endDrag() {
        if (!state.dragging) {
            return;
        }

        elements.hud[
            state.dragging
        ]?.classList.remove(
            "dragging"
        );

        state.dragging =
            null;
    }

    // =====================================================
    // OPEN
    // =====================================================

    function open(
        positions = {}
    ) {
        if (state.active) {
            return;
        }

        state.active =
            true;

        state.dragging =
            null;

        state.original =
            clone(
                positions
            );

        state.current =
            clone(
                positions
            );

        clearPositions();

        applyPositions(
            state.current
        );

        document.body
            .classList.add(
                "layout-editing"
            );

        elements.editor
            ?.classList.remove(
                "hidden"
            );
    }

    // =====================================================
    // CLOSE
    // =====================================================

    function close() {
        endDrag();

        state.active =
            false;

        document.body
            .classList.remove(
                "layout-editing"
            );

        elements.editor
            ?.classList.add(
                "hidden"
            );
    }

    // =====================================================
    // SAVE
    // =====================================================

    async function save() {
        const result =
            await window.HudApp?.nui(
                "layout:save",
                {
                    positions:
                        state.current
                }
            );

        if (
            result === false
        ) {
            return;
        }

        state.original =
            clone(
                state.current
            );

        close();
    }

    // =====================================================
    // CANCEL
    // =====================================================

    async function cancel() {
        clearPositions();

        applyPositions(
            state.original
        );

        await window.HudApp?.nui(
            "layout:cancel"
        );

        state.current =
            clone(
                state.original
            );

        close();
    }

    // =====================================================
    // RESET
    // =====================================================

    async function reset() {
        const response =
            await window.HudApp?.nui(
                "layout:reset"
            );

        if (
            response === false
        ) {
            return;
        }

        state.current = {};

        clearPositions();
    }

    // =====================================================
    // LOAD
    // =====================================================

    function load(data) {
        if (!data) {
            return;
        }

        const positions =
            data.positions ||
            data;

        if (
            typeof positions !==
            "object"
        ) {
            return;
        }

        clearPositions();

        applyPositions(
            positions
        );
    }

    // =====================================================
    // HUD EVENTS
    // =====================================================

    function bindHudElements() {
        movable.forEach(
            (name) => {
                const element =
                    elements.hud[name];

                if (!element) {
                    return;
                }

                element.addEventListener(
                    "mousedown",
                    (event) => {
                        startDrag(
                            event,
                            name
                        );
                    }
                );
            }
        );
    }

    // =====================================================
    // EVENTS
    // =====================================================

    function bindEvents() {
        bindHudElements();

        document.addEventListener(
            "mousemove",
            drag
        );

        document.addEventListener(
            "mouseup",
            endDrag
        );

        elements.save
            ?.addEventListener(
                "click",
                save
            );

        elements.cancel
            ?.addEventListener(
                "click",
                cancel
            );

        elements.reset
            ?.addEventListener(
                "click",
                reset
            );

        window.addEventListener(
            "resize",
            () => {
                if (
                    !state.active
                ) {
                    return;
                }

                clearPositions();

                applyPositions(
                    state.current
                );
            }
        );

        document.addEventListener(
            "keydown",
            (event) => {
                if (
                    event.key ===
                        "Escape" &&
                    state.active
                ) {
                    cancel();
                }
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
            return;
        }

        window.HudApp.register(
            "layout",
            {
                open,
                load,
                applyPositions
            }
        );
    }

    document.addEventListener(
        "DOMContentLoaded",
        init
    );

    return {
        open,
        load,
        applyPositions
    };
})();