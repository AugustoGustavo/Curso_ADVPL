#INCLUDE "Protheus.ch"
#INCLUDE "rptdef.ch"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} User Function Gra02
    (long_description)
    @type  Function
    @author Augusto
    @since 26/07/2020
    @version version
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function Graf02()
    Local aArea         := GetArea()
    Local cAlias        := GetNextAlias()
    Local cNomeRel      := "Rel_Teste_" + dToS( Date() ) + StrTran( Time(), ":" , "-" )
    Local cDiretorio    := GetTempPath()
    Local nLinCab       := 025
    Local nAltura       := 250
    Local nLargura      := 1050
    Local aRand         := {}
    Local oDlg

    Private cHoraEx     := Time()
    Private nPagAtu     := 1 
    Private oPrintPvt
    Private oFontRod    := TFont():New( "ARIAL" , , -06 , , .F. )
    Private oFontTit    := TFont():New( "ARIAL" , , -20 , , .T. )

    Private nLinAtu     := 0
    Private nLinFin     := 820
    Private nColIni     := 010
    Private nColFin     := 500
    Private nColMeio    := ( nColFin  - nColIni) / 2

    Processa( {  || MontaQuery( cAlias ) } , , "Processando..." ) 

    oPrintPvt := FWMSPrinter():New( cNomeRel , IMP_PDF , .F. , , .T. , , @oPrintPvt , , , , , .T. , )
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(9)
    oPrintPvt:SetMargin(60,60,60,60)
    oPrintPvt:StartPage()

    oPrintPvt:SayAlign( nLinCab , nColMeio-150 , "Relatorio Grafico em ADVPL" , oFontTit , 300, 20 , RGB( 0 , 0 , 255 ) , 2 , 0 ) 
    nLinCab += 35
    nLinAtu := nLinCab

    If File( cDiretorio + "graf02.png" )
        fErase( cDiretorio + "graf02.png" )
    EndIf

    DEFINE MSDIALOG oDlg PIXEL FROM 0,0 TO nAltura,nLargura

        oChart := FwChartBar():New()
        oChart:Init( oDlg , .T. , .T. )
        oChart:SetTitle( "Vendas x Clientes", CONTROL_ALIGN_CENTER )

        while (cAlias)->(!EOF()) 
            oChart:AddSerie( (cAlias)->NOME , (cAlias)->TOTAL )
            oChart:AddSerie( (cAlias)->NOME , (cAlias)->TOTAL )
            (cAlias)->(DbSkip())
        endDo

        oChart:SetLegend( CONTROL_ALIGN_LEFT )

        aAdd( aRand , { "199,199,070" , "022,022,008" } )
        aAdd( aRand , { "207,136,077" , "020,020,006" } )
        aAdd( aRand , { "141,225,078" , "017,019,010" } )
        aAdd( aRand , { "166,085,082" , "017,007,007" } )
        aAdd( aRand , { "084,120,164" , "007,013,017" } ) 

        oChart:oFwChartColor:aRandom := aRand
        oChart:oFwChartColor:SetColor( "Random" )

        oChart:Build()

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( oChart:SaveToPng( 0 , 0 , nLargura , nAltura , cDiretorio + "graf02.png" ) , oDlg:End() )

    oPrintPvt:SayBitmap( nLinAtu , nColIni , cDiretorio + "graf02.png" , nLargura/2 , nAltura/1.6 )
    nLinAtu += nAltura + 5  

    RodaPe()

    oPrintPvt:Preview()

    RestArea(aArea)

Return 

/*/{Protheus.doc} MontaQueryu
    (long_description)
    @type  Static Function
    @author Augusto
    @since 26/07/2020
    @version version
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function MontaQuery( cAlias )

    BEGINSQL ALIAS cAlias
        SELECT TOP 50 F2_CLIENTE AS CLIENTE, A1_NOME AS NOME, SUM(F2_VALBRUT) AS TOTAL 
        FROM %Table:SF2% SF2 INNER JOIN %Table:SA1% SA1
            ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA 
        WHERE 
            F2_EMISSAO >= '20200102' AND F2_EMISSAO <= '20200102' AND 
            F2_CLIENTE <> '000001' AND
            SF2.%NotDel% AND SA1.%NotDel%
        GROUP BY F2_CLIENTE, A1_NOME
    ENDSQL

Return

/*/{Protheus.doc} Rodape    
    (long_description)
    @type  Static Function
    @author Augusto
    @since 29/07/2020
    @version version
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RodaPe()
    Local nLinha := nLinFin
    Local cTitulo := ""

    oPrintPvt:Line( nLinha , nColIni , nLinha , nColFin , RGB(0,0,200) )
    nLinha += 4

    cTitulo := "Relatório Clientes x Vendas - " + dToC(dDataBase) + " - " + cHoraEx + " - " + cUserName 

    oPrintPvt:SayAlign( nLinha , nColIni , cTitulo , oFontRod , 250 , 07 , , 0 , )

    cTitulo := "Pagina " + cValToChar(nPagAtu)
    oPrintPvt:SayAlign( nLinha , nColFin , cTitulo , oFontRod , 040 , 07 , , 1 , )

    oPrintPvt:EndPage()
    nPagAtu++
    
Return
