// ==UserScript==
// @name GitHub PR Info
// @namespace http://tampermonkey.net/
// @version 0.1
// @description Copy a PR's title, URL, and line counts to the clipboard.
// @match https://github.com/*
// @grant GM_setClipboard
// @run-at document-idle
// ==/UserScript==
function formatForSlack() {
	const url = getURL();
	return getSlackLink(url) + ' `' + getPRTitle() + '` ' + getLineCounts();
}

function getURL() {
	return window.location.href.replace(/\/(files|changes)(\/?|$).*/, '');
}

function getSlackLink(url) {
	const [, org, repo, , number] = new URL(url).pathname.split('/');
	if (org === 'headway') {
		return `[${repo}#${number}](${url})`;
	}
	return url;
}

function getLineCounts() {
    const addedText = document.querySelector('#diffstat > .color-fg-success').textContent.trim().split(/\s+/).join('/');
    const removedText = document.querySelector('#diffstat > .color-fg-danger').textContent.trim().split(/\s+/).join('/');

	return `(${addedText}, ${removedText})`;
}

function getPRTitle() {
	return document.querySelector('.js-issue-title').textContent.trim();
}
const SHORTCUT = {
    ctrlKey: true,
    shiftKey: true,
    code: 'KeyC'
  };
  function handleKeydown(event) {
    if (event.ctrlKey === SHORTCUT.ctrlKey &&
        event.shiftKey === SHORTCUT.shiftKey &&
        event.code === SHORTCUT.code) {
        quickLinkToClipboard();
    }
  }

function quickLinkToClipboard() {
    GM_setClipboard(formatForSlack(), 'PR');
    const oldColor = document.querySelector('.js-issue-title').style.color;
    setTimeout(function() {
      console.log(`changing color to green`);
      document.querySelector('.js-issue-title').style.color = 'green';
    }, 100);
    setTimeout(function() {
      document.querySelector('.js-issue-title').style.color = oldColor;
    }, 3000);
}

document.querySelector('.js-issue-title').addEventListener('click', quickLinkToClipboard);
document.addEventListener('keydown', handleKeydown);