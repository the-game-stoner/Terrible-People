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
<style type="text/css" media="screen">
  body {
    background: #070a0f;
    color: rgba(255, 255, 255, 0.92);
    font-family: ui-sans-serif, system-ui, sans-serif;
    padding: 20px;
  }
  table, th, td {
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-collapse: collapse;
  }
  th, td {
    padding: 8px 12px;
  }
  th {
    background: rgba(255, 255, 255, 0.06);
  }
  a {
    color: #09ff03;
    text-decoration: none;
  }
  a:hover {
    text-decoration: underline;
  }
  h1 {
    font-size: 1.8rem;
    letter-spacing: -0.02em;
  }
  .back-link {
    display: inline-block;
    margin-bottom: 20px;
  }
</style>
</head>
<body>

<a href="game.jsp" class="back-link">&larr; Back to Game</a>

<h1>Terrible People - Admin Panel</h1>

<p>
  Server up since
  <%
  Date startedDate = (Date) servletContext.getAttribute(StartupUtils.DATE_NAME);
  long uptime = System.currentTimeMillis() - startedDate.getTime();
  uptime /= 1000L;
  long seconds = uptime % 60L;
  long minutes = (uptime / 60L) % 60L;
  long hours = (uptime / 60L / 60L) % 24L;
  long days = (uptime / 60L / 60L / 24L);
  out.print(String.format("%s (%d days, %02d:%02d:%02d)",
      startedDate.toString(), days, hours, minutes, seconds));
  %>
</p>

<h2>Memory Usage</h2>
<table>
  <tr>
    <th>Stat</th>
    <th>MiB</th>
  </tr>
  <tr>
    <td>In Use</td>
    <td><%= (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory())
        / 1024L / 1024L %></td>
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

<h2>Ban List</h2>
<table>
  <tr>
    <th>Host</th>
    <th>Actions</th>
  </tr>
  <%
  for (String host : banList) {
    %>
    <tr>
      <td><%= host %></td>
      <td><a href="?unban=<%= host %>">Unban</a></td>
    </tr>
    <%
  }
  %>
</table>

<h2>Connected Users</h2>
<table>
  <tr>
    <th>Username</th>
    <th>Host</th>
    <th>Actions</th>
  </tr>
  <%
  Collection<User> users = connectedUsers.getUsers();
  for (User u : users) {
    %>
    <tr>
      <td><%= u.getNickname() %></td>
      <td><%= u.getHostname() %></td>
      <td>
        <a href="?kick=<%= u.getNickname() %>">Kick</a>
        <a href="?ban=<%= u.getNickname() %>">Ban</a>
      </td>
    </tr>
    <%
  }
  %>
</table>

<%
Boolean verboseDebugObj = (Boolean) servletContext.getAttribute(StartupUtils.VERBOSE_DEBUG); 
boolean verboseDebug = verboseDebugObj != null ? verboseDebugObj.booleanValue() : false;
%>

<h2>Tools</h2>
<p>
  Verbose logging is currently <strong><%= verboseDebug ? "ON" : "OFF" %></strong>.
  <a href="?verbose=on">Turn on</a> | <a href="?verbose=off">Turn off</a>
</p>
<p>
  <a href="?reloadLog4j=true">Reload log4j.properties</a>
</p>
<p>
  <a href="?reloadProps=true">Reload pyx.properties</a>
</p>

</body>
</html>
