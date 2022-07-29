# # Find the Dockerfile for mcr.microsoft.com/azure-functions/dotnet:3.0-dotnet3-core-tools at this URL
# FROM mcr.microsoft.com/azure-functions/dotnet:3.0-dotnet3-core-tools

# # Args
# # This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# # property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# # will be updated to match your local UID/GID (when using the dockerFile property).
# # See https://aka.ms/vscode-remote/containers/non-root-user for details.
# ARG USERNAME=vscode
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID

# # Install system tools
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends apt-utils zip unzip curl \
#     && apt-get autoremove -y \
#     && apt-get clean -y \
#     && rm -rf /var/lib/apt/lists/*

# # Uncomment if not running as root (e.g., vscode).
# USER $USERNAME

# # Install Azure Bicep CLI for Azure CLI
# # Note: Az CLI will install a separate version of the Bicep CLI that will not conflict with any other Bicep installs you may have and Az CLI will not add Bicep to your PATH.
# RUN az bicep install

# RUN curl -fsSL https://aka.ms/install-azd.sh | bash

ARG VARIANT=bullseye
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}
RUN curl -fsSL https://aka.ms/install-azd.sh | bash \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/debian/$(lsb_release -rs | cut -d'.' -f 1)/prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list' \
    && apt-get update && apt-get install -y zip unzip curl bash-completion azure-functions-core-tools-4

# Install system tools
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends apt-utils zip unzip curl bash-completion dnsutils figlet \
#     && apt-get autoremove -y \
#     && apt-get clean -y \
#     && rm -rf /var/lib/apt/lists/*