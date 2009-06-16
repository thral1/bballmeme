/*<script>*/
/*
AJAXed Wordpress
(C) Anthologyoi.com
*/

var aWP = function (){

		var _d=[]; /*_d is an object with an index of i that holds currently active "request" element information*/
		var _p=[]; /*_p is an object with an index of i that holds information that must exist between requests.*/
		var _a=[]; /*_a is an object that can be used throughout this function.*/
		var i; /*Currently processing element id*/
		var mrc = '';
		var force = 0;
		var com_hide = '';
		
	var $ = function(id) {
		return document.getElementById(id);
	};

	var pos = function(ele) {
		var e = $(ele);
		var etop = 0;
			if(e && e.style.display != 'none'){
				if (e.offsetParent) {
					etop = e.offsetTop
					while (e = e.offsetParent) {
						etop += e.offsetTop
					}
				}
			}
		return etop;

	};

	var get_current_scroll = function(){
		var cur_scroll = 0;

		if(document.body && document.body.scrollTop){

			cur_scroll = document.body.scrollTop;

		}else if(document.documentElement && document.documentElement.scrollTop){

			cur_scroll = document.documentElement.scrollTop;
		}

		return cur_scroll;
	};

	var get_form_data = function(i){
		var base = $(i).getElementsByTagName('input');
		var postobj = {};
		var x = base.length;
		var value = '';
		var name = '';
		var radios=[];

		for(y=0; y<x; y++){
			if(base[y].type != 'button'){
				if(base[y].type == 'text' || base[y].type == 'hidden' || base[y].type == 'password' || base[y].type == 'select'){
						value =  base[y].value;
						name = base[y].name;
				}else if(base[y].type == 'checkbox' || base[y].type == 'radio'){
					if (base[y].checked) {
						value =  base[y].value;
						name = base[y].name;
					}
				}
				if(name && value){
					postobj[name] = value;
				}
				name = value= null;
			}
		}

		base = $(i).getElementsByTagName('textarea');
		x = base.length;

		for(y=0; y<x; y++){
			postobj[base[y].name]= base[y].value;
		}
		return postobj;
	};

	var get_throbber = function (){

			var img = document.createElement('img');
			img.src="http://clipperblog.com/wp-content/plugins/ajaxd-wordpress/images/throbber.gif";
			img.alt="Please hold now loading";
			img.id = "throbber"+i;
			img.className = "throbber";
			document.body.style.cursor='wait'
			if(_d[i].submit == 'TRUE'){

				try{$(_d[i].type+'_'+_d[i].main).parentNode.appendChild(img);}catch(e){}

			}else if(_d[i].this_page && _d[i].pagenum){

				try{$('awppage_'+_d[i].this_page+'_'+_d[i].main+'_link').appendChild(img);}catch(e){}

			}else if(_d[i].link_num){

				try{$('awp'+_d[i].type+'_link'+_d[i].link_num+'_'+_d[i].main).appendChild(img);}catch(e){}

			}else if(arguments[0] && $(arguments[0]) && arguments[1]){
				img.className =arguments[1];
				
				img.src="http://clipperblog.com/wp-content/plugins/ajaxd-wordpress/images/throbber"+arguments[2]+".gif";
				try{$(arguments[0]).parentNode.insertBefore(img, $(arguments[0]));}catch(e){}
			}else{

				try{$('awp'+_d[i].type+'_link_'+_d[i].main).appendChild(img);}catch(e){}

			}
	};

	var do_JS = function(e){
		var Reg = '(?:<script.*?>)((\n|.)*?)(?:</script>)';
		var match    = new RegExp(Reg, 'img');
		var scripts  = e.innerHTML.match(match);
		var doc = document.write;
		document.write = function(p){ e.innerHTML = e.innerHTML.replace(scripts[s],p)};
		if(scripts) {
			for(var s = 0; s < scripts.length; s++) {
				var js = '';
				var match = new RegExp(Reg, 'im');
				js = scripts[s].match(match)[1];
				js = js.replace('<!--','');
				js = js.replace('-->','');
				eval('try{'+js+'}catch(e){}');
			}
		}
		document.write = doc;
	};

	var link_text = function(id,newtext,toggle_text,style,style_toggle){

		if($(id)){
			var l = $(id);
			if(toggle_text){
				if(l.firstChild.data == toggle_text){
					l.firstChild.data = newtext;
					if(style) {l.className = style;}
				}else{
					l.firstChild.data = toggle_text;
					if(style_toggle) {l.className = style_toggle;}
				}
			}else{
				l.firstChild.data = newtext;
					if(style) {l.className = style;}
			}
		}
	};


	var move = function(id,moveto,mode){
		if($(id) && $(moveto) ){
			if(mode == 'sib'){
				$(id).parentNode.insertBefore($(moveto), $(id).nextSibling);
			}else{
				$(id).parentNode.insertBefore($(moveto),$(id));
			}
		}
	};
	return{

		init: function(){
			var preload_throbber = document.createElement('img');
			preload_throbber.src="http://clipperblog.com/wp-content/plugins/ajaxd-wordpress/images/throbber.gif";
			preload_throbber.src="http://clipperblog.com/wp-content/plugins/ajaxd-wordpress/images/throbberlarge.gif";

		},

		addEvent: function(evn,fn,base){

			if (base.addEventListener){
				base.addEventListener(evn, fn, false);
				return true;
			} else if (base.attachEvent){
				var r = base.attachEvent("on"+evn, fn);
				return r;
			} else {
				return false;
			}
		},


		doit : function() {
			aWP.start.main(arguments);

		},

		update: function (){
			var e = $(i);
			_d[i].response = '';

			var nodes = _d[i].result.getElementsByTagName("var");
			if(nodes.length > 0){
				for (j=0; j<nodes.length; j++) {
					if(nodes.item(j).getAttribute('name') && nodes.item(j).firstChild.data){
						_d[i][nodes.item(j).getAttribute('name')] = nodes.item(j).firstChild.data;
					}
				}
			}

			nodes = _d[i].result.getElementsByTagName("response");
			if(nodes.length > 0){
				for (j=0; j<nodes.length; j++) {
					if(nodes.item(j).getAttribute('name')){
						_d[i][nodes.item(j).getAttribute('name')] = nodes.item(j).firstChild.data;
					}else{
						_d[i].response += nodes.item(j).firstChild.data
					}
				}
			}

			nodes = _d[i].result.getElementsByTagName("action");
			if(nodes.length > 0){
				for (j=0; j<nodes.length; j++) {
					if(nodes.item(j).firstChild.data){
						if(nodes.item(j).getAttribute('name')){
							_d[i][nodes.item(j).getAttribute('name')] = nodes.item(j).firstChild.data;
						}else{
							eval(nodes.item(j).firstChild.data);
						}
					}
				}
			}

			if(!_d[i].update_next){
				e.innerHTML = _d[i].response;
				do_JS(e);
				aWP.toggle.main();
			}else{
				eval(_d[i].update_next+'();');
			}
		},

		start: {

			main: function(){

				var args = arguments[0];
				var temp = args[0];
				var postobj = {};

				if(!temp.i){

					if((!temp.id && !temp.primary) || !temp.type){
						return false;
					}else{
						if(!temp.primary){
							temp.primary = 'id';
						}
					}

					i = 'awp'+temp.type+'_'+temp[temp.primary];

				}else{

					i = temp.i;
					temp.i = null;

				}

				if(!$(i)){
					if(_d[i].ths && _d[i].ths.href)
						window.location(_d[i].ths.href);
					return false;
				}else{
					e = $(i);
				}

				if(!_p[i]){
					_p[i] = [];
				}

				_d[i] = [];
				_d[i] = temp;
				_d[i].main = _d[i][_d[i].primary];
				temp = null;

				if(_d[i].submit == 'TRUE'){
					if($(_d[i].type+_d[i].main)){
						try{$(_d[i].type+_d[i].main).disabled = true;} catch(e){}
					}
					postobj = get_form_data(i);
					_d[i].force = 1;
					postobj['id'] = _d[i].id;
				}else{
					postobj['id'] = _d[i].id;
					postobj.main = _d[i].main;
				}

				postobj['type'] =_d[i].type;

				if(aWP.start[_d[i].type])
					postobj = aWP.start[_d[i].type](postobj);

				if(!postobj)
					return false;

				var n=0;

				if(e.innerHTML)
					n = e.innerHTML.length;

				if (n==0 || _d[i].force == 1){

					
				get_throbber();
				if(!_d[i].jQuery){
					aWP.jQuery = function(r){_d[i].result = r;  if(_d[i].result) {aWP.update();}}
				}
				jQuery.ajax({
				type: 'POST',
				url: 'http://clipperblog.com/wp-content/plugins/ajaxd-wordpress/aWP-response.php',
				data:  postobj,
				success:aWP.jQuery,
				async:false
				});

			
				}else{

					return aWP.toggle.main();

				}


			},

			
			commentform: function(postobj){

				if(isNaN(_p[i].prev_link)){
					_p[i].prev_link = 1;
					_d[i].faked = 1;
				}

				if(isNaN(_d[i].com_parent)){
					_d[i].com_parent = 0;
				}

			return postobj;
			},

			comments: function(postobj){

				if(_d[i].show){
					_p[i].show = _d[i].show;
				}

				if(_d[i].hide){
					_p[i].hide = _d[i].hide;
				}

				return postobj;
			},
			post: function(postobj){

				if (_p[i].prev_page == 0 || isNaN(_p[i].prev_page)){ /*The post has never been loaded.*/

					/*If a pagenum isn't passed then there are only two pages.*/
					_d[i].this_page = (isNaN(_d[i].pagenum)) ? 2 : _d[i].pagenum;

					_p[i].prev_page = _d[i].fp;

					_d[i].force = 1;

					postobj['first_page'] = _d[i].fp;

				}else{/*post has been loaded so we are toggling.*/

					if(isNaN(_d[i].pagenum)){
						_d[i].this_page  = (_p[i].prev_page == 2) ? 1 : 2;
					}else{
						_d[i].this_page  = _d[i].pagenum;
					}
				}

				return postobj;
			},
		previewcomment: function(postobj){

				if($('comment_'+_d[i].id)){
					postobj['comment'] = $('comment_'+_d[i].id).value;
				}else{
					base = document.getElementById('awpsubmit_commentform_'+id).getElementsByTagName('textarea');
					x = base.length;
					for(j=0; j<x; j++){
						if(base[j].name = 'comment'){
							postobj['comment'] = base[j].value;
							j = x;
						}
					}
				}
			return postobj;
			},
				dummy: function(){}
		},

		toggle: {
			main: function (){
				var e = $(i);
				var style = $(i).style.display; /*Otherwise we need to get it several times.*/
				if(style != 'none' && style != 'block'){ /*If the element is displayed, but not explicitly set.*/
					$(i).style.display = 'block'; /*Explicitly set it.*/
				}
				var winHeight = window.innerHeight;
				if(!winHeight){
					//yet another IE fix
					winHeight = document.documentElement.clientHeight;
				}

				if(document.getElementById('throbber'+i)){
					setTimeout("try{document.body.style.cursor='auto';}catch(e){}",500);
					setTimeout("try{document.getElementById('throbber"+i+"').parentNode.removeChild(document.getElementById('throbber"+i+"'));}catch(e){}",500);
					setTimeout("try{document.getElementById('throbber"+i+"').parentNode.removeChild(document.getElementById('throbber"+i+"'));}catch(e){}",500);
				}

				if(aWP.toggle[_d[i].type]){
					aWP.toggle[_d[i].type](e,style);
				}else{
					var toggle = 0;
					if(!_d[i].force){

							link_text('awp'+_d[i].type+'_link'+'_'+_d[i].main, _p[i].show, _p[i].hide,'awp' + _d[i].type + '_link','awp' + _d[i].type + '_link_hide');

						toggle = 1;
					}

					if( $(i).style.display != 'block' || toggle){
						aWP.toggle.pick_switch();
					}

				}

				if(_d[i].focus){
					setTimeout("aWP.toggle.smooth_scroll('"+_d[i].focus+"',0);",100);
				}else if(pos(i) > 0 && !_d[i].force && !_d[i].no_jump){
					aWP.toggle.smooth_scroll(i,-1*(winHeight/4));
				}

			},

			commentform: function(){
				var comparent;
				var moveto;
				var sib;
				var style = arguments[1];
						try{ comparent = $('comment_parent_'+_d[i].main).value
					$('comment_parent_'+_d[i].main).value = _d[i].com_parent;}catch(e){}

	
					if(!_p[i].nomove && style != 'none' && !_d[i].nomove){
						if(!$('awpcommentform_anchor_'+_d[i].main)){
							var div = document.createElement('div');
							div.id = 'awpcommentform_anchor_'+_d[i].main;
							div.style.display = 'none';
							try{$('awpcommentform_'+_d[i].main).parentNode.insertBefore(div, $('awpcommentform_'+_d[i].main).nextSibling);}catch(e){}
						}
					}else{
						if(_d[i].nomove)
							_p[i].nomove = 1;
					}

				if(_p[i].prev_link != _d[i].link_num || _d[i].faked ){
					var will_move = 1;
					 moveto = 'awpcommentform_link'+_d[i].link_num+'_'+_d[i].main;
					 sib = 'sib'
				}
				if((style == 'none' || _d[i].quickclose == 1 || _p[i].nomove) && !will_move){
					var will_hide = 1;
				}
				if(_p[i].prev_link == _d[i].link_num && !_p[i].nomove && !will_move){
					var will_remove = 1;
				}

				link_text('awpcommentform_link'+_d[i].link_num+'_'+_d[i].main,_d[i].show,_d[i].hide);

				if(will_remove){
					_d[i].no_jump = 1;
					_d[i].link_num =0;
					will_move = 1
					moveto = 'awpcommentform_anchor_'+_d[i].main
					sib = '';

						try{$('comment_parent_'+_d[i].main).value = 0;}catch(e){}
	
				}

				if(will_move == 1){
					var pos1 = pos(i);

						if(_a['beforemove'])
							_a['beforemove']();

						move(moveto,i,sib);

						if(_a['aftermove'])
							_a['aftermove']();

				

					var pos2 = pos(i);

					if(pos1 == pos2)
						will_hide = 1;
				}

				if(_p[i].last_show && (pos1 != pos2  || _d[i].quickclose == 1)){
					link_text('awpcommentform_link'+_p[i].prev_link+'_'+_d[i].main,_p[i].last_show);
				}

				if(will_hide == 1){
					aWP.toggle.pick_switch();
					_d[i].no_jump = 1;
				}



				try{$('submit_commentform_'+_d[i].main).disabled = false;} catch(e){}

				_p[i].last_show = _d[i].show;
				_p[i].prev_link = _d[i].link_num;
			},
	//<script>
			post: function(){
				var hideChildren;

				if(_d[i].hideChildren){
					hideChildren = 'awppost_'+_d[i].main;
				}



				AOI_eff.start('awppage_'+_p[i].prev_page+'_'+_d[i].main, {'mode': 'hide', 'eff': 'Fade', 'queue': ['show::'+'awppage_'+_d[i].this_page+'_'+_d[i].main], 'background': '#FFFFFF', 'hideChildren': hideChildren} );

					if(_d[i].pagenum){
						/*** Add class switching.  ***/
						$('awppage_'+_d[i].this_page+'_'+_d[i].main+'_link').style.fontWeight = 'bold';

						if(_p[i].prev_page !=_d[i].this_page ){
								$('awppage_'+_p[i].prev_page+'_'+_d[i].main+'_link').style.fontWeight = 'normal';
						}

					}else{
						if(!_d[i].noChange)
							link_text('awppost_link'+'_'+_d[i].main,_p[i].show,_p[i].hide,'awppost_link','awppost_link_hide');
					}
					_p[i].prev_page = _d[i].this_page;
			},
//<script>
			previewcomment: function(){
				$(i).style.height = $('awpsubmit_commentform_'+_d[i].id).offsetHeight+'px';
				$(i).style.top = pos('awpsubmit_commentform_'+_d[i].id)+'px';
				$(i).style.width = $('awpsubmit_commentform_'+_d[i].id).offsetWidth+'px';
				$(i).style.display = 'none';
				$(i).style.overflow = 'auto';
				aWP.toggle.pick_switch();
				$(i).style.position = 'absolute';

			},
	
			pick_switch:function(){

				
				AOI_eff.start(i, {'eff': 'SlideUp'});


	
			},

			smooth_scroll: function(scrolluntil,extra){
				var end = pos(scrolluntil) + extra;
				var cur_scroll = get_current_scroll();
				var step = 50;
				var scrollto = 0;
				var val = cur_scroll - end;

				if(Math.abs(val) > 50 && _p[i].scrollval != val){
					if(Math.abs(val) > 5000){step = 750;} else
					if(Math.abs(val) > 2500){step = 500;} else
					if(Math.abs(val) > 1000){step = 200;} else
					{ step = 50; }
					if (val > 0){
						scrollto =  cur_scroll - step;
					}else if (val < 0){
						scrollto =  cur_scroll + step;
					}
					_p[i].scrollval = val;
					try{window.parent.scrollTo(0,scrollto);}catch(e){}
					setTimeout("aWP.toggle.smooth_scroll('"+scrolluntil+"',"+extra+")",100);
				}

			}
		},

		
		complete: function (){

			aWP.finish.main(_d[i].type);

		},

		finish: {
			main: function(){

				try{$('throbber'+i).parentNode.removeChild($('throbber'+i));}catch(e){}

				if(aWP.finish[_d[i].type])
					aWP.finish[_d[i].type]();

			},

 //<script>
			submit_commentform : function(){

				$('comment_result_'+_d[i].main).innerHTML = _d[i].response;

				if(!_d[i].error){
					if(_d[i].show){
						var num = 1;
						if(_p[i].prev_link){
							num = _p[i].prev_link;
						}

						link_text('awpcommentform_link'+num+'_'+_d[i]['id'],_d[i].show)
					}
					/*If the comment form is inside of the comment div, reloading will destroy it, so we move it.*/
					var moveto;

					if($('awpcommentform_anchor_'+_d[i].main)){
						moveto = 'awpcommentform_anchor_'+_d[i].main;
					}else{
						moveto ='awpcomments_'+_d[i].main;
						$('awpcommentform_'+_d[i].main).style.display='none';
					}

					if(moveto){
						if(_a['beforemove'])
							_a['beforemove']();
						try{move( moveto,'awpcommentform_'+_d[i].main);}catch(e){}
						if(_a['aftermove'])
							_a['aftermove']();
					}

					try{$('comment_parent_'+_d[i].main).value = 0;}catch(e){}
					try{$('comment_'+_d[i][_d[i].primary]).value = '';}catch(e){}
					try{$(_d[i].type+'_'+_d[i][_d[i].primary]).disabled = false;} catch(e){}

					if($('awpcomments_none_'+_d[i].main)){
							if($('awpcomments_none_'+_d[i].main).style.display != 'none'){
								$('awpcomments_none_'+_d[i].main).style.display = 'none';
								$('awpcomments_link_'+_d[i].main).style.display = 'inline';
							}
					}

					var temp = 0
					if($('awpcomments_'+_d[i].id).innerHTML.length > 0){
						temp = 1;
					}

					try{
						if(_p['awpcomments_'+_d[i].id] && _p['awpcomments_'+_d[i].id].hide){
							link_text('awpcomments_link_'+_d[i].id, _p['awpcomments_'+_d[i].id].hide);
						}
					}catch(e){}
						aWP.doit({'id': _d[i].id, 'type': 'comments', 'force': temp, 'focus': 'comment-'+_d[i].mrc});
				}
			},

			dummy: function(){}
		}
	}
}();

aWP.init();



/* start live preview */
// <script>(to trick editors into using javascript syntax)

var aWP_livepreview = function(){
//Private Methods and Attributes are only accessible internally.
				var smilies = [':mrgreen:', ':neutral:', ':twisted:', ':arrow:', ':shock:', ':smile:', ':???:', ':cool:', ':evil:', ':grin:', ':idea:', ':oops:', ':razz:', ':roll:', ':wink:', ':cry:', ':eek:', ':lol:', ':mad:', ':sad:', '8-/?)', '8-/?O', ':-/?(', ':-/?)', ':-/??', ':-/?D', ':-/?P', ':-/?o', ':-/?x', ':-/?|', ';-/?)', ':!:', ':?:'];

			var smiliesfiles = ['mrgreen', 'neutral', 'twisted', 'arrow', 'eek', 'smile', 'confused', 'cool', 'evil', 'biggrin', 'idea', 'redface', 'razz', 'rolleyes', 'wink', 'cry', 'surprised', 'lol', 'mad', 'sad', 'cool', 'eek', 'sad', 'smile', 'confused', 'biggrin', 'razz', 'surprised', 'mad', 'neutral', 'wink', 'exclaim', 'question'];

			var smiliesalt = [':mrgreen:', ':neutral:', ':twisted:', ':arrow:', ':shock:', ':smile:', ':???:', ':cool:', ':evil:', ':grin:', ':idea:', ':oops:', ':razz:', ':roll:', ':wink:', ':cry:', ':eek:', ':lol:', ':mad:', ':sad:', '8-)', '8-O', ':-(', ':-)', ':-?', ':-D', ':-P', ':-o', ':-x', ':-|', ';-)', ':!:', ':?:'];

	
		var smiliescount = 0;
		var x = smiliescount = smilies.length;
		var smil_reg = [];

		while(x--){
				smilies[x] = smilies[x].replace(/([\\\^\$*+[\]?{}.=!:(|)])/g,"\\$1");
				smilies[x] = smilies[x].replace(/(\/\\?)/g,"?");
				smil_reg[x] = new RegExp('(>|\\s|^)'+smilies[x]+'(\\s|$|<)', "gm");
		}
			/* private attributes */

		var characters = new Array('---', ' -- ', '--', 'xn&#8211;', '\\.\\.\\.', '\\s\\(tm\\)','(\\d+)"',"(\\d+)'","(\\w)('{2}|\")",'(`{2}|")(\\w)',"(\\w)'","'([\\s.]|\\w)");
		var replacements = new Array('&#8212;', ' &#8212; ', '&#8211;', 'xn--', '&#8230;',' &#8482;','$1&#8243;', '$1&#8242;','$1&#8221;','&#8220;$2','$1&#8216;','&#8217;$1');
		var char_regex = [];
		var charcount =characters.length;
		for(x=0; x< charcount; x++){
			char_regex[x] = new RegExp(characters[x], "g")
		}
		var delay = 0;

		var element = [];

		var _cleanhtml = function(text){
					return text;
		};

/* private Methods */

	/*
	// Direct translation of wptexturize from php to javascript
	// Cleaned and optimized for speed and actual usage.*/
		var _js_wptexturize =  function(text) {
			var next = true;
			var output = '';
			var curl = '';
				text = text.replace(/(<[^>]*>)/g, '@%@%@$1@%@%@');
				var textarr = text.split('@%@%@');
				var stop = textarr.length;
				var i = 0;
			while (stop > i) {
				curl = textarr[i];
					if (curl.charAt(0) != '<' && next) { // If it's not a tag

						var x = charcount;
						while(x--){
							if(curl.match(char_regex[x])){
								curl = curl.replace(char_regex[x],replacements[x]);
							}
						}
					} else if ( curl.indexOf('<code') == 0 || curl.indexOf('<pre') == 0) {
						next = false;
					} else {
						next = true;
					}
				curl = curl.replace('/&([^#])(?![a-zA-Z1-4]{1,8};)/g', '&#038;$1');
				output += curl;
				i++;
			}
		return output;

		};

	
		var _js_wpautop = function (pee) {

			pee = pee + "\n\n";
			pee = pee.replace(/<br \/>\s*<br \/>/gi, "\n\n");
			pee = pee.replace(/(<(?:dl|dd|dt|ul|ol|li|pre|blockquote|p|h[1-6])[^>]*>)/gi, "\n$1");
			pee = pee.replace(/(<\/(?:dl|dd|dt|ul|ol|li|pre|blockquote|p|h[1-6])>)/gi, "$1\n\n");
			pee = pee.replace(/\r\n|\r/g, "\n");
			pee = pee.replace(/\n\s*\n+/g, "\n\n");
			pee = pee.replace(/([\s\S]+?)\n\n/gm, '<p>$1 </p>\n');
			pee = pee.replace(/<p>\s*?<\/p>/gi, '');
			pee = pee.replace(/(<p>)*\s*(<\/?(?:dl|dd|dt|ul|ol|li|pre|blockquote|p|h[1-6]|hr)[^>]*>)\s*(<\/p>)*/gi, "$2");
			pee = pee.replace(/<p>(<li.+?)<\/p>/i, "$1");
			pee = pee.replace(/<p><blockquote([^>]*)>/gi, "<blockquote$1><p>");
			pee = pee.replace(/<\/blockquote><\/p>/gi, '</p></blockquote>');
			pee = pee.replace(/\s*\n/gi, " <br />\n");
			pee = pee.replace(/(<\/?(?:dl|dd|dt|ul|ol|li|pre|blockquote|p|h[1-6])[^>]*>)\s*<br \/>/gi, "$1");
			pee = pee.replace(/'<br \/>(\s*<\/?(?:p|li|div|dl|dd|dt|th|pre|td|ul|ol)>)/gi, '$1');
			pee = pee.replace(/^((?:&nbsp;)*)\s/gm, '$1&nbsp;');

			return pee;
		};

		var _update = function (id,suf){
			var comment = '';
				if(!element[id]){
					if(suf){

						element[id] = document.getElementById('comment'+suf)
					}else{
						base = document.getElementById('awpsubmit_commentform_'+id).getElementsByTagName('textarea');
						x = base.length;
						for(i=0; i<x; i++){
							if(base[i].id = 'comment'){
								element[id] = base[i];
								i = x;
							}
						}
					}
				}

				comment = element[id].value
				if(comment != ''){
					comment = _js_wpautop(comment);
					comment = _js_wptexturize(comment);
					comment = _cleanhtml(comment);

							 comment = _convertsmilies(comment);
	
      					document.getElementById('add_comment_live_preview_'+id).innerHTML = comment;
				}

		};

			var _convertsmilies = function(text){
			var x = smiliescount;
				while(x--){
					if(text.match(smil_reg[x])){
						text = text.replace(smil_reg[x],'$1<img src="http://clipperblog.com/wp-includes/images/smilies/icon_'+smiliesfiles[x]+'.gif" alt="'+smiliesalt[x]+'" class="wp-smiley" />$2');
					}
				}
			return text;
		};
	
	/* Public Methods */
	return {
		preview: function (id,suf) {
			if(delay >= 0){
				_update(id,suf);
				delay = 0;
			}else{
				delay++;
			}
		}
	}
}();

/* start effects */

/**
*	Copyrighted 2007 to:
*	Aaron Huran http://anthologyoi.com
*	The code is released under a Creative Commons Liscense
*	(Attribution-NonCommercial-ShareAlike 2.0)
*	TERMS: (Removal this section indicates agreement with these Terms.)
*	For Personal (non-distribution) this notice (sans Terms section) must remain.
*	For Distribution this notice must remain and attribution through
*	a publically accessible "followable" link on applicable information/download page is required.
*	No Commercial use without prior approval.
**/

var AOI_eff = function () {
	var delay = 100;
	var _d = [];
	var $ = function (id) {
		return document.getElementById(id);
	};

	var hideChildren = function(id){
		var c = document.getElementById(id).getElementsByTagName('div');

		for(x=0; x < c; x++){

			if(c.parentNode.id == id){
// 				console.log(c.parentNode.id);
			}
// 		console.log(id, c, document.getElementById(c).parentNode.id)
		}

	}

	return {
		start: function () {
			var	i = arguments[0];

			if (!_d[i]) {
				_d[i] = arguments[1] || [];

				if (!_d[i].queue) {
					_d[i].queue = '';
				}

				if (!_d[i].mode) {
					if ($(i).style.display === 'block') {
						_d[i].mode = 'hide';
					} else {
						_d[i].mode = 'show';
					}
				}

				if(_d[i].hideChildren)
					hideChildren(_d[i].hideChildren);
				AOI_eff.setup(i);
			}
		},
		setup: function (i) {

			if ($(i)) {
				if (_d[i].mode === 'hide') {
					_d[i].step = -10;

					AOI_eff.ready(i, 'hide');
				} else if (_d[i].mode === 'show') {

					_d[i].step = 10;
					AOI_eff.ready(i, 'show');
				} else if (_d[i].mode === 'other') {
					_d[i].step = 10;
					AOI_eff.ready(i, 'other');
				}

				if (!_d[i].delay) {
					_d[i].delay = delay;
				}

				AOI_eff.doit(i);
			} else {
				return false;
			}
		},
		ready: function (i, m) {
			var e = $(i).style;
			switch (_d[i].eff) {
				case 'Expand':

					_d[i]['overflow'] = e.overflow;
					_d[i]['lineHeight'] = e.lineHeight;
					_d[i]['letterSpacing'] = e.letterSpacing;

					if (m === 'show') {
						e.overflow = 'hidden';
						e.lineHeight = '300%';
						e.letterSpacing = '1em';
					}

					break;
				case 'SlideUp':
					_d[i]['height'] = $(i).offsetHeight;
					if (m === 'show') { /*We need an object to be displayed to retrieve height.*/
						e.position='absolute'; /*Pull the element out of its default location*/
						e.visibility='hidden'; /*Hide the element*/
						e.display='block';/*"Display" the hidden element*/
						_d[i]['height'] = $(i).offsetHeight;
						e.visibility=''; /*Show it*/
						e.position='relative'; /*Put it back where it was*/
						e.height = '0px'; /*shrink it for the effect.*/
					}
					e.overflow="hidden";
					break;

				case 'ScrollLeft':
					_d[i]['marginLeft'] = e.marginLeft;
					if (m === 'show') {
						e.marginLeft = 80+'%';
					}
					break;
				case 'Fade':
					e.zoom = 1;/*IE fix*/
					e.backgroundColor = _d[i].background;
					if (m === 'show') {
						e.filter = 'alpha(opacity=0)';
						e.opacity = 0;
					}
					break;
			}

			if (m === 'show') {
				e.display = 'block';
			}
		},
		doit: function (i) {
			var e = $(i).style; /**/
			var m = _d[i].mode;
			var s = _d[i].step;
			var v = 0;

			if ( _d[i].step !== 0  ) {
				switch (_d[i].eff) {
					case 'Expand':
						if 	( m === 'hide' ) {
							v = (100+ (10+s)*20); /*IE fix*/
							e.lineHeight = v+'%';
							e.letterSpacing = ((10+s)*3)+'px';
							_d[i].step += 1;
						} else {
							v = (300 - (10-s)*20);/*IE fix*/
							e.lineHeight = v+'%';
							e.letterSpacing = s*2+'px';
							_d[i].step -= 1;
						}
					break;

					case 'SlideUp':
						if 	( m === 'hide' ) {
							e.height =  Math.floor( _d[i]['height']*s*-0.1)+'px';
							_d[i].step += 1;
						} else {
							e.height = Math.floor( _d[i]['height']*(10-s)*0.1)+'px';
							_d[i].step -= 1;
						}
					break;

					case 'ScrollLeft':

						if 	( m === 'hide' ) {
							if ((!window.innerHeight && s < -3) || window.innerHeight ) {/*IE fix*/
								e.marginLeft=((10 + s)*10)+'%';
							}
							_d[i].step += 1;
						} else {
							e.marginLeft=(s*8)+'%';
							_d[i].step -= 1;
						}
					break;

					case 'Fade' :
						if 	( m === 'hide' ) {
							e.opacity = (s)/-10;
							e.filter = 'alpha(opacity='+(s*-10)+')';
							_d[i].step+= 1;
						} else {
							e.filter = 'alpha(opacity='+((10-s)*10)+')';
							e.opacity = (10 - s)/10;
							_d[i].step -= 1;
						}
						break;
					default:
						_d[i].step = 0;
						break;

				}
					setTimeout("AOI_eff.doit('"+i+"');",  _d[i].delay); /*Call next frame after delay.*/
			} else {
				AOI_eff.finish(i); /*Clean up*/
			}
		},
		finish: function (i) {
			var e = $(i).style; /**/
			if ( _d[i].mode === 'hide' ) {
				e.display = 'none';
			}

			switch (_d[i].eff) {
				case 'Expand':
					if ( _d[i]['overflow'] ) {
						e.overflow = _d[i]['overflow'];
					}

					e.lineHeight ="normal";
					e.letterSpacing ="normal";

					break;
				case 'SlideUp':
					e.height = _d[i]['height']+'px';
					if(window.innerHeight){ /*IE has problems setting height to auto.*/
						e.height = 'auto';}
					e.overflow="visible";
					break;
				case 'ScrollLeft':
					e.marginLeft = _d[i]['marginLeft'] ;
					break;
				default :
					e.opacity = 10;
					e.filter = 'alpha(Opacity=100)';
			}

			if ( _d[i].queue.length > 0 ) {/* Checks to see if there is another effect*/
				var val;

				val = _d[i].queue.shift().split('::'); /*Gets values for first queue'd item*/
				if (val[2]) { /*Sets effect*/
					_d[i].eff = val[2];
				}
				if (val[3]) { /*Sets delay*/
					_d[i].delay = val[3];
				}
				dtemp = _d[i];
				_d[i] = null;
				_d[val[1]] = [];
				_d[val[1]] = dtemp;
				_d[val[1]].mode = val[0];


				AOI_eff.setup(val[1]);
			} else {
				_d[i] = null;
			}
		}
	};
}();