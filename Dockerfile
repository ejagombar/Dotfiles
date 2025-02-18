FROM alpine:3.21

WORKDIR /recon

# Set environment variables
ENV TERM=xterm-256color \
    EDITOR=nvim \
    GOPATH=/root/go \
    PATH="/root/go/bin:/root/.local/bin:$PATH"

# Install required packages in a single RUN command (more efficient)
RUN apk add --no-cache \
    go python3 py3-pip python3-dev \
    neovim tmux ripgrep git cmake bash musl-dev make \
    unzip wget curl gzip fd man-pages neovim-doc

# Copy dotfiles
COPY . /Dotfiles

# Symlink config directories
RUN mkdir -p /root/.config \
    && ln -sf /Dotfiles/nvim /root/.config/nvim \
    && ln -sf /Dotfiles/tmux/.tmux.conf /root/.tmux.conf \
    && ln -sf /Dotfiles/.bashrc /root/.bashrc

# Install Go tools manually to avoid Mason conflicts
RUN go install golang.org/x/tools/gopls@latest \
    && ln -sf /root/go/bin/gopls /usr/local/bin/gopls

# Install Mason, LSPs, and Treesitter parsers in a single headless session
RUN nvim --headless +"Lazy! sync" +qall
RUN nvim --headless +"MasonInstall gopls " +qall
# RUN nvim --headless +"TSInstall go python" +qall

# Default to Bash shell
CMD ["bash"]
