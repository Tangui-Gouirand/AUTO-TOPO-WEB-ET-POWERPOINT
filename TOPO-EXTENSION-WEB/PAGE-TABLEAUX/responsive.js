export function adapterNomsEntetesTableau() {
  try {
    const largeurEcranMax = 1023;
    const estPetitEcran = window.innerWidth < largeurEcranMax;

    document
      .querySelectorAll(".infos-site-debit table thead th")
      .forEach((th) => {
        const texteOriginal = th.dataset.texteOriginal || th.textContent.trim();
        if (!th.dataset.texteOriginal) {
          th.dataset.texteOriginal = texteOriginal;
        }

        if (texteOriginal === "Nominal/Secours") {
          if (estPetitEcran) {
            th.textContent = "Nom/Sec";
          } else {
            th.textContent = "Nominal/Secours";
          }
        }
        if (texteOriginal === "Type lien") {
          if (estPetitEcran) {
            th.textContent = "lien";
          } else {
            th.textContent = "Type lien";
          }
        }
      });
  } catch (error) {
    console.error("Erreur dans adapterNomsEntetesTableau:", error);
  }
}