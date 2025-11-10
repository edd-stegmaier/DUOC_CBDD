-- S3 sumativa Asociados Corredora de Propiedades
-- Eduardo Stegmaier

--Caso 1: Listado de clientes con Rango renta

SELECT
    -- Formateo del RUT
    TO_CHAR(numrut_cli, 'L999G999G999') || '-' || dvrut_cli AS "RUT Cliente",
    INITCAP(nombre_cli) || ' ' || INITCAP(appaterno_cli) || ' ' || INITCAP(apmaterno_cli)  AS "Nombre Completo Cliente",
    direccion_cli AS "Direccion Cliente",

    TO_CHAR(renta_cli, 'L9G999G999') AS "Renta Cliente",

    -- Celular
    REGEXP_REPLACE(LPAD(TO_CHAR(celular_cli), 9, '0'), '(\d{2})(\d{3})(\d{4})', '\1-\2-\3') AS "Celular Cliente",

    --Trama
    (CASE
        WHEN renta_cli > 500000 THEN 'TRAMO 1'
        WHEN renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        WHEN renta_cli BETWEEN 0 AND 199999 THEN 'TRAMO 4'
    END) AS "Trama Renta Cliente"

FROM
    cliente
WHERE 
    celular_cli is not NULL AND renta_cli >= &RENTA_MINIMA AND renta_cli <= &RENTA_MAXIMA
ORDER BY  
    nombre_cli || ' ' || appaterno_cli || ' ' || apmaterno_cli;


---------------------------------------------------------------
-- Caso 2: Sueldo Promedio por Categoria de Empleado

SELECT 
    id_categoria_emp AS "CODIGO CATEGORIA",
    
    --Descripcion categoria
    (CASE id_categoria_emp

        WHEN 1 THEN 'Gerente'
        WHEN 2 THEN 'Supervisor'
        WHEN 3 THEN 'Ejecutivo de Arriendo'
        WHEN 4 THEN 'Auxiliar'
        ELSE 'Otro'

    END) AS "DESCRIPCION CATEGORIA",
    
    COUNT(numrut_emp) AS "CANTIDAD EMPLEADOS",

    --Sucursal
    (CASE id_sucursal
    
        WHEN 10 THEN 'Sucursal Las Condes'
        WHEN 20 THEN 'Sucursal Santiago Centro'
        WHEN 30 THEN 'Sucursal Providencia'
        WHEN 40 THEN 'Sucursal Vitacura'
        ELSE 'Otro'

    END) AS "SUCURSAL",

    TO_CHAR(AVG(sueldo_emp), 'L9G999G999') AS "SUELDO PROMEDIO"

FROM 
    empleado 
HAVING
    AVG(sueldo_emp) > &SUELDO_PROMEDIO_MINIMO
GROUP BY
    id_sucursal, ID_CATEGORIA_EMP
ORDER BY
    AVG(sueldo_emp) DESC;


----------------------------------------------------------
-- Caso 3: Arriendo Promedio por Tipo de Propiedad

SELECT 
    id_tipo_propiedad AS "CODIGO TIPO",

    -- Descripcion tipo
    CASE id_tipo_propiedad
        WHEN 'A' THEN 'CASA'
        WHEN 'B' THEN 'DEPARTAMENTO'
        WHEN 'C' THEN 'LOCAL'
        WHEN 'D' THEN 'PARCELA SIN CASA'
        WHEN 'E' THEN 'PARCELA CON CASA'
        ELSE 'Otro'

    END AS "DESCRIPCION TIPO",

    COUNT (nro_propiedad) AS "TOTAL PROPIEDADES",
    TO_CHAR(ROUND(AVG(valor_arriendo)), 'L9G999G999') AS "PROMEDIO ARRIENDO",
    ROUND(AVG(superficie), 2)AS "PROMEDIO SUPERFICIE",
    TO_CHAR(ROUND(AVG(valor_arriendo/superficie)), 'L9G999G999') AS "VALOR ARRIENDO M2",
    
    --Clasificacion
    (CASE
        WHEN AVG(valor_arriendo/superficie) < 5000 THEN 'Economico'
        WHEN AVG(valor_arriendo/superficie) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Alto'

    END) AS "CLASIFICACION"

FROM
    propiedad
HAVING
    AVG(valor_arriendo/superficie)  > 1000
GROUP BY
    id_tipo_propiedad
ORDER BY
    AVG(valor_arriendo/superficie) DESC;
    


