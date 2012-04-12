<?php

$username = 'art';
$password = 'admin123';
include("lib/class-IXR.php");
include("lib/db.php");
$client = new IXR_Client('http://www.iniming.com/xmlrpc.php');
$blog_id = "iniming";

function add_post($post) {
  global $client, $username, $password, $blog_id;
  $title = $post['title'];
  $desc = $post['content'];
  $content['title'] = $title;
  $content['description'] = $desc;

  if (!$client->query('metaWeblog.newPost','', $username, $password, $content, false)) {
    die('An error occurred - '.$client->getErrorCode().":".$client->getErrorMessage());
  }

  echo sprintf("%s added to draft, post id: %d\n", $title, $client->getResponse());

  // Add this post history to DB
  $sql = "insert into post_history(blog, wee_id) values('{$blog_id}', '{$post['id']}')";
  sql_or_die($sql);
  echo "synced to {$blog_id}\n";
}

function get_candidate_post() {
  $DAY = 3600 * 24;
  $threshold = time() - $DAY;
  // Find wee that updated within 24 hours
  $sql = "select * from wee where updated_time > $threshold";
  $ret = sql_or_die($sql);
  $result = array();
  while ($wee = mysql_fetch_assoc($ret)) {
    global $blog_id;
    $sql = "select blog from post_history where blog = '{$blog_id}' and wee_id = {$wee['id']}";
    $t = sql_or_die($sql);
    if (mysql_num_rows($t) == 0) {
      $result[] = $wee;
    }
  }
  return $result;
}

function compose_post($wee) {
  echo sprintf("processing candidate: {$wee['id']} {$wee['title']} %s\n", date('Y-m-d H:i', $wee['updated_time']));
  $source = get_source_by_wee($wee);
  echo "source: $source \n";
  $post = array();
  $post['title'] = $wee['title'];
  $post['content'] = $wee['html'] . "<br />via: <a rel='nofollow' href='{$wee['url']}'>$source</a>";
  $post['id'] = $wee['id'];
  return $post;
}

connect_db("junyi", 'admin123', 'weDaily');
$wee = get_candidate_post();
echo count($wee) . " posts to be drafted\n";

for ($i = 0; $i < count($wee); ++$i) {
  $candidate = $wee[$i];
  $post = compose_post($candidate);
  add_post($post);
}

?>
