$(document).ready(function(){
$.ajax({ url: "/programmes",
        context: document.body,
        success: function(response){
           var htmlR = response.reduceRight((acc, p) => acc + "<li><span>" + p.title[1] + "</span><p>" + p.desc[1] + "</p></li>", "<ul>");
           $("#programmes").html(htmlR + "</ul>");
        }});
});
