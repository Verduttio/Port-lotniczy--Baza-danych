IF OBJECT_ID('dbo.vw_przebieg_samolotow', 'V') IS NOT NULL
	DROP VIEW dbo.vw_przebieg_samolotow
GO
CREATE VIEW vw_przebieg_samolotow AS
	SELECT Samoloty.Id_samolotu, COUNT(Id_lotu) AS Przebieg, Marka, Model, Nazwa FROM Samoloty
	LEFT JOIN Loty ON Loty.Id_samolotu = Samoloty.Id_samolotu
	INNER JOIN Przewoznicy ON Przewoznicy.Id_przewoznika = Samoloty.Id_przewoznika
	GROUP BY Samoloty.Id_samolotu, Marka, Model, Nazwa
GO

SELECT * FROM dbo.vw_przebieg_samolotow