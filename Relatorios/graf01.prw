#include "protheus.ch"

/*/{Protheus.doc} User Function Graf001
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
User Function Graf01()
    Local oChart
    Local oDlg
    Local aRand :=  {}

    DEFINE MSDIALOG oDlg PIXEL FROM 0,0 TO 500,700

        oChart := FwChartBar():New()
        oChart:Init( oDlg , .T. , .T. )
        oChart:SetTitle( "Vendas trimestral", CONTROL_ALIGN_CENTER )

        oChart:AddSerie( "Janeiro" , 21.144 )
        oChart:AddSerie( "Fevereiro" , 18.592 )
        oChart:AddSerie( "Marco" , 25.656 )

        oChart:SetLegend( CONTROL_ALIGN_LEFT )

        aAdd( aRand , { "199,199,070" , "022,022,008" } )
        aAdd( aRand , { "207,136,077" , "020,020,006" } )
        aAdd( aRand , { "141,225,078" , "017,019,010" } ) 

        oChart:oFwChartColor:aRandom := aRand
        oChart:oFwChartColor:SetColor( "Random" )

        oChart:Build() 

    ACTIVATE MSDIALOG oDlg CENTERED

Return 
