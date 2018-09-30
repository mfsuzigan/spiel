// ActionScript file

import com.spiel.Movimentacao;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.ListEvent;

[Bindable]
public var idMovimentacaoSelecionada:String;

public function povoarCamposDesfazer():void
{
	tabelaDesfazer.povoarUltimasAcoes(null, null);
	//var dP:ArrayCollection = (ArrayCollection)(tabelaDesfazer.dataProvider).pop();
}

public function tratarItemClick(event:ListEvent):void
{
	idMovimentacaoSelecionada = event.currentTarget.selectedItem.id.toString();
	botaoDesfazer.enabled = true;
}

public function confirmarDesfazer():void
{
	var mensagemConfirmacao:String;
	
	switch (tabelaDesfazer.selectedItem.codigo.toString())
	{
		case "0":
		
			mensagemConfirmacao = "Desfazer o registro de um veículo irá excluir este permanentemente do banco de dados. Prosseguir?";
			break;
			
		case "1":
		
			mensagemConfirmacao = "Ao desfazer uma operação de entrada, todos os dados financeiros associados serão recalculados. Prosseguir?";
			break;
			
		case "2":
			mensagemConfirmacao = "Ao desfazer uma operação de saída, todos os dados financeiros associados serão recalculados. Prosseguir?";
			break;
	}	
	
	Alert.show(mensagemConfirmacao, "Atenção", Alert.YES|Alert.NO, null, desfazer);
}

public function desfazer(event:CloseEvent):void
{	
	if (event.detail == Alert.NO)
		
		return;
	
	var mov:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	mov.obterDados(idMovimentacaoSelecionada);
	
	if (mov.desfazer())
	{
		switch (tabelaDesfazer.selectedItem.codigo.toString())
	{
		case "0":
		
			break;
			
		case "1":
		
			Application.application.nroVeiculosNoPatioHoje--;
			break;
			
		case "2":
			Application.application.nroBaixas--;
			break;
	}	
		
		Application.application.atualizarEstatisticas(true);
		Alert.show("Ação desfeita com sucesso.", "Ação desfeita");
		povoarCamposDesfazer();
		botaoDesfazer.enabled = false;
	}
}