---
layout: default
title: Power BI projects
---

# Power BI projects

[Back](./)

This page includes some personal Power BI projects developed while I was studying for the PL-300 certification.

## COVID Power BI report

I developed a report on COVID during Jan - July 2020 using public domain data from Kaggle.  This uses main bar and line charts with slicers.  This was developed using a free Power BI license so I am unable to add a link to the reports directly.  The pbix file can be downloaded [here](COVID2.pbix)

The first page shows a table of the top 10 countries by number of confirmed cases at the end of the reporting period.  Clicking a row on the table filters the line charts
to data from that country only.  The line charts show average confirmed cases and deaths across the reporting period for all countries.

![First Page](/docs/assets/images/Page1.png)

The second page breaks down cumulative confirmed cases and deaths by WHO region at the end of the reporting period.

![Second Page](/docs/assets/images/Page2.png)

The third page shows the changes in new cases and new deaths across the reporting period using line charts.  A slicer allows this to be refined by WHO region, or all regions.

![Third Page](/docs/assets/images/Page3.png)

The fourth page shows the change in deaths by case across the reporting period, and also the cumulative deaths per confirmed case for each WHO region. A slicer allows this to be refined by WHO region, or all regions. The slicer is synced to the slicer on the previous page so changing one will filter both pages.

![Fourth Page](/docs/assets/images/Page4.png)

The fifth page shows a pie chart of the total recovered cases by region and a line chart showing the change in total recovered across the reporting period.  Selecting a sector of the pie chart will filter the line chart to show the selected region(s) only

![Fifth Page](/docs/assets/images/Page5.png)