#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} RelTxt
    (Esta função inicia o tratamento para geração do arquivo txt por meio da Static function geraarq())
    @type  User Function
    @author Augusto
    @since 03/06/2020
    @version version
    @param 
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
USER FUNCTION RelTxt()

    IF MSGYESNO(DECODEUTF8("Esta função irá gerar um arquivo txt do cadastro de produtos.")+CRLF+"Deseja continuar?","Gerar do TXT")
        Processa( {||MontaQry()} , , "Processando dados..." )
        MsAguarde( {|| GeraArq()} , , "Gerando TXT...")
    ELSE
        ALERT("Cancelada pelo operador")
        RETURN
    ENDIF   

RETURN NIL

/*/{Protheus.doc} GeraArq
    (Esta função gera um arquivo txt em disco)
    @type  Static Function
    @author Augusto
    @since 03/06/2020
    @version version
    @param 
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GeraArq()

    LOCAL cDir      := "C:\TEMP\"
    LOCAL cNomeArq  := "produtos_p12_v2.txt"
    LOCAL nHandle   := FCREATE(cDir+cNomeArq)

    IF nHandle < 0 
        MSGALERT(DECODEUTF8("Não foi possível criar o arquivo no diretório ") + cDir + CRLF + "Por favor, verifique o diretorio especificado","OPS! Algo deu errado...")
        IF MSGNOYES( "Deseja finalizar o programa?", "Sair?" )
            RETURN
        ELSE
            RETURN u_RelTxt()
        ENDIF
    ELSE
        WHILE TMP->(!EOF())
            FWRITE( nHandle, TMP->(FILIAL) + " | " + TMP->(CODIGO) + " | " + TMP->(DESCRICAO) + CRLF )
            TMP->(DBSKIP())
        ENDDO
        FCLOSE( nHandle )
        DBCloseArea()
    ENDIF

    IF FILE(cDir+cNomeArq)
        MSGINFO( "Arquivo foi gerado com sucesso" + CRLF + cDir + cNomeArq,"Deu certo!" )
    ELSE
        MSGALERT( DECODEUTF8( "O diretório existe mas o arquivo não foi criado...", "OPS!" ) )
        RETURN
    ENDIF
    
RETURN NIL

/*/{Protheus.doc} MontaQry
    (description)
    @type  Static Function
    @author Augusto
    @since 04/06/2020
    @version version
    @param 
    @return return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function MontaQry()
    Local cQuery := ""

    cQuery := " SELECT B1_FILIAL AS FILIAL, B1_COD AS CODIGO, "
    cQuery += " B1_DESC AS DESCRICAO "
    cQuery += " FROM SB1010 WHERE D_E_L_E_T_ = ''"
    cQuery := ChangeQuery(cQuery)
    DBUSEAREA( .T., "TOPCONN", TCGENQRY( , , cQuery ), "TMP", .F., .T. )
    
Return NIL