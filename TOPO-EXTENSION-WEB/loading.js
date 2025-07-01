let currentProgress = 0;
export const updateLoading = (progress, stepMessage, isError = false) => {
  
  if (isError) {
    currentProgress = 0;
  } else if (progress !== 0){
    progress = Math.max(currentProgress, progress);
  }
  currentProgress = progress;

  const progressBar = document.querySelector('.progress-bar');
  const loadingStep = document.getElementById('loading-step');
  
  const safeProgress = Math.min(100, Math.max(0, currentProgress));

  if (progress === 0){
      progressBar.style.width = `${progress}%`;
  }else {
      progressBar.style.width = `${safeProgress}%`;
  }

  progressBar.setAttribute('aria-valuenow', safeProgress);
  loadingStep.textContent = stepMessage;
  loadingStep.style.color = isError ? 'red' : '#6c757d';
};