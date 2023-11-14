// ==UserScript==
// @name         Jira page title and URL to Markdown URL
// @version      1
// @description  Copies the title and URL of a Jira page to the clipboard in a markdown formatted URL
// @match        https://*.atlassian.net/*
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
  
  function copyToClipboard() {
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

  }
  
  document.addEventListener('keydown', handleKeydown);