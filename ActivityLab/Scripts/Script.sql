SELECT * FROM LY_TURMA
SELECT * FROM LY_DISCIPLINA
SELECT * FROM LY_CURSO
SELECT * FROM dbo.LY_GRUPO_HABILITACAO WHERE DESCRICAO LIKE '%ARTE%'
SELECT * FROM dbo.LY_GRUPO_HABILITACAO_DISC

SELECT top 10 
	T.NUM_FUNC,
	UNIDADE_ENS
     , NOME_COMP               AS NOME_UNIDADE
     , DISCIPLINA
     , TURMA
     , ANO
     , SEMESTRE
     , NOME_COMPL              AS NOME_DISCIPLINA
     , VALIDOPARALANCAMENTO
     , CASE WHEN POSSUIPROVA = 'True' 
           THEN POSSUINOTASPENDENTES
           ELSE 'False'
           END POSSUINOTAPENDENTES
	 , CASE WHEN POSSUIFREQ = 'True' 
           THEN POSSUIFREQPENDENTES     
           ELSE 'False'
           END POSSUIFREQPENDENTES     
/*
     , SUBSTRING(STATUS_LANCAMENTO, 14, CHARINDEX('Aguardando', STATUS_LANCAMENTO) - 14 - 5) AS LIBERADO
     
     , SUBSTRING(STATUS_LANCAMENTO, CHARINDEX('Aguardando: ',  STATUS_LANCAMENTO) + 11, 
                                    CHARINDEX('Bloqueado(s):', STATUS_LANCAMENTO) - (CHARINDEX('Aguardando: ', STATUS_LANCAMENTO) + 11) - 5) AS AGUARDANDO 

     , SUBSTRING(STATUS_LANCAMENTO, CHARINDEX('Bloqueado(s):',  STATUS_LANCAMENTO) + 14, 
                                    (LEN(STATUS_LANCAMENTO) - 1) - CHARINDEX('Bloqueado(s):',  STATUS_LANCAMENTO) + 14) AS BLOQUEADO
*/
     , CURSO 
     , MODALIDADE
     , TIPO
     , SERIE
     , POSSUIPROVA
     , POSSUIFREQ

  FROM (
SELECT UE.UNIDADE_ENS
     , UE.NOME_COMP
     , T.DISCIPLINA AS DISCIPLINA
     , T.TURMA
     , T.ANO
     , T.SEMESTRE
     , D.NOME_COMPL
     , CASE WHEN T.CURSO IN ('0001.11', '0001.16', '0001.17', '0001.51') THEN 'False'
            ELSE 'True'
       END VALIDOPARALANCAMENTO     
     
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_PROVA P1 (NOLOCK)
                   WHERE P1.ANO                      = T.ANO
                     AND P1.SEMESTRE                 = T.SEMESTRE
                     AND P1.DISCIPLINA               = T.DISCIPLINA
                     AND P1.TURMA                    = T.TURMA
                     AND P1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                     AND ISNULL(P1.COMPLEMENTO, 'N') = 'N'
                  ) = 0 THEN 'False'
            ELSE 'True'
        END POSSUINOTASPENDENTES
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_FREQ F1 (NOLOCK)
                   WHERE F1.ANO                      = T.ANO
                     AND F1.PERIODO                 = T.SEMESTRE
                     AND F1.DISCIPLINA               = T.DISCIPLINA
                     AND F1.TURMA                    = T.TURMA
                     AND F1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                     AND F1.AULAS_DADAS IS NULL
                  ) = 0 THEN 'False'
            ELSE 'True'
        END POSSUIFREQPENDENTES
        
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_PROVA P1 (NOLOCK)
                   WHERE P1.ANO                      = T.ANO
                     AND P1.SEMESTRE                 = T.SEMESTRE
                     AND P1.DISCIPLINA               = T.DISCIPLINA
                     AND P1.TURMA                    = T.TURMA
                     AND P1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                  ) = 0 THEN 'False'
            ELSE 'True'
        END POSSUIPROVA        
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_FREQ F1 (NOLOCK)
                   WHERE F1.ANO                      = T.ANO
                     AND F1.PERIODO                 = T.SEMESTRE
                     AND F1.DISCIPLINA               = T.DISCIPLINA
                     AND F1.TURMA                    = T.TURMA
                     AND F1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                  ) = 0 THEN 'False'
            ELSE 'True'
        END POSSUIFREQ
                
     --, [DBO].[FCE_STATUS_TURMA_BIMESTRES2](T.ANO, T.SEMESTRE, T.TURMA, T.DISCIPLINA, @NUM_FUNC) AS STATUS_LANCAMENTO
     , T.CURSO AS CURSO
     , CU.MODALIDADE
     , CU.TIPO
     , T.SERIE AS SERIE
     , AD.NUM_FUNC
  FROM LY_DISCIPLINA D (NOLOCK)
 
 INNER 
  JOIN LY_TURMA T (NOLOCK) 
    ON ISNULL(T.DISCIPLINA_MULTIPLA, T.DISCIPLINA) = D.DISCIPLINA
 
 INNER 
  JOIN LY_CURSO CU 
    ON CU.CURSO = T.CURSO
 
 INNER 
  JOIN LY_AULA_DOCENTE AD (NOLOCK) 
    ON T.TURMA      = AD.TURMA
   AND T.DISCIPLINA = AD.DISCIPLINA
   AND T.ANO        = AD.ANO
   AND T.SEMESTRE   = AD.SEMESTRE
   AND AD.DATA_FIM  = T.DT_FIM

 INNER 
  JOIN LY_UNIDADE_ENSINO UE (NOLOCK) 
    ON T.UNIDADE_RESPONSAVEL = UE.UNIDADE_ENS
 
 INNER 
  JOIN LY_SUBPERIODO_LETIVO SPL 
    ON SPL.ANO                   = T.ANO
   AND SPL.PERIODO               = T.SEMESTRE
   AND GETDATE() >= SPL.DT_INICIO
   AND GETDATE() <= SPL.DT_LANCAMENTO

 WHERE T.SIT_TURMA = 'ABERTA'
--   AND T.ANO       = YEAR(GETDATE()) 
   AND T.ANO       = 2013

 GROUP 
    BY UE.UNIDADE_ENS
     , UE.NOME_COMP
     , T.DISCIPLINA
     , T.TURMA
     , T.ANO
     , T.SEMESTRE
     , D.NOME_COMPL
     , T.CURSO
     , CU.MODALIDADE
     , CU.TIPO
     , T.SERIE
     , AD.NUM_FUNC

 UNION

SELECT DISTINCT
       UE.UNIDADE_ENS
     , UE.NOME_COMP
     , T.DISCIPLINA AS DISCIPLINA
     , T.TURMA
     , T.ANO
     , T.SEMESTRE
     , D.NOME_COMPL
     , CASE WHEN T.CURSO IN ( '0001.11', '0001.16', '0001.17', '0001.51' ) THEN 'False'
            ELSE 'True'
       END VALIDOPARALANCAMENTO
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_PROVA P1 (NOLOCK)
                   WHERE P1.ANO                      = T.ANO
                     AND P1.SEMESTRE                 = T.SEMESTRE
                     AND P1.DISCIPLINA               = T.DISCIPLINA
                     AND P1.TURMA                    = T.TURMA
                     AND P1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                     AND ISNULL(P1.COMPLEMENTO, 'N') = 'N'
                  ) = 0 THEN 'False'
             ELSE 'True'
       END POSSUINOTASPENDENTES
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_FREQ F1 (NOLOCK)
                   WHERE F1.ANO                      = T.ANO
                     AND F1.PERIODO                 = T.SEMESTRE
                     AND F1.DISCIPLINA               = T.DISCIPLINA
                     AND F1.TURMA                    = T.TURMA
                     AND F1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                     AND F1.AULAS_DADAS IS NULL
                  ) = 0 THEN 'False'
            ELSE 'True'
        END POSSUIFREQPENDENTES
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_PROVA P1 (NOLOCK)
                   WHERE P1.ANO                      = T.ANO
                     AND P1.SEMESTRE                 = T.SEMESTRE
                     AND P1.DISCIPLINA               = T.DISCIPLINA
                     AND P1.TURMA                    = T.TURMA
                     AND P1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                  ) = 0 THEN 'False'
            ELSE 'True'
        END POSSUIPROVA        
     , CASE WHEN (SELECT COUNT(*)
                    FROM LY_FREQ F1 (NOLOCK)
                   WHERE F1.ANO                      = T.ANO
                     AND F1.PERIODO                 = T.SEMESTRE
                     AND F1.DISCIPLINA               = T.DISCIPLINA
                     AND F1.TURMA                    = T.TURMA
                     AND F1.SUBPERIODO              <= MAX(SPL.SUBPERIODO)
                  ) = 0 THEN 'False'
            ELSE 'True'
        END POSSUIFREQ
     --, [DBO].[FCE_STATUS_TURMA_BIMESTRES2](T.ANO, T.SEMESTRE, T.TURMA, T.DISCIPLINA, @NUM_FUNC) AS STATUS_LANCAMENTO
     , T.CURSO AS CURSO
     , CU.MODALIDADE
     , CU.TIPO
     , T.SERIE AS SERIE 
     , T.NUM_FUNC

  FROM LY_DISCIPLINA D (NOLOCK)
  
  JOIN LY_TURMA T (NOLOCK) ON ISNULL(T.DISCIPLINA_MULTIPLA, T.DISCIPLINA) = D.DISCIPLINA
  
  JOIN LY_CURSO CU ON CU.CURSO = T.CURSO
  
  JOIN LY_UNIDADE_ENSINO UE (NOLOCK) ON T.UNIDADE_RESPONSAVEL = UE.UNIDADE_ENS
  
  JOIN LY_SUBPERIODO_LETIVO SPL
    ON SPL.ANO = T.ANO
   AND SPL.PERIODO = T.SEMESTRE
   AND CONVERT(DATE, GETDATE()) >= SPL.DT_INICIO
   AND CONVERT(DATE, GETDATE()) <= SPL.DT_LANCAMENTO

 WHERE T.SIT_TURMA     = 'Aberta'
   AND T.CLASSIFICACAO = 'PROJ'
   --AND T.ANO           = YEAR(GETDATE())
   AND T.ANO           = 2013

 GROUP 
    BY UE.UNIDADE_ENS
     , UE.NOME_COMP
     , T.DISCIPLINA
     , T.TURMA
     , T.ANO
     , T.SEMESTRE
     , D.NOME_COMPL
     , T.CURSO
     , CU.MODALIDADE
     , CU.TIPO
     , T.SERIE
     , T.NUM_FUNC
     ) AS T
--  WHERE NUM_FUNC = @NUM_FUNC
  WHERE NUM_FUNC IS NOT NULL

 ORDER BY UNIDADE_ENS,
          ANO,
          SEMESTRE,
          TURMA,
          DISCIPLINA
