(function() {
  const parameterContainer = document.getElementById('report-parameters');
  const addButton = document.getElementById('add-parameter-group');
  const removeButton = document.querySelector('.remove-parameter-group');

  if (!parameterContainer) {
      return;
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
    
    parameterContainer.appendChild(template);
    updateRemoveButtonVisibility();
  });

  document.addEventListener('click', function(e) {
    const removeBtn = e.target.closest('.remove-parameter-group');
    if (removeBtn) {
      const groups = parameterContainer.querySelectorAll('.parameter-group');
      if (groups.length > 1) {
        groups[groups.length - 1].remove();
        updateRemoveButtonVisibility();
      }
    }
  });
})();