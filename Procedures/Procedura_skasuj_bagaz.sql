IF OBJECT_ID('Skasuj_bagaz', 'P') IS NOT NULL
	DROP PROC Skasuj_bagaz
GO

CREATE PROC Skasuj_bagaz (
	@Id_rezerwacji INT,
	@Id_bagazu INT
)
AS
	BEGIN TRY
		IF(NOT EXISTS(SELECT * FROM Bagaz WHERE Id_rezerwacji = @Id_rezerwacji AND Id_bagazu = @Id_bagazu)) BEGIN
			RAISERROR('Nie ma bagazu nr %i w rezerwacji nr %i', 16, 1, @Id_bagazu, @Id_rezerwacji)
		END

		DELETE FROM Bagaz
		WHERE Id_rezerwacji = @Id_rezerwacji AND Id_bagazu = @Id_bagazu
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

EXEC Skasuj_bagaz
	@Id_rezerwacji = 5,
	@Id_bagazu = 1