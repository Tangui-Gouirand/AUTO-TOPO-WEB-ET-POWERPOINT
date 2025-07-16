export const fetchInitialRouterList = async (url) => {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`Erreur HTTP ${response.status}`);
    }
    return await response.text();
};

//pour récuperer num Ressource Acces et Num service commercial
export const fetchAccesInfo = async (refRouteur, baseUrl, idReseau) => {
  const urlAccesInfo = `${baseUrl}wasac_synth_routeur.cgi?cmd=&service=PROD_RE&id_reseau=${idReseau}&nom_reseau=&offre=&feuillet=${refRouteur}`;
  try {
    const responseAccesInfo = await fetch(urlAccesInfo);
    if (!responseAccesInfo.ok) {
      console.error(`Erreur HTTP lors de la récupération des infos d'accès pour ${refRouteur}: ${responseAccesInfo.status}`);
      return null;
    }
    return await responseAccesInfo.text();
  } catch (error) {
    console.error(`Erreur lors de la requête Fetch pour les infos d'accès de ${refRouteur}:`, error);
    return null;
  }
};

//pour recuperer le nom du site
export const fetchINFOCEDRE = async (refRouteur, baseUrl, idReseau) => {
  const urlCedre = `https://cedre-https.sso.infra.ftgroup/ICedre/GuardianAuthServlet?action=view&codeApp=ICEDRE&actionCode=icedre&idObjet=${refRouteur}`;
  try {
    const responseAccesInfo = await fetch(urlCedre);
    if (!responseAccesInfo.ok) {
      console.error(`Erreur HTTP lors de la récupération des infos d'accès pour ${refRouteur}: ${responseAccesInfo.status}`);
      return null;
    }
    return await responseAccesInfo.text();
  } catch (error) {
    console.error(`Erreur lors de la requête Fetch pour les infos d'accès de ${refRouteur}:`, error);
    return null;
  }
};

export const fetchDataFeuillet = async (baseUrl, refRessourceAcces, refInfoService) => {
  const fetchedHtml = {
    feuillet: null,
    profil: null,
    debit: null,
  };

  try {
    if (refRessourceAcces?.[0]) {
      
      const urlDataFeuillet = `${baseUrl}affiche_data.cgi?data=affiche_feuillet&feuillet=${refRessourceAcces[0]}&from_appli=`;
      const responseDataFeuillet = await fetch(urlDataFeuillet);
      if (responseDataFeuillet.ok) {
        fetchedHtml.feuillet = await responseDataFeuillet.text();
      } else {
        console.error(`Erreur HTTP pour ${refRessourceAcces[0]}: ${responseDataFeuillet.status}`);
      }
    }

    /* 
    if (refInfoService?.[0]) {
      const urlProfil = `${baseUrl}affiche_data.cgi?data=affiche_SATIN&service_satin=${refInfoService[0]}&from_appli=`;
      const responseDataProfil = await fetch(urlProfil);
      if (responseDataProfil.ok) {
        fetchedHtml.profil = await responseDataProfil.text();
      } else {
        console.error(`Erreur HTTP pour profil ${refInfoService[0]}: ${responseDataProfil.status}`);
      }
    }
      */

    if (refInfoService?.[1]) {
      const urlDebit = `${baseUrl}affiche_data.cgi?data=affiche_SATIN&service_satin=${refInfoService[1]}&from_appli=`;
      const responseUrlDebit = await fetch(urlDebit);
      if (responseUrlDebit.ok) {
        fetchedHtml.profitetdebit = await responseUrlDebit.text();
      } else {
        console.error(`Erreur HTTP pour débit ${refInfoService[1]}: ${responseUrlDebit.status}`);
      }
    }
    return fetchedHtml;
  } catch (error) {
    console.error(`Erreur lors de la récupération des données pour ${refRessourceAcces[0]}:`, error);
    return fetchedHtml;
  }
};