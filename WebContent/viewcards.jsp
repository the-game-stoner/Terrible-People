<?xml version="1.0" encoding="UTF-8" ?>
<%--
Copyright (c) 2013-2018, Andy Janata
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
Interface to view and search all existing cards and card sets.

@author Andy Janata (ajanata@socialgamer.net)
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.google.inject.Injector" %>
<%@ page import="com.google.inject.Key" %>
<%@ page import="net.socialgamer.cah.CahModule.IncludeInactiveCardsets" %>
<%@ page import="net.socialgamer.cah.HibernateUtil" %>
<%@ page import="net.socialgamer.cah.StartupUtils" %>
<%@ page import="net.socialgamer.cah.db.PyxBlackCard" %>
<%@ page import="net.socialgamer.cah.db.PyxCardSet" %>
<%@ page import="net.socialgamer.cah.db.PyxWhiteCard" %>
<%@ page import="org.hibernate.Session" %>
<%@ page import="org.json.simple.JSONValue" %>
<%
  Session hibernateSession = HibernateUtil.instance.sessionFactory.openSession();

ServletContext servletContext = pageContext.getServletContext();
Injector injector = (Injector) servletContext.getAttribute(StartupUtils.INJECTOR);
boolean includeInactive = injector.getInstance(Key.get(Boolean.TYPE, IncludeInactiveCardsets.class));

try {
  @SuppressWarnings("unchecked")
  List<PyxCardSet> cardSets = hibernateSession
      .createQuery(PyxCardSet.getCardsetQuery(includeInactive))
      .setReadOnly(true)
      .setCacheable(true)
      .list();
  
  Map<String, Object> data = new HashMap<String, Object>();
  
  Map<Integer, List<Integer>> whiteCardSets = new HashMap<Integer, List<Integer>>();
  Map<Integer, List<Integer>> blackCardSets = new HashMap<Integer, List<Integer>>();
  
  Set<PyxWhiteCard> whiteCards = new HashSet<PyxWhiteCard>();
  Set<PyxBlackCard> blackCards = new HashSet<PyxBlackCard>();
  
  Map<Integer, Object> cardSetsData = new HashMap<Integer, Object>();
  data.put("cardSets", cardSetsData);
  int i = 0;
  for (PyxCardSet cardSet: cardSets) {
    Map<String, Object> cardSetData = new HashMap<String, Object>();
    cardSetData.put("name", cardSet.getName());
    cardSetData.put("id", cardSet.getId());
    cardSetData.put("description", cardSet.getDescription());

    List<Integer> whiteCardIds = new ArrayList<Integer>(cardSet.getWhiteCards().size());
    for (PyxWhiteCard whiteCard: cardSet.getWhiteCards()) {
      whiteCardIds.add(whiteCard.getId());
      whiteCards.add(whiteCard);
      if (!whiteCardSets.containsKey(whiteCard.getId())) {
        whiteCardSets.put(whiteCard.getId(), new ArrayList<Integer>());
      }
      whiteCardSets.get(whiteCard.getId()).add(cardSet.getId());
    }
    cardSetData.put("whiteCards", whiteCardIds);

    List<Integer> blackCardIds = new ArrayList<Integer>(cardSet.getBlackCards().size());
    for (PyxBlackCard blackCard: cardSet.getBlackCards()) {
      blackCardIds.add(blackCard.getId());
      blackCards.add(blackCard);
      if (!blackCardSets.containsKey(blackCard.getId())) {
        blackCardSets.put(blackCard.getId(), new ArrayList<Integer>());
      }
      blackCardSets.get(blackCard.getId()).add(cardSet.getId());
    }
    cardSetData.put("blackCards", blackCardIds);
    
    cardSetsData.put(i++, cardSetData);
  }
  
  Map<Integer, Object> blackCardsData = new HashMap<Integer, Object>();
  data.put("blackCards", blackCardsData);
  for (PyxBlackCard blackCard: blackCards) {
    Map<String, Object> blackCardData = new HashMap<String, Object>();
    
    blackCardData.put("text", blackCard.getText());
    blackCardData.put("watermark", blackCard.getWatermark());
    blackCardData.put("draw", blackCard.getDraw());
    blackCardData.put("pick", blackCard.getPick());
    blackCardData.put("card_sets", blackCardSets.get(blackCard.getId()));
    
    blackCardsData.put(blackCard.getId(), blackCardData);
  }
  
  Map<Integer, Object> whiteCardsData = new HashMap<Integer, Object>();
  data.put("whiteCards", whiteCardsData);
  for (PyxWhiteCard whiteCard: whiteCards) {
    Map<String, Object> whiteCardData = new HashMap<String, Object>();
    
    whiteCardData.put("text", whiteCard.getText());
    whiteCardData.put("watermark", whiteCard.getWatermark());
    whiteCardData.put("card_sets", whiteCardSets.get(whiteCard.getId()));
    
    whiteCardsData.put(whiteCard.getId(), whiteCardData);
  }
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
<title>Terrible People - Card Viewer</title>
<script type="text/javascript" src="js/jquery-1.11.3.min.js"></script>
<script type="text/javascript" src="js/jquery-migrate-1.2.1.js"></script>
<script type="text/javascript" src="js/jquery.cookie.js"></script>
<script type="text/javascript" src="js/jquery.json.js"></script>
<script type="text/javascript" src="js/QTransform.js"></script>
<script type="text/javascript" src="js/jquery-ui.min.js"></script>
<script type="text/javascript" src="js/jquery.tablesorter.js"></script>
<link rel="stylesheet" type="text/css" href="cah.css" media="screen" />
<link rel="stylesheet" type="text/css" href="jquery-ui.min.css" media="screen" />
<style>
  :root {
    --circle-bg: #070a0f;
    --circle-panel: rgba(255,255,255,0.06);
    --circle-border: rgba(255,255,255,0.12);
    --circle-text: rgba(255,255,255,0.92);
    --circle-accent: #09ff03;
    --circle-accent-soft: rgba(9,255,3,0.14);
  }
  
  body {
    background: radial-gradient(900px 500px at 15% 10%, rgba(9, 255, 3, 0.12), transparent 62%),
                linear-gradient(var(--circle-bg), var(--circle-bg));
    background-attachment: fixed;
    color: var(--circle-text);
    font-family: ui-sans-serif, system-ui, 'Segoe UI', sans-serif;
    margin: 0;
    min-height: 100vh;
    padding: 0;
  }
  
  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 24px;
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
  
  .filter-section {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    padding: 20px 24px;
    margin-bottom: 24px;
    display: flex;
    flex-wrap: wrap;
    gap: 24px;
    align-items: flex-start;
  }
  
  .filter-group {
    flex: 1;
    min-width: 250px;
  }
  
  .filter-group label {
    display: block;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--circle-accent);
    margin-bottom: 8px;
  }
  
  .filter-group select {
    width: 100%;
    height: 180px;
    background: rgba(0,0,0,0.5);
    border: 1px solid var(--circle-border);
    border-radius: 12px;
    color: var(--circle-text);
    padding: 8px;
  }
  
  .filter-group select option {
    padding: 4px 8px;
  }
  
  .filter-group input {
    width: 100%;
    background: rgba(0,0,0,0.5);
    border: 1px solid var(--circle-border);
    border-radius: 12px;
    padding: 12px 16px;
    font-size: 16px;
    color: var(--circle-text);
    box-sizing: border-box;
  }
  
  .filter-group input:focus {
    outline: none;
    border-color: var(--circle-accent);
    box-shadow: 0 0 0 3px rgba(9,255,3,0.15);
  }
  
  .card-table-wrapper {
    background: var(--circle-panel);
    border: 1px solid var(--circle-border);
    border-radius: 20px;
    overflow-x: auto;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  th {
    text-align: left;
    padding: 14px 16px;
    background: rgba(0,0,0,0.3);
    color: var(--circle-accent);
    font-weight: 600;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid var(--circle-border);
    cursor: pointer;
  }
  
  th:hover {
    background: var(--circle-accent-soft);
  }
  
  td {
    padding: 12px 16px;
    border-bottom: 1px solid var(--circle-border);
    vertical-align: top;
  }
  
  tr:hover td {
    background: rgba(255,255,255,0.03);
  }
  
  .card-type {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: bold;
    text-transform: uppercase;
  }
  
  .card-type-black {
    background: rgba(255,255,255,0.1);
    color: #fff;
  }
  
  .card-type-white {
    background: var(--circle-accent-soft);
    color: var(--circle-accent);
  }
  
  .watermark-badge {
    background: rgba(255,255,255,0.06);
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 11px;
    display: inline-block;
  }
  
  .card-text {
    font-size: 14px;
    line-height: 1.5;
  }
  
  /* Card set selector styling for multi-select */
  select[multiple] option:checked {
    background: var(--circle-accent-soft);
    color: var(--circle-accent);
  }
  
  .stats {
    margin-top: 16px;
    font-size: 13px;
    color: rgba(255,255,255,0.5);
    text-align: center;
  }
</style>
<script type="text/javascript">
var data = <%= JSONValue.toJSONString(data) %>;

$(document).ready(function() {
  var cardSetsElem = $('#cardSets'); 
  for (var weight in data.cardSets) {
    var cardSet = data.cardSets[weight];
    cardSetsElem.append(
        '<option value="' + cardSet.id + '" selected="selected">' + cardSet.name + '</option>');
  }
  
  var tableElem = $('#cards');
  for (var id in data.blackCards) {
    var card = data.blackCards[id];
    tableElem.append('<tr id="b' + id + '">\
        <td><span class="card-type card-type-black">Black</span></td>\
        <td class="card-text">' + escapeHtml(card.text) + '</td>\
        <td><span class="watermark-badge">' + (card.watermark || '') + '</span></td>\
        <td>' + card.draw + '</td>\
        <td>' + card.pick + '</td>\
      </tr>');
  }
  for (var id in data.whiteCards) {
    var card = data.whiteCards[id];
    tableElem.append('<tr id="w' + id + '">\
        <td><span class="card-type card-type-white">White</span></td>\
        <td class="card-text">' + escapeHtml(card.text) + '</td>\
        <td><span class="watermark-badge">' + (card.watermark || '') + '</span></td>\
        <td></td>\
        <td></td>\
      </tr>');
  }

  $('#search').keyup(filter);
  $('#cardSets').change(filter);
  $('#cardTable').tablesorter();
  $('#cardTextColumn').click();
  
  updateStats();
});

function escapeHtml(text) {
  if (!text) return '';
  return text.replace(/[&<>]/g, function(m) {
    if (m === '&') return '&amp;';
    if (m === '<') return '&lt;';
    if (m === '>') return '&gt;';
    return m;
  });
}

function updateStats() {
  var visible = $('#cards tr:visible').length;
  var total = $('#cards tr').length;
  $('#stats').text('Showing ' + visible + ' of ' + total + ' cards');
}

function filter() {
  $('#cards tr').hide();
  applyFilter(data.blackCards, 'b');
  applyFilter(data.whiteCards, 'w');
  updateStats();
}

function applyFilter(cardArray, prefix) {
  var cardSetIds = Array();
  $('#cardSets option:selected').each(function(index, elem) {
    cardSetIds[index] = Number(elem.value);
  });
  
  var query = $('#search').val();
  var regexp = new RegExp(query, 'i');
  for (var id in cardArray) {
    var card = cardArray[id];
    $(cardSetIds).each(function(index, cardSetId) {
      if ($.inArray(cardSetId, card.card_sets) !== -1 && card.text.match(regexp)) {
        $('#' + prefix + id).show();
      }
    });
  }
}
</script>
</head>
<body>
<div class="container">
  <a href="game.jsp" class="back-link">← Back to Game</a>
  
  <div class="filter-section">
    <div class="filter-group">
      <label>🎴 Card Sets (Ctrl/Cmd + click for multiple)</label>
      <select id="cardSets" multiple="multiple" size="8">
      </select>
    </div>
    <div class="filter-group">
      <label>🔍 Search Cards</label>
      <input type="text" id="search" placeholder="Search card text... (regex supported)" />
    </div>
  </div>
  
  <div class="card-table-wrapper">
    <table id="cardTable">
      <thead>
        <tr>
          <th style="width: 80px;">Type</th>
          <th id="cardTextColumn">Card Text</th>
          <th style="width: 100px;">Source</th>
          <th style="width: 60px;">Draw</th>
          <th style="width: 60px;">Pick</th>
        </tr>
      </thead>
      <tbody id="cards">
      </tbody>
    </table>
  </div>
  <div id="stats" class="stats"></div>
</div>
</body>
</html>
<%
} finally {
  hibernateSession.close();
}
%>
