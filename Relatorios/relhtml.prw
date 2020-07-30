#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

/*/{Protheus.doc} RelHtml
    (long_description)
    @type  User Function
    @author Augusto
    @since 02/07/2020
    @version version
    @param , , 
    @return Nil, , 
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function RelHtml()

    LOCAL cAlias := GetNextAlias()
    
    IF MsgYesNo( "Deseja Imprimir o relatorio HTML? " )

        Processa( { ||MontaQuery( cAlias ) }, , "Processando..." )
        MsAguarde( { ||GeraHtml( cAlias ) } , , "Gerando arquivo HTML..." )

    ELSE
        Alert("<b>Abortado pelo usuário.</b>")
        Return Nil
    ENDIF
Return Nil

/*/{Protheus.doc} MontaQuery
    (long_description)
    @type  Static Function
    @author Augusto
    @since 02/07/2020
    @version version
    @param , , 
    @return Nil, , 
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function MontaQuery( cAlias )

    BEGINSQL Alias cAlias //Inicia SQL e grava resultado no cAlias
        SELECT TOP 100 
            B1_FILIAL FILIAL, B1_COD CODIGO, B1_DESC DESCRICAO, B1_TIPO TIPO, B1_GRUPO GRUPO, B1_ATIVO ATIVO
        FROM 
            %table:SB1% SB1
        WHERE 
            B1_FILIAL = %exp:xFilial( "SB1" )% AND B1_MSBLQL <>'1' AND D_E_L_E_T_=''
        GROUP BY 
            B1_FILIAL, B1_COD, B1_DESC, B1_TIPO, B1_GRUPO, B1_ATIVO
    ENDSQL

Return Nil

/*/{Protheus.doc} GeraHtml
    (long_description)
    @type  Static Function
    @author Augusto
    @since 02/07/2020
    @version version
    @param , , 
    @return Nil, , 
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GeraHtml( cAlias )
    LOCAL cHtml := ""
    LOCAL cCss  := ""
    LOCAL cFile := "C:\html\index.htm"
    LOCAL dData := Date()
    LOCAL nRet

    //inicia Css - cCss contem os atributos de estilo adicionado na tag <Style> posteriomente incrementado no cHtml
    cCss += "<style>" + CRLF
    cCss += "#table-b {" + CRLF
    cCss += "font-family: 'Lucida Sans Unicode', 'Lucida Grande', Sans-Serif;" + CRLF
    cCss += "font-size: 11px;" + CRLF
    cCss += "background: #fff; " + CRLF
    cCss += "margin: 10px; " + CRLF
    cCss += "width: 1000x; " + CRLF
    cCss += "border-collapse: collapse; " + CRLF
    cCss += "text-align: left; } " + CRLF
   
    cCss += "#table-b th { " + CRLF
    cCss += "font-size: 14px; " + CRLF
    cCss += "font-weight: bold; " + CRLF
    cCss += "color: #333; " + CRLF
    cCss += "padding: 10px 8px; " + CRLF
    cCss += "border-bottom: 2px solid #6678b1; } " + CRLF
   
    cCss += "#table-b td {  " + CRLF
    cCss += "border-bottom: 1px solid #ccc;" + CRLF
    cCss += "color: #333;   " + CRLF
    cCss += "padding: 6px 8px; } " + CRLF
   
    cCss += "#table-b tbody tr:hover td { " + CRLF
    cCss += "background-color: #90caf9; }" + CRLF
    cCss += "</style>" + CRLF 
    //Finaliza Css

    nHandle := fCreate( cFile )
    IF nHandle == -1
        MsgStop( "Falha ao criar o arquivo HTML " + Str( fError() ) )
        RETURN
    ENDIF

    //Montagem do arquivo html
    cHtml := '<html xmlns="http://www.w3.org/1999/xhtml">' + CRLF
    cHtml += '<head>' + CRLF
    cHtml += '<meta charset="utf-8">' + CRLF   
    cHtml += '<title>Relatorio de produtos</title> ' + CRLF
    //cHtml += "<link rel='stylesheet' href='estilo.css' />" + CRLF

    //incremente tag <style> contida na variavel cCss
    cHtml += cCss

    cHtml += "</head>" + CRLF
    cHtml += "<body>" + CRLF
    cHtml += "<div id='cabec'>" + CRLF   
    cHtml += "<center>" + CRLF
    cHtml += "<table width='331' id='table-b' summary='Produtos'>" + CRLF  
    cHtml += "<tr>" + CRLF
    cHtml += "<td width='252' scope='row'><font face='arial'><b>Parametros:</b></font><br />" + CRLF
    cHtml += "<font face='arial'>Data de atualizacao: " + DToC(dData) + " </font><br /> <font face='arial'></font></td>" + CRLF
    cHtml += "</tr>" + CRLF
    cHtml += "</table>" + CRLF
    cHtml += "</center>" + CRLF
    cHtml += "<p align=center><font face='Lucida Sans Unicode' size='6'><u>Relatorio de Produtos</u></font></p> " + CRLF
    cHtml += "<center>" + CRLF
    cHtml += "<table width='1000' id='table-b' summary='Produtos'>" + CRLF
    cHtml += "<tr align='center'>" + CRLF
    cHtml += "<th width='72' scope='row'>Filial</th>" + CRLF
    cHtml += "<th width='100' scope='row'>Codigo</th> " + CRLF
    cHtml += "<th width='200'>Descricao</th>" + CRLF
    cHtml += "<th width='72'>Tipo</th>" + CRLF
    cHtml += "<th width='72'>Grupo</th>" + CRLF
    cHtml += "<th width='72'>Ativo</th>" + CRLF
    cHtml += "</tr>" + CRLF

    FWRITE( nHandle, cHtml )
    cHtml := ""

    DbSelectArea( cAlias )

    WHILE !EOF()
        cHtml += "<tr><td>" + ( cAlias )->FILIAL + "</td>" + CRLF
        cHtml += "<td>" + ( cAlias )->CODIGO + "</td>" + CRLF
        cHtml += "<td>" + ( cAlias )->DESCRICAO + "</td>" + CRLF
        cHtml += "<td>" + ( cAlias )->TIPO + "</td>" + CRLF
        cHtml += "<td>" + ( cAlias )->GRUPO + "</td>" + CRLF
        cHtml += "<td>" + ( cAlias )->ATIVO + "</td>" + CRLF

        FWRITE( nHandle, cHtml )
        cHtml := ""
        DBSKIP()
    ENDDO

    cHtml += "</center>" + CRLF
    cHtml += "</div>" + CRLF
    cHtml += "</body>" + CRLF
    cHtml += "</html>" + CRLF
    FWRITE( nHandle, cHtml )

    FClose( nHandle )
    DBCLOSEAREA( )

    MSGINFO( "Arquivo gerado com sucesso!" )

    nRet := ShellExecute( "Open" , cFile , "" , "C:\html\index.htm" , 1 )

Return nRet