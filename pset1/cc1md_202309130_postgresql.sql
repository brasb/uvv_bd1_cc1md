/*
    Aluno: Brás Washington Brito Prates
    Matrícula: 202309130
    Turma: CC1MD
*/

-- Apaga o banco de dados 'uvv', caso já exista.
DROP DATABASE IF EXISTS uvv;

-- Cria o usuário e dá as permissões corretas para ele. Caso já exista, apagar e recriar.
DROP USER IF EXISTS bras;
CREATE ROLE bras WITH CREATEDB CREATEROLE LOGIN PASSWORD '123';

-- Cria o banco de ddados 'uvv'.
CREATE DATABASE uvv OWNER bras;

-- Conecta ao banco de dados com o usuário correto.
\c 'user=bras password=123 dbname=uvv'

-- Criação do schema. 
CREATE SCHEMA lojas;
-- Definir o schema 'lojas' como o padrão.
SET SEARCH_PATH TO lojas, "$user", public;


-- Criação de tabelas, comentários e restrições.
CREATE TABLE lojas.produtos (
                produto_id                NUMERIC(38)    NOT NULL,
                nome                      VARCHAR(255)   NOT NULL,
                preco_unitario            NUMERIC(10, 2),
                detalhes                  BYTEA,
                imagem                    BYTEA,
                imagem_mime_type          VARCHAR(512),
                imagem_arquivo            VARCHAR(512),
                imagem_charset            VARCHAR(512),
                imagem_ultima_atualizacao DATE,
                CONSTRAINT produto_id PRIMARY KEY (produto_id)
);

COMMENT ON TABLE lojas.produtos IS 'Tabela contendo os dados dos produtos';
COMMENT ON COLUMN lojas.produtos.produto_id IS 'Identificação do produto.';
COMMENT ON COLUMN lojas.produtos.nome IS 'Nome do produto.';
COMMENT ON COLUMN lojas.produtos.preco_unitario IS 'Preço unitário do produto.';
COMMENT ON COLUMN lojas.produtos.detalhes IS 'Arquivo com detalhes do produto.';
COMMENT ON COLUMN lojas.produtos.imagem IS 'Imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_mime_type IS 'Indica o tipo de arquivo da imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_arquivo IS 'Nome do arquivo da imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_charset IS 'Informa o charset da imagem do produto.';
COMMENT ON COLUMN lojas.produtos.imagem_ultima_atualizacao IS 'Informa quando a última atualização da imagem foi feita.';

-- Garante que o produto não vai ser gratuito (com preço igual a 0) e que o preço vai ser positivo.
ALTER TABLE lojas.produtos
ADD CONSTRAINT cc_preco_unitario_positivo
CHECK (preco_unitario > 0);

-- Garante que a última atualização não ocorreu no futuro.
ALTER TABLE lojas.produtos
ADD CONSTRAINT cc_ultima_atualizacao_imagem_presente_ou_passado
CHECK (imagem_ultima_atualizacao <= CURRENT_DATE);


CREATE TABLE lojas.clientes (
                cliente_id NUMERIC(38)  NOT NULL,
                email      VARCHAR(255) NOT NULL,
                nome       VARCHAR(255) NOT NULL,
                telefone1  VARCHAR(20),
                telefone2  VARCHAR(20),
                telefone3  VARCHAR(20),
                CONSTRAINT client_id PRIMARY KEY (cliente_id)
);

COMMENT ON TABLE lojas.clientes IS 'Tabela contendo os dados dos clientes.';
COMMENT ON COLUMN lojas.clientes.cliente_id IS 'Identificador do cliente.';
COMMENT ON COLUMN lojas.clientes.email IS 'E-mail do cliente.';
COMMENT ON COLUMN lojas.clientes.nome IS 'Nome do cliente.';
COMMENT ON COLUMN lojas.clientes.telefone1 IS 'Primeiro telefone do cliente.';
COMMENT ON COLUMN lojas.clientes.telefone2 IS 'Segundo telefone do cliente.';
COMMENT ON COLUMN lojas.clientes.telefone3 IS 'Terceiro telefone do cliente.';

-- Todos os e-mails válidos contêm um "@".
ALTER TABLE lojas.clientes
ADD CONSTRAINT cc_email_contem_arroba
CHECK (email like '%@%');

/*
    Essas constraints garantem que os números de telefone sempre vão conter
    somente os seguintes caracteres:
        * números de 1 a 9;
        * "(";
        * ")";
        * "+";
        * " " (espaço);
        * "-".
    Exemplo: '+55 (27) 3224-5678'.
*/
ALTER TABLE lojas.clientes
ADD CONSTRAINT cc_caracteres_validos_telefone1
CHECK (telefone1 ~ '0-9+ \-\(\)');

ALTER TABLE lojas.clientes
ADD CONSTRAINT cc_caracteres_validos_telefone2
CHECK (telefone2 ~ '0-9+ \-\(\)');

ALTER TABLE lojas.clientes
ADD CONSTRAINT cc_caracteres_validos_telefone3
CHECK (telefone3 ~ '0-9+ \-\(\)');


CREATE TABLE lojas.lojas (
                loja_id                 NUMERIC(38)  NOT NULL,
                nome                    VARCHAR(255) NOT NULL,
                endereco_web            VARCHAR(100),
                endereco_fisico         VARCHAR(512),
                latitude                NUMERIC,
                longitude               NUMERIC,
                logo                    BYTEA,
                logo_mime_type          VARCHAR(512),
                logo_arquivo            VARCHAR(512),
                logo_charset            VARCHAR(512),
                logo_ultima_atualizacao DATE,
                CONSTRAINT loja_id PRIMARY KEY (loja_id)
);

COMMENT ON TABLE lojas.lojas IS 'Tabela contendo dados sobre as lojas da UVV.';
COMMENT ON COLUMN lojas.lojas.loja_id IS 'Número identificador da loja.';
COMMENT ON COLUMN lojas.lojas.nome IS 'Nome da loja.';
COMMENT ON COLUMN lojas.lojas.endereco_web IS 'Endereço web da loja.';
COMMENT ON COLUMN lojas.lojas.endereco_fisico IS 'Endereço físico da loja.';
COMMENT ON COLUMN lojas.lojas.latitude IS 'Latitude da loja.';
COMMENT ON COLUMN lojas.lojas.longitude IS 'Longitude da loja.';
COMMENT ON COLUMN lojas.lojas.logo IS 'Logo da loja.';
COMMENT ON COLUMN lojas.lojas.logo_mime_type IS 'Informa o tipo de arquivo da logo da loja.';
COMMENT ON COLUMN lojas.lojas.logo_arquivo IS 'Nome do arquivo usado na logo da loja.';
COMMENT ON COLUMN lojas.lojas.logo_charset IS 'Especifica o charset da logo da loja.';
COMMENT ON COLUMN lojas.lojas.logo_ultima_atualizacao IS 'Informa a última vez em que a logo foi atualizada.';

-- Latitudes têm o valor mínimo de -90 graus e máximo de 90 graus.
ALTER TABLE lojas.lojas
ADD CONSTRAINT cc_validade_latitude
CHECK (latitude BETWEEN -90 AND 90);

-- Longitudes têm o valor mínimo de -180 graus e máximo de 180 graus.
ALTER TABLE lojas.lojas
ADD CONSTRAINT cc_validade_longitude
CHECK (latitude BETWEEN -180 AND 180);

-- Garante que a última atualização não ocorreu no futuro.
ALTER TABLE lojas.lojas
ADD CONSTRAINT cc_ultima_atualizacao_logo_presente_ou_passado
CHECK (logo_ultima_atualizacao <= CURRENT_DATE);

-- Garante que a loja tem pelo menos um endereço (seja web ou físico).
ALTER TABLE lojas.lojas
ADD CONSTRAINT cc_existencia_pelo_menos_um_endereco
CHECK (not (endereco_web IS NULL AND endereco_fisico IS NULL));

CREATE TABLE lojas.envios (
                envio_id         NUMERIC(38)  NOT NULL,
                loja_id          NUMERIC(38)  NOT NULL,
                cliente_id       NUMERIC(38)  NOT NULL,
                endereco_entrega VARCHAR(512) NOT NULL,
                status           VARCHAR(15)  NOT NULL,
                CONSTRAINT envio_id PRIMARY KEY (envio_id)
);

COMMENT ON TABLE lojas.envios IS 'Tabela que contém os dados sobre os envios dos produtos.';
COMMENT ON COLUMN lojas.envios.envio_id IS 'Identificação do envio.';
COMMENT ON COLUMN lojas.envios.loja_id IS 'Identificação da loja do envio.';
COMMENT ON COLUMN lojas.envios.cliente_id IS 'Identificação do cliente para quem está sendo feito o envio.';
COMMENT ON COLUMN lojas.envios.endereco_entrega IS 'Endereço de entrega do produto.';
COMMENT ON COLUMN lojas.envios.status IS 'Status do envio.';

-- Checa se o status tem um dos valores válidos.
ALTER TABLE lojas.envios
ADD CONSTRAINT cc_validade_status_envios
CHECK (status IN ('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE'));


CREATE TABLE lojas.estoques (
                estoque_id NUMERIC(38) NOT NULL,
                loja_id    NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                quantidade NUMERIC(38) NOT NULL,
                CONSTRAINT estoque_id PRIMARY KEY (estoque_id)
);

COMMENT ON TABLE lojas.estoques IS 'Contém os dados dos estoques.';
COMMENT ON COLUMN lojas.estoques.estoque_id IS 'Identificação do estoque.';
COMMENT ON COLUMN lojas.estoques.loja_id IS 'Informa o ID do loja dona do estoque';
COMMENT ON COLUMN lojas.estoques.produto_id IS 'Indentificação do produto que está sendo estocado.';
COMMENT ON COLUMN lojas.estoques.quantidade IS 'Informa a quantidade de produtos no estoque.';

-- Garante que a quantidade do estoque não é negativa.
ALTER TABLE lojas.estoques
ADD CONSTRAINT cc_estoque_nao_negativo
CHECK (quantidade >= 0);


CREATE TABLE lojas.pedidos (
                pedido_id  NUMERIC(38) NOT NULL,
                data_hora  TIMESTAMP   NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                status     VARCHAR(15) NOT NULL,
                loja_id    NUMERIC(38) NOT NULL,
                CONSTRAINT pedido_id PRIMARY KEY (pedido_id)
);

COMMENT ON TABLE lojas.pedidos IS 'Tabela contendo os dados sobre os pedidos das lojas.';
COMMENT ON COLUMN lojas.pedidos.pedido_id IS 'Identificação do pedido.';
COMMENT ON COLUMN lojas.pedidos.data_hora IS 'Data e hora do pedido.';
COMMENT ON COLUMN lojas.pedidos.cliente_id IS 'ID do cliente que fez o pedido.';
COMMENT ON COLUMN lojas.pedidos.status IS 'Status do pedido.';
COMMENT ON COLUMN lojas.pedidos.loja_id IS 'Identifica a loja do pedido.';

-- Garante que o pedido não foi feito no futuro.
ALTER TABLE lojas.pedidos
ADD CONSTRAINT cc_data_hora_no_presente_ou_passado
CHECK (data_hora <= now());

-- Checa se o status tem um dos valores válidos.
ALTER TABLE lojas.pedidos
ADD CONSTRAINT cc_validade_status_pedidos
CHECK (status IN ('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO'));


CREATE TABLE lojas.pedidos_itens (
                pedido_id       NUMERIC(38)   NOT NULL,
                produto_id      NUMERIC(38)   NOT NULL,
                numero_da_linha NUMERIC(38)   NOT NULL,
                preco_unitario  NUMERIC(10, 2) NOT NULL,
                quantidade      NUMERIC(38)   NOT NULL,
                envio_id        NUMERIC(38),
                CONSTRAINT pedido_id__produto_id PRIMARY KEY (pedido_id, produto_id)
);

COMMENT ON TABLE lojas.pedidos_itens IS 'Tabela contendo os itens dos pedidos.';
COMMENT ON COLUMN lojas.pedidos_itens.pedido_id IS 'Informa a indentificação do pedido.';
COMMENT ON COLUMN lojas.pedidos_itens.produto_id IS 'Informa a identificação do produto do pedido.';
COMMENT ON COLUMN lojas.pedidos_itens.numero_da_linha IS 'Informa o número da linha do pedido.';
COMMENT ON COLUMN lojas.pedidos_itens.preco_unitario IS 'Informa o preço unitário do item.';
COMMENT ON COLUMN lojas.pedidos_itens.quantidade IS 'Informa a quantidade de produtos do pedido.';
COMMENT ON COLUMN lojas.pedidos_itens.envio_id IS 'Informa a indentificação do envio do pedido.';

-- Garante que o produto não vai ser gratuito (com preço igual a 0) e que o preço vai ser positivo.
ALTER TABLE lojas.pedidos_itens
ADD CONSTRAINT cc_pedidos_itens_preco_unitario_valido
CHECK (preco_unitario > 0);

-- Garante que a quantidade de itens sendo pedidos não é zero.
ALTER TABLE lojas.pedidos_itens
ADD CONSTRAINT cc_quantidade_itens_positiva
CHECK (quantidade > 0);


-- Relações entre as tabelas.
ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.estoques ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.envios ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_id)
REFERENCES lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.estoques ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.envios ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES lojas.envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES lojas.pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

