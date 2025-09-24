FROM openjdk:11-slim

RUN apt-get update && apt-get install -y \
    git \
    maven \
    python3 \
    python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/brianfrankcooper/YCSB.git

WORKDIR /opt/YCSB
RUN mvn -pl site.ycsb:mongodb-binding -am clean package -DskipTests

RUN /opt/ycsb/bin/ycsb load mongodb -h >/dev/null 2>&1 || true

WORKDIR /app

# Copiar workloads customizados
COPY workloads/carga/ /opt/YCSB/workloads/carga/
COPY workloads/desempenho_consultas/ /opt/YCSB/workloads/desempenho_consultas/

# Criar link simbólico para facilitar acesso
RUN ln -s /opt/YCSB/bin/ycsb /usr/local/bin/ycsb

# Configura variáveis de ambiente padrão
ENV MONGO_HOST=mongo-db \
    MONGO_PORT=27017 \
    MONGO_USER=teste \
    MONGO_PASSWORD=teste \
    MONGO_AUTH_DB=admin \
    YCSB_HOME=/opt/YCSB

ENV PATH="/opt/YCSB/bin:${PATH}"

CMD ["tail", "-f", "/dev/null"]