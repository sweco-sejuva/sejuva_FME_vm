
$(document).ready(function() {
	$.getJSON("server-demo-config.json", function (config) {
		dataDist.init(config.initObject);
	});
});



var dataDist = (function () {

  // privates
  var repository = 'FMETraining';
  var workspaceName = 'PythonVMCreator.fmw';
  var host ;
  var token ;

  /**
   * Run when the page loads. Callback from the FMEServer API. JSON returned from 
   * the REST API parsed and a HTML published parameter form dynamically created.
   * @param  {JSON} json Returned from the Rest API callback
   */
  function buildParams(json){

    var parameters = $('<div id="parameters" />');
    parameters.insertBefore('#submit');

    // Generates standard form elelemts from
    // the getWorkspaceParameters() return json object
    FMEServer.generateFormItems('parameters', json);

    // Add styling classes to all the select boxes
    var selects = parameters.children('select');
    for(var i = 0; i < selects.length; i++) {
        selects[i].setAttribute('class', 'input-customSize');
    }

    // Remove the auto generated GEOM element and label
    $("#parameters .GEOM").remove();

  }

  /**
   * Builds up the URL and query parameters.
   * @param  {Form} formInfo Published parameter form Object.
   * @return {String} The full URL.
   */
  function buildURL(formInfo){
    var str = '';
    str = host + '/fmejobsubmitter/' + repository + '/' + workspaceName + '?';
    var elem = formInfo[0];
    for(var i = 0; i < elem.length; i++) {
      if(elem[i].type !== 'submit') {

        if(elem[i].type === "checkbox" && elem[i].checked) {
          str += elem[i].name + "=" + elem[i].value + "&";
        } else if(elem[i].type !== "checkbox") {
          str += elem[i].name + "=" + elem[i].value + "&";
        }
      }
    }
    str = str.substring(0, str.length - 1);
    return str;
  }


  /**
   * Run on Submit click. Callback for the FMESERVER API.
   * from the translation which is displayed in a panel.
   * @param  {JSON} result JSON returned by the data download service call.
   */
  function displayResult(result){
    var resultText = result.status;
    var resultUrl = '';
    var resultDiv = $('<div />');

    if(resultText == 'success'){
      //resultUrl = result.serviceResponse.url;
      //resultDiv.append($('<h2>' + resultText.toUpperCase() + '</h2>'));
      resultDiv.append($('<h1>' + 'Email Sent!' + '</h1>'));
	  resultDiv.append($('<h2>' + 'If you do not receive an email within 5 minute, please double-check the email address above, and check your spam filter' + '</h2>'));
     }
    else{
      resultDiv.append($('<h1>' + 'There was an error processing your request <br> Check the information entered above, and email train@safe.com' + '</h1>'));
      resultDiv.append($('<h2>' + result.object + '</h2>'));
    }

    $('#results').html(resultDiv);
  }


  /**
   * ----------PUBLIC METHODS----------
   */
  return {

    init : function(params) {
      var self = this;
      host = params.server;
      token = params.token;
      hostVisible = params.hostVisible;

      //initialize map and drawing tools
      //will eventually be different for each web map type
      var query = document.location.search;
      var mapService = query.split('=');
      
      FMEServer.init({
        server : host,
        token : token
      });

      //set up parameters on page
      FMEServer.getWorkspaceParameters(repository, workspaceName, buildParams);

      $('#geom').change(function(){
        dataDist.updateQuery();
      });
    },

    /**
     * Called by the form when the user clicks on submit.
     * @param  {Form} formInfo Published parameter form Object.
     * @return {Boolean} Returning false prevents a new page loading.
     */
    orderData : function(formInfo){
			// Create the the publishedParameters array, and a checkboxes object
			var params = { "publishedParameters" : [] };
			var publishedParameters = params.publishedParameters;
			var checkboxes = {};

			// Loop through the form elements and build the publishedParameters array
			for( var i = 0; i < form.elements.length; i++ ){
				var element = form.elements[i];
				var obj = { "name" : "", "value" : null }
				obj.name = element.name;
				if( element.type == "select" ) {
					obj.value = element[element.selectedIndex].value;
					publishedParameters.push( obj );
				} else if( element.type == "checkbox" ){
					if( element.checked ) {
						if( !checkboxes[element.name] ){
							checkboxes[element.name] = [];
						}
						checkboxes[element.name].push( element.value );
					}
				} else if( element.type != "hidden" && element.type != "button" ) {
					obj.value = element.value;
					publishedParameters.push( obj );
				}
			}

			// Add all grouped checkbox elements to the published parameters
			for( name in checkboxes ) {
				publishedParameters.push( { "name" : name, "value" : checkboxes[name] } );
			}

			// Submit Job to FME Server and run synchronously
			FMEServer.submitSyncJob( repository, workspace, params, displayResult );
		}
	 

    /**
     * Updates the URL text, called when a form item changes.
     */
    updateQuery : function(){
      var queryStr = buildURL($('#fmeForm'));
      $('#query-panel-results').text(queryStr);
    }
  };
}());
