
--ALTER DATABASE EncuestaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

GO

--opcional
--DROP DATABASE IF EXISTS EncuestaDB;

GO

--opcional
--CREATE DATABASE EncuestaDB;

GO

USE EncuestaDB;

DROP TABLE IF EXISTS Respuesta ;

GO

USE EncuestaDB;

DROP TABLE IF EXISTS Respuestas;

CREATE TABLE Respuestas(
    Id INT PRIMARY KEY IDENTITY, 
    Tipo_Transporte INT,
    Distancia_Recorrida DECIMAL(18,2),
    Domicilio_Origen NVARCHAR(50),
    Domicilio_Destino NVARCHAR(50),
    Email NVARCHAR(50)
)

GO

INSERT INTO Respuestas(Tipo_transporte, Distancia_Recorrida, Domicilio_Origen, Domicilio_Destino , Email)
VALUES(1,4.00,'corrientes 2200','almafuerte 1033','anibal@gmail.com'),
(2,8.50,'artigas y gervacio mendez','almafuerte 1033','marta@gmail.com'),
(2, 6.60,'las lechiguanas 50','almafuerte 1033','cecilia@gmail.com'),
(2, 1.60,'Corrientes y 25 de mayor','almafuerte 1033','romina@gmail.com'),
(1, 0.70,'las lechiguanas 50','almafuerte 1033','gervacio@gmail.com'),
(2, 1.70,'las lechiguanas 50','almafuerte 1033','amelia@gmail.com')


GO

-- cantidad de poblacion encuestada


SELECT COUNT(*) as Cantidad
FROM Respuestas

GO

-- cantidad de personas por tipo de vehiculos

SELECT Tipo_Transporte, COUNT(*) as Cantidad
FROM Respuestas
GROUP BY Tipo_transporte

GO

--caso bicicleta
SELECT r.Tipo_Transporte, 
        CASE WHEN  r.Tipo_Transporte=1 THEN 'Bicicleta'
             WHEN  r.Tipo_Transporte=2 THEN 'Motocicleta' END AS Transporte,
        SUM(r.Distancia_Recorrida)/COUNT(*) AS Promedio
FROM Respuestas r
GROUP BY Tipo_transporte
HAVING Tipo_transporte in (1,2)


GO

