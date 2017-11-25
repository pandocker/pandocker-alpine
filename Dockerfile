FROM alpine:3.6

MAINTAINER k4zuki

RUN apk --no-cache add -U make nodejs-npm curl openssl gcc libc-dev openjdk8 graphviz && \
    mkdir -p /workspace

WORKDIR /workspace

RUN apk --no-cache add -U python3 py3-pillow libxml2-dev libxslt-dev python3-dev bash git

RUN npm install -g phantomjs-prebuilt wavedrom-cli \
      fs-extra yargs onml bit-field

RUN mkdir -p /usr/share/texlive/texmf-dist/tex/latex/BXptool/ && \
      wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip && \
      unzip v0.4.zip && \
      cp BXptool-0.4/bx*.sty BXptool-0.4/bx*.def /usr/share/texlive/texmf-dist/tex/latex/BXptool/ && \
    mkdir -p /usr/local/share/fonts && \
    wget -c https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip && \
      unzip 1.050R-it.zip && cp source-code-pro-2.030R-ro-1.050R-it/TTF/SourceCodePro-*.ttf /usr/local/share/fonts/ && \
    wget -c https://github.com/adobe-fonts/source-sans-pro/archive/2.020R-ro/1.075R-it.zip && \
      unzip 1.075R-it.zip && cp source-sans-pro-2.020R-ro-1.075R-it/TTF/SourceSansPro-*.ttf /usr/local/share/fonts/

# dependencies for texlive
RUN apk --no-cache add -U --repository http://dl-3.alpinelinux.org/alpine/edge/main \
    poppler harfbuzz-icu py3-libxml2 && \
      pip3 install \
      pantable csv2table \
      six pandoc-imagine \
      svgutils && \
      pip3 install pyyaml
# zziplib (found in edge/community repository) is a dependency to texlive-luatex
RUN apk --no-cache add -U --repository http://dl-3.alpinelinux.org/alpine/edge/community \
    zziplib && \

    apk --no-cache add -U --repository http://dl-3.alpinelinux.org/alpine/edge/testing \
    texlive-xetex && \

    ln -s /usr/bin/mktexlsr /usr/bin/mktexlsr.pl && \
    mktexlsr


ENV PLANTUML_VERSION 1.2017.18
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download
RUN curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/plantuml.jar && \
    echo "#!/bin/bash" > /usr/local/bin/plantuml && \
    echo "java -jar /usr/local/plantuml.jar \$@" >> /usr/local/bin/plantuml && \
    chmod +x /usr/local/bin/plantuml

ENV PANDOC_VERSION 2.0.3
ENV PANDOC_ARCHIVE pandoc-$PANDOC_VERSION
ENV PANDOC_URL https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/
RUN wget --no-check-certificate $PANDOC_URL/$PANDOC_ARCHIVE-linux.tar.gz && \
tar zxf $PANDOC_ARCHIVE-linux.tar.gz && cp $PANDOC_ARCHIVE/bin/* /usr/local/bin/

ENV CROSSREF_VERSION v0.3.0.0-beta3
ENV CROSSREF_ARCHIVE linux-ghc8-pandoc-2-0.tar.gz
ENV CROSSREF_URL https://github.com/lierdakil/pandoc-crossref/releases/download/$CROSSREF_VERSION
RUN wget --no-check-certificate $CROSSREF_URL/$CROSSREF_ARCHIVE && \
    tar zxf $CROSSREF_ARCHIVE && \
    mv pandoc-crossref /usr/local/bin/


RUN wget -c https://github.com/tcnksm/ghr/releases/download/v0.5.4/ghr_v0.5.4_linux_amd64.zip && \
    unzip ghr_v0.5.4_linux_amd64.zip && \
    mv ghr /usr/local/bin/ && \
    rm ghr_v0.5.4_linux_amd64.zip

WORKDIR /var
ENV PANDOC_MISC_VERSION 0.0.8
RUN git clone --recursive --depth=1 -b $PANDOC_MISC_VERSION https://github.com/K4zuki/pandoc_misc.git
RUN apk del *-doc

WORKDIR /workspace

VOLUME ["/workspace"]

ENV TZ JST
CMD ["bash"]
