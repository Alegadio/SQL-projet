use CasernePompier1
go

--1) INCENDIES SUBIS PAR BROSSARD ET SES DATES
SELECT DISTINCT I.id_incendie, I.adresse, RI.Date_incendie
FROM Incendie I
INNER JOIN Secteur S ON I.id_secteur = S.id_secteur
INNER JOIN RépondreIncendie RI ON I.id_incendie = RI.id_incendie
WHERE S.Nom_secteur = 'Brossard';

--2) Nom et prenom de pompiers de la Caserne 2
SELECT P.Nom, P.Prenom, C.id_caserne FROM Equipe E
INNER JOIN 
Caserne C ON C.id_caserne = E.id_caserne
INNER JOIN 
Pompier P ON P.id_Equipe = E.id_Equipe
WHERE 
C.id_caserne = 'C2';

-- 3) Les equipements qui ont pas passé l'inspection et la Caserne dont ils appartient  
SELECT id_Equipement, Description_Equipement, id_caserne FROM Equipement
WHERE 
Resultat_inspection = 'Reprouvé';

-- 4) Les vehicules qui sont pas disponibles, le nom de leur secteur et la Caserne dont ils appartient
SELECT V.type, S.Nom_secteur, C.id_caserne FROM Vehicule V
INNER JOIN 
Caserne C on C.id_caserne = V.id_caserne
INNER JOIN 
Secteur S ON S.id_caserne = C.id_caserne
WHERE 
V.Disponibilité = 0;

--5) le nom et prenom  des Caporal qui peuvent intervenir lors d'une incendie dans le secteur LeMoyne
SELECT p.Nom, p.Prenom
FROM Pompier p
INNER JOIN Equipe e ON p.id_Equipe = e.id_Equipe
INNER JOIN Caserne c ON e.id_caserne = c.id_caserne
INNER JOIN Secteur s ON c.id_caserne = s.id_caserne
WHERE p.Grade = 'Caporal'
AND s.Nom_secteur = 'LeMoyne';

-- 6) déterminer le nom, prénom et le grade des pompiers qui ont participé à l'incendie déclaré la nuit du 2023-07-07
SELECT DISTINCT p.Nom, p.Prenom, p.Grade,  i.adresse AS Adresse_Incendie, i.niveau_risque ,  e.id_Equipe
FROM Incendie i
INNER JOIN RépondreIncendie ri ON i.id_incendie = ri.id_incendie
INNER JOIN Equipe e ON ri.id_Equipe = e.id_Equipe
INNER JOIN AvoirHoraire ah ON e.id_Equipe = ah.id_Equipe
INNER JOIN Horaire h ON ah.id_horaire = h.id_horaire
INNER JOIN Pompier p ON p.id_Equipe = e.id_Equipe
WHERE CONVERT(date, ri.Date_incendie) = '2023-07-07'
  AND h.quart_travail = 'Jour' ORDER BY e.id_Equipe;


-- 7)determiner l'equipe qui a aider pour l'incendie deroule a l'adresse 'Mail Champlain,2151 Boul. Lapini?re, Brossard, QC' et qui etait de risque tres eleve 
--On a les equipes  E11 , E12 et E8 qui ont repondu a l'incendie l'adresse 'Mail Champlain,2151 Boul. Lapinière, Brossard, QC' et qui etait --de risque tres eleve  (I5 dans S3 couvert par C3) 
--Alors que les equipes qui sont censees repondre a cette incendie c'est ceux qui sont affectees a la caserne C3 (E9, E10,E11 et E12)
--Donc E8 qui a aide pour cette incendie

SELECT E.id_Equipe
FROM Equipe E
INNER JOIN RépondreIncendie RI ON RI.id_Equipe = E.id_Equipe 
INNER JOIN Incendie I ON RI.id_incendie = I.id_incendie 
WHERE I.adresse = 'Mail Champlain,2151 Boul. Lapinière, Brossard, QC'
AND  I.niveau_risque ='Risque très élevé'
AND NOT EXISTS (
    SELECT 1
    FROM Caserne C
    INNER JOIN Secteur S ON C.id_caserne = S.id_caserne
    WHERE S.id_secteur = I.id_secteur
    AND E.id_caserne = C.id_caserne
);

-- 8)le nom et prenom des pompiers et le id de leur Equipe et caserne qui travaillent le quart de jour pour la journée 2023/07/03
SELECT Pompier.Nom, Pompier.Prenom, Pompier.id_Equipe, Equipe.id_caserne 
FROM Pompier
INNER JOIN Equipe ON Equipe.id_Equipe = Pompier.id_Equipe
INNER JOIN AvoirHoraire ON Equipe.id_Equipe = AvoirHoraire.id_Equipe
where AvoirHoraire.id_horaire IN (SELECT id_horaire From Horaire WHERE journée = '2023-07-03' AND quart_travail = 'Jour')
ORDER BY Equipe.id_caserne;

-- 9)le nom et prenom des pompiers qui interviennent dans les incendies dont niveau de risque est faible 
SELECT Pompier.Nom, Pompier.Prenom, RépondreIncendie.id_incendie FROM Pompier
INNER JOIN Equipe ON Equipe.id_Equipe = Pompier.id_Equipe
INNER JOIN RépondreIncendie ON Equipe.id_Equipe = RépondreIncendie.id_Equipe
WHERE RépondreIncendie.id_incendie IN (select id_incendie FROM Incendie WHERE niveau_risque = 'Risque faible'); 

-- 10)le nombre d'Auxiliaire qui travaillent pour le secteur de Longueuil*/
Select COUNT(case when Grade = 'Auxiliaire' then 1 else null end) AS nombre_auxiliaire FROM Pompier
INNER JOIN Equipe ON Equipe.id_Equipe = Pompier.id_Equipe
INNER JOIN Caserne ON Caserne.id_caserne = Equipe.id_caserne
WHERE Caserne.id_caserne IN (SELECT Secteur.id_caserne FROM Secteur WHERE Secteur.Nom_secteur = 'Longueuil');

-- 11)le nombre de véhicules dont le résultat de l'inspection reprouvés des casernes qui couvrent des secteurs qui ont subi des incendies dont le niveau de risque est élevé.
-- Afficher le nom des secteurs, le id et l'addresse de la caserne et le nombre de véhicules reprouvés
select count(case when Vehicule.resultat_inspection = 'Reprouvé' then Vehicule.quantité else null end ) AS nombre_vehicule_reprouvé, Vehicule.id_caserne,
Secteur.Nom_secteur, Caserne.Adresse
FROM Vehicule
INNER JOIN Caserne ON Caserne.id_caserne = Vehicule.id_caserne 
INNER JOIN Secteur ON Secteur.id_caserne = Vehicule.id_caserne
where Secteur.id_secteur IN (SELECT Incendie.id_Secteur FROM Incendie WHERE Incendie.niveau_risque = 'Risque élevé')
GROUP BY Vehicule.id_caserne, Caserne.Adresse, Secteur.Nom_secteur
ORDER BY nombre_vehicule_reprouvé DESC;

-- 12)mettre à jour le numéro de téléphone d'une caserne
UPDATE Caserne 
SET Num_tel = '450987654' 
WHERE id_caserne = 'C1'

--13)Insérer une équipe dans une caserne
--INSERT INTO Equipe (id_caserne, id_Equipe) VALUES ('C1', 'E20')

--14)Enlever un pompier selon son NAS
Delete from Pompier where NAS = '123456789'

--15)trouver le id et le nom du secteur couvert par id caserne
Select id_secteur, Nom_secteur from Secteur where id_caserne = 'C1'

--16)trouver le id des équipes qui appartient à une caserne
SELECT id_equipe from Equipe where id_caserne ='C1'


--17)Trouver le nom et prénom des pompiers qui travaillent pour une équipe
Select * from Pompier where id_equipe = 'E2'

--18)trouver le id des équipe qui travaillent le jour le 07-07-2023
select id_equipe, Horaire.journée, Horaire.quart_travail from AvoirHoraire inner join Horaire ON Horaire.id_horaire = AvoirHoraire.id_horaire
where AvoirHoraire.id_horaire IN (select Horaire.id_horaire from Horaire where Horaire.journée = '2023-07-07' AND quart_travail = 'jour')