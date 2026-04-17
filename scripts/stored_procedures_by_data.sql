-- =============================================
-- Procedures stockees pour LineageGraphDB
-- Recherche par Input/Output (donnees)
-- =============================================

USE LineageGraphDB;
GO

-- =============================================
-- Procedure: sp_GetTransformationsByData
-- Description: Recherche les transformations qui ont
--              les inputs ou outputs specifies
-- =============================================
IF OBJECT_ID('dbo.sp_GetTransformationsByData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetTransformationsByData;
GO

CREATE PROCEDURE dbo.sp_GetTransformationsByData
    @Input1 NVARCHAR(255) = NULL,
    @Input2 NVARCHAR(255) = NULL,
    @Input3 NVARCHAR(255) = NULL,
    @Input4 NVARCHAR(255) = NULL,
    @Output1 NVARCHAR(255) = NULL,
    @Output2 NVARCHAR(255) = NULL,
    @Output3 NVARCHAR(255) = NULL,
    @Output4 NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id,
        id_type,
        transformation,
        proprietaire,
        input1,
        input2,
        input3,
        input4,
        output1,
        output2,
        output3,
        output4,
        date_creation
    FROM dbo.GrapheTransformation
    WHERE
        -- Recherche par inputs
        (@Input1 IS NOT NULL AND (@Input1 IN (input1, input2, input3, input4)))
        OR (@Input2 IS NOT NULL AND (@Input2 IN (input1, input2, input3, input4)))
        OR (@Input3 IS NOT NULL AND (@Input3 IN (input1, input2, input3, input4)))
        OR (@Input4 IS NOT NULL AND (@Input4 IN (input1, input2, input3, input4)))
        -- Recherche par outputs
        OR (@Output1 IS NOT NULL AND (@Output1 IN (output1, output2, output3, output4)))
        OR (@Output2 IS NOT NULL AND (@Output2 IN (output1, output2, output3, output4)))
        OR (@Output3 IS NOT NULL AND (@Output3 IN (output1, output2, output3, output4)))
        OR (@Output4 IS NOT NULL AND (@Output4 IN (output1, output2, output3, output4)))
    GROUP BY
        id,
        id_type,
        transformation,
        proprietaire,
        input1,
        input2,
        input3,
        input4,
        output1,
        output2,
        output3,
        output4,
        date_creation
    ORDER BY transformation;
END;
GO

-- =============================================
-- Procedure: sp_GetLineageLevel1ByData
-- Description: Retourne les predecesseurs et successeurs
--              niveau 1 pour les transformations trouvees
--              par les inputs/outputs specifies
-- =============================================
IF OBJECT_ID('dbo.sp_GetLineageLevel1ByData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetLineageLevel1ByData;
GO

CREATE PROCEDURE dbo.sp_GetLineageLevel1ByData
    @Input1 NVARCHAR(255) = NULL,
    @Input2 NVARCHAR(255) = NULL,
    @Input3 NVARCHAR(255) = NULL,
    @Input4 NVARCHAR(255) = NULL,
    @Output1 NVARCHAR(255) = NULL,
    @Output2 NVARCHAR(255) = NULL,
    @Output3 NVARCHAR(255) = NULL,
    @Output4 NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Table temporaire pour stocker les transformations trouvees
    CREATE TABLE #FoundTransformations (
        id INT,
        id_type INT,
        transformation NVARCHAR(255),
        proprietaire NVARCHAR(100),
        input1 NVARCHAR(255),
        input2 NVARCHAR(255),
        input3 NVARCHAR(255),
        input4 NVARCHAR(255),
        output1 NVARCHAR(255),
        output2 NVARCHAR(255),
        output3 NVARCHAR(255),
        output4 NVARCHAR(255),
        date_creation DATETIME
    );

    -- Trouver les transformations correspondantes
    INSERT INTO #FoundTransformations
    SELECT
        id, id_type, transformation, proprietaire,
        input1, input2, input3, input4,
        output1, output2, output3, output4,
        date_creation
    FROM dbo.GrapheTransformation
    WHERE
        (@Input1 IS NOT NULL AND (@Input1 IN (input1, input2, input3, input4)))
        OR (@Input2 IS NOT NULL AND (@Input2 IN (input1, input2, input3, input4)))
        OR (@Input3 IS NOT NULL AND (@Input3 IN (input1, input2, input3, input4)))
        OR (@Input4 IS NOT NULL AND (@Input4 IN (input1, input2, input3, input4)))
        OR (@Output1 IS NOT NULL AND (@Output1 IN (output1, output2, output3, output4)))
        OR (@Output2 IS NOT NULL AND (@Output2 IN (output1, output2, output3, output4)))
        OR (@Output3 IS NOT NULL AND (@Output3 IN (output1, output2, output3, output4)))
        OR (@Output4 IS NOT NULL AND (@Output4 IN (output1, output2, output3, output4)))
    GROUP BY
        id, id_type, transformation, proprietaire,
        input1, input2, input3, input4,
        output1, output2, output3, output4,
        date_creation;

    -- 1. Afficher les transformations trouvees
    SELECT
        'TRANSFORMATION' AS record_type,
        id,
        id_type,
        transformation,
        proprietaire,
        input1,
        input2,
        input3,
        input4,
        output1,
        output2,
        output3,
        output4,
        date_creation,
        NULL AS linking_data,
        0 AS level
    FROM #FoundTransformations

    UNION ALL

    -- 2. Predecesseurs niveau 1 (transformations dont les outputs = inputs des transformations trouvees)
    SELECT
        'PREDECESSOR' AS record_type,
        p.id,
        p.id_type,
        p.transformation,
        p.proprietaire,
        p.input1,
        p.input2,
        p.input3,
        p.input4,
        p.output1,
        p.output2,
        p.output3,
        p.output4,
        p.date_creation,
        CASE
            WHEN p.output1 IS NOT NULL AND p.output1 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations) THEN p.output1
            WHEN p.output2 IS NOT NULL AND p.output2 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations) THEN p.output2
            WHEN p.output3 IS NOT NULL AND p.output3 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations) THEN p.output3
            WHEN p.output4 IS NOT NULL AND p.output4 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations) THEN p.output4
        END AS linking_data,
        1 AS level
    FROM dbo.GrapheTransformation p
    WHERE p.transformation NOT IN (SELECT transformation FROM #FoundTransformations)
      AND (
          (p.output1 IS NOT NULL AND p.output1 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations))
          OR (p.output2 IS NOT NULL AND p.output2 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations))
          OR (p.output3 IS NOT NULL AND p.output3 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations))
          OR (p.output4 IS NOT NULL AND p.output4 IN (SELECT input1 FROM #FoundTransformations UNION SELECT input2 FROM #FoundTransformations UNION SELECT input3 FROM #FoundTransformations UNION SELECT input4 FROM #FoundTransformations))
      )
    GROUP BY
        p.id, p.id_type, p.transformation, p.proprietaire,
        p.input1, p.input2, p.input3, p.input4,
        p.output1, p.output2, p.output3, p.output4,
        p.date_creation

    UNION ALL

    -- 3. Successeurs niveau 1 (transformations dont les inputs = outputs des transformations trouvees)
    SELECT
        'SUCCESSOR' AS record_type,
        s.id,
        s.id_type,
        s.transformation,
        s.proprietaire,
        s.input1,
        s.input2,
        s.input3,
        s.input4,
        s.output1,
        s.output2,
        s.output3,
        s.output4,
        s.date_creation,
        CASE
            WHEN s.input1 IS NOT NULL AND s.input1 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations) THEN s.input1
            WHEN s.input2 IS NOT NULL AND s.input2 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations) THEN s.input2
            WHEN s.input3 IS NOT NULL AND s.input3 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations) THEN s.input3
            WHEN s.input4 IS NOT NULL AND s.input4 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations) THEN s.input4
        END AS linking_data,
        1 AS level
    FROM dbo.GrapheTransformation s
    WHERE s.transformation NOT IN (SELECT transformation FROM #FoundTransformations)
      AND (
          (s.input1 IS NOT NULL AND s.input1 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations))
          OR (s.input2 IS NOT NULL AND s.input2 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations))
          OR (s.input3 IS NOT NULL AND s.input3 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations))
          OR (s.input4 IS NOT NULL AND s.input4 IN (SELECT output1 FROM #FoundTransformations UNION SELECT output2 FROM #FoundTransformations UNION SELECT output3 FROM #FoundTransformations UNION SELECT output4 FROM #FoundTransformations))
      )
    GROUP BY
        s.id, s.id_type, s.transformation, s.proprietaire,
        s.input1, s.input2, s.input3, s.input4,
        s.output1, s.output2, s.output3, s.output4,
        s.date_creation

    ORDER BY record_type, transformation;

    DROP TABLE #FoundTransformations;
END;
GO

-- =============================================
-- Procedure: sp_GetPredecessorsByData
-- Description: Retourne uniquement les predecesseurs niveau 1
--              pour les inputs/outputs specifies
-- =============================================
IF OBJECT_ID('dbo.sp_GetPredecessorsByData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetPredecessorsByData;
GO

CREATE PROCEDURE dbo.sp_GetPredecessorsByData
    @Input1 NVARCHAR(255) = NULL,
    @Input2 NVARCHAR(255) = NULL,
    @Input3 NVARCHAR(255) = NULL,
    @Input4 NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Predecesseurs: transformations dont les outputs correspondent aux inputs donnes
    SELECT
        p.id,
        p.id_type,
        p.transformation,
        p.proprietaire,
        p.input1,
        p.input2,
        p.input3,
        p.input4,
        p.output1,
        p.output2,
        p.output3,
        p.output4,
        p.date_creation,
        CASE
            WHEN p.output1 IS NOT NULL AND p.output1 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output1
            WHEN p.output2 IS NOT NULL AND p.output2 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output2
            WHEN p.output3 IS NOT NULL AND p.output3 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output3
            WHEN p.output4 IS NOT NULL AND p.output4 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output4
        END AS linking_data,
        1 AS level
    FROM dbo.GrapheTransformation p
    WHERE
        (p.output1 IS NOT NULL AND p.output1 IN (@Input1, @Input2, @Input3, @Input4))
        OR (p.output2 IS NOT NULL AND p.output2 IN (@Input1, @Input2, @Input3, @Input4))
        OR (p.output3 IS NOT NULL AND p.output3 IN (@Input1, @Input2, @Input3, @Input4))
        OR (p.output4 IS NOT NULL AND p.output4 IN (@Input1, @Input2, @Input3, @Input4))
    GROUP BY
        p.id, p.id_type, p.transformation, p.proprietaire,
        p.input1, p.input2, p.input3, p.input4,
        p.output1, p.output2, p.output3, p.output4,
        p.date_creation
    ORDER BY p.transformation;
END;
GO

-- =============================================
-- Procedure: sp_GetSuccessorsByData
-- Description: Retourne uniquement les successeurs niveau 1
--              pour les outputs specifies
-- =============================================
IF OBJECT_ID('dbo.sp_GetSuccessorsByData', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetSuccessorsByData;
GO

CREATE PROCEDURE dbo.sp_GetSuccessorsByData
    @Output1 NVARCHAR(255) = NULL,
    @Output2 NVARCHAR(255) = NULL,
    @Output3 NVARCHAR(255) = NULL,
    @Output4 NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Successeurs: transformations dont les inputs correspondent aux outputs donnes
    SELECT
        s.id,
        s.id_type,
        s.transformation,
        s.proprietaire,
        s.input1,
        s.input2,
        s.input3,
        s.input4,
        s.output1,
        s.output2,
        s.output3,
        s.output4,
        s.date_creation,
        CASE
            WHEN s.input1 IS NOT NULL AND s.input1 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input1
            WHEN s.input2 IS NOT NULL AND s.input2 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input2
            WHEN s.input3 IS NOT NULL AND s.input3 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input3
            WHEN s.input4 IS NOT NULL AND s.input4 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input4
        END AS linking_data,
        1 AS level
    FROM dbo.GrapheTransformation s
    WHERE
        (s.input1 IS NOT NULL AND s.input1 IN (@Output1, @Output2, @Output3, @Output4))
        OR (s.input2 IS NOT NULL AND s.input2 IN (@Output1, @Output2, @Output3, @Output4))
        OR (s.input3 IS NOT NULL AND s.input3 IN (@Output1, @Output2, @Output3, @Output4))
        OR (s.input4 IS NOT NULL AND s.input4 IN (@Output1, @Output2, @Output3, @Output4))
    GROUP BY
        s.id, s.id_type, s.transformation, s.proprietaire,
        s.input1, s.input2, s.input3, s.input4,
        s.output1, s.output2, s.output3, s.output4,
        s.date_creation
    ORDER BY s.transformation;
END;
GO

PRINT 'Procedures stockees (recherche par donnees) creees avec succes.';
GO
