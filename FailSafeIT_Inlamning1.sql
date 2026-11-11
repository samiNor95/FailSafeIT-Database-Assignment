-- FailSafe IT - Inlamningsuppgift 1
-- Microsoft SQL Server / LocalDB
-- This script creates its own separate database to avoid changing the practice database.
-- Run once in SSMS against (localdb)\MSSQLLocalDB.

USE master;
GO
IF DB_ID(N'FailSafeIT_Inlamning1_Repo') IS NOT NULL
BEGIN
    THROW 50001, 'FailSafeIT_Inlamning1_Repo already exists. The script stopped to protect existing data.', 1;
END;
GO
CREATE DATABASE FailSafeIT_Inlamning1_Repo;
GO
USE FailSafeIT_Inlamning1_Repo;
GO

-- DEL 2.1: DDL - Tabellen Kunder
CREATE TABLE dbo.Kunder (
    KundID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Organisationsnummer VARCHAR(20) NOT NULL UNIQUE,
    Foretagsnamn NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Telefonnummer VARCHAR(20) NOT NULL
);

-- Tabellen Konsulter
CREATE TABLE dbo.Konsulter (
    KonsultID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Personnummer VARCHAR(13) NOT NULL UNIQUE,
    Namn NVARCHAR(100) NOT NULL,
    Timpris DECIMAL(10,2) NOT NULL,
    Specialitet NVARCHAR(100) NOT NULL,
    CONSTRAINT CK_Konsulter_Timpris CHECK (Timpris >= 0)
);

-- Tabellen Uppdrag: varje uppdrag har en kund och en konsult
CREATE TABLE dbo.Uppdrag (
    UppdragID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    KundID INT NOT NULL,
    KonsultID INT NOT NULL,
    Startdatum DATE NOT NULL,
    Slutdatum DATE NOT NULL,
    Rollbeskrivning NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_Uppdrag_Kunder FOREIGN KEY (KundID) REFERENCES dbo.Kunder(KundID),
    CONSTRAINT FK_Uppdrag_Konsulter FOREIGN KEY (KonsultID) REFERENCES dbo.Konsulter(KonsultID),
    CONSTRAINT CK_Uppdrag_Datum CHECK (Slutdatum >= Startdatum)
);
GO

-- DEL 2.2: DML - Fiktiva testdata
-- Organisationsnummer, personnummer, e-post och kontaktuppgifter ar exempeldata.
INSERT INTO dbo.Kunder (Organisationsnummer, Foretagsnamn, Email, Telefonnummer)
VALUES
    ('556123-4567', N'Nordic Tech AB', 'info@nordictech.example', '031-123456'),
    ('559234-5678', N'Secure Cloud AB', 'kontakt@securecloud.example', '08-456789'),
    ('556345-6789', N'Green Energy AB', 'info@greenenergy.example', '040-987654');

INSERT INTO dbo.Konsulter (Personnummer, Namn, Timpris, Specialitet)
VALUES
    ('19900101-1234', N'Ahmed Hassan', 1500.00, N'Cybersecurity'),
    ('19920315-5678', N'Sara Nilsson', 1100.00, N'DevOps'),
    ('19880520-9012', N'Erik Andersson', 1350.00, N'C# Developer');

INSERT INTO dbo.Uppdrag (KundID, KonsultID, Startdatum, Slutdatum, Rollbeskrivning)
VALUES
    (1, 1, '20260110', '20260630', N'Säkerhetsgranskning av API-miljö'),
    (2, 2, '20260201', '20260831', N'DevOps och CI/CD-automatisering'),
    (3, 3, '20260301', '20261231', N'Utveckling av C#-applikation'),
    (1, 2, '20260401', '20261130', N'Molninfrastruktur och övervakning'),
    (2, 1, '20260515', '20261215', N'Penetrationstest och säkerhetsanalys');
GO

-- DEL 2.3 - Fraga A: Konsulter med timpris over 1200, dyrast forst
SELECT Namn, Timpris
FROM dbo.Konsulter
WHERE Timpris > 1200
ORDER BY Timpris DESC;

-- Fraga B: Alla uppdrag med kund, konsult och datum
SELECT
    k.Foretagsnamn,
    c.Namn AS Konsult,
    u.Startdatum,
    u.Slutdatum
FROM dbo.Uppdrag AS u
INNER JOIN dbo.Kunder AS k ON u.KundID = k.KundID
INNER JOIN dbo.Konsulter AS c ON u.KonsultID = c.KonsultID
ORDER BY u.UppdragID;

-- Fraga C: Antal registrerade uppdrag per kund, aven kunder utan uppdrag
-- 'Aktiva i systemet totalt' tolkas som alla registrerade uppdrag, inte bara datumaktiva.
SELECT
    k.Foretagsnamn,
    COUNT(u.UppdragID) AS AntalUppdrag
FROM dbo.Kunder AS k
LEFT JOIN dbo.Uppdrag AS u ON k.KundID = u.KundID
GROUP BY k.KundID, k.Foretagsnamn
ORDER BY AntalUppdrag DESC, k.Foretagsnamn;

-- Fraga D: Andra timpriset for en bestamd konsult
UPDATE dbo.Konsulter
SET Timpris = 1250.00
WHERE KonsultID = 2;
SELECT KonsultID, Namn, Timpris FROM dbo.Konsulter WHERE KonsultID = 2;

-- Fraga E: Radera en kund om inga uppdrag ar kopplade till kunden.
-- Skapa forst en separat testkund som inte har nagra uppdrag.
INSERT INTO dbo.Kunder (Organisationsnummer, Foretagsnamn, Email, Telefonnummer)
VALUES ('559999-1234', N'Test Kund AB', 'test@example.com', '070-1234567');

DELETE FROM dbo.Kunder
WHERE Organisationsnummer = '559999-1234'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Uppdrag AS u
      WHERE u.KundID = Kunder.KundID
  );

-- Verifiering: tre kunder, tre konsulter, fem uppdrag ska finnas kvar.
SELECT (SELECT COUNT(*) FROM dbo.Kunder) AS AntalKunder,
       (SELECT COUNT(*) FROM dbo.Konsulter) AS AntalKonsulter,
       (SELECT COUNT(*) FROM dbo.Uppdrag) AS AntalUppdrag;
GO
