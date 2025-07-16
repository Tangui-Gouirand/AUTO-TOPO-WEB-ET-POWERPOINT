const CORPORATE_PROFIL_LOOKUP = {
  'DUALLOADBA': 'CORPORATE DUAL LOAD BALLANCING',
  'DUALBACKUP': 'CORPORATE DUALBACKUP',
  'ALWAYSONOF': 'CORPORATE ALWAYS-ON OFFLOAD',
  'ALWAYSON': 'CORPORATE ALWAYS-ON',
  'AO4GM2M': 'CORPORATE ALWAYS-ON 4G'
};

const SMALL_PROFIL_LOOKUP = {
  'DUALLOADBA': 'SMALL DUAL LOAD BALLANCING',
  'DUALBACKUP': 'SMALL DUALBACKUP',
  'ALWAYSONOF': 'SMALL ALWAYS-ON OFFLOAD',
  'ALWAYSON': 'SMALL ALWAYS-ON',
  'AO4GM2M': 'SMALL ALWAYS-ON 4G'
};

const MOBILE_PROFIL_LOOKUP = {
  'DUALLOADBA': 'MOBILE DUAL LOAD BALLANCING',
  'DUALBACKUP': 'MOBILE DUALBACKUP',
  'ALWAYSONOF': 'MOBILE ALWAYS-ON OFFLOAD',
  'ALWAYSON': 'MOBILE ALWAYS-ON',
  'AO4GM2M': 'MOBILE ALWAYS-ON 4G'
};

const getProfilAndLink = (profilGet, lien, type) => {
  let profil = "";
  let updatedLien = lien;
  if (type === 'CORPORATE') {
    profil = CORPORATE_PROFIL_LOOKUP[profilGet] || "CORPORATE";
  } else if (type === 'SMALL') {
    profil = SMALL_PROFIL_LOOKUP[profilGet] || "SMALL";
  }

  //if (profilGet === "AO4GM2M") {
  //  updatedLien += " secours 4G";
  //}
  return [updatedLien, profil];
};

export const ProfilCuivreCheck = async (htmlAccesInfo, PROFILGET) => {
  const docAccesInfo = new DOMParser().parseFromString(htmlAccesInfo, 'text/html');
  const links = docAccesInfo.querySelectorAll('a');
  for (const link of links) {
    if (link.title.includes('Informations sur le service')) {
      const parentTd = link.parentElement.parentElement;
      if (parentTd && parentTd.textContent.includes('CORPORATE')) {
        return CORPORATE_PROFIL_LOOKUP[PROFILGET] || "CORPORATE";
      } else if (parentTd && parentTd.textContent.includes('SMALL')) {
        return SMALL_PROFIL_LOOKUP[PROFILGET] || "SMALL";
      }
    }
  }
  return null;
}

export const CorporateFibreCheck = async (htmlAccesInfo, idReseau, PROFILGET, LIEN) => {
  if (LIEN.includes("FTTO")) {
    return getProfilAndLink(PROFILGET, LIEN, 'CORPORATE');
  } else if (LIEN.includes("FTTE")) {
    return getProfilAndLink(PROFILGET, LIEN, 'CORPORATE');
  } else if (LIEN.includes("FTTH")) {
    return getProfilAndLink(PROFILGET, LIEN, 'SMALL');
  }

  const docAccesInfo = new DOMParser().parseFromString(htmlAccesInfo, 'text/html');
  const links = docAccesInfo.querySelectorAll('a');
  for (const link of links) {
    if (link.title.includes('Informations sur le service')) {
      const parentTd = link.parentElement.parentElement;
      if (parentTd && parentTd.textContent.includes("CORPORATE")) {
        for (const lien of links) {
          if (lien.title.includes("Aller sur le service")) {
            const linkElements = [...docAccesInfo.querySelectorAll("a")].filter(
              (a) => a.title.includes("ller sur le service")
            );
            const CDServiceUsine = linkElements[0]?.textContent?.trim() || "";
            const baseUrl =
              "https://wasac.rp-ocn.apps.ocn.infra.ftgroup/perl/wasac-new/";
            const URLCDServiceUsine = `${baseUrl}wasac_synth_service.cgi?cmd=&service=PROD_RE&id_reseau=${idReseau}&num_svc=${CDServiceUsine}`;
            const res1 = await fetch(URLCDServiceUsine);
            const html1 = await res1.text();
            const doc1 = new DOMParser().parseFromString(html1, "text/html");
            const contentSynthSvc = doc1
              .querySelector("#content_Synth_svc")
              ?.textContent?.trim();
            if (contentSynthSvc) {
              if (contentSynthSvc.includes("FTTO")) {
                return getProfilAndLink(PROFILGET, "FTTO", 'CORPORATE');
              } else if (contentSynthSvc.includes("FTTE")) {
                return getProfilAndLink(PROFILGET, "FTTE", 'CORPORATE');
              } else {
                return getProfilAndLink(PROFILGET, "Fibre Optique", 'CORPORATE');
              }
            }
          }
        }
      } else if (parentTd && parentTd.textContent.includes("SMALL")) {
        let [updatedLien, profil] = getProfilAndLink(PROFILGET, "FTTH", 'SMALL');
        if (PROFILGET === "AO4GM2M") {
          updatedLien = "FTTH secours 4G";
        } else {
          updatedLien = "FTTH";
        }
        return [updatedLien, profil];
      }
    }
  }
  return null;
}

export const MobileCheck = async (htmlAccesInfo, idReseau, PROFILGET, LIEN) => {
  const docAccesInfo = new DOMParser().parseFromString(htmlAccesInfo, 'text/html');
  const links = docAccesInfo.querySelectorAll('a');
  for (const link of links) {
    if (link.title.includes('Informations sur le service')) {
      const parentTd = link.parentElement.parentElement;
      if (parentTd && parentTd.textContent.includes('CORPORATE')) {
        return CORPORATE_PROFIL_LOOKUP[PROFILGET] || "CORPORATE";
      } else if (parentTd && parentTd.textContent.includes('SMALL')) {
        return SMALL_PROFIL_LOOKUP[PROFILGET] || "SMALL";
      }
    }
  }
  return null;
}