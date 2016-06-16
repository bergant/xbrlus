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

    ret_list <-
      lapply(
        Element, xbrlBaseElement,
        Namespace = Namespace, as_data_frame = as_data_frame
      )
    # using Reduce/merge instead of do.call/rbind because some columns
    #  in xbrlus database could be missing (see #3 issue)
    ret_df <- Reduce(function(x, y) {merge(x, y, all = TRUE)}, ret_list)
    return(ret_df)

  }
  ret <- xbrlus_get("xbrlBaseElement", list(
    Element=Element,
    Namespace = Namespace
  ))
  if(as_data_frame) {
    ret <- xbrlus_to_data_frame(ret, "baseElement")
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
#' @param as_data_frame Return value in a data frame (default)
#' @references \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlChildren.md}
#' @details All calls to the API must include the Element parameter name and
#'   at least an AccessionID or an Accession number.
#'   In addition the extended link role must be reported.
#' @examples
#' \dontrun{
#'   xbrlChildren(
#'     Element = "Assets", AccessionID = 120617,
#'     GroupURI = "http://www.thecocacolacompany.com/role/ConsolidatedBalanceSheets",
#'     Linkbase = "Calculation", NetworkLink = "summation-item")
#'   )
#' }
#' @export
xbrlChildren <- function(Element, AccessionID = NULL, GroupURI,
                         Linkbase = NULL,
                         Accession = NULL,
                         NetworkLink = NULL,
                         as_data_frame = TRUE) {
  ret <-
    xbrlus_get("xbrlChildren", list(
      Element = Element,
      AccessionID = AccessionID,
      GroupURI = GroupURI,
      Linkbase = Linkbase,
      Accession = Accession,
      NetworkLink = NetworkLink
    ))

  if(as_data_frame) {
    ret <- xbrlus_to_data_frame(ret)
  }
  ret
}

#' Taxonomy Children
#'
#' Gets relationships in a base taxonomy by passing the extended link role
#' (GroupURI), an element name and the namespace of a given taxonomy. The API
#' will return all children of the specified element plus attributes such as
#' weight, order and preferred labels. It will return multiple results. The API
#' also allows the user to specify the different linkbases and relationship
#' types associated with a report or network. For example a user can request the
#' calculation children of Assets in the balance sheet defined in the base
#' taxonomy.
#'
#' @param Element The element name in the base taxonomy. This parameter will not
#'   take a comma separated list.
#' @param Taxonomy The namespace of the taxonomy the element is in. The
#'   parameter allows you to get details from specific taxonomies.
#' @param GroupURI The extended link role in an XBRL report that is defined by
#'   the company.
#' @param Linkbase The type of network relationship. This could be a
#'   Presentation, Calculation or Definition. If this is not entered then all
#'   will be returned.
#' @param ResetCache If set to True the query will pull the data from the
#'   database and will not use a cached file if it is available. Setting the
#'   parameter to False will utilize cache and will be faster.
#' @param as_data_frame Return value in a data frame (default)
#' @references
#' \url{https://github.com/xbrlus/data_analysis_toolkit/blob/master/api/xbrlTaxChildren.md}
#'
#' @details All calls to the API must include the Element parameter name and at
#'   least an AccessionID or an Accession number. In addition the extended link
#'   role must be reported.
#' @examples
#' \dontrun{
#' xbrlTaxChildren(
#'   Element = "InterestExpenseBorrowings",
#'   Taxonomy = "http://fasb.org/us-gaap/2015-01-31",
#'   GroupURI = "http://fasb.org/us-gaap/role/statement/StatementOfIncome",
#'   Linkbase = "Calculation"
#' )
#'
#' }
#' @export
xbrlTaxChildren <- function(Element,
                         Taxonomy,
                         GroupURI,
                         Linkbase = NULL,
                         ResetCache = FALSE,
                         as_data_frame = TRUE) {
  ret <-
    xbrlus_get("xbrlTaxChildren", list(
      Element = Element,
      Taxonomy = Taxonomy,
      GroupURI = GroupURI,
      Linkbase = Linkbase,
      ResetCache = ResetCache
    ))

  if(as_data_frame) {
    ret <- xbrlus_to_data_frame(ret)
  }
  ret
}

#' Extension Element
#'
#' Gets details about elements used in the company extensions.
#'
#' @param Element The element name in the base taxonomy.
#'   This parameter will not take a comma separated list.
#' @param AccessionID Internal Accession identifier used by the XBRL US database.
#' @param Accession Filing accession number.
#'   This is the accession number used as the filing identifier used by the SEC.
#' @param Namespace The namespace of the company filing the data is requested for.
#'   For example http://www.ovt.com/20150430.
#' @param as_data_frame Return value in a data frame (default)
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
  Namespace = NULL,
  as_data_frame = TRUE)
{

  ret <-
    xbrlus_get("xbrlExtensionElement", list(
      Element = Element,
      AccessionID = AccessionID,
      Accession = Accession,
      Namespace = Namespace
    ))
  if(as_data_frame) {
    ret <- xbrlus_to_data_frame(ret, "baseElement")
  }
  ret
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
#' @param as_data_frame Return value in a data frame (default)
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
#'   xbrlNetwork(Element = "Assets", AccessionID = 120617, Linkbase = "Calculation")
#' }
#' @export
xbrlNetwork <- function(
  Element,
  Linkbase = NULL,
  AccessionID = NULL,
  Accession = NULL,
  CIK = NULL,
  as_data_frame = TRUE)
{

  ret <-
    xbrlus_get("xbrlNetwork", list(
      Element = Element,
      Linkbase = Linkbase,
      AccessionID = AccessionID,
      Accession = Accession,
      CIK = CIK
    ))


  if(as_data_frame) {
    ret <- xbrlus_to_data_frame(ret)
  }
  ret
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
  AccessionID = NULL, Accession = NULL, CIK = NULL, Restated = NULL,
  Element = NULL, Axis = NULL, Member = NULL, Dimension = NULL, DimReqd = NULL,
  ExtensionElement = NULL, ExtensionAxis = NULL, ExtensionMember = NULL,
  Period = NULL, StartYear = NULL, NoYears = NULL, Year = NULL, Ultimus = NULL,
  Small = NULL, as_data_frame = TRUE
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
    # API returns count == 0 if there is no data
    if(!is.null(ret$count) && ret$count == 0) return(data.frame())

    # convert to data frame
    ret <- xbrlus_to_data_frame(ret)

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


