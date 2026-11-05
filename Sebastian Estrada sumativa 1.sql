SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK ON
SET PAGESIZE 100
SET LINESIZE 220

/* CASO 1 */

SELECT
    UPPER(tp.desc_tipo_propiedad) AS TIPO,
    COUNT(p.nro_propiedad) AS TOTAL_PROPIEDADES,
    TO_CHAR(
        ROUND(MAX(p.valor_arriendo)),
        'FML999G999G999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS MAX_ARRIENDO,
    TO_CHAR(
        ROUND(AVG(p.valor_arriendo)),
        'FML999G999G999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS PROMEDIO_ARRIENDO,
    TO_CHAR(
        ROUND(MIN(p.valor_arriendo)),
        'FML999G999G999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS MIN_ARRIENDO,
    CASE
        WHEN MAX(p.valor_arriendo) > 1000000 THEN 'PREMIUM'
        ELSE 'ESTANDAR'
    END AS CLASIFICACION,
    TO_CHAR(
        ROUND(SUM(NVL(p.valor_gasto_comun, 0))),
        'FML999G999G999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS TOTAL_GASTOS_COMUNES
FROM propiedad p
INNER JOIN tipo_propiedad tp
    ON p.id_tipo_propiedad = tp.id_tipo_propiedad
GROUP BY
    tp.desc_tipo_propiedad
HAVING
    SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY
    SUM(NVL(p.valor_gasto_comun, 0)) DESC;

/* CASO 2 */

SELECT
    UPPER(
        TRIM(
            e.nombre_emp || ' ' ||
            e.appaterno_emp || ' ' ||
            NVL(e.apmaterno_emp, '')
        )
    ) AS "NOMBRE EMPLEADO",
    TO_CHAR(
        ROUND(e.sueldo_emp),
        'FML999G999G999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS "SUELDO CON FORMATO",
    CASE
        WHEN e.sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "CLASIFICACION SUELDO",
    TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), e.fecing_emp) / 12)
        AS "ANOS ANTIGUEDAD",
    CASE
        WHEN TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), e.fecing_emp) / 12)
             BETWEEN 5 AND 10
        THEN
            'Corresponde bono 5%: ' ||
            TO_CHAR(
                ROUND(e.sueldo_emp * 0.05),
                'FML999G999G999G999G990',
                'NLS_NUMERIC_CHARACTERS = '',.'''
            )
        WHEN TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), e.fecing_emp) / 12)
             BETWEEN 11 AND 20
        THEN
            'Corresponde bono 10%: ' ||
            TO_CHAR(
                ROUND(e.sueldo_emp * 0.10),
                'FML999G999G999G999G990',
                'NLS_NUMERIC_CHARACTERS = '',.'''
            )
        WHEN TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), e.fecing_emp) / 12) > 20
        THEN
            'Corresponde bono 15%: ' ||
            TO_CHAR(
                ROUND(e.sueldo_emp * 0.15),
                'FML999G999G999G999G990',
                'NLS_NUMERIC_CHARACTERS = '',.'''
            )
        ELSE
            'Sin bono'
    END AS BONO
FROM empleado e
WHERE
    e.id_categoria_emp = 3
    AND e.id_sucursal <> &CODIGO_SUCURSAL
    AND e.fecing_emp IS NOT NULL
    AND TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), e.fecing_emp) / 12) > 5
ORDER BY
    e.sueldo_emp DESC;

/* CASO 3 */

SELECT
    CASE
        WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN c.renta_cli >= 600000 THEN 'ALTA'
        WHEN c.renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS CLASIFICACION_RENTA,
    COUNT(c.numrut_cli) AS CANTIDAD_CLIENTES,
    TO_CHAR(
        ROUND(AVG(c.renta_cli)),
        'FML999G999G999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS RENTA_PROMEDIO,
    CASE
        WHEN COUNT(c.fono_fijo_cli) + COUNT(c.celular_cli) = 0
        THEN 'Clientes Sin Telefono'
        ELSE 'Clientes con Telefono'
    END AS ESTADO_TELEFONO
FROM cliente c
WHERE
    c.renta_cli IS NOT NULL
GROUP BY
    CASE
        WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN c.renta_cli >= 600000 THEN 'ALTA'
        WHEN c.renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END
HAVING
    AVG(c.renta_cli) > 200000
ORDER BY
    CASE CLASIFICACION_RENTA
        WHEN 'ALTA' THEN 1
        WHEN 'MEDIA' THEN 2
        WHEN 'BAJA' THEN 3
        WHEN 'PREMIUM' THEN 4
    END;
