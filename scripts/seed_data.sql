-- Script de creation de la table GrapheTransformation et insertion de donnees de test
-- Base de donnees: GraphLevel1

-- Creation de la table unique
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GrapheTransformation')
BEGIN
    CREATE TABLE GrapheTransformation (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        source_transformation NVARCHAR(255) NOT NULL,
        source_proprietaire NVARCHAR(100) NULL,
        source_id_type INT NOT NULL DEFAULT 1,
        target_transformation NVARCHAR(255) NOT NULL,
        target_proprietaire NVARCHAR(100) NULL,
        target_id_type INT NOT NULL DEFAULT 1,
        data_name NVARCHAR(100) NOT NULL,
        date_creation DATETIME NOT NULL DEFAULT GETDATE()
    );

    -- Index pour optimiser les recherches
    CREATE INDEX IX_GrapheTransformation_Source ON GrapheTransformation(source_transformation);
    CREATE INDEX IX_GrapheTransformation_Target ON GrapheTransformation(target_transformation);
    CREATE INDEX IX_GrapheTransformation_DataName ON GrapheTransformation(data_name);
END
GO

-- Insertion de donnees de test
-- Transformation A -> B, C, D
INSERT INTO GrapheTransformation (source_transformation, source_proprietaire, source_id_type, target_transformation, target_proprietaire, target_id_type, data_name)
VALUES
('TRANSFO_A', 'Equipe1', 1, 'TRANSFO_B', 'Equipe2', 2, 'DATA_1_O1'),
('TRANSFO_A', 'Equipe1', 1, 'TRANSFO_C', 'Equipe2', 2, 'DATA_2_O1'),
('TRANSFO_A', 'Equipe1', 1, 'TRANSFO_D', 'Equipe3', 3, 'DATA_3_O1');

-- Transformation B -> E, F
INSERT INTO GrapheTransformation (source_transformation, source_proprietaire, source_id_type, target_transformation, target_proprietaire, target_id_type, data_name)
VALUES
('TRANSFO_B', 'Equipe2', 2, 'TRANSFO_E', 'Equipe3', 3, 'DATA_4_O2'),
('TRANSFO_B', 'Equipe2', 2, 'TRANSFO_F', 'Equipe4', 4, 'DATA_5_O2');

-- Transformation C -> G
INSERT INTO GrapheTransformation (source_transformation, source_proprietaire, source_id_type, target_transformation, target_proprietaire, target_id_type, data_name)
VALUES
('TRANSFO_C', 'Equipe2', 2, 'TRANSFO_G', 'Equipe4', 4, 'DATA_6_O2');

-- Transformation D -> H, I
INSERT INTO GrapheTransformation (source_transformation, source_proprietaire, source_id_type, target_transformation, target_proprietaire, target_id_type, data_name)
VALUES
('TRANSFO_D', 'Equipe3', 3, 'TRANSFO_H', 'Equipe5', 5, 'DATA_7_O3'),
('TRANSFO_D', 'Equipe3', 3, 'TRANSFO_I', 'Equipe5', 5, 'DATA_8_O3');

-- Transformation E -> J
INSERT INTO GrapheTransformation (source_transformation, source_proprietaire, source_id_type, target_transformation, target_proprietaire, target_id_type, data_name)
VALUES
('TRANSFO_E', 'Equipe3', 3, 'TRANSFO_J', 'Equipe6', 6, 'DATA_9_O4');

-- Transformation F -> J (meme cible que E)
INSERT INTO GrapheTransformation (source_transformation, source_proprietaire, source_id_type, target_transformation, target_proprietaire, target_id_type, data_name)
VALUES
('TRANSFO_F', 'Equipe4', 4, 'TRANSFO_J', 'Equipe6', 6, 'DATA_10_O4');

PRINT 'Donnees de test inserees avec succes!';
GO
