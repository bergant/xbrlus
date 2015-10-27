#' Base Element Details
#'
#' Gets details of US GAAP Taxonomy element
#'
#' @param Element The element name in the base taxonomy
#' @param Namespace (optional) The namespace of the taxonomy the data is requested for.
#'   For example http://fasb.org/us-gaap/2015-01-31
#' @param as_data_frame Returns a data frame (TRUE by default)
#' @references \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlBaseElement.md}
#' @examples
#' \dontrun{
#' xbrlBaseElement("Assets")
#' }
#' @export
xbrlBaseElement <- function(Element, Namespace = NULL, as_data_frame = TRUE) {
  if(length(Element) > 1) {
    return(do.call(
      rbind,
      c(
        lapply(Element, xbrlBaseElement,
               Namespace = Namespace,
               as_data_frame = as_data_frame),
        make.row.names = FALSE)
    ))
  }
  ret <- xbrlus_get("xbrlBaseElement", list(
    Element=Element,
    Namespace = Namespace
  ))[[1]]
  if(as_data_frame) {
    ret <- as.data.frame(ret, stringsAsFactors = FALSE)
  }
  ret
}

#' CIK Lookup
#'
#' Gets Central Index Key and other information about a company from a ticker symbol
#'
#' @param Ticker The ticker of the company
#' @param as_data_frame Returns a data frame (TRUE by default)
#' @references \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlCIKLookup.md}
#' @examples
#' \dontrun{
#' xbrlCIKLookup("aapl")
#' }
#' @export
xbrlCIKLookup <- function(Ticker, as_data_frame = TRUE) {
  if(length(Ticker) > 1) {
    return(do.call(
      rbind,
      lapply(Ticker, xbrlCIKLookup, as_data_frame = as_data_frame)
    ))
  }

  ret <-
    xbrlus_get("xbrlCIKLookup", list(Ticker=Ticker), add_api_key = FALSE)[[1]]

  if(as_data_frame) {
    ret <- as.data.frame(ret, stringsAsFactors = FALSE)
  }
  ret
}

#' Children
#'
#' Gets the relationships in a network by passing the extended link role,
#' an element name and the filing number/CIK.
#'
#' @param Element The element name in the base taxonomy.
#'   This parameter will not take a comma separated list.
#' @param AccessionID Internal Accession identifier used by the XBRL US database.
#'   This is a unique filing identifier.
#'   For example one company will have many filings.
#'   This is returned by the API and can be used in subsequent calls.
#'   This allows a comma separated list
#' @param GroupURI The extended link role in an XBRL report that is defined by
#'   the company.
#' @param Linkbase The type of network relationship. This could be a
#'   Presentation, Calculation or Definition.
#'   If this is not entered then all will be returned.
#' @param Accession Filing accession number.
#'   This is the accession number used as the filing identifier used by the SEC.
#'   This parameter does not allow a comma separated list.
#' @param NetworkLink The relationship type that links two elements together.
#'   For example summation-item in the calculation linkbase or dimension-default
#'   in the definition linkbase.
#' @references \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlChildren.md}
#' @details All calls to the API must include the Element parameter name and
#'   at least an AccessionID or an Accession number.
#'   In addition the extended link role must be reported.
#' @examples
#' \dontrun{
#'   xbrlChildren(
#'     Element = "IncomeStatementAbstract",
#'     AccessionID = "146420",
#'     GroupURI = "http://www.ibm.com/role/StatementCONSOLIDATEDSTATEMENTOFEARNINGS",
#'     Linkbase = "Calculation"
#'   )
#' }
#' @export
xbrlChildren <- function(Element, AccessionID = NULL, GroupURI,
                         Linkbase = NULL,
                         Accession = NULL,
                         NetworkLink = NULL) {
  xbrlus_get("xbrlChildren", list(
    Element = Element,
    AccessionID = AccessionID,
    GroupURI = GroupURI,
    Linkbase = Linkbase,
    Accession = Accession,
    NetworkLink = NetworkLink
  ))
}

#' Extension Element
#'
#' Gets the relationships in a network by passing the extended link role,
#' an element name and the filing number/CIK.
#'
#' @param Element The element name in the base taxonomy.
#'   This parameter will not take a comma separated list.
#' @param AccessionID Internal Accession identifier used by the XBRL US database.
#' @param Accession Filing accession number.
#'   This is the accession number used as the filing identifier used by the SEC.
#' @param Namespace The namespace of the company filing the data is requested for.
#'   For example http://www.ovt.com/20150430.
#' @references \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlExtensionElement.md}
#' @examples
#' \dontrun{
#'   xbrlExtensionElement(
#'     AccessionID = 103575,
#'     Element = "ResearchDevelopmentAndRelatedExpenses"
#'   )
#' }
#' @details This API allows the user to fetch details of about elements used in
#'   the company extensions in an XML format, by passing the element name,
#'   namespace and entity information in the API.
#'   THe API allows the user to get the attributes of an extension element and
#'   the associated labels.
#'   If the filing information is provided the API will return the labels used
#'   by the company in their extension filing.
#'   As a convenience it will also return the attributes of the US GAAP taxonomy.
#' @export
xbrlExtensionElement <- function(
  Element,
  AccessionID = NULL,
  Accession = NULL,
  Namespace = NULL )
{

  xbrlus_get("xbrlExtensionElement", list(
    Element = Element,
    AccessionID = AccessionID,
    Accession = Accession,
    Namespace = Namespace
  ))
}

#' Network
#'
#' Gets the relationships in a network by passing the extended link role,
#' an element name and the filing number/CIK.
#'
#' @param Element The element name in the base taxonomy.
#'   This parameter will not take a comma separated list.
#' @param Linkbase The type of network relationship. This could be a
#'   Presentation, Calculation or Definition.
#'   If this is not entered then all will be returned.
#' @param AccessionID Internal Accession identifier used by the XBRL US database.
#' @param Accession Filing accession number.
#'   This is the accession number used as the filing identifier used by the SEC.
#' @param CIK CIK of the Company. This must be 10 digits in length.
#'   This parameter allows a comma separated list.
#' @details This API allows the user to fetch details about a report
#'   (Group/Network/Extended link role) in an XBRL filing that an element
#'   appears in such as the balance sheet or income statement.
#'   This could return multiple results as Assets for example could be in
#'   multiple locations in a filing.
#'   The user passes an element and filing number/CIK and the report url will be
#'   returned.
#'   The API allows the user to specify the different linkbases associated with
#'   a report. For example a user can request the calculation network for those
#'   reports that contain Assets for company ABC.
#'
#'   All calls to the API must include the Element parameter name and at least
#'   an AccessionID or an Accession number or a CIK parameter.
#' @references \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlNetwork.md}
#' @examples
#' \dontrun{
#'   xbrlNetwork(Element="Assets", AccessionID = 103575)
#' }
#' @export
xbrlNetwork <- function(
  Element,
  Linkbase = NULL,
  AccessionID = NULL,
  Accession = NULL,
  CIK = NULL )
{

  xbrlus_get("xbrlNetwork", list(
    Element = Element,
    Linkbase = Linkbase,
    AccessionID = AccessionID,
    Accession = Accession,
    CIK = CIK
  ))
}


#' Values
#'
#' This API allows the user to fetch XBRL facts from the XBRL US database by
#' passing financial statement parameters to define the data returned.
#'
#' @param AccessionID Internal Accession identifier used by the XBRL US
#'   database.
#' @param Accession Filing accession number. This is the accession number used
#'   as the filing identifier used by the SEC.
#' @param CIK CIK of the Company. This must be 10 digits in length. Can be a
#'   character vector.
#' @param Restated A value of false will exclude amounts subsequently restated,
#'   a value of true will include amounts that were restated. If no value is
#'   defined the API defaults to false.
#' @param Element The element name in the base taxonomy. Can be a character
#'   vector.
#' @param Axis The XBRL axis element. Can be a vector. If defined the API will
#'   return facts which use this axis. If DimReqd is set to false this parameter
#'   will be ignored
#' @param Member The XBRL member element. Can be a vector. If defined the API
#'   will return facts which use this member. If DimReqd is set to false this
#'   parameter will be ignored.
#' @param Dimension Axis and member i.e.
#'   DimensionID:IncomeTaxAuthorityAxi:AbasMember. Can be a vector.
#' @param DimReqd True returns all facts with and without dimensions associated
#'   with fact, false returns records with no dimensions. If no value is defined
#'   the API defaults to true.
#' @param ExtensionElement =[base|extension] - base will return non extension
#'   elements and extension will return extension elements. If no value is
#'   provided then all elements are returned.
#' @param ExtensionAxis =[base|extension] - base will return non extension axes
#'   and extension will return extension axes. If no value is provided then all
#'   axes are returned. If DimReqd is set to false this parameter is ignored.
#' @param ExtensionMember =[base|extension] - base will return non extension
#'   members and extension will return extension members. If no value is
#'   provided then all members are returned. If DimReqd is set to false this
#'   parameter is ignored.
#' @param Period =[Y|1Q|2Q|3Q|3QCUM|4Q|1H|2H|Other] - Period required, if not
#'   provided all periods are returned. This parameter allows a comma separated
#'   list.
#' @param StartYear [integer] - First Year of data to return a range used in
#'   conjunction with the Year parameter to define a range.
#' @param Year Year of the data required
#' @param NoYears [integer] - Use to define the number of years of data returned
#'   based on value provided for Year. For example if NoYears is set to 3 and
#'   Year is set to 2014 then fact values will be returned for 2012, 2013, and
#'   2014. If Year is not provided then NoYears is ignored.
#' @param Ultimus [boolean] - True returns the latest value, false returns all
#'   values. If no value is defined the API defaults to true.
#' @param Small [boolean] - If this parameter is set to true the number of
#'   columns in response is cut down.
#' @param as_data_frame If a data frame is wanted (TRUE by default)
#' @details All calls to the API must include at least a CIK or Filing Accession
#'   Number. You can pull data for multiple entities by listing them as comma
#'   separated values. It's not possible to call all values for an element such
#'   as Assets as the response will be too large.
#' @references
#' \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlValues.md}
#'
#' @examples
#' \dontrun{
#'   xbrlValues(
#'     CIK="0000732717",
#'     Element="Assets",
#'     Period="Y",
#'     Year=2014,
#'     NoYears=3,
#'     DimReqd = FALSE,
#'     Small = TRUE,
#'     Ultimus = TRUE
#'   )
#' }
#' @export
xbrlValues <- function(
  AccessionID = NULL,
  Accession = NULL,
  CIK = NULL,
  Restated = NULL,

  Element = NULL,
  Axis = NULL,
  Member = NULL,
  Dimension = NULL,
  DimReqd = NULL,
  ExtensionElement = NULL,
  ExtensionAxis = NULL,
  ExtensionMember = NULL,

  Period = NULL,
  StartYear = NULL,
  NoYears = NULL,
  Year = NULL,
  Ultimus = NULL,

  Small = NULL,

  as_data_frame = TRUE
)
{
  if(length(CIK) > 1) {
    CIK <- paste(CIK, collapse = ", ")
  }
  if(length(Element) > 1) {
    Element <- paste(Element, collapse = ", ")
  }

  ret <-
    xbrlus_get("xbrlValues", list(
      AccessionID = AccessionID,
      Accession = Accession,
      CIK = CIK,
      Restated = Restated,

      Element = Element,
      Axis = Axis,
      Member = Member,
      Dimension = Dimension,
      DimReqd = DimReqd,
      ExtensionElement = ExtensionElement,
      ExtensionAxis = ExtensionAxis,
      ExtensionMember = ExtensionMember,

      Period = Period,
      StartYear = StartYear,
      NoYears = NoYears,
      Year = Year,
      Ultimus = Ultimus,

      Small = Small
    ))

  if(as_data_frame) {
    # convert to data frame
    ret <- do.call(
      rbind,
      c(lapply(ret[names(ret) == "fact"], function(x) {
        x[sapply(x,is.null)] <- NA
        as.data.frame(x, stringsAsFactors = FALSE)
      }),
      make.row.names = FALSE)
    )

    # convert dates and numbers
    numeric_cols <- intersect(c("amount", "decimals", "fact"), names(ret))
    date_cols <- intersect(c("periodStart", "periodEnd", "periodInstant"), names(ret))
    for(x in numeric_cols) {
      ret[[x]] <- as.numeric(ret[[x]])
    }
    for(x in date_cols) {
      ret[[x]] <- as.Date(ret[[x]])
    }
  }

  ret
}


if(FALSE) {
  xbrlCIKLookup("aapl")

  xbrlChildren(
    Element = "IncomeStatementAbstract",
    #AccessionID = "146420",
    Accession = "0001047469-15-001106",
    GroupURI = "http://www.ibm.com/role/http://www.ibm.com/role/StatementConsolidatedStatementOfEarnings"
    #Linkbase = "Calculation"
  )
  xbrlChildren(
    Element = "Assets",
    #AccessionID = 146420,
    Accession = "0001047469-15-001106",
    GroupURI = "http://www.ibm.com/role/",
    Linkbase = "Calculation"
  )

  xbrlExtensionElement(AccessionID = 103575, Element = "ResearchDevelopmentAndRelatedExpenses")
  xbrlExtensionElement(AccessionID = 103575, Element = "ResearchDevelopmentAndRelatedExpenses")
  xbrlNetwork(Element="Assets", AccessionID = 103575, Element = "ResearchDevelopmentAndRelatedExpenses")
  ret <- xbrlNetwork(Element="Assets", AccessionID = 22871)
  ret <- xbrlNetwork(Element="Assets", Accession = "0001193125-09-153165")

  str(ret)
  xbrlChildren(Element = "Assets", AccessionID = 22871, GroupURI = "http://www.apple.com/taxonomy/role/statement/IMetrix_StatementOfFinancialPositionClassified")
  xbrlChildren(Element = "Assets", NetworkLink = "1797733", GroupURI = "http://www.apple.com/taxonomy/role/statement/IMetrix_StatementOfFinancialPositionClassified")
  xbrlChildren(Element = "Assets", NetworkLink = "1797733")
  xbrlChildren(Element = "Assets", NetworkLink = "1797733")


  ret <-
    xbrlValues(
      CIK="0000732717",
      Element="Assets",
      Period="Y",
      Year=2014,
      NoYears=3,
      DimReqd = FALSE,
      Small = TRUE,
      Ultimus = "true"
    )

  str(ret)

}

