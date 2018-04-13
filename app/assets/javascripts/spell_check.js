(function() {
    function disableSpellCheck() {
        let selector = 'input[type=text], textarea';
        let textFields = document.querySelectorAll(selector);

        for (let field of textFields) {
            field.spellcheck = false;
        }
    }

    disableSpellCheck();
})();
