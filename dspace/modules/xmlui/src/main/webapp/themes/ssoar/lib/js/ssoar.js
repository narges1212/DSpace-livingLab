/*
 * Self-made scripts for SSOAR
 */
var _imin, _isec, _MIN = 0, IDLE_TIME = 0;

_imin = 29; // IDLE time in minutes
_isec = 59;
// onload functionalities
window.onload = function() {

  displayInfolisButton(callback);

  if (document
      .getElementById("aspect_submission_StepTransformer_field_submit_upload") != null) {
    document.getElementById("aspect_submission_StepTransformer_field_file")
        .addEventListener("click", deactivateUploadButton);
  }

  if (document.getElementById('SetIdleTime') != null) {
    window.setInterval('getIdleTime()', 1000);
  }
  // only show sorting options, where this function makes sense:
  if (window.location.pathname.match(/.*ssoar.discover$/)
      && window.location.href.indexOf('?') === -1) {
    var divSearchControls = document
        .getElementsByClassName("form-content search-controls");
    for (var i = 0; i < divSearchControls.length; i += 1) {
      divSearchControls[i].style.display = "none";
    }
  }
  iffOpenAireFieldsExistAddOpenAireMagic();
}

function callback() {

  var iFrame = document.getElementById('InfolisIframe');
  var iFrameBody;

  if (iFrame.contentDocument) { // FF
    iFrameBody = iFrame.contentDocument.getElementsByTagName('body')[0];
  } else if (iFrame.contentWindow) { // IE
    iFrameBody = iFrame.contentWindow.document.getElementsByTagName('body')[0];
  }

  if (iFrameBody.innerHTML.includes("keine Studie vorhanden")) {
    // alert("Keine Studie Vorhanden");
    document.getElementById('infolisButton').style.display = "none";
  } else if (iFrameBody.innerHTML.includes("no ID")) {
    // alert(iFrameBody.innerHTML);
    document.getElementById('infolisButton').style.display = "none";
  } else {
    // alert("Studien Vorhanden");
    document.getElementById('infolisButton').style.display = "block";
  }

}

function displayInfolisButton(callback) {

  if (document.getElementById("urn") != null) {
    document.getElementById('infolisButton').style.display = "block";
    var urn = document.getElementById('urn').value;
    // alert(urn);
    var subUrn = urn.substring(22);
    var src = 'http://www.ssoar.info/infolis.php?id=' + subUrn;
    var infolisIFrame = document.getElementById('InfolisIframe');

    infolisIFrame.src = src;
    infolisIFrameJQuery = $(infolisIFrame);
    infolisIFrameJQuery.load(callback);
  }
}

function displayInfolisPopup(urn) {
  var subUrn = urn.substring(22);
  var src = 'http://www.ssoar.info/infolis.php?id=' + subUrn;
  document.getElementById('InfolisIframe').src = src;

  $('#glassPane').removeClass('hidden');
  $('#InfolisPopup').removeClass('hidden');
}

function InfolisCloseFunction() {
  $('#glassPane').addClass("hidden");
  $('.popup').each(function(i, obj) {
    $(this).addClass("hidden");
  });
}

function removeParameters(parameters) {
  // Get Query String from url
  fullQString = window.location.search.substring(1);
  paramCount = 0;
  queryStringComplete = "?";

  if (fullQString.length > 0) {
    // Split Query String into separate parameters
    paramArray = fullQString.split("&");

    // Loop through params, check if parameter exists.
    for (i = 0; i < paramArray.length; i++) {
      currentParameter = paramArray[i].split('=');
      ignoreParameter = false;
      for (j = 0; j < parameters.length; j++) {
        if (currentParameter[0] == parameters[j]) {
          ignoreParameter = true;
        }
      }
      if (!ignoreParameter) // Parameter already exists in current url
      {
        if (paramCount > 0)
          queryStringComplete = queryStringComplete + "&";

        queryStringComplete = queryStringComplete + paramArray[i];
        paramCount++;
      }

    }
  }

  window.location = self.location.protocol + '//' + self.location.host
      + self.location.pathname + queryStringComplete;
}

function toggle(id) {
  var item = document.getElementById(id);
  if (item.style.display === 'none') {
    item.style.display = 'block';
  } else {
    item.style.display = 'none';
  }
}

function getPositionOfNthOccurence(haystackString, needleString, n) {
  return haystackString.split(needleString, n).join(needleString).length;
}

function getStatistics(itemID, language, protocol) {
  var currentUrl = window.location.href;
  console.log("currentUrl: " + currentUrl);

  // assuming protocol, host, port, and context are the string before the 4th
  // occurrence of the slash character
  var protocolAndHostAndPortAndContext = currentUrl.substring(0,
      getPositionOfNthOccurence(currentUrl, "/", 4));
  var statisticsURL = protocolAndHostAndPortAndContext
      + "/api/items/" + itemID + "/statistics";
  console.log("statisticsURL: " + statisticsURL);
  
  var labels;
  switch (language) {
  case "de":
    labels = new Array('Seitenbesuche', 'Downloads', 'wird geladen ...',
        'Diesen Monat', 'Komplett');
    break;

  default:
    labels = new Array('Page views', 'Downloads', 'loading', 'this month',
        'total');
    break;
  }

  // insert statistic tags
  jQuery('#statistics').empty();
  jQuery('#statistics').append(
      '<h3 style="color:#360">' + labels[0] + '</h3><p id="pageViews">'
          + labels[2] + '</p><h3 style="color:#360">' + labels[1]
          + '</h3><p id="downloads">' + labels[2] + '</p>');

  $.getJSON(statisticsURL, function(data) {
    jQuery('#pageViews').empty();
    jQuery('#pageViews').append(
        labels[3] + '<b class="statistics">' + data.pageViewsThisMonth
            + '</b><br>' + labels[4] + '<b class="statistics">'
            + data.pageViewsAll + '</b><br>');

    jQuery('#downloads').empty();
    jQuery('#downloads').append(
        labels[3] + '<b class="statistics">' + data.downloadsThisMonth
            + '</b><br>' + labels[4] + '<b class="statistics">'
            + data.downloadsAll + '</b><br>');
  });
}

function getIdleTime() {
  var _minute, _sec, _nmin, _nsec;

  IDLE_TIME++;

  if ((_isec - IDLE_TIME) == -1) {
    _MIN++;
    IDLE_TIME = 0;
  }

  _minute = _imin - _MIN;
  _sec = _isec - IDLE_TIME;

  _nmin = (_minute.toString().length == 1) ? '0' + _minute : _minute;
  _nsec = (_sec.toString().length == 1) ? '0' + _sec : _sec;

  if (_minute >= 0 && _sec >= 0) {
    document.getElementById('SetIdleTime').innerHTML = _nmin + ':' + _nsec;
    if (_minute == 0 && _sec == 0) {
      // Now Redirect Page
      // After complete the time
      alert('Your session has timed out. Please sign in again.');
      document.location.href = 'http://www.ssoar.info/ssoar/password-login';
    }
  }
}

function checkedFunction() {

  if (document.getElementById("internal_check_openaire_column").children[0].children[1].children[0].checked) {
    document.getElementById("dc_relation_openaireprojectid").style.display = "block";
    // document.getElementById("dc_rights_openaireaccessrights").style.display
    // ="block";
    document
        .getElementById("aspect_submission_StepTransformer_field_dc_rights_openaireaccessrights").value = "Default Value";
  } else {
    document.getElementById("dc_relation_openaireprojectid").style.display = "none";
    document.getElementById("dc_rights_openaireaccessrights").style.display = "none";
  }
}

function getElementByXpath(path) {
  return document.evaluate(path, document, null,
      XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
}

function deactivateUploadButton() {
  if (document
      .getElementById("aspect_submission_StepTransformer_table_submit-upload-summary") != null) {
    // alert("Hochladen der mehrere Dokumente ist nicht m\366glich!");
    getElementByXpath(".//*[@id='file_column']/span").style = "color:red"
    getElementByXpath(".//*[@id='file_column']/span").innerHTML = "Das Hochladen von mehreren Dateien ist momentan nicht m\366glich!";
    document.getElementById("aspect_submission_StepTransformer_field_file")
        .setAttribute("disabled", "disabled");
  }
}

function extendOpenAireFieldsOnFormSubmission(event) {
  // create OpenAIRE embargo end date value
  var embargoDateInputElement = document
      .getElementById("aspect_submission_StepTransformer_field_internal_embargo_liftdate");
  var embargoDateString = embargoDateInputElement.value;
  if (embargoDateString) { // if embargoDateString is not empty
    document.getElementById("aspect_submission_StepTransformer_field_dc_date").value = "info:eu-repo/date/embargoEnd/"
        + embargoDateString;
    document
        .getElementById("aspect_submission_StepTransformer_field_dc_rights").value = "info:eu-repo/semantics/embargoedAccess";
  } else { // embargoDateString is empty
    document.getElementById("aspect_submission_StepTransformer_field_dc_date").value = null;
    document
        .getElementById("aspect_submission_StepTransformer_field_dc_rights").value = "info:eu-repo/semantics/openAccess";
  }

  // extend OpenAIRE grant agreement identifier with prefix
  var openAireGrantAgreementIdentifierInputElement = document
      .getElementById("aspect_submission_StepTransformer_field_dc_relation");
  var openAireGrantAgreementIdentifierString = openAireGrantAgreementIdentifierInputElement.value;
  if (openAireGrantAgreementIdentifierString) { // if is not empty
    openAireGrantAgreementIdentifierInputElement.value = "info:eu-repo/grantAgreement/EC/"
        + openAireGrantAgreementIdentifierString;
  }

  return true;
}

function iffIsOpenAireSubmissionShowOpenAireInputsAndAddFormSubmissionHandler() {
  var submitButton = $("#aspect_submission_StepTransformer_field_submit_next");

  var openAireCheckboxArray = $('input[name=internal_check_openaire]');
  var openAireCheckbox = openAireCheckboxArray.eq(0);
  var isOpenAireSubmission = openAireCheckbox.is(":checked") // true or false

  if (isOpenAireSubmission) {
    document.getElementById("dc_type").style.display = "block";
    document.getElementById("dc_relation").style.display = "block";

    console.log("binding openAIRE submission handler...");
    submitButton.click(extendOpenAireFieldsOnFormSubmission);
    // .submit(..) event handler adding somehow doesn't work. And .on("submit",
    // ..) event handler doesn't exist in the used jQuery library
  } else {
    document.getElementById("dc_type").style.display = "none"; // input for
                                                                // dc.type (for
                                                                // use to define
                                                                // Publication
                                                                // Type), e.g.
                                                                // bachelorThesis
    document.getElementById("dc_relation").style.display = "none"; // input for
                                                                    // dc.relation
                                                                    // (for use
                                                                    // to define
                                                                    // OpenAire
                                                                    // Project
                                                                    // identifier
                                                                    // / grant
                                                                    // agreement
                                                                    // identifier)
    document.getElementById("dc_rights").style.display = "none"; // input for
                                                                  // dc.rights
                                                                  // (for use to
                                                                  // define
                                                                  // OpenAIRE
                                                                  // Access
                                                                  // Level) is
                                                                  // always
                                                                  // hidden. Its
                                                                  // value is
                                                                  // automatically
                                                                  // derived
                                                                  // whether
                                                                  // internal.embargo.liftdate
                                                                  // is empty
                                                                  // (openAccess)
                                                                  // or notempty
                                                                  // (embargoedAccess)
                                                                  // on form
                                                                  // submission.
    document.getElementById("dc_date").style.display = "none"; // input for
                                                                // dc.date (for
                                                                // use to define
                                                                // OpenAIRE
                                                                // embargo end
                                                                // date) is
                                                                // always
                                                                // hidden. Its
                                                                // value is
                                                                // automatically
                                                                // derived from
                                                                // internal.embargo.liftdate
                                                                // on form
                                                                // submission.

    console.log("nulling OpenAIRE input data...");
    document.getElementById("aspect_submission_StepTransformer_field_dc_type").value = null;
    document
        .getElementById("aspect_submission_StepTransformer_field_dc_relation").value = null
    document
        .getElementById("aspect_submission_StepTransformer_field_dc_rights").value = null;
    document.getElementById("aspect_submission_StepTransformer_field_dc_date").value = null;

    console.log("unbinding openAIRE submission handler...");
    submitButton.unbind("click", extendOpenAireFieldsOnFormSubmission);
  }
}

function iffOpenAireFieldsExistAddOpenAireMagic() {
  var openAireCheckboxArray = $('input[name=internal_check_openaire]');
  if (openAireCheckboxArray.length >= 1) {
    // openaire checkbox exists, therefore assuming this document is OpenAIRE
    // input fields-aware.
    var openAireCheckbox = openAireCheckboxArray.eq(0);
    openAireCheckbox
        .change(iffIsOpenAireSubmissionShowOpenAireInputsAndAddFormSubmissionHandler)
    iffIsOpenAireSubmissionShowOpenAireInputsAndAddFormSubmissionHandler(); // trigger
                                                                            // once
  }
}
