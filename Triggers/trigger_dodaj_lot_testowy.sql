IF OBJECT_ID('dbo.tr_inst_insert_loty', 'TR') IS NOT NULL
	DROP TRIGGER dbo.tr_inst_insert_loty

GO
CREATE TRIGGER tr_inst_insert_loty ON Loty
INSTEAD OF INSERT
AS
	DECLARE @Id_lotuTMP INT
	DECLARE @Id_samolotuTMP INT
	DECLARE @DokadTMP INT = NULL
	DECLARE @SkadTMP INT = NULL
	DECLARE @Id_terminaluTMP NVARCHAR(1)
	DECLARE @Nr_bramkiTMP INT
	DECLARE @DataTMP DATETIME
	DECLARE @Typ_lotuTMP NVARCHAR(10) 

	DECLARE @Counter INT = 0
	DECLARE @RowsAmount INT = (SELECT COUNT(*) FROM INSERTED)

	WHILE @Counter < @RowsAmount BEGIN
		PRINT @Counter
		SET @Id_lotuTMP = (SELECT Id_lotu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Id_samolotuTMP = (SELECT Id_samolotu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @DokadTMP = (SELECT Dokad FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @SkadTMP = (SELECT Skad FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Id_terminaluTMP = (SELECT Id_terminalu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Nr_bramkiTMP = (SELECT Nr_bramki FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @DataTMP = (SELECT Data FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)
		SET @Typ_lotuTMP = (SELECT Typ_lotu FROM INSERTED ORDER BY Id_lotu OFFSET @Counter ROWS FETCH NEXT 1 ROWS ONLY)

		PRINT @Typ_lotuTMP

		EXEC Dodaj_lot
		@Id_lotu = @Id_lotuTMP,
		@Id_samolotu = @Id_samolotuTMP,
		@Dokad = @DokadTMP,
		@Skad = @SkadTMP,
		@Id_terminalu = @Id_terminaluTMP,
		@Nr_bramki = @Nr_bramkiTMP,
		@Data = @DataTMP,
		@Typ_lotu = @Typ_lotuTMP

		SET @Counter += 1
		PRINT @Counter
	END

GO

INSERT INTO Loty VALUES
(1035, 97, 6, NULL, 'A', 1, '2021-02-01 14:00', 'Odlot')



