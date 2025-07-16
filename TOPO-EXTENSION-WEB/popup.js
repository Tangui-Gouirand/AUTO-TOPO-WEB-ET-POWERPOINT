import { fetchAndDisplaySuggestions } from './suggestions.js';
import { checkIdInput } from './checkid.js';
import { updateLoading } from './loading.js';
import { optimizedExtractAndProcessTable } from './tableProcessor.js';
import { fetchInitialRouterList } from './wasacApiService.js';
import { checkForUpdates } from './updater.js';
import { cookiejs } from './cookie.js';

async function checkCookieAndShowButton() {
  const ouvrirButton = document.getElementById('ouvrir');
  try {
    const cookie = await chrome.cookies.get({
      url: "https://wasac.rp-ocn.apps.ocn.infra.ftgroup", 
      name: "wasac_session_PROD"
    });
    if (cookie === null || (cookie.expirationDate && cookie.expirationDate * 1000 < Date.now())) {
      console.log("Cookie invalide. Lancement du rafraîchissement cookie en AP.");
      
      ouvrirButton.classList.add('noncliquable');
      ouvrirButton.textContent = 'Session en cours de rafraîchissement...';

      await cookiejs();

      ouvrirButton.classList.remove('noncliquable');
      ouvrirButton.textContent = 'Ouvrir Tableau';
      console.log("Rafraîchissement de session terminé. L'application est prête.");
    }
  } catch (error) {
    console.error("Erreur lors de la vérification du cookie :", error);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  checkCookieAndShowButton();
  checkForUpdates();
  const idInput = document.getElementById('id');
  const ouvrirButton = document.getElementById('ouvrir');
  const loadingMessage = document.getElementById('loading-message');
  let validationTimeout;
  let idReseauGlobal = null;

  const suggestionsDiv = document.createElement("div");
  suggestionsDiv.classList.add("suggestions");
  idInput.parentNode.appendChild(suggestionsDiv);
  suggestionsDiv.style.display = "none";
  let  inputValue = "";
  idInput.addEventListener("input", (event) => {
    inputValue = event.target.value;
    clearTimeout(validationTimeout);
    fetchAndDisplaySuggestions(inputValue, (text) => {
      inputValue = text;
      console.log(inputValue);
      clearTimeout(validationTimeout);
      (async () => {
        const result = await checkIdInput(inputValue, false);
        idReseauGlobal = result || null;
      })();
    });
    validationTimeout = setTimeout(async () => {
      console.log(inputValue);
      const result = await checkIdInput(inputValue, false);
      idReseauGlobal = result || null;
    }, 500);
  });

ouvrirButton.addEventListener('click', async () => {
    const createNewPage = () => {
        window.open(chrome.runtime.getURL('PAGE-TABLEAUX/tableaux.html'));
    };
    if (!idReseauGlobal) {
      alert('Entrez un réseau.');
      return;
    }
    loadingMessage.style.display = 'block';
    updateLoading(5, 'Initialisation ...');
    
    const baseUrl = 'https://wasac.rp-ocn.apps.ocn.infra.ftgroup/perl/wasac-new/';
    const urlListeRouteurs = `${baseUrl}wasac_liste_routeurs.cgi?offre=&id_reseau=${idReseauGlobal}&cmd=listing_etendu&service=PROD_RE&cssLight=1&appli=PROD_RE`;

    try {
      updateLoading(10, 'Récupération de la liste des routeurs...');
      const html = await fetchInitialRouterList(urlListeRouteurs);
      
      const tableHTML = await optimizedExtractAndProcessTable(baseUrl, idReseauGlobal, html, updateLoading, inputValue );

      updateLoading(95, 'Préparation de l\'affichage...');
      localStorage.setItem('persistedTableHTML', tableHTML);

      createNewPage();
      updateLoading(100, 'Affichage terminé');

    } catch (error) {
      console.error(error);
      alert('Erreur durant le traitement.');
      updateLoading(0, 'Erreur', true);
    } finally {
      setTimeout(() => {
        loadingMessage.style.display = 'none';
      }, 500);
    }
  });
});