# Build argument to specify Node.js version (used for image tag)
ARG NODE_VERSION=24

# Use the official Pulumi Node.js image with specified Node version
# The pulumi/pulumi-nodejs image provides different tags for different Node versions
FROM pulumi/pulumi-nodejs-${NODE_VERSION}

# Install system packages including AWS CLI and other tools
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install commonly used Pulumi plugins
# These are the plugins typically pre-installed in the official image
RUN pulumi plugin install resource aws v7.3.1
RUN pulumi plugin install resource command v1.0.1
RUN pulumi plugin install resource synced-folder v0.12.4

# Install global npm packages if needed
# RUN npm install -g typescript @types/node

# Set working directory
WORKDIR /pulumi/projects

# Copy your Pulumi project files (uncomment as needed)
# COPY --chown=pulumi:pulumi . .

# Install project dependencies (uncomment if you have package.json)
# RUN npm install

# Default command
CMD ["pulumi", "version"]
