#INCLUDE 'protheus.ch'

/*/{Protheus.doc} RelExcel
    (Relatorio gera em excel os cadastros de produtos com join nos grupos de produtos)
    @type  User Function
    @author Augusto
    @since 15/06/2020
    @version version
    @param 
    @return return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function RelExcel()

    LOCAL cAlias := GetNextAlias() //obtem nome do alias a ser usado

    //chama funcao para montar e executar query sql
    Processa( { || MontaQuery( cAlias ) } , , "Processando..." )
    MsAguarde( {|| GeraExcel( cAlias ) } , , "O arquivo Excel está sendo gerado..." )

Return Nil

/*/{Protheus.doc} MontaQuery
    (monta query de filtragem dos produtos SB1 com join no grupo de produtos SBM)
    @type  Static Function
    @author Augusto
    @since 15/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function MontaQuery( cAlias )

    BEGINSQL ALIAS cAlias //inicia query sql no calias
        SELECT TOP 1000 
            B1_COD AS CODIGO,
            B1_DESC AS DESCRICAO,
            B1_TIPO AS TIPO,
            BM_GRUPO AS GRUPO, 
            BM_DESC AS GP_DESCRICAO,
            BM_PROORI AS GP_ORIGEM
        FROM
            %table:SB1% SB1 INNER JOIN %table:SBM% SBM
            ON BM_GRUPO = B1_GRUPO
        WHERE 
            B1_FILIAL= %exp:xFilial( "SB1" )% AND
            BM_FILIAL = %exp:xFilial( "SBM" )% AND 
            SB1.%NotDel% AND
            SBM.%NotDel%
        ORDER BY B1_COD

    ENDSQL //finaliza query

Return Nil

/*/{Protheus.doc} GeraExcel
    (Gera o arquivo excel em xml com apenas uma planilha)
    @type  Static Function
    @author Augusto
    @since 23/06/2020
    @version version
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GeraExcel( cAlias )

    LOCAL oExcel    := FWMsExcel():new()
    LOCAL lOk       := .F.
    LOCAL cArq      := ""
    LOCAL cDirTemp  := "C:\spool\"

    DbSelectArea( cAlias )
    dbGoTop()

    oExcel:AddWorkSheet( "PRODUTOS" )
    oExcel:AddTable( "PRODUTOS" , "TESTE" )
    oExcel:AddColumn( "PRODUTOS" , "TESTE" , "CODIGO" , 1 , 1 )
    oExcel:AddColumn( "PRODUTOS" , "TESTE" , "DESCRICAO" , 1 , 1 )
    oExcel:AddColumn( "PRODUTOS" , "TESTE" , "TIPO" , 1 , 1 )
    oExcel:AddColumn( "PRODUTOS" , "TESTE" , "GRUPO" , 1 , 1 )
    oExcel:AddColumn( "PRODUTOS" , "TESTE" , "GP_DESCRICAO" , 1 , 1 )
    oExcel:AddColumn( "PRODUTOS" , "TESTE" , "GP_ORIGEM" , 1 , 1 )

    While ( cAlias )->( !EOF() )
        oExcel:AddRow( "PRODUTOS" , "TESTE" , { ( cAlias )->CODIGO ,;
                                                ( cAlias )->DESCRICAO ,;
                                                ( cAlias )->TIPO ,;
                                                ( cAlias )->GRUPO ,;
                                                ( cAlias )->GP_DESCRICAO ,;
                                                ( cAlias )->GP_ORIGEM } )

        lOk := .T.
        DbSkip()
    EndDo
    
    oExcel:Activate()
    cArq    := CriaTrab( Nil , .F. ) + ".xml"
    oExcel:GetXMLFile( cArq )

    IF  __COPYFILE( cArq , cDirTemp + cArq , , , )
        IF lOk
            oExcelApp   := MSExcel():new()
            oExcelApp:WorkBooks:Open( cDirtemp + cArq )
            oExcelApp:SetVisible( .T. )
            oExcelApp:Destroy()
            MsgInfo( "O arquivo excel foi gerado: " + cDirtemp + cArq + "." )
        ENDIF
    ELSE
        MsgAlert( "Algo deu errado!" )
    ENDIF

    DbCloseArea()

Return Nil