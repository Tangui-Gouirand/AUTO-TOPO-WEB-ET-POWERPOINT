import { checkCookie } from './checkcookie.js';

document.addEventListener('DOMContentLoaded', () => {
    checkCookie() 
    const favoriteStar = document.getElementById('favoriteStar');
    if (favoriteStar){
        favoriteStar.classList.remove('bumping');
    }
    const tableContainer = document.getElementById('tableContentContainer');
    const persistedTableHTML = localStorage.getItem('persistedTableHTML');
    const LOCAL_STORAGE_RESEAUX_FAV = JSON.parse(localStorage.getItem('reseauxFavoris')) || [];
    
    if (persistedTableHTML && tableContainer) {
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = persistedTableHTML;

        const persistedNetworkNameElement = tempDiv.querySelector('.nom_reseau h1');
        const persistedNetworkName = persistedNetworkNameElement ? persistedNetworkNameElement.textContent.trim() : null;

        let contentToLoad = persistedTableHTML;

        if (persistedNetworkName && LOCAL_STORAGE_RESEAUX_FAV.includes(persistedNetworkName)) {
            const savedPageHTML = localStorage.getItem('savedPage_' + persistedNetworkName);
            if (savedPageHTML) {
                contentToLoad = savedPageHTML;
                console.log(`Version sauvegardée du favori '${persistedNetworkName}' chargée.`);
            }
        }
        tableContainer.innerHTML = contentToLoad;
    }

    const script = document.createElement('script');
    script.type = 'module';
    script.src = 'main.js';
    document.body.appendChild(script);
});


async function checkCookieAndShowButton() {
  try {
    const cookie = await chrome.cookies.get({
      url: "https://wasac.rp-ocn.apps.ocn.infra.ftgroup", 
      name: "wasac_session_PROD"
    });
    if (cookie === null || (cookie.expirationDate && cookie.expirationDate * 1000 < Date.now())) {
      console.log("Cookie invalide. Lancement du rafraîchissement cookie en AP.");
      await cookiejs();
      console.log("Rafraîchissement de session terminé. L'application est prête.");
    }
  } catch (error) {
    console.error("Erreur lors de la vérification du cookie :", error);
  }
}