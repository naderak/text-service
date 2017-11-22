// Called in the _index_default.html to populate the index partial with links of text searches
// If the matxhes are more than 3, it creates a button that triggers a modal with all the matches/links
function index_work_search(id, target_selector, text_label_id){
    id = encodeURIComponent(id);
    qselector = $('#q.search_q.q.form-control');
    q = encodeURIComponent($(qselector).val());
    if (!q.trim()){
        $(text_label_id).hide();
    }else{
        $.ajax({
            type: 'GET',
            url: '/catalog.json?search_field=leaf&rows=200&sort=position_isi+asc&q='+q+'&workid='+id,
            datatype: 'json',
            success: function(data) {
                $(target_selector).empty();
                docs = data.response.docs;
                highlighting = data.response.highlighting;
                matches_num = data.response.pages.total_count;
                if (matches_num>0) {
                    $(target_selector).append('<div id="results-header"><p>'+matches_num+' match</p></div>');
                    for (var i= 0; i in docs && i<3; i++) {
                        if (highlighting[docs[i].id].text_tesim != null) {
                            $(target_selector).append('<p><a href="/solr_documents/' + id + '#' + docs[i].page_id_ssi + '">' + highlighting[docs[i].id].text_tesim.join("...") + '</a></br>Side: ' + docs[i].page_ssi + '</p>');                        // }
                        }
                    }
                }if (matches_num>3){
                    var btn = document.createElement("BUTTON");
                    var t = document.createTextNode("Alle forekomster");
                    btn.appendChild(t);
                    btn.setAttribute("id","matches-button-"+id);
                    btn.setAttribute("class","all-matches");
                    $(target_selector).append(btn);
                    $("#matches-button-"+id).click(function(){
                        $("#matches-"+id).modal();
                    });
                    for (var i= 0; i in docs ; i++) {
                        if (highlighting[docs[i].id].text_tesim != null) {
                            $("#matchesModalBody-"+id).append('<p><a href="/solr_documents/' + id + '#' + docs[i].page_id_ssi + '">' + highlighting[docs[i].id].text_tesim.join("...") + '</a></br>Side: ' + docs[i].page_ssi + '</p>');
                        }
                        }
                }if(matches_num==0){$(text_label_id).hide();} // If the number of matches is 0, hide the label
            }
        });
    }
    return false;
}

// Called in the app/views/catalog/_show_tools_work.erb to trigger a modal with all the matches for the search performed in the index
function show_work_search(id, target_selector, q){
    $('.contentSearch').hide();
    $.ajax({
        type: 'GET',
        url: '/catalog.json?search_field=leaf&rows=200&sort=position_isi+asc&q='+encodeURI(q)+'&workid='+id,
        datatype: 'json',
        success: function(data) {
            $(target_selector).empty();
            docs = data.response.docs;
            highlighting = data.response.highlighting;
            matches_num = data.response.pages.total_count;
                if(matches_num>0){
                    $('.contentSearch').show();
                    $(target_selector).append('<div id="results-header"><p>'+matches_num+' match</p></div>');
                    for (var i= 0; i in docs; i++) {
                        if (highlighting[docs[i].id].text_tesim != null) {
                            $(target_selector).append('<p><a onClick="$(\'#searchFullText\').modal(\'hide\')" href="/solr_documents/' + id + '#' + docs[i].page_id_ssi + '">' + highlighting[docs[i].id].text_tesim.join("...") + '</a></br>Side: ' + docs[i].page_ssi + '</p>');
                        }
                    }
                }
        }
    });
}


function cookieTerms(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
}

function checkCookie() {
    var cookie = getCookie("terms");
    if (cookie != "") {
//        ADL.console.log("cookie: "+ cookie);
//        document.getElementById("cookie-button").style.display="none";
    } else {
        document.getElementById("cookie-button").style.display="block";
        if (cookie != "" && cookie != null) {
            cookieTerms("terms", cookie, 60);
        }
    }
}
/////////
function toggleHighlight() {
    var el = document.getElementsByClassName('hit');
    var len = el.length;
    for ( i=0; i<len; i++){
        el[i].classList.toggle('transparentBackground');
    }
}