let idInput = document.getElementById("id");


export const fetchAndDisplaySuggestions = async (currentInputValue, callback) => {
  let suggestionsDiv = document.querySelector(".suggestions");
  
  if (currentInputValue.length < 2) {
    suggestionsDiv.style.display = "none";
    return;
  }
  suggestionsDiv.style.width = idInput.offsetWidth + "px";
  window.addEventListener("resize", () => {
    suggestionsDiv.style.width = idInput.offsetWidth + "px";
  });

  const suggestionsUrl = `https://wasac.rp-ocn.apps.ocn.infra.ftgroup/perl/wasac-new/wasac_ajax.cgi?tbId=network_TB&btId=&cmd=recherche_reseau&req=${currentInputValue}`;

  try {
    const response = await fetch(suggestionsUrl);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const html = await response.text();
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, "text/html");
    const suggestionElements = [...doc.querySelectorAll("ul li a")];
    const suggestions = suggestionElements
      .map((el) => {
        const match = el.href.match(/setRechText\('([^']*)'/);
        return match ? match[1] : null;
      })
      .filter(Boolean);
      displaySuggestions(suggestions, callback,suggestionsDiv);
  } catch (e) {
    console.error(e);
    suggestionsDiv.style.display = "none";
  }
};

const displaySuggestions = (suggestions, callback,suggestionsDiv) => {
  suggestionsDiv.innerHTML = "";
  if (!suggestions.length) {
    suggestionsDiv.style.display = "none";
    return;
  }
  suggestions.forEach((text) => {
    const div = document.createElement("div");
    div.textContent = text;
    div.classList.add("suggestion-item");
    div.addEventListener("click", () => {
      idInput.value = text;
      suggestionsDiv.style.display = "none";
      callback(text);
    });
    suggestionsDiv.appendChild(div);
  });
  suggestionsDiv.style.display = "block";
};