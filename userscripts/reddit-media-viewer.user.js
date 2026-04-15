// ==UserScript==
// @name         Reddit Media Viewer
// @namespace    https://github.com/mjperrone
// @version      1.0
// @description  Grid + lightbox media viewer for Reddit feeds
// @match        https://www.reddit.com/
// @match        https://www.reddit.com/r/*
// @match        https://old.reddit.com/
// @match        https://old.reddit.com/r/*
// @grant        GM_xmlhttpRequest
// @connect      www.reddit.com
// @connect      preview.redd.it
// @connect      i.redd.it
// @connect      v.redd.it
// @require      https://cdn.jsdelivr.net/npm/hls.js@latest/dist/hls.min.js
// ==/UserScript==

(function () {
  'use strict';

  let mediaItems = []; // { url, type, postTitle, postUrl }
  let after = null;
  let loading = false;
  let current = -1;
  let fitMode = 'fit';
  let colCount = 5;
  let overlayVisible = false;

  // --- reddit API helpers ---

  function getSubredditPath() {
    const m = location.pathname.match(/^\/r\/[^/]+/);
    return m ? m[0] : '';
  }

  function fetchPage(afterToken) {
    return new Promise((resolve, reject) => {
      const base = `https://www.reddit.com${getSubredditPath()}/.json?raw_json=1&limit=25`;
      const url = afterToken ? `${base}&after=${afterToken}` : base;
      GM_xmlhttpRequest({
        method: 'GET',
        url,
        headers: { 'Accept': 'application/json' },
        onload: (resp) => {
          try { resolve(JSON.parse(resp.responseText)); }
          catch (e) { reject(e); }
        },
        onerror: reject,
      });
    });
  }

  function extractMedia(listing) {
    const items = [];
    for (const child of listing.data.children) {
      const d = child.data;
      if (d.over_18) continue; // skip NSFW by default

      const postInfo = { postTitle: d.title, postUrl: `https://www.reddit.com${d.permalink}` };

      // gallery
      if (d.is_gallery && d.media_metadata && d.gallery_data) {
        for (const gi of d.gallery_data.items) {
          const meta = d.media_metadata[gi.media_id];
          if (!meta || meta.status !== 'valid') continue;
          if (meta.e === 'Image') {
            const url = meta.s.u || meta.s.gif;
            if (url) items.push({ url, type: 'image', ...postInfo });
          } else if (meta.e === 'AnimatedImage') {
            const url = meta.s.mp4 || meta.s.gif;
            if (url) items.push({ url, type: meta.s.mp4 ? 'video' : 'image', ...postInfo });
          }
        }
        continue;
      }

      // video
      const previewThumb = d.preview && d.preview.images && d.preview.images[0] && d.preview.images[0].source
        ? d.preview.images[0].source.url : null;

      if (d.is_video && d.media && d.media.reddit_video) {
        const rv = d.media.reddit_video;
        items.push({ url: rv.fallback_url, hlsUrl: rv.hls_url, type: 'video', thumb: previewThumb, ...postInfo });
        continue;
      }
      if (d.secure_media && d.secure_media.reddit_video) {
        const rv = d.secure_media.reddit_video;
        items.push({ url: rv.fallback_url, hlsUrl: rv.hls_url, type: 'video', thumb: previewThumb, ...postInfo });
        continue;
      }

      // single image
      if (d.post_hint === 'image' && d.url) {
        items.push({ url: d.url, type: 'image', ...postInfo });
        continue;
      }

      // preview fallback
      if (d.preview && d.preview.images && d.preview.images.length) {
        const src = d.preview.images[0].source;
        if (src && src.url) {
          items.push({ url: src.url, type: 'image', ...postInfo });
        }
      }
    }
    return items;
  }

  async function loadMore() {
    if (loading) return;
    loading = true;
    updateLoadBtn('Loading...');
    try {
      const data = await fetchPage(after);
      after = data.data.after;
      const newItems = extractMedia(data);
      const startIdx = mediaItems.length;
      mediaItems.push(...newItems);
      appendGridItems(startIdx);
      updateLoadBtn(after ? `Load more (${mediaItems.length} loaded)` : 'No more posts');
      if (!after) loadBtn.disabled = true;
    } catch (e) {
      console.error('Reddit Media Viewer: fetch error', e);
      updateLoadBtn('Error loading — try again');
    }
    loading = false;
  }

  // --- build UI ---

  function createUI() {
    // toggle button
    const toggle = document.createElement('button');
    toggle.id = 'rmv-toggle';
    toggle.textContent = 'Media';
    toggle.addEventListener('click', () => {
      overlayVisible = !overlayVisible;
      overlay.style.display = overlayVisible ? 'flex' : 'none';
      if (overlayVisible && mediaItems.length === 0) loadMore();
    });
    document.body.appendChild(toggle);

    // overlay
    const overlay = document.createElement('div');
    overlay.id = 'rmv-overlay';
    overlay.innerHTML = `
      <div id="rmv-toolbar">
        <button class="rmv-col-btn" id="rmv-col-minus">&minus;</button>
        <span id="rmv-col-val">${colCount}</span>
        <button class="rmv-col-btn" id="rmv-col-plus">+</button>
        <span id="rmv-count"></span>
        <button id="rmv-close-overlay">Close</button>
      </div>
      <div id="rmv-grid"></div>
      <button id="rmv-load-more">Load media</button>
      <div id="rmv-lightbox">
        <div id="rmv-lb-top">
          <span id="rmv-lb-title"></span>
          <button id="rmv-lb-mode">Fill</button>
          <button id="rmv-lb-close">&times;</button>
        </div>
        <div class="rmv-zone rmv-zone-left" id="rmv-zone-left"></div>
        <div class="rmv-zone rmv-zone-right" id="rmv-zone-right"></div>
        <div class="rmv-media-wrap rmv-fit" id="rmv-media-wrap"></div>
        <div id="rmv-lb-counter"></div>
      </div>
    `;
    document.body.appendChild(overlay);

    // wire up
    document.getElementById('rmv-close-overlay').addEventListener('click', () => {
      overlayVisible = false;
      overlay.style.display = 'none';
    });

    document.getElementById('rmv-col-minus').addEventListener('click', () => { colCount++; applyCols(); });
    document.getElementById('rmv-col-plus').addEventListener('click', () => { if (colCount > 1) { colCount--; applyCols(); } });

    document.getElementById('rmv-load-more').addEventListener('click', loadMore);

    document.getElementById('rmv-zone-left').addEventListener('click', () => nav(-1));
    document.getElementById('rmv-zone-right').addEventListener('click', () => nav(1));
    document.getElementById('rmv-lb-close').addEventListener('click', closeLightbox);
    document.getElementById('rmv-lb-mode').addEventListener('click', () => {
      fitMode = fitMode === 'fit' ? 'fill' : 'fit';
      const wrap = document.getElementById('rmv-media-wrap');
      wrap.classList.toggle('rmv-fit', fitMode === 'fit');
      wrap.classList.toggle('rmv-fill', fitMode === 'fill');
      document.getElementById('rmv-lb-mode').textContent = fitMode === 'fit' ? 'Fill' : 'Fit';
    });

    document.addEventListener('keydown', (e) => {
      if (!overlayVisible) return;
      if (e.key === 'ArrowUp')   { if (colCount > 1) { colCount--; applyCols(); } e.preventDefault(); return; }
      if (e.key === 'ArrowDown') { colCount++; applyCols(); e.preventDefault(); return; }
      if (current === -1) return;
      if (e.key === 'ArrowLeft')  { nav(-1); e.preventDefault(); }
      if (e.key === 'ArrowRight') { nav(1); e.preventDefault(); }
      if (e.key === 'Escape')     { closeLightbox(); e.preventDefault(); }
      if (e.key === 'f')          {
        fitMode = fitMode === 'fit' ? 'fill' : 'fit';
        const wrap = document.getElementById('rmv-media-wrap');
        wrap.classList.toggle('rmv-fit', fitMode === 'fit');
        wrap.classList.toggle('rmv-fill', fitMode === 'fill');
        document.getElementById('rmv-lb-mode').textContent = fitMode === 'fit' ? 'Fill' : 'Fit';
      }
      if (e.key === 'm') {
        const vid = document.getElementById('rmv-media-wrap').querySelector('video');
        if (vid) vid.muted = !vid.muted;
      }
    });

    return overlay;
  }

  const overlay = createUI();
  const loadBtn = document.getElementById('rmv-load-more');

  function updateLoadBtn(text) { loadBtn.textContent = text; }

  function applyCols() {
    document.getElementById('rmv-col-val').textContent = colCount;
    document.getElementById('rmv-grid').style.setProperty('grid-template-columns', `repeat(${colCount}, 1fr)`, 'important');
  }

  function appendGridItems(startIdx) {
    const grid = document.getElementById('rmv-grid');
    for (let i = startIdx; i < mediaItems.length; i++) {
      const item = mediaItems[i];
      const cell = document.createElement('div');
      cell.className = 'rmv-thumb';
      cell.addEventListener('click', ((idx) => () => openLightbox(idx))(i));

      const img = document.createElement('img');
      img.src = (item.type === 'video' && item.thumb) ? item.thumb : item.url;
      img.loading = 'lazy';
      cell.appendChild(img);

      if (item.type === 'video') {
        const badge = document.createElement('div');
        badge.className = 'rmv-vid-badge';
        badge.textContent = '\u25B6';
        cell.appendChild(badge);
      }
      grid.appendChild(cell);
    }
    document.getElementById('rmv-count').textContent = `${mediaItems.length} items`;
    applyCols();
  }

  // --- lightbox ---

  function openLightbox(idx) {
    current = idx;
    document.getElementById('rmv-lightbox').style.display = 'flex';
    showItem();
  }

  function closeLightbox() {
    document.getElementById('rmv-lightbox').style.display = 'none';
    document.getElementById('rmv-media-wrap').innerHTML = '';
    current = -1;
  }

  function showItem() {
    const wrap = document.getElementById('rmv-media-wrap');
    wrap.innerHTML = '';
    const item = mediaItems[current];

    if (item.type === 'image') {
      const img = document.createElement('img');
      img.src = item.url;
      wrap.appendChild(img);
    } else {
      const vid = document.createElement('video');
      vid.controls = true;
      vid.autoplay = true;
      vid.loop = true;
      wrap.appendChild(vid);

      if (item.hlsUrl && typeof Hls !== 'undefined' && Hls.isSupported()) {
        const hls = new Hls();
        hls.loadSource(item.hlsUrl);
        hls.attachMedia(vid);
      } else if (item.hlsUrl && vid.canPlayType('application/vnd.apple.mpegurl')) {
        // Safari native HLS
        vid.src = item.hlsUrl;
      } else {
        vid.src = item.url;
      }
    }

    document.getElementById('rmv-lb-counter').textContent = `${current + 1} / ${mediaItems.length}`;
    document.getElementById('rmv-lb-title').textContent = item.postTitle;
  }

  function nav(delta) {
    if (current === -1) return;
    current = (current + delta + mediaItems.length) % mediaItems.length;
    showItem();
    // auto-load more when near the end
    if (current >= mediaItems.length - 5 && after && !loading) loadMore();
  }

  // --- styles ---

  const style = document.createElement('style');
  style.textContent = `
    #rmv-toggle {
      position: fixed;
      bottom: 16px;
      right: 16px;
      z-index: 99999;
      background: #333;
      color: #eee;
      border: 2px solid #555;
      border-radius: 8px;
      padding: 8px 16px;
      font-size: 14px;
      cursor: pointer;
      font-family: system-ui, sans-serif;
    }
    #rmv-toggle:hover { background: #444; border-color: #888; }

    #rmv-overlay {
      display: none;
      flex-direction: column;
      position: fixed;
      inset: 0;
      z-index: 100000;
      background: #1a1a1a;
      font-family: system-ui, sans-serif;
      color: #eee;
    }

    #rmv-toolbar {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: 10px 14px;
      background: #222;
      border-bottom: 1px solid #333;
      flex-shrink: 0;
    }

    .rmv-col-btn {
      background: #333;
      color: #ccc;
      border: 1px solid #555;
      width: 28px;
      height: 28px;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
      line-height: 1;
    }
    .rmv-col-btn:hover { background: #444; color: #fff; }

    #rmv-col-val { font-size: 13px; color: #888; min-width: 16px; text-align: center; }
    #rmv-count { font-size: 13px; color: #666; margin-left: auto; }

    #rmv-close-overlay {
      background: #333;
      color: #ccc;
      border: 1px solid #555;
      padding: 4px 12px;
      border-radius: 4px;
      font-size: 13px;
      cursor: pointer;
    }
    #rmv-close-overlay:hover { background: #444; color: #fff; }

    #rmv-grid {
      display: grid !important;
      padding: 12px !important;
      gap: 8px !important;
      grid-template-columns: repeat(5, 1fr) !important;
      overflow-y: auto !important;
      flex: 1 !important;
      position: relative !important;
    }

    .rmv-thumb {
      position: relative !important;
      padding-bottom: 100% !important;
      height: 0 !important;
      overflow: hidden !important;
      border-radius: 6px !important;
      cursor: pointer !important;
      background: #222 !important;
    }
    .rmv-thumb img {
      position: absolute !important;
      top: 0 !important;
      left: 0 !important;
      width: 100% !important;
      height: 100% !important;
      object-fit: cover !important;
      display: block !important;
    }
    .rmv-thumb:hover { outline: 2px solid #6af; outline-offset: -2px; }

    .rmv-vid-badge {
      position: absolute !important;
      bottom: 6px !important;
      right: 6px !important;
      width: 28px !important;
      height: 28px !important;
      background: rgba(0,0,0,.7) !important;
      color: #fff !important;
      font-size: 14px !important;
      border-radius: 50% !important;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      pointer-events: none !important;
    }

    #rmv-load-more {
      flex-shrink: 0;
      padding: 12px;
      background: #222;
      color: #aaa;
      border: none;
      border-top: 1px solid #333;
      font-size: 14px;
      cursor: pointer;
      font-family: system-ui, sans-serif;
    }
    #rmv-load-more:hover { background: #333; color: #eee; }
    #rmv-load-more:disabled { color: #555; cursor: default; }

    /* lightbox */
    #rmv-lightbox {
      display: none;
      position: fixed;
      inset: 0;
      background: #000;
      z-index: 100001;
      align-items: center;
      justify-content: center;
    }

    .rmv-media-wrap {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
    }

    .rmv-fit img, .rmv-fit video {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }
    .rmv-fill img, .rmv-fill video {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .rmv-zone {
      position: absolute;
      top: 0;
      bottom: 0;
      z-index: 10;
    }
    .rmv-zone-left  { left: 0; width: 33.33%; cursor: w-resize; }
    .rmv-zone-right { right: 0; width: 33.33%; cursor: e-resize; }

    #rmv-lb-top {
      position: absolute;
      top: 0; left: 0; right: 0;
      z-index: 20;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 10px 16px;
      gap: 16px;
      pointer-events: none;
    }
    #rmv-lb-top > * { pointer-events: auto; }

    #rmv-lb-title {
      background: rgba(0,0,0,.55);
      padding: 4px 14px;
      border-radius: 12px;
      font-size: 13px;
      color: #aaa;
      max-width: 50%;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    #rmv-lb-mode {
      background: rgba(0,0,0,.6);
      color: #ccc;
      border: 1px solid rgba(255,255,255,.15);
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 13px;
      cursor: pointer;
    }
    #rmv-lb-mode:hover { background: rgba(255,255,255,.15); color: #fff; }

    #rmv-lb-close {
      position: absolute;
      right: 16px;
      background: rgba(0,0,0,.6);
      color: #ccc;
      border: none;
      font-size: 28px;
      width: 40px;
      height: 40px;
      border-radius: 50%;
      cursor: pointer;
      line-height: 1;
    }
    #rmv-lb-close:hover { background: rgba(255,255,255,.15); color: #fff; }

    #rmv-lb-counter {
      position: absolute;
      bottom: 14px;
      left: 50%;
      transform: translateX(-50%);
      z-index: 20;
      background: rgba(0,0,0,.55);
      padding: 4px 14px;
      border-radius: 12px;
      font-size: 14px;
      color: #aaa;
      pointer-events: none;
    }
  `;
  document.head.appendChild(style);
})();
