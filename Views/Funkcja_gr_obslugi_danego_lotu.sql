IF OBJECT_ID('dbo.F_gr_obslugi_lotu', 'IF') IS NOT NULL
	DROP FUNCTION dbo.F_gr_obslugi_lotu
GO
CREATE FUNCTION F_gr_obslugi_lotu (@Id_lotu INT)
RETURNS TABLE
AS
RETURN (
	SELECT GR_Obslugi_lotu.*, Stanowisko, Imie, Nazwisko FROM GR_Obslugi_lotu
	INNER JOIN Pracownicy ON Pracownicy.ID_Pracownika = GR_Obslugi_lotu.Id_Pracownika
	WHERE Id_lotu = @Id_lotu
)
GO

SELECT * FROM F_gr_obslugi_lotu(1001)