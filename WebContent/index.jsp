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
Index page - warm and welcoming for The-Circle community.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Terrible People — Let's play!</title>
<link rel="stylesheet" type="text/css" href="cah.css" />
<style>
  .welcome-container {
    max-width: 900px;
    margin: 0 auto;
    padding: 2rem 1.5rem;
    animation: fadeIn 0.6s ease-out;
  }
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }
  h1 {
    font-size: 48px;
    margin-bottom: 8px;
  }
  h3 {
    font-size: 20px;
    font-weight: normal;
    margin-bottom: 32px;
    color: var(--circle-muted);
  }
  .info-box {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    padding: 24px 28px;
    margin-bottom: 20px;
    transition: all 0.2s ease;
  }
  .info-box:hover {
    border-color: var(--circle-accent);
  }
  .how-to-play {
    background: var(--circle-accent-soft);
    border-left: 4px solid var(--circle-accent);
  }
  .how-to-play p {
    font-size: 18px;
    margin: 0 0 16px 0;
  }
  .how-to-play ol {
    margin: 0;
    padding-left: 20px;
  }
  .how-to-play li {
    font-size: 16px;
    margin: 12px 0;
    line-height: 1.5;
  }
  .privacy-note {
    font-size: 14px;
    color: var(--circle-muted);
    text-align: center;
    margin: 20px 0;
  }
  .btn-primary {
    background: var(--circle-accent);
    border: none;
    border-radius: 60px;
    padding: 16px 48px;
    font-size: 20px;
    font-weight: bold;
    color: #070a0f;
    cursor: pointer;
    transition: all 0.2s ease;
    animation: pulse 2s infinite;
  }
  .btn-primary:hover {
    animation: none;
    background: #0cdd00;
    transform: scale(1.02);
    box-shadow: 0 0 20px rgba(9,255,3,0.4);
  }
  @keyframes pulse {
    0%, 100% { box-shadow: 0 0 0 0 rgba(9, 255, 3, 0.5); }
    50% { box-shadow: 0 0 0 12px rgba(9, 255, 3, 0); }
  }
  .footer-text {
    font-size: 13px;
    text-align: center;
    margin-top: 40px;
    border-top: 1px solid var(--circle-border);
    padding-top: 24px;
    color: var(--circle-muted);
  }
  .footer-text a {
    color: var(--circle-accent);
    text-decoration: none;
  }
  .footer-text a:hover {
    text-decoration: underline;
  }
  dfn {
    border-bottom: 1px dotted var(--circle-accent);
    cursor: help;
  }
</style>
</head>
<body>

<div class="welcome-container">
  <h1>🎉 Terrible <dfn title="Party game for The-Circle community">People</dfn></h1>
  <h3>A Cards Against Humanity-style party game — get ready to laugh!</h3>

  <!-- HOW TO PLAY - clean and readable -->
  <div class="info-box how-to-play">
    <p><strong>🎲 How to Play</strong></p>
    <ol>
      <li><strong>Pick a nickname</strong> — anything goes!</li>
      <li><strong>Join or create a game</strong> — play with friends or the community</li>
      <li><strong>Get your cards</strong> — one player is the "Card Czar" each round</li>
      <li><strong>Play your funniest white card</strong> to match the black card prompt</li>
      <li><strong>The Czar picks the winner</strong> — that player gets an Awesome Point!</li>
      <li><strong>First to reach the score limit wins!</strong> 🏆</li>
    </ol>
    <p style="margin-top: 16px; font-size: 14px;">💡 <strong>Pro tip:</strong> The funniest or most creative answer usually wins. Be terrible!</p>
  </div>

  <!-- PRIVACY - short and clear -->
  <div class="privacy-note">
    🔒 <strong>Privacy:</strong> Your IP is logged for security only. Gameplay stats are anonymous. 
    <a href="privacy.html" style="color: var(--circle-accent);">Full details →</a>
  </div>

  <!-- BIG PLAY BUTTON -->
  <div style="text-align: center; margin: 32px 0 16px;">
    <input type="button" class="btn-primary" value="🎮 Let's Play →"
      onclick="window.location='game.jsp';" />
  </div>

  <!-- FOOTER -->
  <div class="footer-text">
    Terrible People is hosted by <a href="https://www.the-circle.xyz">The-Circle.xyz</a> • 
    Inspired by Cards Against Humanity • 
    <a href="https://github.com/the-game-stoner/Terrible-People">Source on GitHub</a> • 
    <a href="license.html">License</a> • 
    <a href="changelog.jsp">📋 Changelog</a>
  </div>
</div>

</body>
</html>
