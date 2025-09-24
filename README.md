# comparacaoEntreSql_NoSql
Experimento prático e conceitual comparando bancos de dados do tipo SQL e NoSQL

**NAVEGUE POR CADA TIPO DE TESTE ALTERANDO A BRANCH DO REPOSITÓRIO**

## 1. Objetivo
Comparar PostgreSQL (banco de dados relacional) e MongoDB (banco de dados orientado a documentos) em termos de:
Desempenho sob diferentes tipos de carga.


- Escalabilidade, concorrência e robustez.


- Simplicidade e complexidade das consultas (SQL vs NoSQL).


- Cenários de uso mais indicados.



## 2. Ferramentas
Banco Relacional (SQL): PostgreSQL 17.6
Banco Não-Relacional (NoSQL): MongoDB 7.0.23
Dataset: Brazilian E-Commerce Public Dataset by Olist
Benchmarkings:
sysbench: testes de carga/concorrência no PostgreSQL


YCSB: testes de throughput no MongoDB
Scripts auxiliares: Python ou Node.js para consultas comparativas
Gerador de dados: Mockaroo


## 3. Tipos de Testes
### 3.1. Testes de carga
Medir como o banco se comporta sob uma quantidade esperada de usuários/queries.
Exemplo: Em média 1000 usuários acessando simultaneamente um sistema de e-commerce.
Objetivo: verificar se o banco suporta a demanda prevista sem degradação.

### 3.2 Teste de Volume
Avaliar o desempenho com grandes volumes de dados armazenados.
Exemplo: tabelas com milhões de registros e encontrar gargalos.
Objetivo: medir impacto em consultas, corrigir gargalos, índices e tempo de backup/restore.

### 3.3 Teste de Estresse
Vai além da carga esperada, aplicando carga excessiva para encontrar o limite do banco.
Exemplo: inserir 10 bilhões de registros em minutos ou simular picos de acesso.
Objetivo: descobrir até onde o banco aguenta antes de travar e como ele se recupera.

### 3.4. Teste de Desempenho de Consultas
Medir latência, throughput e otimização de consultas específicas.
Exemplo: comparar SELECT com JOINs no SQL vs agregações no MongoDB.
Objetivo: identificar gargalos e comparar modelos de dados.

### 3.5. Teste de Concorrência 
Simular múltiplas transações simultâneas para avaliar bloqueios, deadlocks e isolamento.


---

# Requisitos de Sistema
- Sistema Operacional: Linux, macOS ou Windows com WSL2
- Docker: Versão 20.10 ou superior
- Docker Compose: Versão 2.0 ou superior
- Memória RAM: Mínimo 8 GB (recomendado 16 GB)
- Armazenamento: 20 GB de espaço livre
- Processador: Multicore (4 cores ou mais recomendado)

Estrutura do Projeto
```
comparacaoEntreSql_NoSql/
├── datasets/                          # Diretório de datasets
│   ├── mongo/                        # Arquivos JSON para MongoDB
│   │   ├── …
│   │   └── ...
│   └── *.csv                         # Arquivos CSV para PostgreSQL
├── postgres/
│   └── init/
│       └── 01-init.sql              # Schema do PostgreSQL
├── sysbench/
│   ├── Dockerfile
│   └── scripts/
│       └── …
├── ycsb/
│   ├── Dockerfile
│   └── workloads/
│       └── …
├── docker-compose.yml
├── run_benchmark_<teste>.sh                 # Cada cenário de teste tem um script
└── results/                                 # Resultado dos benchmarks
```
## Configuração do Ambiente
### 1. Preparação dos Datasets
O dataset está em um arquivo .zip na raiz do projeto. Extraia-o na própria raiz.

Certifique-se que os arquivos estão no diretório correto
```
ls datasets/
```
### 2. Construção dos Containers
Para construir e iniciar os containers, use:
```
docker-compose build     # Construir imagens customizadas
docker-compose up -d     # Iniciar containers em background
```
Para verificar status:
```
docker-compose ps
```
## 3. Execução
Cada cenário de teste está em uma branch, todas elas seguem uma estrutura semelhante.

Para realizar o benchmarking, mude para a branch de teste desejada e execute o ```script run_benchmark.sh``` na raiz do projeto:
```
./bash run_benchmark.sh
```




