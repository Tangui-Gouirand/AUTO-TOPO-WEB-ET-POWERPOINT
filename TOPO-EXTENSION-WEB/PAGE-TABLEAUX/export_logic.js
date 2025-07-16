import { formatDataToConfigFile, getAllCheckedRowsData, downloadTextFile } from './exporttab.js';
let networkNameH1 = document.querySelector('.nom_reseau h1').textContent.trim().toUpperCase();

function initializeModeToggle() {
    const mode1Radio = document.getElementById("mode1");
    const mode2Radio = document.getElementById("mode2");
    const tabMode1 = document.querySelector(".TabMode1");
    const tabMode2 = document.querySelector(".TabMode2");

    const updateTabVisibility = () => {
        if (!mode1Radio || !tabMode1 || !tabMode2) return;
        tabMode1.style.display = mode1Radio.checked ? "block" : "none";
        tabMode2.style.display = mode1Radio.checked ? "none" : "block";
    };

    if(mode1Radio) mode1Radio.addEventListener("change", updateTabVisibility);
    if(mode2Radio) mode2Radio.addEventListener("change", updateTabVisibility);
    updateTabVisibility();
}

function initializeConfigExport() {
    document.querySelector(".count-debits-btn")?.addEventListener("click", () => {
        const allCheckedRowsData = getAllCheckedRowsData();
        if (allCheckedRowsData.length > 0) {
            const text = formatDataToConfigFile(allCheckedRowsData);
            downloadTextFile(text, `${networkNameH1}_.txt`);
            
        } else {
            alert("Aucune ligne sélectionnée dans aucun tableau.");
        }
    });
}

function initializePngExport() {
    const exportPngBtn = document.querySelector(".export-png-btn");
    exportPngBtn?.addEventListener("click", async () => {
        const originalText = exportPngBtn.textContent;
        exportPngBtn.textContent = "Génération en cours...";
        exportPngBtn.disabled = true;

        const tablesToExport = Array.from(document.querySelectorAll('.infos-site-debit'))
            .filter(container => container.querySelector('tbody .row-selector:checked:not(:disabled)'));

        if (tablesToExport.length === 0) {
            alert("Aucune ligne sélectionnée à exporter.");
            exportPngBtn.textContent = originalText;
            exportPngBtn.disabled = false;
            return;
        }

        for (const [index, tableContainer] of tablesToExport.entries()) {
            const h2 = tableContainer.querySelector("h2");
            const tableName = h2?.textContent.trim() || `Tableau_${index + 1}`;
            const clone = tableContainer.cloneNode(true);
            
            clone.style.position = 'absolute';
            clone.style.left = '-9999px';
            document.body.appendChild(clone);
            
            Array.from(clone.querySelectorAll('tbody tr')).forEach(row => {
                const cb = row.querySelector('.row-selector');
                if (!cb || !cb.checked || row.classList.contains('hidden')) row.remove();
            });

            clone.querySelectorAll('th:first-child, td:first-child, th:nth-child(2), td:nth-child(2)').forEach(cell => cell.style.display = 'none');
            await html2canvas(clone, { scale: 2 }).then(canvas => {
                const a = document.createElement('a');
                a.href = canvas.toDataURL("image/png");
                a.download = `${networkNameH1}_${tableName.replace(/[^a-zA-Z0-9]/g, '_')}.png`;
                a.click();
            });

            document.body.removeChild(clone);
        }

        exportPngBtn.textContent = originalText;
        exportPngBtn.disabled = false;
    });
}

export function initializeExportLogic() {
    initializeModeToggle();
    document.querySelector(".export-ppt-btn")?.addEventListener("click", () => {
        const sectionPPT = document.querySelector(".sectionppt");
        if(sectionPPT) sectionPPT.style.display = sectionPPT.style.display === "block" ? "none" : "block";
    });
    initializeConfigExport();
    initializePngExport();
}