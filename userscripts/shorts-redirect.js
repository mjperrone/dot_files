// ==UserScript==
// @name         Youtube shorts redirect
// @namespace    http://tampermonkey.net/
// @version      0.3
// @description  Youtuebe shorts > watch redirect
// @author       Fuim
// @match        *://*.youtube.com/*
// @icon         https://www.google.com/s2/favicons?domain=youtube.com
// @grant        none
// @run-at       document-end
// @license      GNU GPLv2
// ==/UserScript==
console.log('yt shorts redirect entered');

var oldHref = document.location.href;
if (window.location.href.indexOf('youtube.com/shorts') > -1) {
    window.location.replace(window.location.toString().replace('/shorts/', '/watch?v='));
}
window.addEventListener("load", function(event) {
    console.log("All resources finished loading!");
});
window.onload = function() {
    console.log('yt shorts onload redirect entered');

    var bodyList = document.querySelector("body")
    var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (oldHref != document.location.href) {
                oldHref = document.location.href;
                const newHref = window.location.toString().replace('/shorts/', '/watch?v=');
                console.log('redirected from', window.location.href, 'to', newHref);
                if (window.location.href.indexOf('youtube.com/shorts') > -1) {
                    window.location.replace(newHref);
                }
            }
        });
    });
    var config = {
        childList: true,
        subtree: true
    };
    observer.observe(bodyList, config);
};
