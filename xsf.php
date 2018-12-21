<?php
$file = "/var/www/html/xsf/README.md";
header("X-Sendfile:$file");
