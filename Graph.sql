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
(1, '��������� �������'),
(2, '������� �����'),
(3, '�������� ������'),
(4, '����� �������'),
(5, '������ �������'),
(6, '������� ������'),
(7, '����� �����'),
(8, '������ �����������');


INSERT INTO Coach (id, name) VALUES
(1, '��� ���������'),
(2, '����� �����'),
(3, '���� ������'),
(4, '���� ��������'),
(5, '����� ���������'),
(6, '����� ����');


INSERT INTO Trophy (id, name) VALUES
(1, '���� ���������'),
(2, '������� ���'),
(3, '������ �������'),
(4, '��������� ����');


-- ����� � ������
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Player WHERE id = 6)),
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 2));

-- ������ � ��������
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 3)),
((SELECT $node_id FROM Player WHERE id = 3), (SELECT $node_id FROM Player WHERE id = 6));

-- ������ � �������
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 4)),
((SELECT $node_id FROM Player WHERE id = 4), (SELECT $node_id FROM Player WHERE id = 6));

-- ����� � �����������
INSERT INTO PlayedTogether ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Player WHERE id = 7), (SELECT $node_id FROM Player WHERE id = 8)),
((SELECT $node_id FROM Player WHERE id = 8), (SELECT $node_id FROM Player WHERE id = 7));




-- ��������� ����������:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 1), (SELECT $node_id FROM Player WHERE id = 5)), 
((SELECT $node_id FROM Coach WHERE id = 1), (SELECT $node_id FROM Player WHERE id = 2)), 
((SELECT $node_id FROM Coach WHERE id = 1), (SELECT $node_id FROM Player WHERE id = 8)); 

-- ����� ���������� �����������
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 2), (SELECT $node_id FROM Player WHERE id = 8));

-- ���� ������ ����������:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 3), (SELECT $node_id FROM Player WHERE id = 2)),
((SELECT $node_id FROM Coach WHERE id = 3), (SELECT $node_id FROM Player WHERE id = 4));

-- �������� ���������� �������
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 4), (SELECT $node_id FROM Player WHERE id = 1));

-- ��������� ����������:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 5), (SELECT $node_id FROM Player WHERE id = 1)),
((SELECT $node_id FROM Coach WHERE id = 5), (SELECT $node_id FROM Player WHERE id = 3)),
((SELECT $node_id FROM Coach WHERE id = 5), (SELECT $node_id FROM Player WHERE id = 6));

-- ���� ����������:
INSERT INTO Coached ($from_id, $to_id)
VALUES
((SELECT $node_id FROM Coach WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 7)),
((SELECT $node_id FROM Coach WHERE id = 6), (SELECT $node_id FROM Player WHERE id = 8));




-- ��������� �������
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 1), (SELECT $node_id FROM Trophy WHERE id = 1)),
((SELECT $node_id FROM Player WHERE id = 1), (SELECT $node_id FROM Trophy WHERE id = 2)),
((SELECT $node_id FROM Player WHERE id = 1), (SELECT $node_id FROM Trophy WHERE id = 3));

-- ������� �����
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Trophy WHERE id = 1)),
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Trophy WHERE id = 2)),
((SELECT $node_id FROM Player WHERE id = 2), (SELECT $node_id FROM Trophy WHERE id = 4)); 

-- ������� ������
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 6), (SELECT $node_id FROM Trophy WHERE id = 4));

-- ������ �����������
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 8), (SELECT $node_id FROM Trophy WHERE id = 1));

-- ������ �������
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 5), (SELECT $node_id FROM Trophy WHERE id = 1));

-- ����� �������
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 4), (SELECT $node_id FROM Trophy WHERE id = 4));

-- �������� ������
INSERT INTO WonTrophy ($from_id, $to_id) VALUES
((SELECT $node_id FROM Player WHERE id = 3), (SELECT $node_id FROM Trophy WHERE id = 1));



SELECT T.name 
FROM Player P, WonTrophy WT, Trophy T
WHERE MATCH(P-(WT)->T)
AND P.name = '��������� �������';

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
AND C.name = '��� ���������';

SELECT P.name AS player_name
FROM Player P, WonTrophy WT, Trophy T
WHERE MATCH(P-(WT)->T)
AND T.name = '������� ���';

SELECT P2.name AS player_name
FROM Player P1, PlayedTogether PT, Player P2
WHERE MATCH(P1-(PT)->P2)
AND P1.name = '������� ������';





SELECT
    T.Name AS Coach,
    STRING_AGG(P.Name, ' -> ') WITHIN GROUP (GRAPH PATH) AS PlayersPath
FROM
    Coach AS T,
    Coached FOR PATH AS cd,
    Player FOR PATH AS P
WHERE
    MATCH(SHORTEST_PATH(T(-(cd)->P)+))
    AND T.Name = '����� ���������';

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

