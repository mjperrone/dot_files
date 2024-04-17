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
      main();
  }
}

function getPRLineCounts() {
    const addedText = document.querySelector('#diffstat > .color-fg-success').textContent.trim().split(/\s+/).join('/');
    const removedText = document.querySelector('#diffstat > .color-fg-danger').textContent.trim().split(/\s+/).join('/');
	return `(${addedText}, ${removedText})`;
}

function colorChangeFeedback(element) {
  const oldColor = element.style.color;
  setTimeout(function() {
    console.log(`changing color to green`);
    element.style.color = 'green';
  }, 100);
  setTimeout(function() {
    console.log(`changing color back`);
    element.style.color = oldColor;
  }, 3000);
}

function copyToClipboard(textToCopy) {
  GM_setClipboard(textToCopy, 'PR');
  console.log(`copied to clipboard: ${textToCopy}`);
}

function main() {
  if (window.location.href.includes('notion.so') || window.location.href.includes('notion.site')) {
    const titleElement = document.querySelectorAll('.notion-page-block > h1.notranslate')[0]
    const title = titleElement.textContent.trim();
    const pageUrl = window.location.href;
    const markdownUrl = `[${title}](${pageUrl})`;
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else if (window.location.href.includes('github.com')) {
    const titleElement = document.querySelector('.js-issue-title');
    const prTitle = titleElement.textContent.trim();
    const text = window.location.href + ' `' + prTitle + '` ' + getPRLineCounts();
    copyToClipboard(text);
    colorChangeFeedback(titleElement);
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
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else {
    const title = document.title.trim();
    const pageUrl = window.location.href;
    const markdownUrl = `[${title}](${pageUrl})`;
    copyToClipboard(markdownUrl);
    const h1s = document.querySelectorAll('h1');
    // filter out h1s that have no text content:
    const h1sWithText = Array.from(h1s).filter(h1 => h1.textContent.trim().length > 0);
    for (const h1 of h1sWithText) {
      colorChangeFeedback(h1);
    }
  }
}

document.addEventListener('keydown', handleKeydown);