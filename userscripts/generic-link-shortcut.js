// ==UserScript==
// @name         Page title and URL to Markdown URL
// @version      1
// @description  Copies the title and URL of the page to the clipboard in a markdown formatted URL
// @match        http://*/*
// @match        https://*/*
// @grant        GM_setClipboard
// ==/UserScript==

const SHORTCUT = {
  ctrlKey: true,
  shiftKey: true,
  code: 'KeyC'
};
function handleKeydown(event) {
  if (event.ctrlKey === SHORTCUT.ctrlKey &&
      event.shiftKey === SHORTCUT.shiftKey &&
      event.code === SHORTCUT.code) {
      copyToClipboard();
  }
}
function formatForSlack() {
	return getURL() + ' `' + getPRTitle() + '` ' + getLineCounts();
}

function getURL() {
	return window.location.href;
}

function getLineCounts() {
    const addedText = document.querySelector('#diffstat > .color-fg-success').textContent.trim().split(/\s+/).join('/');
    const removedText = document.querySelector('#diffstat > .color-fg-danger').textContent.trim().split(/\s+/).join('/');

	return `(${addedText}, ${removedText})`;
}

function getPRTitle() {
	return document.querySelector('.js-issue-title').textContent.trim();
}

function copyToClipboard() {
  if (window.location.href.includes('notion.so') || window.location.href.includes('notion.site')) {
    const titleElement = document.querySelectorAll('.notion-page-block > h1.notranslate')[0]
    const title = titleElement.textContent.trim();
    const pageUrl = window.location.href;
    const markdownUrl = `[${title}](${pageUrl})`;
    console.log(`copying to clipboard: ${markdownUrl}`);
    GM_setClipboard(markdownUrl);
    const oldColor = titleElement.style.color;
    setTimeout(function() {
      console.log(`changing color to green`);
      titleElement.style.color = 'green';
    }, 100);
    setTimeout(function() {
      console.log(`changing color back`);
      titleElement.style.color = oldColor;
    }, 3000);
  } else if (window.location.href.includes('github.com')) {
    GM_setClipboard(formatForSlack(), 'PR');
    const oldColor = document.querySelector('.js-issue-title').style.color;
    setTimeout(function() {
      console.log(`changing color to green`);
      document.querySelector('.js-issue-title').style.color = 'green';
    }, 100);
    setTimeout(function() {
      document.querySelector('.js-issue-title').style.color = oldColor;
    }, 3000);
  } else if(window.location.href.includes('atlassian.net')) {
    const h1s = document.querySelectorAll('h1');
    if (h1s.length !== 1) {
      console.log(`expected 1 h1, found ${h1s.length}, aborting jira link shortcut creation.`);
      return;
    }
    const titleElement = h1s[0];
    const jiraId = window.location.href.split('/').pop();
    const title = titleElement.textContent.trim();

    const pageUrl = window.location.href;
    const markdownUrl = `[${jiraId}](${pageUrl}): \`${title}\``;
    console.log(`copying to clipboard: ${markdownUrl}`);
    GM_setClipboard(markdownUrl);
    const oldColor = titleElement.style.color;
    setTimeout(function() {
      console.log(`changing color to green`);
      titleElement.style.color = 'green';
    }, 100);
    setTimeout(function() {
      console.log(`changing color back`);
      titleElement.style.color = oldColor;
    }, 3000);
  } else {
    const title = document.title.trim();
    const pageUrl = window.location.href;
    const markdownUrl = `[${title}](${pageUrl})`;
    console.log(`copying to clipboard: ${markdownUrl}`);
    GM_setClipboard(markdownUrl);
  }
}

document.addEventListener('keydown', handleKeydown);