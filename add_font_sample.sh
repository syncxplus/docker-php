#!/bin/bash
curl -OL https://www.imagemagick.org/Usage/scripts/imagick_type_gen
curl -OL https://raw.githubusercontent.com/adobe-fonts/source-han-sans/release/OTF/SimplifiedChinese/SourceHanSansSC-Normal.otf
chmod a+x imagick_type_gen
default=`gm convert -list font|grep type|awk '{print $2}'|sed -e 's/type-ghostscript/type/1'`
sample=`./imagick_type_gen ${PWD}/SourceHanSansSC-Normal.otf|sed -e 's/<typemap>//1'|sed -e "s/<\/typemap>//1"|sed -e 's/<?xml version="1.0"?>//1'`
sed -i 's/<\/typemap>//1' ${default}
echo ${sample} >> ${default}
echo "</typemap>" >> ${default}
rm -rf imagick_type_gen SourceHanSansSC-Normal.otf