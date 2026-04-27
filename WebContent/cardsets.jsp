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
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="net.socialgamer.cah.CahModule.Admins" %>
<%@ page import="net.socialgamer.cah.HibernateUtil" %>
<%@ page import="net.socialgamer.cah.StartupUtils" %>
<%@ page import="net.socialgamer.cah.db.PyxBlackCard" %>
<%@ page import="net.socialgamer.cah.db.PyxCardSet" %>
<%@ page import="net.socialgamer.cah.db.PyxWhiteCard" %>
<%@ page import="net.socialgamer.cah.RequestWrapper" %>
<%@ page import="org.apache.commons.lang3.StringEscapeUtils" %>
<%@ page import="org.hibernate.Session" %>
<%@ page import="org.hibernate.Transaction" %>
<%
RequestWrapper wrapper = new RequestWrapper(request);
ServletContext servletContext = pageContext.getServletContext();
Injector injector = (Injector) servletContext.getAttribute(StartupUtils.INJECTOR);
Set<String> admins = injector.getInstance(Key.get(new TypeLiteral<Set<String>>(){}, Admins.class));
if (!admins.contains(wrapper.getRemoteAddr())) {
  response.sendError(403, "Access is restricted to known hosts");
  return;
}

List<String> messages = new ArrayList<String>();

Session hibernateSession = HibernateUtil.instance.sessionFactory.openSession();

// cheap way to make sure we can close the hibernate session at the end of the page
try {
  String editParam = request.getParameter("edit");
  PyxCardSet editCardSet = null;
  if (null != editParam) {
    try {
      editCardSet = (PyxCardSet)hibernateSession.load(PyxCardSet.class, Integer.parseInt(editParam));
    } catch (NumberFormatException nfe) {
      messages.add("Unable to parse or locate requested card set to edit.");
    }
  }
  
  String deleteParam = request.getParameter("delete");
  if (null != deleteParam) {
    try {
      editCardSet = (PyxCardSet)hibernateSession.load(PyxCardSet.class, Integer.parseInt(deleteParam));
      Transaction t = hibernateSession.beginTransaction();
      hibernateSession.delete(editCardSet);
      t.commit();
      response.sendRedirect("cardsets.jsp");
      return;
    } catch (NumberFormatException nfe) {
      messages.add("Invalid id.");
    }
  }
  
  
  String actionParam = request.getParameter("action");
  if ("edit".equals(actionParam)) {
    String idParam = request.getParameter("cardSetId");
    int id = 0;
    try {
      id = Integer.parseInt(idParam);
      if (-1 == id) {
        editCardSet = new PyxCardSet();
      } else {
        editCardSet = (PyxCardSet)hibernateSession.load(PyxCardSet.class, id);
      }
      if (null != editCardSet) {
        String nameParam = request.getParameter("cardSetName");
        String descriptionParam = request.getParameter("cardSetDescription");
        String weightParam = request.getParameter("cardSetWeight");
        String activeParam = request.getParameter("active");
        String baseDeckParam = request.getParameter("baseDeck");
        String[] selectedBlackCardsParam = request.getParameterValues("selectedBlackCards");
        String[] selectedWhiteCardsParam = request.getParameterValues("selectedWhiteCards");
        int weight = -1;
        try {
          weight = Integer.valueOf(weightParam);
        } catch (Exception e) {
          // pass
        }
        if (weight <= 0 || weight > 9999) {
          messages.add("Weight must be a positive integer less than 10000.");
        } else if (null == nameParam || nameParam.isEmpty() || null == selectedBlackCardsParam ||
            null == selectedWhiteCardsParam) {
          messages.add("You didn't specify something.");
          if (-1 == id) {
            editCardSet = null;
          }
        } else {
          editCardSet.setName(nameParam);
          editCardSet.setDescription(descriptionParam);
          editCardSet.setWeight(weight);
          editCardSet.setActive("on".equals(activeParam));
          editCardSet.setBaseDeck("on".equals(baseDeckParam));
          List<Integer> blackCardIds = new ArrayList<Integer>(selectedBlackCardsParam.length);
          for (String bc : selectedBlackCardsParam) {
            blackCardIds.add(Integer.parseInt(bc));
          }
          List<Integer> whiteCardIds = new ArrayList<Integer>(selectedWhiteCardsParam.length);
          for (String wc : selectedWhiteCardsParam) {
            whiteCardIds.add(Integer.parseInt(wc));
          }
          @SuppressWarnings("unchecked")
          List<PyxBlackCard> realBlackCards = hibernateSession.createQuery(
              "from PyxBlackCard where id in (:ids)").setParameterList("ids", blackCardIds).
              setReadOnly(true).list();
          @SuppressWarnings("unchecked")
          List<PyxWhiteCard> realWhiteCards = hibernateSession.createQuery(
              "from PyxWhiteCard where id in (:ids)").setParameterList("ids", whiteCardIds).
              setReadOnly(true).list();
          editCardSet.getBlackCards().clear();
          editCardSet.getBlackCards().addAll(realBlackCards);
          editCardSet.getWhiteCards().clear();
          editCardSet.getWhiteCards().addAll(realWhiteCards);
          Transaction t = hibernateSession.beginTransaction();
          hibernateSession.saveOrUpdate(editCardSet);
          t.commit();
          hibernateSession.flush();
          response.sendRedirect("cardsets.jsp");
          return;
        }
      } else {
        messages.add("Unable to find card set with id " + id + ".");
      }
    } catch (Exception e) {
      messages.add("Something went wrong. " + e.toString());
    }
  }
  
  @SuppressWarnings("unchecked")
  List<PyxCardSet> cardSets = hibernateSession.createQuery("from PyxCardSet order by weight, name")
      .setReadOnly(true).list();
  
  @SuppressWarnings("unchecked")
  List<PyxBlackCard> blackCards = hibernateSession.createQuery("from PyxBlackCard order by id")
      .setReadOnly(true).list();
  
  @SuppressWarnings("unchecked")
  List<PyxWhiteCard> whiteCards = hibernateSession.createQuery("from PyxWhiteCard order by id")
      .setReadOnly(true).list();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
<title>Terrible People - Edit Card Sets</title>
<link rel="icon" type="image/png" href="favicon.png" />
<script type="text/javascript" src="js/jquery-1.11.3.min.js"></script>
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
  
  .cardsets-container {
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
  
  h3 {
    color: #ff5555;
    font-size: 14px;
    background: rgba(255,68,68,0.1);
    padding: 12px 16px;
    border-radius: 12px;
    border-left: 3px solid #ff5555;
    margin-bottom: 20px;
  }
  
  .table-wrapper {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    overflow-x: auto;
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
    padding: 10px 16px;
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
  
  .create-btn {
    display: inline-block;
    background: var(--circle-accent);
    color: #070a0f;
    padding: 8px 20px;
    border-radius: 40px;
    text-decoration: none;
    font-weight: bold;
    font-size: 14px;
    margin-bottom: 20px;
    transition: all 0.2s ease;
  }
  
  .create-btn:hover {
    background: #0cdd00;
    transform: scale(1.02);
  }
  
  form {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    padding: 24px;
    margin-top: 24px;
  }
  
  .form-row {
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    flex-wrap: wrap;
  }
  
  label {
    width: 120px;
    font-weight: 600;
    color: var(--circle-accent);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
  }
  
  input[type="text"], input[type="password"] {
    flex: 1;
    min-width: 250px;
    background: rgba(0,0,0,0.5);
    border: 1px solid var(--circle-border);
    border-radius: 12px;
    padding: 10px 14px;
    color: var(--circle-text);
    font-size: 14px;
  }
  
  input[type="text"]:focus, input[type="password"]:focus {
    outline: none;
    border-color: var(--circle-accent);
    box-shadow: 0 0 0 3px rgba(9,255,3,0.15);
  }
  
  input[type="checkbox"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
    accent-color: var(--circle-accent);
  }
  
  input[type="submit"] {
    background: linear-gradient(135deg, var(--circle-accent) 0%, #0dcc00 100%);
    border: none;
    border-radius: 40px;
    padding: 12px 28px;
    font-size: 16px;
    font-weight: bold;
    color: #070a0f;
    cursor: pointer;
    transition: all 0.2s ease;
    margin-top: 8px;
  }
  
  input[type="submit"]:hover {
    transform: scale(1.02);
    box-shadow: 0 0 20px rgba(9,255,3,0.4);
  }
  
  .dual-select {
    display: flex;
    gap: 20px;
    margin: 20px 0;
    flex-wrap: wrap;
  }
  
  .dual-select-column {
    flex: 1;
    min-width: 250px;
  }
  
  .dual-select-column select {
    width: 100%;
    height: 300px;
    background: rgba(0,0,0,0.5);
    border: 1px solid var(--circle-border);
    border-radius: 12px;
    color: var(--circle-text);
    padding: 8px;
  }
  
  .dual-select-column select option {
    padding: 6px 8px;
    border-bottom: 1px solid var(--circle-border);
  }
  
  .dual-select-column select option:checked {
    background: var(--circle-accent-soft);
    color: var(--circle-accent);
  }
  
  .button-group {
    display: flex;
    gap: 12px;
    margin: 10px 0;
  }
  
  .btn-secondary {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 40px;
    padding: 8px 20px;
    font-size: 13px;
    font-weight: bold;
    color: var(--circle-text);
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .btn-secondary:hover {
    border-color: var(--circle-accent);
    color: var(--circle-accent);
  }
  
  hr {
    border: none;
    border-top: 1px solid var(--circle-border);
    margin: 20px 0;
  }
  
  .inline-hint {
    font-size: 11px;
    color: var(--circle-muted);
    margin-left: 120px;
    margin-top: -8px;
    margin-bottom: 8px;
  }
</style>
<script type="text/javascript">
  $(document).ready(function() {
    $('#addBlackCards').click(function() {
      addItem('allBlackCards', 'selectedBlackCards', 'bc');
    });
    $('#removeBlackCards').click(function() {
      removeItem('selectedBlackCards');
    });
    $('#addWhiteCards').click(function() {
      addItem('allWhiteCards', 'selectedWhiteCards', 'wc');
    });
    $('#removeWhiteCards').click(function() {
      removeItem('selectedWhiteCards');
    });
    $('#editForm').submit(function() {
      $('#selectedBlackCards option').each(function() {
        this.selected = true;
      });
      $('#selectedWhiteCards option').each(function() {
        this.selected = true;
      });
    });
  });
  
  /**
   * Add selected items from sourceList to destList, ignoring duplicates.
   */
  function addItem(sourceListId, destListId, idPrefix) {
    //
    $('#' + sourceListId + ' option').filter(':selected').each(function() {
      var existing = $('#' + idPrefix + '_' + this.value);
      if (existing.length == 0) {
        $('#' + destListId).append(
            '<option value="' + this.value + '" id="' + idPrefix + '_' + this.value + '">' +
            this.text + '</option>');
      }
    });
    $('#' + destListId + ' option').sort(function (a, b) {
      return Number(b.value) < Number(a.value);
    }).appendTo('#' + destListId);
  }
  
  /**
   * Remove selected items from list.
   */
  function removeItem(listId) {
    $('#' + listId + ' option').filter(':selected').each(function() {
      this.parentElement.removeChild(this);
    });
  }
</script>
</head>
<body>
<div class="cardsets-container">
  <a href="admin.jsp" class="back-link">← Back to Admin</a>

  <h1>🃟 Card Sets Management</h1>

  <%
    for (String message : messages) {
  %>
    <h3>⚠️ <%= message %></h3>
  <%
    }
  %>

  <h2>📦 Existing Card Sets</h2>
  <div class="table-wrapper">
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Delete</th>
          <th>Edit</th>
          <th>Weight</th>
          <th>Blacks</th>
          <th>Whites</th>
          <th>Active</th>
        </tr>
      </thead>
      <tbody>
        <%
          for (PyxCardSet cardSet : cardSets) {
        %>
          <tr>
            <td><%=cardSet.getName()%></td>
            <td><a href="?delete=<%=cardSet.getId()%>" class="action-link" onclick="return confirm('Are you sure?')">🗑️ Delete</a></td>
            <td><a href="?edit=<%=cardSet.getId()%>" class="action-link">✏️ Edit</a></td>
            <td><%=cardSet.getWeight()%></td>
            <td><%=cardSet.getBlackCards().size()%></td>
            <td><%=cardSet.getWhiteCards().size()%></td>
            <td><%=cardSet.isActive() ? "✅" : "❌"%></td>
          </tr>
        <%
          }
        %>
      </tbody>
    </table>
  </div>

  <a href="cardsets.jsp" class="create-btn">+ Create New Card Set</a>

  <form action="cardsets.jsp" method="post" id="editForm">
    <input type="hidden" name="action" value="edit" />
    <input type="hidden" name="cardSetId"
        value="<%=editCardSet != null ? editCardSet.getId() : -1%>" />
    
    <h2>
      <%
        if (editCardSet != null) {
      %>
        ✏️ Editing: <span style="color: var(--circle-accent);"><%=editCardSet.getName()%></span>
      <%
        } else {
      %>
        ➕ Create New Card Set
      <%
        }
      %>
    </h2>

    <div class="form-row">
      <label for="cardSetName">Name:</label>
      <input type="text" name="cardSetName" id="cardSetName" size="50"
          value="<%=editCardSet != null ? StringEscapeUtils.escapeXml11(editCardSet.getName()) : ""%>" />
    </div>

    <div class="form-row">
      <label for="cardSetDescription">Description:</label>
      <input type="text" name="cardSetDescription" id="cardSetDescription" size="50"
          value="<%=editCardSet != null ? StringEscapeUtils.escapeXml11(editCardSet.getDescription()) : ""%>" />
    </div>

    <div class="form-row">
      <label for="cardSetWeight">Weight:</label>
      <input type="text" name="cardSetWeight" id="cardSetWeight" size="4"
          value="<%=editCardSet != null ? editCardSet.getWeight() : "1000"%>" />
    </div>
    <div class="inline-hint">Lower weight = appears higher in list (1-9999)</div>

    <div class="form-row">
      <label for="active">Active</label>
      <input type="checkbox" name="active" id="active"
          <%=editCardSet != null && editCardSet.isActive() ? "checked='checked'" : ""%> />
    </div>

    <div class="form-row">
      <label for="baseDeck" title="This deck is sufficient for playing the game.">Base Deck</label>
      <input type="checkbox" name="baseDeck" id="baseDeck"
          <%=editCardSet != null && editCardSet.isBaseDeck() ? "checked='checked'" : ""%> />
    </div>

    <hr />

    <div class="dual-select">
      <div class="dual-select-column">
        <strong>📚 Available Black Cards</strong>
        <select id="allBlackCards" multiple="multiple">
          <%
            for (PyxBlackCard blackCard : blackCards) {
          %>
            <option value="<%=blackCard.getId()%>">
              <%=StringEscapeUtils.escapeXml11(blackCard.toString())%>
            </option>
          <%
            }
          %>
        </select>
        <div class="button-group">
          <input type="button" id="addBlackCards" class="btn-secondary" value="→ Add Selected →" />
          <input type="button" id="removeBlackCards" class="btn-secondary" value="← Remove Selected ←" />
        </div>
      </div>

      <div class="dual-select-column">
        <strong>🃟 Black Cards in Set</strong>
        <select id="selectedBlackCards" name="selectedBlackCards" multiple="multiple">
          <%
            if (editCardSet != null) {
              for (PyxBlackCard blackCard : editCardSet.getBlackCards()) {
          %>
            <option value="<%=blackCard.getId()%>" id="bc_<%=blackCard.getId()%>">
              <%=StringEscapeUtils.escapeXml11(blackCard.toString())%>
            </option>
          <%
              }
            }
          %>
        </select>
      </div>
    </div>

    <hr />

    <div class="dual-select">
      <div class="dual-select-column">
        <strong>📚 Available White Cards</strong>
        <select id="allWhiteCards" multiple="multiple">
          <%
            for (PyxWhiteCard whiteCard : whiteCards) {
          %>
            <option value="<%=whiteCard.getId()%>">
              <%=StringEscapeUtils.escapeXml11(whiteCard.toString())%>
            </option>
          <%
            }
          %>
        </select>
        <div class="button-group">
          <input type="button" id="addWhiteCards" class="btn-secondary" value="→ Add Selected →" />
          <input type="button" id="removeWhiteCards" class="btn-secondary" value="← Remove Selected ←" />
        </div>
      </div>

      <div class="dual-select-column">
        <strong>⬜ White Cards in Set</strong>
        <select id="selectedWhiteCards" name="selectedWhiteCards" multiple="multiple">
          <%
            if (editCardSet != null) {
              for (PyxWhiteCard whiteCard : editCardSet.getWhiteCards()) {
          %>
            <option value="<%= whiteCard.getId() %>" id="wc_<%= whiteCard.getId() %>">
              <%= StringEscapeUtils.escapeXml11(whiteCard.toString()) %>
            </option>
          <% 
              }
            }
          %>
        </select>
      </div>
    </div>

    <input type="submit" value="💾 Save Card Set" />
  </form>
</div>
</body>
</html>
<%
} finally {
  hibernateSession.close();
}
%>
