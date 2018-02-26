(function() {
    let container = document.querySelector('.domain-edit-force-delete-dialog');
    let toggle = container.querySelector('[data-dependent-content-toggle]');
    let dependentContent = container.querySelector('.email-template-row');

    if (!toggle) {
        return;
    }

    toggle.addEventListener('change', function() {
        dependentContent.hidden = !this.checked;
    });
})();
