IF OBJECT_ID('dbo.F_polaczenia_przewoznika', 'IF') IS NOT NULL
	DROP FUNCTION dbo.F_polaczenia_przewoznika
GO
CREATE FUNCTION F_polaczenia_przewoznika (@Nazwa NVARCHAR(50))
RETURNS TABLE
AS
RETURN (
	SELECT Nazwa_lotniska, Polaczenia_z_lotniskami.Panstwo,
	Miasto, Cena FROM Cennik_lotow
	INNER JOIN Przewoznicy ON Przewoznicy.Id_przewoznika = Cennik_lotow.Id_przewoznika
	INNER JOIN Polaczenia_z_lotniskami ON Polaczenia_z_lotniskami.Id_lotniska = Cennik_lotow.Dokad
	WHERE Przewoznicy.Nazwa LIKE @Nazwa
)
GO

SELECT * FROM F_polaczenia_przewoznika('Ryanair')