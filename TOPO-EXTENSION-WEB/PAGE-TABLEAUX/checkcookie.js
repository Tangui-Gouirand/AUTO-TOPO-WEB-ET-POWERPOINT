import { cookiejs } from '../cookie.js';
export const checkCookie = async () => {
  try {
    const cookie = await chrome.cookies.get({
      url: "https://wasac.rp-ocn.apps.ocn.infra.ftgroup", 
      name: "wasac_session_PROD"
    });
    if (cookie === null || (cookie.expirationDate && cookie.expirationDate * 1000 < Date.now())) {
      console.log("Cookie invalide. Lancement du rafraîchissement cookie en AP.");
      await cookiejs();
      console.log("Rafraîchissement de session terminé. L'application est prête.");
    }
  } catch (error) {
    console.error("Erreur lors de la vérification du cookie :", error);
  }
};
