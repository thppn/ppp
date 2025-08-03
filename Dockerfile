FROM python:3.12-slim

ENV ANTLR_VERSION=4.13.2

RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    curl \
    gcc \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/lib/antlr4.jar https://www.antlr.org/download/antlr-${ANTLR_VERSION}-complete.jar

RUN echo '#!/bin/sh\nexec java -jar /usr/local/lib/antlr4.jar "$@"' > /usr/local/bin/antlr4 && \
    chmod +x /usr/local/bin/antlr4

RUN pip install --break-system-packages antlr4-python3-runtime

RUN echo 'alias antlr4="java -jar /usr/local/lib/antlr4.jar"' >> /etc/bash.bashrc && \
    echo 'alias python="python3"' >> /etc/bash.bashrc

WORKDIR /work

COPY . /work

VOLUME ["/work"]

CMD ["/bin/bash"]
