import { fetchAccesInfo,fetchINFOCEDRE, fetchDataFeuillet } from './wasacApiService.js';
import { extractRefRessourceAcces, extractRefInfoService, extractTargetData } from './htmlParser.js';
import { ProfilCuivreCheck, CorporateFibreCheck, MobileCheck} from './ProfilCheck.js';

const cleanTable = (table) => {
  table.classList.add("table", "table-bordered", "table-striped", "table-hover", "table-sm");
  const thead = table.querySelector("thead");
  if (thead) {
    thead.classList.add("thead-dark");
    const headerRows = thead.querySelectorAll("tr.listeheader");
    for (let i = 0; i < headerRows.length - 1; i++) {
      headerRows[i].remove();
    }
  }
};

const cleanRowCells = (row) => {
  for (let i = row.cells.length - 1; i >= 0; i--) {
    if (i !== 1 && i !== 2) {
      row.deleteCell(i);
    }
  }
  row.querySelectorAll("img").forEach((img) => img.remove());
};

const createHeaderCells = (row, headers) => {
  row.innerHTML = '';
  headers.forEach((headerText) => {
    const th = document.createElement("th");
    th.textContent = headerText;
    row.appendChild(th);
    if (headerText === 'Ref Satin') {
      th.classList.add("tdinvisible"); 
    }
  });
};

export async function optimizedExtractAndProcessTable(baseUrl, idReseau, html, updateLoadingCallback, inputValue) {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const table = doc.querySelector('table.Liste');

  if (!table) {
    console.error('Le tableau avec la classe "Liste" n\'a pas été trouvé.');
    alert('Erreur : Le tableau de données n\'a pas été trouvé sur la page.');
    return "";
  }
  
  const allRows = Array.from(table.rows);
  const headerRow = allRows.find(row => row.classList.contains('listeheader'));
  const dataRows = allRows.filter(row => row.classList.contains('lf1') || row.classList.contains('lf2'));

  dataRows.forEach(row => {
    const cell13Content = row.cells[13]?.textContent?.trim().toUpperCase();

    if (cell13Content) {
      if (cell13Content.includes('RESILIATION')) {
        row.classList.add('RESILIATION');
      }else if (cell13Content.includes('ANNULATION') || cell13Content.includes('ANNULE')) {
        row.classList.add('ANNULATION');
      }else if (cell13Content.includes('CARNET')) {
        row.classList.add('CARNET');
      } else if (cell13Content.includes('PARC')) {
        row.classList.add('PARC');
      } else row.classList.add('rien');
    } else {
      row.classList.add('rien');
    }
  });

  updateLoadingCallback(15, 'Préparation des données pour l\'analyse...');
  cleanTable(table);

  if (headerRow) {
    cleanRowCells(headerRow);
    const newHeaderTexts = ['', '', 'Ref Routeur', 'Nom SITE', 'Nominal/Secours', 'DEBIT (M/s)', 'Type lien', 'Ref Satin'];
    createHeaderCells(headerRow, newHeaderTexts);
  }

  const idInputValue = document.getElementById('id')?.value ?? "";

  const startProgress = 15;
  const endProgress = 90;
  const progressRange = endProgress - startProgress;

  const promises = dataRows.map(async (row, index, array) => {

    const baseProgress = startProgress + (index / array.length) * progressRange;
    const progressPerRouter = progressRange / array.length;

    cleanRowCells(row);

    const refRouteur = row.cells[0]?.textContent?.trim() ?? "";
    let nomSite = "";
    //row.cells[1]?.textContent?.trim() ?? "";

    const refreshCell = document.createElement('td');
    const refreshIcon = document.createElement('i');
    refreshIcon.className = 'fas fa-sync-alt refresh-row-btn';
    refreshIcon.title = 'Rafraîchir cette ligne';
    refreshCell.appendChild(refreshIcon);
    row.insertBefore(refreshCell, row.firstChild);

    const checkboxCell = document.createElement('td');
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.classList.add('row-selector');
    checkboxCell.appendChild(checkbox);
    row.insertBefore(checkboxCell, row.cells[1]);




    const linkElement = row.cells[2]?.querySelector('a');
    if (linkElement) {
      const relativeHref = linkElement.getAttribute('href');
      if (relativeHref) {
        const absoluteHref = baseUrl.replace('/perl/wasac-new/', '') + relativeHref;
        linkElement.setAttribute('href', absoluteHref);
        linkElement.setAttribute('target', '_blank');
      }
    }

    let dataFeuillet = { debit: "N/A", typeLien: "N/A", nomSec: "N/A", profil: "N/A", RefSatin :"N/A" };

    const htmlAccesInfo = await fetchAccesInfo(refRouteur, baseUrl, idReseau);
    const htmlCedre = await fetchINFOCEDRE(refRouteur, baseUrl, idReseau)

    const docCedre = new DOMParser().parseFromString(htmlCedre, "text/html");
    const tousLesLabels = Array.from(docCedre.querySelectorAll("div.label"));

    const labelNomSite = tousLesLabels.find(
      (div) => div.textContent.trim() === "Nom du site"
    );

    if (labelNomSite) {
      const valeurEtatRouteurElement = labelNomSite.nextElementSibling;
      if (valeurEtatRouteurElement && valeurEtatRouteurElement.classList.contains('value')) {
        nomSite = valeurEtatRouteurElement.textContent;

        const texteARetirer = inputValue.trim().toUpperCase(); 
        nomSite = nomSite.replace(texteARetirer, ''); 
        //nomSite = nomSite.replace(/(?:(?:_|-)?[sSnN]|sec|nom|nlb|slb|slb1|nominal|4G)$/, '');
        nomSite = nomSite.replace("4G", '');
        if (row.cells[3]) {
          row.cells[3].textContent = nomSite;
        }
      }
    }


    if (htmlAccesInfo) {
      const refRessourceAcces = extractRefRessourceAcces(htmlAccesInfo);
      const refInfoService = extractRefInfoService(htmlAccesInfo);

      updateLoadingCallback((baseProgress + progressPerRouter) * 0.8, `Routeur (${index + 1}/${array.length}) : Récupération des données...`);
      const { feuillet: htmlFeuillet, profitetdebit: htmlDebitetprofitetdebit } = await fetchDataFeuillet(baseUrl, refRessourceAcces, refInfoService);
      
      if (htmlFeuillet) {
        dataFeuillet = extractTargetData(htmlFeuillet, htmlDebitetprofitetdebit, refRessourceAcces);
      }

      updateLoadingCallback((baseProgress + progressPerRouter) * 1, `Routeur (${index + 1}/${array.length}) : Analyse des données...`);
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
        if (dataFeuillet.profil === 'STD4G'){
          dataFeuillet.profil = 'MOBILE 4G';
        }else if (dataFeuillet.profil === 'ALWAYSON4G') {
          dataFeuillet.profil = 'Mobile ALWAYS-ON 4G';
        }
      }else if (dataFeuillet.typeLien === '4G' && dataFeuillet.nomSec === 'Secours') {
        const MobileCheckResult = await MobileCheck(htmlAccesInfo, idReseau, dataFeuillet.profil, dataFeuillet.typeLien);
        if (MobileCheckResult) dataFeuillet.profil = MobileCheckResult;
      }
      dataFeuillet.RefSatin = refInfoService[1] ?? "N/A";
    }
    return { row, dataFeuillet };
  });

  updateLoadingCallback(startProgress, `Lancement de l'analyse des ${dataRows.length} routeurs...`);

  const results = await Promise.all(promises);
  const groupedRows = {};

  results.forEach(({ row, dataFeuillet }) => {
    const newCellsData = [dataFeuillet.nomSec, dataFeuillet.debit, dataFeuillet.typeLien];
    newCellsData.forEach(text => {
      const newTd = document.createElement('td');
      newTd.textContent = text;
      row.appendChild(newTd);
    });
    const cinquiemeThList = document.querySelectorAll("tr.listeheader th:nth-child(7)");
    if (cinquiemeThList) {
        cinquiemeThList.forEach((thcinq) => {
            thcinq.classList.add("tdinvisible");
        });
    }

    const newTdSatin = document.createElement('td');
    newTdSatin.textContent = dataFeuillet.RefSatin;
    newTdSatin.classList.add("tdSatin", "tdinvisible");
    row.appendChild(newTdSatin);  

    const newTdProfil = document.createElement('td');
    newTdProfil.textContent = dataFeuillet.profil;
    newTdProfil.classList.add("tdinvisible");
    row.appendChild(newTdProfil);

    const rowData = {
      html: row.outerHTML,
      debit: dataFeuillet.debit,
      nomSite: row.cells[2]?.textContent?.trim() ?? ""
    };

    groupedRows[dataFeuillet.profil] = groupedRows[dataFeuillet.profil] ?? [];
    groupedRows[dataFeuillet.profil].push(rowData);
  });

  let finalTablesHTML = '';
  const sortedProfilKeys = Object.keys(groupedRows).sort((a, b) => a.localeCompare(b));
  finalTablesHTML += `
  <div class="nom_reseau" id="${idReseau}">
  <i class="fa fa-refresh" title="Rafraîchir tous les tableaux";></i>
  <i id="favoriteStar" class="fa-solid fa-star"></i>
  <H1>${inputValue}</H1>
  </div>
  <div id="loading-message" class="mt-3">
    Chargement en cours...
    <div class="progress mt-2">
      <div class="progress-bar progress-bar-striped progress-bar-animated progress-bar-width" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" aria-label="Loading progress"></div>
    </div>
    <div id="loading-step" class="mt-2"></div>
  </div>
  `;
  for (const profil of sortedProfilKeys) {
    groupedRows[profil].sort((a, b) => {
      const debitA = parseFloat(a.debit);
      const debitB = parseFloat(b.debit);
      const nomSiteA = a.nomSite;
      const nomSiteB = b.nomSite;

      if (!isNaN(debitA) && !isNaN(debitB)) {
        if (debitA !== debitB) return debitA - debitB;
      } else if (!isNaN(debitA)) return -1;
      else if (!isNaN(debitB)) return 1;
      else {
        const debitStringA = String(a.debit).toUpperCase();
        const debitStringB = String(b.debit).toUpperCase();
        if (debitStringA === 'MAX' && debitStringB !== 'MAX') return -1;
        if (debitStringA !== 'MAX' && debitStringB === 'MAX') return 1;
        if (debitStringA === '4G' && debitStringB !== '4G') return -1;
        if (debitStringA !== '4G' && debitStringB === '4G') return 1;
        const debitCompare = debitStringA.localeCompare(debitStringB);
        if (debitCompare !== 0) return debitCompare;
      }
      return nomSiteA.localeCompare(nomSiteB);
    });

    const sortedRowsHTML = groupedRows[profil].map(rowData => rowData.html).join('');
    const tableId = `table-${profil.replace(/[\s/:()]/g, '')}`;
    finalTablesHTML += `
      <div class="infos-site-debit">
        <h2>
          <input type="checkbox" id="select-all-${tableId}" class="select-all" data-table-id="${tableId}">
          <label for="select-all-${tableId}">${profil}</label>
        </h2>
        <table class="table table-bordered table-striped table-hover table-sm" id="${tableId}">
          <thead>
            ${headerRow ? headerRow.outerHTML : ''}
          </thead>
          <tbody>
            ${sortedRowsHTML}
          </tbody>
        </table>
      </div>`;
  }
  finalTablesHTML = finalTablesHTML.replace(/[\n\r]/g, " ");
  return finalTablesHTML;
}