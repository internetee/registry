(function() {
  const parameterContainer = document.getElementById('report-parameters');
  const addButton = document.getElementById('add-parameter-group');
  const removeButton = document.querySelector('.remove-parameter-group');

  if (!parameterContainer) {
      return;
  }

  function updateParameterSetTitles() {
    const groups = parameterContainer.querySelectorAll('.parameter-group');
    groups.forEach((group, index) => {
      const titleElement = group.querySelector('.parameter-set-title');
      if (titleElement) {
        titleElement.textContent = `Parameter Set ${index + 1}`;
      }
    });
  }

  function updateRemoveButtonVisibility() {
    const groups = parameterContainer.querySelectorAll('.parameter-group');
    if (removeButton) {
      removeButton.style.display = groups.length > 1 ? 'inline-block' : 'none';
    }
  }

  addButton.addEventListener('click', function() {
    const groups = parameterContainer.querySelectorAll('.parameter-group');
    const newIndex = groups.length;
    const template = groups[0].cloneNode(true);

    // Update all input names and values
    template.querySelectorAll('input').forEach(input => {
      const name = input.getAttribute('name');
      input.setAttribute('name', name.replace(/\[\d+\]/, `[${newIndex}]`));
      input.value = input.defaultValue; // Reset to default value
    });

    // Update all select names and reset to default values
    template.querySelectorAll('select').forEach(select => {
      const name = select.getAttribute('name');
      select.setAttribute('name', name.replace(/\[\d+\]/, `[${newIndex}]`));
      select.selectedIndex = 0; // Reset to first option (default)
    });

    parameterContainer.appendChild(template);
    updateParameterSetTitles();
    updateRemoveButtonVisibility();
  });

  document.addEventListener('click', function(e) {
    const removeBtn = e.target.closest('.remove-parameter-group');
    if (removeBtn) {
      const groups = parameterContainer.querySelectorAll('.parameter-group');
      if (groups.length > 1) {
        groups[groups.length - 1].remove();
        updateParameterSetTitles();
        updateRemoveButtonVisibility();
      }
    }
  });

  // Initialize titles on page load
  updateParameterSetTitles();
})();