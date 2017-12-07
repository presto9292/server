FROM centos:7
EXPOSE 8443 9443 5601 8000
ENV SKYBOX_DOCKER=1
ENV NSS_SDB_USE_CACHE=YES
STOPSIGNAL SIGINT
RUN yum -y update && \
    yum -y install libaio && \
    yum -y install numactl-libs && \
    yum -y install iproute && \
    yum -y install net-tools && \
    yum -y install sudo && \
    yum -y install less && \
    yum -y install which && \
    rm -rf /var/cache/yum && \
    yum -y clean all && \
    /usr/sbin/groupadd skyboxview && \
    /usr/sbin/useradd -g skyboxview skyboxview && \
    /bin/echo "skyboxview:skyboxview" | chpasswd && \
    usermod -aG wheel skyboxview
USER skyboxview:skyboxview
WORKDIR /opt/skyboxview/server/bin
ADD --chown=skyboxview:skyboxview ./thirdparty_x_jboss.tar /opt/skyboxview
ADD --chown=skyboxview:skyboxview ./all_x_thirdparty_x_jboss.tar /opt/skyboxview
HEALTHCHECK --start-period=2m --interval=10s --retries=78 --timeout=20s \
        CMD curl -k -u skyboxview:skyboxview -H 'accept: application/json' \
        -X GET 'https://localhost:8443/skybox/webservice/jaxrsinternal/internal/healthcheck/ping' \
        || exit 1
ARG skybox_version=
ARG skybox_build_date=
LABEL com.skyboxsecurity.name="Skybox Integrated Image" \
        com.skyboxsecurity.vendor="Skybox Security" \
        com.skyboxsecurity.version="$skybox_version" \
        com.skyboxsecurity.license="Skybox License" \
        com.skyboxsecurity.build-date="$skybox_build_date" \
        com.skyboxsecurity.description="Integrated Image of Skybox Server & Collector" \
        com.skyboxsecurity.maintainer="sales@skyboxsecurity.com"
CMD ["./startserver-debug.sh"]
