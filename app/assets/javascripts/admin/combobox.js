var comboBoxFields = $('.js-combobox');

if (comboBoxFields.length) {
  comboBoxFields.select2({
    width: "100%",
    selectOnBlur: true,
    dropdownAutoWidth: self === top
  });
}
