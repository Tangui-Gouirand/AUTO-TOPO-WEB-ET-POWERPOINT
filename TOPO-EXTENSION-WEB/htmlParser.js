export const extractRefRessourceAcces = (htmlAccesInfo) => {
  const docAccesInfo = new DOMParser().parseFromString(htmlAccesInfo, "text/html");
  const linkElements = Array.from(docAccesInfo.querySelectorAll("a")).filter((a) =>
    a.title.includes("ressource acc")
  );
  const refs = ["", ""];
  if (linkElements.length === 0) return refs;

  refs[0] = linkElements[0]?.textContent?.trim() ?? "";
  if (linkElements.length > 1) {
    refs[1] = " secours 4G";
  }
  return refs;
};

export const extractRefInfoService = (htmlAccesInfo) => {
  const docAccesInfo = new DOMParser().parseFromString(htmlAccesInfo, "text/html");
  const linkElements = Array.from(docAccesInfo.querySelectorAll("a")).filter((a) =>
    a.title.includes("Informations sur le service")
  );
  const profils = ["", ""];
  if (linkElements.length > 0) {
    profils[0] = linkElements[0]?.textContent?.trim() ?? "";
  }

  for (const link of linkElements) {
    if (link.parentElement?.nextSibling?.textContent?.trim().includes("INTRANET")) {
      profils[1] = link.textContent.trim();
      break;
    }
  }
  return profils;
};

export const extractTargetData = (htmlFeuillet, htmlDebitetprofitetdebit, refRessourceAcces) => {
    const docDataFeuillet = new DOMParser().parseFromString(htmlFeuillet || '', "text/html");
    const targetTablesNodeList = docDataFeuillet.querySelectorAll("table.Liste");

    let dataProfil = null;
    if (htmlDebitetprofitetdebit) {
        const docDataProfil = new DOMParser().parseFromString(htmlDebitetprofitetdebit, "text/html");
        const labelTd = Array.from(docDataProfil.querySelectorAll("table.Tableau td.info_label"))
                             .find(td => td.textContent.trim() === "TYPSEC");
        if (labelTd) {
            dataProfil = labelTd.parentNode?.querySelector("td.info_value")?.textContent?.trim() ?? null;
        }
    }

    let targetTablesDebit = [];
    if (htmlDebitetprofitetdebit) {
        const docDataDebit = new DOMParser().parseFromString(htmlDebitetprofitetdebit, "text/html");
        targetTablesDebit = docDataDebit.querySelectorAll("table.Tableauinfo");
    }
    
  const defaultReturn = { debit: 'N/A', typeLien: 'N/A', nomSec: 'N/A', profil: dataProfil ?? 'N/A' };
  if (!targetTablesNodeList || targetTablesNodeList.length === 0) return defaultReturn;

  let rows = [];
  targetTablesNodeList.forEach(table => {
    rows.push(...table.querySelectorAll('tr.lf1, tr.lf2'));
  });

  let debitValue = 'N/A';
  let typeLienValue = 'N/A';
  let nomSecValue = 'N/A';
  let CORPOCheckbefore = "";

  if (targetTablesDebit) {
    for (const table of targetTablesDebit) {
      for (const row of table.rows) {
        const cell0Text = row.cells[0]?.textContent?.trim().toUpperCase();
        const cell1Text = row.cells[1]?.textContent?.trim();
        const cell3Text = row.cells[3]?.textContent?.trim().toUpperCase();

        if (cell0Text?.includes("VTSACCEQ")) {
          debitValue = cell1Text ?? 'N/A';

          const regex = /(\d+)[a-zA-Z]$/;
          debitValue = String(debitValue).replace(regex, '$1');

        }
        if (cell3Text?.includes('INTRACORPO')) {
          CORPOCheckbefore = "FTTO";
        }
        if (cell0Text?.includes("FTTE") && cell1Text?.toUpperCase().includes('ACTIF')) {
          typeLienValue = "FTTE";
        }
      }
    }
  }

  let td0ChildTexts = [];
  for (const row of rows) {
    const currenttd0 = row.cells[0];
    if (currenttd0) {
      currenttd0.childNodes.forEach(node => td0ChildTexts.push(node.textContent?.trim()));
    }
    const linkElement = row.cells[1]?.querySelector('a');
    const value = row.cells[2]?.querySelector('b')?.textContent?.trim() ?? 'N/A';

    if (linkElement?.title === 'ROLE') {
      nomSecValue = value;
    } else if (['NATSUPPORT', 'TYPSERV', 'DSLTYPE'].includes(linkElement?.title)) {
      if (!['NON', 'Voisinage', 'Client'].includes(value)) {
        const currentIsFiber = ["FTTH", "FTTO", "FTTE"].includes(typeLienValue);
        if (!typeLienValue || typeLienValue === 'N/A' || !currentIsFiber) {
          typeLienValue = (value === 'Secours4G') ? '4G' : value;
        }
      }
    }
  }
  
  if (!typeLienValue || typeLienValue === 'N/A' || typeLienValue.toUpperCase().includes("FIBRE")) {
    for (const textOfNode of td0ChildTexts) {
      if (textOfNode) {
        const upperText = textOfNode.toUpperCase();
        if (upperText.includes("FIBRE")) {
          typeLienValue = CORPOCheckbefore.toUpperCase().includes("FTTO") ? "FTTO" : "Fibre Optique";
          break;
        } else if (upperText.includes("LIGNE") || upperText.includes("DSL") ) {
          typeLienValue = "Cuivre";
          break;
        }
      }
    }
  }

  if (debitValue === 'N/A') {
    if (['Mobile4G', 'Mobile 4G', '4G', 'Mobile'].includes(typeLienValue)) debitValue = '4G';
    else if (typeLienValue === 'FTTH') debitValue = 'MAX';
  } else if (debitValue === 'Non Garanti') {
    debitValue = 'MAX';
    if (typeLienValue === 'Fibre Optique') typeLienValue = 'FTTH';
  }
  if (debitValue.toUpperCase().includes("FIBRE")) debitValue = 'MAX';

  if (typeLienValue === 'Mobile4G') typeLienValue = '4G';
  else if (['IP ADSL', 'VDSL'].includes(typeLienValue)) typeLienValue = 'Cuivre';

  if (refRessourceAcces[1]) {
    typeLienValue += refRessourceAcces[1];
  }
  return { debit: debitValue, typeLien: typeLienValue, nomSec: nomSecValue, profil: dataProfil ?? 'N/A' };
};