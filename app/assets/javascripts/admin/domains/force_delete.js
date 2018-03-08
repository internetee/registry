(function() {
    let container = document.querySelector('.domain-edit-force-delete-dialog');

    if (!container) {
        return;
    }

    let toggle = container.querySelector('[data-dependent-content-toggle]');
    let dependentContent = container.querySelector('.email-template-row');

    toggle.addEventListener('change', function() {
        dependentContent.hidden = !this.checked;
    });
})();
