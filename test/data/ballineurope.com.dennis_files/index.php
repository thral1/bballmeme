function akttPostTweet() {
	var tweet_field = jQuery('#aktt_tweet_text');
	var tweet_text = tweet_field.val();
	if (tweet_text == '') {
		return;
	}
	var tweet_msg = jQuery("#aktt_tweet_posted_msg");
	jQuery.post(
		"http://www.ballineurope.com/index.php"
		, {
			ak_action: "aktt_post_tweet_sidebar"
			, aktt_tweet_text: tweet_text
		}
		, function(data) {
			tweet_msg.html(data);
			akttSetReset();
		}
	);
	tweet_field.val('').focus();
	jQuery('#aktt_char_count').html('');
	jQuery("#aktt_tweet_posted_msg").show();
}
function akttSetReset() {
	setTimeout('akttReset();', 2000);
}
function akttReset() {
	jQuery('#aktt_tweet_posted_msg').hide();
}
