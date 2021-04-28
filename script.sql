-- Database: SKY

-- DROP DATABASE "SKY";

CREATE DATABASE "SKY"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
	
	----------- création de la table clients-----------
 CREATE TABLE Clients(
        numPass VARCHAR(9) PRIMARY KEY, 
	nom VARCHAR(255) NOT NULL UNIQUE,
 	ville VARCHAR(255) NOT NULL
 );

------------ création de la table RESERVATIONS -----------
   CREATE TABLE Reservations(
         numR NUMERIC(11) PRIMARY KEY, 
  	 date_arrivée date NOT NULL,  
  	 date_départ date,
	 numPass VARCHAR(9),
	 numC NUMERIC(11),
	   	CONSTRAINT fk_reservation FOREIGN KEY(numPass) REFERENCES Clients(numPass) ON DELETE CASCADE ON UPDATE CASCADE,
		CONSTRAINT fk_chambres FOREIGN KEY(numC) REFERENCES Chambres(numC) ON DELETE CASCADE ON UPDATE CASCADE

  );
------------ création de la table CHAMBRES-----------
 CREATE TABLE Chambres(
         numC NUMERIC(11) PRIMARY KEY, 
         lits NUMERIC(11) NOT NULL DEFAULT 2,
         prix NUMERIC(11) NOT NULL
);

----------------------insertion des tables " Client" ----------------------
INSERT INTO Clients VALUES ('ABC123','JOHN DOO','Agadir');
INSERT INTO Clients VALUES ('Ajh303','JOHN DOOO','Youssoufia');
INSERT INTO Clients VALUES ('BFH143','JOHN DOOOO','Safi');
INSERT INTO Clients VALUES ('KLM456','JOHN DOOOOO','Rabat');
INSERT INTO Clients VALUES ('JHZ231','JOHN DOOOOOO','Sidi ifni');
INSERT INTO Clients VALUES ('CBA198','JOHN DOOOOOOO','Casablanca');

----------------------insertion des tables " Chambres "----------------------
INSERT INTO Chambres VALUES (1,2,800);
INSERT INTO Chambres VALUES (2,1,600);
INSERT INTO Chambres VALUES (3,3,1000);
INSERT INTO Chambres VALUES (4,2,800);
INSERT INTO Chambres VALUES (5,1,600);
INSERT INTO Chambres VALUES (6,4,1100);
INSERT INTO Chambres VALUES (7,3,800);
INSERT INTO Chambres VALUES (8,2,700);

----------------------insertion des tables " Reservations"----------------------
INSERT INTO Reservations VALUES (1,1,'27/04/2021','01/05/2021','CBA198');
INSERT INTO Reservations VALUES (2,1,'27/04/2021','03/05/2021','CBA198');
INSERT INTO Reservations VALUES (3,2,'27/04/2021','04/05/2021','Ajh303');
INSERT INTO Reservations VALUES (4,3,'27/04/2021','07/05/2021','BFH143');
INSERT INTO Reservations VALUES (5,4,'27/04/2021','08/05/2021','KLM456');
INSERT INTO Reservations VALUES (6,5,'27/04/2021','02/05/2021','JHZ231');
INSERT INTO Reservations VALUES (7,6,'27/04/2021','08/05/2021','ABC123');
INSERT INTO Reservations VALUES (8,7,'27/04/2021','02/05/2021','ABC123');



	
SELECT * FROM "Clients"
SELECT * FROM "Chambres"
SELECT * FROM public."Reservations"

-- //First Function 
CREATE or replace FUNCTION chambresRéservées ()
RETURNS TABLE(numC NUMERIC(11) ,lits NUMERIC(11),prix NUMERIC(11)) as $list$

BEGIN
    RETURN QUERY SELECT
     ch.*
    FROM
     "Chambres" AS ch,"Reservations" AS r
     WHERE ch."numC"=r."numC" AND EXTRACT(MONTH FROM r."départ")=08
	 GROUP BY ch."numC";
END; 
$list$ LANGUAGE 'plpgsql';


-- Function 2

CREATE or replace FUNCTION ListClient ()
RETURNS TABLE(numPass VARCHAR ,nom varchar,ville varchar) as $list$

BEGIN
    RETURN QUERY SELECT
     cl.*
    FROM
     "Chambres" AS ch,"Reservations" AS r,"Clients" AS cl
     WHERE ch."numC"=r."numC" AND r."numPass" = cl."numPass" AND ch."prix">700
	 GROUP BY cl."numPass";
END; 
$list$ LANGUAGE 'plpgsql';

-- 

-- Function 3

CREATE or replace FUNCTION chambresRéservéesParClient ()
RETURNS TABLE(numC NUMERIC(11) ,lits NUMERIC(11),prix NUMERIC(11)) as $list$

BEGIN
    RETURN QUERY SELECT
     ch.*
    FROM
     "Chambres" AS ch,"Reservations" AS r,"Clients" AS cl
     WHERE ch."numC"=r."numC" AND r."numPass" = cl."numPass" AND cl.nom Like'A%'
	 GROUP BY ch."numC";
END; 
$list$ LANGUAGE 'plpgsql';

-- 
-- 
-- FUNCTION 4
CREATE or replace FUNCTION clientsRéservées ()
RETURNS TABLE(numPass VARCHAR ,nom varchar,ville varchar) as $list$

BEGIN
    RETURN QUERY SELECT 
     cl.*
    FROM
     "Chambres" AS ch, "Reservations" AS r,"Clients" AS cl
     WHERE ch."numC"= r."numC" AND r."numPass" = cl."numPass" 
	 GROUP BY cl."numPass"
	having count(ch."numC")>2;
END; 
$list$ LANGUAGE 'plpgsql';

-- 
-- 
-- 
-- FUNCTION 5
CREATE or replace FUNCTION clientsHabitent ()
RETURNS TABLE(numPass VARCHAR ,nom varchar,ville varchar) as $list$

BEGIN
    RETURN QUERY SELECT 
     cl.*
    FROM
     "Chambres" AS ch, "Reservations" AS r,"Clients" AS cl
     WHERE ch."numC"= r."numC" AND r."numPass" = cl."numPass" AND cl."ville"='Casablanca' 
	 GROUP BY cl."numPass"
	having count(ch."numC")>2 AND count(r."numPass")>2 ;
END; 
$list$ LANGUAGE 'plpgsql';

-- 
-- 
-- PROCEDURE 6
create or replace procedure ModifierPrix()
language plpgsql    
as $update$
begin
    -- subtracting the amount from the sender's account 
    update "Chambres" 
    set prix = 1000 
    where prix >= 700;
end;$update$


-- PROCEDURE 7
create or replace procedure supprimerClient()
language plpgsql    
as $delete$
begin
    -- subtracting the amount from the sender's account 
    delete from "Clients" WHERE "Clients"."numPass" Not in(select "numPass" FROM "Reservations" );
end;$delete$

-- 
-- 
-- Procedure 8

create or replace procedure ModifierPrixPourLits()
language plpgsql    
as $updatePrice$
begin
    -- subtracting the amount from the sender's account 
    update "Chambres" 
    set prix = prix - 100
    where lits > 2;
end;$updatePrice$


CALL ModifierPrixPourLits()
CALL supprimerClient()
CALL ModifierPrix()





