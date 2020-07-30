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
    Private nColFin     := 550
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

    ACTIVATE MSDIALOG oDlg CENTERED Init ( oChart:SaveToPng( 0 , 0 , nLargura , nAltura , cDiretorio + "graf02.png" ) , oDlg:End() )

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
        SELECT F2_CLIENTE CLIENTE, A1_NOME NOME, SUM(F2_VALBRUT) TOTAL 
        FROM %TABLE:SF2% SF2 INNER JOIN %TABLE:SA1%
            ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA 
        WHERE SF2.%NOTDEL% AND SA1.%NOTDEL% AND 
            F2_EMISSAO >= '20200101' AND F2_EMISSAO <= '20200105'
        GROUP BY F2_CLIENTE, A1_NOME
    ENDSQL

Return
