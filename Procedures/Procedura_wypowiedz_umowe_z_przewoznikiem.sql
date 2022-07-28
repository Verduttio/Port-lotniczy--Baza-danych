IF OBJECT_ID('Wypowiedz_umowe_z_przewoznikiem', 'P') IS NOT NULL
	DROP PROC Wypowiedz_umowe_z_przewoznikiem
GO

--wypowiedzenia następuje z chwilą natychmiastową
--w chwili wypowiedzena zaplanowane loty zostają automatycznie wykasowane
CREATE PROC Wypowiedz_umowe_z_przewoznikiem (
	@Id_przewoznika INT
)
AS
	BEGIN TRY
		IF(NOT EXISTS(SELECT * FROM Przewoznicy WHERE Id_przewoznika = @Id_przewoznika)) BEGIN
			RAISERROR('Nie istnieje przewoznik o id %i', 16, 1, @Id_przewoznika)
		END

		--wpisanie aktualnej daty do tabeli z umowami w miejscu daty do kiedy
		--przy odpowiednim przewoźniku
		UPDATE Umowy_z_przewoznikami
		SET Do_kiedy = CURRENT_TIMESTAMP
		WHERE Id_przewoznika = @Id_przewoznika

		--wykasowanie lotów przeprowadzanych przez danego przewoznika
		--z tabeli loty
		DELETE FROM Loty
		WHERE Id_samolotu IN (SELECT Id_samolotu FROM Samoloty WHERE Id_przewoznika = @Id_przewoznika)
		AND Data > CURRENT_TIMESTAMP

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

EXEC Wypowiedz_umowe_z_przewoznikiem
	@Id_przewoznika = 1