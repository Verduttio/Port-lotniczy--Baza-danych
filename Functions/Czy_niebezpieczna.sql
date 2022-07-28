--Testowe wyswietlanie pasazerow, którzy są na liscie niebezpiecznych
SELECT * FROM [Osoby niebezpieczne]
WHERE EXISTS (SELECT Pasazer.NR_Paszportu FROM Pasazer 
WHERE [Osoby niebezpieczne].NR_Paszportu = Pasazer.NR_Paszportu);

---------FUNKCJA---------
IF OBJECT_ID('dbo.Czy_niebezpieczna', 'FN') IS NOT NULL
	DROP FUNCTION dbo.Czy_niebezpieczna
GO

CREATE FUNCTION Czy_niebezpieczna (@Nr_paszportu VARCHAR(15))
RETURNS VARCHAR(3)
AS
BEGIN
	DECLARE @Ilosc BIT
	DECLARE @Out VARCHAR(3)
	SET @Ilosc = (SELECT COUNT(*) FROM [Osoby niebezpieczne]
			WHERE [Osoby niebezpieczne].NR_Paszportu = @Nr_paszportu)
	SET @Out =
		CASE @Ilosc
			WHEN 0 THEN 'NIE'
			WHEN 1 THEN 'TAK'
		END
	RETURN @Out
END
GO

SELECT dbo.Czy_niebezpieczna('PR324500')
SELECT dbo.Czy_niebezpieczna('GH565755')