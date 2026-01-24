FROM tomcat:9.0.111-jre21-temurin-jammy
RUN rm -rf /usr/local/tomcat/webapps/*
WORKDIR /tmp
COPY /tmp/boxfuse-sample-java-war-hello/target/hello-1.0.war /usr/local/tomcat/webapps/ROOT.war
