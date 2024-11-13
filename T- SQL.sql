
USE CasernePompier1
GO

--TRIGGERS:

SELECT COLUMN_NAME,ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Pompier';
GO
--- Création d'un trigger qui empêche la mise à jour du nom et prenom du pompier
CREATE OR ALTER TRIGGER TRG_Pompier_UPDATE
ON Pompier AFTER UPDATE
AS
  IF (COLUMNS_UPDATED() & 6) > 0
  BEGIN
    RAISERROR ('Impossible de modifier le nom ou le prenom du popmier.',16,1)
    ROLLBACK TRANSACTION
  END;

UPDATE Pompier 
SET Nom = 'Kail' 
WHERE NAS = '109876543';
GO

--Trigger pour eviter la mis a jour d'AvoirHoraire
CREATE OR ALTER TRIGGER trg_Warning
ON AvoirHoraire INSTEAD OF UPDATE
AS
	IF(COLUMNS_UPDATED() & 1) > 0
BEGIN 
	RAISERROR('l''horaire ne peut pas etre modifie', 16, 1);
	RETURN; 
END;


UPDATE AvoirHoraire 
SET id_Equipe = 'E8'
WHERE id_Equipe = 'E10';
GO

--PROCEDURES 

-- Création de la procédure stockée insertionIncendie qui insere les donnés d'un incendie dans la table incendie
create procedure insertionIncendie
(-- Liste des paramètres
    @id_incendie VARCHAR(3), 
    @classification VARCHAR(50),
    @type VARCHAR(50),
    @niveau_risque VARCHAR(20),
	@adresse VARCHAR(100),
	@id_secteur VARCHAR(10)
)
AS
begin  
    insert into Incendie(id_incendie , classification , type ,niveau_risque ,adresse , id_secteur )
    values (@id_incendie , @classification ,@type ,@niveau_risque, @adresse, @id_secteur);
end;

-- Appel 
execute insertionIncendie
    @id_incendie ='I11', 
    @classification='Incendie de Batiment Commercial ',
    @type ='centre commercial de moins de 45 commerces ',
    @niveau_risque =' Risque élevé',
	@adresse ='Mail Champlain,2151 Boul. Lapiniere, Brossard, QC',
	@id_secteur ='S3';
GO

--SELECT * FROM Incendie;

--procedure qui cherche le nom et prenom d'un pompier avec son NAS
create or alter procedure ChercherPompier
(
    @NAS VARCHAR(10)
)
AS
begin
    select Nom, Prenom from Pompier where @NAS = NAS;
end;
GO

---Exécution
execute ChercherPompier
@NAS= '890123446';
GO


--Fonction qui cherche les incendies dont un pompier specifique a repondu 
CREATE OR ALTER FUNCTION ReponduIncendie(@NasP Varchar(10))
RETURNS TABLE
AS RETURN (
	SELECT DISTINCT Nom, Prenom, I.id_incendie, Nom_secteur, Date_incendie 
	FROM Pompier P	
	INNER JOIN
	RépondreIncendie Rp ON Rp.id_Equipe = P.id_Equipe
	INNER JOIN 
	Incendie I ON I.id_incendie = Rp.id_incendie
	INNER JOIN 
	Secteur S ON S.id_secteur = I.id_secteur
	WHERE NAS = @NasP);
GO

--Declaration du parametre
DECLARE @NASPompier varchar(10);
SET @NASPompier = '210987657';

--Appel de la fonction 
SELECT * FROM ReponduIncendie(@NASPompier);