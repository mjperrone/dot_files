// ==UserScript==
// @name         Redirect distracting sites to notion
// @namespace    http://tampermonkey.net/
// @version      0.3
// @description  Redirect distracting sites to notion
// @match        *://*.youtube.com/*
// @match        *://*.facebook.com/*
// @match        *://*.reddit.com/*
// @grant        GM_setClipboard
// @run-at       document-start
// ==/UserScript==
console.log('distracting redirect script entered');

var oldHref = document.location.href;
const bannedDomains = ['facebook.com', 'youtube.com', 'reddit.com' ];
const redirectTo = "https://notion.so";
redirect();
function redirect() {
    console.log('redirect in distracting redirect script');
    if (bannedDomains.some(domain => document.location.href.includes(domain))) {
        if (new Date().getHours() <= 6 && new Date().getHours() >= 0 || new Date().getHours() > 22){
        // if (true) {
            console.log("Redirecting from " + document.location.hostname + " to " + redirectTo);
            document.location.href = redirectTo;
        }
    }
}

window.onload = function() {
    console.log('onload in distracting redirect script');
    var bodyList = document.querySelector("body")
    var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(_mutation) {
            if (oldHref != document.location.href) {
                redirect();
            }
        });
    });
    var config = {
        childList: true,
        subtree: true
    };
    observer.observe(bodyList, config);
};