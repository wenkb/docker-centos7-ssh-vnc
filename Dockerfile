FROM centos:centos7

LABEL description="centos7 with ssh and vnc" \
      organization="JUSFOUN" \
      author="wenkb" \
      create_date="2018-09-01" \
      build_cmd="docker build --rm -t wenkb-centos7:v1 ."

# envrionment config
ENV ROOT_PW=password \
    GEOMETRY=1360x768

# change root password
RUN echo "root:$ROOT_PW" | chpasswd

# change time zone
RUN rm -rf /etc/localtime \
 && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# chinese support
RUN yum -y update \
 && yum -y install wqy* \
 && yum -y install kde-l10n-Chinese \
 && yum -y reinstall glibc-common \
 && yum clean all \
 && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
 && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8

# install openssh and desktop
RUN yum -y update \
 # openssh
 && yum -y install openssh-clients openssh-server epel-release vim \
 && echo 'UseDNS no' >> /etc/ssh/sshd_config \
 && sed -i -e '/pam_loginuid.so/d' /etc/pam.d/sshd \
 && /usr/bin/ssh-keygen -A \
 # desktop
 && yum -y groupinstall "X Window system" \
 && yum -y groupinstall xfce \
 && yum -y install tigervnc-server\
 && rm /etc/xdg/autostart/xfce-polkit* \
 && mkdir -p /root/.vnc \
 && echo $ROOT_PW | vncpasswd -f > /root/.vnc/passwd \
 && chmod 600 /root/.vnc/passwd \
 && yum clean all

# install tools
RUN yum -y update \
 && yum -y install firefox \
 && yum -y install im-chooser \
 && yum -y install ibus \
 && yum -y install ibus-libpinyin \
 && yum -y install wget \
 && yum -y install gedit \
 && yum clean all

# create upload and download dir
RUN mkdir -p /home/upload \
 && mkdir -p /home/download

# xfce config
ADD ./xfce/ /root/

# VNC config file
COPY ./vnc/vncserver@.service /usr/lib/systemd/system
COPY ./vnc/xstartup /root/.vnc

# copy bash file
COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

EXPOSE 5900 22

CMD ["/root/startup.sh"]

