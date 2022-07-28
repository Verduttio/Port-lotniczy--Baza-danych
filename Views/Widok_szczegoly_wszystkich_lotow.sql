IF OBJECT_ID('dbo.vw_Szczegoly_lotow', 'V') IS NOT NULL
	DROP VIEW dbo.vw_Szczegoly_lotow
GO
CREATE VIEW vw_Szczegoly_lotow AS
SELECT Loty.Id_lotu, Loty.Data, Loty.Typ_lotu, Polaczenia_z_lotniskami.Nazwa_lotniska AS [Lotnisko], Polaczenia_z_lotniskami.Miasto, 
Polaczenia_z_lotniskami.Panstwo, dbo.Ilosc_rezerwacji_na_lot(Id_lotu) AS Rezerwacje, Samoloty_szczegoly.Ilosc_miejsc, Loty.Id_samolotu, Samoloty_szczegoly.Model, Samoloty_szczegoly.Marka,
Przewoznicy.Nazwa AS [Linia lotnicza], Loty.Id_terminalu, Loty.Nr_bramki
FROM Loty
INNER JOIN Samoloty ON Loty.Id_samolotu = Samoloty.Id_samolotu
INNER JOIN Przewoznicy ON Przewoznicy.Id_przewoznika = Samoloty.Id_przewoznika
INNER JOIN Samoloty_szczegoly ON (Samoloty_szczegoly.Marka = Samoloty.Marka AND Samoloty_szczegoly.Model = Samoloty.Model)
INNER JOIN Polaczenia_z_lotniskami ON (Loty.Dokad = Polaczenia_z_lotniskami.Id_lotniska OR Loty.Skad = Polaczenia_z_lotniskami.Id_lotniska)
GO

SELECT * FROM dbo.vw_Szczegoly_lotow