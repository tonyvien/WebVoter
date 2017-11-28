//Invoke loadSites() to retrieve websites
loadSites();

/*************************************************************************/
/*************************************************************************/
/******************************* FUNCTIONS *******************************/
/*************************************************************************/
/*************************************************************************/


// This function simply trims the site/team/student (The folder) name
// from the "src" path. 
function trimSiteName(sname){
	for(let i = 3; i < sname.length; i++){
  	if(sname[i] === '/'){
    	return sname.slice(3, i);
    }
  }
}


// This function retrieves all of the websites via an ajax POST request
// and grabs any existing websites on the server. If there are no websites
// then display a warning message to upload a zip file.
function loadSites(){
	let $sites = $('#sites');
	$.ajax({
		type: 'POST',
		url: '/get-sites',
        beforeSend: function() {
          $('#invalid-ws-msg').hide();
          $('#loading-box').fadeIn(250);
        },
        complete: function() {
          $('#loading-box').fadeOut(250);
        },
		success: function(data){
			if(data!=="[]"){
				// Convert data string as an array
				let ws_arr = data.replace(/[\]\[,"]/g, '').split(' ');
				// Append an iframe to the #sites div
				ws_arr.forEach((src)=>{

					// Trim src to hold the folder name (or student/team name)
					ws_name = trimSiteName(src);

					$sites.append('<iframe class="ws" src="' + src + '"></iframe>');
					// append a vote box for each website
					// TODO: Slice "src" value to just the foldername...
					let voteBox = 
					`
					<div class="btn-group btn-group-lg voteBox" role="group" aria-label="Basic example">
					  <button data-src="${ws_name}" type="button" class="btn btn-secondary first">1st</button>
					  <button data-src="${ws_name}" type="button" class="btn btn-secondary second">2nd</button>
					  <button data-src="${ws_name}" type="button" class="btn btn-secondary third">3rd</button>
					</div>
					`;
					$sites.append(voteBox);
				});

				/*******************************************************/
				/****************** Add Message Boxes ******************/
				/*******************************************************/

				// Add a success box here:
				let successBox = 
				`
					<div id="success-box" class="alert alert-success text-center" role="alert">
	  					Your vote was successfully submitted!
					</div>
				`;

				// Add an error box here:
				let errBox = 
				`
					<div id="error-box" class="alert alert-danger text-center" role="alert">
	  					Please vote for your 1st, 2nd, and 3rd favorite website.
					</div>
				`;

				// Add an "voted already" box here:
				let votedBox = 
				`
					<div id="voted-box" class="alert alert-primary text-center" role="alert">
	  					Hmmm... Looks like you voted already. Users are only allowed to vote once.
					</div>
				`;

				// Load in submission button box at the bottom of the page
				let voteBtn = 
				`
					<button id="voteBtn" type="button" class="btn btn-primary btn-lg">Submit Vote</button>
				`;

				//Append all message boxes (Initially hidden from css)
				$sites.append(successBox)
				$sites.append(errBox)
				$sites.append(votedBox)
				// Lastly, append vote/submit button
				$sites.append(voteBtn)

				// Finally, fade in $sites
				$sites.delay(500).fadeIn(1000);

			} else {
          		$('#invalid-ws-msg').slideDown(500);
			}
		}
	});
}


/*************************************************************************/
/*************************************************************************/
/**************************** EVENT LISTENERS ****************************/
/*************************************************************************/
/*************************************************************************/

// This event listener waits for a .voteBox button click.
// When a user makes a selection, clear button siblings (Prevent users
// from voting more than once for one website) and any other previously 
// selected choices (Prevents users from voting 1st multiple times).
$(document).on('click', '.voteBox .btn', function(){
	// This "if" block unselects the all other .first/.second/.third clicks
	// and place the vote choice (src) in a form for processing.
	if($(this).hasClass('first')){
		// Clear the other selected ".first" button clicks...proceed
		$('.voteBox .btn.first.btn-success').removeClass('btn-success').addClass('btn-secondary');
	} else if($(this).hasClass('second')){
		// clear the other selected ".second" button clicks...proceed
		$('.voteBox .btn.second.btn-success').removeClass('btn-success').addClass('btn-secondary');
	} else {
		// clear the other selected ".third" button clicks...proceed
		$('.voteBox .btn.third.btn-success').removeClass('btn-success').addClass('btn-secondary');
	}

	// Unselect this btn's siblings. (Prevents users from voting 1st, 2nd, and 3rd for one website)
	$(this).siblings().removeClass('btn-success').addClass('btn-secondary');

	// Finally, mark this selected button as selected
	$(this).removeClass('btn-secondary').addClass('btn-success');
});



// This event listener waits for the user to submit their 3 vote choices.
// If their 1st, 2nd, and 3rd choices are empty, display the error box.
// Else, make an ajax POST request to the server and send the three
// choices to be processed.
$(document).on('click', '#voteBtn', function(){
	// Get the 1st, 2nd, 3rd votes
	let first  = $('.voteBox .btn.first.btn-success').data('src'),
		second = $('.voteBox .btn.second.btn-success').data('src'),
		third  = $('.voteBox .btn.third.btn-success').data('src');

	// Hide all message boxes
	$('#error-box').hide();

	if(first && second && third){
		$.ajax({
			url: '/vote',
			type: 'POST',
			data: JSON.stringify({"first": first, "second": second, "third": third}),
			success: function(data){
				if(data === "true"){
					$('#success-box').slideDown(500).delay(2000).slideUp(500);
				} else {
					$('#voted-box').slideDown(500).delay(2000).slideUp(500);
				}
			}
		});
	} else {
		$('#error-box').slideDown(500);
	}
});