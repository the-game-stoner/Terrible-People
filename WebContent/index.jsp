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
Index page.

@author Andy Janata (ajanata@socialgamer.net)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Terrible People</title>
<link rel="stylesheet" type="text/css" href="cah.css" media="screen" />
</head>
<body>

<div class="welcome-container">
  <h1>
    Terrible <dfn style="border-bottom: 1px dotted var(--circle-accent)"
    title="Party game for The-Circle community">People</dfn>
  </h1>
  <h3>A party game for The-Circle community.</h3>

  <div class="info-box">
    <p>
      Your computer's IP address will <strong>always</strong> be logged when you load the game client.
      It is not tied in any way to your username, except possibly if a server error occurs. Gameplay
      results are logged permanently, but without information identifying you.
    </p>
  </div>

  <div class="info-box">
    <p><strong>Recent Changes:</strong></p>
    <ul>
      <li>3 September 2018: All chat and fill-in-the-blank cards have been disabled.
      <a href="https://gist.githubusercontent.com/ajanata/07ededdb584f7bb77a8c7191d3a4bbcc/raw/e76faacc19c2bb598a1a8fd94b9ebcb29c5502e0">
      Learn why.</a></li>
      <li><a href="changelog.html">Older entries.</a></li>
    </ul>
  </div>

  <details class="info-box">
    <summary><strong>Known Issues</strong></summary>
    <ul>
      <li><strong>Do not open the game more than once in the same browser.</strong> Neither instance
      will receive all data from the server, and you will not be able to play.</li>
      <li>This game was extensively tested in <a href="http://google.com/chrome">Google Chrome</a>.
      It should work in all recent versions of major browsers, but it may not look 100% as intended.</li>
      <li>You may not always see your card in the top area after you play it, but it has been played.</li>
      <li>If you refresh in the game, an error will pop up in the log briefly before the refresh
      happens. It is safe to ignore.</li>
      <li>Interface elements may not be perfectly sized and positioned immediately after loading the
      page if your window is sufficiently small. Resize the window to fix.</li>
      <li>A player joining the game in progress may have a slightly incorrect representation of the
      game state until the next round begins.</li>
    </ul>
  </details>

  <details class="info-box">
    <summary><strong>Current Limitations</strong></summary>
    <ul>
      <li>Support for Black Cards with "pick" and/or "draw" annotations is rudimentary.</li>
      <li>You cannot un-do your first (or second) card: Once it's played, it's played.</li>
      <li>When you have a lot of players, cards may overlap your hand. Resize the window to help.</li>
      <li>You can't bet Awesome Points to play another card.</li>
    </ul>
  </details>

  <div class="info-box">
    <p><strong>Future enhancements:</strong></p>
    <ul>
      <li>There may be an option to display who played every card.</li>
      <li>A registration system and long-term statistics tracking may be added at some point.</li>
    </ul>
  </div>

  <p>
    If the game seems to be in a weird state, refresh the page and it should take you back to where
    you were. Please report bugs on
    <a href="https://github.com/ajanata/PretendYoureXyzzy/issues/new">GitHub</a>.
  </p>

  <div class="button-container">
    <input type="button" class="btn-primary" value="Take me to the game!"
      onclick="window.location='game.jsp';" />
  </div>

  <p class="footer-text">
    Terrible People is a party game for The-Circle community, inspired by Cards Against Humanity,
    available at <a href="http://www.cardsagainsthumanity.com/">cardsagainsthumanity.com</a>.
    This web version is in no way endorsed or sponsored by cardsagainsthumanity.com.
    Source code available on <a href="https://github.com/ajanata/PretendYoureXyzzy">GitHub</a>.
    See <a href="license.html">full license information</a>.
  </p>
</div>

</body>
</html>
