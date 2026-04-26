<%--
Copyright (c) 2012-2020, Andy Janata | Modified for Terrible People
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.google.inject.Injector, com.google.inject.Key, com.google.inject.TypeLiteral" %>
<%@ page import="javax.servlet.http.HttpSession, net.socialgamer.cah.RequestWrapper, net.socialgamer.cah.StartupUtils" %>
<%@ page import="net.socialgamer.cah.data.GameOptions, net.socialgamer.cah.CahModule, net.socialgamer.cah.CahModule.*" %>
<%
    HttpSession hSession = request.getSession(true);
    RequestWrapper wrapper = new RequestWrapper(request);
    ServletContext servletContext = pageContext.getServletContext();
    Injector injector = (Injector) servletContext.getAttribute(StartupUtils.INJECTOR);
    boolean allowBlankCards = injector.getInstance(Key.get(new TypeLiteral<Boolean>(){}, AllowBlankCards.class));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Terrible People — Join a Game</title>
    
    <link rel="stylesheet" href="cah.css" />
    <link rel="stylesheet" href="jquery-ui.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg-color: #121212;
            --card-white: #ffffff;
            --card-black: #1e1e1e;
            --accent: #ff3e3e;
            --text-main: #e0e0e0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            margin: 0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* Welcome Screen Styling */
        .welcome-container {
            max-width: 500px;
            margin: 60px auto;
            padding: 30px;
            background: #1d1d1d;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            text-align: center;
        }

        h1 { font-weight: 800; font-size: 2.5rem; margin-bottom: 0.5rem; color: #fff; }
        h3 { font-weight: 400; opacity: 0.8; margin-bottom: 2rem; }

        .nickbox {
            display: flex;
            flex-direction: column;
            gap: 15px;
            text-align: left;
        }

        label { font-weight: 600; font-size: 0.9rem; color: #bbb; }

        input[type="text"], input[type="password"] {
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #333;
            background: #2a2a2a;
            color: white;
            font-size: 1rem;
        }

        .btn-primary {
            background: var(--accent);
            color: white;
            border: none;
            padding: 15px;
            border-radius: 6px;
            font-weight: 800;
            cursor: pointer;
            transition: transform 0.2s, background 0.2s;
            margin-top: 10px;
        }

        .btn-primary:hover {
            background: #ff5e5e;
            transform: translateY(-2px);
        }

        /* Game Layout */
        #menubar {
            background: #1a1a1a;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #333;
        }

        .hide { display: none !important; }
        
        .footer-text { margin-top: 30px; font-size: 0.8rem; opacity: 0.6; line-height: 1.6; }
        .footer-text a { color: var(--accent); text-decoration: none; }
    </style>

    <script src="js/jquery-1.11.3.min.js"></script>
    <script src="js/jquery-migrate-1.2.1.js"></script>
    <script src="js/jquery-ui.min.js"></script>
    <script src="js/jquery.cookie.js"></script>
    <script src="js/jquery.json.js"></script>
    <script src="js/QTransform.js"></script>
    
    <script src="js/cah.js"></script>
    <script src="js/cah.config.js"></script>
    <script src="js/cah.constants.js"></script>
    <script src="js/cah.log.js"></script>
    <script src="js/cah.gamelist.js"></script>
    <script src="js/cah.card.js"></script>
    <script src="js/cah.cardset.js"></script>
    <script src="js/cah.game.js"></script>
    <script src="js/cah.preferences.js"></script>
    <script src="js/cah.longpoll.js"></script>
    <script src="js/cah.longpoll.handlers.js"></script>
    <script src="js/cah.ajax.js"></script>
    <script src="js/cah.ajax.builder.js"></script>
    <script src="js/cah.ajax.handlers.js"></script>
    <script src="js/cah.app.js"></script>
</head>

<body id="gamebody">

<div id="welcome" class="welcome-container">
    <h1>🎉 Terrible People</h1>
    <h3>A party game for The-Circle community</h3>

    <div class="info-box">
        <p>✨ Choose a nickname and join the fun!</p>
    </div>

    <div id="nickbox" class="nickbox">
        <div>
            <label for="nickname">🎭 Your Nickname</label>
            <input type="text" id="nickname" maxlength="30" placeholder="e.g., FunnyGuy" style="width: 100%; box-sizing: border-box;" />
        </div>
        
        <div>
            <label for="idcode">🔐 Identification Code (Optional)</label>
            <input type="password" id="idcode" maxlength="100" disabled placeholder="Disabled for now" style="width: 100%; box-sizing: border-box;" />
            <small><a href="https://github.com/ajanata/PretendYoureXyzzy/wiki/Identification-Codes" target="_blank">What's this?</a></small>
        </div>
        
        <span id="nickbox_error" class="error"></span>
        
        <button type="button" class="btn-primary" id="nicknameconfirm">
            🎮 Set Nickname & Enter Game
        </button>
    </div>

    <p class="footer-text">
        Inspired by Cards Against Humanity.<br />
        <a href="#">Source code</a> • <a href="#">License</a> • <a href="#">Privacy</a>
    </p>
</div>

<div id="canvas" class="hide">
    <div id="menubar">
        <div id="menubar_left">
            <input type="button" id="refresh_games" class="hide" value="Refresh" />
            <input type="button" id="create_game" class="hide" value="Create Game" />
            <input type="text" id="filter_games" class="hide" placeholder="Filter games" />
            <input type="button" id="leave_game" class="hide" value="Leave" />
            <input type="button" id="start_game" class="hide" value="Start" />
        </div>
        <div id="menubar_right">
            <span>Timer: <b id="current_timer">0</b>s</span>
            <input type="button" id="view_cards" value="View Cards" onclick="window.open('viewcards.jsp', 'viewcards');" />
            <input type="button" id="logout" value="Log out" />
        </div>
    </div>

    <div id="main">
        <div id="game_list" class="hide"></div>
        <div id="main_holder"></div>
    </div>
</div>

<div id="bottom" class="hide">
    <div id="info_area"></div>
    <div id="tabs">
        <ul>
            <li><a href="#tab-preferences">Settings</a></li>
            <li><a href="#tab-gamelist-filters">Filters</a></li>
            <li><a href="#tab-global">Global Chat</a></li>
        </ul>
        
        <div id="tab-preferences">
            <div class="tab-controls">
                <button onclick="cah.Preferences.save();">Save Settings</button>
                <label><input type="checkbox" id="hide_connect_quit" /> Hide connect/quit events</label>
                <label><input type="checkbox" id="no_persistent_id" /> Opt-out of tracking</label>
            </div>
            <textarea id="ignore_list" placeholder="Ignore list (one per line)"></textarea>
        </div>

        <div id="tab-global">
            <div class="log" style="height: 150px; overflow-y: auto; background: #000; padding: 10px; margin-bottom: 5px;"></div>
            <div style="display: flex; gap: 5px;">
                <input type="text" class="chat" maxlength="200" style="flex-grow: 1;" />
                <input type="button" class="chat_submit" value="Send" />
            </div>
        </div>
    </div>
</div>

<div class="hide">
    <div id="gamelist_lobby_template" class="gamelist_lobby">
        <div class="gamelist_lobby_left">
            <h3><span class="gamelist_lobby_host"></span>'s Game</h3>
            <div class="stats">
                <b>Players:</b> <span class="gamelist_lobby_player_count"></span>/<span class="gamelist_lobby_max_players"></span>
            </div>
        </div>
        <div class="gamelist_lobby_right">
            <input type="button" class="gamelist_lobby_join" value="Join" />
        </div>
    </div>

    <div id="black_up_template" class="card blackcard">
        <span class="card_text"></span>
        <div class="logo"><div class="logo_text">Terrible People</div></div>
    </div>

    <div id="white_up_template" class="card whitecard">
        <span class="card_text"></span>
        <div class="logo"><div class="logo_text">Terrible People</div></div>
    </div>
</div>

<div style="position:absolute; left:-99999px" role="alert" id="aria-notifications"></div>

</body>
</html>
