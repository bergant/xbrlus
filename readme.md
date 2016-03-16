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

balance_sheet <- 
  elements %>% 
  left_join(values, by = "elementName") %>% 
  select(entity, standard.text, amount) %>% 
  mutate(amount = round(amount / 10e6,0)) %>%  
  spread(entity, amount)

balance_sheet <- balance_sheet[
    order(order(elements$elementName)),   
    !is.na(names(balance_sheet))]
row.names(balance_sheet) <- NULL

library(pander)
pandoc.table(
  balance_sheet,
  caption = "Balance Sheet Comparison",
  big.mark = ",",
  split.table = 200,
  style = "rmarkdown",
  justify = c("left", rep("right", 3)))
```



| standard.text                                                                   |   APPLE INC |   FACEBOOK INC |   Google Inc. |
|:--------------------------------------------------------------------------------|------------:|---------------:|--------------:|
| Assets, Current                                                                 |       7,329 |          1,307 |         7,289 |
| Assets, Noncurrent                                                              |          NA |             NA |         3,803 |
| Assets                                                                          |      20,700 |          1,790 |        11,092 |
| Liabilities, Current                                                            |       4,366 |            110 |         1,591 |
| Liabilities, Noncurrent                                                         |          NA |             NA |            NA |
| Liabilities                                                                     |       8,345 |            242 |            NA |
| Stockholders' Equity Attributable to Parent                                     |      12,355 |          1,547 |         8,731 |
| Stockholders' Equity Attributable to Noncontrolling Interest                    |          NA |             NA |            NA |
| Stockholders' Equity, Including Portion Attributable to Noncontrolling Interest |          NA |             NA |            NA |
| Liabilities and Equity                                                          |      20,700 |          1,790 |        11,092 |

Table: Balance Sheet Comparison


## References
Data Analysis Toolkit and API description on GitHub: https://github.com/xbrlus/data_analysis_toolkit
