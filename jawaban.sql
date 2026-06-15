SELECT 
    level2, 
    jumlah_anomali, 
    id, 
    nilai_order, 
    average, 
    stdev, 
    jarak_average, 
    z_score
FROM (
   
    SELECT 
        1 AS tipe_baris,
        sub_outlier.manager_level_2 AS level2,
        COUNT(sub_outlier.node_id) AS jumlah_anomali,
        NULL AS id,
        NULL AS nilai_order,
        NULL AS average,
        NULL AS stdev,
        NULL AS jarak_average,
        NULL AS z_score
    FROM (
        SELECT 
            o.node_id, 
            o.nilai_order,
            CASE 
                WHEN n1.parent_id = 'ROOT' THEN n1.id
                WHEN n2.parent_id = 'ROOT' THEN n2.id
                WHEN n3.parent_id = 'ROOT' THEN n3.id
                WHEN n4.parent_id = 'ROOT' THEN n4.id
                WHEN n5.parent_id = 'ROOT' THEN n5.id
            END AS manager_level_2
        FROM orders o
        JOIN nodes n1 ON o.node_id = n1.id
        LEFT JOIN nodes n2 ON n1.parent_id = n2.id
        LEFT JOIN nodes n3 ON n2.parent_id = n3.id
        LEFT JOIN nodes n4 ON n3.parent_id = n4.id
        LEFT JOIN nodes n5 ON n4.parent_id = n5.id
    ) AS sub_outlier
    JOIN (
        SELECT 
            sub_map.manager_level_2,
            AVG(sub_map.nilai_order) AS avg_nilai,
            STDDEV_POP(sub_map.nilai_order) AS std_nilai
        FROM (
            SELECT 
                o.nilai_order,
                CASE 
                    WHEN n1.parent_id = 'ROOT' THEN n1.id
                    WHEN n2.parent_id = 'ROOT' THEN n2.id
                    WHEN n3.parent_id = 'ROOT' THEN n3.id
                    WHEN n4.parent_id = 'ROOT' THEN n4.id
                    WHEN n5.parent_id = 'ROOT' THEN n5.id
                END AS manager_level_2
            FROM orders o
            JOIN nodes n1 ON o.node_id = n1.id
            LEFT JOIN nodes n2 ON n1.parent_id = n2.id
            LEFT JOIN nodes n3 ON n2.parent_id = n3.id
            LEFT JOIN nodes n4 ON n3.parent_id = n4.id
            LEFT JOIN nodes n5 ON n4.parent_id = n5.id
        ) AS sub_map
        GROUP BY sub_map.manager_level_2
    ) AS stats ON sub_outlier.manager_level_2 = stats.manager_level_2
    WHERE sub_outlier.nilai_order > (stats.avg_nilai + 3 * stats.std_nilai)
       OR sub_outlier.nilai_order < (stats.avg_nilai - 3 * stats.std_nilai)
    GROUP BY sub_outlier.manager_level_2

    UNION ALL


    SELECT 
        2 AS tipe_baris,
        sub_outlier.manager_level_2 AS level2,
        NULL AS jumlah_anomali,
        sub_outlier.node_id AS id,
        sub_outlier.nilai_order AS nilai_order,
        stats.avg_nilai AS average,
        stats.std_nilai AS stdev,
        (sub_outlier.nilai_order - stats.avg_nilai) AS jarak_average,
        (sub_outlier.nilai_order - stats.avg_nilai) / stats.std_nilai AS z_score
    FROM (
        SELECT 
            o.node_id, 
            o.nilai_order,
            CASE 
                WHEN n1.parent_id = 'ROOT' THEN n1.id
                WHEN n2.parent_id = 'ROOT' THEN n2.id
                WHEN n3.parent_id = 'ROOT' THEN n3.id
                WHEN n4.parent_id = 'ROOT' THEN n4.id
                WHEN n5.parent_id = 'ROOT' THEN n5.id
            END AS manager_level_2
        FROM orders o
        JOIN nodes n1 ON o.node_id = n1.id
        LEFT JOIN nodes n2 ON n1.parent_id = n2.id
        LEFT JOIN nodes n3 ON n2.parent_id = n3.id
        LEFT JOIN nodes n4 ON n3.parent_id = n4.id
        LEFT JOIN nodes n5 ON n4.parent_id = n5.id
    ) AS sub_outlier
    JOIN (
        SELECT 
            sub_map.manager_level_2,
            AVG(sub_map.nilai_order) AS avg_nilai,
            STDDEV_POP(sub_map.nilai_order) AS std_nilai
        FROM (
            SELECT 
                o.nilai_order,
                CASE 
                    WHEN n1.parent_id = 'ROOT' THEN n1.id
                    WHEN n2.parent_id = 'ROOT' THEN n2.id
                    WHEN n3.parent_id = 'ROOT' THEN n3.id
                    WHEN n4.parent_id = 'ROOT' THEN n4.id
                    WHEN n5.parent_id = 'ROOT' THEN n5.id
                END AS manager_level_2
            FROM orders o
            JOIN nodes n1 ON o.node_id = n1.id
            LEFT JOIN nodes n2 ON n1.parent_id = n2.id
            LEFT JOIN nodes n3 ON n2.parent_id = n3.id
            LEFT JOIN nodes n4 ON n3.parent_id = n4.id
            LEFT JOIN nodes n5 ON n4.parent_id = n5.id
        ) AS sub_map
        GROUP BY sub_map.manager_level_2
    ) AS stats ON sub_outlier.manager_level_2 = stats.manager_level_2
    WHERE sub_outlier.nilai_order > (stats.avg_nilai + 3 * stats.std_nilai)
       OR sub_outlier.nilai_order < (stats.avg_nilai - 3 * stats.std_nilai)
) AS hasil_gabungan
ORDER BY tipe_baris ASC, level2 ASC;