# Credit to "https://github.com/willhallonline/docker-ansible" and 
# https://nickjanetakis.com/blog/docker-tip-56-volume-mounting-ssh-keys-into-a-docker-container
# Usage
# docker build --progress=plain -t local/debian-ansible .
# docker run -it -v .:/ansible -v $env:USERPROFILE\.ssh:/tmp/.ssh:ro local/debian-ansible /bin/bash
FROM --platform=linux/amd64 debian:bookworm

ARG ANSIBLE_CORE_VERSION=2.16.10
ARG ANSIBLE_VERSION=9.9.0
ARG ANSIBLE_LINT=6.22.1
ENV ANSIBLE_CORE_VERSION ${ANSIBLE_CORE_VERSION}
ENV ANSIBLE_VERSION ${ANSIBLE_VERSION}
ENV ANSIBLE_LINT ${ANSIBLE_LINT}

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y python3-pip sshpass git openssh-client libhdf5-dev libssl-dev libffi-dev dos2unix && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

RUN  rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED && \
  pip3 install --upgrade pip cffi && \
  pip3 install ansible-core==${ANSIBLE_CORE_VERSION} && \
  pip3 install ansible==${ANSIBLE_VERSION} ansible-lint==${ANSIBLE_LINT} && \
  pip3 install mitogen jmespath && \
  pip install --upgrade pywinrm && \
  rm -rf /root/.cache/pip

RUN mkdir /ansible && \
  mkdir -p /etc/ansible && \
  echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN dos2unix /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh
ENTRYPOINT ["/bin/docker-entrypoint.sh"]
CMD [ "ansible-playbook", "--version" ]
