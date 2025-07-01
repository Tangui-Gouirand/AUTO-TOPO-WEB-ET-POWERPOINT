const mode1Radio = document.getElementById("mode1");
const mode2Radio = document.getElementById("mode2");
let networkNameH1 = document.querySelector('.nom_reseau h1').textContent.trim().toUpperCase();

function createSiteInfoString(row) {
    const nomSite = row.nomSite?.trim() || "N/A";
    if (row.typeLien === 'FTTH secours 4G') {
        row.typeLien = "FTTH4G";
    } else if (row.typeLien === 'Cuivre secours 4G') {
        row.typeLien = "Cuivre";
    }

    const nomSiteComplet = (row.Satin && row.Satin.trim() !== "N/A") ? `${nomSite} ${row.Satin}` : nomSite;
    
    return `${nomSiteComplet} * ${row.NomSec} * ${row.refRouteur} * ${row.typeLien}`;
}

export function formatDataToConfigFile(tablesData) {
    try {
        const lines = [`NomClient : ${networkNameH1}`];
        lines.push(`NombreTableaux : ${tablesData.length}`);

        tablesData.forEach((table, tableIndex) => {
            const tableauIndex = tableIndex + 1;
            lines.push(`Tab&${tableauIndex}&Nom&offre : ${table.tableName}`);

            if (mode1Radio.checked) {
                const debitsGrouped = table.rows.reduce((acc, row) => {
                    const debit = row.debit || "N/A";
                    if (!acc[debit]) {
                        acc[debit] = [];
                    }
                    acc[debit].push(row);
                    return acc;
                }, {});

                const sortedDebits = Object.keys(debitsGrouped).sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
                lines.push(`Tab&${tableauIndex}&Nombre&DEBITS : ${sortedDebits.length}`);

                sortedDebits.forEach((debitValue, debitIndex) => {
                    const debitGroup = debitsGrouped[debitValue];
                    const currentDebitNumber = debitIndex + 1;
                    lines.push(`Tab&${tableauIndex}&Nombre&Site&DEBIT&${currentDebitNumber} : ${debitGroup.length}`);

                    if (/^\d+$/.test(debitValue)) {
                        debitValue += " Mb/s";
                    }
                    lines.push(`Tab&${tableauIndex}&Valeur&DEBIT&${currentDebitNumber} : ${debitValue}`);

                    debitGroup.forEach((row, rowInGroupIndex) => {
                        const siteIndex = rowInGroupIndex + 1;
                        const siteInfo = createSiteInfoString(row);
                        lines.push(`Tab&${tableauIndex}&SITE&${siteIndex}&DEBIT&${currentDebitNumber} : ${siteInfo}`);
                    });
                });

            } else {
                lines.push(`Tab&${tableauIndex}&Nombre&DEBITS : ${table.debitCount || 1}`);
                lines.push(`Tab&${tableauIndex}&Nombre&Site&DEBIT&1 : ${table.rows.length}`);
                
                const valeurDebit = table.rows.length > 0 ? table.rows[0].debit : "N/A";
                lines.push(`Tab&${tableauIndex}&Valeur&DEBIT&1 : ${valeurDebit}`);

                table.rows.forEach((row, rowIndex) => {
                    const siteIndex = rowIndex + 1;
                    const siteInfo = createSiteInfoString(row);
                    lines.push(`Tab&${tableauIndex}&SITE&${siteIndex}&DEBIT&1 : ${siteInfo}`);
                });
            }
        });

        return lines.join(';\n') + ';';

    } catch (error) {
        console.error("Erreur dans formatDataToConfigFile:", error);
        return "";
    }
}

function extractRowData(row) {
    const isSatinHidden = row.cells[7]?.classList.contains('tdinvisible');

    return {
        refRouteur: row.cells[2]?.textContent ?? "N/A",
        nomSite: row.cells[3]?.textContent ?? "N/A",
        NomSec: row.cells[4]?.textContent ?? "N/A",
        debit: row.cells[5]?.textContent ?? "N/A",
        typeLien: row.cells[6]?.textContent ?? "N/A",
        Satin: isSatinHidden ? "N/A" : (row.cells[7]?.textContent ?? "N/A"),
    };
}

export function getAllCheckedRowsData() {
    try {
        const tablesData = [];
        const tableContainers = document.querySelectorAll(".infos-site-debit");

        tableContainers.forEach((container, tableIndex) => {
            const h2Element = container.querySelector("h2");
            const tableNameElement = h2Element?.querySelector("label") || h2Element;
            const tableName = tableNameElement?.textContent.trim() || `Tableau ${tableIndex + 1}`;

            const checkedRows = container.querySelectorAll("tbody .row-selector:checked");
            if (checkedRows.length === 0) return; 

            const allRowsData = Array.from(checkedRows).map(cb => extractRowData(cb.closest("tr")));

            let currentTableData = {
                tableName,
                rows: [],
                debitCount: 1
            };

            allRowsData.forEach((rowData, index) => {
                const isFull = currentTableData.rows.length === 18;
                const debitChanged = mode2Radio.checked && index > 0 && rowData.debit !== allRowsData[index - 1].debit;
                
                if (isFull || debitChanged) {
                    tablesData.push(currentTableData);
                    currentTableData = { tableName, rows: [], debitCount: 1 };
                }

                currentTableData.rows.push(rowData);
            });
            
            if (currentTableData.rows.length > 0) {
                tablesData.push(currentTableData);
            }
        });
        return tablesData;
    } catch (error) {
        console.error("Erreur dans getAllCheckedRowsData:", error);
        return [];
    }
}

export function downloadTextFile(text, filename) {
    try {
        const blob = new Blob([text], { type: 'text/plain;charset=utf-8,' });
        const url = URL.createObjectURL(blob);
        const element = document.createElement("a");
        element.setAttribute("href", url);
        element.setAttribute("download", filename);
        element.style.display = "none";
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
        URL.revokeObjectURL(url);
    } catch (error) {
        console.error("Erreur lors du téléchargement du fichier texte:", error);
    }
}