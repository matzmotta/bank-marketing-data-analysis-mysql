/*
BANK MARKETING DATA ANALYSIS

Este projeto tem como objetivo analisar o comportamento de clientes
em campanhas de marketing de um banco, buscando identificar perfis
com maior probabilidade de aceitação de produtos financeiros.

A base contém informações sobre clientes de um banco e interações
em campanhas de marketing telefônico para oferta de depósitos a prazo.

Principais variáveis analisadas:

- age (idade)
- job (profissão)
- marital (estado civil)
- loan (empréstimo pessoal)
- campaign (número de vezes que o cliente foi contatado durante a campanha)
- euribor3m (taxa de juros Euribor de 3 meses)
- y (aceitação do produto)
*/


-- 1. Qual é o perfil geral dos clientes do banco?
-- (idade média e média da taxa de juros em 3 meses)

SELECT 
    ROUND(AVG(age), 1) AS media_idade,
    ROUND(AVG(euribor3m), 2) AS taxa_media_juros
FROM bank;

/*
A consulta permite identificar a idade média dos clientes e contextualizar
o cenário econômico no momento da campanha.

A taxa média de juros de 3,62% sugere um ambiente de juros moderados
durante o período analisado.
*/


-- 2. Quais profissões têm maior taxa de aceitação do produto bancário?

SELECT 
    job AS profissao,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS clientes_aceitaram,
    SUM(CASE WHEN y = 'no' THEN 1 ELSE 0 END) AS clientes_negaram
FROM bank
GROUP BY job
ORDER BY clientes_aceitaram DESC;


-- 3. Quais são as profissões mais comuns entre os clientes do banco?

SELECT 
    job AS profissao,
    COUNT(*) AS total_clientes
FROM bank
GROUP BY job
ORDER BY total_clientes DESC
LIMIT 5;

/*
As cinco profissões mais comuns entre os clientes são:
Administrativo (admin),
Operacional (blue-collar),
Técnico (technician),
Serviços (services),
Gestão/gerência (management).
*/


-- 4. Clientes com empréstimo pessoal aceitam mais ou menos o produto?

SELECT 
    loan AS emprestimo_pessoal,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS aceitaram_produto,
    SUM(CASE WHEN y = 'no' THEN 1 ELSE 0 END) AS recusaram_produto,
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1
    ) AS percentual_aceitacao
FROM bank
WHERE loan <> 'unknown'
GROUP BY loan
ORDER BY percentual_aceitacao DESC;

/*
Os resultados indicam que clientes sem empréstimo pessoal apresentam
uma leve tendência maior de aceitar o produto.

Entretanto, como a diferença é relativamente pequena, o fator
"empréstimo pessoal" isoladamente não parece ser um forte preditor
de aceitação.
*/


-- 5. Qual é a taxa geral de clientes que aceitaram o produto?

SELECT
    COUNT(*) AS total_clientes,
    SUM(y = 'yes') AS aceitaram,
    ROUND(AVG(y = 'yes') * 100, 1) AS taxa_aceitacao
FROM bank;

/*
De acordo com a consulta, aproximadamente 11,3% dos clientes
aceitaram o produto oferecido na campanha.
*/


-- 6. Qual faixa etária mais aceita o depósito oferecido?

SELECT
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS faixa_etaria,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS aceitaram_produto,    
    ROUND(SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS percentual_aceitacao

FROM bank
GROUP BY faixa_etaria
ORDER BY percentual_aceitacao DESC;

/*
Os resultados indicam que clientes com 60 anos ou mais apresentam
a maior taxa de aceitação do produto, sugerindo que esse público
pode ser um foco estratégico para futuras campanhas.

Em seguida aparecem os clientes entre 18 e 29 anos.
*/

-- 7. O estado civil influencia na aceitação do produto?

SELECT
    marital,
    COUNT(*) AS total_clientes,
	SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS aceitaram_produto,
    ROUND(
	SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1
    ) AS percentual_aceitacao
FROM bank
WHERE marital <> 'unknown'
GROUP BY marital
ORDER BY percentual_aceitacao DESC;

/*
Clientes solteiros apresentam maior taxa de aceitação
em comparação com clientes casados ou divorciados.

Uma possível explicação é que esse grupo pode possuir
menos responsabilidades financeiras e maior flexibilidade
para aderir a novos produtos bancários.
*/


-- 8. Quais perfis de clientes foram mais contatados nas campanhas?

SELECT
    job AS profissao,    
    ROUND(AVG(campaign), 2) AS media_contatos,
    SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) AS aceitaram,    
    ROUND(
        SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1
    ) AS taxa_aceitacao,

RANK() OVER(
        ORDER BY
        ROUND(
            SUM(CASE WHEN y = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1
        ) DESC
    ) AS ranking_aceitacao

FROM bank
WHERE job <> 'unknown'
GROUP BY job
ORDER BY ranking_aceitacao ASC;

/*
Clientes desempregados e estudantes apresentam a maior média
de contatos durante as campanhas.

No entanto, a taxa de aceitação não acompanha necessariamente
esse volume de tentativas, o que pode indicar uma possível
ineficiência na segmentação da campanha.
*/