IF OBJECT_ID('dbo.F_Samoloty_przewoznika', 'IF') IS NOT NULL
DROP FUNCTION dbo.F_Samoloty_przewoznika
GO
CREATE FUNCTION dbo.F_Samoloty_przewoznika (@Id_przewoznika INT)
RETURNS TABLE
AS
RETURN (
	SELECT Id_samolotu, Samoloty.Marka, Samoloty.Model, Samoloty_szczegoly.Ilosc_miejsc
	FROM Samoloty
	JOIN Samoloty_szczegoly ON (Samoloty_szczegoly.Model = Samoloty.Model
	AND Samoloty_szczegoly.Marka = Samoloty.Marka)
	WHERE Id_przewoznika = @Id_przewoznika
)
GO
-----
SELECT * FROM F_Samoloty_przewoznika(1)