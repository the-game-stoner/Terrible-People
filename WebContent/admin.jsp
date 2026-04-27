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
<%@ page import="net.socialgamer.cah.RequestWrapper" %>
<%@ page import="net.socialgamer.cah.StartupUtils" %>
<%@ page import="net.socialgamer.cah.CahModule.Admins" %>
<%@ page import="net.socialgamer.cah.CahModule.BanList" %>
<%@ page import="net.socialgamer.cah.Constants.DisconnectReason" %>
<%@ page import="net.socialgamer.cah.Constants.LongPollEvent" %>
<%@ page import="net.socialgamer.cah.Constants.LongPollResponse" %>
<%@ page import="net.socialgamer.cah.Constants.ReturnableData" %>
<%@ page import="net.socialgamer.cah.data.ConnectedUsers" %>
<%@ page import="net.socialgamer.cah.data.QueuedMessage" %>
<%@ page import="net.socialgamer.cah.data.QueuedMessage.MessageType" %>
<%@ page import="net.socialgamer.cah.data.User" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
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

ConnectedUsers connectedUsers = injector.getInstance(ConnectedUsers.class);
Set<String> banList = injector.getInstance(Key.get(new TypeLiteral<Set<String>>(){}, BanList.class));

String verboseParam = request.getParameter("verbose");
if (verboseParam != null) {
  if (verboseParam.equals("on")) {
    servletContext.setAttribute(StartupUtils.VERBOSE_DEBUG, Boolean.TRUE);
  } else {
    servletContext.setAttribute(StartupUtils.VERBOSE_DEBUG, Boolean.FALSE);
  }
  response.sendRedirect("admin.jsp");
  return;
}

String kickParam = request.getParameter("kick");
if (kickParam != null) {
  User user = connectedUsers.getUser(kickParam);
  if (user != null) {
    Map<ReturnableData, Object> data = new HashMap<ReturnableData, Object>();
    data.put(LongPollResponse.EVENT, LongPollEvent.KICKED.toString());
    QueuedMessage qm = new QueuedMessage(MessageType.KICKED, data);
    user.enqueueMessage(qm);

    connectedUsers.removeUser(user, DisconnectReason.KICKED);
  }
  response.sendRedirect("admin.jsp");
  return;
}

String banParam = request.getParameter("ban");
if (banParam != null) {
  User user = connectedUsers.getUser(banParam);
  if (user != null) {
   Map<ReturnableData, Object> data = new HashMap<ReturnableData, Object>();
   data.put(LongPollResponse.EVENT, LongPollEvent.BANNED.toString());
   QueuedMessage qm = new QueuedMessage(MessageType.KICKED, data);
   user.enqueueMessage(qm);

   connectedUsers.removeUser(user, DisconnectReason.BANNED);
   banList.add(user.getHostname());
  }
  response.sendRedirect("admin.jsp");
  return;
}

String unbanParam = request.getParameter("unban");
if (unbanParam != null) {
  banList.remove(unbanParam);
  response.sendRedirect("admin.jsp");
  return;
}

String reloadLog4j = request.getParameter("reloadLog4j");
if ("true".equals(reloadLog4j)) {
  StartupUtils.reconfigureLogging(this.getServletContext());
}

String reloadProps = request.getParameter("reloadProps");
if ("true".equals(reloadProps)) {
  StartupUtils.reloadProperties(this.getServletContext());
}

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
<title>Terrible People - Admin</title>
<link rel="stylesheet" type="text/css" href="cah.css" media="screen" />
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
  
  .admin-container {
    max-width: 1200px;
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
  
  .stats-grid {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    overflow: hidden;
    margin-bottom: 24px;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  th {
    text-align: left;
    padding: 12px 16px;
    background: rgba(0,0,0,0.3);
    color: var(--circle-accent);
    font-weight: 600;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid var(--circle-border);
  }
  
  td {
    padding: 12px 16px;
    border-bottom: 1px solid var(--circle-border);
  }
  
  tr:hover td {
    background: var(--circle-accent-soft);
  }
  
  .action-link {
    color: var(--circle-accent);
    text-decoration: none;
    margin-right: 12px;
    font-size: 13px;
  }
  
  .action-link:hover {
    text-decoration: underline;
  }
  
  .tools-panel {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    padding: 20px 24px;
    margin-top: 24px;
  }
  
  .tools-panel p {
    margin: 12px 0;
  }
  
  .badge {
    display: inline-block;
    background: var(--circle-accent-soft);
    color: var(--circle-accent);
    font-size: 11px;
    padding: 2px 10px;
    border-radius: 20px;
    margin-left: 8px;
  }
  
  .empty-row td {
    text-align: center;
    color: var(--circle-muted);
    padding: 24px;
  }
  
  hr {
    border: none;
    border-top: 1px solid var(--circle-border);
    margin: 20px 0;
  }
</style>
</head>
<body>
<div class="admin-container">
  <a href="game.jsp" class="back-link">← Back to Game</a>

  <h1>🛡️ Terrible People - Admin Panel</h1>

  <div class="stats-grid">
    <table>
      <tr>
        <th style="width: 200px;">Server Uptime</th>
        <td>
          <%
          Date startedDate = (Date) servletContext.getAttribute(StartupUtils.DATE_NAME);
          long uptime = System.currentTimeMillis() - startedDate.getTime();
          uptime /= 1000L;
          long seconds = uptime % 60L;
          long minutes = (uptime / 60L) % 60L;
          long hours = (uptime / 60L / 60L) % 24L;
          long days = (uptime / 60L / 60L / 24L);
          out.print(String.format("%s <span class='badge'>%d days, %02d:%02d:%02d</span>",
              startedDate.toString(), days, hours, minutes, seconds));
          %>
        </td>
      </tr>
    </table>
  </div>

  <h2>💾 Memory Usage</h2>
  <div class="stats-grid">
    <table>
      <tr>
        <th style="width: 200px;">Stat</th>
        <th>MiB</th>
      </tr>
      <tr>
        <td>In Use</td>
        <td><%= (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / 1024L / 1024L %></td>
      </tr>
      <tr>
        <td>Free</td>
        <td><% out.print(Runtime.getRuntime().freeMemory() / 1024L / 1024L); %></td>
      </tr>
      <tr>
        <td>JVM Allocated</td>
        <td><% out.print(Runtime.getRuntime().totalMemory() / 1024L / 1024L); %></td>
      </tr>
      <tr>
        <td>JVM Max</td>
        <td><% out.print(Runtime.getRuntime().maxMemory() / 1024L / 1024L); %></td>
      </tr>
    </table>
  </div>

  <h2>🚫 Ban List</h2>
  <div class="stats-grid">
    <table>
      <thead>
        <tr>
          <th>Host</th>
          <th style="width: 100px;">Actions</th>
        </tr>
      </thead>
      <tbody>
        <%
        if (banList.isEmpty()) {
        %>
        <tr class="empty-row">
          <td colspan="2">No banned hosts.</td>
        </tr>
        <%
        } else {
          for (String host : banList) {
        %>
        <tr>
          <td><%= host %></td>
          <td><a href="?unban=<%= host %>" class="action-link">Unban</a></td>
        </tr>
        <%
          }
        }
        %>
      </tbody>
    </table>
  </div>

  <h2>👥 Connected Users</h2>
  <div class="stats-grid">
    <table>
      <thead>
        <tr>
          <th>Username</th>
          <th>Host</th>
          <th style="width: 150px;">Actions</th>
        </tr>
      </thead>
      <tbody>
        <%
        Collection<User> users = connectedUsers.getUsers();
        if (users.isEmpty()) {
        %>
        <tr class="empty-row">
          <td colspan="3">No users currently connected.</td>
        </tr>
        <%
        } else {
          for (User u : users) {
        %>
        <tr>
          <td><%= u.getNickname() %></td>
          <td><%= u.getHostname() %></td>
          <td>
            <a href="?kick=<%= u.getNickname() %>" class="action-link">Kick</a>
            <a href="?ban=<%= u.getNickname() %>" class="action-link">Ban</a>
          </td>
        </tr>
        <%
          }
        }
        %>
      </tbody>
    </table>
  </div>

  <h2>⚙️ Tools</h2>
  <div class="tools-panel">
    <%
    Boolean verboseDebugObj = (Boolean) servletContext.getAttribute(StartupUtils.VERBOSE_DEBUG); 
    boolean verboseDebug = verboseDebugObj != null ? verboseDebugObj.booleanValue() : false;
    %>
    <p>
      <strong>📋 Verbose Logging:</strong> Currently <strong style="color: var(--circle-accent);"><%= verboseDebug ? "ON" : "OFF" %></strong>
      <span style="margin-left: 16px;">
        <a href="?verbose=on" class="action-link">Turn On</a> | 
        <a href="?verbose=off" class="action-link">Turn Off</a>
      </span>
    </p>
    <hr />
    <p>
      🔄 <a href="?reloadLog4j=true" class="action-link">Reload log4j.properties</a>
    </p>
    <p>
      🔄 <a href="?reloadProps=true" class="action-link">Reload pyx.properties</a>
    </p>
  </div>
</div>
</body>
</html>
