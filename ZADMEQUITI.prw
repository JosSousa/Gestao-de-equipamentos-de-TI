#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ZADMEQUITI
Rotina para administracao dos ativos de TI.
Desenvolvida em MVC modelo 3, utilizando a as tabelas ZT1 e ZT2.
@type function
@version  1.0.0
@author Josue Oliveira
@since 23/03/2024
/*/
User Function ZADMEQUITI()
  Local oBrowse := FWLoadBrw("ZADMEQUITI") 
  oBrowse:Activate() 
Return

/*/{Protheus.doc} BrowseDef
Funcao responsavel por criacao do BroseDef.
@type function
@version 1.0.0
@author Josue Oliveira
@since 20/07/2024
/*/
Static Function BrowseDef()
  Local aArea := GetArea()
  Local oBrowse := FwMBrowse():New() 
  oBrowse:SetAlias("ZT1")
  oBrowse:SetDescription("Equipamentos de TI")
  oBrowse:SetMenudef("ZADMEQUITI")
  RestArea(aArea)
Return oBrowse

/*/{Protheus.doc} MenuDef
Funcao que cria o MenuDef
@type function
@version  1.0.0
@author Josue Oliveira
@since 20/07/2024
/*/
Static Function MenuDef()
  Local aMenu     := {}
  ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.ZADMEQUITI' OPERATION MODEL_OPERATION_VIEW ACCESS 0  //OPERATION 1
  ADD OPTION aMenu TITLE 'Incluir'    ACTION 'VIEWDEF.ZADMEQUITI' OPERATION MODEL_OPERATION_INSERT ACCESS 0  //OPERATION 3
  ADD OPTION aMenu TITLE 'Alterar'    ACTION 'VIEWDEF.ZADMEQUITI' OPERATION MODEL_OPERATION_UPDATE ACCESS 0  //OPERATION 4
Return aMenu

/*/{Protheus.doc} ModelDef
Funcao que cria a ModelDef
@type function
@version  1.0.0
@author Josue Oliveira
@since 20/07/2024
/*/
Static Function ModelDef()
  Local oModel := MPFormModel():New("MVCZT1M",/*bPre*/,  /*bPos*/,  /*bCommit*/,/*bCancel*/)
  Local oStZT1 := FwFormStruct(1,"ZT1")
  Local oStZT2 := FwFormStruct(1,"ZT2")

  oStZT2:SetProperty("ZT2_CODEQU",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, "ZT1->ZT1_CODEQU"))
  //Cria Modelos de dados, Cabecalho e Item.
  oModel:AddFields("ZT1MASTER",,oStZT1)
  oModel:AddGrid("ZT2DETAIL","ZT1MASTER",oStZT2,,/*{|oStZU2| Teste(oStZU2)}*/,,,)
  oModel:SetRelation("ZT2DETAIL",{{"ZT2_FILIAL","xFilial('ZT1')"},{"ZT2_CODEQU","ZT1_CODEQU"}},ZT2->(IndexKey(1)))

  //D/fine a chave primaria.
  oModel:SetPrimaryKey({"ZT2_FILIAL","ZT2_CODEQU"})

  //Combina os campos que nao podem se repetir, ficarem iguais.
  oModel:GetModel("ZT2DETAIL"):SetUniqueLine({"ZT2_CODEQU","ZT2_SEQUEN"})

  oModel:SetDescription("Equipamentos de TI")
  oModel:GetModel("ZT1MASTER"):SetDescription("Equipamentos de TI")
  oModel:GetModel("ZT2DETAIL"):SetDescription("Movimentos dos Equipamentos")
Return oModel

/*/{Protheus.doc} ViewDef
Funcao que cria a ViewDef
@type function
@version  1.0.0
@author Josue Oliveira
@since 20/07/2024
/*/
Static Function ViewDef()
  Local oView     := Nil

  //Instancia o Model da funcao desejada.
  Local oModel    := FwLoadModel("ZADMEQUITI")
  Local oStZT1    := FwFormStruct(2,"ZT1")
  Local oStZT2    := FwFormStruct(2,"ZT2")

  //Remove o campo ID para nao aparecer no Grid.
  oStZT2:RemoveField("ZT2_CODEQU")

  //Trava o campo de ITEM para que nao seja editado.
  oStZT2:SetProperty("ZT2_SEQUEN",    MVC_VIEW_CANCHANGE, .F.)

  //Instancia da funcao FwFormView para o objeto oView.
  oView := FwFormView():New()

  //Carrega o model importado para a View.
  oView:SetModel(oModel)

  //Cria as views de cabecalho e item, com as estruturas de dados criadas acima.
  oView:AddField("VIEWZT1",oStZT1,"ZT1MASTER")
  oView:AddGrid("VIEWZT2",oStZT2,"ZT2DETAIL")
  oView:AddIncrementField("ZT2DETAIL","ZT2_SEQUEN")

  //Define o tamanho dos BOX horizontais para CABECALHO E GRID.
  oView:CreateHorizontalBox("CABEC",30)
  oView:CreateHorizontalBox("GRID",70)

  //Relaciona as views criadas aos BOX criados.
  oView:SetOwnerView("VIEWZT1","CABEC")
  oView:SetOwnerView("VIEWZT2","GRID")

  //Define os titulos personalizados ao cabecalho e grid.
  oView:EnableTitleView("VIEWZT1","Equipamento de TI")
  oView:EnableTitleView("VIEWZT2","Movimentação do Equipamento")

Return oView
