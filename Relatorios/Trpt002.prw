#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} Trpt002
    (Este relatorio ir� imprimir as vendas para clientes do sistema)
    @type  Function
    @author Augusto
    @since 11/06/2020
    @version version
    @param 
    @return return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function trpt002()
    LOCAL oReport   := NIL
    LOCAL cPerg     := Padr("TRPT002",10) //padr adiciona 10 caracteres no nome, nesse caso "TRPT002   ", que � o padrao do campo da SX1
    LOCAL cAlias    := GetNextAlias()  

    /*
    SX1-TRPT002:
    MV_PAR01 = Cliente de ?
    MV_PAR02 = Cliente ate ?
    */
    Pergunte( cPerg , .F. ) //chama o grupo de pergunta configurado no SX1, o param .F. indica que o usu�rio deve clica no Outra A��es/Parametros para executar

    oReport := RptDef( cPerg , cAlias )
    oReport:PrintDialog()

Return Nil

/*/{Protheus.doc} RptPrint
    (long_description)
    @type  Static Function
    @author Augusto
    @since 11/06/2020
    @version version
    @param oReport
    @return return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RptPrint( oReport , cAlias , oSection1 , oSection2 )
    //LOCAL oSection1     := oReport:Section( 1 ) //Retorna objeto TRSection pelo indice da se��o 1
    //LOCAL oSection2     := oReport:Section( 2 ) //Retorna objeto TRSection pelo indice da se��o 2
    LOCAL cNumCod       := "" 

    oSection1:BeginQuery() //indica inicio da query para a se��o 1
    BEGINSQL ALIAS cAlias 

        SELECT A1_COD, A1_NOME, C5_NUM, C6_QTDVEN, C6_PRCVEN, B1_DESC, C6_ITEM, B1_COD
        FROM %Table:SA1% SA1, %Table:SC5% SC5, %Table:SC6% SC6, %Table:SB1% SB1
        WHERE SA1.%NotDel% AND C5_FILIAL = %Exp:xFilial("SC5")% AND 
        SC5.%NotDel% AND C5_CLIENTE = A1_COD AND 
        C5_CLIENTE >= %Exp:MV_PAR01% AND C5_CLIENTE <= %Exp:MV_PAR02% AND
        C6_FILIAL = %Exp:xFilial("SC6")% AND SC6.%NotDel% AND C6_NUM = C5_NUM AND 
        B1_FILIAL = %Exp:xFilial("SB1")% AND SB1.%NotDel% AND B1_COD = C6_PRODUTO
        ORDER BY A1_FILIAL, A1_COD, C5_FILIAL, C5_NUM, C6_FILIAL, C6_ITEM

    ENDSQL
    oSection1:EndQuery() //indica fim da query da se��o 2
    oSection2:SetParentQuery() //indica que a se��o filha herda a query da se��o pai

    DbSelectArea( cAlias )
    ( cAlias )->( DbGotop() )

    oReport:SetMeter( ( cAlias )->( LastRec() ) )

    While !EOF()
        IF oReport:Cancel()
            Exit
        ENDIF
        oSection1:Init()
        oReport:IncMeter()
        cNumCod := ( cAlias )->A1_COD
        IncProc( "Imprimindo Cliente " + Alltrim( ( cAlias )->A1_COD ) )

        oSection1:Cell( "A1_COD" ):SetValue( ( cAlias )->A1_COD )
        oSection1:Cell( "A1_NOME" ):SetValue( ( cAlias )->A1_NOME )
        oSection1:PrintLine()

        oSection2:init()
        
        while cNumCod == ( cAlias )->A1_COD

            oReport:incMeter( )
            IncProc( "Imprimindo dados dos pedidos " + AllTrim( ( cAlias )->C5_NUM ) )
            oSection2:Cell( "C5_NUM" ):SetValue( ( cAlias )->C5_NUM )
            oSection2:Cell( "C6_ITEM" ):SetValue( ( cAlias )->C6_ITEM )
            oSection2:Cell( "B1_COD" ):SetValue( ( cAlias )->B1_COD )
            oSection2:Cell( "B1_DESC" ):SetValue( ( cAlias )->B1_DESC )
            oSection2:Cell( "C6_PRCVEN" ):SetValue( ( cAlias )->C6_PRCVEN )
            oSection2:Cell( "C6_QTDVEN" ):SetValue( ( cAlias )->C6_QTDVEN )
            oSection2:PrintLine()

            ( cAlias )->( dbSkip() )

        endDo

        oSection2:Finish()
        oReport:ThinLine()
        oSection1:Finish()
    EndDo
Return Nil

/*/{Protheus.doc} RptDef
    (long_description)
    @type  Static Function
    @author Augusto
    @since 11/06/2020
    @version version
    @param cPerg
    @return oReport
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RptDef( cPerg , cAlias )
    LOCAL oReport       := NIL
    LOCAL cTitulo       := "Pedidos por cliente"
    LOCAL cDesc         := "este relatorio imprime a lista dos dados dos pedidos de vendas separados por cliente"
    LOCAL oSection1     := Nil
    LOCAL oSection2     := Nil

    //Instancia a classe TReport
    //Param do New            cNome_rel   ,cTiulo_rel,uParam  ,bMetod_print                             ,cDescri,lOrientacao    ,cTotalTexto    ,lTotalinLine   ,cPageTotText   ,lPageTotInLine ,lTotPgBreak    ,nColSpace
    oReport := TReport():New( "TRpt002"   ,cTitulo   ,cPerg   ,{|oReport| RptPrint( oReport , cAlias , oSection1 , oSection2 )} ,cDesc  ,               ,               ,               ,               ,               ,               ,           )

    //Define propriedade do relatorio
    oReport:SetPortrait() 

    //Instacia a classe TRSection
    //                              oParent     , cTitle        , {uTable}              , aOrder, lLoadCells, lLoadOrder, {||uTotalText}, lTotalInLine  , lHeaderPage   , lHeaderBreak  , lPageBreak, lLineBreak, nLeftMargin   , lLineStyle, nColSpace , lAutoSize , cCharSeparator, nLinesBefore  , nCols , nClrBack  , nClrFore  , nPercentage
    oSection1   := TRSection():new( oReport     , "Clientes"    , {"SA1"},              ,       ,           ,           ,               ,               ,               ,               ,           ,           ,               ,           ,           ,           ,               ,               ,       ,           ,           ,           , )
    oSection2   := TRSection():new( oSection1   , "Pedidos"     , {"SC5","SC6","SB1"}   ,       ,           ,           ,               ,               ,               ,               ,           ,           , 05            ,           ,           ,           ,               ,               ,       ,           ,           ,           , )

    //Define Celulas da Se��o 1 - Clientes
    //            oBjSection, NomeCell     , table , cel title  , Mask Cell , tamanho   ,
    TRCell():new( oSection1 , "A1_COD"     , cAlias , "Codigo"   , ""        , 06        , )
    TRCell():new( oSection1 , "A1_NOME"    , cAlias , "Nome"     , "@!"      , 40        , )

    //Define Celulas da Se��o 2 - Pedidos
    TRCell():new( oSection2 , "C5_NUM"     , cAlias , "Num Ped"      , ""                    , 06        , )
    TRCell():new( oSection2 , "C6_ITEM"    , cAlias , "Item Ped"     , ""                    , 05        , )
    TRCell():new( oSection2 , "B1_COD"     , cAlias , "Cod Prod"     , ""                    , 06        , )    
    TRCell():new( oSection2 , "B1_DESC"    , cAlias , "Desc Prod"    , "@!"                  , 36        , )
    TRCell():new( oSection2 , "C6_PRCVEN"  , cAlias , "Preco"        , "@E 999,999.99"       , 06        , )
    TRCell():new( oSection2 , "C6_QTDVEN"  , cAlias , "Quantidade"   , "@E 999,999.99"       , 30        , )

    oSection1:SetPageBreak(.F.) //Quebra Se��o

Return oReport