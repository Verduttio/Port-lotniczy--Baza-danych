IF OBJECT_ID('Zmien_samolot_obslugujacy_lot', 'P') IS NOT NULL
	DROP PROC Zmien_samolot_obslugujacy_lot
GO

CREATE PROC Zmien_samolot_obslugujacy_lot (
	@Id_lotu INT,
	@Id_nowego_samolotu INT
)
AS
	BEGIN TRY
		DECLARE @Id_linia_lotnicza INT
		--pobranie daty lotu nad ktorym pracujemy
		DECLARE @Data_lotu DATETIME = (SELECT Data FROM Loty WHERE Id_lotu = @Id_lotu)

		SET @Id_linia_lotnicza = (SELECT Id_przewoznika FROM Loty
								INNER JOIN Samoloty ON Samoloty.Id_samolotu = Loty.Id_samolotu
								WHERE Id_lotu = @Id_lotu)

		IF (NOT EXISTS(SELECT * FROM Samoloty WHERE Id_samolotu = @Id_nowego_samolotu AND Id_przewoznika = @Id_linia_lotnicza)) BEGIN
			RAISERROR('Nowy samolot nie jest tej samej linii lotniczej co stary', 16,1)
		END

		DECLARE @DateVARCHAR VARCHAR(30) = CAST(@Data_lotu AS VARCHAR)

		IF ((SELECT dbo.Czy_samolot_na_lotnisku(@Id_nowego_samolotu, @Data_lotu)) = 'NIE') BEGIN
			RAISERROR('Samolot o id %i, nie przebywa na naszym lotnisku w dniu %s', 16, 1, @Id_nowego_samolotu, @DateVARCHAR)
		END

		------usuniecie ewentualnego przylotu zmienianego(starego) samolotu
		DECLARE @Id_starego_samolotu INT = (SELECT Id_samolotu FROM Loty WHERE Id_lotu = @Id_lotu)
		DECLARE @Data_przylotu DATETIME = (SELECT Data FROM Loty WHERE Id_lotu = @Id_lotu)

		DECLARE @Nr_lotu_przylotu INT = (SELECT TOP 1 Id_lotu FROM Loty
										WHERE Id_samolotu = @Id_starego_samolotu AND Data > @Data_przylotu)

		--Sprawdzenie czy lot jest naprawdę przylotem(gdyby był odlot to coś poszło nie tak przy dodawaniu lotow)
		IF ((SELECT Typ_lotu FROM Loty WHERE Id_lotu = @Nr_lotu_przylotu) <> 'Przylot') BEGIN
			RAISERROR('Lot nr %i powinien być Przylotem a nim nie jest', 16, 1, @Nr_lotu_przylotu)
		END

		--nastepny lot nowego samolotu, musimy sprawdzić czy samolot bedzie miał czas by wrócić na swój zaplanowany lot
		--zakladamy, ze samolot bedzie potrzebował pełnych 2 dni, czyli 48 godzin
		DECLARE @Data_nastepnego_lot_nowego DATETIME = (SELECT TOP 1 Data FROM Loty WHERE Id_samolotu = @Id_nowego_samolotu
														AND Data > @Data_lotu ORDER BY Data ASC)
		IF ((SELECT DATEDIFF(HOUR, @Data_lotu, @Data_nastepnego_lot_nowego)) < 48) BEGIN
			RAISERROR('Nowy samolot nie bedzie mial wystarczająco czasu by wrócić na swój zaplanowany lot.', 16, 1)
		END

		--Kasowanie tego przylotu, skoro samolot nie poleci to nie może przylecieć bo będzie na lotnisku cały czas
		IF (@Nr_lotu_przylotu IS NOT NULL) BEGIN
			DELETE FROM Loty
			WHERE Id_lotu = @Nr_lotu_przylotu
		END
		
		--update na nowy samolot zmienianego lotu
		UPDATE Loty
		SET Id_samolotu = @Id_nowego_samolotu
		WHERE Id_lotu = @Id_lotu


		--dodanie przylotu nowego samolotu z lotu nad ktorym pracowalismy, do tabeli loty
		DECLARE @Last_flight_nr INT = (SELECT MAX(Id_lotu) FROM Loty)
		DECLARE @Skad INT = (SELECT Dokad FROM Loty WHERE Id_lotu = @Id_lotu)
		DECLARE @Arrival_time DATETIME = DATEADD(HOUR, 48, @Data_lotu)
		INSERT INTO Loty VALUES 
		(@Last_flight_nr+1, @Id_nowego_samolotu, NULL, @Skad, 'D', 6, @Arrival_time, 'Przylot')

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





