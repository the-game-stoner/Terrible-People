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
    <title>Terrible People — The-Circle</title>
    
    <link rel="stylesheet" href="cah.css" />
    <link rel="stylesheet" href="jquery-ui.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">

    <style>
        :root {
            --bg: #121212;
            --panel: #1e1e1e;
            --accent: #ff3e3e;
            --text: #e0e0e0;
            --card-white: #ffffff;
            --card-black: #000000;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg);
            color: var(--text);
            margin: 0;
            overflow-x: hidden;
        }

        /* Login Screen */
        .welcome-container {
            max-width: 600px;
            margin: 50px auto;
            padding: 30px;
            background: var(--panel);
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 10px 40px rgba(0,0,0,0.6);
        }

        /* Game Board Layout Fixes */
        #canvas { padding: 15px; }
        
        #menubar {
            background: #252525;
            padding: 10px 20px;
            border-radius: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        #main_holder { display: flex; flex-wrap: wrap; gap: 20px; }

        /* The "Fucked Up" Parts - Fixing template displays */
        .game_left_side { float: left; width: 250px; }
        .game_right_side { margin-left: 270px; min-height: 300px; }
        .game_hand { clear: both; padding-top: 20px; border-top: 1px solid #333; margin-top: 20px; }
        
        .card {
            border-radius: 10px;
            padding: 15px;
            font-weight: 700;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            transition: transform 0.2s;
        }

        .blackcard { background: var(--card-black); color: white; border: 1px solid #444; }
        .whitecard { background: var(--card-white); color: black; }

        input[type="button"], button {
            background: #333;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
        }

        input[type="button"]:hover { background: var(--accent); }
        
        #nicknameconfirm {
            background: var(--accent);
            padding: 15px 30px;
            font-size: 1.1rem;
            margin-top: 20px;
        }

        .hide { display: none !important; }

        /* Tabs styling */
        #tabs { background: var(--panel); border-radius: 8px; margin-top: 20px; }
        .ui-tabs-nav { background: transparent; border: none; border-bottom: 1px solid #333; }
        .ui-tabs-panel { padding: 20px; }

        #nickbox input {
            padding: 12px;
            width: 100%;
            max-width: 300px;
            background: #111;
            border: 1px solid #444;
            color: white;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>

    <script src="js/jquery-1.11.3.min.js"></script>
    <script src="js/jquery-migrate-1.2.1.js"></script>
    <script src="js/jquery.cookie.js"></script>
    <script src="js/jquery.json.js"></script>
    <script src="js/QTransform.js"></script>
    <script src="js/jquery-ui.min.js"></script>
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
    
    <div id="nickbox">
        <label for="nickname">Choose a Nickname:</label><br/>
        <input type="text" id="nickname" maxlength="30" placeholder="e.g., CircleKing" /><br/>
        
        <label for="idcode">Identification Code (Optional):</label><br/>
        <input type="password" id="idcode" maxlength="100" disabled /><br/>
        
        <input type="button" id="nicknameconfirm" value="Join the Chaos →" />
        <div id="nickbox_error" class="error"></div>
    </div>

    <div style="margin-top: 30px; font-size: 0.8rem; opacity: 0.5;">
        Inspired by Cards Against Humanity. Please play responsibly.
    </div>
</div>

<div id="canvas" class="hide">
    <div id="menubar">
        <div id="menubar_left">
            <input type="button" id="refresh_games" class="hide" value="Refresh Games" />
            <input type="button" id="create_game" class="hide" value="Create Game" />
            <input type="text" id="filter_games" class="hide" placeholder="Filter games..." />
            <input type="button" id="leave_game" class="hide" value="Leave Game" />
            <input type="button" id="start_game" class="hide" value="Start Game" />
            <input type="button" id="stop_game" class="hide" value="Stop Game" />
        </div>
        <div id="menubar_right">
            Timer: <span id="current_timer">0</span>s
            <input type="button" id="view_cards" value="View Cards" onclick="window.open('viewcards.jsp', 'viewcards');" />
            <input type="button" id="logout" value="Logout" />
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
            <li><a href="#tab-preferences">Preferences</a></li>
            <li><a href="#tab-gamelist-filters">Filters</a></li>
            <li><a href="#tab-global">Global Chat</a></li>
        </ul>
        <div id="tab-preferences">
            <button onclick="cah.Preferences.save();">Save</button>
            <label><input type="checkbox" id="hide_connect_quit" /> Hide Connect/Quit</label><br/>
            <textarea id="ignore_list" placeholder="Ignore list (one per line)"></textarea>
        </div>
        <div id="tab-gamelist-filters">
            <fieldset>
                <legend>Card Set Filters</legend>
                <select id="cardsets_banned" multiple></select>
                <select id="cardsets_neutral" multiple></select>
                <select id="cardsets_required" multiple></select>
            </fieldset>
        </div>
        <div id="tab-global">
            <div class="log" style="height: 150px; overflow-y: auto; background: #000; padding: 10px; margin-bottom: 5px;"></div>
            <input type="text" class="chat" maxlength="200" style="width: 80%" />
            <input type="button" class="chat_submit" value="Chat" />
        </div>
    </div>
</div>

<div class="hide">
    <div id="gamelist_lobby_template" class="gamelist_lobby">
        <div class="gamelist_lobby_left">
            <h3><span class="gamelist_lobby_host"></span>'s Game (<span class="gamelist_lobby_player_count"></span>/<span class="gamelist_lobby_max_players"></span>)</h3>
            <div><strong>Players:</strong> <span class="gamelist_lobby_players"></span></div>
            <div><strong>Goal:</strong> <span class="gamelist_lobby_goal"></span></div>
        </div>
        <div class="gamelist_lobby_right">
            <input type="button" class="gamelist_lobby_join" value="Join" />
        </div>
    </div>

    <div id="black_up_template" class="card blackcard">
        <span class="card_text"></span>
        <div class="logo"><div class="logo_text">Terrible People</div></div>
        <div class="card_metadata">
            <div class="pick hide">PICK <div class="card_number"></div></div>
        </div>
    </div>

    <div id="white_up_template" class="card whitecard">
        <span class="card_text"></span>
        <div class="logo"><div class="logo_text">Terrible People</div></div>
    </div>

    <div id="game_template" class="game">
        <div class="game_top">
            <input type="button" class="game_show_options" value="Game Options" />
            <div class="game_message">Waiting...</div>
        </div>
        <div class="game_main_area">
            <div class="game_left_side">
                <div class="game_black_card"></div>
                <input type="button" class="confirm_card" value="Confirm Selection" />
            </div>
            <div class="game_options"></div>
            <div class="game_right_side hide">
                <div class="game_white_cards game_right_side_cards"></div>
            </div>
        </div>
        <div class="game_hand">
            <div class="game_hand_cards"></div>
        </div>
    </div>

    <div id="scoreboard_template" class="scoreboard"></div>
    <div id="scorecard_template" class="scorecard">
        <span class="scorecard_player"></span>: <span class="scorecard_score">0</span> pts
        <span class="scorecard_status"></span>
    </div>

    <div class="game_options" id="game_options_template">
        <fieldset>
            <legend>Options</legend>
            Score limit: 
            <select id="score_limit_template" class="score_limit">
                <% for (int i = injector.getInstance(Key.get(Integer.class, MinScoreLimit.class)); i <= injector.getInstance(Key.get(Integer.class, MaxScoreLimit.class)); i++) { %>
                    <option <%=(i == injector.getInstance(Key.get(Integer.class, DefaultScoreLimit.class))) ? "selected" : "" %> value="<%=i%>"><%=i%></option>
                <% } %>
            </select><br/>
            Player limit:
            <select id="player_limit_template" class="player_limit">
                <% for (int i = injector.getInstance(Key.get(Integer.class, MinPlayerLimit.class)); i <= injector.getInstance(Key.get(Integer.class, MaxPlayerLimit.class)); i++) { %>
                    <option <%= i == injector.getInstance(Key.get(Integer.class, DefaultPlayerLimit.class)) ? "selected" : "" %> value="<%=i%>"><%=i%></option>
                <% } %>
            </select>
            <div class="card_sets">
                <span class="base_card_sets"></span>
                <span class="extra_card_sets"></span>
            </div>
        </fieldset>
    </div>
</div>

<div style="position:absolute; left:-99999px" role="alert" id="aria-notifications"></div>
</body>
</html>
