<?php
try {
    $draw = new GmagickDraw;
    $draw->annotate(100, 100, "思源黑体");
    $draw->setfont("SourceHanSansSC-Normal");
    $draw->setfontsize(50);
    $draw->setfillcolor("red");
    $gm = new Gmagick('/var/font/testbird.png');
    header('Content-type: image/png');
    echo $gm->drawimage($draw);
} catch (Exception $e) {
    var_dump($e);
}
