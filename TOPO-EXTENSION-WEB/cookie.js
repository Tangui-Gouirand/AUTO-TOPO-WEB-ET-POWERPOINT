const OFFSCREEN_DOCUMENT_PATH = 'offscreen.html';

async function hasOffscreenDocument() {
    if ('getContexts' in chrome.runtime) {
        const contexts = await chrome.runtime.getContexts({
            contextTypes: ['OFFSCREEN_DOCUMENT'],
            documentUrls: [chrome.runtime.getURL(OFFSCREEN_DOCUMENT_PATH)]
        });
        return contexts.length > 0;
    } else {
        const clients = await clients.matchAll();
        return clients.some(client => client.url.endsWith(OFFSCREEN_DOCUMENT_PATH));
    }
}

async function setupOffscreenDocument() {
    if (await hasOffscreenDocument()) {
        return;
    }
    
    await chrome.offscreen.createDocument({
        url: OFFSCREEN_DOCUMENT_PATH,
        reasons: ['IFRAME_SCRIPTING'],
        justification: 'Rafraîchir le cookie SSO dans un iframe invisible.',
    });
}

export const cookiejs = async () => {
    return new Promise(async (resolve) => {
        await setupOffscreenDocument();
        const checkInterval = setInterval(async () => {
            if (!(await hasOffscreenDocument())) {
                clearInterval(checkInterval);
                resolve();
            }
        }, 3500);
    });
};