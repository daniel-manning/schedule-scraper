$(document).ready(function(){
$.ajax({ url: "/channels",
        context: document.body,
        success: function(response){
           var htmlR = response.reduceRight((acc, c) => acc + "<li><span>" + c.displayName + "</span><button id=\"" + c.channelID + "\" class=\"filter-button\">Filter Channel</button></li>", "<ul>");
           $("#channels").html(htmlR + "</ul>");
        }});
});


 $(document).on('click', '.filter-button', function(){ $.ajax({
    headers: {
     'Accept': 'application/json',
     'Content-Type': 'application/json'
    }, url: "/filterChannels/" + $(this).attr('id'),
    type: "POST",
    success: function( result ) {
    },
    error: function( result ) {
    }
    })});

