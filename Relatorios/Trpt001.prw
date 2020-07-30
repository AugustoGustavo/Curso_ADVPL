#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} TRpt001
    (long_description)
    @type  Function
    @author Augusto
    @since 08/06/2020
    @version version
    @param 
    @return return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TRpt001()
    LOCAL oReport   := Nil              //objeto que será defino com a classe TReport
    LOCAL cAlias    :=  getNextAlias()  //Pega nome/alias para criar tabela temporaria

    oReport := RptDef(cAlias)           //Função que define estrutura do relatório
    oReport:PrintDialog()               //Chama função que apresenta tela inicial do TReport
Return NIL

/*/{Protheus.doc} RPrint
    (long_description)
    @type  Static Function
    @author Augusto
    @since 08/06/2020
    @version version
    @param oReport, cAlias
    @return return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RPrint(oReport, cAlias)

    LOCAL oSecao1     :=  oReport:Section(1)    //Instancia a classe Section com indice 1 definida no RptDef()

    oSecao1:BeginQuery()    //Inicia query Embedded SQL na seção 1
        BEGINSQL Alias cAlias //Inicia SQL e grava resultado no cAlias
            SELECT TOP 100 
                B1_FILIAL FILIAL, B1_COD CODIGO, B1_DESC DESCRICAO, B1_TIPO TIPO, B1_ATIVO ATIVO
            FROM 
                %table:SB1% SB1
            WHERE 
                B1_FILIAL = '' AND B1_MSBLQL <>'1' AND D_E_L_E_T_=''
            GROUP BY 
                B1_FILIAL, B1_COD, B1_DESC, B1_TIPO, B1_ATIVO
        ENDSQL
    oSecao1:EndQuery()  	                    //Finaliza query
    oReport:SetMeter((cAlias)->(RECCOUNT()))    //adiciona regua de processamento
    oSecao1:Print()                             //Imprime a seção 1
Return Nil

/*/{Protheus.doc} RptDef
    (long_description)
    @type  Static Function
    @author Augusto
    @since 08/06/2020
    @version version
    @param cAlias
    @return return oRpt
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RptDef(cAlias)
    LOCAL cTitulo   :=  "Produtos Ativos"                                       //Titulo do relatorio  
    LOCAL cDesc     :=  "Imprime relatório dos produtos ativos não-bloqueados"  //Descricao do relatorio 
    LOCAL oRpt      //Variavel do tipo objeto que irá instanciar a classe TReport
    LOCAL oSection1 //Variavel do tipo objeto que irá instanciar a classe TRSection

    //Instancia a classe TReport
    //Param do New         cNome_rel   ,cTiulo_rel,uParam  ,bMetod_print                     ,cDescri,lOrientacao    ,cTotalTexto    ,lTotalinLine   ,cPageTotText   ,lPageTotInLine ,lTotPgBreak    ,nColSpace
    oRpt := TReport():New( "TRpt001"   ,cTitulo   ,        ,{|oRpt| Rprint(oRpt, cAlias)}    ,cDesc  ,               ,               ,               ,               ,               ,               ,           )
    
    //Instacia a classe TRSection
    oSection1   := TRSection():new( oRpt   , "Produtos" , {"SB1"} )

    //Por meio da classe TRCell, define as celulas do relatorio atribuindo os nomes das colunas usadas no Embedded SQL da função Rptin()  
    //            oBjSection, NomeCell     , table , cel title  , Mask Cell , tamanho   ,
    TRCell():new( oSection1 , "FILIAL"     , "SB1" , "Filial"   , ""        , 02        , )
    TRCell():new( oSection1 , "CODIGO"     , "SB1" , "Codigo"   , ""        , 15        , )
    TRCell():new( oSection1 , "DESCRICAO"  , "SB1" , "Descricao", ""        , 36        , )
    TRCell():new( oSection1 , "TIPO"       , "SB1" , "Tipo"     , ""        , 02        , )
    TRCell():new( oSection1 , "ATIVO"      , "SB1" , "Ativo"    , ""        , 02        , )

Return oRpt