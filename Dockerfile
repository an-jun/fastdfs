FROM ubuntu:xenial
MAINTAINER anjunact@qq.com

# 更新数据源
WORKDIR /etc/apt
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse' > sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse' >> sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse' >> sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse' >> sources.list
RUN apt-get update

# 安装依赖
RUN apt-get install make gcc libpcre3-dev zlib1g-dev git --assume-yes
WORKDIR /root
RUN git clone https://github.com/happyfish100/libfastcommon
RUN git clone https://github.com/happyfish100/fastdfs
RUN git clone https://github.com/happyfish100/fastdfs-nginx-module
RUN cd libfastcommon && ./make.sh && ./make.sh install
RUN cd /root/fastdfs && ./make.sh && ./make.sh install
ADD nginx-1.14.1.tar.gz /root/
WORKDIR /root/nginx-1.14.1
RUN  ./configure --add-module=/root/fastdfs-nginx-module/src && make && make install

# 配置 FastDFS 跟踪器
ADD tracker.conf /etc/fdfs
RUN mkdir -p /fastdfs/tracker
# 配置 FastDFS 存储
ADD storage.conf /etc/fdfs
RUN mkdir -p /fastdfs/storage

# 配置 FastDFS 客户端
ADD client.conf /etc/fdfs
ADD mod_fastdfs.conf /etc/fdfs

WORKDIR /root/fastdfs/conf
RUN cp http.conf mime.types /etc/fdfs/

# 配置 Nginx
ADD nginx.conf /usr/local/nginx/conf

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /
EXPOSE 7777
CMD ["/bin/bash"]



