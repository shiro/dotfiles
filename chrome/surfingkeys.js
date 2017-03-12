// mapkey('<Ctrl-y>', 'Show me the money', function() {
//     Front.showPopup('a well-known phrase uttered by characters in the 1996 film Jerry Maguire (Escape to close).');
// });


settings.scrollStepSize = 140;
settings.newTabPosition = "last";


mapkey('p', "Open the clipboard's URL in the current tab", function() {
    Front.getContentFromClipboard(function(response) {
        window.location.href = response.data;
    });
});

map('B', 'b');
mapkey('b', 'Open a Bookmark in current tab', 'Front.openOmnibar({type: "Bookmarks", tabbed: false})');

map('<Alt-t>', '<Alt-s>');

map('<ArrowRight>', 'R');
map('<ArrowLeft>', 'E');

map('F', 'C');
map('o', 'go');
map('O', 't');
map('ö', 'gx$');
map('u', 'e');

map('P', 'cc');
map('gi', 'i');
map('gf', 'w');
map('H', 'S');
map('L', 'D');
map('gt', 'R');
map('gT', 'E');
map('yf', 'ya');

unmap(".");
unmap("sg");
unmap("sd");
unmap("sb");
unmap("ga");
unmap("sw");
unmap("ss");
// unmap("s");
unmap("S");
unmap(";dh");
unmap("t");
unmap("cpToggle");
unmap(";cpCopy");
unmap(";apApply");
unmap("spaset");
unmap("spbset");
unmap("spdset");
unmap("spsset");
unmap("spcset");
unmap("spishow");
unmap("sfrshow");

settings.theme = `
.sk_theme {
    background: rgba(0, 50, 70, 0.95);
}

.sk_theme input {
    color: white;
}

.sk_theme#sk_omnibar {
    box-shadow: 0 0 15px 0px rgba(255, 255, 255, 0.9);
}

.sk_theme #sk_omnibarSearchResult > ul {
}

.sk_theme #sk_omnibarSearchResult > ul > li {
    margin: 5px 10px;
    background-color: rgba(255, 255, 255, 1);
    font-size: 16px;
    transition: 0.3s all;
    border-radius: 5px;
}

.sk_theme #sk_omnibarSearchResult > ul > li:hover, .sk_theme #sk_omnibarSearchResult > ul > .focused {
    cursor: pointer;
    font-size: 20px;
    background-color: rgba(205, 222, 249, 0.9) !important;
}`
