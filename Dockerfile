# Set the base image
FROM alpine:3.3

LABEL description="Synereo Docker Image Beta" version="0.1.3"
MAINTAINER N<ns68751+dockerfile@gmail.com>

ENV NODEADMINEMAIL admin@localhost
ENV NODEADMINPASS a
ENV DEPLOYMENT_MODE colocated
ENV DSLSERVER 127.0.0.1
ENV DSLPORT 5672
ENV DSLEPSSERVER 127.0.0.1
ENV DSLEPSPORT 5672
ENV BFCLSERVER 127.0.0.1
ENV BFCLPORT 5672

ENV W_DIR /usr/local
ENV S_DIR $W_DIR/splicious
ENV S_CMD splicious.sh
ENV MONGODB_HOST 127.0.0.1
ENV MONGODB_PORT 27017
WORKDIR $W_DIR
ADD m2cup-jlex-configgy-prolog-pickling.tar.gz /root/

# Install OpenJDK 8, Maven and other software
RUN \
    echo http://dl-4.alpinelinux.org/alpine/v3.3/main >> /etc/apk/repositories && \
    echo http://dl-4.alpinelinux.org/alpine/v3.3/community>> /etc/apk/repositories && \
    apk --update add openjdk8 automake autoconf bash gcc git libc-dev imake ncurses-dev openjdk8 openssh-client && \
    wget http://apache.claz.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz -O \
         /usr/lib/apache-maven-3.3.9-bin.tar.gz && \
    cd /usr/lib/ && \
    tar -xzvf apache-maven-3.3.9-bin.tar.gz && \
    rm -f apache-maven-3.3.9-bin.tar.gz && \
    \
    cd /usr/bin && \
    ln -s ../lib/jvm/java-1.8-openjdk/bin/jar jar && \
    ln -s ../lib/jvm/java-1.8-openjdk/bin/javac javac && \
    ln -s ../lib/apache-maven-3.3.9/bin/mvn mvn && \
#    ln -s /usr/lib/jvm/java-1.8-openjdk/bin/javac /usr/bin/javac && \
#    ln -s /usr/lib/jvm/java-1.8-openjdk/bin/jar /usr/bin/jar && \
#    ln -s /usr/lib/apache-maven-3.3.9/bin/mvn /usr/bin/mvn && \
    \
    cd $W_DIR && \
#    git clone -b forespray https://github.com/n10n/SpecialK.git  && \
#    git clone -b master https://github.com/n10n/agent-service-ati-ia.git  && \
#    git clone -b livelygig-api https://github.com/n10n/lgimporter.git GLoSEval && \
    git clone -b 1.0 https://github.com/synereo/specialk.git SpecialK && \
    git clone -b 1.0 https://github.com/synereo/agent-service-ati-ia.git  && \
    git clone -b 1.0 https://github.com/synereo/gloseval.git GLoSEval && \
    \
    cd $W_DIR/SpecialK && \
    mvn -e -fn -DskipTests=true install prepare-package && \
    cd $W_DIR/agent-service-ati-ia/AgentServices-Store && \
    mvn -e -fn -DskipTests=true install prepare-package && \
    cd $W_DIR/GLoSEval && \
    mvn -e -fn -DskipTests=true install prepare-package && \
    \
    mkdir -p $S_DIR/lib $S_DIR/logs $S_DIR/config && \
    cp -rP $W_DIR/SpecialK/target/lib/* $S_DIR/lib/ && \
    cp -rP $W_DIR/agent-service-ati-ia/AgentServices-Store/target/lib/* $S_DIR/lib/ && \
    cp -rP $W_DIR/GLoSEval/target/lib/* $S_DIR/lib/ && \
    cp -rP $W_DIR/GLoSEval/target/gloseval-0.1.jar $S_DIR/lib/ && \
#    echo CLASSPATH=\`find lib -name "*.jar" -exec echo -n {}: \\\;\`lib\/ >$S_DIR/run.sh && \
#    echo java -cp \$CLASSPATH com.biosimilarity.evaluator.spray.Boot -unchecked -deprecation -encoding utf8 -usejavacp >> zexe/run.sh && \
    echo java -cp \"lib/*\" com.biosimilarity.evaluator.spray.Boot >> $S_DIR/run.sh && \
    \
    cp $W_DIR/GLoSEval/eval.conf $S_DIR/config/ && \
    cd $S_DIR && \
    ln -s config/eval.conf eval.conf && \
    cp $W_DIR/GLoSEval/log.properties $S_DIR/ && \
#    mv $W_DIR/agentui $S_DIR/ && \
#    mv $W_DIR/$S_CMD $S_DIR/ && \
    \
#    rm -rf $W_DIR/GLoSEval $W_DIR/SpecialK $W_DIR/agent-service-ati-ia && \
#    rm -rf /root/.m2 /root/.zinc && \
    rm -rf /var/cache/apk/* && \
    rm -f $S_DIR/lib/junit-3.8.1.jar $S_DIR/lib/junit-4.7.jar $S_DIR/lib/scalaz-core_2.10-6.0.4.jar $S_DIR/lib/slf4j-api-1.6.1.jar && \
    rm $S_DIR/lib/*.pom && \
#   Autostart 
#    chmod 755 /etc/init.d/$S_CMD && \
#    ln -s /etc/init.d/$S_CMD /etc/runlevels/default/$S_CMD && \
#    update-rc.d /etc/init.d/$S_CMD defaults && \
    cd $S_DIR/

ADD agentui.tar.gz $S_DIR/
ADD sclabin.tar.gz $S_DIR/
COPY splicious.sh $S_DIR/
COPY entrypoint.sh $W_DIR/

RUN \
    rm -f /usr/local/splicious/bin/._* && \
    chmod 755 $S_DIR/run.sh && \
    chmod 755 $S_DIR/splicious.sh && \
    chmod 755 $W_DIR/entrypoint.sh

WORKDIR $S_DIR
     
EXPOSE 9876
ENTRYPOINT ["/usr/local/entrypoint.sh"]
#CMD [ "/usr/local/splicious/splicious.sh start" ]
CMD [ "/usr/local/splicious/run.sh" ]
