import { makeTablesSortable } from './Triertab.js';
import { adapterNomsEntetesTableau } from './responsive.js';
import { attachEditableCellListeners } from './Modiftab.js';
import { initializeFavoriteManagement } from './favorites_manager.js';
import { initializePopupHandlers } from './popup_handler.js';
import { initializeTableInteractions } from './table_interactions.js';
import { initializeExportLogic } from './export_logic.js';

    makeTablesSortable();
    adapterNomsEntetesTableau();
    
    // Initialisation des modules
    attachEditableCellListeners();
    initializeFavoriteManagement();
    initializePopupHandlers();
    initializeTableInteractions();
    initializeExportLogic();

    // Responsive
    window.addEventListener("resize", adapterNomsEntetesTableau);