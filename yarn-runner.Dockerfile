FROM summerwind/actions-runner-dind:latest

# Add repositories
RUN (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;\
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# install packages
RUN sudo apt update \
    && sudo apt install -y --no-install-recommends \
    docker \
    docker-buildx \
    git \
    jq \
    openssl \
    zstd \
    gh \
    yarn \
    pip \
    p7zip && \
    sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && sudo rm -f awscliv2.zip

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["entrypoint-dind.sh"]
