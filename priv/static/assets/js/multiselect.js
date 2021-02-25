import Taggle from "taggle";

var i = 0;

var select = document.getElementsByClassName("taxons-input")[0] || false;

new Taggle("tags", {
    onTagAdd: function (e, tag) {
        var selected, option;

        selected = select;
        option = document.createElement("option");
        option.setAttribute("id", i);
        option.setAttribute("value", tag);
        option.setAttribute("selected", "selected");
        selected.appendChild(option);
        i = i + 1;
    },
    tags: getSelectValues(select),
    onTagRemove: function (e, tag) {
        var s = document.getElementsByClassName("taxons-input")[0];
        for (var i = 0; i < s.length; i++) {
            if (s.options[i].value == tag) s.remove(i);
        }
    }
});

function getSelectValues(select) {
    var result = [];
    var options = select && select.options;
    var opt;

    for (var i = 0, iLen = options.length; i < iLen; i++) {
        opt = options[i];

        if (opt.selected) {
            result.push(opt.value || opt.text);
        }
    }
    return result;
}
