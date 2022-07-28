IF OBJECT_ID('Przedluz_umowe_z_przewoznikiem(o miesiecy)', 'P') IS NOT NULL
	DROP PROC [Przedluz_umowe_z_przewoznikiem(o miesiecy)]
GO

--przedłuzenie następuje o podaną w argumencie ilość miesięcy
CREATE PROC [Przedluz_umowe_z_przewoznikiem(o miesiecy)] (
	@Id_przewoznika INT,
	@Ilosc_miesiecy INT
)
AS
	BEGIN TRY
		IF(NOT EXISTS(SELECT * FROM Przewoznicy WHERE Id_przewoznika = @Id_przewoznika)) BEGIN
			RAISERROR('Nie istnieje przewoznik o id %i', 16, 1, @Id_przewoznika)
		END

		IF (@Ilosc_miesiecy <= 0) BEGIN
			RAISERROR('Ilosc miesiecy nie jest liczba dodatnia', 16, 1)
		END

		UPDATE Umowy_z_przewoznikami
		SET Do_kiedy = DATEADD(MONTH, 12, Do_kiedy)
		WHERE Id_przewoznika = @Id_przewoznika

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

EXEC [Przedluz_umowe_z_przewoznikiem(o miesiecy)]
	@Id_przewoznika = 1,
	@Ilosc_miesiecy = 12