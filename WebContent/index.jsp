<?xml version="1.0" encoding="UTF-8" ?>
<%--
Copyright (c) 2012-2018, Andy Janata
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted
provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions
  and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of
  conditions and the following disclaimer in the documentation and/or other materials provided
  with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--%>
<%--
Index page - cleaned and modernized for The-Circle theme.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Terrible People — A party game for The-Circle community</title>
<link rel="stylesheet" type="text/css" href="cah.css" />
<style>
  .welcome-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem 1.5rem;
    animation: fadeIn 0.6s ease-out;
  }
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .info-box {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: var(--circle-radius);
    padding: 1rem 1.25rem;
    margin-bottom: 1.25rem;
    transition: all 0.2s ease;
  }
  .info-box:hover {
    border-color: var(--circle-accent);
    transform: translateX(4px);
  }
  .btn-primary {
    background: var(--circle-accent);
    border: none;
    border-radius: 40px;
    padding: 12px 32px;
    font-size: 1rem;
    font-weight: bold;
    color: #000;
    cursor: pointer;
    transition: all 0.2s ease;
    animation: pulse 2s infinite;
  }
  .btn-primary:hover {
    animation: none;
    background: #0cdd00;
    transform: scale(1.02);
  }
  @keyframes pulse {
    0%, 100% { box-shadow: 0 0 0 0 rgba(9, 255, 3, 0.4); }
    50% { box-shadow: 0 0 0 8px rgba(9, 255, 3, 0); }
  }
  .footer-text {
    font-size: 11px;
    text-align: center;
    margin-top: 2rem;
    border-top: 1px solid var(--circle-border);
    padding-top: 1.5rem;
  }
  details.info-box summary {
    cursor: pointer;
    font-weight: bold;
  }
  details.info-box summary:hover {
    color: var(--circle-accent);
  }
</style>
</head>
<body>

<div class="welcome-container">
  <h1>Terrible <dfn title="Party game for The-Circle community">People</dfn></h1>
  <h3>A party game for The-Circle community.</h3>

  <div class="info-box">
    <p>🔒 Your IP address is logged for security. Gameplay results are logged anonymously.</p>
  </div>

  <div class="info-box" style="background: var(--circle-accent-soft); border-color: var(--circle-accent);">
    <p style="margin: 0; font-weight: bold;">✨ Quick Start:</p>
    <ol style="margin: 0.5rem 0 0 1.25rem;">
      <li>Enter a nickname</li>
      <li>Join an existing game or create your own</li>
      <li>Wait for the Card Czar to start the round</li>
      <li>Pick the funniest white card to win Awesome Points!</li>
    </ol>
  </div>

  <details class="info-box" open>
    <summary><strong>📖 About the Game</strong></summary>
    <ul>
      <li><strong>Players:</strong> 3-20 players recommended</li>
      <li><strong>Game length:</strong> 15-45 minutes</li>
      <li><strong>Mobile friendly:</strong> Works on phones and tablets</li>
    </ul>
  </details>

  <details class="info-box">
    <summary><strong>💡 Tips</strong></summary>
    <ul>
      <li>Don't open the game in multiple tabs</li>
      <li>Refresh if something looks wrong</li>
      <li>Resize window if cards overlap</li>
    </ul>
  </details>

  <div style="text-align: center; margin: 1.5rem 0;">
    <input type="button" class="btn-primary" value="🎮 Take me to the game!"
      onclick="window.location='game.jsp';" />
  </div>

  <p class="footer-text">
    Terrible People is a party game for The-Circle community, inspired by Cards Against Humanity.
    <br />
    <a href="https://github.com/the-game-stoner/Terrible-People">Source code</a> • 
    <a href="license.html">License</a> • 
    <a href="privacy.html">Privacy</a>
  </p>
</div>

</body>
</html>
