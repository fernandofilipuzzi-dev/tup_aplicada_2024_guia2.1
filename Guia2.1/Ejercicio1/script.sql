
--ALTER DATABASE EncuestaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

--GO

--opcional
DROP DATABASE IF EXISTS EncuestaDB;

GO

--opcional
CREATE DATABASE EncuestaDB;

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
VALUES(1,4.50,'corrientes 2200','almafuerte 1033','anibal@gmail.com'),
(2, 8.50,'artigas y gervacio mendez','almafuerte 1033','marta@gmail.com'),
(2, 6.60,'las lechiguanas 50','almafuerte 1033','cecilia@gmail.com'),
(2, 1.00,'Corrientes y 25 de mayor','almafuerte 1033','romina@gmail.com'),
(1, 1.00,'las lechiguanas 50','almafuerte 1033','gervacio@gmail.com'),
(2, 1.00,'las lechiguanas 50','almafuerte 1033','amelia@gmail.com')

--select * from Respuestas

--select sum(Distancia_Recorrida) from Respuestas where Tipo_Transporte=2

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

--Distancia promedio recorrida para cada tipo de transporte entre todos los viajes realizados
DECLARE @Cantidad INT =0;
SELECT @Cantidad =COUNT(*) FROM Respuestas;

SELECT r.Tipo_Transporte, 
        CASE WHEN  r.Tipo_Transporte=1 THEN 'Bicicleta'
             WHEN  r.Tipo_Transporte=2 THEN 'Motocicleta'
             WHEN  r.Tipo_Transporte=3 THEN 'Automovil' 
             WHEN  r.Tipo_Transporte=4 THEN 'Transporte público' END AS Transporte,
         CONVERT(DECIMAL(18,2),SUM(r.Distancia_Recorrida)/@Cantidad) AS Promedio
FROM Respuestas r
GROUP BY Tipo_transporte
--HAVING Tipo_transporte in (1,2)


GO

-- incluir todos los casos cuando es cero

--como no tengo la tabla de tipos  me valgo de una variable de tabla
DECLARE @Tipos_Transporte TABLE 
( 
    Id INT, 
    Descripcion NVARCHAR(50)
)
INSERT INTO @Tipos_Transporte(Id, Descripcion)
VALUES(1,'Bicicleta'),
(2,'Motocicleta'),
(3,'Automóvil'),
(4,'Transporte público')

DECLARE @Cantidad INT =0;
SELECT @Cantidad =COUNT(*) FROM Respuestas;

SELECT tt.Descripcion,  CONVERT(DECIMAL(18,2),SUM(  ISNULL(r.Distancia_Recorrida,0))/ @Cantidad) AS Promedio
FROM @Tipos_Transporte tt 
LEFT JOIN Respuestas r ON r.Tipo_Transporte=tt.Id
GROUP BY tt.Descripcion

select  @Cantidad 

--SELECT tt.Descripcion,  SUM(  r.Distancia_Recorrida) as total
--FROM @Tipos_Transporte tt 
--LEFT JOIN Respuestas r ON r.Tipo_Transporte=tt.Id
--GROUP BY tt.Descripcion

GO

DROP PROCEDURE IF EXISTS Calcular_Promedio_DistanciaPromedio_En_Viajes_Por_Tipo

GO
--con cursores en un sp para jugar un poco - logica procedimental

CREATE PROCEDURE Calcular_Promedio_DistanciaPromedio_En_Viajes_Por_Tipo
AS
BEGIN
     
   DECLARE @Id_Respuesta INT;  
   DECLARE @Tipo_Transporte INT;  
   DECLARE @Distancia DECIMAL(18,2);  
   DECLARE Cursor_Respuesta CURSOR FOR SELECT Id,Tipo_Transporte,Distancia_Recorrida FROM Respuestas;

   OPEN Cursor_Respuesta;
    
   FETCH NEXT FROM Cursor_Respuesta INTO @Id_Respuesta, @Tipo_Transporte,@Distancia;

   DECLARE @Contador_Respuesta INT=0
   DECLARE @Distancia_Bicicleta DECIMAL(18,2)=0
   DECLARE @Distancia_Moto DECIMAL(18,2)=0
   DECLARE @Distancia_Auto DECIMAL(18,2)=0
   DECLARE @Distancia_Publico DECIMAL(18,2)=0

   WHILE @@FETCH_STATUS=0
   BEGIN
     
    SET @Contador_Respuesta=@Contador_Respuesta+1;

    IF @Tipo_Transporte=1 
        SET @Distancia_Bicicleta=@Distancia_Bicicleta+@Distancia;
    ELSE IF  @Tipo_Transporte=2 
        SET @Distancia_Moto=@Distancia_Moto+@Distancia;
    ELSE IF  @Tipo_Transporte=3 
        SET @Distancia_Auto=@Distancia_Auto+@Distancia;
    ELSE IF  @Tipo_Transporte=4 
        SET @Distancia_Publico=@Distancia_Publico+@Distancia;

    FETCH NEXT FROM Cursor_Respuesta INTO @Id_Respuesta, @Tipo_Transporte, @Distancia;
   END

   SELECT 'Bicicleta' as Descripcion, CONVERT(DECIMAL(18,2), @Distancia_Bicicleta/@Contador_Respuesta) as Promedio
   UNION
   SELECT 'Motocicleta' as Descripcion,  CONVERT(DECIMAL(18,2),@Distancia_Moto/@Contador_Respuesta) as Promedio
   UNION
   SELECT 'Automóvil' as Descripcion,  CONVERT(DECIMAL(18,2), @Distancia_Auto/@Contador_Respuesta) as Promedio
   UNION
   SELECT 'Transporte público' as Descripcion,   CONVERT(DECIMAL(18,2),@Distancia_Publico/@Contador_Respuesta) as Promedio

   CLOSE Cursor_Respuesta

   DEALLOCATE cursor_Respuesta

END


GO

EXEC Calcular_Promedio_DistanciaPromedio_En_Viajes_Por_Tipo
