FROM centos:centos7

EXPOSE 4440

# Configure env variables
ARG RUNDECK_VERSION='3.2.0.20191218'
ENV RDECK_BASE '/var/lib/rundeck'
ENV RDECK_CONFIG '/etc/rundeck'

# Where to store the DB and project definitions and logs
VOLUME ["/var/rundeck", "/var/lib/rundeck/logs"]

# Install java and xsltproc
RUN yum install -y java-1.8.0-openjdk gettext xmlstarlet \
    python-requests python-requests-kerberos bc openssh-clients && yum clean all


# Install rundeck
# See https://bintray.com/rundeck/rundeck-rpm       ←←←← VESIONS
# See https://github.com/rundeck/rundeck/issues/5168#issuecomment-522818928 regarding the `--setopt=obsoletes=0` flag
RUN yum install -y http://repo.rundeck.org/latest.rpm && \
    yum install -y --setopt=obsoletes=0 rundeck-${RUNDECK_VERSION} rundeck-config-${RUNDECK_VERSION} && \
    yum clean all

COPY run.sh /

# Create rundeck folders and give appropriate permissions
RUN mkdir -p /tmp/rundeck && mkdir -p $RDECK_BASE && chmod -R a+rw $RDECK_BASE && chmod -R a+rw /var/log/rundeck && \
    chmod -R a+rw /tmp/rundeck && mkdir -p /rundeck-config && chmod -R a+rw $RDECK_CONFIG && \
    chmod -R a+rwx /rundeck-config && chmod a+x /run.sh

ENTRYPOINT './run.sh'
