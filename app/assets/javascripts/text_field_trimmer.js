(function () {
    function trimTextFields() {
        let selector = 'input[type=text], input[type=search], input[type=email], textarea';
        let textFields = document.querySelectorAll(selector);
        let listener = function () {
            this.value = this.value.trim();
        };

        for (let field of textFields) {
            field.addEventListener('change', listener);
        }
    }

    trimTextFields();
})();
