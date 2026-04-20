// ==UserScript==
// @name         Page title and URL to Markdown URL
// @version      4
// @description  Copies the title and URL of the page to the clipboard in a markdown formatted URL
// @match        http://*/*
// @match        https://*/*
// @grant        GM_setClipboard
// @run-at       document-start
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
      console.log('[link-shortcut] shortcut captured on', window.location.href);
      main();
  }
}

function getPRLineCounts() {
    let added = 0, removed = 0;
    let matchCount = 0;
    const srOnlyEls = document.querySelectorAll('.sr-only');
    for (const el of srOnlyEls) {
        const match = el.textContent.match(/(\d+) additions? & (\d+) deletions?/);
        if (match) {
            matchCount++;
            added += parseInt(match[1], 10);
            removed += parseInt(match[2], 10);
        }
    }
    console.log(`[link-shortcut] line counts: scanned ${srOnlyEls.length} .sr-only els, matched ${matchCount}, added=${added} removed=${removed}`);
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
  console.log(`[link-shortcut] copied to clipboard: ${textToCopy}`);
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
    const matchedSelector = titleSelectors.find(sel => document.querySelector(sel));
    const titleElement = matchedSelector ? document.querySelector(matchedSelector) : null;
    console.log(`[link-shortcut] github title selector matched: ${matchedSelector || 'NONE (falling back to document.title)'}`);
    const prTitle = (titleElement ? titleElement.textContent : document.title).trim();
    const cleanUrl = url.replace(/\/(files|changes)(\/?|$).*/, '');

    // If on files/changes page, redirect to summary and auto-copy after load
    if (url !== cleanUrl) {
      console.log(`[link-shortcut] redirecting to summary page: ${cleanUrl}`);
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

  console.log(`[link-shortcut] githubCopy: title="${prTitle}" lineCounts="${lineCounts}" eddy="${eddyConvoUrl || 'none'}"`);
  copyToClipboard(text);
  if (titleElement) colorChangeFeedback(titleElement);
}

console.log('[link-shortcut] loaded on', window.location.href, 'readyState=', document.readyState);
window.addEventListener('keydown', handleKeydown, { capture: true });

function runPendingPRCopy() {
  if (!sessionStorage.getItem('pendingPRCopy')) return;
  console.log('[link-shortcut] pendingPRCopy flag found, auto-copying after redirect');
  sessionStorage.removeItem('pendingPRCopy');
  const url = window.location.href;
  if (!url.includes('github.com')) return;
  const titleSelectors = [
    'h1[data-component="PH_Title"] span',
    'bdi.markdown-title',
    '.js-issue-title',
  ];
  const matchedSelector = titleSelectors.find(sel => document.querySelector(sel));
  const titleElement = matchedSelector ? document.querySelector(matchedSelector) : null;
  console.log(`[link-shortcut] post-redirect github title selector matched: ${matchedSelector || 'NONE'}`);
  const prTitle = (titleElement ? titleElement.textContent : document.title).trim();
  githubCopy(titleElement, prTitle, url);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', runPendingPRCopy, { once: true });
} else {
  runPendingPRCopy();
}
