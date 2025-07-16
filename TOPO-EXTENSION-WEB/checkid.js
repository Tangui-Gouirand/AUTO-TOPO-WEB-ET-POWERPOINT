let ouvrirButton = document.getElementById('ouvrir');
let isCurrentlyValidating = false;

const fetchIdReseau = async (url, parseFunction) => {
  try {
    const response = await fetch(url);
    if (!response.ok) throw new Error(`HTTP ${response.status} pour l'URL: ${url}`);
    const html = await response.text();
    return parseFunction(html);
  } catch (error) {
    console.error(`Erreur lors de la requête à l'URL ${url}:`, error);
    return null;
  }
};

export const checkIdInput = async (idValue) => {
  if (isCurrentlyValidating) return;
  isCurrentlyValidating = true;

  const idInput = document.getElementById('id');
  idInput.classList.remove('input-error', 'input-ok');
  if (!idValue) {
    isCurrentlyValidating = false;
    return;
  }

  let idReseau = null;

  // Première tentative
  idReseau = await fetchIdReseau(
    `https://wasac.rp-ocn.apps.ocn.infra.ftgroup/perl/wasac-new/wasac_page.cgi?service=PROD_RE&nom_reseau=${idValue}`,
    (html) => {
      const doc = new DOMParser().parseFromString(html, 'text/html');
      const frame = doc.querySelector('FRAME');
      return (frame && /id_reseau=([1-9][0-9]*)/.test(frame.src)) ? RegExp.$1 : null;
    }
  );

  // Deuxième tentative si la première a échoué
  if (!idReseau) {
    idReseau = await fetchIdReseau(
      `https://wasac.rp-ocn.apps.ocn.infra.ftgroup/perl/wasac-new/wasac_recherche_routeur.cgi?network=${idValue}&service=SCAO&cmd=perform_search`,
      (html) => {
        const doc = new DOMParser().parseFromString(html, 'text/html');
        const linkElements = doc.querySelectorAll('a[onclick]');
        for (const link of linkElements) {
          const onclickAttribute = link.getAttribute('onclick');
          if (onclickAttribute) {
            const match = onclickAttribute.match(/id_reseau=([1-9][0-9]*)/);
            if (match && match[1]) {
              return match[1];
            }
          }
        }
        return null;
      }
    );
  }

  if (idReseau) {
    idInput.classList.add('input-ok');
    ouvrirButton.classList.remove('noncliquable');
  } else {
    idInput.classList.add('input-error');
    ouvrirButton.classList.add('noncliquable');
  }

  isCurrentlyValidating = false;
  return idReseau;
};