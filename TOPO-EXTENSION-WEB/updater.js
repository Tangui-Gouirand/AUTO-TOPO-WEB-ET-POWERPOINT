const compareVersions = (v1, v2) => {
  const parts1 = v1.split('.').map(Number);
  const parts2 = v2.split('.').map(Number);
  const len = Math.max(parts1.length, parts2.length);

  for (let i = 0; i < len; i++) {
    const p1 = parts1[i] || 0;
    const p2 = parts2[i] || 0;
    if (p1 > p2) return 1;
    if (p1 < p2) return -1;
  }
  return 0;
};

const displayUpdateButton = (url, currentVersion, latestVersion) => {
    const container = document.querySelector('.d-grid.gap-2');
    if (!container || document.querySelector('.update-button') || document.querySelector('.version-info')) return;

    const updateButton = document.createElement('a');
    updateButton.href = url;
    updateButton.target = '_blank';
    updateButton.textContent = 'Mise à jour disponible';
    updateButton.classList.add('btn', 'btn-success', 'mt-2', 'update-button');
    
    const versionInfoText = document.createElement('p');
    versionInfoText.textContent = `Actuelle : v${currentVersion} | Disponible : v${latestVersion}`;
    versionInfoText.classList.add('version-info');
    
    container.appendChild(updateButton);
    container.appendChild(versionInfoText);
};

export const checkForUpdates = async () => {
  const versionUrl = "https://raw.githubusercontent.com/Tangui-Gouirand/TOPO/main/version.json";


  try {
    const response = await fetch(versionUrl, { cache: "no-store" });
    if (!response.ok) {
        throw new Error(`Erreur réseau: ${response.status}`);
    }
    const latestVersionInfo = await response.json();
    
    const currentVersion = chrome.runtime.getManifest().version;
    const latestVersion = latestVersionInfo.version;

    if (compareVersions(latestVersion, currentVersion) > 0) {
      // Cas 1 : Une mise à jour est disponible
      displayUpdateButton(latestVersionInfo.url, currentVersion, latestVersion);
    } else {
      // Cas 2 : L'extension est à jour
      const container = document.querySelector('.d-grid.gap-2');
      if (!container || container.querySelector('.version-info')) return;
      
      const versionInfoText = document.createElement('p');
      versionInfoText.textContent = "Vous avez la dernière version d'installée.";
      versionInfoText.classList.add('version-info');
      container.appendChild(versionInfoText);
    }

  } catch (error) {
    // Cas 3 : Erreur lors de la vérification
    console.error("Erreur lors de la vérification de la mise à jour:", error);
    
    const currentVersion = chrome.runtime.getManifest().version;
    const container = document.querySelector('.d-grid.gap-2');
    
    if (!container || container.querySelector('.version-info')) return;
    
    const versionInfoText = document.createElement('p');
    versionInfoText.textContent = `Actuelle : v${currentVersion} | Disponible : N/A`;
    versionInfoText.classList.add('version-info');
    
    container.appendChild(versionInfoText);
  }
};