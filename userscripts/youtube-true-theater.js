// ==UserScript==
// @name         YouTube True Theater Mode
// @namespace    http://tampermonkey.net/
// @version      3.0
// @description  Twitch-style theater: just the video, nothing else. Shift+T to toggle, Escape to exit.
// @author       mjperrone
// @match        *://*.youtube.com/*
// @icon         https://www.google.com/s2/favicons?domain=youtube.com
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    'use strict';

    let active = false;
    let cursorTimer = null;

    const style = document.createElement('style');
    style.textContent = `
        /* Always-on theater mode fixes (scroll + grid overlay) */
        ytd-app {
            overflow: auto !important;
        }
        ytd-app[scrolling] {
            position: absolute !important;
            top: 0 !important;
            left: 0 !important;
            right: calc((var(--ytd-app-fullerscreen-scrollbar-width) + 1px)*-1) !important;
            bottom: 0 !important;
            overflow-x: auto !important;
        }
        ytd-watch-flexy[full-bleed-player] #single-column-container.ytd-watch-flexy,
        ytd-watch-flexy[full-bleed-player] #columns.ytd-watch-flexy {
            display: flex !important;
        }
        .ytp-fullscreen-grid-peeking.ytp-full-bleed-player.ytp-delhi-modern:not(.ytp-autohide) .ytp-chrome-bottom {
            bottom: 0 !important;
            opacity: 1 !important;
        }
        #movie_player:not(.ytp-grid-ended-state) .ytp-fullscreen-grid {
            display: none !important;
            top: 100% !important;
            opacity: 0 !important;
        }

        /* True theater mode — toggled with Shift+T */
        body.true-theater {
            overflow: hidden !important;
        }
        body.true-theater #masthead-container,
        body.true-theater #below,
        body.true-theater #secondary,
        body.true-theater #chat-container,
        body.true-theater ytd-miniplayer,
        body.true-theater tp-yt-app-drawer,
        body.true-theater #guide-wrapper {
            display: none !important;
        }
        body.true-theater #page-manager {
            margin-top: 0 !important;
        }
        body.true-theater #full-bleed-container {
            max-height: none !important;
            height: 100vh !important;
            width: 100vw !important;
        }
        body.true-theater #player-theater-container {
            max-height: none !important;
            height: 100% !important;
        }
        body.true-theater #movie_player {
            max-height: none !important;
            max-width: none !important;
            width: 100% !important;
            height: 100% !important;
            background: #000 !important;
        }
        body.true-theater .html5-video-container {
            width: 100% !important;
            height: 100% !important;
        }
        body.true-theater .html5-video-container video {
            width: 100% !important;
            height: 100% !important;
            left: 0 !important;
            top: 0 !important;
        }
        body.true-theater-hide-cursor #movie_player,
        body.true-theater-hide-cursor #movie_player * {
            cursor: none !important;
        }
    `;

    function injectStyle() {
        if (document.head) {
            document.head.appendChild(style);
        } else {
            document.addEventListener('DOMContentLoaded', () => document.head.appendChild(style));
        }
    }

    function ensureTheaterMode() {
        const flexy = document.querySelector('ytd-watch-flexy');
        if (flexy && !flexy.hasAttribute('theater')) {
            const btn = document.querySelector('.ytp-size-button');
            if (btn) btn.click();
        }
    }

    function toggle(state) {
        active = state !== undefined ? state : !active;
        document.body.classList.toggle('true-theater', active);
        if (active) {
            ensureTheaterMode();
            startCursorAutoHide();
        } else {
            stopCursorAutoHide();
            document.body.classList.remove('true-theater-hide-cursor');
        }
        requestAnimationFrame(() => {
            window.dispatchEvent(new Event('resize'));
        });
    }

    function startCursorAutoHide() {
        document.addEventListener('mousemove', resetCursorTimer);
        scheduleCursorHide();
    }

    function stopCursorAutoHide() {
        document.removeEventListener('mousemove', resetCursorTimer);
        clearTimeout(cursorTimer);
    }

    function resetCursorTimer() {
        document.body.classList.remove('true-theater-hide-cursor');
        scheduleCursorHide();
    }

    function scheduleCursorHide() {
        clearTimeout(cursorTimer);
        cursorTimer = setTimeout(() => {
            if (active) document.body.classList.add('true-theater-hide-cursor');
        }, 2500);
    }

    function onKeydown(e) {
        const tag = e.target.tagName;
        if (tag === 'INPUT' || tag === 'TEXTAREA' || e.target.isContentEditable) return;

        if (e.key === 'T' && e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey) {
            e.preventDefault();
            e.stopPropagation();
            toggle();
        }
        if (e.key === 'Escape' && active) {
            toggle(false);
        }
    }

    injectStyle();
    document.addEventListener('keydown', onKeydown, true);

    // Exit on SPA navigation away from a video page
    window.addEventListener('yt-navigate-finish', () => {
        if (active && !location.pathname.startsWith('/watch')) {
            toggle(false);
        }
    });
})();
