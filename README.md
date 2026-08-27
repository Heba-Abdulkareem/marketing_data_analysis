# Olist Marketing Analysis

## Project Overview

This project analyzes marketing qualified leads to understand where leads are coming from, which landing pages attract the most leads, and how lead activity changes over time.

The analysis was done using SQL and Power BI, starting with the raw data and turning it into a dashboard that makes the main patterns easier to understand.

## Business Questions

The analysis focuses on a few main questions:

- Which marketing sources generate the most leads?
- Which landing pages have the highest lead volume?
- How does lead volume change over time?
- Which sources perform better across different periods?
- Are leads more common on weekdays or weekends?
- How concentrated are leads across landing pages?
- Are there any data quality issues that could affect the analysis?

## Approach

I started by looking at the overall dataset and checking the number of leads, sources, and landing pages.

Then I analyzed lead volume by source and landing page to identify the main contributors.

After that, I looked at monthly trends and month-over-month changes to understand how lead activity changed over time.

I also compared weekday and weekend activity and analyzed source performance across different months.

Finally, I checked for missing values and duplicate lead IDs and used cumulative analysis to understand how leads are distributed across landing pages.

## Key Findings

- The dataset contains around 8,000 leads from 11 sources and 495 landing pages.
- Organic search is the largest source of leads, followed by paid search and social.
- Most leads were generated during weekdays, with weekdays accounting for about 86.8% of leads.
- Lead volume varies considerably across months, with some periods showing much higher activity than others.
- Lead volume is concentrated across a smaller group of landing pages, while many landing pages generate relatively few leads.
- Missing source values are present in the data and were included as a separate category during the analysis.

## Power BI Dashboard

The dashboard is divided into two pages.

### Overview

The first page provides a high-level view of:

- Total leads
- Lead sources
- Landing pages
- Lead volume by source
- Monthly lead trends
- Weekday vs weekend distribution
- Top 10 landing pages

### Detailed Marketing Analysis

The second page focuses on:

- Source performance by day type
- Monthly source performance
- Cumulative lead distribution by landing page
- 80% target analysis

## Tools

- MySQL
- Power BI
- Excel

## Files

- `olist_marketing_analysis.sql` — SQL analysis and queries
- `marketing_dashboard.pbix` — Power BI dashboard
