const String baseUrl = 'http://kitapalintilari.kodsuzyazilim.tk';
// const String baseUrl = 'http://192.168.1.105';

const String loginRegisterUrl =
    baseUrl + '/kitapalintilari/users/login_register.php';

const String getPhotoUrl = baseUrl + '/kitapalintilari/users/get_photo.php';

const String updatePhotoUrl =
    baseUrl + '/kitapalintilari/users/update_photo.php';

const String userPhotoPath = baseUrl + '/kitapalintilari/users/photos/';

const String updateNamePath =
    baseUrl + '/kitapalintilari/users/update_name.php';

const String updateMailPath =
    baseUrl + '/kitapalintilari/users/update_mail.php';

const String updatePasswordPath =
    baseUrl + '/kitapalintilari/users/update_password.php';

const String addQuotePath = baseUrl + '/kitapalintilari/quotes/add_quote.php';

String getQuotesPath(int limit) =>
    baseUrl + '/kitapalintilari/quotes/get_quotes.php?id=$limit';

String getQuotesLikePath(int limit) =>
    baseUrl + '/kitapalintilari/quotes/get_quotes.php?id=$limit&like=0';

const String likeQuotePath = baseUrl + '/kitapalintilari/quotes/like_quote.php';

const String favoriteQuotePath =
    baseUrl + '/kitapalintilari/quotes/favorite_quote.php';

const String getFavoritesPath =
    baseUrl + '/kitapalintilari/quotes/get_favorites.php';

const String getFavoritePostsPath =
    baseUrl + '/kitapalintilari/quotes/get_favorite_posts.php';

const String reportQuotePath = baseUrl + '/kitapalintilari/quotes/report.php';

const String deleteQuotePath =
    baseUrl + '/kitapalintilari/quotes/delete_quote.php';

const String getUserIdPath = baseUrl + '/kitapalintilari/users/get_id.php';

const String addCommentPath =
    baseUrl + '/kitapalintilari/quotes/add_comment.php';

String getCommentPath(int limit) =>
    baseUrl + '/kitapalintilari/quotes/get_comments.php?limit=$limit';

const String removeCommentPath =
    baseUrl + '/kitapalintilari/quotes/remove_comment.php';

const String getLikesCommentsPath =
    baseUrl + '/kitapalintilari/users/get_user_like_comments.php';

const String blockUserPath = baseUrl + '/kitapalintilari/users/block_user.php';

const String getUserTokenPath =
    baseUrl + '/kitapalintilari/users/get_token.php';
