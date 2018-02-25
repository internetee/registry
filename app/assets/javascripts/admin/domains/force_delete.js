(function () {
    let toggle = document.querySelector('.domain-edit-force-delete-dialog [data-dependent-content-toggle]');
    let dependentContent = document.querySelector('.domain-edit-force-delete-dialog .email-template-row');

    if (!toggle) {
        return;
    }

    toggle.addEventListener('change', function () {
        dependentContent.hidden = !this.checked;
    });
})();
