backend docker {
  .host = "web";
  .port = "80";
}

sub vcl_recv {
  set req.backend = docker;
}

include "/opt/ding2.vcl";
