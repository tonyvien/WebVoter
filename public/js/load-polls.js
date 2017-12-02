$(document).ready(function(){
	var polls = document.getElementById('polls');
	// If current HTML Document contains a div element with
	// and ID "polls", being retrieving polls
	(function(){
		if( polls !== null ){
			$.ajax({
				url: '/get-polls',
				type: 'GET',
				success: function(data){
					//console.log(JSON.parse(data));
					polls = JSON.parse(data);
					polls.forEach(function(poll, ndx){
						let pollsHtml = 
						`
					    <tr>
					      <th scope="row">${ndx+1}</th>
					      <td>${poll.user}</td>
					      <td>${poll.first}</td>
					      <td>${poll.second}</td>
					      <td>${poll.third}</td>
					    </tr>
						`; 
						$('#poll-list').append(pollsHtml);
					});
				}
			});
		}
	})();

	// Make an ajax request to update the csv file on the server and begin downloading
	$('#download-CSV-btn').click(()=>{
		$.ajax({
			url: '/download-polls',
			type: 'GET',
			success: function(data){
				window.location=data;
			}
		});
	});
});