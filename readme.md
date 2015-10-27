# xbrlus

This package provides an R interface to 
[XBRL US API](https://github.com/xbrlus/data_analysis_toolkit).


## Installation


```r
devtools::install_github("bergant/xbrlus")
```

## Setup
All APIs (except for the `CIKLookup`) require use of a valid XBRL US API
key. You can get the key and read the terms of usage at
http://xbrl.us/use/howto/data-analysis-toolkit/.

__xbrlus__ package will read the API key from environment variable
`XBRLUS_API_KEY`.
To start R session with the initialized environment variable
create a file in your R home with a line like this:

`XBRLUS_API_KEY=EnterKeyHere`

and name it as `.Renviron`. To check where your R home is, type `normalizePath("~")` in your R console.

## Usage
Get information about companies and XBRL concepts with `xbrlCIKLookup` 
and `xbrlBaseElement`: 

```r
library(xbrlus)

companies <- xbrlCIKLookup(c(
  "aapl", 
  "goog", 
  "fb"
)) 

elements <- xbrlBaseElement(c(
  "AssetsCurrent",
  "AssetsNoncurrent",
  "Assets",
  "LiabilitiesCurrent",
  "LiabilitiesNoncurrent",
  "Liabilities",
  "StockholdersEquity",
  "MinorityInterest",
  "StockholdersEquityIncludingPortionAttributableToNoncontrollingInterest",
  "LiabilitiesAndStockholdersEquity"
))
```

Use `xbrlValues` to get balance sheet values:

```r
values <- xbrlValues(
  CIK = companies$cik, 
  Element = elements$elementName, 
  DimReqd = FALSE, 
  Period = "Y",
  Year = 2013,
  NoYears = 1,
  Ultimus = TRUE,
  Small = TRUE,
  as_data_frame = TRUE
)
```

Reshape to wide format and print table:

```r
library(dplyr)
library(tidyr)
library(htmlTable)

balance_sheet <- 
  elements %>% 
  left_join(values, by = "elementName") %>% 
  select(entity, standard.text, amount) %>% 
  mutate(amount = round(amount / 10e6,0)) %>%  
  spread(entity, amount )

balance_sheet <- balance_sheet[order(order(elements$elementName)), ]  
htmlTable(balance_sheet, 
          align="lrrr", align.header = "lrrr", 
          rnames = FALSE, 
          caption = "Bilance Sheet Comparison")
```

<table class='gmisc_table' style='border-collapse: collapse;' >
<thead>
<tr><td colspan='5' style='text-align: left;'>
Bilance Sheet Comparison</td></tr>
<tr>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: left;'>standard.text</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: right;'>APPLE INC</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: right;'>FACEBOOK INC</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: right;'>Google Inc.</th>
<th style='border-bottom: 1px solid grey; border-top: 2px solid grey; text-align: right;'></th>
</tr>
</thead>
<tbody>
<tr>
<td style='text-align: left;'>Assets, Current</td>
<td style='text-align: right;'>7329</td>
<td style='text-align: right;'>1307</td>
<td style='text-align: right;'>7289</td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Assets, Noncurrent</td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
<td style='text-align: right;'>3803</td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Assets</td>
<td style='text-align: right;'>20700</td>
<td style='text-align: right;'>1790</td>
<td style='text-align: right;'>11092</td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Liabilities, Current</td>
<td style='text-align: right;'>4366</td>
<td style='text-align: right;'>110</td>
<td style='text-align: right;'>1591</td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Liabilities, Noncurrent</td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Liabilities</td>
<td style='text-align: right;'>8345</td>
<td style='text-align: right;'>242</td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Stockholders' Equity Attributable to Parent</td>
<td style='text-align: right;'>12355</td>
<td style='text-align: right;'>1547</td>
<td style='text-align: right;'>8731</td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Stockholders' Equity Attributable to Noncontrolling Interest</td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='text-align: left;'>Stockholders' Equity, Including Portion Attributable to Noncontrolling Interest</td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
<td style='text-align: right;'></td>
</tr>
<tr>
<td style='border-bottom: 2px solid grey; text-align: left;'>Liabilities and Equity</td>
<td style='border-bottom: 2px solid grey; text-align: right;'>20700</td>
<td style='border-bottom: 2px solid grey; text-align: right;'>1790</td>
<td style='border-bottom: 2px solid grey; text-align: right;'>11092</td>
<td style='border-bottom: 2px solid grey; text-align: right;'></td>
</tr>
</tbody>
</table>


## References
Data Analysis Toolkit and API description on GitHub: https://github.com/xbrlus/data_analysis_toolkit
