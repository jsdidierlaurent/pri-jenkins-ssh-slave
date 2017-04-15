FROM resin/raspberry-pi-openjdk:openjdk-8-jdk
LABEL maintainer "Jean-Sébastien Didierlaurent <js.didierlaurent@gmail.com>"

# Install SSHD
RUN apt-get update && \
    apt-get install \
    curl \
    wget \
    git \
    openssh-server && \
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set SSH Configuration to allow remote logins without /proc write access
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

# Create Jenkins User
RUN useradd jenkins -m -s /bin/bash

# Add public key for Jenkins login
RUN mkdir /home/jenkins/.ssh

# Create this directory and put authorized_keys files with your pub.key 
COPY /files/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins /home/jenkins
RUN chgrp -R jenkins /home/jenkins
RUN chmod 600 /home/jenkins/.ssh/authorized_keys
RUN chmod 700 /home/jenkins/.ssh

# Add the jenkins user to sudoers
RUN echo "jenkins    ALL=(ALL)    ALL" >> etc/sudoers

# Expose SSH port and run SSHD
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]