(function () {
    function disableSpellCheck() {
        let selector = 'input[type=text], textarea';
        let textFields = document.querySelectorAll(selector);

        textFields.forEach(
            function (field, _currentIndex, _listObj) {
                field.spellcheck = false;
            }
        );
    }

    disableSpellCheck();
})();
