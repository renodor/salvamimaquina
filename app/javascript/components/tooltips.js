
const tooltips = () => {
  const tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]');

  if (tooltips.length > 0) {
    tooltips.map(function(tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  }
};

export { tooltips };
