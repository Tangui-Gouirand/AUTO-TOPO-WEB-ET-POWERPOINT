export function makeTablesSortable() {
  try {
    document.querySelectorAll(".infos-site-debit table").forEach((table) => {
      const headers = table.querySelectorAll("thead th");
      const sortableColumnsConfig = {
        2: { type: "alpha" }, // Ref Routeur
        3: { type: "alpha" }, // Nom SITE
        5: { type: "numeric" }, // DEBIT (M/s)
        6: { type: "alpha" }, // Type lien
      };

      headers.forEach((th, index) => {
        if (sortableColumnsConfig[index]) {
          th.classList.add("sortable");
          if (!th.querySelector(".sort-indicator")) {
            const sortIndicator = document.createElement("span");
            sortIndicator.classList.add("sort-indicator");
            th.appendChild(sortIndicator);
          }
          th.addEventListener("click", () => {
            try {
              sortTableByColumn(
                table,
                index,
                th,
                sortableColumnsConfig[index].type
              );
            } catch (error) {
              console.error(
                `Erreur lors du tri de la colonne ${index}:`,
                error
              );
            }
          });
        }
      });
    });
  } catch (error) {
    console.error("Erreur dans makeTablesSortable:", error);
  }
}


function sortTableByColumn(table, columnIndex, clickedTh, sortType) {
  try {
    const tbody = table.querySelector("tbody");
    if (!tbody) return;
    const rows = Array.from(tbody.querySelectorAll("tr"));
    let currentSortDir = clickedTh.dataset.sortDir;
    const newSortDir = currentSortDir === "asc" ? "desc" : "asc";
    clickedTh.dataset.sortDir = newSortDir;

    table.querySelectorAll("thead th.sortable").forEach((th_loop) => {
      const indicator = th_loop.querySelector(".sort-indicator");
      if (indicator) {
        if (th_loop === clickedTh) {
          indicator.textContent = newSortDir === "asc" ? " ▲" : " ▼";
          indicator.classList.add("trier");
        } else {
          indicator.textContent = "";
          delete th_loop.dataset.sortDir;
          indicator.classList.remove("trier");
        }
      }
    });

    rows.sort((rowA, rowB) => {
      const cellA = rowA.querySelector(`td:nth-child(${columnIndex + 1})`);
      const cellB = rowB.querySelector(`td:nth-child(${columnIndex + 1})`);

      let valA = cellA ? cellA.textContent.trim() : "";
      let valB = cellB ? cellB.textContent.trim() : "";
      let comparison = 0;

      if (sortType === "numeric") {
        const numA = parseFloat(valA);
        const numB = parseFloat(valB);
        const isNumA = !isNaN(numA);
        const isNumB = !isNaN(numB);

        if (isNumA && isNumB) {
          comparison = numA - numB;
        } else if (isNumA) {
          comparison = -1;
        } else if (isNumB) {
          comparison = 1;
        } else {
          comparison = valA.localeCompare(valB);
        }
      } else {
        comparison = valA.localeCompare(valB);
      }
      return newSortDir === "asc" ? comparison : -comparison;
    });

    tbody.innerHTML = "";
    rows.forEach((row) => tbody.appendChild(row));
  } catch (error) {
    console.error("Erreur dans sortTableByColumn:", error);
  }
}