(function () {
    var listener = function () {
        this.value = this.value.trim();
    };

    var selector = 'input[type=text], input[type=search], input[type=email], textarea';
    var fields = document.querySelectorAll(selector);

    for (var i = 0; i < fields.length; ++i) {
        fields[i].addEventListener('change', listener);
    }
})();
