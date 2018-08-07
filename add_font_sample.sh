#!/usr/bin/env bash

curl -OL https://raw.githubusercontent.com/adobe-fonts/source-han-sans/release/OTF/SourceHanSansSC.zip
unzip -d /var/font/ SourceHanSansSC.zip
rm -f SourceHanSansSC.zip

default=`gm convert -list font|grep type|awk '{print $2}'|sed -e 's/type-ghostscript/type/1'`
sample=`/var/font/imagick_type_gen /var/font/SourceHanSansSC/SourceHanSansSC-Normal.otf|sed -e 's/<typemap>//1'|sed -e "s/<\/typemap>//1"|sed -e 's/<?xml version="1.0"?>//1'`
sed -i 's/<\/typemap>//1' ${default}
echo ${sample} >> ${default}
echo "</typemap>" >> ${default}

chown -R www-data:www-data /var/font /var/www
