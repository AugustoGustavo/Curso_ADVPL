#INCLUDE 'protheus.ch'

/*/{Protheus.doc} RelExcel2
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
User Function RelExcel2()

    LOCAL cAlias := GetNextAlias() //obtem nome do alias a ser usado

    //chama funcao para montar e executar query sql
    Processa( { || MontaQuery( cAlias ) } , , "Processando..." )
    //chama funcao que monta e gera o arquivo excel
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

    BEGINSQL ALIAS cAlias //inicial query sql

        SELECT DISTINCT TOP 100 
            A1_COD, A1_NOME, A1_MCOMPRA,
            C5_NUM, C5_TIPO, C5_VEND1, C5_CLIENTE, C5_EMISSAO, 
            C6_ITEM, C6_PRODUTO, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_NUM,
            B1_DESC, B1_GRUPO
        FROM 
            %Table:SA1% SA1, %Table:SC5% SC5, %Table:SC6% SC6, %Table:SB1% SB1
        WHERE 
            SA1.%NotDel% AND C5_FILIAL = %Exp:xFilial("SC5")% AND 
            SC5.%NotDel% AND C5_CLIENTE = A1_COD AND 
            //C5_CLIENTE >= %Exp:MV_PAR01% AND C5_CLIENTE <= %Exp:MV_PAR02% AND
            C6_FILIAL = %Exp:xFilial("SC6")% AND SC6.%NotDel% AND C6_NUM = C5_NUM AND 
            B1_FILIAL = %Exp:xFilial("SB1")% AND SB1.%NotDel% AND B1_COD = C6_PRODUTO
        ORDER BY 
            A1_FILIAL, A1_COD, C5_FILIAL, C5_NUM, C6_FILIAL, C6_ITEM

    ENDSQL //finaliza a query sql

Return Nil

/*/{Protheus.doc} GeraExcel
    (long_description)
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

    LOCAL oExcel    := FWMsExcel():new() //Instacia objeto da classe fwmsexcel
    LOCAL lOk       := .F. //variavel logica usada para validar se criou as linhas na planilha
    LOCAL cArq      := "" //variavel pra armazenar o nome do arquivo excel
    LOCAL cDirTemp  := "C:\spool\" //diretorio onde sera gerado o arquivo excel

    DbSelectArea( cAlias ) //usa o alias 
    dbGoTop() //vai pro topo da tabela

    oExcel:setFontSize( 12 ) //define fonte tamanho 12
    oExcel:setFont( "Arial" ) //define o tipo de fonte 
    oExcel:SetTitleBold( .t. ) //define o titulo em negrito
    oExcel:SetBGGeneralColor( "#ffa931" ) //define cor de fundo 
    oExcel:SetTitleFrColor( "#07031a" ) //define cor do titulo
    oExcel:SetLineFrColor( "#4f8a8b" ) //define cor da primeira linha
    oExcel:SetLine2FrColor( "#f4f6ff" ) //define cor da segunda linha

    oExcel:AddWorkSheet( "CLIENTES" ) //nome adiciona planilha 1 com nome clientes
    oExcel:AddTable( "CLIENTES" , "CLIENTES" ) //adiciona um tabela cliente na planilha clientes
    //define o nome das colunas da tabela clientes
    oExcel:AddColumn( "CLIENTES" , "CLIENTES" , "A1_COD" , 1 , 1 ) 
    oExcel:AddColumn( "CLIENTES" , "CLIENTES" , "A1_NOME" , 1 , 1 )
    oExcel:AddColumn( "CLIENTES" , "CLIENTES" , "A1_MCOMPRA" , 1 , 1 )

    oExcel:AddWorkSheet( "PEDIDOS" ) //nome adiciona planilha 1 com nome pedidos
    oExcel:AddTable( "PEDIDOS" , "PEDIDOS" ) //adiciona um tabela pedidos na planilha pedidos
    //define o nome das colunas da tabela clientes
    oExcel:AddColumn( "PEDIDOS" , "PEDIDOS" , "C5_NUM" , 1 , 1 )
    oExcel:AddColumn( "PEDIDOS" , "PEDIDOS" , "C5_EMISSAO" , 1 , 1 )
    oExcel:AddColumn( "PEDIDOS" , "PEDIDOS" , "C6_QTDVEN" , 1 , 1 )
    oExcel:AddColumn( "PEDIDOS" , "PEDIDOS" , "C6_VALOR" , 3 , 3 )
    oExcel:AddColumn( "PEDIDOS" , "PEDIDOS" , "B1_DESC" , 1 , 1 )

    //repeticao para percorrer a tabela
    While ( cAlias )->( !EOF() )
        //adiciona as linhas ta planilha clientes na tabela clientes
        oExcel:AddRow( "CLIENTES" , "CLIENTES" , { ( cAlias )->A1_COD ,;
                                                ( cAlias )->A1_NOME ,;
                                                ( cAlias )->A1_MCOMPRA } )
        //adiciona linhas da planilha pedidos na tabela pedidos
        oExcel:AddRow( "PEDIDOS" , "PEDIDOS" ,  { ( cAlias )->C5_NUM ,;
                                                ( cAlias )->C5_EMISSAO ,;
                                                ( cAlias )->C6_QTDVEN ,;
                                                ( cAlias )->C6_VALOR ,;
                                                ( cAlias )->B1_DESC } )
        //alimenta variavel logica indicando que adicinou as linhas                             
        lOk := .T. 
        DbSkip() //aponta proximo registro
    EndDo

    
    //gera o arquivo excel no diretorio definido em cDirTemp
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
        //se algum erro na geracao, manda mensagem na tela
        MsgAlert( "Algo deu errado!" )
    ENDIF

    //Fecha a tabela
    DbCloseArea()

Return Nil