import { RefreshOneLine } from './Refresh.js';

function handleSelectAllChange() {
    const container = this.closest('.infos-site-debit');
    if (container) {
        const table = container.querySelector('table');
        if (table) {
            table.querySelectorAll(".row-selector").forEach(checkbox => {
                if (!checkbox.closest('tr').classList.contains('hidden')) {
                    checkbox.checked = this.checked;
                }
            });
        }
    }
}

function handleRowCheckboxChange() {
    const container = this.closest('.infos-site-debit');
    if (container) {
        const table = container.querySelector("table");
        const selectAll = container.querySelector(".select-all");

        if (table && selectAll) {
            const visibleCheckboxes = Array.from(table.querySelectorAll(".row-selector"))
                                           .filter(cb => !cb.closest('tr').classList.contains('hidden'));
            const allVisibleChecked = visibleCheckboxes.length > 0 && visibleCheckboxes.every(cb => cb.checked);
            selectAll.checked = allVisibleChecked;
        }
    }
}

export function attachSelectAllAndRowCheckListeners() {
    document.querySelectorAll(".select-all").forEach(selectAll => {
        selectAll.removeEventListener("change", handleSelectAllChange);
        selectAll.addEventListener("change", handleSelectAllChange);
    });
    document.querySelectorAll(".row-selector").forEach(rowCheckbox => {
        rowCheckbox.removeEventListener("change", handleRowCheckboxChange);
        rowCheckbox.addEventListener("change", handleRowCheckboxChange);
    });
}

function initializeVisibilityFilters() {
    document.querySelectorAll('.menu input[type="checkbox"]').forEach(checkbox => {
        checkbox.addEventListener("change", function () {
            document.querySelectorAll("." + this.value).forEach(element => {
                element.classList.toggle("hidden", !this.checked);
                const rowCheckbox = element.querySelector('.row-selector');
                if (rowCheckbox) {
                    rowCheckbox.checked = false;
                    rowCheckbox.disabled = !this.checked;
                }
            });
        });
    });
}

function handleSatinToggle() {
    this.classList.toggle("active");
    document.querySelectorAll("tr.listeheader th:nth-child(8), .tdSatin").forEach(el => {
        el.classList.toggle("tdinvisible");
    });
}

function initializeSatinToggle() {
    const satinButton = document.querySelector(".REFSATIN");
    if (satinButton) {
        const satinColumnExample = document.querySelector(".tdSatin");
        if (satinColumnExample && !satinColumnExample.classList.contains("tdinvisible")) {
            satinButton.classList.add("active");
        } else {
            satinButton.classList.remove("active");
        }
        satinButton.removeEventListener("click", handleSatinToggle);
        satinButton.addEventListener("click", handleSatinToggle);
    }
}

function handleRowRefresh() {
    const icon = this;
    const row = icon.closest('tr');
    if (!row) return;

    icon.classList.add('fa-spin');

    const idReseau = document.querySelector('.nom_reseau')?.id;
    const refRouteur = row.cells[2]?.textContent?.trim();

    if (!idReseau || !refRouteur) {
        console.error("Impossible de trouver l'ID du réseau ou la référence du routeur.");
        icon.classList.remove('fa-spin');
        return;
    }

    RefreshOneLine(idReseau, refRouteur).then(newData => {
        if (newData) {
            row.cells[4].textContent = newData.nomSec;
            row.cells[5].textContent = newData.debit;
            row.cells[6].textContent = newData.typeLien;
            row.cells[7].textContent = newData.RefSatin;
            row.cells[8].textContent = newData.profil;
            
            row.classList.remove('rien', 'PARC', 'RESILIATION', 'ANNULATION', 'CARNET')
            row.classList.add(newData.infoparc)

            document.dispatchEvent(new CustomEvent('rowRefreshed', {
                bubbles: true
            }));

            row.classList.add('row-refreshed');
            setTimeout(() => row.classList.remove('row-refreshed'), 1500);
        } else {
            alert(`Erreur lors du rafraîchissement de la ligne pour ${refRouteur}.`);
        }
    }).finally(() => {
        icon.classList.remove('fa-spin');
    });
}

export function attachRowRefreshListeners() {
    document.querySelectorAll(".refresh-row-btn").forEach(button => {
        button.addEventListener('click', handleRowRefresh);
    });
}

export function initializeTableInteractions() {
    attachSelectAllAndRowCheckListeners();
    initializeVisibilityFilters();
    initializeSatinToggle();
    attachRowRefreshListeners();
}