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
Administration tools.

@author Andy Janata (ajanata@socialgamer.net)
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.google.inject.Injector" %>
<%@ page import="com.google.inject.Key" %>
<%@ page import="com.google.inject.TypeLiteral" %>
<%@ page import="net.socialgamer.cah.CahModule.Admins" %>
<%@ page import="net.socialgamer.cah.HibernateUtil" %>
<%@ page import="net.socialgamer.cah.StartupUtils" %>
<%@ page import="net.socialgamer.cah.db.PyxBlackCard" %>
<%@ page import="net.socialgamer.cah.db.PyxWhiteCard" %>
<%@ page import="net.socialgamer.cah.RequestWrapper" %>
<%@ page import="org.hibernate.Session" %>
<%@ page import="org.hibernate.Transaction" %>
<%@ page import="java.util.Set" %>
<%
RequestWrapper wrapper = new RequestWrapper(request);
ServletContext servletContext = pageContext.getServletContext();
Injector injector = (Injector) servletContext.getAttribute(StartupUtils.INJECTOR);
Set<String> admins = injector.getInstance(Key.get(new TypeLiteral<Set<String>>(){}, Admins.class));
if (!admins.contains(wrapper.getRemoteAddr())) {
  response.sendError(403, "Access is restricted to known hosts");
  return;
}

final String watermark = request.getParameter("watermark") != null ? request.getParameter("watermark") : "";

String error = "";
String status = "";
String field = "";
final String color = request.getParameter("color");
if (color != null) {
  if ("black".equals(color)) {
    final String text = request.getParameter("text");
    final String pick_s = request.getParameter("pick");
    final String draw_s = request.getParameter("draw");
    
    if (text == null || "".equals(text) || pick_s == null || "".equals(pick_s) || draw_s == null ||
        "".equals(draw_s)) {
      error = "You didn't specify something.";
    } else {
      int pick = 0;
      int draw = 0;
      try {
        pick = Integer.parseInt(pick_s);
        draw = Integer.parseInt(draw_s);
      } catch (NumberFormatException e) {
        error = "Something isn't a number.";
      }
      if (0 == pick) {
        error += " Pick can't be 0.";
      } else {
        final Session s = HibernateUtil.instance.sessionFactory.openSession();
        final Transaction transaction = s.beginTransaction();
        transaction.begin();
        final PyxBlackCard card = new PyxBlackCard();
        card.setText(text);
        card.setPick(pick);
        card.setDraw(draw);
        card.setWatermark(watermark);
        s.save(card);
        transaction.commit();
        s.close();
        status = "Saved '" + text + "'.";
        field = "black";
      }
    }
  } else if ("white".equals(color)) {
    final String text = request.getParameter("text");
    
    if (text == null || "".equals(text)) {
      error = "You didn't specify something.";
    } else {
      final Session s = HibernateUtil.instance.sessionFactory.openSession();
      final Transaction transaction = s.beginTransaction();
      transaction.begin();
      final PyxWhiteCard card = new PyxWhiteCard();
      card.setText(text);
      card.setWatermark(watermark);
      s.save(card);
      transaction.commit();
      s.close();
      status = "Saved '" + text + "'.";
      field = "white";
    }
  }
}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
<title>Terrible People - Add Cards</title>
<link rel="icon" type="image/png" href="favicon.png" />
<style>
  :root {
    --circle-bg: #070a0f;
    --circle-panel: rgba(255,255,255,0.06);
    --circle-panel2: rgba(255,255,255,0.04);
    --circle-border: rgba(255,255,255,0.12);
    --circle-text: rgba(255,255,255,0.92);
    --circle-muted: rgba(255,255,255,0.68);
    --circle-accent: #09ff03;
    --circle-accent-soft: rgba(9,255,3,0.14);
  }
  
  body {
    background: radial-gradient(900px 500px at 15% 10%, rgba(9,255,3,0.12), transparent 62%),
                linear-gradient(var(--circle-bg), var(--circle-bg));
    background-attachment: fixed;
    color: var(--circle-text);
    font-family: ui-sans-serif, system-ui, 'Segoe UI', sans-serif;
    margin: 0;
    min-height: 100vh;
    padding: 40px 20px;
  }
  
  .addcard-container {
    max-width: 800px;
    margin: 0 auto;
    animation: fadeIn 0.5s ease-out;
  }
  
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  .back-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 40px;
    padding: 8px 20px;
    margin-bottom: 24px;
    color: var(--circle-text);
    text-decoration: none;
    transition: all 0.2s ease;
  }
  
  .back-link:hover {
    border-color: var(--circle-accent);
    color: var(--circle-accent);
    transform: translateX(-4px);
  }
  
  h1 {
    font-size: 36px;
    margin-bottom: 8px;
    color: var(--circle-accent);
  }
  
  h2 {
    font-size: 22px;
    margin-top: 32px;
    margin-bottom: 16px;
    color: var(--circle-text);
    border-bottom: 1px solid var(--circle-border);
    padding-bottom: 8px;
  }
  
  form {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    padding: 24px;
    margin-bottom: 30px;
    transition: all 0.2s ease;
  }
  
  form:hover {
    border-color: var(--circle-accent);
  }
  
  .form-row {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    margin-bottom: 16px;
  }
  
  label {
    display: inline-block;
    width: 100px;
    font-weight: 600;
    color: var(--circle-accent);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
  }
  
  input[type="text"] {
    flex: 1;
    min-width: 250px;
    background: rgba(0,0,0,0.5);
    border: 1px solid var(--circle-border);
    border-radius: 12px;
    padding: 10px 14px;
    color: var(--circle-text);
    font-size: 14px;
    font-family: monospace;
  }
  
  input[type="text"]:focus {
    outline: none;
    border-color: var(--circle-accent);
    box-shadow: 0 0 0 3px rgba(9,255,3,0.15);
  }
  
  input[type="submit"] {
    background: linear-gradient(135deg, var(--circle-accent) 0%, #0dcc00 100%);
    border: none;
    border-radius: 40px;
    padding: 10px 28px;
    font-size: 14px;
    font-weight: bold;
    color: #070a0f;
    cursor: pointer;
    transition: all 0.2s ease;
    margin-top: 8px;
    margin-left: 100px;
  }
  
  input[type="submit"]:hover {
    transform: scale(1.02);
    box-shadow: 0 0 20px rgba(9,255,3,0.4);
  }
  
  .error {
    color: #ff5555;
    font-size: 14px;
    padding: 12px 16px;
    background: rgba(255,68,68,0.1);
    border-radius: 12px;
    margin-bottom: 20px;
    border-left: 3px solid #ff5555;
  }
  
  .success {
    color: var(--circle-accent);
    font-size: 14px;
    padding: 12px 16px;
    background: var(--circle-accent-soft);
    border-radius: 12px;
    margin-bottom: 20px;
    border-left: 3px solid var(--circle-accent);
  }
  
  .info-note {
    font-size: 13px;
    color: var(--circle-muted);
    margin-bottom: 20px;
    padding: 12px 16px;
    background: var(--circle-panel2);
    border-radius: 12px;
  }
  
  .inline-hint {
    font-size: 11px;
    color: var(--circle-muted);
    margin-left: 100px;
    margin-top: -8px;
    margin-bottom: 8px;
  }
</style>
</head>
<body>
<div class="addcard-container">
  <a href="game.jsp" class="back-link">← Back to Game</a>

  <h1>🃟 Terrible People - Add Cards</h1>

  <div class="info-note">
    💡 Convention is to use four underscores <strong>____</strong> for the blanks on black cards.
  </div>

  <% if (!error.isEmpty()) { %>
    <div class="error">❌ <%= error %></div>
  <% } %>
  <% if (!status.isEmpty()) { %>
    <div class="success">✅ <%= status %></div>
  <% } %>

  <h2>🃟 Black Card</h2>
  <form method="post" action="addcard.jsp">
    <input type="hidden" name="color" value="black" />
    <div class="form-row">
      <label for="black_text">Card Text</label>
      <input type="text" id="black_text" name="text" size="150" placeholder="e.g., ____ is the new black." />
    </div>
    <div class="form-row">
      <label for="pick">Pick</label>
      <input type="text" id="pick" name="pick" size="3" value="1" />
    </div>
    <div class="inline-hint">Number of cards players must pick</div>
    <div class="form-row">
      <label for="draw">Draw</label>
      <input type="text" id="draw" name="draw" size="3" value="0" />
    </div>
    <div class="inline-hint">Number of cards drawn (for "draw 2, pick 1" style)</div>
    <div class="form-row">
      <label for="watermark_b">Watermark</label>
      <input type="text" id="watermark_b" name="watermark" size="3" maxlength="5" value="<%= watermark %>" placeholder="US, UK, etc." />
    </div>
    <input type="submit" value="+ Add Black Card" />
  </form>

  <h2>⬜ White Card</h2>
  <form method="post" action="addcard.jsp">
    <input type="hidden" name="color" value="white" />
    <div class="form-row">
      <label for="white_text">Card Text</label>
      <input type="text" id="white_text" name="text" size="150" placeholder="e.g., A really terrible answer." />
    </div>
    <div class="form-row">
      <label for="watermark_w">Watermark</label>
      <input type="text" id="watermark_w" name="watermark" size="3" maxlength="5" value="<%= watermark %>" placeholder="US, UK, etc." />
    </div>
    <input type="submit" value="+ Add White Card" />
  </form>
</div>

<script type="text/javascript">
var field = '<%= field %>';
if ('' != field) {
  document.getElementById(field + '_text').focus();
}
</script>
</body>
</html>
