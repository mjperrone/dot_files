// ==UserScript==
// @name         Page title and URL to Markdown URL
// @version      3
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
    let added = 0, removed = 0;
    for (const el of document.querySelectorAll('.sr-only')) {
        const match = el.textContent.match(/(\d+) additions? & (\d+) deletions?/);
        if (match) {
            added += parseInt(match[1], 10);
            removed += parseInt(match[2], 10);
        }
    }
    if (added && removed) return `(+${added}/-${removed})`;
    if (added) return `(+${added})`;
    if (removed) return `(-${removed})`;
    return '';
}

function formatPRTitle(title) {
  const jiraMatch = title.match(/^\[([A-Z]+-\d+)\]\s*/);
  if (jiraMatch) {
    const rest = title.slice(jiraMatch[0].length);
    return `\`${rest}\``;
  }
  return `\`${title}\``;
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

function getEddyConvoLink() {
  const descBody = document.querySelector('.comment-body');
  if (!descBody) return '';
  const links = descBody.querySelectorAll('a');
  for (const link of links) {
    if (link.textContent.trim() === 'Conversation' &&
        link.closest('p, div, li')?.textContent.includes('Generated with')) {
      return link.href;
    }
  }
  return '';
}

function main() {
  const url = window.location.href;

  if (url.includes('notion.so') || url.includes('notion.site')) {
    const titleElement = document.querySelectorAll('.notion-page-block > h1.notranslate')[0]
    const title = titleElement.textContent.trim();
    const markdownUrl = `[${title}](${url})`;
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else if (url.includes('github.com')) {
    const titleSelectors = [
      'h1[data-component="PH_Title"] span',  // 2026 GitHub UI
      'bdi.markdown-title',                   // 2025 GitHub UI
      '.js-issue-title',                      // legacy
    ];
    const titleElement = titleSelectors.reduce((el, sel) => el || document.querySelector(sel), null);
    const prTitle = (titleElement ? titleElement.textContent : document.title).trim();
    const cleanUrl = url.replace(/\/(files|changes)(\/?|$).*/, '');

    // If on files/changes page, redirect to summary and auto-copy after load
    if (url !== cleanUrl) {
      sessionStorage.setItem('pendingPRCopy', '1');
      window.location.href = cleanUrl;
      return;
    }

    githubCopy(titleElement, prTitle, cleanUrl);
  } else if (url.includes('atlassian.net') && url.includes('/wiki/')) {
    // Confluence page — title lives in a textarea inside the editor title container
    const titleElement = document.querySelector('[data-testid="editor-title-container"] textarea');
    const title = titleElement.value.trim();
    const markdownUrl = `[${title}](${url})`;
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else if (url.includes('atlassian.net')) {
    // Jira ticket
    const h1s = document.querySelectorAll('h1');
    if (h1s.length !== 1) {
      console.log(`expected 1 h1, found ${h1s.length}, aborting jira link shortcut creation.`);
      return;
    }
    const titleElement = h1s[0];
    const jiraId = url.split('/').pop();
    const title = titleElement.textContent.trim();

    const markdownUrl = `[${jiraId}](${url}): \`${title}\``;
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else if (url.includes('docs.google.com')) {
    const titleElement = document.querySelector('.docs-title-input-label-inner');
    const title = titleElement.textContent.trim();
    const markdownUrl = `[${title}](${url})`;
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else if (url.includes('eddy.internal.headway.co/conversations/')) {
    const titleElement =
      document.querySelector('button[aria-label="Click to rename"]') ||
      document.querySelector('button[aria-label="Conversation options"] > span') ||
      document.querySelector('header span.font-semibold');
    const title = titleElement ? titleElement.textContent.trim() : document.title.trim();
    const markdownUrl = `[Eddy: ${title}](${url})`;
    copyToClipboard(markdownUrl);
    if (titleElement) colorChangeFeedback(titleElement);
  } else {
    const title = document.title.trim();
    const markdownUrl = `[${title}](${url})`;
    copyToClipboard(markdownUrl);
    const h1s = document.querySelectorAll('h1');
    const h1sWithText = Array.from(h1s).filter(h1 => h1.textContent.trim().length > 0);
    for (const h1 of h1sWithText) {
      colorChangeFeedback(h1);
    }
  }
}

function githubCopy(titleElement, prTitle, cleanUrl) {
  const [, org, repo, , number] = new URL(cleanUrl).pathname.split('/');
  const linkDisplayText = org === 'headway' ? `${repo}#${number}` : `${org}/${repo}#${number}`;
  const lineCounts = getPRLineCounts();
  const formattedTitle = formatPRTitle(prTitle);
  const eddyConvoUrl = getEddyConvoLink();
  const eddyLink = eddyConvoUrl ? ` [(Eddy Convo)](${eddyConvoUrl})` : '';
  const text = `[${linkDisplayText}](${cleanUrl}): ${formattedTitle}${eddyLink}${lineCounts ? ' ' + lineCounts : ''}`;

  copyToClipboard(text);
  if (titleElement) colorChangeFeedback(titleElement);
}

document.addEventListener('keydown', handleKeydown);

if (sessionStorage.getItem('pendingPRCopy')) {
  sessionStorage.removeItem('pendingPRCopy');
  const url = window.location.href;
  if (url.includes('github.com')) {
    const titleSelectors = [
      'h1[data-component="PH_Title"] span',
      'bdi.markdown-title',
      '.js-issue-title',
    ];
    const titleElement = titleSelectors.reduce((el, sel) => el || document.querySelector(sel), null);
    const prTitle = (titleElement ? titleElement.textContent : document.title).trim();
    githubCopy(titleElement, prTitle, url);
  }
}
