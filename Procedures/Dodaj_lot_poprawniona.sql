IF OBJECT_ID('Dodaj_lot', 'P') IS NOT NULL
	DROP PROC Dodaj_lot
GO

CREATE PROC Dodaj_lot (
	@Id_lotu INT,
	@Id_samolotu INT,
	@Dokad INT = NULL,
	@Skad INT = NULL,
	@Id_terminalu NVARCHAR(1),
	@Nr_bramki INT,
	@Data DATETIME,
	@Typ_lotu NVARCHAR(10)
)
AS
	BEGIN TRY
		IF (@Id_lotu < 0)
			RAISERROR('Id_lotu jest liczba ujemna. Nie dodano lotu', 16, 1)

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

		--sprawdzanie czy bramka nie jest już zajęta na ten czas
		IF (EXISTS (SELECT * FROM Loty WHERE Id_terminalu = @Id_terminalu AND Nr_bramki = @Nr_bramki AND Data = @Data)) BEGIN
			RAISERROR('Bramka jest juz zajeta na ten czas', 16, 1)
		END


		/*  --w sumie nie wiem czy to ma byc skoro jest CHECK przy INSERT
		IF (@Skad IS NULL AND @Dokad IS NULL) BEGIN
			RAISERROR('Nie podano parametru skad, dokad.', 16, 1)
		END

		IF (@Skad IS NOT NULL AND @Dokad IS NOT NULL) BEGIN
			RAISERROR('Oba parametry skad oraz dokad sa uzupelnione', 16, 1)
		END
		*/

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

		IF (NOT EXISTS (SELECT * FROM Bramki WHERE Id_terminalu = @Id_terminalu AND Nr_bramki = @Nr_bramki)) BEGIN
			RAISERROR('Nie ma bramki nr %i w terminalu %s', 16, 1, @Nr_bramki, @Id_terminalu)
		END

		IF (@Data < CURRENT_TIMESTAMP) BEGIN
			RAISERROR('Wprowadzona data juz minela, nie mozna dodac lotu "do przeszlosci"', 16, 1)
		END

		DECLARE @DateVARCHAR VARCHAR(30) = CAST(@Data AS VARCHAR)

		IF (SELECT dbo.Czy_samolot_na_lotnisku(@Id_samolotu, @Data)) = 'NIE'
			RAISERROR('Samolot o id %i, nie przebywa na naszym lotnisku w dniu %s', 16,1, @Id_samolotu, @DateVARCHAR)

		INSERT INTO Loty VALUES
		(@Id_lotu, @Id_samolotu, @Dokad, @Skad, @Id_terminalu, @Nr_bramki, @Data, @Typ_lotu)
	END TRY
	BEGIN CATCH		
		SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
 Return(5)
	END CATCH

GO	

EXEC Dodaj_lot
	@Id_lotu = 1035,
	@Id_samolotu = 97,
	@Dokad = 6,
	@Skad = NULL,
	@Id_terminalu = 'A',
	@Nr_bramki = 1,
	@Data = '2021-02-01 14:00',
	@Typ_lotu = 'Odlot'