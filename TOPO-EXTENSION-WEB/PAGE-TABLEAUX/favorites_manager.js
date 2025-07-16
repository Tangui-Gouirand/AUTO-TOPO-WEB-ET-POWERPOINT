import { makeTablesSortable } from './Triertab.js';
import { adapterNomsEntetesTableau } from './responsive.js';
import { attachEditableCellListeners } from './Modiftab.js';
import { initializeTableInteractions } from './table_interactions.js';
import { Refreshalltab } from './Refresh.js';

const LOCAL_STORAGE_SAVED_PAGE_PREFIX = 'savedPage_';
let LOCAL_STORAGE_RESEAUX_FAV = JSON.parse(localStorage.getItem('reseauxFavoris')) || [];
const navigationFav = document.querySelector('.navigation-fav');

function saveCurrentPageContent(networkName) {
    const tableContainer = document.getElementById('tableContentContainer');
    if (tableContainer && networkName) {
        const clone = tableContainer.cloneNode(true);
        clone.querySelectorAll('.glitter').forEach(el => el.remove());
        
        const clonedStar = clone.querySelector('#favoriteStar');
        if (clonedStar) {
            clonedStar.classList.remove('bumping');
        }
        clone.querySelectorAll('.fa-spin').forEach(el => el.classList.remove('fa-spin'));
        localStorage.setItem(LOCAL_STORAGE_SAVED_PAGE_PREFIX + networkName, clone.innerHTML);
    }
}

function removeSavedPageContent(networkName) {
    if (networkName) {
        localStorage.removeItem(LOCAL_STORAGE_SAVED_PAGE_PREFIX + networkName);
    }
}

function createGlitterExplosion(element) {
    const container = element.closest('.favorite-container');
    if (!container) return;
    const fragment = document.createDocumentFragment();
    for (let i = 0; i < 20; i++) {
        const glitter = document.createElement('div');
        glitter.classList.add('glitter');
        const angle = Math.random() * 2 * Math.PI;
        const distance = Math.random() * 50 + 20;
        glitter.style.setProperty('--x', `${Math.cos(angle) * distance}px`);
        glitter.style.setProperty('--y', `${Math.sin(angle) * distance}px`);
        fragment.appendChild(glitter);
        setTimeout(() => glitter.remove(), 700);
    }
    container.appendChild(fragment);
}

export function displayFavoriteTablesInNav() {
    navigationFav.innerHTML = '';
    const currentNetworkName = document.querySelector('.nom_reseau h1')?.textContent.trim();

    if (LOCAL_STORAGE_RESEAUX_FAV.length === 0) {
        navigationFav.innerHTML = `<span class="no-favorites-message">Aucun favori. Cliquez sur une étoile pour en ajouter.</span>`;
        return;
    }

    LOCAL_STORAGE_RESEAUX_FAV.forEach(networkName => {
        const favoriteLink = document.createElement('a');
        favoriteLink.href = "#";
        favoriteLink.textContent = networkName;
        favoriteLink.classList.add('favorite-link');
        if (networkName === currentNetworkName) {
            favoriteLink.classList.add('active');
        }

        favoriteLink.addEventListener("click", (e) => {
            e.preventDefault();
            const clickedNetworkName = e.target.textContent.trim();
            const displayedNetworkName = document.querySelector('.nom_reseau h1')?.textContent.trim();
            if (displayedNetworkName !== clickedNetworkName) {
                const savedPageHTML = localStorage.getItem(LOCAL_STORAGE_SAVED_PAGE_PREFIX + clickedNetworkName);
                if (savedPageHTML) {
                    document.getElementById("tableContentContainer").innerHTML = savedPageHTML;
                    makeTablesSortable();
                    adapterNomsEntetesTableau();
                    attachEditableCellListeners();
                    initializeTableInteractions();
                    initializeFavoriteManagement();
                }
            }
        });
        navigationFav.appendChild(favoriteLink);
    });
}

function handleRowRefreshmentSave() {
    const favoriteStar = document.getElementById('favoriteStar');

    if (favoriteStar && favoriteStar.classList.contains('checked')) {
        const networkNameH1 = document.querySelector('.nom_reseau h1');
        const currentNetworkName = networkNameH1 ? networkNameH1.textContent.trim() : null;
        if (currentNetworkName) {
            saveCurrentPageContent(currentNetworkName);
        }
    }
}

function handleCellModification(e) {
    const { element, oldValue, newValue } = e.detail;
    if (oldValue === newValue) return;
    const favoriteStar = document.getElementById('favoriteStar');
    if (!favoriteStar) return;
    if (element.tagName === 'H1') {
        const newNetworkName = newValue;
        const oldNetworkName = oldValue;
        if (LOCAL_STORAGE_RESEAUX_FAV.includes(newNetworkName)) {
            element.textContent = oldNetworkName;
            return;
        }
        const isFavorite = favoriteStar.classList.contains('checked');
        if (isFavorite) {
            removeSavedPageContent(oldNetworkName);
            const index = LOCAL_STORAGE_RESEAUX_FAV.indexOf(oldNetworkName);
            if (index > -1) {
                LOCAL_STORAGE_RESEAUX_FAV.splice(index, 1, newNetworkName);
            }
            localStorage.setItem('reseauxFavoris', JSON.stringify(LOCAL_STORAGE_RESEAUX_FAV));
            saveCurrentPageContent(newNetworkName);
            displayFavoriteTablesInNav();
        }
    } else {
        const isFavorite = favoriteStar.classList.contains('checked');
        if (isFavorite) {
            const networkNameH1 = document.querySelector('.nom_reseau h1');
            const currentNetworkName = networkNameH1 ? networkNameH1.textContent.trim() : null;
            saveCurrentPageContent(currentNetworkName);
        }
    }
}

document.addEventListener('cellEdited', handleCellModification);
document.addEventListener('rowRefreshed', handleRowRefreshmentSave);

function globalClickListener(event) {
    const favoriteStar = event.target.closest('#favoriteStar');
    if (!favoriteStar) {
        return;
    }

    if (!event.isTrusted) {
        return;
    }

    const networkNameH1 = document.querySelector('.nom_reseau h1');
    if (!networkNameH1) return;

    const isChecked = favoriteStar.classList.toggle("checked");
    const networkName = networkNameH1.textContent.trim();
    
    if (isChecked) {
        favoriteStar.classList.add('bumping');
        setTimeout(() => {
            favoriteStar.classList.remove('bumping');
        }, 300);

        createGlitterExplosion(favoriteStar);

        if (!LOCAL_STORAGE_RESEAUX_FAV.includes(networkName)) {
            LOCAL_STORAGE_RESEAUX_FAV.push(networkName);
            saveCurrentPageContent(networkName);
        }
    } else {
        const index = LOCAL_STORAGE_RESEAUX_FAV.indexOf(networkName);
        if (index > -1) {
            LOCAL_STORAGE_RESEAUX_FAV.splice(index, 1);
            removeSavedPageContent(networkName);
        }
    }
    localStorage.setItem('reseauxFavoris', JSON.stringify(LOCAL_STORAGE_RESEAUX_FAV));
    displayFavoriteTablesInNav();
}

document.addEventListener('click', globalClickListener);

export function initializeFavoriteManagement() {
    const favoriteStar = document.getElementById('favoriteStar');
    const refreshButton = document.querySelector('.fa-refresh');
    const networkNameH1 = document.querySelector('.nom_reseau h1');

    if (!favoriteStar || !networkNameH1) return;

    const NAMENETWORK = networkNameH1.textContent.trim();
    const idReseau = document.querySelector('.nom_reseau').id;

    if (!favoriteStar.parentNode.classList.contains('favorite-container')) {
        const container = document.createElement('div');
        container.classList.add('favorite-container');
        favoriteStar.parentNode.insertBefore(container, favoriteStar);
        container.appendChild(favoriteStar);
    }

    favoriteStar.classList.toggle("checked", LOCAL_STORAGE_RESEAUX_FAV.includes(NAMENETWORK));
    
    if (refreshButton) {
        refreshButton.onclick = async () => {
            const refreshedHTML = await Refreshalltab(idReseau, NAMENETWORK);
            if (refreshedHTML) {
                localStorage.setItem(LOCAL_STORAGE_SAVED_PAGE_PREFIX + NAMENETWORK, refreshedHTML);
                document.getElementById("tableContentContainer").innerHTML = refreshedHTML;
                makeTablesSortable();
                adapterNomsEntetesTableau();
                attachEditableCellListeners();
                initializeTableInteractions();
                initializeFavoriteManagement();
                displayFavoriteTablesInNav();
            }
        };
    }
    
    displayFavoriteTablesInNav();
}