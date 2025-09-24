FROM ubuntu:22.04

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências
RUN apt-get update && apt-get install -y \
    git \
    make \
    automake \
    libtool \
    pkg-config \
    libaio-dev \
    libmysqlclient-dev \
    libpq-dev \
    postgresql-client \
    build-essential \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Clona e compila sysbench
WORKDIR /opt
RUN git clone https://github.com/akopytov/sysbench.git
WORKDIR /opt/sysbench
RUN ./autogen.sh \
    && ./configure --with-pgsql \
    && make -j$(nproc) \
    && make install

# Criar diretório para scripts
WORKDIR /app

# Copiar scripts de teste
COPY scripts/carga/ ./scripts/carga/
RUN chmod +x ./scripts/carga/*.sh

COPY scripts/concorrencia/ ./scripts/concorrencia/
RUN chmod +x ./scripts/concorrencia/*.sh

# Configura variáveis de ambiente padrão
ENV DB_HOST=postgres-db \
    DB_PORT=5432 \
    DB_USER=teste \
    DB_PASSWORD=teste \
    DB_NAME=testedb

# Entrar no container para rodar sysbench manualmente
CMD ["tail", "-f", "/dev/null"]