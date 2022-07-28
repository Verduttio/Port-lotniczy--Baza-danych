IF OBJECT_ID('TR_dodaj_lot', 'TR') IS NOT NULL
	DROP TRIGGER TR_dodaj_lot
GO

CREATE TRIGGER TR_dodaj_lot ON Loty
INSTEAD OF INSERT
AS
BEGIN TRY
	DECLARE @Id_lotu INT
	DECLARE @Id_samolotu INT
	DECLARE @Dokad INT = NULL
	DECLARE @Skad INT = NULL
	DECLARE @Id_terminalu NVARCHAR(1)
	DECLARE @Nr_bramki INT
	DECLARE @Data DATETIME
	DECLARE @Typ_lotu NVARCHAR(10)

	DECLARE @Counter INT = 0
	DECLARE @RowsAmount INT = (SELECT COUNT(*) FROM INSERTED)

	WHILE @Counter < @RowsAmount BEGIN
		SET @Id_lotu = (SELECT Id_lotu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Id_samolotu = (SELECT Id_samolotu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Dokad = (SELECT Dokad FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Skad = (SELECT Skad FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Id_terminalu = (SELECT Id_terminalu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Nr_bramki = (SELECT Nr_bramki FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Data = (SELECT Data FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Typ_lotu = (SELECT Typ_lotu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)

		IF (@Id_lotu < 0) BEGIN
			RAISERROR('Id_lotu jest liczba ujemna. Nie dodano lotu', 16, 1)
		END

		IF (EXISTS (SELECT Id_lotu FROM Loty WHERE Id_lotu = @Id_lotu)) BEGIN
			RAISERROR('Lot o id %i juz istnieje.', 16,1,@Id_lotu)
		END

		IF (NOT EXISTS (SELECT Id_samolotu FROM Samoloty WHERE Id_samolotu = @Id_samolotu)) BEGIN
			RAISERROR('Samolot o id %i nie istnieje', 16,1,@Id_samolotu)
		END

		IF (@Data > (SELECT Do_kiedy FROM Umowy_z_przewoznikami
					INNER JOIN Samoloty ON Samoloty.Id_przewoznika = Umowy_z_przewoznikami.Id_przewoznika
					WHERE Id_samolotu = @Id_samolotu)) BEGIN
			RAISERROR('Umowa z przewoznikiem danego samolotu jest juz niewazna', 16, 1)
		END

		IF (NOT EXISTS (SELECT * FROM Bramki WHERE Id_terminalu = @Id_terminalu AND Nr_bramki = @Nr_bramki)) BEGIN
			RAISERROR('Nie ma bramki nr %i w terminalu %s', 16, 1, @Nr_bramki, @Id_terminalu)
		END

		--sprawdzanie czy bramka nie bedzie zajeta w tym czasie
		--czas potrzebny na obsluge samolotu przy bramce wynosi 30 minut
		DECLARE @Potential_flights INT = (SELECT COUNT(*)
		FROM Loty
		WHERE Id_terminalu = @Id_terminalu
		AND Nr_bramki = @Nr_bramki AND Id_lotu <> @Id_lotu
		AND Data > DATEADD(MINUTE, -30, @Data) AND Data < DATEADD(MINUTE, 30, @Data))
		IF (@Potential_flights > 0) BEGIN
		RAISERROR('Kolizja z bramkami. Nie wystarczająca ilość czasu na obsługę samolotu przy bramce', 16, 1)
		END

		IF (@Dokad IS NOT NULL) BEGIN
			IF (@Dokad NOT BETWEEN 1 AND 22) BEGIN
				RAISERROR('Miasto o id %i nie istnieje', 16, 1, @Dokad)
			END
			--teraz sprawdzanie czy dany samolot moze leciec do danego panstwa
			IF(NOT EXISTS (SELECT * FROM Cennik_lotow
							INNER JOIN Samoloty ON (Samoloty.Id_przewoznika = Cennik_lotow.Id_przewoznika)
							WHERE (Dokad = @Dokad AND Id_samolotu = @Id_samolotu)) ) BEGIN
				RAISERROR('Samolot o id %i nie lata do lotniska o id %i.', 16, 1, @Id_samolotu, @Dokad)
			END
		END

		IF (@Skad IS NOT NULL) BEGIN
			IF (@Skad NOT BETWEEN 1 AND 22) BEGIN
				RAISERROR('Miasto o id %i nie istnieje', 16, 1, @Skad)
			END
		END


		IF (@Data < CURRENT_TIMESTAMP) BEGIN
			RAISERROR('Wprowadzona data juz minela, nie mozna dodac lotu "do przeszlosci"', 16, 1)
		END

		DECLARE @DateVARCHAR VARCHAR(30) = CAST(@Data AS VARCHAR)

		IF (SELECT dbo.Czy_samolot_na_lotnisku(@Id_samolotu, @Data)) = 'NIE' BEGIN
			RAISERROR('Samolot o id %i, nie przebywa na naszym lotnisku w dniu %s', 16,1, @Id_samolotu, @DateVARCHAR)
		END

		SET @Counter += 1

		INSERT INTO Loty VALUES
		(@Id_lotu, @Id_samolotu, @Dokad, @Skad, @Id_terminalu, @Nr_bramki, @Data, @Typ_lotu)

		PRINT('Dodano lot nr' + CONVERT(VARCHAR(10), @Id_lotu))

	END
END TRY
BEGIN CATCH
SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
END CATCH
GO	
--------
SELECT * FROM Loty

INSERT INTO Loty VALUES
(1035, 97, 7, NULL, 'A', 2, '2021-03-10 10:00', 'Odlot'),
(1036, 4, 1, NULL, 'A', 2, '2021-02-10 12:00', 'Odlot')

INSERT INTO Loty VALUES
(1035, 97, 6, NULL, 'A', 2, '2021-01-31 10:50', 'Odlot'),
(1036, 4, 1, NULL, 'A', 2, '2021-02-10 12:00', 'Odlot')

DELETE FROM Loty
WHERE Id_lotu = 1035

DELETE FROM Loty
WHERE Id_lotu = 1036