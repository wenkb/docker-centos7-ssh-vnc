FROM centos:centos7

LABEL description="centos7 with ssh and vnc" \
      organization="JUSFOUN" \
      author="wenkb" \
      create_date="2018-09-01"

# envrionment config
ENV ROOT_PW=password \
    GEOMETRY=1360x768

# change root password
RUN echo "root:$ROOT_PW" | chpasswd

RUN yum -y update \
    # -----------------------------------------------------------------------------
    # change time zone
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    # -----------------------------------------------------------------------------
    # install supervisor
    && yum -y install python-setuptools \
    && easy_install supervisor \
    # -----------------------------------------------------------------------------
    # install openssh
    && yum -y install openssh-clients openssh-server epel-release vim \
    # off DNS search
    && echo 'UseDNS no' >> /etc/ssh/sshd_config \
    # ssh login config
    && sed -i -e '/pam_loginuid.so/d' /etc/pam.d/sshd \
    && /usr/bin/ssh-keygen -A \
    # -----------------------------------------------------------------------------
    # install desktop
    && yum -y groupinstall "X Window system" \
    && yum -y groupinstall xfce \
    && yum -y install tigervnc-server\
    && rm /etc/xdg/autostart/xfce-polkit* \
    && mkdir -p /root/.vnc \
    && echo $ROOT_PW | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd \
    # -----------------------------------------------------------------------------
    # clear install temp files
    && yum clean all

# xfce config
ADD ./xfce/ /root/

# VNC config file
COPY ./vnc/vncserver@.service /usr/lib/systemd/system
COPY ./vnc/xstartup /root/.vnc

# copy bash file
COPY supervisord.conf /etc/supervisord.conf
COPY ssh.sh /root/ssh.sh
COPY vnc.sh /root/vnc.sh
RUN chmod +x /root/ssh.sh
RUN chmod +x /root/vnc.sh

EXPOSE 5900 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

