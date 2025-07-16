import { updateLoading } from "../loading.js";
import { fetchInitialRouterList } from "../wasacApiService.js";
import { optimizedExtractAndProcessTable } from "../tableProcessor.js";

import { fetchAccesInfo, fetchDataFeuillet } from "../wasacApiService.js";
import { extractRefRessourceAcces, extractRefInfoService, extractTargetData } from '../htmlParser.js';
import { ProfilCuivreCheck, CorporateFibreCheck, MobileCheck} from '../ProfilCheck.js';

import { checkCookie } from './checkcookie.js';


let loadingMessage = document.getElementById("loading-message");

export async function Refreshalltab(idReseau, inputValue) {
  await checkCookie();
  loadingMessage = document.getElementById("loading-message");
  loadingMessage.style.display = "block";
  updateLoading(5, "Initialisation ...");

  const baseUrl = "https://wasac.rp-ocn.apps.ocn.infra.ftgroup/perl/wasac-new/";
  const urlListeRouteurs = `${baseUrl}wasac_liste_routeurs.cgi?offre=&id_reseau=${idReseau}&cmd=listing_etendu&service=PROD_RE&cssLight=1&appli=PROD_RE`;

  try {
    updateLoading(10, "Récupération de la liste des routeurs...");
    const html = await fetchInitialRouterList(urlListeRouteurs);
    const tableHTML = await optimizedExtractAndProcessTable(baseUrl,idReseau,html,updateLoading,inputValue);

    updateLoading(95, "Préparation de l'affichage...");
    updateLoading(100, "Affichage terminé");
    loadingMessage.style.display = "none";
    updateLoading(0, "");
    localStorage.setItem("persistedTableHTML", tableHTML);
    let contentToLoad = tableHTML;
    let pageFoundInFavorites = false;
    const LOCAL_STORAGE_RESEAUX_FAV = JSON.parse(localStorage.getItem('reseauxFavoris')) || [];
    if (inputValue && LOCAL_STORAGE_RESEAUX_FAV.includes(inputValue)) {
            const savedPageHTML = localStorage.getItem('savedPage_' + inputValue);
            if (savedPageHTML) {
                contentToLoad = savedPageHTML;
                pageFoundInFavorites = true;
                return `${tableHTML}`;
            }
        }
  } catch (error) {
    console.error(error);
    alert("Erreur durant le traitement.");
    updateLoading(0, "Erreur", true);
    loadingMessage.style.display = "none";
  }
}


export async function RefreshOneLine(idReseau, refRouteur) {
  await checkCookie();
  const baseUrl = 'https://wasac.rp-ocn.apps.ocn.infra.ftgroup/perl/wasac-new/';
  let dataFeuillet = { debit: "N/A", typeLien: "N/A", nomSec: "N/A", profil: "N/A", RefSatin :"N/A", infoparc :"N/A"};

  try {
      const htmlAccesInfo = await fetchAccesInfo(refRouteur, baseUrl, idReseau);
      if (htmlAccesInfo) {
        const refRessourceAcces = extractRefRessourceAcces(htmlAccesInfo);
        const refInfoService = extractRefInfoService(htmlAccesInfo);

      const { feuillet: htmlFeuillet, profitetdebit: htmlDebitetprofitetdebit } = await fetchDataFeuillet(baseUrl, refRessourceAcces, refInfoService);
      
      if (htmlFeuillet) {
        dataFeuillet = extractTargetData(htmlFeuillet, htmlDebitetprofitetdebit, refRessourceAcces);
      }

        const docAccesInfo = new DOMParser().parseFromString(htmlAccesInfo, "text/html");
        const boldElements = Array.from(docAccesInfo.querySelectorAll("b"));
        let status = "rien"; // Valeur par défaut

        const etatRouteurElement = boldElements.find(
            (b) => b.textContent.trim() === "Etat routeur"
        );

        if (etatRouteurElement) {
            const statusCell = etatRouteurElement.parentElement.nextElementSibling;
            if (statusCell) {
              if (statusCell.textContent.trim().toUpperCase().includes('RESILIATION')){
                dataFeuillet.infoparc = "RESILIATION"
              }else if (statusCell.textContent.trim().toUpperCase().includes('ANNULATION') || statusCell.textContent.trim().toUpperCase().includes('ANNULE')){
                dataFeuillet.infoparc = "ANNULATION"
              }else if (statusCell.textContent.trim().toUpperCase().includes('CARNET')){
                dataFeuillet.infoparc = "CARNET"
              }else if (statusCell.textContent.trim().toUpperCase().includes('PARC')){
                dataFeuillet.infoparc = "PARC"
              }else {
                dataFeuillet.infoparc = "rien"
              }
            }
        }

        const typeLienUpper = dataFeuillet.typeLien.toUpperCase();
        if (typeLienUpper.includes('FIBRE') || ['FTTE', 'FTTO', 'FTTH'].some(ft => typeLienUpper.includes(ft))) {
            const fibreCheckResult = await CorporateFibreCheck(htmlAccesInfo, idReseau, dataFeuillet.profil, dataFeuillet.typeLien);
            if (fibreCheckResult?.length === 2) {
                [dataFeuillet.typeLien, dataFeuillet.profil] = fibreCheckResult;
            }
        } else if (dataFeuillet.typeLien.includes('Cuivre')) {
            const profilCuivre = await ProfilCuivreCheck(htmlAccesInfo, dataFeuillet.profil);
            if (profilCuivre) dataFeuillet.profil = profilCuivre;
        } else if (dataFeuillet.typeLien === '4G' && dataFeuillet.nomSec === 'Nominal') {
             if (dataFeuillet.profil === 'STD4G'){ dataFeuillet.profil = 'MOBILE 4G'; }
             else if (dataFeuillet.profil === 'ALWAYSON4G') { dataFeuillet.profil = 'Mobile ALWAYS-ON 4G'; }
        } else if (dataFeuillet.typeLien === '4G' && dataFeuillet.nomSec === 'Secours') {
            const MobileCheckResult = await MobileCheck(htmlAccesInfo, idReseau, dataFeuillet.profil, dataFeuillet.typeLien);
            if (MobileCheckResult) dataFeuillet.profil = MobileCheckResult;
        }
        dataFeuillet.RefSatin = refInfoService[1] ?? "N/A";
      }
      return dataFeuillet; 
  } catch (error) {
    console.error(`Erreur lors du rafraîchissement de la ligne pour ${refRouteur}:`, error);
    return null;
  }
}