// ==UserScript==
// @name         Auto-Close Zoom Launch Tabs
// @namespace    headway
// @version      1.0
// @description  Closes the "Launch Meeting" tab Zoom opens after triggering the desktop app
// @match        https://headway-co.zoom.us/*
// @grant        window.close
// @run-at       document-idle
// ==/UserScript==

(function () {
    'use strict';
  
    if (location.hash.includes('success')) {
      setTimeout(() => window.close(), 1500);
    }
  })();
  