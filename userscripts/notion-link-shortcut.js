// ==UserScript==
// @name         Notion page title and URL to Markdown URL
// @version      1
// @description  Copies the title and URL of a Notion page to the clipboard in a markdown formatted URL
// @match        https://www.notion.so/*
// @match        https://*.notion.site/*
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
    const title = document.querySelectorAll('.notion-page-block > div.notranslate')[0].textContent.trim();
    const pageUrl = window.location.href;
    const markdownUrl = `[${title}](${pageUrl})`;
    console.log(`copying to clipboard: ${markdownUrl}`);
    GM_setClipboard(markdownUrl);
  }
  
  document.addEventListener('keydown', handleKeydown);