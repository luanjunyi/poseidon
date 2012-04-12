<?php

function connect_db($user, $password, $dbname, $hostname="localhost") {
  if (!mysql_connect($hostname, $user, $password)) {
    die("connect to DB failed");
  }

  if (!mysql_select_db($dbname)) {
    die("mysql_select_db failed");
  }

  if (!mysql_query("set names utf8")) {
    die("failed to set names utf8");
  }
}

function sql_or_die($sql) {
  $ret = mysql_query($sql);
  if (!$ret) {
    die("sql( $sql ) failed:" . mysql_error() . "<br />");
  } else {
    return $ret;
  }
}

function get_source_by_wee($wee) {
  $sql = "select title from wee_source where id = {$wee['source_id']}";
  $ret = sql_or_die($sql);
  $row = mysql_fetch_row($ret);
  return $row[0];
}

?>