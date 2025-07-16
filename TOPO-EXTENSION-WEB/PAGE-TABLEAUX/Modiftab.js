function createTextInput(value, placeholder) {
    const input = document.createElement("input");
    input.type = "text";
    input.value = value;
    input.placeholder = placeholder;
    return input;
}

function createSelect(options, selectedValue) {
    const select = document.createElement("select");
    options.forEach(optionText => {
        const option = document.createElement("option");
        option.value = optionText;
        option.textContent = optionText;
        if (optionText === selectedValue) {
            option.selected = true;
        }
        select.appendChild(option);
    });
    return select;
}

const inputConfig = {
    "Nominal/Secours": (text) => createSelect(["Nominal", "Secours", "N/A"], text),
    "Nom/Sec": (text) => createSelect(["Nominal", "Secours", "N/A"], text),
    "Type lien": (text) => createSelect(["Cuivre", "4G", "FTTO", "FTTE", "FTTH", "FTTH secours 4G", "N/A"], text),
    "lien": (text) => createSelect(["Cuivre", "4G", "FTTO", "FTTE", "FTTH", "FTTH secours 4G", "N/A"], text),
    "DEBIT (M/s)": (text) => createTextInput(text, "Entrez le débit"),
    "Profil": (text) => createTextInput(text, "Entrez le profil"),
};

export function handleCellClick() {
    const cell = this;
    cell.classList.add("editable-cell");

    if (cell.querySelector("input, select")) {
        return;
    }

    const originalText = cell.textContent.trim();
    let inputElement;

    if (cell.tagName === 'H1') {
        inputElement = createTextInput(originalText, "Entrez le nom du réseau");
    } else {
        if (cell.cellIndex === 0 || cell.cellIndex === 1 || cell.cellIndex === 2) {
            return;
        }

        const table = cell.closest("table");
        const headerCell = table?.querySelector(`th:nth-child(${cell.cellIndex + 1})`);
        const columnHeader = headerCell?.textContent.trim();

        const creationFunction = inputConfig[columnHeader];

        if (creationFunction) {
            inputElement = creationFunction(originalText);
        } else {
            inputElement = createTextInput(originalText, "Entrez le texte");
        }
    }
    
    if (!inputElement) return;

    cell.textContent = "";
    cell.appendChild(inputElement);
    inputElement.focus();

    const finishEditing = () => {
        const newValue = inputElement.value.trim();
        cell.textContent = newValue;
        console.log("Étape 1 : Modification terminée. Envoi de l'événement 'cellEdited'.");

        document.dispatchEvent(new CustomEvent('cellEdited', {
            bubbles: true,
            detail: {
                element: cell,
                oldValue: originalText,
                newValue: newValue,
            }
        }));
    };

    inputElement.addEventListener("blur", finishEditing);
    inputElement.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
            inputElement.blur();
        }
    });
}

export function attachEditableCellListeners() {
    document.querySelectorAll(".table td, .nom_reseau h1").forEach((cell) => {
        cell.removeEventListener("click", handleCellClick);
        cell.addEventListener("click", handleCellClick);
    });
}