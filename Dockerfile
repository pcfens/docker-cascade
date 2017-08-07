FROM store/oracle/serverjre:8

LABEL org.label-schema.name="Cascade CMS" \
      org.label-schema.description="Cascade v8.4.1" \
      org.label-schema.schema-version="1.0"

EXPOSE 8080
HEALTHCHECK CMD curl -f http://localhost:8080/ || exit 1

RUN ln -s /usr/share/zoneinfo/America/New_York /etc/localtime \
    && yum install util-linux -y \
    && yum clean all

# Copy the tomcat component of the download into the container
COPY cascade/tomcat /usr/local/tomcat

# Copy our custom start script and configuration files into the
# image
COPY run.sh /usr/local/tomcat/bin/
COPY *.xml /usr/local/tomcat/conf/

WORKDIR /usr/local/tomcat
CMD ["bin/run.sh"]
