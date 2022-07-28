IF OBJECT_ID('Przesun_czas_lotu(o minut)', 'P') IS NOT NULL
	DROP PROC [Przesun_czas_lotu(o minut)]
GO

CREATE PROC [Przesun_czas_lotu(o minut)] (
	@Id_lotu INT,
	@Ilosc_minut INT
)
AS
	BEGIN TRY
		IF(NOT EXISTS(SELECT * FROM Loty WHERE Id_lotu = @Id_lotu)) BEGIN
			RAISERROR('Nie istnieje lot o nr %i', 16, 1, @Id_lotu)
		END

		IF (@Ilosc_minut <= 0) BEGIN
			RAISERROR('Ilosc minut nie jest liczba dodatnia', 16, 1)
		END

		DECLARE @New_date DATETIME = DATEADD(MINUTE, @Ilosc_minut, (SELECT Data FROM Loty WHERE Id_lotu = @Id_lotu))

		--sprawdzanie czy bramka nie bedzie zajeta w tym czasie
		--czas potrzebny na obsluge samolotu przy bramce wynosi 30 minut
		DECLARE @Id_terminalu NVARCHAR(1) = (SELECT Id_terminalu FROM Loty WHERE Id_lotu = @Id_lotu)
		DECLARE @Nr_bramki INT = (SELECT Nr_bramki FROM Loty WHERE Id_lotu = @Id_lotu)
	
		DECLARE @Potential_flights INT = (SELECT COUNT(*) FROM Loty
		WHERE Id_terminalu = @Id_terminalu AND Nr_bramki = @Nr_bramki AND Id_lotu <> @Id_lotu
		AND Data > DATEADD(MINUTE, -30, @New_date) AND Data < DATEADD(MINUTE, 30, @New_date))

		IF (@Potential_flights > 0) BEGIN
			RAISERROR('Kolizja z bramkami, poprzedni samolot nie zdazy opuscic bramki', 16, 1)
		END


		UPDATE Loty
		SET Data = @New_date
		WHERE Id_lotu = @Id_lotu

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

EXEC [Przesun_czas_lotu(o minut)]
	@Id_lotu = 1021,
	@Ilosc_minut = 2880