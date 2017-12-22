// Called in the _index_default.html to populate the index partial with links of text searches
// If the matxhes are more than 3, it creates a button that triggers a modal with all the matches/links
function index_work_search(id, modal_selector, modal_body_selector,target_selector, text_label_id, q, match){
    id = encodeURIComponent(id);
    if (!q.trim()){
        $(text_label_id).hide();
    }else{
        $.ajax({
            type: 'GET',
            url: '/text.json?search_field=leaf&rows=200&sort=position_isi+asc&q='+q+'&workid='+id+'&match='+match,
            datatype: 'json',
            success: function(data) {
                $(target_selector).empty();
                docs = data.data;
                hl_field = (match == 'phrase')?'text_tsim':'text_tesim';
                matches_num = data.meta.pages.total_count;
                if (matches_num>0) {
                    $(target_selector).append('<div id="results-header"><p>'+matches_num+' match</p></div>');
                    for (var i= 0; i in docs && i<3; i++) {
                        $(target_selector).append('<p><a href="/text/' + id + '#' + docs[i].attributes.xmlid_ssi + '">' + docs[i].highlighting[docs[i].id][hl_field].join("...") + '</a></br>Side: ' + docs[i].attributes.page_ssi + '</p>');                        // }
                    }
                }if (matches_num>3){
                    var btn = document.createElement("BUTTON");
                    var t = document.createTextNode("Alle forekomster");
                    btn.appendChild(t);
                    btn.setAttribute("id","modal-button-"+id);
                    btn.setAttribute("class","all-matches");
                    $(target_selector).append(btn);
                    $("#modal-button-"+id).click(function(){
                        $(modal_selector).modal();
                    });
                    for (var i= 0; i in docs ; i++) {
                        $(modal_body_selector).append('<p><a href="/text/' + id + '#' + docs[i].attributes.xmlid_ssi + '">' + docs[i].highlighting[docs[i].id][hl_field].join("...") + '</a></br>Side: ' + docs[i].attributes.page_ssi + '</p>');                        // }
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

///////// Cookie popup in the home page
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
    var cookie_button = document.getElementById("cookie-button");
    if (cookie_button) {
        var cookie = getCookie("terms");
        if (cookie != "") {
        } else {
            cookie_button.style.display = "block";
            if (cookie != "" && cookie != null) {
                cookieTerms("terms", cookie, 60);
            }
        }
    }
}
$( document ).ready(function() {
    checkCookie();
});
/////////
function toggleHighlight() {
    var el = document.getElementsByClassName('hit');
    var len = el.length;
    for ( i=0; i<len; i++){
        el[i].classList.toggle('transparentBackground');
    }
}