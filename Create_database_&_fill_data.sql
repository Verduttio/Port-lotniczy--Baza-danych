CREATE DATABASE Port_lotniczy
GO
USE Port_lotniczy

CREATE TABLE Przewoznicy (
	Id_przewoznika INT PRIMARY KEY,
	Nazwa NVARCHAR(50) NOT NULL,
	Panstwo NVARCHAR(50) NOT NULL,
	Nr_telefonu NVARCHAR(13) NOT NULL   
);


CREATE TABLE Samoloty_szczegoly (
	Marka NVARCHAR(20),
	Model NVARCHAR(20),
	Ilosc_miejsc INT NOT NULL,
	PRIMARY KEY(Marka, Model)
)

CREATE TABLE Samoloty (
	Id_samolotu INT PRIMARY KEY,
	Marka NVARCHAR(20) NOT NULL,
	Model NVARCHAR(20) NOT NULL,
	Id_przewoznika INT NOT NULL,
	FOREIGN KEY (Marka, Model) REFERENCES Samoloty_szczegoly(Marka, Model) ON DELETE CASCADE ON UPDATE CASCADE
)

ALTER TABLE Samoloty
ADD CONSTRAINT FK_Samoloty FOREIGN KEY(Id_przewoznika) REFERENCES Przewoznicy(Id_przewoznika)
ON DELETE CASCADE  
ON UPDATE CASCADE;   

CREATE TABLE Umowy_z_przewoznikami (
	Id_przewoznika INT NOT NULL,
	Nr_umowy INT PRIMARY KEY,
	Od_kiedy DATE,
	Do_kiedy DATE,
	CHECK (Do_kiedy >= Od_kiedy),
	FOREIGN KEY (Id_przewoznika) REFERENCES Przewoznicy(Id_przewoznika) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Polaczenia_z_lotniskami (
	Id_lotniska INT PRIMARY KEY,
	Nazwa_lotniska NVARCHAR(50) NOT NULL,
	Panstwo NVARCHAR(50) NOT NULL,
	Miasto NVARCHAR(50) NOT NULL
);

CREATE TABLE Cennik_lotow (
	Dokad INT NOT NULL,
	Cena MONEY NOT NULL,
	Id_przewoznika INT NOT NULL,
	PRIMARY KEY(Dokad, Id_przewoznika),
	FOREIGN KEY(Dokad) REFERENCES Polaczenia_z_lotniskami(Id_lotniska) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY(Id_przewoznika) REFERENCES Przewoznicy(Id_przewoznika) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Terminale (
	Id_terminalu NVARCHAR(1) PRIMARY KEY,
	Polozenie NVARCHAR(2) NOT NULL
);


CREATE TABLE Bramki (
	Id_terminalu NVARCHAR(1) NOT NULL,
	Nr_bramki INT NOT NULL,
	PRIMARY KEY (Id_terminalu, Nr_bramki),
	FOREIGN KEY(Id_terminalu) REFERENCES Terminale(Id_terminalu) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Loty (
	Id_lotu INT PRIMARY KEY,
	Id_samolotu INT NOT NULL,
	Dokad INT,
	Skad INT,
	Id_terminalu NVARCHAR(1) NOT NULL,
	Nr_bramki INT NOT NULL,
	Data DATETIME NOT NULL,
	Typ_lotu NVARCHAR(10) NOT NULL,
	FOREIGN KEY (Id_samolotu) REFERENCES Samoloty(Id_samolotu) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Id_terminalu, Nr_bramki) REFERENCES Bramki(Id_terminalu, Nr_bramki)ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Dokad) REFERENCES Polaczenia_z_lotniskami(Id_lotniska) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Skad) REFERENCES Polaczenia_z_lotniskami(Id_lotniska),
	CONSTRAINT CHK_Typ_lotu CHECK ((Typ_lotu = 'Przylot' AND (Skad IS NOT NULL AND Dokad IS NULL)) OR (Typ_lotu = 'Odlot' AND (Dokad IS NOT NULL AND Skad IS NULL)))
)

----------------------------------------------------

IF OBJECT_ID('Pracownicy', 'U') is not NUll DROP TABLE Pracownicy 

CREATE TABLE Pracownicy(
	ID_Pracownika int not null,
	Imie nvarchar(50) not null,
	Nazwisko nvarchar(50) not null,
	Stanowisko nvarchar(50) not null,
	Stawka money not null
)


IF OBJECT_ID('GR_Obslugi_lotu', 'U') is not NUll DROP TABLE GR_Obslugi_lotu

CREATE TABLE GR_Obslugi_lotu(
	Id_lotu int not null,
	Id_Pracownika int not null
)

IF OBJECT_ID('Osoby niebezpieczne', 'U') is not NUll DROP TABLE [Osoby niebezpieczne]

CREATE TABLE [Osoby niebezpieczne](
	NR_Paszportu varchar(15) not null,
	Imie nvarchar(50) not null,
	Nazwisko nvarchar(50) not null,
)

IF OBJECT_ID('Pasazer', 'U') is not NUll DROP TABLE Pasazer

CREATE TABLE Pasazer(
	Id_Pasazera int not null,
	NR_Paszportu varchar(15) not null UNIQUE,
	Imie nvarchar(50) not null,
	Nazwisko nvarchar(50) not null,
	Panstwo nvarchar(50) null
)

IF OBJECT_ID('Klasa podrozy', 'U') is not NUll DROP TABLE [Klasa podrozy]

CREATE TABLE [Klasa podrozy](
	Klasa int not null,
	Prowizja real not null  
)


IF OBJECT_ID('Rezerwacje', 'U') is not NUll DROP TABLE Rezerwacje

CREATE TABLE Rezerwacje(
	Id_Rezerwacji int not null,
	Id_lotu int not null,
	Id_pasazera int not null,
	Klasa_podrozy int not null
)

IF OBJECT_ID('Bagaz', 'U') is not NUll DROP TABLE Bagaz

CREATE TABLE Bagaz(
	Id_rezerwacji int not null,
	Id_bagazu int not null,
	Waga real not null
)

IF OBJECT_ID('Cennik_Bagazy', 'U') is not NUll DROP TABLE [Cennik_Bagazy]

CREATE TABLE [Cennik_Bagazy](
	Waga int not null, -- do X kg
	Cena money not null,
)

-- PRIMARY KEY :
Alter table [Cennik_Bagazy] add PRIMARY KEY (Waga)
Alter table Bagaz add Primary Key (Id_rezerwacji, Id_bagazu)
Alter table Rezerwacje add Primary Key (Id_Rezerwacji)
Alter table [Klasa podrozy] add Primary Key (Klasa)
Alter table Pasazer add Primary Key (Id_Pasazera)
Alter table [Osoby niebezpieczne] add Primary Key (NR_Paszportu)
Alter table GR_Obslugi_lotu add Primary Key (Id_lotu, ID_Pracownika)
Alter table Pracownicy add Primary Key (ID_Pracownika)

--FOREIGN KEY :

Alter table GR_Obslugi_lotu add Foreign Key (ID_Pracownika) REFERENCES Pracownicy(ID_Pracownika)
ON DELETE CASCADE
ON UPDATE CASCADE

Alter table GR_Obslugi_lotu add Foreign Key (ID_lotu) REFERENCES Loty(ID_Lotu)
ON DELETE CASCADE
ON UPDATE CASCADE

Alter table Rezerwacje add FOREIGN KEY (Id_pasazera) REFERENCES Pasazer(Id_Pasazera)
ON DELETE CASCADE
ON UPDATE CASCADE

Alter table Rezerwacje add FOREIGN KEY (Klasa_podrozy) REFERENCES [Klasa podrozy](Klasa)

Alter table Rezerwacje add FOREIGN KEY (Id_lotu) REFERENCES [Loty](Id_lotu)
ON DELETE CASCADE
ON UPDATE CASCADE

Alter table Bagaz add FOREIGN KEY (Id_rezerwacji) REFERENCES Rezerwacje(Id_rezerwacji)
ON DELETE CASCADE
ON UPDATE CASCADE

-- UNIQUE
Alter TABLE REZERWACJE 
ADD UNIQUE(ID_LOTU, ID_PASAZERA)




--------wstawianie danych
INSERT INTO Przewoznicy VALUES
(1, 'Ryanair', 'Irlandia', '+48221522001'),
(2, 'Lufthansa', 'Niemcy', '+48225123917'),
(3, 'easyJet', 'Wielka Brytania', '+48616262022'),
(4, 'Emirates', 'Zjednoczone Emiraty Arabskie', '+48223060808'),
(5, 'Air France', 'Francja', '+48225123949'),
(6, 'British Airways', 'Wielka Brytania', '+48223060850'),
(7, 'Air Berlin', 'Niemcy', '+493034340'),
(8, 'KLM', 'Holandia', '+48225123947'),
(9, 'Delta Air Lines', 'Stany Zjednoczone', '+14047152600'),
(10, 'American Airlines', 'Stany Zjednoczone', '+48226253002'),
(11, 'Air China', 'Chiny', '00861095583'),
(12, 'Singapore Airlines', 'Singapur', '+6562238888'),
(13, 'Turkish Airlines', 'Turcja', '+48225297700'),
(14, 'LOT Polish Airlines', 'Polska', '+48225777755'),
(15, 'Ukraine International Airlines', 'Ukraina', '+444865486'),
(16, 'Qatar Airways', 'Katar', '+48717564055'),
(17, 'ANA All Nippon Airways', 'Japonia', '0367411120'),
(18, 'Qantas Airways', 'Australia', '1300650729'),
(19, 'Wizz Air', 'Węgry', '+48703703003'),
(20, 'Air Canada', 'Kanada', '+48226968520');


INSERT INTO Umowy_z_przewoznikami VALUES
(1, 1001, '20150115', '20250101'),
(2, 1002, '20160315', '20210205'),
(3, 1003, '20160215', '20220211'),
(4, 1012, '20100425', '20300709'),
(5, 1005, '20100224', '20251111'),
(6, 1023, '20190102', '20220421'),
(7, 1007, '20200101', '20201231'), 
(8, 1008, '20190717', '20220202'),
(9, 1009, '20100110', '20300110'),
(10, 1034, '20170108', '20250125'),
(11, 1011, '20190105', '20240404'),
(12, 1056, '20160119', '20270101'),
(13, 1067, '20000616', '20210202'),
(14, 1078, '20150115', '20240212'),
(15, 1089, '20180701', '20300101'),
(16, 1016, '20100110', '20290908'),
(17, 1017, '20100110', '20201231'), 
(18, 1018, '20150115', '20220213'),
(19, 2001, '20191231', '20211231'),
(20, 1020, '20120112', '20230307');

INSERT INTO Samoloty_szczegoly VALUES 
('Boeing', '737-300', 133),
('Boeing', '737-900', 215),
('Boeing', '747-8', 467),
('Boeing', '767-200', 216),
('Boeing', '777-300', 297),
('Boeing', '787-9', 275),
('Boeing', '787-10', 310),
('Airbus', 'A300', 266),
('Airbus', 'A310', 262),
('Airbus', 'A330', 330),
('Airbus', 'A340', 350),
('Airbus', 'A350', 325),
('Airbus', 'A380', 853), 
('Airbus', 'A318', 132),
('Airbus', 'A320', 180),
('Airbus', 'A321', 220),
('Embraer', '170', 70),
('Embraer', '175', 80),
('Embraer', '190', 98),
('Embraer', '190LR', 106),
('Embraer', '195', 108),
('Embraer', '195LR', 122),
('Saab', '2000', 58),
('ATR', '42-300', 50),
('Cessna', 'Citation I', 8),
('Cessna', 'Citation X', 12)

INSERT INTO Samoloty VALUES 
(1, 'Boeing', '737-300', 1), 
(2, 'Boeing', '737-900', 2),
(3, 'Boeing', '747-8', 2),
(4, 'Boeing', '767-200', 1), 
(5, 'Boeing', '777-300', 1),
(6, 'Boeing', '787-9', 1),
(7, 'Boeing', '787-10', 3), 
(8, 'Airbus', 'A300', 1),
(9, 'Airbus', 'A310', 1),
(10, 'Airbus', 'A330', 3),
(11, 'Airbus', 'A340', 1),
(12, 'Airbus', 'A350', 3),
(13, 'Airbus', 'A380', 4),
(14, 'Airbus', 'A318', 1),
(15, 'Airbus', 'A320', 4),
(16, 'Airbus', 'A321', 1),
(17, 'Embraer', '170', 5),
(18, 'Embraer', '175', 1),
(19, 'Embraer', '190', 1),
(20, 'Embraer', '190LR', 1),
(21, 'Embraer', '195', 5), 
(22, 'Embraer', '195LR', 7),
(23, 'Saab', '2000', 1),
(24, 'ATR', '42-300', 7), 
(25, 'Cessna', 'Citation I', 8),
(26, 'Cessna', 'Citation X', 8), 
-----
(27, 'Boeing', '737-300', 6),
(28, 'Boeing', '737-900', 6),
(29, 'Boeing', '747-8', 6),
(30, 'Boeing', '767-200', 4),
(31, 'Boeing', '777-300', 6),
(32, 'Boeing', '787-9', 6),
(33, 'Boeing', '787-10', 6), 
(34, 'Airbus', 'A300', 6),
(35, 'Airbus', 'A310', 6),
(36, 'Airbus', 'A330', 9),
(37, 'Airbus', 'A340', 6),
(38, 'Airbus', 'A350', 6),
(39, 'Airbus', 'A380', 8), 
(40, 'Airbus', 'A318', 6),
(41, 'Airbus', 'A320', 6),
(42, 'Airbus', 'A321', 6),
--
(43, 'Boeing', '737-300', 10),
(44, 'Boeing', '737-900', 10),
(45, 'Boeing', '747-8', 11),  
(46, 'Boeing', '767-200', 10),
(47, 'Boeing', '777-300', 11),
(48, 'Boeing', '787-9', 10),
(49, 'Boeing', '787-10', 10),
(50, 'Airbus', 'A300', 10),
(51, 'Airbus', 'A310', 10),
(52, 'Airbus', 'A330', 10),
(53, 'Airbus', 'A340', 11),  
(54, 'Airbus', 'A350', 10),
(55, 'Airbus', 'A380', 10), 
(56, 'Airbus', 'A318', 10),
(57, 'Airbus', 'A320', 10),
(58, 'Airbus', 'A321', 10),
--
(59, 'Boeing', '737-300', 13), 
(60, 'Boeing', '737-900', 12),
(61, 'Boeing', '747-8', 13),
(62, 'Boeing', '767-200', 13),
(63, 'Boeing', '777-300', 12),
(64, 'Boeing', '787-9', 12),
(65, 'Boeing', '787-10', 12),
(66, 'Airbus', 'A300', 12),
(67, 'Airbus', 'A310', 13),
(68, 'Airbus', 'A330', 12),
(69, 'Airbus', 'A340', 13),
(70, 'Airbus', 'A350', 12),
(71, 'Airbus', 'A380', 12), 
(72, 'Airbus', 'A318', 13),
(73, 'Airbus', 'A320', 12),
(74, 'Airbus', 'A321', 12),
--
(75, 'Boeing', '737-300', 14),
(76, 'Boeing', '737-900', 14),
(77, 'Boeing', '747-8', 14),
(78, 'Boeing', '767-200', 14),
(79, 'Boeing', '777-300', 15), 
(80, 'Boeing', '787-9', 14),
(81, 'Boeing', '787-10', 14), 
(82, 'Airbus', 'A300', 14),
(83, 'Airbus', 'A310', 15),
(84, 'Airbus', 'A330', 14),
(85, 'Airbus', 'A340', 14),
(86, 'Airbus', 'A350', 15),
(87, 'Airbus', 'A380', 14), 
(88, 'Airbus', 'A318', 15),
(89, 'Airbus', 'A320', 14),
(90, 'Airbus', 'A321', 14),
(91, 'Embraer', '170', 15),
(92, 'Embraer', '175', 14),
(93, 'Embraer', '190', 15),
(94, 'Embraer', '190LR', 14),
(95, 'Embraer', '195', 14),
(96, 'Embraer', '195LR', 14),
(97, 'Saab', '2000', 15),   
(98, 'ATR', '42-300', 14),
(99, 'Cessna', 'Citation I', 15),
(100, 'Cessna', 'Citation X', 14),
--
(101, 'Airbus', 'A300', 16),
(102, 'Airbus', 'A310', 16),
(103, 'Airbus', 'A330', 16),
(104, 'Airbus', 'A340', 16),
(105, 'Airbus', 'A350', 16),
(106, 'Airbus', 'A380', 16), 
(107, 'Airbus', 'A318', 16),
(108, 'Airbus', 'A320', 16),
(109, 'Airbus', 'A321', 16),
--
(110, 'Boeing', '737-300', 17),
(111, 'Boeing', '737-900', 17),
(112, 'Boeing', '747-8', 18), 
(113, 'Boeing', '767-200', 19),
(114, 'Boeing', '777-300', 20),
(115, 'Boeing', '787-9', 17),
(116, 'Boeing', '787-10', 19),
(117, 'Airbus', 'A300', 18),
(118, 'Airbus', 'A310', 19),
(119, 'Airbus', 'A330', 20),
(120, 'Airbus', 'A340', 20),
(121, 'Airbus', 'A350', 19),
(122, 'Airbus', 'A380', 19), 
(123, 'Airbus', 'A318', 19),
(124, 'Airbus', 'A320', 19),
(125, 'Airbus', 'A321', 18),
(126, 'Embraer', '170', 17),  
(127, 'Embraer', '175', 18),
(128, 'Embraer', '190', 18),  
(129, 'Embraer', '190LR', 19),
(130, 'Embraer', '195', 20),
(131, 'Embraer', '195LR', 20),
(132, 'Saab', '2000', 19),
(133, 'ATR', '42-300', 19), 
(134, 'Cessna', 'Citation I', 19),  
(135, 'Cessna', 'Citation X', 19)


INSERT INTO Polaczenia_z_lotniskami VALUES
(1, 'Hartsfield-Jackson Atlanta International Airport', 'Stany Zjednoczone', 'Atlanta'),
(2, 'Beijing Capital International Airport', 'Chiny', 'Pekin'),
(3, 'Dubai International Airport', 'Zjednoczone Emiraty Arabskie', 'Dubaj'),
(4, 'Haneda Airport', 'Japonia', 'Tokio'),
(5, 'Los Angeles International Airport', 'Stany Zjednoczone', 'Los Angeles'),
(6, 'Chicago-O’Hare', 'Stany Zjednoczone', 'Chicago'),
(7, 'London Heathrow', 'Wielka Brytania', 'Londyn'),
(8, 'Hong Kong International Airport', 'Chiny', 'Hongkong'),
(9, 'Shanghai Pudong International Airport', 'Chiny', 'Szanghaj'),
(10, 'Charles de Gaulle International Airport', 'Francja', 'Roissy-en-France'),
(11, 'Amsterdam Airport Schiphol', 'Holandia', 'Amsterdam'),
(12, 'Dallas/Fort Worth International Airport', 'Stany Zjednoczone', 'Dallas'),
(13, 'Guangzhou Baiyun International Airport', 'Chiny', 'Kanton'),
(14, 'Frankfurt am Main Airport', 'Niemcy', 'Frankfurt'),
(15, 'Ataturk Airport', 'Turcja', 'Stambul'),
(16, 'Indira Gandhi International Airport', 'Indie', 'Nowe Delhi'),
(17, 'Soekarno–Hatta International Airport', 'Indonezja', 'Dzakarta'),
(18, 'Singapore Changi Airport', 'Singapur', 'Singapur'),
(19, 'Incheon International Airport', 'Korea Południowa', 'Inczon'),
(20, 'Denver International Airport', 'Stany Zjednoczone', 'Denver'),
(21, 'Warsaw Chopin Airport', 'Polska', 'Warszawa'),
(22, 'Boryspil International Airport', 'Ukraina', 'Boryspol')


INSERT INTO Cennik_lotow VALUES 
(1, 3000, 9),
(1, 3500, 10),
(1, 3300, 1),
(1, 3200, 14),
(2, 4400, 17),
(2, 3900, 11),
(2, 4800, 15),
(3, 5000, 4),
(4, 4000, 17),
(4, 4500, 2),
(4, 3990, 18),
(5, 2990, 19),
(5, 3450, 20),
(6, 2500, 6),
(6, 3500, 10),
(6, 4400, 14),
(6, 3150, 15),
(7, 2000, 6),
(7, 2500, 3),
(7, 2750, 5),
(8, 4400, 11),
(9, 4500, 11),
(10, 1800, 5),
(11, 2100, 8),
(12, 2900, 7),
(13, 4100, 16),
(14, 2150, 9),
(14, 2500, 7),
(15, 3900, 13),
(15, 4100, 14),
(16, 4500, 15),
(16, 4250, 20),
(16, 4300, 19),
(17, 2900, 18),
(17, 3300, 12),
(18, 4500, 12),
(18, 4110, 13),
(18, 3400, 3),
(19, 4700, 17),
(19, 4500, 14),
(20, 3900, 9),
(20, 3600, 1),
(21, 1800, 10),
(21, 2100, 14),
(21, 2700, 12),
(22, 2500, 15),
(22, 2000, 6),
(22, 2900, 4)

INSERT INTO Terminale VALUES 
('A', 'N'),
('B', 'E'),
('C', 'S'),
('D', 'W')


INSERT INTO Bramki VALUES
('A', 1),
('A', 2),
('A', 3),
('B', 1),
('B', 2),
('B', 3),
('B', 4),
('B', 5),
('C', 1),
('C', 2),
('D', 1),
('D', 2),
('D', 3),
('D', 4),
('D', 5),
('D', 6)

INSERT INTO Loty VALUES
(1000, 4, 1, NULL, 'A', 1, '2021-01-06 12:00', 'Odlot'),
(1001, 36, 1, NULL, 'A', 2, '2021-01-07 19:00', 'Odlot'),
(1002, 53, 2, NULL, 'B', 5, '2021-01-07 21:15', 'Odlot'),
(1003, 126, 2, NULL, 'C', 1, '2021-01-08 08:50', 'Odlot'),
(1004, 4, NULL, 5, 'D', 6, '2021-01-09 10:00', 'Przylot'),
(1005, 13, 3, NULL, 'C', 2, '2021-01-10 14:15', 'Odlot'),
(1006, 111, 4, NULL, 'A', 3, '2021-01-11 16:40', 'Odlot'),
(1007, 128, 4, NULL, 'A', 1, '2021-01-11 22:10', 'Odlot'),
(1008, 134, 5, NULL, 'C', 1, '2021-01-12 04:30', 'Odlot'),
(1009, 97, 6, NULL, 'B', 1, '2021-01-12 23:45', 'Odlot'),
(1010, 53, NULL, 17, 'D', 5, '2021-01-13 14:20', 'Przylot'),
(1011, 36, NULL, 22, 'D', 6, '2021-01-13 14:30', 'Przylot'),
(1012, 33, 7, NULL, 'B', 4, '2021-01-14 16:00', 'Odlot'),
(1013, 53, 8, NULL, 'A', 1, '2021-01-15 13:30', 'Odlot'),
(1014, 45, 9, NULL, 'B', 1, '2021-01-16 21:00', 'Odlot'),
(1015, 21, 10, NULL, 'C', 2, '2021-01-17 11:40', 'Odlot'),
(1016, 26, 11, NULL, 'B', 4, '2021-01-18 15:05', 'Odlot'),
(1017, 126, NULL, 21, 'D', 3, '2021-01-19 10:50', 'Przylot'),
(1018, 13, NULL, 16, 'D', 2, '2021-01-20 14:25', 'Przylot'),
(1019, 24, 12, NULL, 'A', 1, '2021-01-21 19:20', 'Odlot'),
(1020, 106, 13, NULL, 'B', 3, '2021-01-22 20:00', 'Odlot'),
(1021, 36, 14, NULL, 'C', 2, '2021-01-23 10:10', 'Odlot'),
(1022, 111, NULL, 10, 'D', 4, '2021-01-24 22:00', 'Przylot'),
(1023, 81, 15, NULL, 'C', 2, '2021-01-25 10:15', 'Odlot'),
(1024, 59, 15, NULL, 'A', 1, '2021-01-26 19:30', 'Odlot'),
(1025, 133, 16, NULL, 'B', 3, '2021-01-27 15:50', 'Odlot'),
(1026, 112,17, NULL, 'C', 2, '2021-01-27 20:00', 'Odlot'),
(1027, 128, NULL, 4, 'D', 4, '2021-01-27 23:45', 'Przylot'),
(1028, 7, 18, NULL, 'A', 2, '2021-01-28 10:00', 'Odlot'),
(1029, 134, NULL, 22, 'D', 6, '2021-01-28 14:00', 'Przylot'),
(1030, 97, NULL, 20, 'D', 5, '2021-01-28 16:00', 'Przylot'),
(1031, 111, 19, NULL, 'B', 3, '2021-01-29 17:45', 'Odlot'),
(1032, 1, 20, NULL, 'C', 2, '2021-01-29 20:15', 'Odlot'),
(1033, 55, 21, NULL, 'A', 3, '2021-01-30 14:00', 'Odlot'),
(1034, 79, 22, NULL, 'C', 1, '2021-01-31 10:10', 'Odlot')

---

INSERT INTO Pracownicy VALUES
(1, 'Jan', 'Valsman', 'pilot', 3750),
(2, 'Piotr', 'Rymarczyk', 'pilot', 4000),
(3, 'Jarosław', 'Widewski', 'pilot', 3500),
(4, 'Natalia', 'Kujawinska', 'pilot', 4000),
(5, 'Wiktor', 'Adamiec', 'pilot', 3000),
(6, 'Wiktoria', 'Chomicka', 'stewardessa', 2500),
(7, 'Olga', 'Chomik', 'stewardessa', 2500),
(8, 'Kunigunda', 'von Bismark', 'stewardessa', 3000),
(9, 'Fatima', 'Istaimelova', 'stewardessa', 1800),
(10, 'Szymon', 'Aleksiev', 'steward', 2500),
(11, 'Mark', 'Wisniewski', 'steward', 3000),
(12, 'Jan', 'Bura', 'celnik', 5000),
(13, 'Peter', 'Peterson', 'pilot', 5000),
(14, 'Władysław', 'Guralski', 'strażnik', 3500),
(15, 'Włodzimierz', 'Boguski', 'strażnik', 3500),
(16, 'Witold', 'Boguski', 'strażnik', 3000),
(17, 'Semuel', 'Tesla', 'strażnik', 2800),
(18, 'Irena', 'Halicka', 'celnik', 5500),
(19, 'Krzysztof', 'Hejnek', 'celnik', 4500),
(20, 'Walter', 'Adamowski', 'pilot', 3750),
(21, 'Kim', 'Sen', 'pilot', 4000),
(22, 'Aleksandra', 'Drewniowska', 'pilot', 4500),
(23, 'Lilia', 'Komarowska', 'stewardessa', 2700),
(24, 'Anna', 'Gutowska', 'stewardessa', 2500),
(25, 'Samanta', 'Iwanicka', 'stewardessa', 3000),
(26, 'Wiktoria', 'Ekielska', 'stewardessa', 2200),
(27, 'Katarzyna', 'Kozubek', 'stewardessa', 3000),
(28, 'Olga', 'Jurczyk', 'stewardessa', 3100),
(29, 'Andrzej', 'Leja', 'pilot', 4000),
(30, 'Sirius', 'Black', 'pilot', 3500),
(31, 'Jerzy', 'Murawski', 'pilot', 4200)


INSERT INTO GR_Obslugi_lotu VALUES
(1000, 1), (1000, 2),
(1000, 6), (1000, 8),
(1000, 9), (1001, 4),
(1001, 3), (1001, 7),
(1001, 10), (1001, 11),
(1002, 13), (1002, 20),
(1002, 5), (1002, 23),
(1002, 24), (1003, 20),
(1003, 21), (1003, 26),
(1003, 27),(1004, 29), 
(1004, 27),
(1004, 28), (1005, 1),
(1005, 2), (1005, 6),
(1005, 7), (1006, 3),
(1006, 4), (1006, 8),
(1006, 10), (1006, 11),
(1007, 13), (1007, 20),
(1007, 27), (1007, 28),
(1008, 31), (1008, 30),
(1008, 24), (1008, 25),
(1009, 22), (1009, 20),
(1009, 9), (1009, 27),
(1009, 28), 
(1010, 1), (1010, 2),
(1010, 6), (1010, 8),
(1010, 9), (1011, 4),
(1011, 3), (1011, 7),
(1011, 10), (1011, 11),
(1012, 13), (1012, 20),
(1012, 5), (1012, 23),
(1012, 24), (1013, 20),
(1013, 21), (1013, 26),
(1013, 27),
(1014, 29), (1014, 27),
(1014, 28), (1015, 1),
(1015, 2), (1015, 6),
(1015, 7), (1016, 3),
(1016, 4), (1016, 8),
(1016, 10), (1016, 11),
(1017, 13), (1017, 20),
(1017, 27), (1017, 28),
(1018, 31), (1018, 30),
(1018, 24), (1018, 25),
(1019, 22), (1019, 20),
(1019, 9), (1019, 27),
(1019, 28), 
(1020, 1), (1020, 2),
(1020, 6), (1020, 8),
(1020, 9), (1021, 4),
(1021, 3), (1021, 7),
(1021, 10), (1021, 11),
(1022, 13), (1022, 20),
(1022, 5), (1022, 23),
(1022, 24), (1023, 20),
(1023, 21), (1023, 26),
(1023, 27),
(1024, 29), (1024, 27),
(1024, 28), (1025, 1),
(1025, 2), (1025, 6),
(1025, 7), (1026, 3),
(1026, 4), (1026, 8),
(1026, 10), (1026, 11),
(1027, 13), (1027, 20),
(1027, 27), (1027, 28),
(1028, 31), (1028, 30),
(1028, 24), (1028, 25),
(1029, 22), (1029, 20),
(1029, 9), (1029, 27),
(1029, 28),
(1030, 1), (1030, 2),
(1030, 6), (1030, 8),
(1030, 9), (1031, 4),
(1031, 3), (1031, 7),
(1031, 10), (1031, 11),
(1032, 13), (1032, 20),
(1032, 5), (1032, 23),
(1032, 24), (1033, 20),
(1033, 21), (1033, 26),
(1033, 27),
(1034, 29), (1034, 27),
(1034, 28)

INSERT INTO [Osoby niebezpieczne] VALUES
('FN645678' , 'Aleksandr', 'Fibonacci'),
('KK334556' , 'Jan', 'Kordemski'),
('4455284L' , 'Ann', 'Brown'),
('OP569832' , 'Otto', 'Den'),
('UU4567TR' , 'Witold', 'Kwiek'),
('FE789678' , 'Józef', 'Kuniek'),
('PR324500' , 'Aleks', 'Mederski'),
('HP345289' , 'Ludowik', 'Olivier')

INSERT INTO PASAZER VALUES
(1, 'GH454747' , 'Jan', 'Bieler', 'Niemcy'),
(2, 'GH565755' , 'Mia', 'Krause', 'Niemcy'),
(3, 'UJ746235' , 'Emma', 'Remus', 'Wielka Brytania'),
(4, 'KF84U3P2' , 'Marie', 'Cooper', 'Stany Zjednoczone'),
(5, 'KC489920' , 'Lena', 'Red', 'Wielka Brytania'),
(6, 'KD894492' , 'Felix', 'Montgomery', 'Stany Zjednoczone'),
(7, 'DL482029' , 'Max', 'Simpson', 'Stany Zjednoczone'),
(8, 'EE372024' , 'Julian', 'Oldenburg', 'Luksemburg'),
(9, 'SS203039' , 'Witold', 'Kujawinski', 'Polska'),
(10, 'DL394753' , 'Włodzimierz', 'Michałek', 'Polska'),
(11, 'DL220395' , 'Szymon', 'Kwiek', 'Polska'),
(12, 'ZE3O3922' , 'Olga', 'Larek', 'Polska'),
(13, 'OJ844840' , 'Jarosław', 'Kwiatkowki', 'Polska'),
(14, 'VKR49394' , 'Ivan', 'Malychev', 'Rosja'),
(15, 'CL394849' , 'Tadeusz', 'Razmus', 'Ukraina'),
(16, 'DF444002' , 'Yaryna', 'Sych', 'Ukraina'),
(17, 'AA302MF3' , 'Harry', 'Coldman', 'Wielka Brytania'),
(18, '30493MMF' , 'Lucius', 'Malfoy', 'Wielka Brytania'),
(19, '23DOE333' , 'Taras', 'Petrenko', 'Ukraina'),
(20, 'RR394203' , 'Peter', 'Oldenburg', 'Luksemburg'),
(21, 'IJ444932' , 'Olivier', 'Twen', 'Francja'),
(22, 'FC389393' , 'Caton', 'de Cavi', 'Hiszpania'),
(23, 'WO483624' , 'Jose', 'de Pola', 'Hiszpania'),
(24, 'UE356832' , 'Emiliano', 'del Pozo', 'Hiszpania'),
(25, 'KE895398' , 'Petr', 'Vasylev', 'Rosja'),
(26, 'KD493920' , 'Nikolay', 'Tarnowski', 'Bialorus'),
(27, 'PR324500' , 'Aleks', 'Mederski', 'Bialorus'),
(28, 'AD204893' , 'Ku', 'Mur', 'Chiny'),
(29, 'DP299211' , 'Kin', 'Sin', 'Korea Poludniowa'),
(30, 'XPL93484' , 'Caton', 'Orevue', 'Francja'),
(31, 'AD204894', 'Piotr', 'Kotowski', 'Polska')

INSERT INTO [Klasa podrozy] VALUES
(1, 0.15), (2, 0.10) , 
(3, 0.05) , (4, 0.0)


INSERT INTO REZERWACJE VALUES
(0, 1000, 1, 1),
(1, 1001, 1, 2),
(2, 1001, 2, 4),
(3, 1034, 21, 1),
(4, 1005, 12, 3),
(5, 1000, 17, 2),
(6, 1001, 3, 2),
(7, 1001, 4, 4),
(8, 1023, 12, 3),
(9, 1031, 12, 3),
(10, 1007, 5, 1),
(11, 1008, 6, 2),
(12, 1009, 7, 4),
(13, 1010, 22, 1),
(14, 1011, 24, 3),
(15, 1012, 8, 2),
(16, 1011, 9, 2),
(17, 1013, 9, 4),
(18, 1012, 10, 3),
(19, 1017, 11, 3),
(20, 1000, 14, 1),
(21, 1001, 15, 2),
(22, 1001, 26, 4),
(23, 1034, 20, 1),
(24, 1005, 19, 3),
(25, 1031, 17, 2),
(26, 1001, 18, 2),
(27, 1001, 30, 4),
(28, 1023, 10, 3),
(29, 1005, 16, 3),
(30, 1007, 18, 1),
(31, 1009, 22, 2),
(32, 1001, 23, 4),
(33, 1033, 28, 1),
(34, 1015, 20, 3),
(35, 1016, 29, 2),
(36, 1018, 30, 2),
(37, 1013, 14, 4),
(38, 1010, 17, 3),
(39, 1023, 7, 3),
(40, 1034, 13, 1),
(41, 1030, 25, 3),
(42, 1000, 31, 1),
(43, 1032, 27, 3)


INSERT INTO BAGAZ VALUES
(0, 0, 5.34),
(1, 0, 12.4),
(1, 1, 2),
(3, 0, 10.6),
(4, 0, 23.12),
(5, 0, 1.56),
(5, 1, 10.3),
(5, 2, 12.4),
(7, 0, 5.3),
(9, 0, 6.4),
(10, 0, 2.2),
(11, 0, 2.2),
(12, 0, 3.4),
(12, 1, 4.0),
(14, 0, 7.8),
(15, 0, 10.1),
(16, 0, 9.8),
(16, 1, 23.45),
(18, 0, 24.8),
(19, 0, 11.0),
(20, 0, 9.7),
(21, 0, 18.9),
(21, 1, 78),
(23, 0, 5.5),
(24, 0, 3.9),
(25, 0, 4.5),
(25, 1, 4.5),
(25, 2, 5.6),
(25, 3, 6.1),
(29, 0, 5.9),
(30, 0, 4.9),
(31, 0, 7.8),
(31, 1, 8.1),
(33, 0, 7),
(34, 0, 6.7),
(35, 0, 8),
(35, 1, 3.4),
(37, 0, 13.9),
(37, 1, 2.1),
(39, 0, 23.2),
(40, 0, 44.77),
(41, 0, 7.9),
(41, 1, 8.0),
(43, 0, 1.2)

--Powyżej 100 nie obsługujemy w pasazerskich samolotach
INSERT INTO CENNIK_BAGAZY VALUES
(1, 15) , (5, 20), 
(10, 30) , (15, 45),
(20, 50) , (25, 75),
(30, 100), (35, 125),
(45, 150), (60, 175),
(80, 200), (100, 250)
