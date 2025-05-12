USE MASTER
GO
DROP DATABASE IF EXISTS Graph
GO
CREATE DATABASE Graph
GO
USE Graph
GO



CREATE TABLE Player (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Coach (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Trophy (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;


CREATE TABLE PlayedTogether AS EDGE;

CREATE TABLE Coached AS EDGE;

CREATE TABLE WonTrophy AS EDGE;




INSERT INTO Player (id, name) VALUES
(1, 'Криштиану Роналду'),
(2, 'Лионель Месси'),
(3, 'Винисиус Жуниор'),
(4, 'Усман Дембеле'),
(5, 'Эрлинг Холланд'),
(6, 'Киллиан Мбаппе'),
(7, 'Ламин Ямаль'),
(8, 'Роберт Левандовски');


INSERT INTO Coach (id, name) VALUES
(1, 'Пеп Гвардиола'),
(2, 'Юрген Клопп'),
(3, 'Луис Энрике'),
(4, 'Жозе Мауринью'),
(5, 'Карло Анчелотти'),
(6, 'Ханси Флик');


INSERT INTO Trophy (id, name) VALUES
(1, 'Лига чемпионов'),
(2, 'Золотой мяч'),
(3, 'Премия Пушкаша'),
(4, 'Чемпионат мира');


-- Месси и Мбаппе
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Player WHERE id = 6)),
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 2));

-- Мбаппе и Винисиус
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 3)),
((SELECT $node_id FROM Player WHERE id = 3), (SELECT $node_id FROM Player WHERE id = 6));

-- Мбаппе и Дембеле
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 4)),
((SELECT $node_id FROM Player WHERE id = 4), (SELECT $node_id FROM Player WHERE id = 6));

-- Ямаль и Левандовски
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 7), (SELECT $node_id FROM Player WHERE id = 8)),
((SELECT $node_id FROM Player WHERE id = 8), (SELECT $node_id FROM Player WHERE id = 7));




-- Гвардиола тренировал:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 1), (SELECT $node_id FROM Player WHERE id = 5)), 
((SELECT $node_id FROM Coach WHERE id = 1), (SELECT $node_id FROM Player WHERE id = 2)), 
((SELECT $node_id FROM Coach WHERE id = 1), (SELECT $node_id FROM Player WHERE id = 8)); 

-- Клопп тренировал Левандовски
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 2), (SELECT $node_id FROM Player WHERE id = 8));

-- Луис Энрике тренировал:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 3), (SELECT $node_id FROM Player WHERE id = 2)),
((SELECT $node_id FROM Coach WHERE id = 3), (SELECT $node_id FROM Player WHERE id = 4));

-- Мауринью тренировал Роналду
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 4), (SELECT $node_id FROM Player WHERE id = 1));

-- Анчелотти тренировал:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 5), (SELECT $node_id FROM Player WHERE id = 1)),
((SELECT $node_id FROM Coach WHERE id = 5), (SELECT $node_id FROM Player WHERE id = 3)),
((SELECT $node_id FROM Coach WHERE id = 5), (SELECT $node_id FROM Player WHERE id = 6));

-- Флик тренировал:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 7)),
((SELECT $node_id FROM Coach WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 8));




-- Криштиану Роналду
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 1), (SELECT $node_id FROM Trophy WHERE id = 1)),
((SELECT $node_id FROM Player WHERE id = 1), (SELECT $node_id FROM Trophy WHERE id = 2)),
((SELECT $node_id FROM Player WHERE id = 1), (SELECT $node_id FROM Trophy WHERE id = 3));

-- Лионель Месси
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Trophy WHERE id = 1)),
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Trophy WHERE id = 2)),
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Trophy WHERE id = 4)); 

-- Киллиан Мбаппе
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Trophy WHERE id = 4));

-- Роберт Левандовски
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 8), (SELECT $node_id FROM Trophy WHERE id = 1));

-- Эрлинг Холланд
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 5), (SELECT $node_id FROM Trophy WHERE id = 1));

-- Усман Дембеле
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 4), (SELECT $node_id FROM Trophy WHERE id = 4));

-- Винисиус Жуниор
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 3), (SELECT $node_id FROM Trophy WHERE id = 1));



SELECT T.name 
FROM Player P, WonTrophy WT, Trophy T
WHERE MATCH(P-(WT)->T)
AND P.name = 'Криштиану Роналду';

SELECT P.name
FROM Player P
WHERE NOT EXISTS (
    SELECT 1 
    FROM WonTrophy WT
    WHERE WT.$from_id = P.$node_id
);

SELECT P.name AS player_name
FROM Coach C, Coached CH, Player P
WHERE MATCH(C-(CH)->P)
AND C.name = 'Пеп Гвардиола';

SELECT P.name AS player_name
FROM Player P, WonTrophy WT, Trophy T
WHERE MATCH(P-(WT)->T)
AND T.name = 'Золотой мяч';

SELECT P2.name AS player_name
FROM Player P1, PlayedTogether PT, Player P2
WHERE MATCH(P1-(PT)->P2)
AND P1.name = 'Киллиан Мбаппе';





SELECT
    T.Name AS Coach,
    STRING_AGG(P.Name, ' -> ') WITHIN GROUP (GRAPH PATH) AS PlayersPath
FROM
    Coach AS T,
    Coached FOR PATH AS cd,
    Player FOR PATH AS P
WHERE
    MATCH(SHORTEST_PATH(T(-(cd)->P)+))
    AND T.Name = 'Карло Анчелотти';

SELECT
    P1.name AS Player1,
    P2.name AS Player2,
    T.name AS CommonTrophy
FROM
    Player AS P1,
    Player AS P2,
    Trophy AS T,
    WonTrophy AS WT1,
    WonTrophy AS WT2
WHERE
    MATCH(P1-(WT1)->T<-(WT2)-P2)
    AND P1.id = 2 
    AND P1.id <> P2.id



  select @@servername

