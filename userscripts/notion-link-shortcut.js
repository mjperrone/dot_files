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

  }
  
  document.addEventListener('keydown', handleKeydown);