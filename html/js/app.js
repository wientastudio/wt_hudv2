const HudApp = (() => {
    const modules = {};
    let nuiReadySent = false;

    function register(name, module) {
        if (!name || !module) return;

        modules[name] = module;
    }

    function getModule(name) {
        return modules[name];
    }

    function emit(name, method, data) {
        const module = modules[name];

        if (!module) return;
        if (typeof module[method] !== "function") return;

        module[method](data);
    }

    function setHudVisibility(data) {
        const root = document.getElementById("hudRoot");

        if (!root) return;

        const visible = data?.visible === true;

        root.classList.toggle("is-hidden", !visible);
    }

    function resetHud() {
        document
            .querySelectorAll(".hud-element")
            .forEach((element) => {
                element.classList.add("is-hidden");
            });
    }

    function handleInit(data) {
        const root = document.documentElement;

        if (data?.config?.accent) {
            root.style.setProperty(
                "--accent",
                data.config.accent
            );
        }

        if (data?.config?.scale) {
            root.style.setProperty(
                "--hud-scale",
                data.config.scale
            );
        }

        emit(
            "settings",
            "applyInitial",
            data?.config || {}
        );

        setHudVisibility({
            visible: data?.visible !== false
        });

        setTimeout(() => {
    document.body.classList.add(
        "nui-ready"
    );
}, 100);
    }

    function handleCinematic(data) {
        const enabled = data?.enabled === true;
        const blackBars = data?.blackBars === true;

        document.body.classList.toggle(
            "cinematic-active",
            enabled && blackBars
        );
    }


function handleMinimapVisibility(data) {
    document.body.classList.toggle(
        "minimap-visible",
        data?.visible === true
    );
}

    function handleMessage(event) {
        const message = event.data;

        if (!message || typeof message !== "object") {
            return;
        }

        const action = message.action;
        const data = message.data;

        switch (action) {
            case "hud:init":
                handleInit(data);
                break;

            case "hud:visibility":
                setHudVisibility(data);
                break;

            case "hud:reset":
                resetHud();
                break;

            case "layout:load":
    emit(
        "layout",
        "load",
        data
    );
    break;    

            case "playerInfo:update":
                emit(
                    "playerInfo",
                    "update",
                    data
                );
                break;

            case "playerInfo:visibility":
                emit(
                    "playerInfo",
                    "setVisibility",
                    data
                );
                break;

            case "status:update":
                emit(
                    "status",
                    "update",
                    data
                );
                break;

            case "status:visibility":
                emit(
                    "status",
                    "setVisibility",
                    data
                );
                break;

            case "vehicle:update":
                emit(
                    "vehicle",
                    "update",
                    data
                );
                break;

case "vehicle:visibility":
    emit(
        "vehicle",
        "setVisibility",
        data
    );

    document.body.classList.toggle(
        "vehicle-active",
        data?.visible === true
    );
    break;

            case "location:update":
                emit(
                    "location",
                    "update",
                    data
                );
                break;

case "location:visibility":
    emit(
        "location",
        "setVisibility",
        data
    );
    break;

case "minimap:visibility":
    handleMinimapVisibility(data);
    break;

case "voice:update":
                emit(
                    "voice",
                    "update",
                    data
                );
                break;

            case "voice:visibility":
                emit(
                    "voice",
                    "setVisibility",
                    data
                );
                break;

            case "weapon:update":
                emit(
                    "weapon",
                    "update",
                    data
                );
                break;

            case "weapon:visibility":
                emit(
                    "weapon",
                    "setVisibility",
                    data
                );
                break;

            case "cinematic:update":
                handleCinematic(data);
                break;

            case "settings:open":
                emit(
                    "settings",
                    "open",
                    data
                );
                break;

            case "settings:close":
                emit(
                    "settings",
                    "close"
                );
                break;

            case "settings:apply":
                emit(
                    "settings",
                    "apply",
                    data
                );
                break;

            case "settings:preview":
                emit(
                    "settings",
                    "preview",
                    data
                );
                break;

            case "settings:reset":
                emit(
                    "settings",
                    "reset",
                    data
                );
                break;

            default:
                break;
        }
    }

    async function nui(name, data = {}) {
        const resource =
            typeof GetParentResourceName === "function"
                ? GetParentResourceName()
                : "wienta_hud";

        try {
            const response = await fetch(
                `https://${resource}/${name}`,
                {
                    method: "POST",

                    headers: {
                        "Content-Type":
                            "application/json; charset=UTF-8"
                    },

                    body: JSON.stringify(data)
                }
            );

            const text = await response.text();

            if (!text) {
                return null;
            }

            try {
                return JSON.parse(text);
            } catch {
                return text;
            }
        } catch (error) {
            console.error(
                `[Wienta HUD] NUI callback failed: ${name}`,
                error
            );

            return null;
        }
    }

    function sendReady() {
        if (nuiReadySent) return;

        nuiReadySent = true;

        nui("ready");
    }

    function init() {
        window.addEventListener(
            "message",
            handleMessage
        );

const queueReady = () => {
    setTimeout(
        sendReady,
        0
    );
};

document.addEventListener(
    "DOMContentLoaded",
    queueReady,
    {
        once: true
    }
);

if (
    document.readyState === "interactive" ||
    document.readyState === "complete"
) {
    queueReady();
}
    }

    init();

    return {
        register,
        getModule,
        nui
    };
})();

window.HudApp = HudApp;