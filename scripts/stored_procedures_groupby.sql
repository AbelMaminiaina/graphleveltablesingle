-- =============================================
-- Procedures stockees pour LineageGraphDB
-- Table: GrapheTransformation
-- Version avec GROUP BY (sans DISTINCT)
-- =============================================

USE LineageGraphDB;
GO

-- =============================================
-- Procedure: sp_GetPredecessorsLevel1_GroupBy
-- Description: Retourne les predecesseurs directs (niveau 1)
--              d'une transformation donnee
-- Les predecesseurs sont les transformations dont les outputs
-- correspondent aux inputs de la transformation cible
-- =============================================
IF OBJECT_ID('dbo.sp_GetPredecessorsLevel1_GroupBy', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetPredecessorsLevel1_GroupBy;
GO

CREATE PROCEDURE dbo.sp_GetPredecessorsLevel1_GroupBy
    @TransformationName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Recuperer les inputs de la transformation cible
    DECLARE @Input1 NVARCHAR(255), @Input2 NVARCHAR(255),
            @Input3 NVARCHAR(255), @Input4 NVARCHAR(255);

    SELECT @Input1 = input1, @Input2 = input2,
           @Input3 = input3, @Input4 = input4
    FROM dbo.GrapheTransformation
    WHERE transformation = @TransformationName;

    -- Trouver les predecesseurs (transformations dont les outputs = nos inputs)
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
        -- Donnee de liaison (premier output qui correspond)
        CASE
            WHEN p.output1 IS NOT NULL AND p.output1 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output1
            WHEN p.output2 IS NOT NULL AND p.output2 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output2
            WHEN p.output3 IS NOT NULL AND p.output3 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output3
            WHEN p.output4 IS NOT NULL AND p.output4 IN (@Input1, @Input2, @Input3, @Input4) THEN p.output4
        END AS linking_data,
        1 AS level
    FROM dbo.GrapheTransformation p
    WHERE p.transformation <> @TransformationName
      AND (
          (p.output1 IS NOT NULL AND p.output1 IN (@Input1, @Input2, @Input3, @Input4))
          OR (p.output2 IS NOT NULL AND p.output2 IN (@Input1, @Input2, @Input3, @Input4))
          OR (p.output3 IS NOT NULL AND p.output3 IN (@Input1, @Input2, @Input3, @Input4))
          OR (p.output4 IS NOT NULL AND p.output4 IN (@Input1, @Input2, @Input3, @Input4))
      )
    GROUP BY
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
        p.date_creation
    ORDER BY p.transformation;
END;
GO

-- =============================================
-- Procedure: sp_GetSuccessorsLevel1_GroupBy
-- Description: Retourne les successeurs directs (niveau 1)
--              d'une transformation donnee
-- Les successeurs sont les transformations dont les inputs
-- correspondent aux outputs de la transformation source
-- =============================================
IF OBJECT_ID('dbo.sp_GetSuccessorsLevel1_GroupBy', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetSuccessorsLevel1_GroupBy;
GO

CREATE PROCEDURE dbo.sp_GetSuccessorsLevel1_GroupBy
    @TransformationName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Recuperer les outputs de la transformation source
    DECLARE @Output1 NVARCHAR(255), @Output2 NVARCHAR(255),
            @Output3 NVARCHAR(255), @Output4 NVARCHAR(255);

    SELECT @Output1 = output1, @Output2 = output2,
           @Output3 = output3, @Output4 = output4
    FROM dbo.GrapheTransformation
    WHERE transformation = @TransformationName;

    -- Trouver les successeurs (transformations dont les inputs = nos outputs)
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
        -- Donnee de liaison (premier input qui correspond)
        CASE
            WHEN s.input1 IS NOT NULL AND s.input1 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input1
            WHEN s.input2 IS NOT NULL AND s.input2 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input2
            WHEN s.input3 IS NOT NULL AND s.input3 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input3
            WHEN s.input4 IS NOT NULL AND s.input4 IN (@Output1, @Output2, @Output3, @Output4) THEN s.input4
        END AS linking_data,
        1 AS level
    FROM dbo.GrapheTransformation s
    WHERE s.transformation <> @TransformationName
      AND (
          (s.input1 IS NOT NULL AND s.input1 IN (@Output1, @Output2, @Output3, @Output4))
          OR (s.input2 IS NOT NULL AND s.input2 IN (@Output1, @Output2, @Output3, @Output4))
          OR (s.input3 IS NOT NULL AND s.input3 IN (@Output1, @Output2, @Output3, @Output4))
          OR (s.input4 IS NOT NULL AND s.input4 IN (@Output1, @Output2, @Output3, @Output4))
      )
    GROUP BY
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
        s.date_creation
    ORDER BY s.transformation;
END;
GO

-- =============================================
-- Procedure: sp_GetLineageLevel1_GroupBy
-- Description: Retourne les predecesseurs ET successeurs
--              directs (niveau 1) d'une transformation
-- =============================================
IF OBJECT_ID('dbo.sp_GetLineageLevel1_GroupBy', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetLineageLevel1_GroupBy;
GO

CREATE PROCEDURE dbo.sp_GetLineageLevel1_GroupBy
    @TransformationName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Info de la transformation
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
    WHERE transformation = @TransformationName;

    -- Predecesseurs
    EXEC dbo.sp_GetPredecessorsLevel1_GroupBy @TransformationName;

    -- Successeurs
    EXEC dbo.sp_GetSuccessorsLevel1_GroupBy @TransformationName;
END;
GO

-- =============================================
-- Procedure: sp_CountLineageLevel1_GroupBy
-- Description: Compte les predecesseurs et successeurs
--              directs (niveau 1) d'une transformation
-- =============================================
IF OBJECT_ID('dbo.sp_CountLineageLevel1_GroupBy', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CountLineageLevel1_GroupBy;
GO

CREATE PROCEDURE dbo.sp_CountLineageLevel1_GroupBy
    @TransformationName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Input1 NVARCHAR(255), @Input2 NVARCHAR(255),
            @Input3 NVARCHAR(255), @Input4 NVARCHAR(255),
            @Output1 NVARCHAR(255), @Output2 NVARCHAR(255),
            @Output3 NVARCHAR(255), @Output4 NVARCHAR(255);

    SELECT @Input1 = input1, @Input2 = input2,
           @Input3 = input3, @Input4 = input4,
           @Output1 = output1, @Output2 = output2,
           @Output3 = output3, @Output4 = output4
    FROM dbo.GrapheTransformation
    WHERE transformation = @TransformationName;

    SELECT
        @TransformationName AS transformation,
        (SELECT COUNT(*)
         FROM (
             SELECT p.id
             FROM dbo.GrapheTransformation p
             WHERE p.transformation <> @TransformationName
               AND (
                   (p.output1 IS NOT NULL AND p.output1 IN (@Input1, @Input2, @Input3, @Input4))
                   OR (p.output2 IS NOT NULL AND p.output2 IN (@Input1, @Input2, @Input3, @Input4))
                   OR (p.output3 IS NOT NULL AND p.output3 IN (@Input1, @Input2, @Input3, @Input4))
                   OR (p.output4 IS NOT NULL AND p.output4 IN (@Input1, @Input2, @Input3, @Input4))
               )
             GROUP BY p.id
         ) AS predecessors
        ) AS predecessor_count,
        (SELECT COUNT(*)
         FROM (
             SELECT s.id
             FROM dbo.GrapheTransformation s
             WHERE s.transformation <> @TransformationName
               AND (
                   (s.input1 IS NOT NULL AND s.input1 IN (@Output1, @Output2, @Output3, @Output4))
                   OR (s.input2 IS NOT NULL AND s.input2 IN (@Output1, @Output2, @Output3, @Output4))
                   OR (s.input3 IS NOT NULL AND s.input3 IN (@Output1, @Output2, @Output3, @Output4))
                   OR (s.input4 IS NOT NULL AND s.input4 IN (@Output1, @Output2, @Output3, @Output4))
               )
             GROUP BY s.id
         ) AS successors
        ) AS successor_count;
END;
GO

PRINT 'Procedures stockees (version GROUP BY) creees avec succes.';
GO
