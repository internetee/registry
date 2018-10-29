(function () {
    function trimTextFields() {
        let selector = 'input[type=text], input[type=search], input[type=email], textarea';
        let textFields = document.querySelectorAll(selector);
        let changeListener = function () {
            this.value = this.value.trim();
        };

        textFields.forEach(
            function (field, currentIndex, listObj) {
                field.addEventListener('change', changeListener);
            }
        );
    }

    trimTextFields();
})();
