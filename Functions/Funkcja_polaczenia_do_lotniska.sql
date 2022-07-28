IF OBJECT_ID('dbo.F_Polaczenia_do_lotniska', 'IF') IS NOT NULL
DROP FUNCTION dbo.F_Polaczenia_do_lotniska
GO
CREATE FUNCTION F_Polaczenia_do_lotniska (@Id_lotniska INT)
RETURNS TABLE
AS
RETURN (
	SELECT Przewoznicy.Id_przewoznika, Nazwa, Cena FROM Cennik_lotow
	INNER JOIN Przewoznicy
	ON Przewoznicy.Id_przewoznika = Cennik_lotow.Id_przewoznika
	WHERE Dokad = @Id_lotniska
)
GO
------
SELECT * FROM F_Polaczenia_do_lotniska(1)