(function(){$(document).on("page:change",function(){return $("form").each(function(){return $(this).validate()}),$(".js-contact-form").on("restoreDefault",function(t){var e;switch(e=$(t.target),e.find(".js-ident-tip").hide(),$(".js-ident-country-code option:selected").val()){case"EE":return $(".js-ident-type").find("option[value=birthday]").prop("disabled",!0);default:return $(".js-ident-type").find("option[value=birthday]").prop("disabled",!1)}}),$(".js-ident-country-code").change(function(){var t;return t=$(".js-contact-form"),t.trigger("restoreDefault")}),$(".js-ident-type").change(function(t){var e;switch(e=$(".js-contact-form"),e.trigger("restoreDefault"),t.target.value){case"birthday":return e.find(".js-ident-tip").show()}}),$(".js-contact-form").trigger("restoreDefault")})}).call(this);