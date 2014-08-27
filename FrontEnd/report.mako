## -*- coding: utf-8 -*-
<%doc>
    ,o888888o.       d888888o.   8 888888888o
 . 8888     `88.   .`8888:' `88. 8 8888    `88.
,8 8888       `8b  8.`8888.   Y8 8 8888     `88
88 8888        `8b `8.`8888.     8 8888     ,88
88 8888         88  `8.`8888.    8 8888.   ,88'
88 8888         88   `8.`8888.   8 888888888P'
88 8888        ,8P    `8.`8888.  8 8888
`8 8888       ,8P 8b   `8.`8888. 8 8888
 ` 8888     ,88'  `8b.  ;8.`8888 8 8888
    `8888888P'     `Y8888P ,88P' 8 8888

8888888b.                                    888
888   Y88b                                   888
888    888                                   888
888   d88P .d88b.  88888b.   .d88b.  888d888 888888
8888888P" d8P  Y8b 888 "88b d88""88b 888P"   888
888 T88b  88888888 888  888 888  888 888     888
888  T88b Y8b.     888 d88P Y88..88P 888     Y88b.
888   T88b "Y8888  88888P"   "Y88P"  888      "Y888
                   888
 .d8888b.          888                                888
d88P  Y88b         888                                888
888    888                                            888
888         .d88b.  88888b.   .d88b.  888d888 8888b.  888888 .d88b.  888d888
888  88888 d8P  Y8b 888 "88b d8P  Y8b 888P"      "88b 888   d88""88b 888P"
888    888 88888888 888  888 88888888 888    .d888888 888   888  888 888
Y88b  d88P Y8b.     888  888 Y8b.     888    888  888 Y88b. Y88..88P 888
 "Y8888P88  "Y8888  888  888  "Y8888  888    "Y888888  "Y888 "Y88P"  888

## AUTHOR AND PROGRAM INFO ####################################################

Author:  Alex Jansons <u5183898@anu.edu.au>
Version: 1.0 (MVP)
Created: 28/07/2014

Welcome the report generator of the OhScapPlease (OSP) package! The aim of this
program is to create a HTML report from XML data extracted from a SQL database
based on parameters specified in a config file. The tasks of extracting the
data and parsing the config file are left up to the other components of OSP.

How to use:

To generate a report, simply type: python makereport.py
and then open write2me.html

This program requires the mako library, which you can easily get with pip:
pip install mako

Design:

The minimum viable product (MVP) needs to be able to generate a table with the 
following fields (and a chart):

Definition Name | Definition Result | Machine Name | Date

These are the fields defined in Theo's basic schema: https://cs.anu.edu.au/redm
ine/attachments/download/870/Screen%20Shot%202014-08-02%20at%206.46.54%20pm.png

In the basic schema, the definition result will be one of the following:
notapplicable, notselected, pass, fixed, error, fail. In a future version, the
number of possible results will be reduced to just: fail, pass, notapplicable.

Extended schema: https://cs.anu.edu.au/redmine/attachments/download/922/Screen%
20Shot%202014-08-07%20at%2011.00.53%20pm.png

Some suggested/planned features for future versions include:

-Being able to click a machine name, definition name or result to get more
 information about it.

-The addition of a line/bar chart, to illustrate the overall make up of results
 over a period of time.

</%doc>
##
## SETUP (MODULE LEVEL CODE) ##################################################
##
<%!
   ## What the heck is module level code? Code within these tags is executed at
   ## the module level of the template, and not within the rendering function
   ## of the template. Therefore, this code does not have access to the
   ## template’s context and is only executed when the template is loaded into
   ## memory (which can be only once per application, or more, depending on
   ## the runtime environment). See more at:
   ## http://docs.makotemplates.org/en/latest/syntax.html#module-level-blocks
    
   ## Do our module imports
      import datetime
      import fakedata

   ## Get the date, so we can record when the report was generated
      def getDate():
        return datetime.datetime.now()
    
   ## Get some fake data from the fake data module to create an example report
   ## important: data is a list of dictionaries! Each dictionary can be
   ## thought of as essentially a row in a table. Where the key is the field
   ## and the value is, well, the value for that field. And since data is a
   ## list of rows, we can easily turn it into a table!
      data = fakedata.get_MVP()
    
   ## We're going to count how many results there are, to work out %'s later
   ## Basically, it's the sum of resultcount's values.
      totalresults = 0
    
   ## resultcount is a dictionary that records how many fails, passes, etc
   ## there are. Key = result, Value = number of that result
      resultcount = {}
      for i in data:
        if i['result'] in resultcount:
          resultcount[i['result']] = resultcount[i['result']] + 1
        else:
          resultcount[i['result']] = 1
        totalresults = totalresults + 1

   ## Colours for the results. I just picked some pastels I think represent
   ## the results. They'll be used for the chart, and the table cell colours.
   ## TODO: Change to Red, Green, Grey once we're down to 3 result types.
      resultcolours = {'fail': '#FE6A6A',
                       'error': '#997D65',
                       'notapplicable': '#EAD376',
                       'notselected': '#CCCCCC',
                       'pass': '#A6EAAA',
                       'fixed': '#B0CFFE'}
%>
##
## HELPER FUNCTIONS ###########################################################
##
## This function creates HTML table rows from dictionaries. Notice that each
## result type has their own <td> class defined. This just colours the cell
## based on the result. Check out style.css to see the implementation.
## TODO: at the moment, the values are hard-coded in the CSS, but it would be
## nice in the future to have the colours defined in one place, so you don't
## have to change them twice. I think a CSS mako template could do this.
<%def name="make_result_row(i)">
    <tr>
        <td>${i['definition_name']}</td>\
        <td class=${i['result']}>${i['result']}</td>\
        <td>${i['machine_name']}</td>\
        <td>${i['date'].isoformat()}</td>\
    </tr>
</%def>
##
## HTML TEMPLATE ##############################################################
##
## Now begins the HTML template. Anything that isn't wrapped up in mako tags
## will be written as is., unless it's after ##

<html>
  <head>
    ## Import the scripts we'll be using for table sorting and making the chart
    <link rel="stylesheet" type="text/css" href="style.css">
    <script src="sorttable.js"></script>
    <script src="Chart.js"></script>
    <title>OSP Report</title>
  </head>
  <body onload="createChart();">
    
    <h1>OSP Report</h1>
    <h3>Generated at ${getDate()}</h2>

    <br>

    <div class="left">
      ## Here we print the main table of the result data
      <h2>Definition Results</h2>
      <hr>
      <table class="sortable" id="def_table">
        <thead>
          <tr>
            ## These are the schema fields that will form our table header
            ## TODO: Make a function to generate these
            <th>Definintion</th>
            <th>Result</th>
            <th>Machine Name</th>
            <th>Date</th>
          </tr>
      </thead>
      <tbody>
         ## Now we populate the table with some rows
         <%
           for i in data:
             {make_result_row(i)}
           endfor
         %>
       <tbody>
     </table>
    </div>
    ## In the right column, we have our pie chart and result over table
    <div class="right">
      <h2>Results Overview</h2>
      <hr>
      <table class="sortable" id="overview_table">
        <thead>
          <th>Result</th>
          <th>Percentage</th>
        </thead>
        <tbody>
          % for i in resultcount:
            <tr>
              <td class=${i}>${i}</td>
              ## There seems to be an issue with rounding here, I think it
              ## has something to do with the difference between python
              ## two and 3. TODO: Fix this
              <td>${round((resultcount[i]/float(totalresults)),2)*100}%</td>
            </tr>
          % endfor
        </tbody>
      </table>

      <br><br><br>

      <center>
        <canvas id="myChart" width="350" height="350"></canvas>
      </center>
    </div>
  </body>
</html>

## Here we define a javascript function that'll make our chart
<script type="text/javascript">
      function createChart() {
      var data = [
        % for i in resultcount:
          {
            value:  ${resultcount[i]},
            color: "${resultcolours[i]}",
            label: "${i}"
          },
        % endfor
      ];
      var cht = document.getElementById('myChart');
      var ctx = cht.getContext('2d');
      var myChart = new Chart(ctx).Doughnut(data);

    }
</script>