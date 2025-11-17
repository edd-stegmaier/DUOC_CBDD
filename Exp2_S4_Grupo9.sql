-- S4 Conciertos Chile S.A.
-- Grupo 9

---------------------------------------------------
--Caso 1: Listado de Trabajadores

SELECT 
    t.NOMBRE || ' ' || t.APPATERNO || ' ' || t.APMATERNO  AS "Nombre Completo Trabajador",
    REPLACE(TO_CHAR(t.NUMRUT,'99G999G999'), ',','.') || '-' ||t.DVRUT AS "RUT Trabajador",
    tt.DESC_CATEGORIA                     AS "Tipo Trabajador",
    UPPER(cc.NOMBRE_CIUDAD)               AS "Ciudad Trabajador",
    TO_CHAR(t.SUELDO_BASE, 'L99G999G999') AS "Sueldo Base"
FROM 
    TRABAJADOR t
LEFT JOIN TIPO_TRABAJADOR tt
    ON tt.ID_CATEGORIA = t.ID_CATEGORIA_T
LEFT JOIN COMUNA_CIUDAD cc
    ON cc.ID_CIUDAD = t.ID_CIUDAD
WHERE
    t.SUELDO_BASE BETWEEN 650000 AND 3000000
ORDER BY
    cc.NOMBRE_CIUDAD DESC, t.SUELDO_BASE ASC;

-----------------------------------------------------
--Caso 2: Listado Cajeros

SELECT
    REPLACE(TO_CHAR(t.NUMRUT,'99G999G999'), ',','.') || '-' ||t.DVRUT AS "RUT Trabajador",
    LOWER(t.NOMBRE) || ' ' || UPPER(t.APPATERNO) AS "Nombre Trabajador",
    COUNT(tc.NRO_TICKET)                         AS "Total Tickets",
    TO_CHAR(SUM(tc.MONTO_TICKET), 'L9G999G999')  AS "Total Vendido",
    TO_CHAR(SUM(ct.VALOR_COMISION), 'L999G999')  AS "Comision Total",
    tt.DESC_CATEGORIA                            AS "Tipo Trabajador",
    UPPER(cc.NOMBRE_CIUDAD)                      AS "Ciudad Trabajador"
FROM
    TRABAJADOR t
LEFT JOIN COMUNA_CIUDAD cc
    ON cc.ID_CIUDAD = t.ID_CIUDAD
LEFT JOIN TIPO_TRABAJADOR tt
    ON tt.ID_CATEGORIA = t.ID_CATEGORIA_T
INNER JOIN TICKETS_CONCIERTO tc 
    ON tc.NUMRUT_T = t.NUMRUT
INNER JOIN COMISIONES_TICKET ct 
    ON ct.NRO_TICKET = tc.NRO_TICKET
HAVING
    SUM(tc.MONTO_TICKET) > 50000
GROUP BY
    t.NUMRUT,
    t.DVRUT,
    t.NOMBRE,
    t.APPATERNO,
    t.APMATERNO,
    tt.DESC_CATEGORIA,
    UPPER(cc.NOMBRE_CIUDAD)
ORDER BY
    SUM(tc.MONTO_TICKET) DESC;

-----------------------------------------------------
--Caso 3: Listado de Bonificaciones

SELECT
    --aparecieron unos trabajadores repetidos

    REPLACE(TO_CHAR(t.NUMRUT,'99G999G999'), ',','.') || '-' ||t.DVRUT AS "RUT Trabajador",
    INITCAP(LOWER(t.NOMBRE)) || ' ' || INITCAP(LOWER(t.APPATERNO)) AS "Trabajador Nombre",
    EXTRACT(YEAR FROM t.FECING)           AS "Año Ingreso",
    EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.FECING) AS "Años Antiguedad",
    NVL(COUNT(DISTINCT af.NUMRUT_CARGA), '0')       AS "Num. Cargas Familiares",
    i.NOMBRE_ISAPRE                       AS "Nombre Isapre",
    TO_CHAR(t.SUELDO_BASE, 'L99G999G999') AS "Sueldo Base",
    --Bono Fonasa
    (CASE
        WHEN UPPER(i.NOMBRE_ISAPRE)='FONASA' THEN TO_CHAR(ROUND(t.SUELDO_BASE*0.01), 'L999G999') 
        ELSE '0' 
    END) AS "Bono Fonasa",
    --Bono Antiguedad
    (CASE
        WHEN (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.FECING)) <= 10 
            THEN TO_CHAR(ROUND(t.SUELDO_BASE*0.1), 'L999G999')
        WHEN (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.FECING)) >= 11 
            THEN TO_CHAR(ROUND(t.SUELDO_BASE*0.15), 'L999G999')
    END) AS "Bono Antiguedad",
    a.NOMBRE_AFP                          AS "Nombre AFP",
    UPPER(ec.DESC_ESTCIVIL)               AS "Estado Civil"
FROM
    TRABAJADOR t
LEFT JOIN ASIGNACION_FAMILIAR af
    ON af.NUMRUT_T = t.NUMRUT
LEFT JOIN ISAPRE i USING (COD_ISAPRE)
LEFT JOIN AFP    a USING (COD_AFP)
LEFT JOIN EST_CIVIL e 
    ON e.NUMRUT_T = t.NUMRUT
    AND (e.fecter_estcivil IS NULL OR e.fecter_estcivil > SYSDATE)
LEFT JOIN ESTADO_CIVIL ec 
    ON ec.ID_ESTCIVIL = e.ID_ESTCIVIL_EST
GROUP BY
    t.NUMRUT, t.DVRUT,
    t.NOMBRE, t.APPATERNO,
    t.FECING, t.SUELDO_BASE,
    af.NUMRUT_CARGA,
    i.NOMBRE_ISAPRE,
    a.NOMBRE_AFP,
    e.FECTER_ESTCIVIL,
    ec.DESC_ESTCIVIL
ORDER BY
    NUMRUT ASC;

