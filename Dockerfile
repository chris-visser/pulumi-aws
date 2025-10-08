# Build argument to specify Node.js version
ARG NODE_VERSION=22

# Use official Pulumi Node.js base image
FROM pulumi/pulumi-nodejs-${NODE_VERSION}

# Create a non-root user (avoid root completely)
USER 1001
WORKDIR /home/pulumi

# Copy AWS CLI binary instead of installing via apt-get (no root needed)
RUN mkdir -p /tmp/aws && \
    chmod -R 777 /tmp/aws && \
    case "$(uname -m)" in \
      x86_64) ARCH="x86_64";; \
      aarch64) ARCH="aarch64";; \
    esac && \
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "/tmp/aws/awscliv2.zip" && \
    unzip /tmp/aws/awscliv2.zip -d /tmp/aws && \
    /tmp/aws/aws/install --bin-dir /home/pulumi/.local/bin --install-dir /home/pulumi/.aws-cli --update && \
    rm -rf /tmp/aws

# Add Pulumi plugins (runs as non-root)
RUN pulumi plugin install resource aws && \
    pulumi plugin install resource command

# Ensure local bin is in PATH
ENV PATH="/home/pulumi/.local/bin:${PATH}"

# Set working directory for project
WORKDIR /home/pulumi/projects

# Drop privileges explicitly (just to be clear)
USER 1001

# Default command
CMD ["pulumi", "version"]
