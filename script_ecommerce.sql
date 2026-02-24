-- Criação do Banco de Dados
CREATE DATABASE IF NOT EXISTS EcommerceRefinado;
USE EcommerceRefinado;

-- 1. Tabela Geral de Clientes
CREATE TABLE Client (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    Address VARCHAR(255),
    ClientType ENUM('PF', 'PJ') NOT NULL
);

-- 2. Especialização: Pessoa Física
CREATE TABLE ClientPF (
    idClientPF INT PRIMARY KEY,
    FullName VARCHAR(255) NOT NULL,
    CPF CHAR(11) NOT NULL,
    CONSTRAINT unique_cpf_pf UNIQUE (CPF),
    CONSTRAINT fk_client_pf FOREIGN KEY (idClientPF) REFERENCES Client(idClient) ON DELETE CASCADE
);

-- 3. Especialização: Pessoa Jurídica
CREATE TABLE ClientPJ (
    idClientPJ INT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    CNPJ CHAR(14) NOT NULL,
    CONSTRAINT unique_cnpj_pj UNIQUE (CNPJ),
    CONSTRAINT fk_client_pj FOREIGN KEY (idClientPJ) REFERENCES Client(idClient) ON DELETE CASCADE
);

-- 4. Tabela de Produtos
CREATE TABLE Product (
    idProduct INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(50) NOT NULL,
    Category ENUM('Eletrônico', 'Vestuário', 'Brinquedos', 'Alimentos', 'Móveis') NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);

-- 5. Pedidos e Entrega
CREATE TABLE Orders (
    idOrder INT AUTO_INCREMENT PRIMARY KEY,
    idOrderClient INT,
    OrderDescription VARCHAR(255),
    SendValue FLOAT DEFAULT 10,
    OrderStatus ENUM('Cancelado', 'Confirmado', 'Em processamento') DEFAULT 'Em processamento',
    TrackingCode VARCHAR(50) UNIQUE,
    CONSTRAINT fk_orders_client FOREIGN KEY (idOrderClient) REFERENCES Client(idClient)
);

-- 6. Pagamentos (Permite múltiplas formas por pedido)
CREATE TABLE Payment (
    idPayment INT AUTO_INCREMENT PRIMARY KEY,
    idOrder INT,
    TypePayment ENUM('Boleto', 'Cartão', 'Pix'),
    ValuePaid DECIMAL(10,2),
    CONSTRAINT fk_payment_order FOREIGN KEY (idOrder) REFERENCES Orders(idOrder)
);

-- 7. Persistência de Dados (Testes)
INSERT INTO Client (Address, ClientType) VALUES 
('Rua das Flores, 10', 'PF'),
('Av. Central, 500', 'PJ'),
('Rua B, 200', 'PF');

INSERT INTO ClientPF (idClientPF, FullName, CPF) VALUES 
(1, 'Maria Silva', '12345678901'),
(3, 'Ricardo Souza', '11122233344');

INSERT INTO ClientPJ (idClientPJ, SocialName, CNPJ) VALUES 
(2, 'Tech Solutions LTDA', '98765432100012');

INSERT INTO Product (Pname, Category, Price) VALUES 
('Smartphone', 'Eletrônico', 1500.00),
('Monitor 4K', 'Eletrônico', 2200.00),
('Cadeira Gamer', 'Móveis', 950.00),
('Teclado Mecânico', 'Eletrônico', 300.00);

INSERT INTO Orders (idOrderClient, OrderDescription, SendValue, OrderStatus, TrackingCode) VALUES 
(1, 'Compra de eletrônicos', 15.00, 'Confirmado', 'TRK123456BR'),
(2, 'Equipamento de escritório', 50.00, 'Confirmado', 'TRK987654BR'),
(3, 'Acessórios', 10.00, 'Em processamento', 'TRK000111BR');

INSERT INTO Payment (idOrder, TypePayment, ValuePaid) VALUES 
(1, 'Pix', 1515.00),
(2, 'Cartão', 1000.00),
(2, 'Boleto', 1250.00),
(3, 'Pix', 310.00);

-- QUERIES PARA DESAFIO

-- 1. Recuperação simples: Lista de Clientes e seus tipos
SELECT * FROM Client;

-- 2. Filtro + Expressão (Atributo Derivado): Valor total do pedido com frete
SELECT idOrder, (SendValue + 100) as Total_Estimado FROM Orders; 

-- 3. Ordenação: Produtos por preço decrescente
SELECT * FROM Product ORDER BY Price DESC;

-- 4. Condição de Grupo (HAVING): Clientes que gastaram mais de 1000 no total
SELECT idOrderClient, SUM(ValuePaid) as TotalGastos
FROM Payment P
JOIN Orders O ON P.idOrder = O.idOrder
GROUP BY idOrderClient
HAVING TotalGastos > 1000;

-- 5. Junção Complexa: Nome do Cliente, Status do Pedido e Forma de Pagamento
SELECT 
    COALESCE(PF.FullName, PJ.SocialName) as Nome_Cliente,
    O.idOrder,
    O.OrderStatus,
    P.TypePayment
FROM Client C
LEFT JOIN ClientPF PF ON C.idClient = PF.idClientPF
LEFT JOIN ClientPJ PJ ON C.idClient = PJ.idClientPJ
JOIN Orders O ON C.idClient = O.idOrderClient
JOIN Payment P ON O.idOrder = P.idOrder;
