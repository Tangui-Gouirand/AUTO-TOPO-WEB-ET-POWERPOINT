const FINAL_COOKIE_URL = "https://wasac.rp-ocn.apps.ocn.infra.ftgroup";
const FINAL_COOKIE_NAME = "wasac_session_PROD";
const SSO_URL = 'https://wasac.sso.infra.ftgroup/perl/wasac-new/loginsso.cgi';

const iframe = document.createElement('iframe');
iframe.src = SSO_URL;
document.body.appendChild(iframe);

let checkInterval;
let fallbackTimeout;

const cleanupAndClose = (message) => {
    console.log(message);
    clearInterval(checkInterval);
    clearTimeout(fallbackTimeout);
    window.close();
};

fallbackTimeout = setTimeout(() => {
    cleanupAndClose("Le document offscreen a dépassé le délai de 15 secondes et va se fermer.");
}, 15000);

const checkForFinalCookie = async () => {
    try {
        const cookie = await chrome.cookies.get({
            url: FINAL_COOKIE_URL,
            name: FINAL_COOKIE_NAME
        });

        if (cookie && (!cookie.expirationDate || cookie.expirationDate * 1000 > Date.now())) {
            cleanupAndClose("Cookie de session final détecté. Le rafraîchissement est terminé.");
        } else {
            console.log("En attente du cookie de session final...");
        }
    } catch (error) {
        console.error("Erreur lors de la vérification du cookie dans le document offscreen :", error);
    }
};

setTimeout(() => {
    checkInterval = setInterval(checkForFinalCookie, 2000);
}, 3000);