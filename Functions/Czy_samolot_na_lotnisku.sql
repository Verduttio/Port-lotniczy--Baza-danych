SELECT * FROM Loty
WHERE Id_samolotu = 2
ORDER BY Data DESC


IF OBJECT_ID('dbo.Czy_samolot_na_lotnisku', 'FN') IS NOT NULL
	DROP FUNCTION dbo.Czy_samolot_na_lotnisku
GO

CREATE FUNCTION Czy_samolot_na_lotnisku (@Id_samolotu INT, @Data DATETIME)
RETURNS VARCHAR(3)
AS
BEGIN
	DECLARE @Ilosc_lotow INT
	DECLARE @Out VARCHAR(3)
	SET @Ilosc_lotow = (SELECT COUNT(*) FROM Loty
						WHERE Id_samolotu = @Id_samolotu AND Data <= @Data)
	IF @Ilosc_lotow = 0
		SET @Out = 'TAK'
	ELSE
		BEGIN
			IF (SELECT TOP 1 Typ_lotu FROM Loty
						WHERE Id_samolotu = @Id_samolotu
						AND Data <= @Data
						ORDER BY Data DESC) = 'Przylot'
				SET @Out = 'TAK'
			ELSE
				SET @Out = 'NIE'
		END
	RETURN @Out
END
GO

SELECT dbo.Czy_samolot_na_lotnisku(36, '2021-01-15 13:30')
SELECT dbo.Czy_samolot_na_lotnisku(134, '2021-01-15 13:30')