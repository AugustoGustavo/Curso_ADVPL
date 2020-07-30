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
    Local cNomeRel      := "Rel_Teste_" + dToS( Date() ) + StrTran( Time(), ":" , "-" )
    Local cDiretorio    := GetTempPath()
    Local nLinCab       := 025
    Local nAltura       := 250
    Local nLargura      := 1050
    Local aRand         := {}

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

    Processa( {  || MontaQuery() } , , "Processando..." ) 

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

    oPrintPvt:Print()

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
Static Function MontaQuery()
    
Return 
