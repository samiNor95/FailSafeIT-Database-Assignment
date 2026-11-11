# FailSafe IT – Inlämningsuppgift 1

## Projektbeskrivning

Detta projekt innehåller en relationsdatabas för konsultföretaget FailSafe IT, byggd i Microsoft SQL Server.

Databasen består av tre tabeller: **Kunder**, **Konsulter** och **Uppdrag**. Varje uppdrag kopplas till en kund och en konsult genom främmande nycklar.

Projektet innehåller ett ER-diagram, ett SQL-skript med testdata och SQL-frågor samt en kort beskrivning av normalisering och DevSecOps-säkerhet.

## Databasdesign och normalisering (3NF)

**Första normalformen (1NF):** Varje tabell har en primärnyckel och varje kolumn innehåller ett enskilt värde. Det finns inga upprepade kolumngrupper.

**Andra normalformen (2NF):** Databasen uppfyller 1NF och alla icke-nyckelattribut beror på hela primärnyckeln. Varje tabell använder en enkel primärnyckel, exempelvis KundID eller KonsultID.

**Tredje normalformen (3NF):** Databasen uppfyller 2NF och de icke-nyckelattribut som lagras beror på tabellens nyckel, inte på andra icke-nyckelattribut. Kunduppgifter lagras i Kunder, konsultuppgifter i Konsulter och uppdragsspecifika uppgifter i Uppdrag. Detta minskar risken för duplicerad data och uppdateringsfel.

## DevSecOps-reflektion

### Sec – Skydd mot SQL Injection

För att skydda applikationen mot SQL Injection använder jag parametriserade SQL-frågor, så att användarens inmatning behandlas som data i stället för körbar SQL-kod. Jag begränsar även databasbehörigheter enligt principen Least Privilege.

### Ops – Prestanda och indexering

Jag använder ett unikt index på Organisationsnummer i tabellen Kunder för att göra sökningar efter specifika organisationsnummer effektiva även när databasen växer. Indexet hjälper SQL Server att hitta rätt kund utan att behöva läsa igenom hela tabellen.

## Projektfiler

- **FailSafeIT_Inlamning1.sql** – SQL-skript med tabeller, testdata och frågor A–E.
- **FailSafe IT - ER Diagram.pdf** – ER-diagram med primärnycklar, främmande nycklar och relationer.

## Verktyg

Microsoft SQL Server, SQL Server Management Studio (SSMS), Lucidchart och GitHub.
