<?xml version="1.0" encoding="UTF-8" ?>
<%--
Copyright (c) 2012-2020, Andy Janata
All rights reserved.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.google.inject.Injector" %>
<%@ page import="com.google.inject.Key" %>
<%@ page import="com.google.inject.TypeLiteral" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="net.socialgamer.cah.RequestWrapper" %>
<%@ page import="net.socialgamer.cah.StartupUtils" %>
<%@ page import="net.socialgamer.cah.data.GameOptions" %>
<%@ page import="net.socialgamer.cah.CahModule" %>
<%@ page import="net.socialgamer.cah.CahModule.*" %>
<%
HttpSession hSession = request.getSession(true);
RequestWrapper wrapper = new RequestWrapper(request);
ServletContext servletContext = pageContext.getServletContext();
Injector injector = (Injector) servletContext.getAttribute(StartupUtils.INJECTOR);
boolean allowBlankCards = injector.getInstance(Key.get(new TypeLiteral<Boolean>(){}, AllowBlankCards.class));
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes" />
<title>Terrible People — Join a Game</title>
<script type="text/javascript" src="js/jquery-1.11.3.min.js"></script>
<script type="text/javascript" src="js/jquery-migrate-1.2.1.js"></script>
<script type="text/javascript" src="js/jquery.cookie.js"></script>
<script type="text/javascript" src="js/jquery.json.js"></script>
<script type="text/javascript" src="js/QTransform.js"></script>
<script type="text/javascript" src="js/jquery-ui.min.js"></script>
<script type="text/javascript" src="js/cah.js"></script>
<script type="text/javascript" src="js/cah.config.js"></script>
<script type="text/javascript" src="js/cah.constants.js"></script>
<script type="text/javascript" src="js/cah.log.js"></script>
<script type="text/javascript" src="js/cah.gamelist.js"></script>
<script type="text/javascript" src="js/cah.card.js"></script>
<script type="text/javascript" src="js/cah.cardset.js"></script>
<script type="text/javascript" src="js/cah.game.js"></script>
<script type="text/javascript" src="js/cah.preferences.js"></script>
<script type="text/javascript" src="js/cah.longpoll.js"></script>
<script type="text/javascript" src="js/cah.longpoll.handlers.js"></script>
<script type="text/javascript" src="js/cah.ajax.js"></script>
<script type="text/javascript" src="js/cah.ajax.builder.js"></script>
<script type="text/javascript" src="js/cah.ajax.handlers.js"></script>
<script type="text/javascript" src="js/cah.app.js"></script>
<link rel="stylesheet" type="text/css" href="cah.css" media="screen" />
<link rel="stylesheet" type="text/css" href="jquery-ui.min.css" media="screen" />
<style>
  #welcome { animation: fadeIn 0.5s ease-out; }
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(15px); }
    to { opacity: 1; transform: translateY(0); }
  }
</style>
</head>
<body id="gamebody">

<div id="welcome" class="welcome-container">
  <h1>Terrible <dfn title="Party game for The-Circle community">People</dfn></h1>
  <h3>A party game for The-Circle community.</h3>
  <div class="info-box">
    <p>✨ Choose a nickname and join the fun. No registration required — just jump in!</p>
  </div>
  <div id="nickbox" class="nickbox">
    <label for="nickname">🎭 Your Nickname</label>
    <input type="text" id="nickname" value="" maxlength="30" role="textbox" aria-label="Enter your nickname." data-lpignore="true" placeholder="e.g., FunnyGuy, QueenOfCards" />
    <label for="idcode">
      <dfn title="Only available via HTTPS. Provide a secret identification code to positively identify yourself.">🔐 Optional Identification Code</dfn>
    </label>
    <input type="password" id="idcode" value="" maxlength="100" disabled="disabled" aria-label="Optionally enter an identification code." placeholder="For returning players (optional)" />
    <a href="https://github.com/ajanata/PretendYoureXyzzy/wiki/Identification-Codes">ℹ️ What's this?</a>
    <span id="nickbox_error" class="error"></span>
    <div style="text-align: center; margin-top: 1.5rem;">
      <input type="button" class="btn-primary" id="nicknameconfirm" value="🎮 Set Nickname & Enter Game →" />
    </div>
  </div>
  <p style="text-align: center; font-size: 0.85rem; color: var(--circle-muted);">
    <a href="privacy.html" style="color: var(--circle-accent);">📋 Privacy info</a> — We log IPs for security only.
  </p>
  <p class="footer-text">
    Terrible People is a party game for The-Circle community, inspired by Cards Against Humanity.<br />
    <a href="https://github.com/the-game-stoner/Terrible-People">Source code</a> • <a href="license.html">License</a>
  </p>
</div>

<div id="main_container" class="hide">

  <div id="canvas">
    <div id="menubar">
      <div id="menubar_left">
        <input type="button" id="refresh_games" class="hide" value="Refresh Games" />
        <input type="button" id="create_game" class="hide" value="Create Game" />
        <input type="text" id="filter_games" class="hide" placeholder="Filter games" data-lpignore="true"/>
        <input type="button" id="leave_game" class="hide" value="Leave Game" />
        <input type="button" id="start_game" class="hide" value="Start Game" />
        <input type="button" id="stop_game" class="hide" value="Stop Game" />
      </div>
      <div id="menubar_right">
        Timer: <span id="current_timer">0</span>s
        <input type="button" id="view_cards" value="View Cards" onclick="window.open('viewcards.jsp', 'viewcards');" />
        <input type="button" id="logout" value="Log out" />
      </div>
    </div>
    <div id="main">
      <div id="game_list" class="hide"></div>
      <div id="main_holder"></div>
    </div>
  </div>

  <div id="bottom">
    <div id="info_area"></div>
    <div id="tabs">
      <ul>
        <li><a href="#tab-preferences" class="tab-button">User Preferences</a></li>
        <li><a href="#tab-gamelist-filters" class="tab-button">Game List Filters</a></li>
        <li><a href="#tab-global" class="tab-button" id="button-global">Global Chat</a></li>
      </ul>
      <div id="tab-preferences">
        <input type="button" value="Save" onclick="cah.Preferences.save();" />
        <input type="button" value="Revert" onclick="cah.Preferences.load();" />
        <label for="hide_connect_quit">Hide connect/quit events:</label>
        <input type="checkbox" id="hide_connect_quit" /><br />
        <label for="ignore_list">Ignore list (one per line):</label><br/>
        <textarea id="ignore_list" style="width: 200px; height: 100px"></textarea>
      </div>
      <div id="tab-gamelist-filters">
         <input type="button" value="Save" onclick="cah.Preferences.save();" />
         <fieldset><legend>Filters</legend>
         <select id="cardsets_neutral" multiple="multiple" style="width:100%; height:80px;"></select>
         </fieldset>
      </div>
      <div id="tab-global">
        <div class="log" id="log_global"></div>
        <div class="chat-input-wrapper">
          <input type="text" class="chat" id="chat_global" maxlength="200" aria-label="Type here to chat." data-lpignore="true" placeholder="Say something..." />
          <input type="button" class="chat_submit" id="chat_submit_global" value="Send" />
        </div>
      </div>
    </div>
  </div>

  <div id="gamelist_lobby_template" class="hide">
    <div class="gamelist_lobby">
      <div class="gamelist_lobby_left">
        <h3><span class="gamelist_lobby_host"></span>'s Game</h3>
        <div><strong>Players:</strong> <span class="gamelist_lobby_players"></span></div>
      </div>
      <div class="gamelist_lobby_right">
        <input type="button" class="gamelist_lobby_join" value="Join" />
      </div>
    </div>
  </div>

  <div id="black_up_template" class="hide">
    <div class="card blackcard">
      <span class="card_text"></span>
      <div class="logo"><div class="logo_text">Terrible People</div></div>
    </div>
  </div>

  <div id="white_up_template" class="hide">
    <div class="card whitecard">
      <span class="card_text"></span>
      <div class="logo"><div class="logo_text">Terrible People</div></div>
    </div>
  </div>

  <div id="game_template" class="hide">
    <div class="game">
      <div class="game_top">
        <input type="button" class="game_show_options game_menu_bar" value="Options" />
        <div class="game_message"></div>
      </div>
      <div class="game_left_side">
        <div class="game_black_card"></div>
        <input type="button" class="confirm_card" value="Confirm" />
      </div>
      <div class="game_right_side">
          <div class="game_right_side_box">
              <div class="game_right_side_cards"></div>
          </div>
      </div>
      <div class="game_hand"><div class="game_hand_cards"></div></div>
    </div>
  </div>

  <div id="white_down_template" class="hide"><div class="card whitecard"></div></div>
  <div id="black_down_template" class="hide"><div class="card blackcard"></div></div>
  <div id="scoreboard_template" class="hide"><div class="scoreboard"><div class="game_message">Scoreboard</div></div></div>
  <div id="scorecard_template" class="hide">
    <div class="scorecard">
      <span class="scorecard_player"></span>
      <span class="scorecard_points"><span class="scorecard_score">0</span> Awesome Points</span>
      <span class="scorecard_status"></span>
    </div>
  </div>
</div>

<div style="position:absolute; left:-99999px" role="alert" id="aria-notifications"></div>
</body>
</html>
