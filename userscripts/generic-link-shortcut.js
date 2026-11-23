// ==UserScript==
// @name         Page title and URL to Markdown URL
// @version      13
// @description  Copies the title and URL of the page to the clipboard in a markdown formatted URL
// @match        http://*/*
// @match        https://*/*
// @grant        GM_setClipboard
// @grant        GM_xmlhttpRequest
// @connect      github.com
// @connect      githubusercontent.com
// @connect      amazonaws.com
// @run-at       document-start
// ==/UserScript==

const SHORTCUT = {
  ctrlKey: true,
  shiftKey: true,
  code: 'KeyC'
};

/** Backslash-escape [] and () so titles are safe inside Markdown [text](url) link text. */
function escapeMarkdownLinkTitle(text) {
  return text.replace(/[\[\]()]/g, '\\$&');
}

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
    return formatLineCounts(added, removed);
}

function formatLineCounts(added, removed) {
    if (added && removed) return `(+${added}/-${removed})`;
    if (added) return `(+${added})`;
    if (removed) return `(-${removed})`;
    return '';
}

/**
 * Line counts for any PR (not just the one on screen): the Files changed route
 * returns React payload JSON with per-file diffSummaries when asked for JSON.
 */
async function fetchPRLineCounts(origin, org, repo, prNumber) {
  try {
    const res = await fetch(`${origin}/${org}/${repo}/pull/${prNumber}/changes`, {
      credentials: 'include',
      headers: { Accept: 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'GitHub-Verified-Fetch': 'true' },
    });
    if (!res.ok) return '';
    const summaries = (await res.json())?.payload?.pullRequestsChangesRoute?.diffSummaries;
    if (!Array.isArray(summaries) || !summaries.length) return '';
    let added = 0, removed = 0;
    for (const f of summaries) {
      added += Number(f.linesAdded) || 0;
      removed += Number(f.linesDeleted) || 0;
    }
    return formatLineCounts(added, removed);
  } catch (e) {
    console.log(`[link-shortcut] failed to fetch line counts for #${prNumber}:`, e);
    return '';
  }
}

const GITHUB_TITLE_SELECTORS = [
  'h1 > span[class*="markdownTitle"]',   // Nov 2026 UI: CSS-module hashed class (markdownTitle__xxxx). The h1 also holds an sr-only " - #N" span, so target the span
  'h1 > span.markdown-title',             // Oct 2026 UI
  'h1[data-component="PH_Title"] span',  // 2026 GitHub UI
  'bdi.markdown-title',                   // 2025 GitHub UI
  '.js-issue-title',                      // legacy
];

/**
 * document.title on GitHub looks like "Title by author · Pull Request #123 · org/repo"
 * (or "Title · Issue #123 · org/repo"). Strip that suffix when no title element matched.
 */
function titleFromDocumentTitle() {
  return document.title
    .replace(/\s*·\s*(Pull Request|Issue) #\d+\s*·\s*[^·]+$/i, '')
    .replace(/\s+by\s+\S+$/i, '')
    .trim();
}

function getGitHubTitle() {
  const matchedSelector = GITHUB_TITLE_SELECTORS.find(sel => document.querySelector(sel));
  const titleElement = matchedSelector ? document.querySelector(matchedSelector) : null;
  console.log(`[link-shortcut] github title selector matched: ${matchedSelector || 'NONE (falling back to document.title)'}`);
  const prTitle = titleElement ? titleElement.textContent.trim() : titleFromDocumentTitle();
  return { titleElement, prTitle };
}

/**
 * GitHub native stacked PRs: the PR page embeds React payload JSON with
 * payload.pullRequestsLayoutRoute.stack = { position, size, pulls: [{ number, title, state, url }] }
 * (pulls ordered top of stack first; stack is null for unstacked PRs).
 */
function stackFromDocument(doc, prNumber) {
  const scripts = doc.querySelectorAll('script[type="application/json"][data-target="react-app.embeddedData"]');
  for (const script of scripts) {
    let layout;
    try {
      layout = JSON.parse(script.textContent)?.payload?.pullRequestsLayoutRoute;
    } catch {
      continue;
    }
    if (!layout || String(layout.pullRequest?.number) !== String(prNumber)) continue;
    return { found: true, stack: layout.stack?.pulls?.length ? layout.stack : null };
  }
  return { found: false, stack: null };
}

async function getGitHubStack(cleanUrl, prNumber) {
  // Embedded data can be stale or missing after client-side navigation, so fall
  // back to fetching the PR page (same-origin, so private repos work via cookies).
  let result = stackFromDocument(document, prNumber);
  if (!result.found) {
    try {
      const res = await fetch(cleanUrl, { credentials: 'include', headers: { Accept: 'text/html' } });
      const html = await res.text();
      result = stackFromDocument(new DOMParser().parseFromString(html, 'text/html'), prNumber);
    } catch (e) {
      console.log('[link-shortcut] failed to fetch PR page for stack info:', e);
    }
  }
  console.log(`[link-shortcut] stack: ${result.stack ? `${result.stack.size} PRs` : 'none'} (embedded data found=${result.found})`);
  return result.stack;
}

function formatPRTitle(title) {
  const jiraMatch = title.match(/^\[([A-Z]+-\d+)\]\s*/);
  if (jiraMatch) {
    const rest = title.slice(jiraMatch[0].length);
    return `\`${rest}\``;
  }
  return `\`${title}\``;
}

const PENDING_COLOR = 'orange';
const DONE_COLOR = 'green';
const ERROR_COLOR = 'red';

/** Permanent (no timeout / revert): the title stays this color until reload. */
function setTitleColor(element, color) {
  element.style.setProperty('color', color, 'important');
}

/** Final "copied" feedback. */
function colorChangeFeedback(element) {
  setTitleColor(element, DONE_COLOR);
}

const CAMERA_ICON = ':camera:';

/**
 * Real content images only. Skips GitHub emoji, avatars, and small badges such
 * as Cursor's "Open in Web" / "Open in Cursor" buttons (114x28 <img>s that ride
 * along in every Cursor cloud-agent PR description).
 */
function isContentImage(img) {
  if (img.classList.contains('emoji') || img.closest('g-emoji') || img.classList.contains('avatar')) return false;
  if (/^open in /i.test(img.getAttribute('alt') || '')) return false;
  const height = parseInt(img.getAttribute('height'), 10);
  if (height && height <= 40) return false;
  return true;
}

function hasContentImage(root) {
  return Array.from(root.querySelectorAll('img')).some(isContentImage);
}

/** Description source (markdown and/or HTML) contains a content image. */
function bodyTextHasImage(text) {
  if (!text) return false;
  if (/!\[[^\]]*\]\(/.test(text)) return true;  // markdown image
  if (/(^|\s)https:\/\/github\.com\/user-attachments\/assets\/\S+/.test(text)) return true;  // bare upload URL
  return hasContentImage(new DOMParser().parseFromString(text, 'text/html'));
}

/**
 * Whether a PR page's description contains an image. Checks the rendered
 * description first, then the embedded React payload. Returns false when unsure.
 */
/**
 * The PR description's rendered body. Older GitHub UIs use .comment-body; the
 * Nov 2026 UI renders <section aria-label="Description"> with a .markdown-body inside.
 */
function descriptionBodyElement(doc) {
  return doc.querySelector('.comment-body')
    || doc.querySelector('section[aria-label="Description"] .markdown-body');
}

function descriptionHasImagesInDocument(doc, prNumber) {
  const descBody = descriptionBodyElement(doc);
  if (descBody) return hasContentImage(descBody);
  const pr = embeddedPullRequest(doc, prNumber);
  return pr ? bodyTextHasImage(pr.bodyHTML || pr.body || '') : false;
}

/** The PR object from the page's embedded React payload, if present. */
function embeddedPullRequest(doc, prNumber) {
  const scripts = doc.querySelectorAll('script[type="application/json"][data-target="react-app.embeddedData"]');
  for (const script of scripts) {
    let pr;
    try {
      pr = JSON.parse(script.textContent)?.payload?.pullRequestsLayoutRoute?.pullRequest;
    } catch {
      continue;
    }
    if (pr && String(pr.number) === String(prNumber)) return pr;
  }
  return null;
}

function contentImageUrls(root, baseUrl) {
  return Array.from(root.querySelectorAll('img'))
    .filter(isContentImage)
    .map(img => img.getAttribute('src'))
    .filter(Boolean)
    .map(src => new URL(src, baseUrl).href);
}

/** URLs of content images in the current PR's description, in order. */
function descriptionImageUrls(doc, prNumber) {
  const base = window.location.href;
  let urls = [];
  const descBody = descriptionBodyElement(doc);
  if (descBody) {
    urls = contentImageUrls(descBody, base);
  } else {
    const pr = embeddedPullRequest(doc, prNumber);
    if (pr?.bodyHTML) {
      urls = contentImageUrls(new DOMParser().parseFromString(pr.bodyHTML, 'text/html'), base);
    } else if (pr?.body) {
      const md = [...pr.body.matchAll(/!\[[^\]]*\]\((\S+?)(?:\s+"[^"]*")?\)/g)].map(m => m[1]);
      const html = contentImageUrls(new DOMParser().parseFromString(pr.body, 'text/html'), base);
      const bare = [...pr.body.matchAll(/(?:^|\s)(https:\/\/github\.com\/user-attachments\/assets\/\S+)/g)].map(m => m[1]);
      urls = [...md, ...html, ...bare];
    }
  }
  return [...new Set(urls)];
}

/** Gap between clipboard writes so clipboard-history managers record each one. */
const CLIPBOARD_STEP_DELAY_MS = 600;

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

/** GM_xmlhttpRequest bypasses CORS, so GitHub's signed image URLs can be read. */
function fetchImageBlob(url) {
  return new Promise((resolve, reject) => {
    GM_xmlhttpRequest({
      method: 'GET',
      url,
      responseType: 'blob',
      timeout: 15000,
      onload: r => (r.status >= 200 && r.status < 300 ? resolve(r.response) : reject(new Error(`HTTP ${r.status}`))),
      onerror: () => reject(new Error('network error')),
      ontimeout: () => reject(new Error('timeout')),
    });
  });
}

/** Async Clipboard API only reliably accepts image/png, so re-encode anything else. */
async function toPngBlob(blob) {
  if (blob.type === 'image/png') return blob;
  const bitmap = await createImageBitmap(blob);
  const canvas = document.createElement('canvas');
  canvas.width = bitmap.width;
  canvas.height = bitmap.height;
  canvas.getContext('2d').drawImage(bitmap, 0, 0);
  bitmap.close();
  return new Promise((resolve, reject) =>
    canvas.toBlob(b => (b ? resolve(b) : reject(new Error('toBlob failed'))), 'image/png'));
}

/** Download and PNG-encode every image; failures are logged and dropped. */
async function loadPngImages(urls) {
  const results = await Promise.all(urls.map(async url => {
    try {
      return await toPngBlob(await fetchImageBlob(url));
    } catch (e) {
      console.log(`[link-shortcut] failed to load image ${url}:`, e);
      return null;
    }
  }));
  return results.filter(Boolean);
}

/** Write each image to the clipboard in turn. Returns how many succeeded. */
async function copyImagesToClipboard(pngs) {
  let copied = 0;
  for (const png of pngs) {
    try {
      await navigator.clipboard.write([new ClipboardItem({ 'image/png': png })]);
      copied++;
      console.log(`[link-shortcut] copied image ${copied}/${pngs.length} to clipboard`);
      if (copied < pngs.length) await sleep(CLIPBOARD_STEP_DELAY_MS);
    } catch (e) {
      console.log('[link-shortcut] failed to write image to clipboard:', e);
    }
  }
  return copied;
}

/**
 * Fetches another PR's page once and reports whether its description has
 * images plus a promise for those images (already downloading) as PNGs.
 */
async function fetchPRDescriptionImages(origin, org, repo, prNumber) {
  const none = { hasImages: false, pngs: Promise.resolve([]) };
  try {
    const res = await fetch(`${origin}/${org}/${repo}/pull/${prNumber}`, { credentials: 'include', headers: { Accept: 'text/html' } });
    if (!res.ok) return none;
    const doc = new DOMParser().parseFromString(await res.text(), 'text/html');
    if (!descriptionHasImagesInDocument(doc, prNumber)) return none;
    const urls = descriptionImageUrls(doc, prNumber);
    console.log(`[link-shortcut] #${prNumber} description has ${urls.length} image(s)`);
    return { hasImages: true, pngs: loadPngImages(urls) };
  } catch (e) {
    console.log(`[link-shortcut] failed to check description images for #${prNumber}:`, e);
    return none;
  }
}

function copyToClipboard(textToCopy) {
  GM_setClipboard(textToCopy, 'PR');
  console.log(`[link-shortcut] copied to clipboard: ${textToCopy}`);
}

function getEddyConvoLink() {
  const descBody = descriptionBodyElement(document);
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

function isLinearAppUrl(url) {
  try {
    const { hostname } = new URL(url);
    return hostname === 'linear.app';
  } catch {
    return false;
  }
}

/** Path segment immediately after `segment` (e.g. "issue", "project"). */
function linearPathSegmentAfter(url, segment) {
  try {
    const parts = new URL(url).pathname.split('/').filter(Boolean);
    const i = parts.indexOf(segment);
    return i >= 0 ? (parts[i + 1] || '') : '';
  } catch {
    return '';
  }
}

function linearTitleFromDocumentTitle() {
  return document.title
    .replace(/\s*[·•]\s*Linear.*$/i, '')
    .replace(/\s*\|\s*Linear.*$/i, '')
    .trim();
}

function getLinearTitleElement() {
  const selectors = ['main h1', '[role="main"] h1', 'article h1'];
  for (const sel of selectors) {
    const el = document.querySelector(sel);
    if (!el) continue;
    const text = (el instanceof HTMLTextAreaElement || el instanceof HTMLInputElement
      ? el.value
      : el.textContent).trim();
    if (text) return el;
  }
  const h1s = document.querySelectorAll('h1');
  for (const h1 of h1s) {
    const t = h1.textContent.trim();
    if (t.length > 0 && t.length < 500) return h1;
  }
  return null;
}

function linearTitleText(titleElement) {
  if (!titleElement) return linearTitleFromDocumentTitle();
  if (titleElement instanceof HTMLTextAreaElement || titleElement instanceof HTMLInputElement) {
    return titleElement.value.trim();
  }
  return titleElement.textContent.trim();
}

/** Human issue id (e.g. ENG-123) from URL path or leading document title. */
function linearIssueDisplayId(url) {
  const fromPath = linearPathSegmentAfter(url, 'issue');
  if (/^[A-Z]{2,10}-\d+$/i.test(fromPath)) return fromPath;
  const fromTitle = document.title.match(/^([A-Z]{2,10}-\d+)\b/);
  if (fromTitle) return fromTitle[1];
  if (fromPath && !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(fromPath)) {
    return fromPath;
  }
  return '';
}

const EDDY_HOSTNAME = 'eddy.internal.headway.co';

/**
 * Slack custom emoji shown before the title for each kind of Eddy page. The
 * trailing ":" makes the link read "<emoji>: Title" (e.g. ":edifact:: Report").
 */
const EDDY_ICONS = {
  conversation: ':eddy::',
  coordinator: ':eddy-on-it::',            // Eddy Projects coordinator chat
  worker: ':eddy-admires-subagents::',     // Eddy Projects worker chat
  artifact: ':edifact::',
  workflow: ':eddy-blueprint::',
  scheduled: ':eddy-scheduled::',
  slackAgent: ':eddy-slack-agent::',
  webhook: ':edhooks::',
  skill: ':eddy-student::',                // library items / catalog skills
  other: ':eddy::',
};

/** Query params that only drive one-time UI (back-link, share dialog, approval card, composer prefill). */
const EDDY_TRANSIENT_PARAMS = ['from', 'share', 'approve', 'prefill'];

function isEddyUrl(url) {
  try {
    return new URL(url).hostname === EDDY_HOSTNAME;
  } catch {
    return false;
  }
}

/** Which kind of Eddy page this is, from the path alone. */
function eddyPageKind(pathname) {
  if (/^\/(conversations|projects)\/[^/]+/.test(pathname)) return 'conversation';
  if (/^\/(artifacts\/[^/]+|a\/[^/]+)/.test(pathname)) return 'artifact';
  if (/^\/(workflows|blueprints|workflow-runs)(\/|$)/.test(pathname)) return 'workflow';
  if (/^\/(library\/scheduled|schedules)(\/|$)/.test(pathname)) return 'scheduled';
  if (/^\/(library\/slack|slack-agents)(\/|$)/.test(pathname)) return 'slackAgent';
  if (/^\/library\/webhooks(\/|$)/.test(pathname)) return 'webhook';
  if (/^\/library\/(items|catalog)\/|^\/library\/[^/]+$/.test(pathname)) return 'skill';
  return 'other';
}

/**
 * Eddy Projects role of the open conversation. The header carries a role pill
 * (data-project-role-pill="coordinator" | "worker"); the header tint
 * (violet = coordinator, sky = worker) is the fallback.
 */
function eddyConversationRole() {
  const pill = document.querySelector('header [data-project-role-pill], [data-project-role-pill]');
  const role = pill?.getAttribute('data-project-role-pill');
  if (role === 'coordinator' || role === 'worker') return role;
  const header = document.querySelector('header.sticky');
  if (header?.className.includes('border-violet-500')) return 'coordinator';
  if (header?.className.includes('border-sky-500')) return 'worker';
  return null;
}

function isVisible(el) {
  return el.getClientRects().length > 0;
}

/**
 * The page's visible title element. Owners get a "Click to rename" button
 * (conversations and artifacts both use one); otherwise Eddy renders a
 * plain h1 / font-semibold span in the sticky header. The header renders a
 * mobile and a desktop copy of the title, so pick the visible one.
 */
function eddyTitleElement() {
  const selectors = [
    'header button[aria-label="Click to rename"]',
    'button[aria-label="Click to rename"]',
    'header h1',
    'header span.font-semibold',
    'main h1',
    'h1',
  ];
  for (const sel of selectors) {
    for (const el of document.querySelectorAll(sel)) {
      if (isVisible(el) && el.textContent.trim()) return el;
    }
  }
  return null;
}

/**
 * The element's own text, ignoring child elements. The artifact page renders a
 * "Shared" badge inside the rename button, so textContent would be "TitleShared".
 */
function eddyElementText(el) {
  const own = Array.from(el.childNodes)
    .filter(n => n.nodeType === Node.TEXT_NODE)
    .map(n => n.textContent)
    .join('')
    .trim();
  return own || el.textContent.trim();
}

/**
 * Some Eddy pages have no header to color (artifact app mode: /a/<name> for
 * viewers, ?mode=app), so flash a bar across the top of the page instead.
 */
function eddyFallbackFeedback() {
  const bar = document.createElement('div');
  bar.style.cssText = `position:fixed;top:0;left:0;right:0;height:4px;background:${DONE_COLOR};z-index:2147483647;pointer-events:none`;
  document.documentElement.appendChild(bar);
  setTimeout(() => bar.remove(), 1500);
}

/** document.title without Eddy's tab-status prefixes and " - Eddy" style suffixes. */
function eddyTitleFromDocumentTitle() {
  return document.title
    .replace(/^(\(\d+\)\s*)?([^\p{L}\p{N}\s]+\s*)+/u, '')
    .replace(/(\s+-\s+(Library|Agents|Workflows|Eddy))+\s*$/g, '')
    .trim();
}

/** The title an HTML artifact gives itself (<title>, else first h1/h2), read from the iframe's srcdoc. */
function artifactInnerTitle() {
  // The iframe is sandboxed without allow-same-origin, so contentDocument is
  // off limits, but the srcdoc attribute the host page sets is readable.
  const iframe = document.querySelector('iframe[data-artifact-iframe]');
  if (!iframe?.srcdoc) return '';
  try {
    const doc = new DOMParser().parseFromString(iframe.srcdoc, 'text/html');
    return (
      doc.querySelector('title')?.textContent?.trim() ||
      doc.querySelector('h1')?.textContent?.trim() ||
      doc.querySelector('h2')?.textContent?.trim() ||
      ''
    );
  } catch (e) {
    console.log('[link-shortcut] failed to parse iframe srcdoc:', e);
    return '';
  }
}

/** "report.inline.html" style labels: the artifact still shows its filename, not a chosen title. */
function looksLikeFilename(text) {
  return /\.[a-z0-9]{1,6}$/i.test(text) && !/\s/.test(text);
}

function eddyCleanUrl(url) {
  const u = new URL(url);
  for (const p of EDDY_TRANSIENT_PARAMS) u.searchParams.delete(p);
  return u.href;
}

function eddyCopy(url) {
  const cleanUrl = eddyCleanUrl(url);
  let kind = eddyPageKind(new URL(cleanUrl).pathname);
  if (kind === 'conversation') kind = eddyConversationRole() || 'conversation';

  const titleElement = eddyTitleElement();
  let title = titleElement ? eddyElementText(titleElement) : eddyTitleFromDocumentTitle();
  if (kind === 'artifact') {
    // Prefer the artifact's own title over a bare filename, but keep a
    // display title the owner chose.
    const inner = artifactInnerTitle();
    if (inner && (!title || looksLikeFilename(title))) title = inner;
  }

  const markdownUrl = `[${EDDY_ICONS[kind]} ${escapeMarkdownLinkTitle(title)}](${cleanUrl})`;
  console.log(`[link-shortcut] eddy page kind=${kind} title element=${titleElement ? titleElement.tagName : 'NONE'}`);
  copyToClipboard(markdownUrl);
  // Color the visible page title, never the sandboxed artifact iframe (that
  // was invisible: the iframe's own document ignores the parent's styles).
  if (titleElement) colorChangeFeedback(titleElement);
  else eddyFallbackFeedback();
}

function main() {
  const url = window.location.href;

  if (url.includes('notion.so') || url.includes('notion.site')) {
    const titleElement = document.querySelectorAll('.notion-page-block > h1.notranslate')[0]
    const title = titleElement.textContent.trim();
    const markdownUrl = `[${escapeMarkdownLinkTitle(title)}](${url})`;
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else if (url.includes('github.com')) {
    const { titleElement, prTitle } = getGitHubTitle();
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
    const markdownUrl = `[${escapeMarkdownLinkTitle(title)}](${url})`;
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
  } else if (isLinearAppUrl(url) && url.includes('/issue/')) {
    const titleElement = getLinearTitleElement();
    const title = linearTitleText(titleElement);
    const issueId = linearIssueDisplayId(url);
    const markdownUrl = issueId
      ? `[${issueId}](${url}): \`${title}\``
      : `[${escapeMarkdownLinkTitle(title)}](${url})`;
    copyToClipboard(markdownUrl);
    if (titleElement) colorChangeFeedback(titleElement);
  } else if (isLinearAppUrl(url) && url.includes('/project/')) {
    const titleElement = getLinearTitleElement();
    const title = linearTitleText(titleElement);
    const markdownUrl = `[${escapeMarkdownLinkTitle(title)}](${url})`;
    copyToClipboard(markdownUrl);
    if (titleElement) colorChangeFeedback(titleElement);
  } else if (url.includes('docs.google.com')) {
    const titleElement = document.querySelector('.docs-title-input-label-inner');
    const title = titleElement.textContent.trim();
    const markdownUrl = `[${escapeMarkdownLinkTitle(title)}](${url})`;
    copyToClipboard(markdownUrl);
    colorChangeFeedback(titleElement);
  } else if (isEddyUrl(url)) {
    eddyCopy(url);
  } else {
    const title = document.title.trim();
    const markdownUrl = `[${escapeMarkdownLinkTitle(title)}](${url})`;
    copyToClipboard(markdownUrl);
    const h1s = document.querySelectorAll('h1');
    const h1sWithText = Array.from(h1s).filter(h1 => h1.textContent.trim().length > 0);
    for (const h1 of h1sWithText) {
      colorChangeFeedback(h1);
    }
  }
}

async function githubCopy(titleElement, prTitle, cleanUrl) {
  // Immediate feedback: the click was registered, copy is in progress.
  if (titleElement) setTitleColor(titleElement, PENDING_COLOR);
  try {
    await githubCopyInner(titleElement, prTitle, cleanUrl);
  } catch (e) {
    console.log('[link-shortcut] githubCopy failed:', e);
    if (titleElement) setTitleColor(titleElement, ERROR_COLOR);
  }
}

async function githubCopyInner(titleElement, prTitle, cleanUrl) {
  const { origin } = new URL(cleanUrl);
  const [, org, repo, kind, number] = new URL(cleanUrl).pathname.split('/');
  const displayFor = n => (org === 'headway' ? `${repo}#${n}` : `${org}/${repo}#${n}`);
  // Line counts and stack info are independent network fetches; run them together.
  const [lineCounts, stack] = await Promise.all([
    getPRLineCounts() || (kind === 'pull' ? fetchPRLineCounts(origin, org, repo, number) : ''),
    kind === 'pull' ? getGitHubStack(cleanUrl, number) : null,
  ]);
  const eddyConvoUrl = getEddyConvoLink();
  const eddyLink = eddyConvoUrl ? ` [(Eddy Convo)](${eddyConvoUrl})` : '';
  const hasImages = kind === 'pull' && descriptionHasImagesInDocument(document, number);
  // Start downloading images now so it overlaps with the stack/line-count fetches.
  const imagesPromise = hasImages ? loadPngImages(descriptionImageUrls(document, number)) : Promise.resolve([]);
  const currentLine = `${hasImages ? CAMERA_ICON + ' ' : ''}[${displayFor(number)}](${cleanUrl}): ${formatPRTitle(prTitle)}${eddyLink}${lineCounts ? ' ' + lineCounts : ''}`;

  let text = currentLine;
  let pngs;
  if (stack) {
    // GitHub lists the top of the stack first; emit bottom → top (merge order).
    const pulls = [...stack.pulls].reverse();
    const isCurrent = pr => String(pr.number) === String(number);
    const [counts, imageInfos] = await Promise.all([
      Promise.all(pulls.map(pr => isCurrent(pr) ? lineCounts : fetchPRLineCounts(origin, org, repo, pr.number))),
      Promise.all(pulls.map(pr => isCurrent(pr)
        ? { hasImages, pngs: imagesPromise }
        : fetchPRDescriptionImages(origin, org, repo, pr.number))),
    ]);
    const images = imageInfos.map(info => info.hasImages);
    // Every PR's images, bottom of the stack first (same order as the text lines).
    pngs = (await Promise.all(imageInfos.map(info => info.pngs))).flat();
    const lines = pulls.map((pr, i) => {
      if (isCurrent(pr)) return currentLine;
      const prUrl = pr.url ? new URL(pr.url, origin).href : `${origin}/${org}/${repo}/pull/${pr.number}`;
      const state = pr.state === 'MERGED' ? ' (merged)' : pr.state === 'CLOSED' ? ' (closed)' : '';
      return `${images[i] ? CAMERA_ICON + ' ' : ''}[${displayFor(pr.number)}](${prUrl}): ${formatPRTitle(pr.title || '')}${counts[i] ? ' ' + counts[i] : ''}${state}`;
    });
    text = lines.join('\n');
  } else {
    pngs = await imagesPromise;
  }

  console.log(`[link-shortcut] githubCopy: title="${prTitle}" lineCounts="${lineCounts}" eddy="${eddyConvoUrl || 'none'}" stack=${stack ? stack.size : 0} images=${pngs.length}`);
  // Images go on the clipboard first so the PR text ends up as the latest entry.
  await copyImagesToClipboard(pngs);
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
  const { titleElement, prTitle } = getGitHubTitle();
  githubCopy(titleElement, prTitle, url);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', runPendingPRCopy, { once: true });
} else {
  runPendingPRCopy();
}
