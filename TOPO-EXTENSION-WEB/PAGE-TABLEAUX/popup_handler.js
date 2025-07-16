export function initializePopupHandlers() {
    const popupContainer = document.createElement("div");
    popupContainer.classList.add("popup-container");
    document.body.appendChild(popupContainer);

    const menu = document.querySelector(".menu");
    const gestionConfig = document.querySelector(".GestionConfig");
    const sectionPPT = document.querySelector(".sectionppt");

    const addCloseButton = (popupElement) => {
        if (!popupElement) return null;
        const closeButton = document.createElement("div");
        closeButton.classList.add("close-button");
        popupElement.insertBefore(closeButton, popupElement.firstChild);
        return closeButton;
    };
    
    const menuCloseButton = addCloseButton(menu);
    const configCloseButton = addCloseButton(gestionConfig);

    const closePopup = () => {
        if(sectionPPT) sectionPPT.style.display = "none";
        popupContainer.style.display = "none";
        document.body.appendChild(menu);
        document.body.appendChild(gestionConfig);
        menu.style.display = "none";
        gestionConfig.style.display = "none";
    };

    document.getElementById("menu-btn")?.addEventListener("click", () => {
        popupContainer.style.display = "flex";
        popupContainer.appendChild(menu);
        menu.style.display = "flex";
    });

    document.getElementById("config-btn")?.addEventListener("click", () => {
        popupContainer.style.display = "flex";
        popupContainer.appendChild(gestionConfig);
        gestionConfig.style.display = "flex";
    });

    popupContainer.addEventListener("click", (e) => {
        if (e.target === popupContainer) closePopup();
    });

    if (menuCloseButton) menuCloseButton.addEventListener("click", closePopup);
    if (configCloseButton) configCloseButton.addEventListener("click", closePopup);
}