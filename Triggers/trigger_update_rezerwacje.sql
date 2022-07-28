IF OBJECT_ID('Tr_AU_rezerwacja','TR') IS NOT NULL
DROP TRIGGER Tr_AU_rezerwacja
GO 
CREATE TRIGGER Tr_AU_rezerwacja ON Rezerwacje
AFTER UPDATE
AS
	DECLARE @Id_pasazera INT = (SELECT Id_pasazera FROM Deleted)
	DECLARE @Id_rezerwacji INT = (SELECT Id_rezerwacji FROM Deleted)
	DECLARE @Id_starego_lotu INT = (SELECT Id_lotu FROM Deleted)
	
	--dane zaktualizowanej rezerwacji
	DECLARE @Id_nowego_lotu INT = (SELECT Id_lotu FROM Rezerwacje
								WHERE Id_Rezerwacji = @Id_rezerwacji)
	DECLARE @Data_nowego_lotu DATETIME = (SELECT Data FROM Loty
									JOIN Rezerwacje ON Rezerwacje.Id_lotu = Loty.Id_lotu
									WHERE Rezerwacje.Id_lotu = @Id_nowego_lotu)
	--sprawdzenie czy data nowego lotu nie koliduje z innymi rezerwacjami danego pasazera
	--przyjmujemy, że data nie koliduje gdy odstępy między lotami wynoszą przynajmniej 4 godziny
	DECLARE @Ilosc_lotow INT -- ilosc lotow danego pasazera w przedziale 4 godzinnym wzgledem zaktualizowanej rezerwacji
	SET @Ilosc_lotow = (SELECT COUNT(*) FROM Rezerwacje
						JOIN Loty ON Loty.Id_lotu = Rezerwacje.Id_lotu
						WHERE Id_pasazera = @Id_pasazera
						AND Data < DATEADD(HOUR, 4, @Data_nowego_lotu)
						AND Data > DATEADD(HOUR, -4, @Data_nowego_lotu))
	IF (@Ilosc_lotow <> 1) BEGIN
		PRINT('Dany pasazer ma juz rezerwacje na lot w tym samym czasie')
		--zatem przywracamy rezerwacje
		UPDATE Rezerwacje
		SET Id_lotu = @Id_starego_lotu
		WHERE Id_Rezerwacji = @Id_rezerwacji
	END
GO
---

INSERT INTO Rezerwacje VALUES 
(42, 1005, 1, 1)

UPDATE Rezerwacje
SET Id_lotu = 1002
WHERE Id_rezerwacji = 42

DELETE FROM Rezerwacje
WHERE Id_rezerwacji = 42