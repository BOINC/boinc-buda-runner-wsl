FROM debian:trixie

RUN apt update && apt install -y \
    qemu-user \
    qemu-user-binfmt \
    mmdebstrap

WORKDIR /app

CMD ["/bin/bash"]
